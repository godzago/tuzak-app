import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/models/analysis_result.dart';
import '../result_presentation.dart';

class ResultBadge extends StatelessWidget {
  const ResultBadge({super.key, required this.level, this.incomplete = false});
  final RiskLevel level;
  final bool incomplete;
  Color get color => incomplete ? AppColors.muted : level.color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: ClaySurface.decoration(
      color: Color.lerp(Colors.white, color, .12)!,
      radius: 30,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            incomplete
                ? AppLocalizations.of(context).limitedCheckLabel
                : level.label(AppLocalizations.of(context)),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}
