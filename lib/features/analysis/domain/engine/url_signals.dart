import '../models/rule_set.dart';
import 'entity_extractor.dart';
import 'host_normalizer.dart';
import 'message_normalizer.dart';

bool belongsTo(String host, String domain) =>
    host == domain || host.endsWith('.$domain');

Set<String> detectUrlSignals(MessageEntities entities, RuleSet rules) {
  final policy = rules.urlPolicy!;
  final signals = <String>{};
  final prose = normalizeMessage(entities.prose);
  final mentioned = rules.brands
      .where(
        (brand) => brand.aliases.any(
          (alias) => RegExp(
            '(^|[^a-z0-9])${RegExp.escape(normalizeMessage(alias))}([^a-z0-9]|\$)',
          ).hasMatch(prose),
        ),
      )
      .toSet();
  for (final url in entities.urls) {
    final host = url.host;
    final labels = host.split('.');
    final ip = isIpHost(host);
    if (ip) signals.add('ip_host');
    if (labels.any((label) => label.startsWith('xn--'))) {
      signals.add('punycode');
    }
    if (url.uri.authority.contains('@')) signals.add('at_sign');
    if (url.explicitHttp) signals.add('non_https');
    if (policy.shorteners.any((d) => belongsTo(host, d))) {
      signals.add('shortener');
    }
    if (policy.riskyTlds.contains(labels.last)) signals.add('risky_tld');
    if (labels.any((l) => '-'.allMatches(l).length >= policy.minHyphens)) {
      signals.add('many_hyphens');
    }
    if (ip) continue;
    var suffix = labels.last;
    for (final candidate in policy.twoLevelSuffixes) {
      if (belongsTo(host, candidate) && candidate.length > suffix.length) {
        suffix = candidate;
      }
    }
    final body = labels.take(labels.length - suffix.split('.').length).toList();
    final subdomain = body.take(body.isNotEmpty ? body.length - 1 : 0).toList();
    if (subdomain.length >= policy.minSubdomainLabels ||
        subdomain.join('.').length >= policy.minSubdomainCharacters) {
      signals.add('long_subdomain');
    }
    // Other URL signals still apply to official hosts. Multiple genuine
    // institutional links must not falsely impersonate one another.
    if (rules.brands.any((b) => b.domains.any((d) => belongsTo(host, d)))) {
      continue;
    }
    final components = body.expand((label) => label.split('-')).toSet();
    if (_deceptiveSubdomain(subdomain, prose, policy)) {
      signals.add('deceptive_subdomain');
    }
    for (final brand in rules.brands) {
      final compound = brand.hostTokens.any(
        (token) =>
            token.length >= policy.minLookalikeLength &&
            components.any(
              (part) => _compoundToken(part, token, policy.compoundAffixes),
            ),
      );
      if (mentioned.contains(brand) ||
          brand.hostTokens.any(components.contains) ||
          compound) {
        signals.add('brand_mismatch');
      }
      if (compound ||
          brand.hostTokens.any(
            (token) =>
                token.length >= policy.minLookalikeLength &&
                components.any(
                  (part) =>
                      part != token &&
                      (part.length - token.length).abs() <=
                          policy.maxLookalikeDistance &&
                      _distance(part, token) <= policy.maxLookalikeDistance,
                ),
          )) {
        signals.add('lookalike');
      }
    }
  }
  return signals;
}

bool _compoundToken(String part, String token, List<String> affixes) {
  if (part == token) return false;
  // Match complete compounds, not arbitrary substrings (e.g. pineapple).
  // Bounded segmentation avoids nested-regex backtracking on digit-heavy hosts.
  for (
    var start = part.indexOf(token);
    start >= 0;
    start = part.indexOf(token, start + 1)
  ) {
    if (_affixSequence(part.substring(0, start), affixes) &&
        _affixSequence(part.substring(start + token.length), affixes)) {
      return true;
    }
  }
  return false;
}

bool _affixSequence(String text, List<String> affixes) {
  final reachable = List.filled(text.length + 1, false)..[0] = true;
  for (var i = 0; i < text.length; i++) {
    if (!reachable[i]) continue;
    final code = text.codeUnitAt(i);
    if (code >= 48 && code <= 57) reachable[i + 1] = true;
    for (final affix in affixes) {
      if (text.startsWith(affix, i)) reachable[i + affix.length] = true;
    }
  }
  return reachable.last;
}

bool _deceptiveSubdomain(
  List<String> subdomain,
  String prose,
  UrlPolicy policy,
) {
  // A full-looking domain placed to the LEFT of the actual registered owner:
  // unknownbrand.com.login.evil.example. No brand inventory is needed.
  for (final suffix in policy.embeddedDomainSuffixes) {
    final parts = suffix.split('.');
    for (var start = 1; start + parts.length <= subdomain.length; start++) {
      if (subdomain.sublist(start, start + parts.length).join('.') == suffix) {
        return true;
      }
    }
  }
  // For unknown brands, corroborate a prose name in a deep subdomain with
  // an account/security label. This is structural suspicion, not ownership proof.
  if (subdomain.length < policy.deceptiveMinLabels) return false;
  const accountLabels = {
    'login',
    'signin',
    'account',
    'accounts',
    'verify',
    'secure',
    'security',
    'giris',
    'hesap',
    'dogrulama',
  };
  final components = subdomain.expand((p) => p.split('-')).toSet();
  if (!components.any(accountLabels.contains)) return false;
  return components.any(
    (part) =>
        part.length >= 4 &&
        !accountLabels.contains(part) &&
        !{
          'www',
          'mail',
          'email',
          'online',
          'support',
          'portal',
          'service',
        }.contains(part) &&
        RegExp(
          '(^|[^a-z0-9])${RegExp.escape(part)}([^a-z0-9]|\$)',
        ).hasMatch(prose),
  );
}

int _distance(String a, String b) {
  var previous = List.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final deletion = previous[j] + 1;
      final insertion = current[j - 1] + 1;
      final substitution = previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1);
      var best = deletion < insertion ? deletion : insertion;
      if (substitution < best) best = substitution;
      current[j] = best;
    }
    previous = current;
  }
  return previous.last;
}
