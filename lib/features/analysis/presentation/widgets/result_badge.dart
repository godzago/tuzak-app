import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/analysis_result.dart';
import '../result_presentation.dart';

class ResultBadge extends StatelessWidget {
  const ResultBadge({super.key, required this.level});
  final RiskLevel level;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: level.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            level.label(AppLocalizations.of(context)),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: level.color,
            ),
          ),
        ),
      ],
    ),
  );
}
