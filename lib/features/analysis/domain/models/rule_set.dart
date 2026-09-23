import 'analysis_result.dart';

enum MatchKind { contains, regex, host, tld, brandMismatch }

class AnalysisRule {
  AnalysisRule({
    required this.id,
    required this.reason,
    required this.weight,
    required this.kind,
    required this.patterns,
  }) : regexes = kind == MatchKind.regex
           ? patterns.map((p) => RegExp(p, caseSensitive: false)).toList()
           : const [];

  final String id;
  final ReasonCode reason;
  final double weight;
  final MatchKind kind;
  final List<String> patterns;
  final List<RegExp> regexes;
}

class Brand {
  const Brand(this.aliases, this.domains);
  final List<String> aliases;
  final List<String> domains;
}

class RuleSet {
  const RuleSet({
    required this.version,
    required this.brandVersion,
    required this.usomVersion,
    required this.ready,
    required this.suspiciousThreshold,
    required this.highThreshold,
    required this.rules,
    required this.brands,
    required this.domainHashes,
  });

  final String version;
  final String brandVersion;
  final String usomVersion;
  final bool ready;
  final double suspiciousThreshold;
  final double highThreshold;
  final List<AnalysisRule> rules;
  final List<Brand> brands;
  final Set<String> domainHashes;

  factory RuleSet.fromJson(
    Map<String, dynamic> rulesData,
    Map<String, dynamic> brandsData,
    Map<String, dynamic> usomData,
  ) {
    for (final data in [rulesData, brandsData, usomData]) {
      if (data['schemaVersion'] != 1 ||
          data['version'] is! String ||
          (data['version'] as String).isEmpty ||
          !['pending', 'ready'].contains(data['status'])) {
        throw const FormatException('Unsupported data manifest');
      }
    }
    final thresholds = rulesData['thresholds'] as Map<String, dynamic>;
    final suspicious = (thresholds['suspicious'] as num).toDouble();
    final high = (thresholds['high'] as num).toDouble();
    if (!suspicious.isFinite ||
        !high.isFinite ||
        suspicious <= 0 ||
        high <= suspicious ||
        high >= 1) {
      throw const FormatException('Invalid risk thresholds');
    }
    final ids = <String>{};
    final rules = (rulesData['rules'] as List).map((item) {
      final data = item as Map<String, dynamic>;
      final id = data['id'] as String;
      final weight = (data['weight'] as num).toDouble();
      final kind = MatchKind.values.byName(data['kind'] as String);
      final reason = ReasonCode.values.byName(data['reason'] as String);
      final patterns = List<String>.from(data['patterns'] as List);
      if (id.isEmpty ||
          !ids.add(id) ||
          !weight.isFinite ||
          weight <= 0 ||
          weight > 1 ||
          reason == ReasonCode.noSignals ||
          reason == ReasonCode.usom ||
          (kind != MatchKind.brandMismatch && patterns.isEmpty) ||
          patterns.any((p) => p.trim().isEmpty || p.length > 512)) {
        throw const FormatException('Invalid analysis rule');
      }
      return AnalysisRule(
        id: id,
        reason: reason,
        weight: weight,
        kind: kind,
        patterns: List.unmodifiable(patterns),
      );
    }).toList();
    final brands = (brandsData['brands'] as List).map((item) {
      final data = item as Map<String, dynamic>;
      final aliases = List<String>.from(data['aliases'] as List);
      final domains = List<String>.from(data['domains'] as List);
      if (aliases.isEmpty ||
          domains.isEmpty ||
          aliases.any((a) => a.trim().isEmpty) ||
          domains.any((d) => !_validDomain(d))) {
        throw const FormatException('Invalid brand');
      }
      return Brand(List.unmodifiable(aliases), List.unmodifiable(domains));
    }).toList();
    if (usomData['hashAlgorithm'] != 'sha256') {
      throw const FormatException('Unsupported domain hash');
    }
    final hashes = List<String>.from(usomData['domainHashes'] as List);
    if (hashes.any((h) => !RegExp(r'^[a-f0-9]{64}$').hasMatch(h))) {
      throw const FormatException('Invalid domain hash');
    }
    final ready = [
      rulesData,
      brandsData,
      usomData,
    ].every((d) => d['status'] == 'ready');
    if (ready && rules.isEmpty) {
      throw const FormatException('Ready rule set must contain rules');
    }
    return RuleSet(
      version: rulesData['version'] as String,
      brandVersion: brandsData['version'] as String,
      usomVersion: usomData['version'] as String,
      ready: ready,
      suspiciousThreshold: suspicious,
      highThreshold: high,
      rules: List.unmodifiable(rules),
      brands: List.unmodifiable(brands),
      domainHashes: Set.unmodifiable(hashes),
    );
  }

  static bool _validDomain(String value) =>
      value == value.toLowerCase() &&
      RegExp(
        r'^(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,63}$',
      ).hasMatch(value);
}
