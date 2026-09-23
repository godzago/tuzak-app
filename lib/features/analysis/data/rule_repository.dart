import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/rule_set.dart';

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
    final files = await Future.wait([
      _loadData('rules'),
      _loadData('brands'),
      _loadData('usom'),
    ]);
    return RuleSet.fromJson(
      jsonDecode(files[0]) as Map<String, dynamic>,
      jsonDecode(files[1]) as Map<String, dynamic>,
      jsonDecode(files[2]) as Map<String, dynamic>,
    );
  }
}
