import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/analysis/application/analysis_controller.dart';
import '../features/analysis/domain/models/rule_set.dart';
import '../features/analysis/presentation/screens/home_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/connectivity_service.dart';
import 'startup_screen.dart';

class TuzakApp extends StatefulWidget {
  const TuzakApp({
    super.key,
    this.rules,
    this.analyzer,
    this.loadRules,
    this.showSplash = true,
    this.connectionCheck,
    this.connectionChanges,
  });
  final RuleSet? rules;
  final Analyzer? analyzer;
  final Future<RuleSet> Function()? loadRules;
  final bool showSplash;
  final ConnectionCheck? connectionCheck;
  final ConnectionStatusStream? connectionChanges;

  @override
  State<TuzakApp> createState() => _TuzakAppState();
}

class _TuzakAppState extends State<TuzakApp> {
  StreamSubscription<bool>? _connectionSubscription;
  bool? _connected;
  bool _streamReported = false;

  @override
  void initState() {
    super.initState();
    _trackConnection();
  }

  void _trackConnection() {
    const service = ConnectivityService();
    final changes =
        widget.connectionChanges ??
        (widget.connectionCheck == null ? service.statusChanges : null);
    _connectionSubscription = changes?.call().listen(
      (connected) {
        _streamReported = true;
        if (mounted && connected != _connected) {
          setState(() => _connected = connected);
        }
      },
      onError: (_) {
        // Unknown status is not proof that the device is offline.
      },
    );
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final connected =
        await (widget.connectionCheck ??
            const ConnectivityService().hasNetwork)();
    if (!mounted || _streamReported || connected == null) return;
    setState(() => _connected = connected);
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tuzak',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => _ConnectionBanner(
      offline: _connected == false,
      child: child ?? const SizedBox.shrink(),
    ),
    home: widget.showSplash
        ? StartupScreen(
            rules: widget.rules,
            analyzer: widget.analyzer,
            loadRules: widget.loadRules,
          )
        : HomeScreen(rules: widget.rules, analyzer: widget.analyzer),
  );
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.offline, required this.child});
  final bool offline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!offline) return child;
    return Column(
      children: [
        Material(
          color: const Color(0xFFFFE7CC),
          child: SafeArea(
            bottom: false,
            child: Semantics(
              liveRegion: true,
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).offlineWarning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A3B12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
