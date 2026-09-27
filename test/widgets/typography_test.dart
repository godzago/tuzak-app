import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuzak/core/theme/app_theme.dart';

void main() {
  test('all Material text roles use Poppins at bundled weights', () async {
    final t = AppTheme.light.textTheme;
    final styles = [
      t.displayLarge,
      t.displayMedium,
      t.displaySmall,
      t.headlineLarge,
      t.headlineMedium,
      t.headlineSmall,
      t.titleLarge,
      t.titleMedium,
      t.titleSmall,
      t.bodyLarge,
      t.bodyMedium,
      t.bodySmall,
      t.labelLarge,
      t.labelMedium,
      t.labelSmall,
    ];
    for (final style in styles) {
      expect(style?.fontFamily, startsWith('Poppins'));
      expect(
        style?.fontWeight,
        isIn([
          FontWeight.w400,
          FontWeight.w500,
          FontWeight.w600,
          FontWeight.w700,
        ]),
      );
    }
    expect(t.headlineLarge?.fontWeight, FontWeight.w700);
    expect(t.titleLarge?.fontWeight, FontWeight.w600);
    expect(t.bodyLarge?.fontWeight, FontWeight.w400);
    expect(t.labelSmall?.fontWeight, FontWeight.w500);
    expect(t.labelSmall?.letterSpacing, greaterThan(0));
    expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
    await GoogleFonts.pendingFonts();
  });

  test(
    'all four weights are bundled as assets and a local font family',
    () async {
      final assets = (await AssetManifest.loadFromAssetBundle(
        rootBundle,
      )).listAssets();
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        final path = 'assets/fonts/poppins/Poppins-$weight.ttf';
        expect(assets, contains(path));
        final data = await rootBundle.load(path);
        expect(data.getUint32(0), 0x00010000);
      }
      final fontManifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
      final family = fontManifest.singleWhere((f) => f['family'] == 'Poppins');
      expect((family['fonts'] as List).map((f) => f['weight']), [
        400,
        500,
        600,
        700,
      ]);
      expect(fontManifest.any((f) => f['family'] == 'Inter'), isFalse);
      expect(
        await rootBundle.loadString('assets/fonts/poppins/OFL.txt'),
        contains('Poppins'),
      );
    },
  );
}
