import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';

// Synthetic results used only to exercise result layouts in tests.
AnalysisResult sampleResult(RiskLevel level) => AnalysisResult(
  level: level,
  score: 0,
  rulesVersion: 'test',
  reasons: switch (level) {
    RiskLevel.low => [ReasonCode.noSignals],
    RiskLevel.suspicious => [ReasonCode.urgency, ReasonCode.shortLink],
    RiskLevel.high => [
      ReasonCode.brandMismatch,
      ReasonCode.urgency,
      ReasonCode.credentials,
    ],
    RiskLevel.dangerous => [
      ReasonCode.usom,
      ReasonCode.credentials,
      ReasonCode.payment,
    ],
  },
);
