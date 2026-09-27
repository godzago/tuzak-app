import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tuzak/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start without internet warns and remains usable', (
    tester,
  ) async {
    await app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(
      find.text('İnternet bağlantısı yok — kontroller sınırlı olabilir.'),
      findsOneWidget,
    );
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    final button = find.descendant(
      of: start,
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });
}
