import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/app/startup_screen.dart';
import 'package:tuzak/app/tuzak_app.dart';
import 'package:tuzak/core/widgets/app_artwork.dart';
import 'package:tuzak/features/analysis/domain/models/rule_set.dart';
import 'package:tuzak/features/analysis/presentation/screens/home_screen.dart';
import 'package:tuzak/features/analysis/presentation/screens/search_screen.dart';
import 'package:tuzak/features/sharing/incoming_share_service.dart';
import 'package:tuzak/l10n/app_localizations.dart';

class _PendingShare extends IncomingShareService {
  String? text = 'Paylaşılan örnek mesaj';
  @override
  Future<String?> takePendingText() async {
    final pending = text;
    text = null;
    return pending;
  }
}

Future<bool?> connected() async => true;

void main() {
  void size(WidgetTester tester, {Size dimensions = const Size(430, 1000)}) {
    tester.view.physicalSize = dimensions;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'splash leads to home, search, and back without replaying splash',
    (tester) async {
      size(tester);
      await tester.pumpWidget(TuzakApp(connectionCheck: connected));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.image(const AssetImage(AppArtwork.opening)), findsOneWidget);
      final start = find.byKey(const Key('startCheck'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.image(const AssetImage(AppArtwork.search)), findsOneWidget);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    },
  );

  testWidgets(
    'slow or failed rules cannot strand startup or yield a fake result',
    (tester) async {
      size(tester);
      final pending = Completer<RuleSet>();
      await tester.pumpWidget(
        TuzakApp(loadRules: () => pending.future, connectionCheck: connected),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(SplashScreen), findsOneWidget);
      pending.completeError(const FormatException('invalid bundle'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposing during splash cancels its timer', (tester) async {
    await tester.pumpWidget(TuzakApp(connectionCheck: connected));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home and search work at 320px with large text', (tester) async {
    size(tester, dimensions: const Size(320, 700));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      TuzakApp(showSplash: false, connectionCheck: connected),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pending share opens search with the message, once', (
    tester,
  ) async {
    size(tester);
    final sharing = _PendingShare();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(rules: null, sharing: sharing),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('messageInput')))
          .controller!
          .text,
      'Paylaşılan örnek mesaj',
    );
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsNothing);
    expect(sharing.text, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline banner persists while every screen remains usable', (
    tester,
  ) async {
    size(tester);
    var checks = 0;
    await tester.pumpWidget(
      TuzakApp(
        connectionCheck: () async {
          checks++;
          return false;
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();
    const warning = 'İnternet bağlantısı yok — kontroller sınırlı olabilir.';
    expect(find.text(warning), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(warning), findsOneWidget);
    final start = find.byKey(const Key('startCheck'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text(warning), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(checks, 1);
    expect(find.text(warning), findsOneWidget);
  });

  for (final connected in [true, null]) {
    testWidgets('startup with network status $connected does not warn', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(
        TuzakApp(showSplash: false, connectionCheck: () async => connected),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });
  }

  testWidgets(
    'connectivity delay cannot hold startup or notify after dispose',
    (tester) async {
      size(tester);
      final pending = Completer<bool?>();
      await tester.pumpWidget(
        TuzakApp(showSplash: false, connectionCheck: () => pending.future),
      );
      await tester.pump();
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      pending.complete(false);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('connectivity stream updates the banner automatically', (
    tester,
  ) async {
    size(tester);
    final statuses = StreamController<bool>();
    addTearDown(statuses.close);
    await tester.pumpWidget(
      TuzakApp(
        showSplash: false,
        connectionCheck: connected,
        connectionChanges: () => statuses.stream,
      ),
    );
    await tester.pumpAndSettle();
    const warning = 'İnternet bağlantısı yok — kontroller sınırlı olabilir.';
    expect(find.text(warning), findsNothing);
    statuses.add(false);
    await tester.pumpAndSettle();
    expect(find.text(warning), findsOneWidget);
    statuses.add(true);
    await tester.pumpAndSettle();
    expect(find.text(warning), findsNothing);
  });
}
