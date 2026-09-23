import '../domain/models/analysis_result.dart';

// Deliberately separate from the engine. These are labelled UI examples,
// never the result of evaluating a user's message.
AnalysisResult previewResult(RiskLevel level) => AnalysisResult(
  level: level,
  score: 0,
  rulesVersion: 'preview',
  isPreview: true,
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
