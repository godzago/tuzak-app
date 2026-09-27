import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_artwork.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../info/info_screen.dart';
import '../../../sharing/incoming_share_service.dart';
import '../../application/analysis_controller.dart';
import '../../domain/engine/rule_engine.dart';
import '../../domain/models/rule_set.dart';
import '../widgets/privacy_note.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.rules,
    this.analyzer,
    this.sharing = const IncomingShareService(),
  });
  final RuleSet? rules;
  final Analyzer? analyzer;
  final IncomingShareService sharing;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _routeOpen = false;
  bool _takingShare = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takeShare();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _takeShare();
  }

  void _notify(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _takeShare() async {
    if (!mounted || _routeOpen || _takingShare) return;
    _takingShare = true;
    try {
      final text = await widget.sharing.takePendingText();
      if (!mounted || text == null || text.trim().isEmpty) return;
      if (text.length > RuleEngine.maxMessageLength) {
        _notify(AppLocalizations.of(context).inputTooLong);
        return;
      }
      // Search owns and clears the controller; raw text is not stored in a
      // route argument or retained in this async frame until navigation ends.
      unawaited(_openSearch(controller: TextEditingController(text: text)));
    } catch (_) {
      if (mounted) _notify(AppLocalizations.of(context).shareUnavailable);
    } finally {
      _takingShare = false;
    }
  }

  Future<void> _openSearch({TextEditingController? controller}) async {
    if (_routeOpen) {
      controller?.dispose();
      return;
    }
    _routeOpen = true;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          rules: widget.rules,
          analyzer: widget.analyzer,
          sharing: widget.sharing,
          messageController: controller,
        ),
      ),
    );
    if (!mounted) return;
    _routeOpen = false;
    _takeShare();
  }

  Future<void> _openInfo() async {
    if (_routeOpen) return;
    _routeOpen = true;
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const InfoScreen()));
    if (!mounted) return;
    _routeOpen = false;
    _takeShare();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    return AppScaffold(
      header: AppHeader(
        title: s.appName,
        brand: true,
        trailing: IconButton(
          tooltip: s.infoTitle,
          onPressed: _openInfo,
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.muted),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: ClaySurface.decoration(
                color: const Color(0xFFF7F5FF),
                radius: 30,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      s.offline,
                      style: theme.bodySmall?.copyWith(color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => AppArtwork(
              asset: AppArtwork.opening,
              height: (constraints.maxWidth * .72).clamp(180, 290).toDouble(),
            ),
          ),
          Text(
            s.tagline,
            style: theme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            s.welcomeDescription,
            style: theme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            key: const Key('startCheck'),
            label: s.startCheck,
            icon: Icons.search_rounded,
            onPressed: () => _openSearch(),
          ),
          const SizedBox(height: 14),
          const PrivacyNote(),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow =
                  constraints.maxWidth < 330 ||
                  MediaQuery.textScalerOf(context).scale(14) > 21;
              final cards = [
                _FeatureCard(
                  icon: Icons.link_rounded,
                  title: s.featureLinks,
                  body: s.featureLinksBody,
                ),
                _FeatureCard(
                  icon: Icons.fact_check_outlined,
                  title: s.featureMessages,
                  body: s.featureMessagesBody,
                ),
              ];
              return narrow
                  ? Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 10),
                        cards[1],
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[1]),
                        ],
                      ),
                    );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: ClaySurface.decoration(color: const Color(0xFFE8E4F8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.ink,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.homeTip, style: theme.titleMedium),
                      const SizedBox(height: 4),
                      Text(s.homeTipBody, style: theme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            s.privacyShort,
            textAlign: TextAlign.center,
            style: theme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: ClaySurface.decoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(icon: icon, size: 44),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
