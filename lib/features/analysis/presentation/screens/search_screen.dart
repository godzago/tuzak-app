import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_artwork.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../info/info_screen.dart';
import '../../../sharing/incoming_share_service.dart';
import '../../application/analysis_controller.dart';
import '../../domain/engine/rule_engine.dart';
import '../../domain/models/analysis_result.dart';
import '../../domain/models/rule_set.dart';
import '../widgets/message_input_card.dart';
import '../widgets/privacy_note.dart';
import 'result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.rules,
    this.analyzer,
    this.messageController,
    this.sharing = const IncomingShareService(),
  });
  final RuleSet? rules;
  final Analyzer? analyzer;
  final TextEditingController? messageController;
  final IncomingShareService sharing;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _text;
  late final AnalysisController _analysis;
  bool _takingShare = false;
  bool _routeOpen = false;

  @override
  void initState() {
    super.initState();
    _text = widget.messageController ?? TextEditingController();
    _analysis = widget.analyzer != null
        ? AnalysisController(analyzeMessage: widget.analyzer!)
        : AnalysisController.fromRules(widget.rules);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _takeShare());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _takeShare();
  }

  Future<void> _takeShare() async {
    if (_takingShare || _routeOpen || _analysis.busy || !mounted) return;
    _takingShare = true;
    try {
      final text = await widget.sharing.takePendingText();
      if (!mounted || text == null || text.trim().isEmpty) return;
      if (text.length > RuleEngine.maxMessageLength) {
        _notify(AppLocalizations.of(context).inputTooLong);
        return;
      }
      setState(() {
        _text.text = text;
        _analysis.reset();
      });
      _notify(AppLocalizations.of(context).sharedMessageLoaded);
    } catch (_) {
      if (mounted) _notify(AppLocalizations.of(context).shareUnavailable);
    } finally {
      _takingShare = false;
    }
  }

  void _notify(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _paste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      final text = data?.text;
      final s = AppLocalizations.of(context);
      if (text == null || text.trim().isEmpty) {
        _notify(s.clipboardEmpty);
        return;
      }
      if (text.length > RuleEngine.maxMessageLength) {
        _notify(s.inputTooLong);
        return;
      }
      setState(() {
        _text.text = text;
        _text.selection = TextSelection.collapsed(offset: text.length);
        _analysis.reset();
      });
    } catch (_) {
      if (mounted) _notify(AppLocalizations.of(context).clipboardUnavailable);
    }
  }

  Future<void> _check() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await _analysis.analyze(_text.text);
    if (mounted && result != null) await _openResult(result);
    if (mounted) _takeShare();
  }

  Future<void> _openResult(AnalysisResult result) async {
    if (_routeOpen) return;
    _routeOpen = true;
    FocusManager.instance.primaryFocus?.unfocus();
    // Remove the raw message before navigating; results contain no message text.
    _text.clear();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
    if (!mounted) return;
    setState(() {
      _text.clear();
      _analysis.reset();
      _routeOpen = false;
    });
    _takeShare();
  }

  Future<void> _openInfo() async {
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
    _text.dispose();
    _analysis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: _analysis,
      builder: (context, _) => AppScaffold(
        header: AppHeader(
          title: s.searchHeader,
          onBack: () => Navigator.maybePop(context),
          trailing: IconButton(
            tooltip: s.infoTitle,
            onPressed: _analysis.busy ? null : _openInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: AppColors.muted,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            const AppArtwork(asset: AppArtwork.search, height: 156),
            const SizedBox(height: 4),
            Text(
              s.searchTitle,
              textAlign: TextAlign.center,
              style: theme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              s.searchSubtitle,
              textAlign: TextAlign.center,
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 24),
            MessageInputCard(
              controller: _text,
              enabled: !_analysis.busy,
              onChanged: (_) => setState(_analysis.reset),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final paste = OutlineButton(
                  label: s.paste,
                  icon: Icons.content_paste_rounded,
                  onPressed: _analysis.busy ? null : _paste,
                );
                final check = PrimaryButton(
                  key: const Key('checkButton'),
                  label: _analysis.busy ? s.checking : s.check,
                  icon: Icons.search_rounded,
                  loading: _analysis.busy,
                  onPressed: _text.text.trim().isEmpty ? null : _check,
                );
                if (constraints.maxWidth < 300 ||
                    MediaQuery.textScalerOf(context).scale(14) > 21) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [check, const SizedBox(height: 10), paste],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 4, child: paste),
                    const SizedBox(width: 12),
                    Expanded(flex: 6, child: check),
                  ],
                );
              },
            ),
            if (_analysis.failure != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: NoticeCard(
                  error: true,
                  text: switch (_analysis.failure!) {
                    AnalysisFailure.unavailable => s.analysisUnavailable,
                    AnalysisFailure.invalidInput => s.inputTooLong,
                    AnalysisFailure.failed => s.analysisFailed,
                  },
                ),
              ),
            const SizedBox(height: 20),
            const PrivacyNote(),
          ],
        ),
      ),
    );
  }
}
