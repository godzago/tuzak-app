import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/models/analysis_result.dart';

extension RiskPresentation on RiskLevel {
  Color get color => switch (this) {
    RiskLevel.low => AppColors.green,
    RiskLevel.suspicious => AppColors.amber,
    RiskLevel.high => AppColors.red,
    RiskLevel.dangerous => AppColors.darkRed,
  };
  IconData get icon => switch (this) {
    RiskLevel.low => Icons.check_rounded,
    RiskLevel.suspicious => Icons.question_mark_rounded,
    RiskLevel.high => Icons.priority_high_rounded,
    RiskLevel.dangerous => Icons.block_rounded,
  };
  String label(AppLocalizations s) => switch (this) {
    RiskLevel.low => s.lowLabel,
    RiskLevel.suspicious => s.suspiciousLabel,
    RiskLevel.high => s.highLabel,
    RiskLevel.dangerous => s.dangerousLabel,
  };
  String title(AppLocalizations s) => switch (this) {
    RiskLevel.low => s.lowTitle,
    RiskLevel.suspicious => s.suspiciousTitle,
    RiskLevel.high => s.highTitle,
    RiskLevel.dangerous => s.dangerousTitle,
  };
  String description(AppLocalizations s) => switch (this) {
    RiskLevel.low => s.lowDescription,
    RiskLevel.suspicious => s.suspiciousDescription,
    RiskLevel.high => s.highDescription,
    RiskLevel.dangerous => s.dangerousDescription,
  };
}

extension ReasonPresentation on ReasonCode {
  (String, String, IconData) content(AppLocalizations s) => switch (this) {
    ReasonCode.noSignals => (
      s.noSignalsTitle,
      s.noSignalsBody,
      Icons.check_rounded,
    ),
    ReasonCode.urgency => (s.urgencyTitle, s.urgencyBody, Icons.timer_outlined),
    ReasonCode.credentials => (
      s.credentialsTitle,
      s.credentialsBody,
      Icons.key_rounded,
    ),
    ReasonCode.payment => (
      s.paymentTitle,
      s.paymentBody,
      Icons.credit_card_outlined,
    ),
    ReasonCode.shortLink => (
      s.shortLinkTitle,
      s.shortLinkBody,
      Icons.link_rounded,
    ),
    ReasonCode.brandMismatch => (
      s.brandTitle,
      s.brandBody,
      Icons.link_off_rounded,
    ),
    ReasonCode.suspiciousDomain => (
      s.domainTitle,
      s.domainBody,
      Icons.language_rounded,
    ),
    ReasonCode.usom => (s.usomTitle, s.usomBody, Icons.gpp_bad_outlined),
    ReasonCode.generic => (
      s.genericSignalTitle,
      s.genericSignalBody,
      Icons.info_outline_rounded,
    ),
  };
}
