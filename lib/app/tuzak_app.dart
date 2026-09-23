import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/analysis/application/analysis_controller.dart';
import '../features/analysis/domain/models/rule_set.dart';
import '../features/analysis/presentation/screens/home_screen.dart';
import '../l10n/app_localizations.dart';

class TuzakApp extends StatelessWidget {
  const TuzakApp({super.key, this.rules, this.analyzer});
  final RuleSet? rules;
  final Analyzer? analyzer;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tuzak',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: HomeScreen(rules: rules, analyzer: analyzer),
  );
}
