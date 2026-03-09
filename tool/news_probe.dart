import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

Future<void> main(List<String> args) async {
  final targetPath = args.isNotEmpty ? args.first : '/';
  final client = _NewsProbeClient();

  try {
    final result = await client.fetch(targetPath);
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
  } finally {
    client.close();
  }
}

class _NewsProbeClient {
  _NewsProbeClient()
    : _cookieJar = CookieJar(),
      _dio = Dio(
        BaseOptions(
          baseUrl: 'https://news.iwara.tv',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'text/html; charset=utf-8'},
          responseType: ResponseType.plain,
        ),
      ) {
    _dio.options.validateStatus = (status) => (status ?? 0) < 500;
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: _createHttpClient,
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequestHeaders = Map<String, dynamic>.from(options.headers);
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final CookieJar _cookieJar;
  HttpClient? _httpClient;
  Map<String, dynamic>? lastRequestHeaders;

  Map<String, String> _defaultHeaders() {
    return const <String, String>{
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9,ja;q=0.8,zh-CN;q=0.7',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      'Referer': 'https://news.iwara.tv/',
      'Origin': 'https://news.iwara.tv',
    };
  }

  HttpClient _createHttpClient() {
    final client = HttpClient();
    client.userAgent = null;
    client.idleTimeout = const Duration(seconds: 90);
    client.findProxy = (_) => 'DIRECT';
    _httpClient = client;
    return client;
  }

  Future<_ProbeResult> fetch(String path) async {
    final response = await _dio.get<String>(
      path,
      options: Options(
        headers: _defaultHeaders(),
        responseType: ResponseType.plain,
      ),
    );

    final body = response.data ?? '';
    final bodyLower = body.toLowerCase();
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse('https://news.iwara.tv$path'),
    );

    return _ProbeResult(
      path: path,
      statusCode: response.statusCode,
      isCloudflareChallenge:
          response.headers.value('cf-mitigated')?.toLowerCase() ==
              'challenge' ||
          bodyLower.contains('just a moment') ||
          bodyLower.contains('window._cf_chl_opt') ||
          bodyLower.contains('/cdn-cgi/challenge-platform/'),
      hasBody: body.trim().isNotEmpty,
      setCookieCount: response.headers['set-cookie']?.length ?? 0,
      cookieNames: cookies.map((cookie) => cookie.name).toList(growable: false),
      requestHeaders: lastRequestHeaders ?? const <String, dynamic>{},
      responseHeaders: Map<String, List<String>>.from(response.headers.map),
      bodySnippet: _snippet(body),
      userAgentRemoved: _httpClient?.userAgent == null,
      proxyRule: 'DIRECT',
    );
  }

  String _snippet(String body) {
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 400) return normalized;
    return '${normalized.substring(0, 400)}...';
  }

  void close() {
    _dio.close(force: true);
    _httpClient?.close(force: true);
    _httpClient = null;
  }
}

class _ProbeResult {
  const _ProbeResult({
    required this.path,
    required this.statusCode,
    required this.isCloudflareChallenge,
    required this.hasBody,
    required this.setCookieCount,
    required this.cookieNames,
    required this.requestHeaders,
    required this.responseHeaders,
    required this.bodySnippet,
    required this.userAgentRemoved,
    required this.proxyRule,
  });

  final String path;
  final int? statusCode;
  final bool isCloudflareChallenge;
  final bool hasBody;
  final int setCookieCount;
  final List<String> cookieNames;
  final Map<String, dynamic> requestHeaders;
  final Map<String, List<String>> responseHeaders;
  final String bodySnippet;
  final bool userAgentRemoved;
  final String proxyRule;

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'statusCode': statusCode,
      'isCloudflareChallenge': isCloudflareChallenge,
      'hasBody': hasBody,
      'setCookieCount': setCookieCount,
      'cookieNames': cookieNames,
      'userAgentRemoved': userAgentRemoved,
      'proxyRule': proxyRule,
      'requestHeaders': requestHeaders,
      'responseHeaders': responseHeaders,
      'bodySnippet': bodySnippet,
    };
  }
}
