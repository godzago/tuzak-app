enum RiskLevel { low, suspicious, high, dangerous }

enum ReasonCode {
  noSignals,
  urgency,
  credentials,
  payment,
  shortLink,
  brandMismatch,
  suspiciousDomain,
  usom,
  generic,
}

class RiskSignal {
  const RiskSignal({
    required this.id,
    required this.reason,
    required this.score,
  });
  final String id;
  final ReasonCode reason;
  final double score;
}

class AnalysisResult {
  AnalysisResult({
    required this.level,
    required this.score,
    required List<ReasonCode> reasons,
    required this.rulesVersion,
    this.isPreview = false,
  }) : reasons = List.unmodifiable(reasons.take(3));

  final RiskLevel level;
  // A rule score, not a calibrated probability of fraud.
  final double score;
  final List<ReasonCode> reasons;
  final String rulesVersion;
  final bool isPreview;
}

class RulesUnavailable implements Exception {
  const RulesUnavailable();
}

class InvalidMessage implements Exception {
  const InvalidMessage();
}
