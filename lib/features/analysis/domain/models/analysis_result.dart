import 'threat_match.dart';

enum RiskLevel { low, suspicious, high, dangerous }

enum ThreatCheckStatus { localOnly, unavailable, partial, complete }

enum CheckedEntity { message, link, number }

enum ReasonCode {
  noSignals,
  urgency,
  credentials,
  payment,
  shortLink,
  brandMismatch,
  suspiciousDomain,
  usom,
  officialThreat,
  officialClean,
  generic,
  cargo,
  government,
  bankCard,
  prize,
  easyMoney,
  familyImpersonation,
  codeRequest,
  promotion,
  lookalike,
  riskyTld,
  ipHost,
  punycode,
  manyHyphens,
  longSubdomain,
  atSign,
  nonHttps,
  deceptiveSubdomain,
}

class RiskSignal {
  const RiskSignal({
    required this.id,
    required this.reason,
    required this.score,
    this.why,
  });
  final String id;
  final ReasonCode reason;
  final double score;
  final String? why;
}

class AnalysisResult {
  AnalysisResult({
    required this.level,
    required this.score,
    required List<ReasonCode> reasons,
    required this.rulesVersion,
    this.isPreview = false,
    this.usomChecked = true,
    this.reasonDescriptions = const {},
    this.threatCheck = ThreatCheckStatus.localOnly,
    this.threatMatch,
    this.checkedEntity = CheckedEntity.message,
  }) : reasons = List.unmodifiable(reasons.take(3));

  final RiskLevel level;
  // A rule score, not a calibrated probability of fraud.
  final double score;
  final List<ReasonCode> reasons;
  final String rulesVersion;
  final bool isPreview;
  final bool usomChecked;
  final Map<ReasonCode, String> reasonDescriptions;
  final ThreatCheckStatus threatCheck;
  final ThreatMatch? threatMatch;
  final CheckedEntity checkedEntity;
}

class RulesUnavailable implements Exception {
  const RulesUnavailable();
}

class InvalidMessage implements Exception {
  const InvalidMessage();
}
