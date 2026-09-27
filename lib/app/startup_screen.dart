import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/widgets/app_artwork.dart';
import '../features/analysis/application/analysis_controller.dart';
import '../features/analysis/domain/models/rule_set.dart';
import '../features/analysis/presentation/screens/home_screen.dart';
import '../l10n/app_localizations.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key, this.rules, this.analyzer, this.loadRules});
  final RuleSet? rules;
  final Analyzer? analyzer;
  final Future<RuleSet> Function()? loadRules;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  Timer? _timer;
  RuleSet? _rules;
  bool _minimumElapsed = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _minimumElapsed = true);
    });
    _load();
  }

  Future<void> _load() async {
    RuleSet? rules;
    try {
      rules = widget.loadRules == null
          ? widget.rules
          : await widget.loadRules!();
    } catch (_) {
      // Still open the UI; unavailable rules never produce a risk result.
    }
    if (mounted) {
      setState(() {
        _rules = rules;
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 350),
    child: _loaded && _minimumElapsed
        ? HomeScreen(
            key: const ValueKey('home'),
            rules: _rules,
            analyzer: widget.analyzer,
          )
        : const SplashScreen(key: ValueKey('splash')),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppArtwork.splash,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.appName,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.splashTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Color(0xFFB6BDCA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
