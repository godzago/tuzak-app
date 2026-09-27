import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../features/analysis/domain/engine/host_normalizer.dart';
import '../features/analysis/domain/models/threat_match.dart';

export '../features/analysis/domain/models/threat_match.dart';

const _debugBuild =
    !bool.fromEnvironment('dart.vm.product') &&
    !bool.fromEnvironment('dart.vm.profile');

class ThreatApiConfig {
  const ThreatApiConfig({
    this.apiKey = const String.fromEnvironment('THREAT_API_KEY'),
    this.apiKeyHeader = const String.fromEnvironment(
      'THREAT_API_KEY_HEADER',
      defaultValue: 'X-API-Key',
    ),
    this.apiKeyPrefix = const String.fromEnvironment('THREAT_API_KEY_PREFIX'),
  });

  static const baseUrl = 'https://siberguvenlik.gov.tr';
  static const requestTimeout = Duration(milliseconds: 3500);
  static const batchTimeout = Duration(seconds: 4);
  final String apiKey;
  final String apiKeyHeader;
  final String apiKeyPrefix;
}

class ThreatApiService {
  ThreatApiService({
    Dio? dio,
    this.config = const ThreatApiConfig(),
    void Function(String)? debugLogger,
  }) : _dio = dio ?? Dio(),
       _debugLogger = debugLogger ?? Zone.current.print {
    _dio.options = BaseOptions(
      baseUrl: ThreatApiConfig.baseUrl,
      connectTimeout: ThreatApiConfig.requestTimeout,
      receiveTimeout: ThreatApiConfig.requestTimeout,
      sendTimeout: ThreatApiConfig.requestTimeout,
      // Do not forward queried domains or credentials to redirects.
      followRedirects: false,
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        if (config.apiKey.isNotEmpty && config.apiKeyHeader.isNotEmpty)
          config.apiKeyHeader: '${config.apiKeyPrefix}${config.apiKey}',
      },
    );
  }

  final ThreatApiConfig config;
  final Dio _dio;
  final void Function(String) _debugLogger;

  // Assertions are disabled in release/profile builds. Keep diagnostics lazy
  // so response serialization and logging only happen during debugging.
  void _debug(String Function() message) {
    assert(() {
      try {
        var text = message();
        final key = config.apiKey;
        if (key.isNotEmpty) {
          final encoded = jsonEncode(key);
          text = text
              .replaceAll(
                encoded.substring(1, encoded.length - 1),
                '[REDACTED]',
              )
              .replaceAll(key, '[REDACTED]');
        }
        _debugLogger(text.length > 4096 ? '${text.substring(0, 4096)}…' : text);
      } catch (_) {
        // Diagnostics must never change the result of a threat check.
      }
      return true;
    }());
  }

  static String? domainForQuery(String value) {
    try {
      final host = normalizeHost(value.trim());
      return isIpHost(host) ? null : host;
    } catch (_) {
      return null;
    }
  }

  static String? phoneForQuery(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length == 12) return digits;
    if (digits.startsWith('0') && digits.length == 11) {
      return '90${digits.substring(1)}';
    }
    if (digits.length == 10 && digits.startsWith('5')) return '90$digits';
    return null;
  }

  Future<ThreatMatch?> checkDomain(
    String domain, {
    CancelToken? cancelToken,
  }) async {
    final host = domainForQuery(domain);
    if (host == null) return null;
    return _check(host, ThreatEntityType.domain, cancelToken: cancelToken);
  }

  Future<ThreatMatch?> checkHost(
    String value, {
    CancelToken? cancelToken,
  }) async {
    late final String host;
    try {
      host = normalizeHost(value.trim());
    } catch (_) {
      return null;
    }
    return _check(
      host,
      isIpHost(host) ? ThreatEntityType.ip : ThreatEntityType.domain,
      cancelToken: cancelToken,
    );
  }

  Future<ThreatMatch?> checkPhone(
    String phone, {
    CancelToken? cancelToken,
  }) async {
    final normalized = phoneForQuery(phone);
    if (normalized == null) return null;
    return _check(normalized, ThreatEntityType.phone, cancelToken: cancelToken);
  }

  Future<ThreatMatch?> _check(
    String query,
    ThreatEntityType entityType, {
    CancelToken? cancelToken,
  }) async {
    final token = cancelToken ?? CancelToken();
    final elapsed = Stopwatch()..start();
    if (_debugBuild) _debug(() => 'lookup_start kind=${entityType.name}');
    try {
      late final ThreatMatch result;
      try {
        result = await _lookup(
          query,
          entityType,
          token,
        ).timeout(ThreatApiConfig.requestTimeout);
      } on TimeoutException {
        if (_debugBuild) _debug(() => 'lookup_timeout kind=${entityType.name}');
        token.cancel();
        return null;
      }
      if (_debugBuild) {
        _debug(
          () =>
              'lookup_success kind=${entityType.name} found=${result.found} '
              'criticality=${result.criticalityLevel ?? 'none'}',
        );
      }
      return result;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (_isConnectionFailure(error)) {
        if (_debugBuild) {
          _debug(
            () =>
                'lookup_connection_failure kind=${entityType.name} '
                'type=${error.type.name}',
          );
        }
        return null;
      }
      if (_debugBuild) {
        _debug(
          () => status == 401 || status == 403
              ? 'lookup_auth_failure kind=${entityType.name} HTTP=$status '
                    'authConfigured=${config.apiKey.isNotEmpty && config.apiKeyHeader.isNotEmpty}'
              : 'lookup_http_failure kind=${entityType.name} '
                    'type=${error.type.name} HTTP=${status ?? 'none'}',
        );
      }
      throw ThreatApiException('HTTP/API failure');
    } on ThreatApiException {
      rethrow;
    } catch (_) {
      if (_debugBuild) {
        _debug(() => 'lookup_invalid_response kind=${entityType.name}');
      }
      throw ThreatApiException('Invalid API response');
    } finally {
      elapsed.stop();
      if (_debugBuild) {
        _debug(
          () =>
              'lookup_end kind=${entityType.name} '
              'elapsedMs=${elapsed.elapsedMilliseconds}',
        );
      }
    }
  }

  Future<ThreatMatch> _lookup(
    String query,
    ThreatEntityType entityType,
    CancelToken token,
  ) async {
    var page = await _page(query, entityType, 1, token);
    if (page.total == 0) {
      return ThreatMatch(found: false, entityType: entityType);
    }
    var exact = _exactMatch(query, entityType, page.models);
    if (exact != null) return exact;
    // The live API's q is a substring search: example.com also finds
    // kgm-example.com. A positive count alone is NOT an exact threat match.
    if (page.total > page.models.length) {
      page = await _page(query, entityType, page.total.clamp(1, 9999), token);
      exact = _exactMatch(query, entityType, page.models);
      if (exact != null) return exact;
    }
    if (page.models.length < page.total ||
        page.models.any((item) => !_validRecord(item, entityType))) {
      throw ThreatApiException('Incomplete API search');
    }
    return ThreatMatch(found: false, entityType: entityType);
  }

  Future<({int total, List<dynamic> models})> _page(
    String query,
    ThreatEntityType entityType,
    int perPage,
    CancelToken token,
  ) async {
    if (_debugBuild) {
      _debug(() => 'lookup_request kind=${entityType.name} perPage=$perPage');
    }
    final response = await _dio.get<dynamic>(
      '/api/address/index',
      queryParameters: {
        'q': query,
        if (entityType == ThreatEntityType.domain) 'type': 'domain',
        if (entityType == ThreatEntityType.ip) 'type': 'ip',
        'per-page': perPage,
      },
      cancelToken: token,
    );
    if (response.statusCode != 200 || response.data is! Map) {
      throw ThreatApiException('Unexpected API response');
    }
    final data = response.data as Map;
    final total = _integer(data['totalCount']);
    final models = data['models'];
    if (total == null ||
        total < 0 ||
        models is! List ||
        models.length > total) {
      throw ThreatApiException('Invalid API payload');
    }
    if (_debugBuild) {
      _debug(
        () =>
            'lookup_response kind=${entityType.name} '
            'HTTP=${response.statusCode} total=$total count=${models.length}',
      );
    }
    return (total: total, models: models);
  }

  ThreatMatch? _exactMatch(
    String query,
    ThreatEntityType entityType,
    List<dynamic> models,
  ) {
    final matches = <ThreatMatch>[];
    for (final item in models) {
      if (item is! Map || item['url'] is! String) continue;
      final recordType = item['type'];
      final value = item['url'] as String;
      final exact = switch (entityType) {
        ThreatEntityType.domain =>
          recordType == 'domain' && domainForQuery(value) == query,
        ThreatEntityType.ip =>
          const {'ip', 'ipv4', 'ipv6', 'ipv6net'}.contains(recordType) &&
              _ipForQuery(value) == query,
        ThreatEntityType.phone =>
          (recordType == 'phone' || recordType == 'telephone') &&
              phoneForQuery(value) == query,
      };
      if (!exact) {
        continue;
      }
      final severity = _integer(item['criticality_level']);
      final category = item['desc'];
      matches.add(
        ThreatMatch(
          found: true,
          criticalityLevel: severity != null && severity >= 1 && severity <= 10
              ? severity
              : null,
          category:
              category is String &&
                  RegExp(r'^[A-Za-z0-9_-]{1,40}$').hasMatch(category)
              ? category
              : null,
          entityType: entityType,
        ),
      );
    }
    matches.sort(
      (a, b) => (a.criticalityLevel ?? 11).compareTo(b.criticalityLevel ?? 11),
    );
    return matches.firstOrNull;
  }

  bool _validRecord(dynamic item, ThreatEntityType entityType) {
    if (item is! Map || item['type'] is! String || item['url'] is! String) {
      return false;
    }
    if (entityType == ThreatEntityType.domain) {
      return item['type'] == 'domain' &&
          domainForQuery(item['url'] as String) != null;
    }
    if (entityType == ThreatEntityType.ip) {
      return const {'ip', 'ipv4', 'ipv6', 'ipv6net'}.contains(item['type']) &&
          _ipForQuery(item['url'] as String) != null;
    }
    // Phone searches use the API's unfiltered address search because the
    // published schema has no phone filter. Other well-formed address records
    // are valid non-matches; only explicit phone/telephone records can match.
    return const {
      'domain',
      'url',
      'ip',
      'ipv4',
      'ipv6',
      'ipv6net',
      'phone',
      'telephone',
    }.contains(item['type']);
  }

  bool _isConnectionFailure(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.cancel => true,
    DioExceptionType.unknown => error.error is TimeoutException,
    DioExceptionType.badCertificate || DioExceptionType.badResponse => false,
  };

  static int? _integer(dynamic value) => switch (value) {
    int v => v,
    String v => int.tryParse(v),
    _ => null,
  };

  static String? _ipForQuery(String value) {
    try {
      final host = normalizeHost(value.trim());
      return isIpHost(host) ? host : null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _dio.close(force: true);
}

class ThreatApiException implements Exception {
  const ThreatApiException(this.message);
  final String message;
}
