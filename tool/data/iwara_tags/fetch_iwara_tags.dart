import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

const String _defaultOutputPath = 'tool/data/iwara_tags/iwara_tags.json';
const int _defaultPageSize = 100;

Future<void> main(List<String> args) async {
  try {
    if (args.contains('--help') || args.contains('-h')) {
      _printUsage();
      return;
    }

    final config = _parseArgs(args);
    final client = _IwaraTagClient(
      pageSize: config.pageSize,
      cookieHeader: config.cookieHeader,
    );

    final snapshot = await client.fetchAllTags();
    await _writeSnapshot(outputPath: config.outputPath, snapshot: snapshot);

    stdout.writeln(
      'Fetched ${snapshot.count} tags across ${snapshot.pages} pages.',
    );
    stdout.writeln('Saved snapshot to ${config.outputPath}');
    client.close();
  } on ArgumentError catch (error) {
    stderr.writeln('Argument error: ${error.message}');
    stderr.writeln('');
    _printUsage();
    exitCode = 64;
  } on _CloudflareChallengeException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } catch (error) {
    stderr.writeln('Failed to fetch Iwara tags: $error');
    exitCode = 1;
  }
}

void _printUsage() {
  stdout.writeln('Fetch all Iwara tags and save them to a local JSON file.');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln(
    '  dart run tool/fetch_iwara_tags.dart [--output <path>] [--page-size <n>]',
  );
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln('  --output <path>     Output JSON path.');
  stdout.writeln('                       Default: $_defaultOutputPath');
  stdout.writeln('  --page-size <n>     Tags fetched per request.');
  stdout.writeln('                       Default: $_defaultPageSize');
  stdout.writeln(
    '  --cookie <header>   Optional Cookie header for Cloudflare/session.',
  );
}

_ScriptConfig _parseArgs(List<String> args) {
  String outputPath = _defaultOutputPath;
  int pageSize = _defaultPageSize;
  String? cookieHeader;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--output':
        if (i + 1 >= args.length) {
          throw ArgumentError('Missing value for --output');
        }
        outputPath = args[++i];
        break;
      case '--page-size':
        if (i + 1 >= args.length) {
          throw ArgumentError('Missing value for --page-size');
        }
        pageSize = int.parse(args[++i]);
        if (pageSize <= 0) {
          throw ArgumentError('--page-size must be greater than 0');
        }
        break;
      case '--cookie':
        if (i + 1 >= args.length) {
          throw ArgumentError('Missing value for --cookie');
        }
        cookieHeader = args[++i].trim();
        if (cookieHeader.isEmpty) {
          throw ArgumentError('--cookie must not be empty');
        }
        break;
      default:
        throw ArgumentError('Unknown argument: $arg');
    }
  }

  return _ScriptConfig(
    outputPath: outputPath,
    pageSize: pageSize,
    cookieHeader: cookieHeader,
  );
}

Future<void> _writeSnapshot({
  required String outputPath,
  required _TagSnapshot snapshot,
}) async {
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(snapshot.toJson()),
  );
}

class _ScriptConfig {
  const _ScriptConfig({
    required this.outputPath,
    required this.pageSize,
    this.cookieHeader,
  });

  final String outputPath;
  final int pageSize;
  final String? cookieHeader;
}

