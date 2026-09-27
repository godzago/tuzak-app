import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/core/theme/app_theme.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';
import 'package:tuzak/features/analysis/domain/models/threat_match.dart';
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';
import 'package:tuzak/l10n/app_localizations.dart';

void main() {
  for (final status in ThreatCheckStatus.values) {
    testWidgets(
      'result clearly presents $status coverage without a technical error',
      (tester) async {
        final hasMatch =
            status == ThreatCheckStatus.complete ||
            status == ThreatCheckStatus.partial;
        tester.view.physicalSize = const Size(430, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ResultScreen(
              result: AnalysisResult(
                level: hasMatch ? RiskLevel.dangerous : RiskLevel.low,
                score: 0,
                rulesVersion: 'test',
                usomChecked: false,
                reasons: hasMatch
                    ? [ReasonCode.officialThreat]
                    : [ReasonCode.noSignals],
                threatCheck: status,
                checkedEntity: status == ThreatCheckStatus.localOnly
                    ? CheckedEntity.message
                    : CheckedEntity.link,
                threatMatch: !hasMatch
                    ? null
                    : const ThreatMatch(
                        found: true,
                        criticalityLevel: 1,
                        category: 'BP',
                      ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('threatCheckStatus')), findsNothing);
        expect(find.textContaining('Hukuki karar'), findsNothing);
        if (hasMatch) {
          expect(
            find.text('Bu adres banka dolandırıcılığı kayıtlarında var'),
            findsOneWidget,
          );
          expect(find.text('Bu linki açma'), findsOneWidget);
        }
        if (status == ThreatCheckStatus.unavailable) {
          expect(find.text('Kontrol yarım kaldı'), findsOneWidget);
          expect(find.text('Bağlantı temiz'), findsNothing);
        }
        if (status == ThreatCheckStatus.localOnly) {
          expect(find.text('Mesaj temiz'), findsOneWidget);
        }
        expect(find.textContaining('401'), findsNothing);
        expect(find.textContaining('112'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final (entity, title) in [
    (CheckedEntity.link, 'Bağlantı temiz'),
    (CheckedEntity.number, 'Numara temiz'),
    (CheckedEntity.message, 'Mesaj temiz'),
  ]) {
    testWidgets('clean title adapts to ${entity.name}', (tester) async {
      tester.view.physicalSize = const Size(430, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResultScreen(
            result: AnalysisResult(
              level: RiskLevel.low,
              score: 0,
              reasons: [ReasonCode.officialClean],
              rulesVersion: 'test',
              checkedEntity: entity,
              threatCheck: entity == CheckedEntity.message
                  ? ThreatCheckStatus.localOnly
                  : ThreatCheckStatus.complete,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    });
  }

  testWidgets('matched reasons sound specific and conversational', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResultScreen(
          result: AnalysisResult(
            level: RiskLevel.high,
            score: .9,
            reasons: const [
              ReasonCode.brandMismatch,
              ReasonCode.urgency,
              ReasonCode.prize,
            ],
            rulesVersion: 'test',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bu mesaja güvenme'), findsOneWidget);
    expect(find.text('Bu marka değil, sadece öyle görünüyor'), findsOneWidget);
    expect(find.text('Seni acele ettirmeye çalışıyor'), findsOneWidget);
    expect(find.text('Olmadık bir ödül vadediyor'), findsOneWidget);
    expect(find.text('Linke tıklama, cevap yazma'), findsNothing);
    expect(find.text('Cevap yazma, bilgi paylaşma'), findsOneWidget);
  });
}
