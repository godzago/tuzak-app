import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/services/threat_api_service.dart';
import 'package:tuzak/features/analysis/application/threat_enriched_analyzer.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';

AnalysisResult local({
  RiskLevel level = RiskLevel.low,
  CheckedEntity checkedEntity = CheckedEntity.message,
}) => AnalysisResult(
  level: level,
  score: level == RiskLevel.low ? 0 : .8,
  rulesVersion: 'synthetic',
  usomChecked: false,
  checkedEntity: checkedEntity,
  reasons: level == RiskLevel.low
      ? [ReasonCode.noSignals]
      : [ReasonCode.urgency, ReasonCode.credentials, ReasonCode.shortLink],
);

Future<ThreatMatch?> unexpectedPhone(
  String _, {
  CancelToken? cancelToken,
}) async => throw StateError('unexpected phone lookup');

void main() {
  test(
    'every link and phone starts a lookup without sending paths or prose',
    () async {
      var localDone = false;
      final hosts = <String>[];
      final phones = <String>[];
      final analyzer = ThreatEnrichedAnalyzer(
        analyzeLocal: (_) async {
          localDone = true;
          return local();
        },
        checkDomain: (domain, {cancelToken}) async {
          expect(localDone, isTrue);
          hosts.add(domain);
          return const ThreatMatch(found: false);
        },
        checkPhone: (phone, {cancelToken}) async {
          expect(localDone, isTrue);
          phones.add(phone);
          return const ThreatMatch(
            found: false,
            entityType: ThreatEntityType.phone,
          );
        },
      );
      final result = await analyzer.analyze(
        'Secret message https://user:password@RISK.EXAMPLE/private?code=123#private '
        'https://risk.example/other https://[2001:db8::1]/ https://127.0.0.1/ '
        'https://other.example/a person@email.example '
        '+90 532 123 45 67 and 0533 765 43 21',
      );
      expect(hosts, [
        'risk.example',
        'risk.example',
        '2001:db8::1',
        '127.0.0.1',
        'other.example',
      ]);
      expect(phones, ['905321234567', '905337654321']);
      expect(result.level, RiskLevel.low);
      expect(result.threatCheck, ThreatCheckStatus.complete);
      expect(result.reasons, [ReasonCode.officialClean]);
    },
  );

  test(
    'critical hit takes precedence and preserves score and three reasons',
    () async {
      final analyzer = ThreatEnrichedAnalyzer(
        analyzeLocal: (_) async => local(level: RiskLevel.high),
        checkDomain: (_, {cancelToken}) async =>
            const ThreatMatch(found: true, criticalityLevel: 3, category: 'PH'),
        checkPhone: unexpectedPhone,
      );
      final result = await analyzer.analyze('https://risk.example');
      expect(result.level, RiskLevel.dangerous);
      expect(result.score, .8);
      expect(result.reasons, [
        ReasonCode.officialThreat,
        ReasonCode.urgency,
        ReasonCode.credentials,
      ]);
      expect(result.threatMatch?.category, 'PH');
    },
  );

  test('a critical phone hit escalates and preserves number context', () async {
    final analyzer = ThreatEnrichedAnalyzer(
      analyzeLocal: (_) async => local(checkedEntity: CheckedEntity.number),
      checkDomain: (_, {cancelToken}) async =>
          throw StateError('unexpected link lookup'),
      checkPhone: (_, {cancelToken}) async => const ThreatMatch(
        found: true,
        criticalityLevel: 2,
        entityType: ThreatEntityType.phone,
      ),
    );
    final result = await analyzer.analyze('0532 123 45 67');
    expect(result.level, RiskLevel.dangerous);
    expect(result.checkedEntity, CheckedEntity.number);
    expect(result.reasons.first, ReasonCode.officialThreat);
  });

  test(
    'noncritical/missing severity warns, but cannot lower existing risk',
    () async {
      for (final severity in [null, 4, 10]) {
        for (final level in RiskLevel.values) {
          final analyzer = ThreatEnrichedAnalyzer(
            analyzeLocal: (_) async => local(level: level),
            checkDomain: (_, {cancelToken}) async =>
                ThreatMatch(found: true, criticalityLevel: severity),
            checkPhone: unexpectedPhone,
          );
          final result = await analyzer.analyze('https://risk.example');
          expect(
            result.level,
            level.index < RiskLevel.high.index ? RiskLevel.high : level,
          );
          expect(result.reasons, contains(ReasonCode.officialThreat));
          expect(result.reasons, isNot(contains(ReasonCode.noSignals)));
        }
      }
    },
  );

  test('no API entity keeps analysis wholly local', () async {
    final baseline = local();
    final analyzer = ThreatEnrichedAnalyzer(
      analyzeLocal: (_) async => baseline,
      checkDomain: (_, {cancelToken}) => throw StateError('should not call'),
      checkPhone: unexpectedPhone,
    );
    expect(await analyzer.analyze('Merhaba'), same(baseline));
  });

  test('connection failures preserve local risk and never throw', () async {
    final baseline = local(level: RiskLevel.high);
    final analyzer = ThreatEnrichedAnalyzer(
      analyzeLocal: (_) async => baseline,
      checkDomain: (domain, {cancelToken}) async {
        return null;
      },
      checkPhone: unexpectedPhone,
    );
    final result = await analyzer.analyze(
      'https://first.example https://second.example',
    );
    expect(result.level, baseline.level);
    expect(result.score, baseline.score);
    expect(result.reasons, baseline.reasons);
    expect(result.threatCheck, ThreatCheckStatus.unavailable);
  });

  test(
    'API/protocol failures are not silently downgraded to local-only',
    () async {
      final analyzer = ThreatEnrichedAnalyzer(
        analyzeLocal: (_) async => local(),
        checkDomain: (_, {cancelToken}) async =>
            throw const ThreatApiException('bad response'),
        checkPhone: unexpectedPhone,
      );
      await expectLater(
        analyzer.analyze('https://risk.example'),
        throwsA(isA<ThreatApiException>()),
      );
    },
  );

  test(
    'parallel deadline retains timely hit, cancels slow calls, ignores late replies',
    () {
      fakeAsync((clock) {
        final pending = <String, Completer<ThreatMatch?>>{};
        final tokens = <CancelToken>[];
        final analyzer = ThreatEnrichedAnalyzer(
          analyzeLocal: (_) async => local(),
          checkDomain: (domain, {cancelToken}) {
            tokens.add(cancelToken!);
            return (pending[domain] = Completer<ThreatMatch?>()).future;
          },
          checkPhone: unexpectedPhone,
        );
        AnalysisResult? result;
        analyzer
            .analyze(
              'https://first.example https://second.example https://third.example',
            )
            .then((r) => result = r);
        clock.flushMicrotasks();
        expect(pending.length, 3); // All started before any reply.
        pending['first.example']!.complete(
          const ThreatMatch(found: true, criticalityLevel: 1, category: 'MD'),
        );
        clock.flushMicrotasks();
        clock.elapse(const Duration(milliseconds: 3999));
        expect(result, isNull);
        clock.elapse(const Duration(milliseconds: 1));
        expect(result?.level, RiskLevel.dangerous);
        expect(result?.threatCheck, ThreatCheckStatus.partial);
        expect(tokens.every((token) => token.isCancelled), isTrue);
        final finalResult = result;
        pending['second.example']!.complete(const ThreatMatch(found: false));
        pending['third.example']!.completeError(StateError('late error'));
        clock.flushMicrotasks();
        expect(result, same(finalResult));
        expect(result?.threatCheck, ThreatCheckStatus.partial);
      });
    },
  );

  test('disposing during requests cancels every active request', () async {
    final tokens = <CancelToken>[];
    final analyzer = ThreatEnrichedAnalyzer(
      analyzeLocal: (_) async => local(),
      checkDomain: (_, {cancelToken}) async {
        tokens.add(cancelToken!);
        await cancelToken.whenCancel;
        return null;
      },
      checkPhone: unexpectedPhone,
    );
    final future = analyzer.analyze('https://one.example https://two.example');
    await Future<void>.delayed(Duration.zero);
    expect(tokens.length, 2);
    analyzer.dispose();
    expect(tokens.every((token) => token.isCancelled), isTrue);
    expect((await future).threatCheck, ThreatCheckStatus.unavailable);
  });
}
