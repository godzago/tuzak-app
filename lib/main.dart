import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/tuzak_app.dart';
import 'features/analysis/data/rule_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Poppins',
    ], await rootBundle.loadString('assets/fonts/poppins/OFL.txt'));
  });
  runApp(TuzakApp(loadRules: RuleRepository().load));
}
