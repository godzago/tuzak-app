import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/app/tuzak_app.dart';
import 'package:tuzak/core/widgets/app_artwork.dart';
import 'package:tuzak/app/startup_screen.dart';
import 'package:tuzak/l10n/app_localizations.dart';
import 'package:tuzak/core/theme/app_theme.dart';
import 'package:tuzak/features/analysis/data/rule_repository.dart';
import 'package:tuzak/features/analysis/presentation/screens/search_screen.dart';
import 'package:tuzak/features/analysis/presentation/screens/result_screen.dart';
import '../support/sample_results.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';

void main() {
  testWidgets(
    'capture real Flutter screens for visual review',
    (tester) async {
      final previousShadows = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = previousShadows);
      tester.view.physicalSize = const Size(430, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: TuzakApp(
            connectionCheck: () async => true,
            showSplash: false,
            rules: await RuleRepository().load(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (final asset in [
          AppArtwork.opening,
          AppArtwork.search,
          AppArtwork.splash,
        ]) {
          await precacheImage(
            AssetImage(asset),
            tester.element(find.byType(MaterialApp)),
          );
        }
      });
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('build/qa')..createSync(recursive: true);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('home');
      final start = find.byKey(const Key('startCheck'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      await capture('search');
      for (final risk in RiskLevel.values) {
        Navigator.of(tester.element(find.byType(SearchScreen))).push<void>(
          MaterialPageRoute(
            builder: (_) => ResultScreen(result: sampleResult(risk)),
          ),
        );
        await tester.pumpAndSettle();
        await capture('result-${risk.name}');
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Geri'));
        await tester.pumpAndSettle();
      }
      Navigator.of(tester.element(find.byType(SearchScreen))).push<void>(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: AnalysisResult(
              level: RiskLevel.low,
              score: 0,
              rulesVersion: 'test',
              usomChecked: false,
              threatCheck: ThreatCheckStatus.unavailable,
              reasons: [ReasonCode.noSignals],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await capture('result-unverified');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await capture('splash');
      debugDisableShadows = previousShadows;
    },
    skip: !const bool.fromEnvironment('CAPTURE_SCREENSHOTS'),
  );
}
