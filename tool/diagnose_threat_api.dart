import 'dart:convert';
import 'dart:io';
import 'package:tuzak/features/analysis/data/asset_rule_adapter.dart';
import 'package:tuzak/features/analysis/domain/engine/entity_extractor.dart';
import 'package:tuzak/features/analysis/domain/engine/rule_engine.dart';
import 'package:tuzak/features/analysis/application/threat_enriched_analyzer.dart';
import 'package:tuzak/services/threat_api_service.dart';

// Run from app/: dart --enable-asserts run tool/diagnose_threat_api.dart DOMAIN
// Sends only DOMAIN to the official API, never opens the investigated URL.
Future<void> main(List<String> args) async {
  if (args.length != 1 ||
      ThreatApiService.domainForQuery(args.single) == null) {
    stderr.writeln(
      'Usage: dart --enable-asserts run tool/diagnose_threat_api.dart DOMAIN',
    );
    exitCode = 64;
    return;
  }
  final domain = args.single;
  final rules = parseAssetRules(
    jsonDecode(File('assets/data/rules.json').readAsStringSync())
        as Map<String, dynamic>,
    null,
  );
  final local = RuleEngine(rules);
  final api = ThreatApiService(debugLogger: stdout.writeln);
  final analyzer = ThreatEnrichedAnalyzer(
    analyzeLocal: (text) async => local.analyze(text),
    checkDomain: api.checkDomain,
    checkPhone: api.checkPhone,
  );
  try {
    stdout.writeln(
      'Extracted hosts: ${const EntityExtractor().extract(domain).hosts}',
    );
    final baseline = local.analyze(domain);
    stdout.writeln(
      'Local: ${baseline.level.name}, score=${baseline.score}, reasons=${baseline.reasons}',
    );
    for (var attempt = 1; attempt <= 2; attempt++) {
      final result = await analyzer.analyze(domain);
      stdout.writeln(
        'Attempt $attempt: level=${result.level.name}, coverage=${result.threatCheck.name}, '
        'category=${result.threatMatch?.category}, criticality=${result.threatMatch?.criticalityLevel}',
      );
    }
  } finally {
    analyzer.dispose();
    api.dispose();
  }
}
