import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/analysis_result.dart';
import '../models/rule_set.dart';
import 'entity_extractor.dart';
import 'message_normalizer.dart';

class RuleEngine {
  const RuleEngine(this.rules);
  static const maxMessageLength = 10000;
  final RuleSet rules;

  AnalysisResult analyze(String message) {
    if (message.trim().isEmpty || message.length > maxMessageLength) {
      throw const InvalidMessage();
    }
    if (!rules.ready) throw const RulesUnavailable();
    final text = normalizeMessage(message);
    if (text.isEmpty) throw const InvalidMessage();
    final entities = const EntityExtractor().extract(message);
    final usomMatch = entities.hosts.any(
      (host) => rules.domainHashes.contains(
        sha256.convert(utf8.encode(host)).toString(),
      ),
    );
    final signals = <RiskSignal>[];
    for (final rule in rules.rules) {
      final matched = switch (rule.kind) {
        MatchKind.contains => rule.patterns.any(
          (p) => text.contains(normalizeMessage(p)),
        ),
        MatchKind.regex => rule.regexes.any((r) => r.hasMatch(text)),
        MatchKind.host => entities.hosts.any(
          (h) => rule.patterns.any((p) => _belongsTo(h, p)),
        ),
        MatchKind.tld => entities.hosts.any(
          (h) => rule.patterns.any((p) => h.endsWith('.${p.toLowerCase()}')),
        ),
        MatchKind.brandMismatch =>
          entities.hosts.isNotEmpty &&
              rules.brands.any(
                (brand) =>
                    brand.aliases.any(
                      (alias) => _mentions(text, normalizeMessage(alias)),
                    ) &&
                    entities.hosts.any(
                      (host) => !brand.domains.any((d) => _belongsTo(host, d)),
                    ),
              ),
      };
      // A rule contributes at most once, regardless of repeated words or links.
      if (matched) {
        signals.add(
          RiskSignal(id: rule.id, reason: rule.reason, score: rule.weight),
        );
      }
    }
    var complement = 1.0;
    for (final signal in signals) {
      complement *= 1 - signal.score;
    }
    // Remove floating-point drift at the documented threshold boundaries.
    final score = double.parse((1 - complement).toStringAsFixed(12));
    final level = usomMatch
        ? RiskLevel.dangerous
        : score > rules.highThreshold
        ? RiskLevel.high
        : score >= rules.suspiciousThreshold
        ? RiskLevel.suspicious
        : RiskLevel.low;
    signals.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.id.compareTo(b.id);
    });
    final reasons = <ReasonCode>{
      if (usomMatch) ReasonCode.usom,
      ...signals.map((s) => s.reason),
    };
    return AnalysisResult(
      level: level,
      score: score,
      reasons: reasons.isEmpty
          ? [ReasonCode.noSignals]
          : reasons.take(3).toList(),
      rulesVersion: rules.version,
    );
  }

  bool _belongsTo(String host, String domain) =>
      host == domain.toLowerCase() || host.endsWith('.${domain.toLowerCase()}');

  bool _mentions(String text, String alias) => RegExp(
    '(^|[^a-z0-9])${RegExp.escape(alias)}([^a-z0-9]|\$)',
  ).hasMatch(text);
}
