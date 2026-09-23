import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tuzak/main.dart' as app;
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('offline preview round trip on a device', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('messageInput')),
      'Örnek mesaj',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final preview = find.byKey(const Key('preview-high'));
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
  });
}