class _IwaraTagClient {
  _IwaraTagClient({required this.pageSize, this.cookieHeader})
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://apiq.iwara.tv',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: const {
            'Accept': 'application/json, text/plain, */*',
            'Content-Type': 'application/json',
            'x-site': 'www.iwara.tv',
            'Referer': 'https://www.iwara.tv/',
            'Origin': 'https://www.iwara.tv',
          },
        ),
      ) {
    _dio.options.validateStatus = (status) => (status ?? 0) < 500;
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.userAgent = null;
        client.findProxy = (_) => 'DIRECT';
        return client;
      },
    );
  }

  final Dio _dio;
  final int pageSize;
  final String? cookieHeader;

  Future<_TagSnapshot> fetchAllTags() async {
    final seenIds = <String>{};
    final tags = <Map<String, dynamic>>[];
    int page = 0;
    int expectedCount = 0;
    int actualPageSize = 0;

    while (true) {
      final response = await _dio.get<dynamic>(
        '/tags',
        queryParameters: {'page': page, 'limit': pageSize},
        options: Options(
          headers: {
            if (cookieHeader != null && cookieHeader!.isNotEmpty)
              'Cookie': cookieHeader,
          },
        ),
      );

      if ((response.statusCode ?? 0) < 200 ||
          (response.statusCode ?? 0) >= 300) {
        _throwIfCloudflareChallenge(response);
        final preview = _preview(response.data);
        throw HttpException(
          'Failed to fetch /tags page=$page limit=$pageSize '
          '(status=${response.statusCode}, body=$preview)',
        );
      }

      final data = _normalizePayload(response.data);
      if (data == null) {
        throw const FormatException('Empty response body when fetching tags');
      }

      final results = data['results'];
      final count = data['count'];
      final responseLimit = data['limit'];
      if (results is! List || count is! int) {
        throw FormatException(
          'Unexpected /tags payload shape: ${jsonEncode(data)}',
        );
      }

      expectedCount = count;
      actualPageSize = responseLimit is int
          ? responseLimit
          : (results.isNotEmpty ? results.length : actualPageSize);

      for (final item in results) {
        if (item is! Map) continue;
        final normalized = Map<String, dynamic>.from(item);
        final id = normalized['id']?.toString();
        if (id == null || id.isEmpty) continue;
        if (seenIds.add(id)) {
          tags.add(normalized);
        }
      }

      final fetchedCount =
          (page + 1) * (actualPageSize > 0 ? actualPageSize : pageSize);
      final reachedEnd =
          results.isEmpty ||
          tags.length >= expectedCount ||
          fetchedCount >= expectedCount;
      if (reachedEnd) {
        break;
      }

      page++;
    }

    tags.sort((a, b) {
      final left = a['id']?.toString() ?? '';
      final right = b['id']?.toString() ?? '';
      return left.compareTo(right);
    });

    return _TagSnapshot(
      source: 'https://apiq.iwara.tv/tags',
      fetchedAt: DateTime.now().toUtc(),
      requestedPageSize: pageSize,
      pageSize: actualPageSize > 0 ? actualPageSize : pageSize,
      count: tags.length,
      expectedCount: expectedCount,
      pages: page + 1,
      tags: tags,
    );
  }

  void _throwIfCloudflareChallenge(Response<dynamic> response) {
    final mitigated = response.headers.value('cf-mitigated')?.toLowerCase();
    final body = response.data?.toString() ?? '';
    final normalizedBody = body.toLowerCase();
    final isChallenge =
        mitigated == 'challenge' ||
        normalizedBody.contains('just a moment') ||
        normalizedBody.contains('enable javascript and cookies to continue') ||
        normalizedBody.contains('/cdn-cgi/challenge-platform/');

    if (!isChallenge) {
      return;
    }

    throw _CloudflareChallengeException(
      'Cloudflare blocked the CLI request before the tag API returned JSON.\n'
      'Open https://apiq.iwara.tv/tags in a browser, complete the challenge, '
      'then rerun this script with a Cookie header, for example:\n'
      'dart run tool/fetch_iwara_tags.dart '
      '--cookie "cf_clearance=...; other_cookie=..."',
    );
  }

  Map<String, dynamic>? _normalizePayload(dynamic rawData) {
    if (rawData == null) {
      return null;
    }
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }
    if (rawData is String) {
      final trimmed = rawData.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    return null;
  }

  String _preview(Object? data) {
    final raw = data == null ? 'null' : jsonEncode(data);
    if (raw.length <= 200) {
      return raw;
    }
    return '${raw.substring(0, 200)}...';
  }

  void close() {
    _dio.close(force: true);
  }
}

class _CloudflareChallengeException implements Exception {
  const _CloudflareChallengeException(this.message);

  final String message;
}

class _TagSnapshot {
  const _TagSnapshot({
    required this.source,
    required this.fetchedAt,
    required this.requestedPageSize,
    required this.pageSize,
    required this.count,
    required this.expectedCount,
    required this.pages,
    required this.tags,
  });

  final String source;
  final DateTime fetchedAt;
  final int requestedPageSize;
  final int pageSize;
  final int count;
  final int expectedCount;
  final int pages;
  final List<Map<String, dynamic>> tags;

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'source': source,
      'fetchedAt': fetchedAt.toIso8601String(),
      'requestedPageSize': requestedPageSize,
      'pageSize': pageSize,
      'count': count,
      'expectedCount': expectedCount,
      'pages': pages,
      'tags': tags,
    };
  }
}
