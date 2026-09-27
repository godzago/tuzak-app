import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'clay_surface.dart';

class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.ink,
    this.size = 38,
  });
  final IconData icon;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: ClaySurface.decoration(
      color: Color.lerp(Colors.white, color, .18)!,
      radius: size,
    ),
    child: Icon(
      icon,
      size: size * 0.49,
      color: color,
      shadows: const [
        Shadow(color: Colors.white, offset: Offset(-1, -1), blurRadius: 1),
        Shadow(color: Color(0x25766BA8), offset: Offset(1, 2), blurRadius: 2),
      ],
    ),
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.labelSmall),
  );
}

class InfoListCard extends StatelessWidget {
  const InfoListCard({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ClaySurface(
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),
          children[i],
        ],
      ],
    ),
  );
}

class InfoListTile extends StatelessWidget {
  const InfoListTile({
    super.key,
    required this.title,
    required this.leading,
    this.body,
    this.trailing,
  });
  final String title;
  final String? body;
  final Widget leading;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (body != null && body!.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(body!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    ),
  );
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.text, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFF1EE) : const Color(0xFFE5EAF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: error ? AppColors.darkRed : AppColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: error ? AppColors.darkRed : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
