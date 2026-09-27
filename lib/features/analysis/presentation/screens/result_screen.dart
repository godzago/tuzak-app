import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/analysis_result.dart';
import '../result_presentation.dart';
import '../widgets/result_badge.dart';
import '../widgets/bank_call_sheet.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final AnalysisResult result;

  String _title(AppLocalizations s, {required bool incomplete}) {
    if (incomplete) return s.limitedCheckTitle;
    return switch ((result.level, result.checkedEntity)) {
      (RiskLevel.low, CheckedEntity.link) => s.linkCleanTitle,
      (RiskLevel.low, CheckedEntity.number) => s.numberCleanTitle,
      (RiskLevel.low, CheckedEntity.message) => s.messageCleanTitle,
      (RiskLevel.suspicious, CheckedEntity.link) => s.suspiciousLinkTitle,
      (RiskLevel.suspicious, CheckedEntity.number) => s.suspiciousNumberTitle,
      (RiskLevel.suspicious, CheckedEntity.message) => s.suspiciousMessageTitle,
      (RiskLevel.high, CheckedEntity.link) => s.highLinkTitle,
      (RiskLevel.high, CheckedEntity.number) => s.highNumberTitle,
      (RiskLevel.high, CheckedEntity.message) => s.highMessageTitle,
      (RiskLevel.dangerous, CheckedEntity.link) => s.dangerousLinkTitle,
      (RiskLevel.dangerous, CheckedEntity.number) => s.dangerousNumberTitle,
      (RiskLevel.dangerous, CheckedEntity.message) => s.dangerousMessageTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final level = result.level;
    final theme = Theme.of(context).textTheme;
    final low = level == RiskLevel.low;
    final incomplete =
        low &&
        result.checkedEntity != CheckedEntity.message &&
        (result.threatCheck == ThreatCheckStatus.unavailable ||
            result.threatCheck == ThreatCheckStatus.partial);
    final doNotEngage = switch (result.checkedEntity) {
      CheckedEntity.link => s.doNotEngageLinkTitle,
      CheckedEntity.number => s.doNotEngageNumberTitle,
      CheckedEntity.message => s.doNotEngageMessageTitle,
    };
    final advice = <(String, IconData)>[
      if (low) (s.protectSecretsTitle, Icons.lock_outline_rounded),
      if (level == RiskLevel.suspicious)
        (s.verifyTitle, Icons.person_search_outlined),
      if (low || level == RiskLevel.suspicious)
        (s.officialAppTitle, Icons.open_in_new_rounded),
      if (level == RiskLevel.high || level == RiskLevel.dangerous) ...[
        (doNotEngage, Icons.block_rounded),
        (s.contactBankTitle, Icons.account_balance_outlined),
      ],
    ];
    return AppScaffold(
      header: AppHeader(
        title: s.analysis,
        onBack: () => Navigator.pop(context),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.shield_outlined, size: 22, color: AppColors.muted),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: IconBadge(
              icon: incomplete ? Icons.help_outline_rounded : level.icon,
              color: incomplete ? AppColors.muted : level.color,
              size: 100,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: ResultBadge(level: level, incomplete: incomplete),
          ),
          const SizedBox(height: 16),
          Text(
            _title(s, incomplete: incomplete),
            style: theme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SectionLabel(low ? s.whyLow : s.whyFlagged),
          InfoListCard(
            children: [
              for (final reason in result.reasons)
                Builder(
                  builder: (context) {
                    final (defaultTitle, icon) = reason.content(s);
                    final title = reason == ReasonCode.officialThreat
                        ? officialThreatTitle(result.threatMatch?.category, s)
                        : defaultTitle;
                    return InfoListTile(
                      title: title,
                      leading: IconBadge(icon: icon, color: level.color),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 28),
          SectionLabel(s.recommendedActions),
          InfoListCard(
            children: [
              for (var i = 0; i < advice.length; i++)
                InfoListTile(
                  title: advice[i].$1,
                  trailing: advice[i].$1 == s.contactBankTitle
                      ? Container(
                          decoration: ClaySurface.decoration(
                            color: const Color(0xFFF0ECFC),
                            radius: 30,
                          ),
                          child: TextButton(
                            onPressed: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                              ),
                              builder: (_) => const BankCallSheet(),
                            ),
                            child: Text(s.callAction),
                          ),
                        )
                      : null,
                  leading: low
                      ? Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: ClaySurface.decoration(
                            color: AppColors.background,
                            radius: 30,
                          ),
                          child: Text('${i + 1}', style: theme.titleMedium),
                        )
                      : IconBadge(icon: advice[i].$2, color: AppColors.ink),
                ),
            ],
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            key: const Key('scanAnother'),
            label: s.scanAnother,
            icon: Icons.add_rounded,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
