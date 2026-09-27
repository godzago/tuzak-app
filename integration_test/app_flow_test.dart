import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tuzak/main.dart' as app;
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('splash, home, offline analysis and return on a device', (
    tester,
  ) async {
    await app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    const clipboardMessage = 'Panodan gelen cihaz testi';
    await Clipboard.setData(const ClipboardData(text: clipboardMessage));
    await tester.tap(find.text('Yapıştır'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text,
      clipboardMessage,
    );
    await tester.enterText(
      find.byKey(const Key('messageInput')),
      'PTT: Son uyarı! Şifrenizi gönderin: https://ptt-islem.example',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final check = find.byKey(const Key('checkButton'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.textContaining('mesajın analiz edilmedi'), findsNothing);
    expect(
      tester.widget<ResultScreen>(find.byType(ResultScreen)).result.level.name,
      'high',
    );
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text,
      isEmpty,
    );
  });
}
