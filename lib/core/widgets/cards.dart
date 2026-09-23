import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: size * 0.49, color: color),
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.025),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
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
    required this.body,
    required this.leading,
    this.trailing,
  });
  final String title;
  final String body;
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
              const SizedBox(height: 5),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: trailing,
                ),
            ],
          ),
        ),
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
