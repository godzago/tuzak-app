import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/features/analysis/data/rule_repository.dart';
import 'package:tuzak/features/analysis/domain/engine/entity_extractor.dart';
import 'package:tuzak/features/analysis/domain/engine/message_normalizer.dart';
import 'package:tuzak/features/analysis/domain/engine/rule_engine.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';
import 'package:tuzak/features/analysis/domain/models/rule_set.dart';

Map<String, dynamic> get fixtureRules =>
    jsonDecode(File('test/fixtures/synthetic_rules.json').readAsStringSync())
        as Map<String, dynamic>;
Map<String, dynamic> get fixtureBrands => {
  'schemaVersion': 1,
  'version': 'test',
  'status': 'ready',
  'brands': [
    {
      'aliases': ['Testmarka'],
      'domains': ['testmarka.test'],
    },
  ],
};
Map<String, dynamic> get fixtureUsom => {
  'schemaVersion': 1,
  'version': 'test',
  'status': 'ready',
  'hashAlgorithm': 'sha256',
  'domainHashes': [sha256.convert(utf8.encode('malware.test')).toString()],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final engine = RuleEngine(
    RuleSet.fromJson(fixtureRules, fixtureBrands, fixtureUsom),
  );
  final cases =
      jsonDecode(File('test/fixtures/synthetic_cases.json').readAsStringSync())
          as List;
  for (final c in cases) {
    test(c['name'] as String, () {
      final result = engine.analyze(c['message'] as String);
      expect(result.level.name, c['level']);
      expect(result.score, closeTo((c['score'] as num).toDouble(), 1e-10));
      expect(result.isPreview, isFalse);
    });
  }
  test('Turkish folding and whitespace', () {
    expect(
      normalizeMessage('  İŞLEM\nŞİFRE IĞDIR öçü  '),
      'islem sifre igdir ocu',
    );
  });
  test('only strongest three unique reasons, USOM first', () {
    final result = engine.analyze(
      'Testmarka hemen şifreni paylaş ödeme yap https://malware.test',
    );
    expect(result.reasons, [
      ReasonCode.usom,
      ReasonCode.credentials,
      ReasonCode.brandMismatch,
    ]);
  });
  test('empty and overlong messages fail without classification', () {
    expect(() => engine.analyze('  '), throwsA(isA<InvalidMessage>()));
    expect(
      () => engine.analyze('\u200B\u200D'),
      throwsA(isA<InvalidMessage>()),
    );
    expect(() => engine.analyze('a' * 10001), throwsA(isA<InvalidMessage>()));
  });
  test('bundled placeholder does not analyze real input', () async {
    final rules = await RuleRepository().load();
    expect(rules.ready, isFalse);
    expect(
      () => RuleEngine(rules).analyze('hello'),
      throwsA(isA<RulesUnavailable>()),
    );
  });
  test('bad thresholds rejected', () {
    final data = fixtureRules;
    data['thresholds'] = {'suspicious': 0.7, 'high': 0.6};
    expect(
      () => RuleSet.fromJson(data, fixtureBrands, fixtureUsom),
      throwsFormatException,
    );
  });
  test('invalid regex rejected before analysis', () {
    final data = fixtureRules;
    (data['rules'] as List)[1]['patterns'] = ['['];
    expect(
      () => RuleSet.fromJson(data, fixtureBrands, fixtureUsom),
      throwsFormatException,
    );
  });
  test('duplicate rules rejected instead of inflated scoring', () {
    final data = fixtureRules;
    (data['rules'] as List).add((data['rules'] as List).first);
    expect(
      () => RuleSet.fromJson(data, fixtureBrands, fixtureUsom),
      throwsFormatException,
    );
  });
  test('invalid weights rejected', () {
    final data = fixtureRules;
    (data['rules'] as List).first['weight'] = 1.2;
    expect(
      () => RuleSet.fromJson(data, fixtureBrands, fixtureUsom),
      throwsFormatException,
    );
  });
  test('pending USOM prevents claiming complete analysis', () {
    final usom = fixtureUsom..['status'] = 'pending';
    final rules = RuleSet.fromJson(fixtureRules, fixtureBrands, usom);
    expect(
      () => RuleEngine(rules).analyze('hello'),
      throwsA(isA<RulesUnavailable>()),
    );
  });
  test('IBAN, telephone and amount extraction', () {
    final entities = const EntityExtractor().extract(
      'TR33 0006 1005 1978 6457 8413 26 +90 532 123 45 67 125,50 TL',
    );
    expect(entities.ibans, hasLength(1));
    expect(entities.phones, hasLength(1));
    expect(entities.amounts, ['125,50 TL']);
  });
}
