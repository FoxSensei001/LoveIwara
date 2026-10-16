import 'dart:io';

import 'package:dio/dio.dart' as d_dio;
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/x_version_calculator_utils.dart';

import 'config_service.dart';
import 'http_client_factory.dart';
import 'iwara_network_service.dart';

/// 视频源签名（X-Version）盐值的自动更新。
///
/// 盐值写死在官网前端的 `main.<hash>.js` 里，官方换过盐（2026-02 那次，
/// 所有人都要等发新版才能正常看视频）。
///
/// ⛔ 盐值不对时文件服务器**不报错**：照样返回 200，只是清单里只剩
/// 360 / preview 两档（没有签名时也一样）。用户看到的是「清晰度只剩 360」，
/// 代码里没有异常可抓。
///
/// 所以这里把「签过名的清单里没有 Source」当成盐值失效的信号：拉官网首页
/// 找到 main.js，从中提取盐值，变了就用它重签重发一次；重发拿到 Source，
/// 才换上并保存。
///
/// ⛔ 只从主站（www.iwara.tv）取盐值。2026-10 主站和 AI 站用的是同一个盐值；
/// 两站以后分开换盐的话，AI 站的视频这里修不了，只能等发版。
class XVersionSaltService {
  XVersionSaltService._({
    XVersionSaltStore? store,
    Future<String> Function(Uri uri)? fetch,
    DateTime Function()? now,
  }) : _store = store ?? const _ConfigSaltStore(),
       _fetchOverride = fetch,
       _now = now ?? DateTime.now;

  static final XVersionSaltService instance = XVersionSaltService._();

  /// 测试用：换掉持久化、网络和时钟，好覆盖真正的官网刷新流程。
  @visibleForTesting
  factory XVersionSaltService.forTest({
    required XVersionSaltStore store,
    required Future<String> Function(Uri uri) fetch,
    DateTime Function()? now,
  }) => XVersionSaltService._(store: store, fetch: fetch, now: now);

  static const String _tag = 'XVersionSaltService';

  /// 两次检查官网之间的最短间隔，避免连着打开几个缺 Source 的视频时反复请求
  static const Duration _minCheckInterval = Duration(minutes: 10);

  /// 单次连接 / 接收的超时。首页、main.js（以及可能的无头过盾）是串行的，
  /// 整次恢复的总时长由调用方的 `checkSiteTimeout` 限制。
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// 播放器打开视频时最多等官网这么久。超时先放 360，检查在后台做完，
  /// 下一次请求（重开视频、链接过期刷新）直接用它的结果。
  static const Duration playbackCheckSiteTimeout = Duration(seconds: 8);

  static final RegExp _mainScriptPattern = RegExp(
    r'''src=["'](/main\.[0-9a-f]+\.js)["']''',
  );

  /// 前端计算签名的那一句形如 `"_"+e.expires+"_<salt>"`
  static final RegExp _saltPattern = RegExp(
    r'"_"\+[\w$.]+expires\+"_([A-Za-z0-9]{16,})"',
  );

  final XVersionSaltStore _store;
  final Future<String> Function(Uri uri)? _fetchOverride;
  final DateTime Function() _now;

  bool _loaded = false;

  /// 当前盐值是从哪个 main.js 提取的；null 表示还没提取过（在用内置值）。
  String? _savedScript;

  /// 从官网提取到、但还没换来过 Source 的盐值。
  ///
  /// ⛔ 证实之前不换全局盐值、不存盘。提取规则一旦失配抓到错值，直接存下去
  /// 会盖掉能用的内置值；之后 main.js 路径不变就不会再查，所有视频都只剩
  /// 360，直到前端发新版、而重新提取又抓到同一个错值。
  _SaltCandidate? _candidate;
  DateTime? _lastCheckAt;
  Future<String?>? _checking;
  d_dio.Dio? _dio;

  /// 带 X-Version 请求视频源清单。
  ///
  /// [send] 用给定的请求头发出请求。结果像是签名失效时，从官网取盐值重签
  /// 重发一次；取不到或盐值没变就原样返回第一次的结果，行为与以前一致。
  ///
  /// [checkSiteTimeout] 限制等官网的总时长（首页、main.js、无头过盾加起来），
  /// 到点就先返回第一次的结果，检查在后台继续，下一次请求直接用它的结果。
  /// 不传就一直等（下载刷新链接在后台，不赶时间）。
  ///
  /// 重签后的请求失败时：
  /// - [keepFirstOnRetryFailure] 为 true（播放器）：取消以外的失败沿用第一次
  ///   拿到的低清晰度，视频至少能看；
  /// - 默认把异常原样交给调用方。下载刷新链接要靠它区分「网断了」和
  ///   「这档清晰度没了」，吞掉异常会让 Source 任务被误判成永久失败。
  Future<d_dio.Response<dynamic>> requestVideoSources(
    String fileUrl,
    Future<d_dio.Response<dynamic>> Function(Map<String, dynamic> headers)
    send, {
    bool keepFirstOnRetryFailure = false,
    Duration? checkSiteTimeout,
  }) async {
    _ensureLoaded();
    final usedSalt = XVersionCalculatorUtil.salt;
    final response = await send(_headersFor(fileUrl, usedSalt));
    if (!looksUnsigned(response.data)) return response;

    // 并发的另一个请求可能已经把盐值换掉了，那就直接用新盐值重发；
    // 否则去官网看有没有新盐值
    final current = XVersionCalculatorUtil.salt;
    final retrySalt = current != usedSalt
        ? current
        : await _checkSiteWithin(checkSiteTimeout);
    if (retrySalt == null || retrySalt == usedSalt) return response;

    LogUtils.i('用新的签名盐值重新请求视频源', _tag);
    final d_dio.Response<dynamic> retried;
    try {
      retried = await send(_headersFor(fileUrl, retrySalt));
    } on Exception catch (e) {
      if (!keepFirstOnRetryFailure) rethrow;
      if (e is d_dio.DioException && d_dio.CancelToken.isCancel(e)) rethrow;
      LogUtils.w('重签后请求视频源失败，沿用第一次的结果: $e', _tag);
      return response;
    }
    if (hasSource(retried.data)) await _adopt(retrySalt);
    return retried;
  }

