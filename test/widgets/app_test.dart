import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/app/tuzak_app.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';

void main() {
  Future<void> launch(WidgetTester tester, {bool real = false}) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TuzakApp(
        analyzer: real
            ? (_) async => AnalysisResult(
                level: RiskLevel.low,
                score: 0,
                reasons: [ReasonCode.noSignals],
                rulesVersion: 'test',
              )
            : null,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'blank input disables check and unavailable rules never show a result',
    (tester) async {
      await launch(tester);
      final button = find.descendant(
        of: find.byKey(const Key('checkButton')),
        matching: find.byType(FilledButton),
      );
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('messageInput')), '   ');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('messageInput')), 'Merhaba');
      await tester.pump();
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(ResultScreen), findsNothing);
      expect(find.textContaining('Analiz henüz hazır değil.'), findsOneWidget);
    },
  );

  for (final level in RiskLevel.values) {
    testWidgets(
      '${level.name} preview is labelled and clears input on return',
      (tester) async {
        await launch(tester);
        await tester.enterText(
          find.byKey(const Key('messageInput')),
          'Private message',
        );
        final preview = find.byKey(Key('preview-${level.name}'));
        await tester.ensureVisible(preview);
        await tester.tap(preview);
        await tester.pumpAndSettle();
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.textContaining('mesajın analiz edilmedi'), findsOneWidget);
        await tester.tap(find.byTooltip('Geri'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('messageInput')))
              .controller!
              .text,
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('real analyzer navigation and scan-another clears input', (
    tester,
  ) async {
    await launch(tester, real: true);
    await tester.enterText(find.byKey(const Key('messageInput')), 'hello');
    await tester.pump();
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.textContaining('mesajın analiz edilmedi'), findsNothing);
    final another = find.byKey(const Key('scanAnother'));
    await tester.ensureVisible(another);
    await tester.tap(another);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text,
      isEmpty,
    );
  });
  testWidgets('clipboard action, no passive clipboard read', (tester) async {
    var reads = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          reads++;
          return {'text': 'Bir mesaj'};
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await launch(tester);
    expect(reads, 0);
    await tester.tap(find.text('Yapıştır'));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text,
      'Bir mesaj',
    );
  });
  testWidgets('320px wide with large text has no layout overflow', (
    tester,
  ) async {
    await launch(tester);
    tester.view.physicalSize = const Size(320, 700);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final preview = find.byKey(const Key('preview-dangerous'));
    await tester.ensureVisible(preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
