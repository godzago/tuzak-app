import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.muted),
      const SizedBox(width: 7),
      Flexible(
        child: Text(
          AppLocalizations.of(context).privacyNote,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}
