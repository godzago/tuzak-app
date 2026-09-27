import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../services/threat_api_service.dart';
import '../domain/engine/entity_extractor.dart';
import '../domain/engine/host_normalizer.dart';
import '../domain/models/analysis_result.dart';

const _debugBuild =
    !bool.fromEnvironment('dart.vm.product') &&
    !bool.fromEnvironment('dart.vm.profile');

typedef DomainLookup =
    Future<ThreatMatch?> Function(String domain, {CancelToken? cancelToken});

class ThreatEnrichedAnalyzer {
  ThreatEnrichedAnalyzer({
    required this.analyzeLocal,
    required this.checkDomain,
    required this.checkPhone,
    void Function(String)? debugLogger,
  }) : _debugLogger = debugLogger ?? Zone.current.print;

  final Future<AnalysisResult> Function(String) analyzeLocal;
  final DomainLookup checkDomain;
  final DomainLookup checkPhone;
  final void Function(String) _debugLogger;
  final Set<CancelToken> _active = {};
  bool _disposed = false;

  void _debug(String message) {
    assert(() {
      try {
        _debugLogger(message);
      } catch (_) {
        // Debugging must not affect analysis.
      }
      return true;
    }());
  }

  Future<AnalysisResult> analyze(String message) async {
    final local = await analyzeLocal(message);
    if (_disposed) return local;
    final extracted = const EntityExtractor().extract(message);
    final lookups = <({ThreatEntityType type, String value})>[
      for (final url in extracted.urls)
        (
          type: isIpHost(url.host)
              ? ThreatEntityType.ip
              : ThreatEntityType.domain,
          value: url.host,
        ),
      for (final phone in extracted.phones)
        if (ThreatApiService.phoneForQuery(phone) case final number?)
          (type: ThreatEntityType.phone, value: number),
    ];
    if (lookups.isEmpty) return local;

    final replies = <ThreatMatch>[];
    final tokens = <CancelToken>[];
    var accepting = true;
    try {
      await Future.wait<void>(
        lookups.map((lookup) async {
          final token = CancelToken();
          tokens.add(token);
          _active.add(token);
          try {
            final reply = await (lookup.type == ThreatEntityType.phone
                ? checkPhone(lookup.value, cancelToken: token)
                : checkDomain(lookup.value, cancelToken: token));
            if (accepting && reply != null) replies.add(reply);
          } on ThreatApiException {
            if (_debugBuild) {
              _debug('lookup_batch_api_failure kind=${lookup.type.name}');
            }
            rethrow;
          } catch (_) {
            if (_debugBuild) {
              _debug(
                'lookup_batch_unexpected_failure kind=${lookup.type.name}',
              );
            }
            rethrow;
          } finally {
            _active.remove(token);
          }
        }),
      ).timeout(
        ThreatApiConfig.batchTimeout,
        onTimeout: () {
          if (_debugBuild) {
            _debug('lookup_batch_timeout count=${lookups.length}');
          }
          return <void>[];
        },
      );
    } finally {
      accepting = false;
      for (final token in tokens) {
        token.cancel();
        _active.remove(token);
      }
    }

    final matches = replies.where((r) => r.found).toList()
      ..sort(
        (a, b) =>
            (a.criticalityLevel ?? 11).compareTo(b.criticalityLevel ?? 11),
      );
    final match = matches.firstOrNull;
    final cleanReplies = replies.where((r) => !r.found).length;
    final addCleanReason =
        match == null && cleanReplies > 0 && local.level == RiskLevel.low;
    var level = local.level;
    if (match?.isCritical == true) {
      level = RiskLevel.dangerous;
    } else if (match != null && level.index < RiskLevel.high.index) {
      // Criticality ranks incidents; even level 8 is a confirmed threat record.
      level = RiskLevel.high;
    }
    return AnalysisResult(
      level: level,
      score: local.score,
      rulesVersion: local.rulesVersion,
      usomChecked: local.usomChecked,
      checkedEntity: local.checkedEntity,
      reasonDescriptions: local.reasonDescriptions,
      reasons: [
        if (match != null) ReasonCode.officialThreat,
        if (addCleanReason) ReasonCode.officialClean,
        ...local.reasons.where(
          (r) =>
              (match == null || r != ReasonCode.noSignals) &&
              (!addCleanReason || r != ReasonCode.noSignals),
        ),
      ],
      threatMatch: match,
      threatCheck: replies.isEmpty
          ? ThreatCheckStatus.unavailable
          : replies.length == lookups.length
          ? ThreatCheckStatus.complete
          : ThreatCheckStatus.partial,
    );
  }

  void dispose() {
    _disposed = true;
    for (final token in _active) {
      token.cancel();
    }
    _active.clear();
  }
}
