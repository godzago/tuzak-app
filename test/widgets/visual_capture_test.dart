import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/app/tuzak_app.dart';
import 'package:tuzak/features/analysis/domain/models/analysis_result.dart';

void main() {
  testWidgets(
    'capture real Flutter screens for visual review',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1450);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final font = FontLoader('Inter')
        ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
      await font.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: boundaryKey, child: const TuzakApp()),
      );
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
      for (final risk in RiskLevel.values) {
        final button = find.byKey(Key('preview-${risk.name}'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        await capture('result-${risk.name}');
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Geri'));
        await tester.pumpAndSettle();
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_SCREENSHOTS'),
  );
}
