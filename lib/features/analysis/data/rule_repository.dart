import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/rule_set.dart';
import 'asset_rule_adapter.dart';

class RuleRepository {
  RuleRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  Future<String> _loadData(String name) async {
    final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    final path = 'assets/data/$name.json';
    return _bundle.loadString(
      manifest.listAssets().contains(path)
          ? path
          : 'assets/data/$name.example.json',
    );
  }

  Future<RuleSet> load() async {
    final rulesData =
        jsonDecode(await _loadData('rules')) as Map<String, dynamic>;
    if (rulesData.containsKey('url_signals')) {
      Map<String, dynamic>? usom;
      try {
        usom = jsonDecode(await _loadData('usom')) as Map<String, dynamic>;
      } catch (_) {
        // Local analysis remains available, with USOM explicitly unavailable.
      }
      return parseAssetRules(rulesData, usom);
    }
    final files = await Future.wait([_loadData('brands'), _loadData('usom')]);
    return RuleSet.fromJson(
      rulesData,
      jsonDecode(files[0]) as Map<String, dynamic>,
      jsonDecode(files[1]) as Map<String, dynamic>,
    );
  }
}
