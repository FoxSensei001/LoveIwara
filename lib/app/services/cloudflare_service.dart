import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/cloudflare_challenge.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'storage_service.dart';

class CloudflareCookieBundle {
  final String cfClearance;
  final String? cfBm;
  final String? cfuvid;
  final int? expiresDate;

  const CloudflareCookieBundle({
    required this.cfClearance,
    this.cfBm,
    this.cfuvid,
    this.expiresDate,
  });

  Map<String, String> toCookieMap() {
    return {
      'cf_clearance': cfClearance,
      if (cfBm != null && cfBm!.isNotEmpty) '__cf_bm': cfBm!,
      if (cfuvid != null && cfuvid!.isNotEmpty) '_cfuvid': cfuvid!,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'cf_clearance': cfClearance,
      if (cfBm != null) '__cf_bm': cfBm,
      if (cfuvid != null) '_cfuvid': cfuvid,
      if (expiresDate != null) 'expiresDate': expiresDate,
    };
  }

  static CloudflareCookieBundle? fromJson(Object? value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final clearance = map['cf_clearance']?.toString();
    if (clearance == null || clearance.isEmpty) return null;
    return CloudflareCookieBundle(
      cfClearance: clearance,
      cfBm: map['__cf_bm']?.toString(),
      cfuvid: map['_cfuvid']?.toString(),
      expiresDate: map['expiresDate'] is int
          ? map['expiresDate'] as int
          : int.tryParse(map['expiresDate']?.toString() ?? ''),
    );
  }
}

class CloudflareCookieStore {
  final CloudflareCookieBundle? zone;
  final Map<String, CloudflareCookieBundle> hosts;
  final int updatedAtMs;

  const CloudflareCookieStore({
    required this.zone,
    required this.hosts,
    required this.updatedAtMs,
  });

  factory CloudflareCookieStore.empty() {
    return const CloudflareCookieStore(zone: null, hosts: {}, updatedAtMs: 0);
  }

  bool hasAnyCookie() => zone != null || hosts.isNotEmpty;

  bool isHostCovered(String host) {
    return zone != null || hosts.containsKey(host);
  }