  Map<String, dynamic> _headersFor(String fileUrl, String salt) => {
    'X-Version': XVersionCalculatorUtil.calculateXVersion(
      fileUrl,
      withSalt: salt,
    ),
  };

  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    final record = _store.read();
    if (record == null) return;
    // ⛔ 新版换了内置盐值，说明维护者已经跟进过官网：旧记录（连同它的
    // main.js 路径）作废，从新内置值开始。否则旧缓存会盖掉修复，官网一时
    // 不可达时装了新版也只能看 360。
    if (record.builtinSalt != XVersionCalculatorUtil.defaultSalt) {
      LogUtils.i('内置签名盐值已变，忽略之前自动提取的盐值', _tag);
      return;
    }
    XVersionCalculatorUtil.salt = record.salt;
    _savedScript = record.script;
  }

  /// 候选盐值换来了 Source：换上并保存。并发重发时只有第一个会走到保存。
  Future<void> _adopt(String salt) async {
    final candidate = _candidate;
    if (candidate == null || candidate.salt != salt) return;
    _candidate = null;
    XVersionCalculatorUtil.salt = salt;
    _savedScript = candidate.script;
    LogUtils.i('签名盐值已从官网更新（${candidate.script}）', _tag);
    await _save(salt, candidate.script);
  }

  Future<void> _save(String salt, String script) async {
    try {
      await _store.write(
        XVersionSaltRecord(
          salt: salt,
          script: script,
          builtinSalt: XVersionCalculatorUtil.defaultSalt,
        ),
      );
    } catch (e) {
      // 存不下也不影响这次播放，下次启动重新从官网取
      LogUtils.e('保存签名盐值失败', tag: _tag, error: e);
    }
  }

  Future<String?> _checkSiteWithin(Duration? timeout) {
    final checking = _checking ??= _checkSite().whenComplete(
      () => _checking = null,
    );
    if (timeout == null) return checking;
    return checking.timeout(
      timeout,
      // ⛔ 手里有候选就先拿它试，不能干等官网：官网一直慢、两次打开又隔开
      // 超过节流期时，每次都卡在拉首页上超时，候选永远没机会证实
      onTimeout: () {
        final candidate = _candidate?.salt;
        LogUtils.w(
          '等官网超过 ${timeout.inSeconds} 秒，'
          '${candidate == null ? '先用第一次的结果' : '先用上次的候选盐值试'}',
          _tag,
        );
        return candidate;
      },
    );
  }

  /// 从官网前端提取盐值。返回值得一试的候选盐值；官网用的就是当前盐值、
  /// 取不到或提取不到时返回 null。并发调用共用同一次检查。
  Future<String?> _checkSite() async {
    final now = _now();
    final last = _lastCheckAt;
    if (last != null && now.difference(last) < _minCheckInterval) {
      // 上一次提取的候选还没机会证实（比如触发它的视频本来就没有 Source），
      // 节流期间继续拿它试
      return _candidate?.salt;
    }
    _lastCheckAt = now;

    try {
      final site = Uri.parse(CommonConstants.iwaraBaseUrl);
      final script = extractMainScriptPath(await _fetch(site));
      if (script == null) {
        LogUtils.w('官网首页里没找到 main.js，跳过盐值更新', _tag);
        return _candidate?.salt;
      }

      // 前端没换版本：当前盐值就是从这个 main.js 来的（或证实过），不必再下载
      if (script == _savedScript) {
        _candidate = null;
        return null;
      }
      final candidate = _candidate;
      if (candidate != null && candidate.script == script) {
        return candidate.salt;
      }

      final salt = extractSalt(await _fetch(site.resolve(script)));
      if (salt == null) {
        LogUtils.w('main.js 里没找到签名盐值: $script', _tag);
        _candidate = null;
        return null;
      }

      if (salt == XVersionCalculatorUtil.salt) {
        // 官网用的就是当前盐值，缺 Source 另有原因。记下 main.js 路径，
        // 前端没换版本就不必再下载
        _candidate = null;
        _savedScript = script;
        await _save(salt, script);
        return null;
      }

      LogUtils.i('从官网提取到新的签名盐值（$script），重发验证', _tag);
      _candidate = _SaltCandidate(salt: salt, script: script);
      return salt;
    } catch (e) {
      LogUtils.e('从官网更新签名盐值失败', tag: _tag, error: e);
      return _candidate?.salt;
    }
  }

  Future<String> _fetch(Uri uri) => (_fetchOverride ?? _getString)(uri);

  /// 与 ApiService 同一套网络栈：共享 HttpClient（代理）、CookieJar、过盾。
  ///
  /// ⛔ 故意不设浏览器 UA，跟 ApiService 一样用 Dart 默认 UA。实测（2026-10）
  /// 从 dart:io 请求官网首页：默认 UA 直接 200；报 WebView / Chrome 的 UA 反而
  /// 403 + `cf-mitigated: challenge`（浏览器 UA 配非浏览器 TLS 指纹被判可疑），
  /// 打开视频要多等两轮无头过盾。main.js 是静态资源，哪种 UA 都不挑战。
  d_dio.Dio get _siteDio => _dio ??= _createSiteDio();

  d_dio.Dio _createSiteDio() {
    final dio = d_dio.Dio(
      d_dio.BaseOptions(
        connectTimeout: _requestTimeout,
        receiveTimeout: _requestTimeout,
        responseType: d_dio.ResponseType.plain,
      ),
    );
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClientFactory.instance.createHttpClient,
    );
    if (Get.isRegistered<IwaraNetworkService>()) {
      // 这是打开视频时顺带做的事：只走无头过盾，过不去就算了，绝不弹验证页。
      // 页面和脚本都要原文，不能按 API 那样从 HTML 里抠 JSON。
      Get.find<IwaraNetworkService>().registerDio(
        dio,
        decodeJsonAfterChallenge: false,
        interactiveChallenge: false,
      );
    }
    return dio;
  }

  Future<String> _getString(Uri uri) async {
    final response = await _siteDio.getUri<String>(uri);
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw HttpException('Request failed: $status', uri: uri);
    }
    return response.data ?? '';
  }

  /// 签过名的清单一定带 Source（原档）；盐值不对时服务器只给 360 / preview。
  /// 空清单（转码中等情况）不算。
  static bool looksUnsigned(Object? data) =>
      data is List && data.isNotEmpty && !hasSource(data);

  static bool hasSource(Object? data) =>
      data is List &&
      data.any((item) => item is Map && item['name'] == 'Source');

  static bool isValidSalt(String salt) =>
      RegExp(r'^[A-Za-z0-9]{16,}$').hasMatch(salt);

  /// 从官网首页 HTML 里找出 `/main.<hash>.js`
  static String? extractMainScriptPath(String html) =>
      _mainScriptPattern.firstMatch(html)?.group(1);

  /// 从 main.js 里提取签名盐值
  static String? extractSalt(String js) =>
      _saltPattern.firstMatch(js)?.group(1);
}

