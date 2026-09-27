import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuzak/services/threat_api_service.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  bool cancelled = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    cancelFuture?.then((_) => cancelled = true);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody response(Object? body, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

Map<String, Object?> record({
  String domain = 'risk.example',
  Object? severity = 2,
  Object? category = 'BP',
  String type = 'domain',
}) => {
  'url': domain,
  'type': type,
  'criticality_level': severity,
  'desc': category,
};

void main() {
  ThreatApiService service(
    _Adapter adapter, {
    ThreatApiConfig config = const ThreatApiConfig(),
    void Function(String)? debugLogger,
  }) {
    final api = ThreatApiService(
      dio: Dio()..httpClientAdapter = adapter,
      config: config,
      debugLogger: debugLogger ?? (_) {},
    );
    addTearDown(api.dispose);
    return api;
  }

  test(
    'anonymous query contains only normalized domain and required filters',
    () async {
      final adapter = _Adapter(
        (_) => response({
          'totalCount': 1,
          'models': [record()],
        }),
      );
      final match = await service(adapter).checkDomain('RISK.EXAMPLE.');
      expect(match?.found, isTrue);
      expect(match?.criticalityLevel, 2);
      expect(match?.category, 'BP');
      final request = adapter.requests.single;
      expect(request.uri.origin, 'https://siberguvenlik.gov.tr');
      expect(request.uri.path, '/api/address/index');
      expect(request.queryParameters, {
        'q': 'risk.example',
        'type': 'domain',
        'per-page': 1,
      });
      expect(request.data, isNull);
      expect(
        request.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('x-api-key')),
      );
      expect(request.followRedirects, isFalse);
      expect(request.connectTimeout, const Duration(milliseconds: 3500));
      expect(request.receiveTimeout, const Duration(milliseconds: 3500));
    },
  );

  test('auth header name and prefix are configurable', () async {
    final adapter = _Adapter((_) => response({'totalCount': 0, 'models': []}));
    final api = service(
      adapter,
      config: const ThreatApiConfig(
        apiKey: 'synthetic-test-key',
        apiKeyHeader: 'Authorization',
        apiKeyPrefix: 'Bearer ',
      ),
    );
    expect((await api.checkDomain('clean.example'))?.found, isFalse);
    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer synthetic-test-key',
    );
  });

  test(
    'positive substring count alone cannot flag a different domain',
    () async {
      final adapter = _Adapter(
        (_) => response({
          'totalCount': 1,
          'models': [record(domain: 'not-risk.example')],
        }),
      );
      expect(
        (await service(adapter).checkDomain('risk.example'))?.found,
        isFalse,
      );
    },
  );

  test('expands a partial search to find the exact domain', () async {
    final adapter = _Adapter(
      (r) => response({
        'totalCount': 2,
        'models': [
          record(domain: 'not-risk.example'),
          if (r.queryParameters['per-page'] == 2)
            record(severity: '3', category: 'PH'),
        ],
      }),
    );
    final match = await service(adapter).checkDomain('risk.example');
    expect(adapter.requests.length, 2);
    expect(match?.isCritical, isTrue);
    expect(match?.category, 'PH');
  });

  test('incomplete substring results stay unknown rather than clean', () async {
    final adapter = _Adapter(
      (_) => response({
        'totalCount': 10000,
        'models': [record(domain: 'other.example')],
      }),
    );
    await expectLater(
      service(adapter).checkDomain('risk.example'),
      throwsA(isA<ThreatApiException>()),
    );
    expect(adapter.requests.last.queryParameters['per-page'], 9999);
  });

  test('missing or invalid severity never becomes critical', () async {
    for (final severity in [null, 0, -1, 11, 'bad', 2.5]) {
      final adapter = _Adapter(
        (_) => response({
          'totalCount': 1,
          'models': [record(severity: severity, category: '<untrusted>')],
        }),
      );
      final match = await service(adapter).checkDomain('risk.example');
      expect(match?.found, isTrue);
      expect(match?.criticalityLevel, isNull);
      expect(match?.isCritical, isFalse);
      expect(match?.category, isNull);
    }
  });

  test(
    'IP, whole URL, email and invalid input never leave the service',
    () async {
      final adapter = _Adapter((_) => throw StateError('unexpected request'));
      final api = service(adapter);
      for (final input in [
        'https://risk.example/private?code=123',
        '127.0.0.1',
        '[2001:db8::1]',
        'person@risk.example',
        'hello there',
        '',
        'risk.example/path',
      ]) {
        expect(await api.checkDomain(input), isNull);
      }
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'phone lookup always sends a normalized general address query',
    () async {
      final adapter = _Adapter(
        (_) => response({'totalCount': 0, 'models': []}),
      );
      final match = await service(adapter).checkPhone('+90 (532) 123 45 67');
      expect(match?.found, isFalse);
      expect(match?.entityType, ThreatEntityType.phone);
      expect(adapter.requests.single.queryParameters, {
        'q': '905321234567',
        'per-page': 1,
      });
    },
  );

  test('IP-host links use the official IP filter', () async {
    final adapter = _Adapter((_) => response({'totalCount': 0, 'models': []}));
    final match = await service(adapter).checkHost('2001:db8::1');
    expect(match?.found, isFalse);
    expect(match?.entityType, ThreatEntityType.ip);
    expect(adapter.requests.single.queryParameters, {
      'q': '2001:db8::1',
      'type': 'ip',
      'per-page': 1,
    });
  });

  test('an exact phone record is interpreted and escalatable', () async {
    final adapter = _Adapter(
      (_) => response({
        'totalCount': 1,
        'models': [
          record(domain: '+90 532 123 45 67', type: 'phone', severity: 2),
        ],
      }),
    );
    final match = await service(adapter).checkPhone('0532 123 45 67');
    expect(match?.found, isTrue);
    expect(match?.criticalityLevel, 2);
    expect(match?.entityType, ThreatEntityType.phone);
  });

  for (final status in [301, 401, 403, 429, 500, 503]) {
    test('HTTP $status is reported instead of silently skipped', () async {
      final adapter = _Adapter(
        (_) => response({'error': 'not available'}, status: status),
      );
      await expectLater(
        service(adapter).checkDomain('risk.example'),
        throwsA(isA<ThreatApiException>()),
      );
    });
  }

  test('HTML and malformed payloads are reported', () async {
    for (final payload in [
      null,
      '<html>login</html>',
      [],
      {},
      {'totalCount': 'bad', 'models': []},
      {'totalCount': -1, 'models': []},
      {
        'totalCount': 0,
        'models': [record()],
      },
      {'totalCount': 1},
      {
        'totalCount': 1,
        'models': [record(type: 'url')],
      },
    ]) {
      final adapter = _Adapter((_) => response(payload));
      await expectLater(
        service(adapter).checkDomain('risk.example'),
        throwsA(isA<ThreatApiException>()),
      );
    }
  });

  test('an actual connection failure quietly returns null', () async {
    final adapter = _Adapter(
      (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );
    expect(await service(adapter).checkDomain('risk.example'), isNull);
  });

  test(
    'a bad TLS certificate is never treated as an offline fallback',
    () async {
      final adapter = _Adapter(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.badCertificate,
        ),
      );
      await expectLater(
        service(adapter).checkDomain('risk.example'),
        throwsA(isA<ThreatApiException>()),
      );
    },
  );

  test('total timeout aborts an unresponsive request at 3.5 seconds', () {
    fakeAsync((clock) {
      final adapter = _Adapter((_) => Completer<ResponseBody>().future);
      final api = service(adapter);
      var done = false;
      ThreatMatch? result;
      api.checkDomain('risk.example').then((r) {
        done = true;
        result = r;
      });
      clock.flushMicrotasks();
      clock.elapse(const Duration(milliseconds: 3499));
      expect(done, isFalse);
      clock.elapse(const Duration(milliseconds: 1));
      expect(done, isTrue);
      expect(result, isNull);
      expect(adapter.cancelled, isTrue);
    });
  });

  test(
    'reported public threat response is matched by its complete subdomain',
    () async {
      const host = 'toria.apple03cloudstore.com';
      final logs = <String>[];
      final adapter = _Adapter(
        (_) => response({
          'totalCount': 1,
          'count': 1,
          'page': 0,
          'pageCount': 1,
          'models': [
            {
              ...record(domain: host, severity: 8, category: 'MD'),
              'id': 1172234,
              'source': 'SB',
              'connectiontype': 'OT',
            },
          ],
        }),
      );
      final match = await service(
        adapter,
        debugLogger: logs.add,
      ).checkDomain(host);
      expect(adapter.requests.single.queryParameters, {
        'q': host,
        'type': 'domain',
        'per-page': 1,
      });
      expect(match?.found, isTrue);
      expect(match?.criticalityLevel, 8);
      expect(match?.category, 'MD');
      expect(logs.join('\n'), contains('lookup_start kind=domain'));
      expect(logs.join('\n'), contains('lookup_response kind=domain'));
    },
  );

  test(
    '401/403 are explicit in debug logs and never reveal an API key',
    () async {
      for (final status in [401, 403]) {
        final logs = <String>[];
        final adapter = _Adapter(
          (_) => response({'error': 'synthetic-secret'}, status: status),
        );
        final api = service(
          adapter,
          config: const ThreatApiConfig(apiKey: 'synthetic-secret'),
          debugLogger: logs.add,
        );
        await expectLater(
          api.checkDomain('risk.example'),
          throwsA(isA<ThreatApiException>()),
        );
        final output = logs.join('\n');
        expect(
          output,
          contains('lookup_auth_failure kind=domain HTTP=$status'),
        );
        expect(output, contains('authConfigured=true'));
        expect(output, isNot(contains('synthetic-secret')));
      }
    },
  );

  test(
    'debug response logs never include echoed keys or response bodies',
    () async {
      const key = 'synthetic-"secret"';
      final logs = <String>[];
      final adapter = _Adapter(
        (_) => response({
          'totalCount': 0,
          'models': [],
          'echo': key,
          'padding': 'x' * 5000,
        }),
      );
      final api = service(
        adapter,
        config: const ThreatApiConfig(apiKey: key),
        debugLogger: logs.add,
      );
      expect((await api.checkDomain('clean.example'))?.found, isFalse);
      final output = logs.join('\n');
      expect(output, isNot(contains(key)));
      expect(output, isNot(contains('synthetic-')));
      expect(logs.every((line) => line.length <= 4097), isTrue);
    },
  );

  test('a failing debug logger cannot interrupt a valid lookup', () async {
    final adapter = _Adapter(
      (_) => response({
        'totalCount': 1,
        'models': [record()],
      }),
    );
    final api = service(
      adapter,
      debugLogger: (_) => throw StateError('logger failed'),
    );
    expect((await api.checkDomain('risk.example'))?.found, isTrue);
  });
}
