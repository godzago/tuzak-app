import '../domain/models/analysis_result.dart';
import '../domain/models/rule_set.dart';

/// Loads the authored rules.json contract without requiring a live USOM feed.
/// Placeholder hashes are enabled only explicitly by synthetic regression tests.
RuleSet parseAssetRules(
  Map<String, dynamic> data,
  Map<String, dynamic>? usom, {
  bool allowSyntheticUsom = false,
}) {
  Never invalid() => throw const FormatException('Invalid analysis assets');
  String string(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value : invalid();
  Map<String, dynamic> map(dynamic value) =>
      value is Map<String, dynamic> ? value : invalid();
  List<String> strings(dynamic value) {
    if (value is! List || value.isEmpty) invalid();
    final result = value.map(string).toList();
    if (result.toSet().length != result.length) invalid();
    return List.unmodifiable(result);
  }

  double weight(dynamic value) =>
      value is num && value.isFinite && value > 0 && value <= 1
      ? value.toDouble()
      : invalid();
  int positive(dynamic value) => value is int && value > 0 ? value : invalid();
  final version = string(data['version']);
  if (!version.startsWith('1.')) invalid();
  final thresholds = map(data['thresholds']);
  final suspicious = weight(thresholds['suspicious']);
  final high = weight(thresholds['high']);
  if (suspicious >= high || high >= 1) invalid();
  const urlReasons = {
    'brand_mismatch': ReasonCode.brandMismatch,
    'lookalike': ReasonCode.lookalike,
    'shortener': ReasonCode.shortLink,
    'risky_tld': ReasonCode.riskyTld,
    'ip_host': ReasonCode.ipHost,
    'punycode': ReasonCode.punycode,
    'many_hyphens': ReasonCode.manyHyphens,
    'long_subdomain': ReasonCode.longSubdomain,
    'at_sign': ReasonCode.atSign,
    'non_https': ReasonCode.nonHttps,
    'deceptive_subdomain': ReasonCode.deceptiveSubdomain,
  };
  const textReasons = {
    'urgency': ReasonCode.urgency,
    'cargo': ReasonCode.cargo,
    'government': ReasonCode.government,
    'bank_card': ReasonCode.bankCard,
    'prize': ReasonCode.prize,
    'easy_money': ReasonCode.easyMoney,
    'family_impersonation': ReasonCode.familyImpersonation,
    'code_request': ReasonCode.codeRequest,
    'credential_request': ReasonCode.credentials,
    'spam_promo': ReasonCode.promotion,
  };
  final rules = <AnalysisRule>[];
  void addRules(String key, Map<String, ReasonCode> reasons, MatchKind kind) {
    final section = map(data[key]);
    if (reasons.keys.any(
          (id) => !section.containsKey(id) && id != 'deceptive_subdomain',
        ) ||
        section.keys.any((key) => !reasons.containsKey(key))) {
      invalid();
    }
    for (final entry in section.entries) {
      final item = map(entry.value);
      final patterns = kind == MatchKind.regex
          ? strings(item['patterns'])
          : const <String>[];
      if (patterns.any((p) => p.length > 512)) invalid();
      rules.add(
        AnalysisRule(
          id: entry.key,
          reason: reasons[entry.key]!,
          weight: weight(item['weight']),
          kind: kind,
          patterns: patterns,
          why: string(item['why']),
        ),
      );
    }
  }

  addRules('url_signals', urlReasons, MatchKind.urlSignal);
  addRules('text_categories', textReasons, MatchKind.regex);
  final brandData = data['brands'];
  if (brandData is! List || brandData.isEmpty) invalid();
  final domainPattern = RegExp(
    r'^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$',
  );
  List<String> domains(dynamic value) {
    final result = strings(value);
    if (result.any((d) => d.length > 253 || !domainPattern.hasMatch(d))) {
      invalid();
    }
    return result;
  }

  final brands = brandData.map((item) {
    final brand = map(item);
    string(brand['name']);
    return Brand(
      strings(brand['aliases']),
      domains(brand['official']),
      hostTokens: strings(brand['host_tokens']),
    );
  }).toList();
  // Trusted suffixes are context, never a bypass for other signals.
  domains(data['trusted_suffixes']);
  final options = map(data['url_signal_options']);
  final lookalike = map(options['lookalike']);
  if (lookalike['algorithm'] != 'levenshtein') invalid();
  final subdomain = map(options['long_subdomain']);
  final deceptive = options['deceptive_subdomain'] == null
      ? null
      : map(options['deceptive_subdomain']);
  final policy = UrlPolicy(
    twoLevelSuffixes: domains(data['two_level_suffixes']),
    shorteners: domains(data['shorteners']),
    riskyTlds: strings(data['risky_tlds']),
    minHyphens: positive(map(options['many_hyphens'])['min_in_one_label']),
    minSubdomainLabels: positive(subdomain['min_labels']),
    minSubdomainCharacters: positive(subdomain['min_characters']),
    minLookalikeLength: positive(lookalike['min_token_length']),
    maxLookalikeDistance: positive(lookalike['max_distance']),
    compoundAffixes: lookalike['compound_affixes'] == null
        ? const []
        : strings(lookalike['compound_affixes']),
    embeddedDomainSuffixes: deceptive == null
        ? const []
        : strings(deceptive['embedded_domain_suffixes']),
    deceptiveMinLabels: deceptive == null
        ? 3
        : positive(deceptive['min_labels']),
  );
  final scoring = map(data['scoring']);
  if (scoring['method'] != 'noisy_or' ||
      scoring['once_per_signal'] != true ||
      scoring['high_comparison'] != '>' ||
      scoring['suspicious_comparison'] != '>=' ||
      scoring['round_decimals'] != 12 ||
      scoring['max_reasons'] != 3 ||
      scoring['usom_match_level'] != 'dangerous') {
    invalid();
  }

  // Missing, placeholder, or malformed optional threat data must not disable
  // the independent local heuristics, nor masquerade as a clean threat check.
  var usomAvailable = false;
  var hashes = <String>{};
  var usomVersion = 'unavailable';
  if (usom != null) {
    final version = usom['version'];
    final generated = usom['generated'];
    final entries = usom['entries'];
    final valid =
        version is String &&
        version.isNotEmpty &&
        generated is String &&
        DateTime.tryParse(generated) != null &&
        entries is List &&
        entries.isNotEmpty &&
        entries.every(
          (h) => h is String && RegExp(r'^[a-f0-9]{64}$').hasMatch(h),
        );
    if (valid) {
      usomVersion = version;
      usomAvailable =
          version.startsWith('1.') ||
          (allowSyntheticUsom && version == '0.0.0-placeholder');
      if (usomAvailable) hashes = Set<String>.from(entries);
    }
  }
  return RuleSet(
    version: version,
    brandVersion: version,
    usomVersion: usomVersion,
    ready: true,
    suspiciousThreshold: suspicious,
    highThreshold: high,
    rules: List.unmodifiable(rules),
    brands: List.unmodifiable(brands),
    domainHashes: Set.unmodifiable(hashes),
    usomAvailable: usomAvailable,
    urlPolicy: policy,
  );
}
