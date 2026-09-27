import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuzak/core/theme/app_theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (_) async => ['wifi'],
        );
  });
  // Exercise real asset font loading, including on a clean offline first run.
  // Load before the widget tests' fake clock to avoid asynchronous font swaps.
  await HttpOverrides.runZoned(() async {
    AppTheme.light;
    await GoogleFonts.pendingFonts();
  }, createHttpClient: (_) => throw StateError('Font loading attempted HTTP'));
  await testMain();
}
