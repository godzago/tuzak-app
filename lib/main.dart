import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'app/tuzak_app.dart';
import 'features/analysis/data/rule_repository.dart';
import 'features/analysis/domain/models/rule_set.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  RuleSet? rules;
  try {
    rules = await RuleRepository().load();
  } catch (_) {
    // A missing or invalid rule bundle must never produce a low-risk result.
  }
  runApp(TuzakApp(rules: rules));
}
