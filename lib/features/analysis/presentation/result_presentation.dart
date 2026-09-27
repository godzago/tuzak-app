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
}

extension ReasonPresentation on ReasonCode {
  (String, IconData) content(AppLocalizations s) => switch (this) {
    ReasonCode.noSignals => (s.noSignalsTitle, Icons.check_rounded),
    ReasonCode.urgency => (s.urgencyTitle, Icons.timer_outlined),
    ReasonCode.credentials => (s.credentialsTitle, Icons.key_rounded),
    ReasonCode.codeRequest => (s.codeRequestTitle, Icons.password_rounded),
    ReasonCode.payment => (s.paymentTitle, Icons.credit_card_outlined),
    ReasonCode.shortLink => (s.shortLinkTitle, Icons.link_rounded),
    ReasonCode.brandMismatch => (s.brandTitle, Icons.link_off_rounded),
    ReasonCode.suspiciousDomain => (s.domainTitle, Icons.language_rounded),
    ReasonCode.lookalike => (s.lookalikeTitle, Icons.copy_rounded),
    ReasonCode.riskyTld => (s.riskyTldTitle, Icons.public_off_outlined),
    ReasonCode.ipHost => (s.ipHostTitle, Icons.numbers_rounded),
    ReasonCode.punycode => (s.punycodeTitle, Icons.translate_rounded),
    ReasonCode.manyHyphens => (s.manyHyphensTitle, Icons.link_off_rounded),
    ReasonCode.longSubdomain => (
      s.longSubdomainTitle,
      Icons.account_tree_outlined,
    ),
    ReasonCode.atSign => (s.atSignTitle, Icons.alternate_email_rounded),
    ReasonCode.nonHttps => (s.nonHttpsTitle, Icons.lock_open_rounded),
    ReasonCode.deceptiveSubdomain => (
      s.deceptiveDomainTitle,
      Icons.language_rounded,
    ),
    ReasonCode.usom => (s.usomTitle, Icons.gpp_bad_outlined),
    ReasonCode.officialThreat => (
      s.officialThreatTitle,
      Icons.gpp_bad_outlined,
    ),
    ReasonCode.officialClean => (s.officialCleanTitle, Icons.verified_outlined),
    ReasonCode.generic => (s.genericSignalTitle, Icons.info_outline_rounded),
    ReasonCode.cargo => (s.cargoTitle, Icons.local_shipping_outlined),
    ReasonCode.government => (
      s.governmentTitle,
      Icons.account_balance_outlined,
    ),
    ReasonCode.bankCard => (s.bankCardTitle, Icons.credit_card_outlined),
    ReasonCode.prize => (s.prizeTitle, Icons.card_giftcard_rounded),
    ReasonCode.easyMoney => (s.easyMoneyTitle, Icons.paid_outlined),
    ReasonCode.familyImpersonation => (
      s.familyImpersonationTitle,
      Icons.people_outline_rounded,
    ),
    ReasonCode.promotion => (s.promotionTitle, Icons.campaign_outlined),
  };
}

String officialThreatTitle(String? category, AppLocalizations s) =>
    switch (category) {
      'BP' => s.officialThreatBankTitle,
      'PH' => s.officialThreatPhishingTitle,
      'MD' => s.officialThreatMalwareTitle,
      _ => s.officialThreatTitle,
    };
