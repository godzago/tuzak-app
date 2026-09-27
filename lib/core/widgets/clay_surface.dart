import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Soft raised shell with a lit upper rim and shaded lower inner edge.
class ClaySurface extends StatelessWidget {
  const ClaySurface({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.radius = 28,
    this.padding = EdgeInsets.zero,
  });
  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    decoration: decoration(color: color, radius: radius),
    child: Container(
      margin: const EdgeInsets.all(2),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius - 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, .2)!,
            color,
            Color.lerp(color, AppColors.ink, .045)!,
          ],
        ),
      ),
      child: child,
    ),
  );

  static BoxDecoration decoration({
    Color color = Colors.white,
    double radius = 28,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(color, Colors.white, .65)!,
        Color.lerp(color, AppColors.ink, .12)!,
      ],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0xD9FFFFFF),
        offset: Offset(-5, -5),
        blurRadius: 12,
      ),
      BoxShadow(color: Color(0x24766BA8), offset: Offset(6, 8), blurRadius: 18),
    ],
  );
}
