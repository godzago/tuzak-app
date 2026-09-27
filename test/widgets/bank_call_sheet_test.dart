import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/core/theme/app_theme.dart';
import 'package:tuzak/features/analysis/presentation/widgets/bank_call_sheet.dart';
import 'package:tuzak/l10n/app_localizations.dart';

void main() {
  testWidgets('bank call validates input and handles unavailable phone app', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BankCallSheet(
            openPhone: (uri) async {
              expect(uri.toString(), 'tel:4440123');
              return false;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), '444 0-123');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '4440123',
    );
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    final s = AppLocalizations.of(tester.element(find.byType(BankCallSheet)));
    expect(find.text(s.phoneUnavailable), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
