import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/analysis_result.dart';
import '../result_presentation.dart';
import '../widgets/result_badge.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final AnalysisResult result;

  Future<void> _call(BuildContext context) async {
    final s = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.callConfirmTitle),
        content: Text(s.callConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.call),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    var opened = false;
    try {
      opened = await launchUrl(Uri(scheme: 'tel', path: '112'));
    } catch (_) {
      /* No raw errors logged. */
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.callUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final level = result.level;
    final theme = Theme.of(context).textTheme;
    final low = level == RiskLevel.low;
    final advice = <(String, String, IconData)>[
      if (low)
        (
          s.protectSecretsTitle,
          s.protectSecretsBody,
          Icons.lock_outline_rounded,
        ),
      if (level == RiskLevel.suspicious)
        (s.verifyTitle, s.verifyBody, Icons.person_search_outlined),
      if (low || level == RiskLevel.suspicious)
        (s.officialAppTitle, s.officialAppBody, Icons.open_in_new_rounded),
      if (level == RiskLevel.high || level == RiskLevel.dangerous) ...[
        (s.doNotTapTitle, s.doNotTapBody, Icons.block_rounded),
        if (level == RiskLevel.dangerous)
          (s.deleteTitle, s.deleteBody, Icons.delete_outline_rounded),
        (s.contactBankTitle, s.contactBankBody, Icons.account_balance_outlined),
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
          if (result.isPreview) ...[
            NoticeCard(text: '${s.previewLabel} · ${s.previewNotice}'),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: IconBadge(icon: level.icon, color: level.color, size: 60),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ResultBadge(level: level),
          ),
          const SizedBox(height: 16),
          Text(level.title(s), style: theme.headlineLarge),
          const SizedBox(height: 14),
          Text(level.description(s), style: theme.bodyLarge),
          const SizedBox(height: 32),
          SectionLabel(low ? s.whyLow : s.whyFlagged),
          InfoListCard(
            children: [
              for (final reason in result.reasons)
                Builder(
                  builder: (context) {
                    final (title, body, icon) = reason.content(s);
                    return InfoListTile(
                      title: title,
                      body: body,
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
                  body: advice[i].$2,
                  leading: low
                      ? Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${i + 1}', style: theme.titleMedium),
                        )
                      : IconBadge(icon: advice[i].$3, color: AppColors.ink),
                ),
            ],
          ),
          if (level == RiskLevel.high || level == RiskLevel.dangerous) ...[
            const SizedBox(height: 12),
            InfoListCard(
              children: [
                InfoListTile(
                  title: s.emergencyTitle,
                  body: s.emergencyBody,
                  leading: const IconBadge(icon: Icons.phone_outlined),
                  trailing: OutlinedButton.icon(
                    onPressed: () => _call(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: Text(s.call),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 30),
          PrimaryButton(
            key: const Key('scanAnother'),
            label: s.scanAnother,
            icon: Icons.add_rounded,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 18),
          Text(
            s.resultDisclaimer,
            style: theme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
