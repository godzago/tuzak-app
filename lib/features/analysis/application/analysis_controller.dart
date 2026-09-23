import 'package:flutter/foundation.dart';
import '../domain/engine/rule_engine.dart';
import '../domain/models/analysis_result.dart';
import '../domain/models/rule_set.dart';

enum AnalysisFailure { unavailable, invalidInput, failed }

typedef Analyzer = Future<AnalysisResult> Function(String text);

class AnalysisController extends ChangeNotifier {
  AnalysisController({required this.analyzeMessage});

  factory AnalysisController.fromRules(RuleSet? rules) => AnalysisController(
    analyzeMessage: (text) async {
      if (rules == null) throw const RulesUnavailable();
      return compute(_runAnalysis, (rules, text));
    },
  );

  final Analyzer analyzeMessage;
  bool busy = false;
  AnalysisFailure? failure;
  int _generation = 0;
  bool _disposed = false;

  Future<AnalysisResult?> analyze(String text) async {
    if (busy) return null;
    if (text.trim().isEmpty || text.length > RuleEngine.maxMessageLength) {
      failure = AnalysisFailure.invalidInput;
      notifyListeners();
      return null;
    }
    final generation = ++_generation;
    busy = true;
    failure = null;
    notifyListeners();
    try {
      final result = await analyzeMessage(text);
      return !_disposed && generation == _generation ? result : null;
    } on RulesUnavailable {
      if (!_disposed && generation == _generation) {
        failure = AnalysisFailure.unavailable;
      }
    } on InvalidMessage {
      if (!_disposed && generation == _generation) {
        failure = AnalysisFailure.invalidInput;
      }
    } catch (_) {
      // Never log exception details: they may contain user input.
      if (!_disposed && generation == _generation) {
        failure = AnalysisFailure.failed;
      }
    } finally {
      if (!_disposed && generation == _generation) {
        busy = false;
        notifyListeners();
      }
    }
    return null;
  }

  void reset() {
    _generation++;
    busy = false;
    failure = null;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

AnalysisResult _runAnalysis((RuleSet, String) input) =>
    RuleEngine(input.$1).analyze(input.$2);