/// 从 [script] 里提取到、还没换来过 Source 的盐值。
class _SaltCandidate {
  const _SaltCandidate({required this.salt, required this.script});

  final String salt;
  final String script;
}

/// 一次自动提取的结果。
@immutable
class XVersionSaltRecord {
  const XVersionSaltRecord({
    required this.salt,
    required this.script,
    required this.builtinSalt,
  });

  final String salt;

  /// 提取时官网用的 main.js 路径，没变就不必重新下载
  final String script;

  /// 保存时 App 的内置盐值。新版换了内置值，这条记录就作废。
  final String builtinSalt;

  Map<String, dynamic> toJson() => {
    'salt': salt,
    'script': script,
    'builtin': builtinSalt,
  };

  /// 解析不了或字段不合法时返回 null（当作没有记录）。
  static XVersionSaltRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final salt = json['salt'];
    final script = json['script'];
    final builtin = json['builtin'];
    if (salt is! String || !XVersionSaltService.isValidSalt(salt)) return null;
    if (script is! String || script.isEmpty) return null;
    if (builtin is! String || builtin.isEmpty) return null;
    return XVersionSaltRecord(salt: salt, script: script, builtinSalt: builtin);
  }
}

/// 盐值记录的读写。
abstract class XVersionSaltStore {
  XVersionSaltRecord? read();
  Future<void> write(XVersionSaltRecord record);
}

/// 存在 ConfigService 里（随配置一起备份 / 恢复；恢复出旧记录也无妨，
/// 内置值对不上会作废，对得上而盐值过期会在下次缺 Source 时刷新）。
class _ConfigSaltStore implements XVersionSaltStore {
  const _ConfigSaltStore();

  ConfigService? get _config =>
      Get.isRegistered<ConfigService>() ? Get.find<ConfigService>() : null;

  @override
  XVersionSaltRecord? read() =>
      XVersionSaltRecord.fromJson(_config?[ConfigKey.X_VERSION_SALT_CACHE]);

  @override
  Future<void> write(XVersionSaltRecord record) async {
    await _config?.setSetting(ConfigKey.X_VERSION_SALT_CACHE, record.toJson());
  }
}
