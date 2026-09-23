import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/cards.dart';
import '../../l10n/app_localizations.dart';
import '../analysis/domain/models/rule_set.dart';
import '../sharing/incoming_share_service.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.rules});
  final RuleSet? rules;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    String version(String? value) => value == null
        ? s.unavailable
        : value == 'pending'
        ? s.pending
        : value;
    return AppScaffold(
      header: AppHeader(
        title: s.infoTitle,
        onBack: () => Navigator.pop(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: IconBadge(
              icon: Icons.shield_outlined,
              color: AppColors.ink,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(s.infoIntro, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text(s.infoDescription, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 28),
          InfoListCard(
            children: [
              InfoListTile(
                title: s.privacyTitle,
                body: s.privacyBody,
                leading: const IconBadge(icon: Icons.lock_outline_rounded),
              ),
              InfoListTile(
                title: s.sourcesTitle,
                body: s.sourcesBody,
                leading: const IconBadge(icon: Icons.fact_check_outlined),
              ),
              InfoListTile(
                title: s.shareTitle,
                body: const IncomingShareService().supported
                    ? s.shareBody
                    : s.sharePreviewBody,
                leading: const IconBadge(icon: Icons.ios_share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InfoListCard(
            children: [
              for (final row in [
                (s.ruleVersion, rules?.version),
                (s.brandVersion, rules?.brandVersion),
                (s.usomVersion, rules?.usomVersion),
              ])
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 18,
                    runSpacing: 6,
                    children: [
                      Text(
                        row.$1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        version(row.$2),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: s.appName,
              applicationVersion: '0.1.0',
            ),
            child: Text(s.licenses),
          ),
          Text(
            s.version,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
