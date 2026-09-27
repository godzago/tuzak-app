import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/features/analysis/application/threat_enriched_analyzer.dart';
import 'package:tuzak/features/analysis/data/asset_rule_adapter.dart';
import 'package:tuzak/features/analysis/domain/engine/entity_extractor.dart';
import 'package:tuzak/features/analysis/domain/engine/rule_engine.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';
import 'package:tuzak/services/threat_api_service.dart';

const reportedHost = 'toria.apple03cloudstore.com';

Future<ThreatMatch?> unexpectedPhone(
  String _, {
  CancelToken? cancelToken,
}) async => throw StateError('unexpected phone lookup');

void main() {
  final data =
      jsonDecode(File('assets/data/rules.json').readAsStringSync())
          as Map<String, dynamic>;
  final rules = parseAssetRules(data, null);
  final engine = RuleEngine(rules);

  test(
    'extracts the full reported subdomain from bare, HTTPS and authority forms',
    () {
      for (final text in [
        reportedHost,
        'Apple iCloud: https://$reportedHost/device?token=private#fragment',
        'https://user:password@$reportedHost:443/private',
        '(https://TORIA.APPLE03CLOUDSTORE.COM./)',
      ]) {
        final entities = const EntityExtractor().extract(text);
        expect(entities.hosts, {reportedHost});
        expect(entities.urls.single.host, reportedHost);
        expect(
          ThreatApiService.domainForQuery(entities.urls.single.host),
          reportedHost,
        );
      }
      expect(
        const EntityExtractor().extract('person@$reportedHost').hosts,
        isEmpty,
      );
    },
  );

  test(
    'reported domain is high offline without relying on message keywords',
    () {
      final result = engine.analyze(reportedHost);
      expect(result.level, RiskLevel.high);
      expect(result.score, .7525);
      expect(
        result.reasons,
        containsAll([ReasonCode.brandMismatch, ReasonCode.lookalike]),
      );
    },
  );

  test(
    'long digit runs cannot cause regex backtracking or arbitrary brand matches',
    () {
      final result = engine.analyze('https://${'9' * 50}applee.example');
      expect(result.reasons, isNot(contains(ReasonCode.brandMismatch)));
      expect(result.reasons, isNot(contains(ReasonCode.lookalike)));
      expect(
        engine.analyze('https://apple${'9' * 50}.example').level,
        RiskLevel.high,
      );
    },
  );

  test('reported domain with mocked criticality 2 becomes dangerous', () async {
    final analyzer = ThreatEnrichedAnalyzer(
      analyzeLocal: (text) async => engine.analyze(text),
      checkDomain: (host, {cancelToken}) async {
        expect(host, reportedHost);
        return const ThreatMatch(
          found: true,
          criticalityLevel: 2,
          category: 'MD',
        );
      },
      checkPhone: unexpectedPhone,
    );
    final result = await analyzer.analyze(
      'https://$reportedHost/path?private=123',
    );
    expect(result.level, RiskLevel.dangerous);
    expect(result.reasons.first, ReasonCode.officialThreat);
    expect(result.threatCheck, ThreatCheckStatus.complete);
  });

  test(
    'actual severity 8 record is at least high even with neutral local rules',
    () async {
      final analyzer = ThreatEnrichedAnalyzer(
        analyzeLocal: (_) async => AnalysisResult(
          level: RiskLevel.low,
          score: 0,
          rulesVersion: 'test',
          reasons: [ReasonCode.noSignals],
        ),
        checkDomain: (_, {cancelToken}) async =>
            const ThreatMatch(found: true, criticalityLevel: 8, category: 'MD'),
        checkPhone: unexpectedPhone,
      );
      final result = await analyzer.analyze(reportedHost);
      expect(result.level, RiskLevel.high);
      expect(result.reasons, [ReasonCode.officialThreat]);
    },
  );

  test(
    'reported domain remains high when four-second API deadline expires',
    () {
      fakeAsync((clock) {
        final analyzer = ThreatEnrichedAnalyzer(
          analyzeLocal: (text) async => engine.analyze(text),
          checkDomain: (_, {cancelToken}) async {
            await cancelToken!.whenCancel;
            return null;
          },
          checkPhone: unexpectedPhone,
        );
        AnalysisResult? result;
        analyzer.analyze(reportedHost).then((r) => result = r);
        clock.flushMicrotasks();
        clock.elapse(const Duration(seconds: 4));
        expect(result?.level, RiskLevel.high);
        expect(result?.threatCheck, ThreatCheckStatus.unavailable);
      });
    },
  );

  test('generic structural detection does not need any known brands', () {
    final withoutBrands = {
      ...data,
      'brands': [
        {
          'name': 'Unrelated',
          'aliases': ['unrelated'],
          'host_tokens': ['unrelated'],
          'official': ['unrelated.example'],
        },
      ],
    };
    final genericEngine = RuleEngine(parseAssetRules(withoutBrands, null));
    for (final message in [
      'https://unlistedbrand.com.login.attacker.example',
      'https://unlistedbrand.co.uk.attacker.example',
      'NovelBrand hesabı: https://login.novelbrand.accounts.verify.attacker.example',
    ]) {
      final result = genericEngine.analyze(message);
      expect(
        result.level.index,
        greaterThanOrEqualTo(RiskLevel.suspicious.index),
      );
      expect(result.reasons, contains(ReasonCode.deceptiveSubdomain));
    }
    for (final message in [
      'https://img.eu.west.assets.cdn.example/photo',
      'https://unlistedbrand.com/path/attacker.example',
      'https://company.example?q=brand.com.evil.example',
    ]) {
      expect(
        genericEngine.analyze(message).reasons,
        isNot(contains(ReasonCode.deceptiveSubdomain)),
      );
    }
  });
}
