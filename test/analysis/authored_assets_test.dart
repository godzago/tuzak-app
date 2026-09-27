import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/app/tuzak_app.dart';
import 'package:tuzak/features/analysis/application/analysis_controller.dart';
import 'package:tuzak/features/analysis/data/asset_rule_adapter.dart';
import 'package:tuzak/features/analysis/data/rule_repository.dart';
import 'package:tuzak/features/analysis/domain/engine/entity_extractor.dart';
import 'package:tuzak/features/analysis/domain/engine/host_normalizer.dart';
import 'package:tuzak/features/analysis/domain/engine/rule_engine.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';

Map<String, dynamic> asset(String file) =>
    jsonDecode(File('assets/data/$file.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cases =
      jsonDecode(File('test/fixtures/test_cases.json').readAsStringSync())
          as List;
  final synthetic = RuleEngine(
    parseAssetRules(asset('rules'), asset('usom'), allowSyntheticUsom: true),
  );
  final normal = RuleEngine(parseAssetRules(asset('rules'), asset('usom')));
  for (final entry in cases) {
    test('authored ${entry['id']}', () {
      final result = synthetic.analyze(entry['text'] as String);
      final expected = RiskLevel.values.byName(
        (entry['expect_min'] ?? entry['expect_max']) as String,
      );
      expect(
        result.level.index,
        entry.containsKey('expect_min')
            ? greaterThanOrEqualTo(expected.index)
            : lessThanOrEqualTo(expected.index),
      );
      expect(result.reasons.length, lessThanOrEqualTo(3));
    });
  }
  test('placeholder does not produce a threat match in normal use', () {
    final result = normal.analyze('https://usom-placeholder-01.example');
    expect(result.level, isNot(RiskLevel.dangerous));
    expect(result.usomChecked, isFalse);
    expect(result.reasons, isNot(contains(ReasonCode.usom)));
  });
  test('missing or broken optional USOM preserves honest local analysis', () {
    for (final usom in [
      null,
      <String, dynamic>{},
      {
        'version': '1.0.0',
        'generated': 'bad',
        'entries': ['wrong'],
      },
    ]) {
      final rules = parseAssetRules(asset('rules'), usom);
      expect(rules.ready, isTrue);
      expect(rules.usomAvailable, isFalse);
      expect(
        RuleEngine(rules).analyze('Şifrenizi bana gönderin').level,
        RiskLevel.high,
      );
    }
  });
  test('invalid required rules fail instead of giving low risk', () {
    final data = asset('rules');
    (data['text_categories'] as Map)['code_request']['patterns'] = ['['];
    expect(() => parseAssetRules(data, asset('usom')), throwsFormatException);
    final unsupported = asset('rules')..['version'] = '99.0.0';
    expect(
      () => parseAssetRules(unsupported, asset('usom')),
      throwsFormatException,
    );
    final invalidWeight = asset('rules');
    invalidWeight['url_signals']['at_sign']['weight'] = 3;
    expect(
      () => parseAssetRules(invalidWeight, asset('usom')),
      throwsFormatException,
    );
  });
  test(
    'repetition does not inflate risk; official URL cannot erase requests',
    () {
      const request = 'Doğrulama kodunu bana gönder';
      expect(
        normal.analyze('$request. $request').score,
        normal.analyze(request).score,
      );
      expect(
        normal.analyze('Şifrenizi bana gönderin https://ptt.gov.tr').level,
        RiskLevel.high,
      );
      expect(
        normal
            .analyze('PTT https://ptt.gov.tr https://ptt-giris.example')
            .level,
        isNot(RiskLevel.low),
      );
    },
  );
  test(
    'URL authority, IPv6, Unicode and schemeless links are extracted offline',
    () {
      expect(normalizeHost('ÖRNEK.example.'), 'xn--rnek-4qa.example');
      expect(normalizeHost('[2001:0db8:0:0:0:0:0:1]'), '2001:db8::1');
      expect(normalizeHost('[::]'), '::');
      expect(normalizeHost('ptt.gov.tr.'), 'ptt.gov.tr');
      expect(normalizeHost('akbаnk.example'), isNot('akbank.example'));
      final entities = const EntityExtractor().extract(
        'PTT https://ptt.gov.tr@hile.example ptt.gov.tr',
      );
      expect(entities.hosts, {'hile.example', 'ptt.gov.tr'});
      expect(entities.prose.trim(), 'PTT');
      expect(
        normal.analyze('https://[2001:db8::1]/').reasons,
        contains(ReasonCode.ipHost),
      );
      expect(
        normal.analyze('dokuman.example/a@b?x=@y').reasons,
        isNot(contains(ReasonCode.atSign)),
      );
      expect(
        normal.analyze('ptt.gov.tr').reasons,
        isNot(contains(ReasonCode.nonHttps)),
      );
    },
  );
  test(
    'production controller runs bundled rules in the analysis isolate',
    () async {
      final rules = await RuleRepository().load();
      final controller = AnalysisController.fromRules(rules);
      addTearDown(controller.dispose);
      final result = await controller.analyze('Şifrenizi bana gönderin');
      expect(controller.failure, isNull);
      expect(result?.level, RiskLevel.high);
      expect(result?.usomChecked, isFalse);
    },
  );
  testWidgets('bundled assets drive check to a compact real result', (
    tester,
  ) async {
    final rules = await RuleRepository().load();
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TuzakApp(
        connectionCheck: () async => true,
        showSplash: false,
        rules: rules,
        analyzer: (text) async => RuleEngine(rules).analyze(text),
      ),
    );
    await tester.pumpAndSettle();
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('preview-high')), findsNothing);
    await tester.enterText(
      find.byKey(const Key('messageInput')),
      'PTT: Son uyarı! https://ptt-islem.example',
    );
    await tester.pump();
    final button = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    final result = tester
        .widget<ResultScreen>(find.byType(ResultScreen))
        .result;
    expect(result.level, RiskLevel.high);
    expect(result.isPreview, isFalse);
    expect(result.usomChecked, isFalse);
      expect(find.textContaining('Hukuki karar'), findsNothing);
      expect(find.text('Bu linke güvenme'), findsOneWidget);
    expect(find.textContaining('Kontrol şu an kullanılamıyor'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
