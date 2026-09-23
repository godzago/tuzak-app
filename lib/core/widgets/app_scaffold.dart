import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child, this.header, this.footer});
  final Widget child;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F6FB), AppColors.background, Color(0xFFE9EEF6)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                ?header,
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    child: child,
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: footer!,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.brand = false,
  });
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool brand;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            tooltip: AppLocalizations.of(context).back,
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
          )
        else if (brand)
          Container(
            width: 34,
            height: 38,
            margin: const EdgeInsets.only(left: 8, right: 10),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.ink,
              size: 28,
            ),
          ),
        Expanded(
          child: Text(
            title,
            style: brand
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
