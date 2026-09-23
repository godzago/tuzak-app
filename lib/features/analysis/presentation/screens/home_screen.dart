import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
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
import '../preview_results.dart';
import '../result_presentation.dart';
import '../widgets/message_input_card.dart';
import '../widgets/privacy_note.dart';
import 'result_screen.dart';

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
  final _text = TextEditingController();
  late final AnalysisController _analysis;
  bool _takingShare = false;
  bool _routeOpen = false;

  @override
  void initState() {
    super.initState();
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => InfoScreen(rules: widget.rules)),
    );
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
          title: s.appName,
          brand: true,
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
            const SizedBox(height: 20),
            const _ShieldHero(),
            const SizedBox(height: 22),
            Text(
              s.tagline,
              textAlign: TextAlign.center,
              style: theme.headlineLarge,
            ),
            const SizedBox(height: 14),
            Text(
              s.homeSubtitle,
              textAlign: TextAlign.center,
              style: theme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    s.offline,
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 36),
            const Divider(),
            const SizedBox(height: 26),
            SectionLabel(s.howItWorks),
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                _Step(number: '01', label: s.stepPaste),
                _Step(number: '02', label: s.stepCheck),
                _Step(number: '03', label: s.stepDecide),
              ],
            ),
            if (widget.rules?.ready != true) ...[
              const SizedBox(height: 32),
              Text(s.previewTitle, style: theme.titleMedium),
              const SizedBox(height: 3),
              Text(s.previewSubtitle, style: theme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final level in RiskLevel.values)
                    OutlinedButton(
                      key: Key('preview-${level.name}'),
                      onPressed: _analysis.busy
                          ? null
                          : () => _openResult(previewResult(level)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: level.color,
                        side: BorderSide(
                          color: level.color.withValues(alpha: 0.2),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text(level.label(s)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(s.previewFootnote, style: theme.bodySmall),
            ],
            const SizedBox(height: 28),
            Text(
              s.privacyShort,
              textAlign: TextAlign.center,
              style: theme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShieldHero extends StatelessWidget {
  const _ShieldHero();
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDFE5EF)),
            ),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E6F0)),
            ),
          ),
          Container(
            width: 72,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF23486A), AppColors.ink],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 38,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 15,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F1E9),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label});
  final String number;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        number,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8190A5)),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.ink),
        ),
      ),
    ],
  );
}
