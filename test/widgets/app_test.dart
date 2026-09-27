import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/app/tuzak_app.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';
import '../support/sample_results.dart';

void main() {
  Future<void> launch(
    WidgetTester tester, {
    bool real = false,
    RiskLevel level = RiskLevel.low,
  }) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TuzakApp(
        showSplash: false,
        connectionCheck: () async => true,
        analyzer: real ? (_) async => sampleResult(level) : null,
      ),
    );
    await tester.pumpAndSettle();
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    await tester.tap(start);
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
      expect(
        find.textContaining('Kontrol şu an kullanılamıyor.'),
        findsOneWidget,
      );
    },
  );

  for (final level in RiskLevel.values) {
    testWidgets(
      '${level.name} result uses the normal flow and clears input on return',
      (tester) async {
        await launch(tester, real: true, level: level);
        await tester.enterText(
          find.byKey(const Key('messageInput')),
          'Private message',
        );
        await tester.pump();
        final check = find.byKey(const Key('checkButton'));
        await tester.ensureVisible(check);
        await tester.tap(check);
        await tester.pumpAndSettle();
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(
          tester.widget<ResultScreen>(find.byType(ResultScreen)).result.level,
          level,
        );
        expect(find.textContaining('ÖRNEK SONUÇ'), findsNothing);
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
  testWidgets('overlong clipboard input is rejected with a friendly message', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async =>
          call.method == 'Clipboard.getData' ? {'text': 'a' * 10001} : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await launch(tester);
    await tester.tap(find.text('Yapıştır'));
    await tester.pumpAndSettle();
    expect(find.textContaining('en fazla 10.000 karakter'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('a 10000 character message completes without crashing', (
    tester,
  ) async {
    await launch(tester, real: true);
    await tester.enterText(find.byKey(const Key('messageInput')), 'a' * 10000);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text
          .length,
      10000,
    );
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('technical analyzer failures never expose raw details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TuzakApp(
        showSplash: false,
        connectionCheck: () async => true,
        analyzer: (_) async => throw StateError(
          'https://siberguvenlik.gov.tr/api/address/index '
          'criticality_level=1 category=PH secret-token',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('messageInput')), 'hello');
    await tester.pump();
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.textContaining('Kontrol tamamlanamadı.'), findsOneWidget);
    expect(find.textContaining('siberguvenlik.gov.tr'), findsNothing);
    expect(find.textContaining('criticality_level'), findsNothing);
    expect(find.textContaining('secret-token'), findsNothing);
  });
  testWidgets('script-like text stays plain and is removed before results', (
    tester,
  ) async {
    const script = '<script>alert(1)</script>';
    await launch(tester, real: true);
    await tester.enterText(find.byKey(const Key('messageInput')), script);
    await tester.pump();
    expect(find.text(script), findsOneWidget);
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.textContaining('<script>'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('320px wide with large text has no layout overflow', (
    tester,
  ) async {
    await launch(tester, real: true, level: RiskLevel.dangerous);
    tester.view.physicalSize = const Size(320, 700);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const Key('messageInput')),
      'Test mesajı',
    );
    await tester.pump();
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('phone landscape flow has no layout overflow', (tester) async {
    await launch(tester, real: true, level: RiskLevel.high);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const Key('messageInput')),
      'Acele et, bu linki aç: ptt-kargo.xyz/takip',
    );
    await tester.pump();
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
