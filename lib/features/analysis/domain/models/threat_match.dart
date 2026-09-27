enum ThreatEntityType { domain, ip, phone }

class ThreatMatch {
  const ThreatMatch({
    required this.found,
    this.criticalityLevel,
    this.category,
    this.entityType = ThreatEntityType.domain,
  });

  final bool found;
  final int? criticalityLevel;
  final String? category;
  final ThreatEntityType entityType;

  bool get isCritical =>
      found &&
      criticalityLevel != null &&
      criticalityLevel! >= 1 &&
      criticalityLevel! <= 3;
}
