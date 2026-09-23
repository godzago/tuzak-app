import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/features/analysis/application/analysis_controller.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';

AnalysisResult result() => AnalysisResult(
  level: RiskLevel.low,
  score: 0,
  reasons: [ReasonCode.noSignals],
  rulesVersion: 'test',
);

void main() {
  test('double submit starts only one analysis', () async {
    final pending = Completer<AnalysisResult>();
    var calls = 0;
    final controller = AnalysisController(
      analyzeMessage: (_) {
        calls++;
        return pending.future;
      },
    );
    final first = controller.analyze('hello');
    expect(controller.busy, isTrue);
    expect(await controller.analyze('hello'), isNull);
    pending.complete(result());
    expect(await first, isNotNull);
    expect(calls, 1);
    expect(controller.busy, isFalse);
    controller.dispose();
  });
  test('reset ignores late results', () async {
    final pending = Completer<AnalysisResult>();
    final controller = AnalysisController(
      analyzeMessage: (_) => pending.future,
    );
    final future = controller.analyze('hello');
    controller.reset();
    pending.complete(result());
    expect(await future, isNull);
    expect(controller.failure, isNull);
    controller.dispose();
  });
  test('dispose during analysis is safe', () async {
    final pending = Completer<AnalysisResult>();
    final controller = AnalysisController(
      analyzeMessage: (_) => pending.future,
    );
    final future = controller.analyze('hello');
    controller.dispose();
    pending.completeError(const RulesUnavailable());
    expect(await future, isNull);
  });
  test('missing rules return no result', () async {
    final controller = AnalysisController.fromRules(null);
    expect(await controller.analyze('hello'), isNull);
    expect(controller.failure, AnalysisFailure.unavailable);
    controller.dispose();
  });
}