  Map<String, dynamic> toJson() {
    return {
      'updatedAtMs': updatedAtMs,
      if (zone != null) 'zone': zone!.toJson(),
      'hosts': hosts.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  static CloudflareCookieStore fromJson(Object? value) {
    if (value is! Map) return CloudflareCookieStore.empty();
    final map = Map<String, dynamic>.from(value);
    final hostsRaw = map['hosts'];
    final hosts = <String, CloudflareCookieBundle>{};
    if (hostsRaw is Map) {
      for (final entry in hostsRaw.entries) {
        final host = entry.key.toString();
        final bundle = CloudflareCookieBundle.fromJson(entry.value);
        if (bundle != null) {
          hosts[host] = bundle;
        }
      }
    }
    return CloudflareCookieStore(
      zone: CloudflareCookieBundle.fromJson(map['zone']),
      hosts: hosts,
      updatedAtMs: map['updatedAtMs'] is int
          ? map['updatedAtMs'] as int
          : int.tryParse(map['updatedAtMs']?.toString() ?? '') ?? 0,
    );
  }
}

class CloudflareService extends GetxService {
  static const String _tag = 'CloudflareService';
  static const Duration _cooldownDuration = Duration(seconds: 15);

  final StorageService _storage = StorageService();
  final CookieManager _cookieManager = CookieManager.instance();

  CloudflareCookieStore _cookieStore = CloudflareCookieStore.empty();
  String? _userAgent;

  Completer<bool>? _verifyingCompleter;
  DateTime? _cooldownUntil;

  String? get userAgent => _userAgent;
  bool get isVerifying => _verifyingCompleter != null;

  Future<CloudflareService> init() async {
    await _loadPersistedState();
    return this;
  }

  bool isCloudflareChallenge(DioException error) {
    if (error.response?.statusCode != 403) return false;
    final mitigated = error.response?.headers['cf-mitigated']?.firstOrNull;
    return mitigated == 'challenge';
  }

  void applyHeadersForRequest({
    required Map<String, dynamic> headers,
    required Uri uri,
  }) {
    if (_userAgent != null && _userAgent!.isNotEmpty) {
      headers['User-Agent'] = _userAgent!;
    }

    final cookieHeader = buildCookieHeaderForHost(
      uri.host,
      existing: headers['Cookie'],
    );
    if (cookieHeader != null) {
      headers['Cookie'] = cookieHeader;
    }

    headers.putIfAbsent('x-site', () => CommonConstants.iwaraSiteHost);
    headers.putIfAbsent('Referer', () => CommonConstants.iwaraBaseUrl);
    headers.putIfAbsent('Origin', () => CommonConstants.iwaraBaseUrl);
  }

  String? buildCookieHeaderForHost(String host, {Object? existing}) {
    final cookieMap = <String, String>{};
    if (_cookieStore.zone != null) {
      cookieMap.addAll(_cookieStore.zone!.toCookieMap());
    }
    final hostBundle = _cookieStore.hosts[host];
    if (hostBundle != null) {
      cookieMap.addAll(hostBundle.toCookieMap());
    }
    if (cookieMap.isEmpty) return null;

    return _mergeCookieHeader(existing?.toString(), cookieMap);
  }

  Future<bool> ensureVerified({
    required Uri triggerUri,
    String? reason,
    bool force = true,
  }) async {
    final triggerHost = triggerUri.host;

    if (!force && _cookieStore.isHostCovered(triggerHost)) {
      return true;
    }

    if (_isInCooldown()) {
      LogUtils.w('$_tag 验证处于冷却期，跳过自动拉起', _tag);
      return false;
    }

    while (true) {
      final inFlight = _verifyingCompleter;
      if (inFlight != null) {
        final ok = await inFlight.future;
        if (ok && _cookieStore.isHostCovered(triggerHost)) return true;
        if (_isInCooldown()) return false;
        if (!ok) return false;
        continue;
      }

      final completer = Completer<bool>();
      _verifyingCompleter = completer;

      bool ok = false;
      try {
        ok = await _openChallengePage(triggerUri: triggerUri, reason: reason);
        if (ok) {
          await _probeAndPersistCookies(triggerHost: triggerHost);
        }
      } catch (e, s) {
        LogUtils.e('$_tag 拉起/处理验证失败', tag: _tag, error: e, stackTrace: s);
        ok = false;
      } finally {
        if (!completer.isCompleted) {
          completer.complete(ok);
        }
        _verifyingCompleter = null;
      }

      if (!ok) {
        _cooldownUntil = DateTime.now().add(_cooldownDuration);
        return false;
      }

      return _cookieStore.isHostCovered(triggerHost);
    }
  }

  Future<void> clearStoredState({bool clearWebViewCookies = false}) async {
    _cookieStore = CloudflareCookieStore.empty();
    _userAgent = null;
    _cooldownUntil = null;

    await _storage.deleteSecureData(KeyConstants.cloudflareCookieStore);
    await _storage.deleteSecureData(KeyConstants.userAgent);

    if (clearWebViewCookies) {
      try {
        await _cookieManager.deleteAllCookies();
      } catch (e) {
        LogUtils.w('$_tag 清理 WebView cookies 失败: $e', _tag);
      }
    }
  }

  Future<void> _loadPersistedState() async {
    try {
      _userAgent = await _storage.readSecureData(KeyConstants.userAgent);

      final raw = await _storage.readSecureData(
        KeyConstants.cloudflareCookieStore,
      );
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        _cookieStore = CloudflareCookieStore.fromJson(decoded);
      }

      LogUtils.d(
        '$_tag 初始化完成 - hasUserAgent: ${_userAgent != null}, '
        'hasCookies: ${_cookieStore.hasAnyCookie()}, '
        'hosts: ${_cookieStore.hosts.keys.length}, '
        'hasZone: ${_cookieStore.zone != null}',
        _tag,
      );
    } catch (e, s) {
      LogUtils.e('$_tag 加载持久化状态失败', tag: _tag, error: e, stackTrace: s);
      _cookieStore = CloudflareCookieStore.empty();
    }
  }

  Future<bool> _openChallengePage({
    required Uri triggerUri,
    String? reason,
  }) async {
    final scheme = (triggerUri.scheme == 'http' || triggerUri.scheme == 'https')
        ? triggerUri.scheme
        : 'https';
    final host = triggerUri.host;
    final initialUri = Uri(scheme: scheme, host: host, path: '/');

    final result = await appRouter.push<CloudflareChallengeResult>(
      '/cloudflare_challenge',
      extra: CloudflareChallengeRequest(
        initialUri: initialUri,
        triggerHost: host,
        reason: reason,
      ),
    );

    if (result?.userAgent != null && result!.userAgent!.isNotEmpty) {
      await _persistUserAgent(result.userAgent!);
    }

    return result?.verified == true;
  }

  Future<void> _persistUserAgent(String ua) async {
    if (_userAgent == ua) return;
    _userAgent = ua;
    try {
      await _storage.writeSecureData(KeyConstants.userAgent, ua);
      LogUtils.d('$_tag User-Agent 已更新', _tag);
    } catch (e) {
      LogUtils.w('$_tag 保存 User-Agent 失败: $e', _tag);
    }
  }

  Future<void> _probeAndPersistCookies({required String triggerHost}) async {
    final candidateHosts = _buildCandidateHosts(triggerHost);
    final byHost = <String, CloudflareCookieBundle>{};

    for (final host in candidateHosts) {
      try {
        final cookies = await _cookieManager.getCookies(
          url: WebUri('https://$host/'),
        );
        final bundle = _extractBundle(cookies);
        if (bundle != null) {
          byHost[host] = bundle;
        }
      } catch (e) {
        // 忽略单个 host 探测失败，避免阻断整体流程
        LogUtils.w('$_tag 探测 cookies 失败: $host - $e', _tag);
      }
    }

    if (byHost.isEmpty) {
      LogUtils.w('$_tag 未探测到 cf_clearance，可能验证未完成', _tag);
      return;
    }

    // Zone 推断：同一个 cf_clearance 值在多个 host 下可见，认为是 zone 级。
    CloudflareCookieBundle? zone;
    final counts = <String, int>{};
    for (final b in byHost.values) {
      counts[b.cfClearance] = (counts[b.cfClearance] ?? 0) + 1;
    }
    MapEntry<String, int>? zoneEntry;
    for (final entry in counts.entries) {
      if (entry.value >= 2) {
        zoneEntry = entry;
        break;
      }
    }
    if (zoneEntry != null) {
      for (final b in byHost.values) {
        if (b.cfClearance == zoneEntry.key) {
          zone = b;
          break;
        }
      }
    }

    _cookieStore = CloudflareCookieStore(
      zone: zone,
      hosts: byHost,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await _storage.writeSecureData(
        KeyConstants.cloudflareCookieStore,
        jsonEncode(_cookieStore.toJson()),
      );
      LogUtils.i(
        '$_tag Cookies 已更新 - '
        'hosts=${byHost.length}, '
        'zone=${zone != null ? "yes" : "no"}',
        _tag,
      );
    } catch (e, s) {
      LogUtils.e('$_tag 保存 cookies 失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  CloudflareCookieBundle? _extractBundle(List<Cookie> cookies) {
    String? clearance;
    String? cfBm;
    String? cfuvid;
    int? expiresDate;

    for (final c in cookies) {
      final name = c.name;
      if (name == 'cf_clearance') {
        clearance = c.value;
        expiresDate = c.expiresDate;
      } else if (name == '__cf_bm') {
        cfBm = c.value;
      } else if (name == '_cfuvid') {
        cfuvid = c.value;
      }
    }

    if (clearance == null || clearance.isEmpty) return null;
    return CloudflareCookieBundle(
      cfClearance: clearance,
      cfBm: cfBm,
      cfuvid: cfuvid,
      expiresDate: expiresDate,
    );
  }

  List<String> _buildCandidateHosts(String triggerHost) {
    final hosts = <String>{
      triggerHost,
      Uri.parse(CommonConstants.iwaraBaseUrl).host,
      Uri.parse(CommonConstants.iwaraApiBaseUrl).host,
      Uri.parse(CommonConstants.iwaraImageBaseUrl).host,
    };
    hosts.removeWhere((h) => h.isEmpty);
    return hosts.toList();
  }

  bool _isInCooldown() {
    final until = _cooldownUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  static String _mergeCookieHeader(
    String? existing,
    Map<String, String> toAdd,
  ) {
    final map = <String, String>{};
    if (existing != null && existing.trim().isNotEmpty) {
      for (final part in existing.split(';')) {
        final trimmed = part.trim();
        if (trimmed.isEmpty) continue;
        final idx = trimmed.indexOf('=');
        if (idx <= 0) continue;
        final k = trimmed.substring(0, idx).trim();
        final v = trimmed.substring(idx + 1).trim();
        if (k.isNotEmpty) map[k] = v;
      }
    }
    map.addAll(toAdd);
    return map.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }
}
