// token_manager.dart
// 专业的 Token 管理器，处理 token 刷新的并发控制和生命周期管理

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import 'http_client_factory.dart';
import 'iwara_network_service.dart';
import 'iwara_site_headers.dart';
import 'storage_service.dart';

/// Token 验证结果枚举
enum TokenValidationResult {
  valid, // 有效
  expired, // 过期
  invalid, // 无效
  wrongType, // 类型错误
  malformed, // 格式错误
}

/// Token 刷新结果
class TokenRefreshResult {
  final bool success;
  final String? accessToken;
  final String? errorMessage;
  final bool isAuthError; // 是否是认证错误（需要重新登录）

  TokenRefreshResult({
    required this.success,
    this.accessToken,
    this.errorMessage,
    this.isAuthError = false,
  });

  factory TokenRefreshResult.success(String accessToken) {
    return TokenRefreshResult(success: true, accessToken: accessToken);
  }

  factory TokenRefreshResult.authError(String message) {
    return TokenRefreshResult(
      success: false,
      errorMessage: message,
      isAuthError: true,
    );
  }

  factory TokenRefreshResult.networkError(String message) {
    return TokenRefreshResult(
      success: false,
      errorMessage: message,
      isAuthError: false,
    );
  }

  /// 刷新被新会话(登录/切号/登出)取代而作废。
  /// 不是认证失败 —— 调用方不得据此登出或清理 token(HIGH#1)。
  factory TokenRefreshResult.superseded() {
    return TokenRefreshResult(
      success: false,
      errorMessage: 'Refresh superseded by session change',
      isAuthError: false,
    );
  }
}

/// Token 管理器
/// 负责 token 的存储、验证、刷新和并发控制
class TokenManager {
  static const String _tag = 'TokenManager';

  final StorageService _storage = StorageService();

  // 独立的 Dio 实例，用于 token 刷新请求
  // 不使用主 ApiService 的 Dio，避免循环依赖和拦截器干扰
  late final dio.Dio _tokenDio;

  // Token 存储
  String? _authToken; // refresh_token，有效期约30天
  String? _accessToken; // access_token，有效期约1小时

  // Token 过期时间
  DateTime? _authTokenExpireTime;
  DateTime? _accessTokenExpireTime;

  // 刷新状态管理 - 核心并发控制
  Completer<TokenRefreshResult>? _refreshCompleter;
  bool _isRefreshing = false;

  // 当前在途刷新所属的代次。并发复用与共享状态复位都按此判定，
  // 避免被取代的旧刷新清掉新刷新的状态、或新登录 latch 到注定作废的旧刷新(HIGH#1)。
  int _refreshingGeneration = -1;

  // 刷新代次：每次登录(saveAuthToken)或登出(clearTokens)递增。
  // refreshAccessToken 在发起请求时捕获代次，回包写回前再校验；
  // 若期间发生过登出/新登录(代次已变)，则丢弃这次陈旧回包，
  // 避免旧账号的 access token 覆盖新会话(见 Finding #1)。
  int _tokenGeneration = 0;

  // 认证失效回调：后台刷新发现 refresh token 失效时通知上层(AuthService)，
  // 让其执行登出/清理，而不是只停掉定时器(见 Finding #2)。
  void Function(String reason)? onAuthInvalidated;

  // 刷新成功回调：后台定时器刷新成功时通知上层(AuthService)，
  // 使会话状态从 refreshing/degradedOffline 收敛到 authenticated(A3/A4)。
  void Function()? onRefreshSucceeded;

  // 后台刷新定时器
  Timer? _backgroundRefreshTimer;

  // 配置常量
  static const int _refreshThresholdSeconds = 5 * 60; // 提前5分钟刷新
  static const Duration _tokenRequestTimeout = Duration(seconds: 15);
  static const Duration _backgroundRefreshInterval = Duration(minutes: 13);

  // Getters
  String? get authToken => _authToken;
  String? get accessToken => _accessToken;
  bool get hasToken => _authToken != null && _accessToken != null;

  /// 是否持有 refresh token（不要求 access token 也在）。
  /// 启动恢复应以此为准：只要 refresh token 有效就能重建 access token(#4)。
  bool get hasRefreshToken => _authToken != null;

  /// 是否持有可用的 access token。
  bool get hasUsableAccessToken => _accessToken != null;

  bool get isRefreshing => _isRefreshing;

  /// 当前 token 归属的账号标识(JWT subject)。
  /// 用于将本地缓存(如用户资料)绑定到具体账号，避免跨账号串用(见 Finding #5)。
  /// 无法解析时返回 null，调用方应将"无法确认"按宽松处理。
  String? get authTokenSubject =>
      _extractSubject(_authToken) ?? _extractSubject(_accessToken);

  /// 从 JWT 中提取账号标识，容忍多种字段命名。
  String? _extractSubject(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map) return null;
      final id = payload['id'] ??
          payload['sub'] ??
          payload['userId'] ??
          payload['user'];
      return id?.toString();
    } catch (_) {
      return null;
    }
  }

  /// 检查 auth token（refresh_token）是否过期
  bool get isAuthTokenExpired {
    if (_authToken == null || _authTokenExpireTime == null) return true;
    return DateTime.now().isAfter(_authTokenExpireTime!);
  }

  /// 检查 access token 是否过期（提前阈值时间就视为过期）
  bool get isAccessTokenExpired {
    if (_accessToken == null || _accessTokenExpireTime == null) return true;
    return DateTime.now()
        .add(const Duration(seconds: _refreshThresholdSeconds))
        .isAfter(_accessTokenExpireTime!);
  }

  /// 检查 access token 是否真正过期（不考虑提前刷新阈值）
  bool get isAccessTokenActuallyExpired {
    if (_accessToken == null || _accessTokenExpireTime == null) return true;
    return DateTime.now().isAfter(_accessTokenExpireTime!);
  }

  /// 获取 access token 剩余有效时间（秒）
  int get accessTokenRemainingSeconds {
    if (_accessTokenExpireTime == null) return 0;
    final remaining = _accessTokenExpireTime!.difference(DateTime.now());
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  TokenManager({dio.Dio? tokenDio}) {
    if (tokenDio != null) {
      // 测试注入：允许传入带 mock adapter 的 Dio，避免真实网络。
      _tokenDio = tokenDio;
    } else {
      _initTokenDio();
    }
  }

  void attachNetworkService(IwaraNetworkService networkService) {
    networkService.registerDio(_tokenDio);
  }

  void _initTokenDio() {
    _tokenDio = dio.Dio(
      dio.BaseOptions(
        baseUrl: CommonConstants.iwaraApiBaseUrl,
        connectTimeout: _tokenRequestTimeout,
        receiveTimeout: _tokenRequestTimeout,
        sendTimeout: _tokenRequestTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 配置 HTTP 客户端适配器（使用共享 HttpClient 实现连接复用）
    _tokenDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClientFactory.instance.createHttpClient,
    );

    // site header 通过拦截器动态注入，避免构造时 baked-in
    _tokenDio.interceptors.add(buildIwaraSiteHeaderInterceptor());
  }

  /// 初始化 - 从存储中加载 token
  Future<void> init() async {
    try {
      _authToken = await _storage.readSecureData(KeyConstants.authToken);
      _accessToken = await _storage.readSecureData(KeyConstants.accessToken);

      // 会话作废墓碑校验(HIGH#3)：若持久化 token 属于已登出会话
      // （登出时删除曾失败而残留），代次不符则丢弃，杜绝复活。
      if (_authToken != null) {
        final stamp = await _storage.readSecureData(KeyConstants.authTokenStamp);
        final counter = await _readRevocationCounter();
        if (stamp != null && (int.tryParse(stamp) ?? -1) != counter) {
          LogUtils.w('$_tag 检测到残留的已作废会话 token(stamp=$stamp, counter=$counter)，清理');
          await clearTokens();
          return;
        }
        if (stamp == null) {
          // 升级前已存在但未盖戳的旧 token：补盖当前代次，纳入墓碑保护。
          await _storage.writeSecureData(
            KeyConstants.authTokenStamp,
            counter.toString(),
          );
        }
      }

      if (_authToken != null) {
        _updateTokenExpireTime(_authToken!, isAuthToken: true);
      }
      if (_accessToken != null) {
        _updateTokenExpireTime(_accessToken!, isAuthToken: false);
      }

      LogUtils.d(
        '$_tag 初始化完成 - '
        'hasAuthToken: ${_authToken != null}, '
        'hasAccessToken: ${_accessToken != null}, '
        'authTokenExpired: $isAuthTokenExpired, '
        'accessTokenExpired: $isAccessTokenExpired',
      );
    } catch (e) {
      LogUtils.e('$_tag 初始化失败', error: e);
    }
  }

  /// 验证 token
  TokenValidationResult validateToken(
    String token, {
    required bool isAuthToken,
  }) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return TokenValidationResult.malformed;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map) return TokenValidationResult.malformed;

      final type = payload['type'] as String?;
      if (type == null) return TokenValidationResult.invalid;

      if (isAuthToken && type != 'refresh_token') {
        return TokenValidationResult.wrongType;
      }
      if (!isAuthToken && type != 'access_token') {
        return TokenValidationResult.wrongType;
      }

      final exp = payload['exp'] as int?;
      if (exp == null) return TokenValidationResult.invalid;

      final expireTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (DateTime.now().isAfter(expireTime)) {
        return TokenValidationResult.expired;
      }

      return TokenValidationResult.valid;
    } catch (e) {
      LogUtils.e('$_tag Token 验证失败', error: e);
      return TokenValidationResult.malformed;
    }
  }

  /// 更新 token 过期时间
  void _updateTokenExpireTime(String token, {required bool isAuthToken}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map) return;

      final exp = payload['exp'] as int?;
      if (exp == null) return;

      final expireTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      if (isAuthToken) {
        _authTokenExpireTime = expireTime;
        LogUtils.d('$_tag Auth token 过期时间: $_authTokenExpireTime');
      } else {
        _accessTokenExpireTime = expireTime;
        LogUtils.d(
          '$_tag Access token 过期时间: $_accessTokenExpireTime '
          '(剩余 ${accessTokenRemainingSeconds}s)',
        );
      }
    } catch (e) {
      LogUtils.e('$_tag Token 过期时间解析失败', error: e);
    }
  }

  /// 读取持久化的会话作废代次（登出墓碑），缺失视为 0(HIGH#3)。
  Future<int> _readRevocationCounter() async {
    final raw = await _storage.readSecureData(
      KeyConstants.authRevocationCounter,
    );
    return int.tryParse(raw ?? '') ?? 0;
  }

  /// 保存 auth token（登录时调用）
  Future<void> saveAuthToken(String token) async {
    final validation = validateToken(token, isAuthToken: true);
    if (validation != TokenValidationResult.valid) {
      throw Exception('Invalid auth token: $validation');
    }

    // 新登录开启新会话：递增代次，使任何在途的旧刷新回包失效(#1)。
    _tokenGeneration++;
    _authToken = token;
    _updateTokenExpireTime(token, isAuthToken: true);
    // token 为敏感数据：fail-closed，安全存储不可用时不落明文，仅内存会话(HIGH#1)。
    await _storage.writeSecureData(
      KeyConstants.authToken,
      token,
      allowPlaintextFallback: false,
    );
    // 给当前 token 盖上会话作废代次，启动时据此校验残留(HIGH#3)。
    final counter = await _readRevocationCounter();
    await _storage.writeSecureData(
      KeyConstants.authTokenStamp,
      counter.toString(),
    );
    LogUtils.i('$_tag Auth token 已保存 (代次=$_tokenGeneration, stamp=$counter)');
  }

  /// 登录：staging/commit 模式(MEDIUM#4)。
  /// 先用候选 refresh token 隔离换取 access token，**成功才**提交为当前会话；
  /// 网络/认证失败不触碰现有会话，避免切号/重登时网络抖动导致旧会话被全量清空。
  Future<TokenRefreshResult> loginWithRefreshToken(String refreshToken) async {
    final validation = validateToken(refreshToken, isAuthToken: true);
    if (validation != TokenValidationResult.valid) {
      return TokenRefreshResult.authError('Invalid refresh token: $validation');
    }

    try {
      final response = await _tokenDio.post(
        '/user/token',
        options: dio.Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );
      final data = response.data;

      if (response.statusCode == 401) {
        return TokenRefreshResult.authError('Refresh token invalid (401)');
      }
      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['accessToken'] != null) {
        final newAccessToken = data['accessToken'] as String;
        if (validateToken(newAccessToken, isAuthToken: false) ==
            TokenValidationResult.valid) {
          // 提交：成功才覆盖当前会话。
          await _commitSession(refreshToken, newAccessToken);
          LogUtils.i('$_tag 登录会话已提交 (代次=$_tokenGeneration)');
          return TokenRefreshResult.success(newAccessToken);
        }
        return TokenRefreshResult.authError('Invalid access token received');
      }
      // 403 Cloudflare / 其他 → 视为可重试，不摧毁旧会话。
      return TokenRefreshResult.networkError(
        'Login token exchange failed (status: ${response.statusCode})',
      );
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return TokenRefreshResult.authError('Refresh token invalid (401)');
      }
      return TokenRefreshResult.networkError('Network error: ${e.message}');
    } catch (e) {
      return TokenRefreshResult.networkError('Unknown error: $e');
    }
  }

  /// 原子提交一个新会话（仅在候选 token 验证成功后调用）。
  Future<void> _commitSession(String refreshToken, String accessToken) async {
    // 递增代次，使旧会话的任何在途刷新作废(#1)。
    _tokenGeneration++;
    // 与 clearTokens 一致：提交新会话时也复位旧会话的在途刷新状态，
    // 完成其等待者并清掉 _isRefreshing/completer，避免泄漏污染 isRefreshing(A1)。
    final pending = _refreshCompleter;
    _isRefreshing = false;
    _refreshCompleter = null;
    _refreshingGeneration = -1;
    if (pending != null && !pending.isCompleted) {
      pending.complete(TokenRefreshResult.superseded());
    }
    _authToken = refreshToken;
    _accessToken = accessToken;
    _updateTokenExpireTime(refreshToken, isAuthToken: true);
    _updateTokenExpireTime(accessToken, isAuthToken: false);
    await _storage.writeSecureData(
      KeyConstants.authToken,
      refreshToken,
      allowPlaintextFallback: false,
    );
    await _storage.writeSecureData(
      KeyConstants.accessToken,
      accessToken,
      allowPlaintextFallback: false,
    );
    // 盖上当前会话作废代次(HIGH#3)。
    final counter = await _readRevocationCounter();
    await _storage.writeSecureData(
      KeyConstants.authTokenStamp,
      counter.toString(),
    );
  }

  /// 保存 access token
  Future<void> _saveAccessToken(String token) async {
    final validation = validateToken(token, isAuthToken: false);
    if (validation != TokenValidationResult.valid) {
      throw Exception('Invalid access token: $validation');
    }

    _accessToken = token;
    _updateTokenExpireTime(token, isAuthToken: false);
    // token 为敏感数据：fail-closed，不降级明文(HIGH#1)。
    await _storage.writeSecureData(
      KeyConstants.accessToken,
      token,
      allowPlaintextFallback: false,
    );
    LogUtils.d('$_tag Access token 已保存');
  }

  /// 刷新 access token - 核心方法
  ///
  /// 并发控制：如果已经有刷新任务在进行，返回同一个 Future
  /// 这确保了多个并发的 401 错误只会触发一次刷新
  Future<TokenRefreshResult> refreshAccessToken() async {
    // 仅复用「当前代次」的在途刷新；登录/切号(代次已变)后必须新建刷新，
    // 不能让新登录 latch 到注定被代次守卫丢弃的旧刷新(HIGH#1)。
    if (_isRefreshing &&
        _refreshCompleter != null &&
        _refreshingGeneration == _tokenGeneration) {
      LogUtils.d('$_tag 刷新任务已在进行中（同代次），等待完成...');
      return _refreshCompleter!.future;
    }

    // 检查是否有有效的 refresh token
    if (_authToken == null) {
      LogUtils.w('$_tag 没有 auth token，无法刷新');
      return TokenRefreshResult.authError('No refresh token available');
    }

    if (isAuthTokenExpired) {
      LogUtils.w('$_tag Auth token 已过期，需要重新登录');
      return TokenRefreshResult.authError('Refresh token expired');
    }

    // 开始刷新。用局部 completer + 局部 gen，使被取代的旧刷新返回时
    // 既不清掉新刷新的共享状态，也只完成自己的等待者。
    _isRefreshing = true;
    final completer = Completer<TokenRefreshResult>();
    _refreshCompleter = completer;
    final gen = _tokenGeneration;
    _refreshingGeneration = gen;

    // 收尾：仅当自己仍是「当前代次」的刷新时才复位共享状态。
    TokenRefreshResult finish(TokenRefreshResult result) {
      if (_refreshingGeneration == gen) {
        _isRefreshing = false;
        _refreshCompleter = null;
        _refreshingGeneration = -1;
      }
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      return result;
    }

    LogUtils.d('$_tag 开始刷新 access token... (代次=$gen)');

    try {
      final response = await _tokenDio.post(
        '/user/token',
        options: dio.Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      final data = response.data;

      // Cloudflare challenge 已解但响应解析失败：是网络/CF 抖动，可重试，
      // 不能当成认证失败而误登出(N-low)。
      if (response.extra['cloudflare_parse_failed'] == true) {
        LogUtils.w('$_tag Token 刷新遇到 Cloudflare 解析失败，稍后重试');
        return finish(
          TokenRefreshResult.networkError('Cloudflare parse failed'),
        );
      }

      if (response.statusCode == 403) {
        final cfMitigated = response.headers.value('cf-mitigated');
        if (cfMitigated != null && cfMitigated.contains('challenge')) {
          LogUtils.w('$_tag Token 刷新遇到 Cloudflare challenge (403)，稍后重试');
          return finish(
            TokenRefreshResult.networkError('Cloudflare challenge (403)'),
          );
        }
      }

      if (response.statusCode == 401) {
        // Refresh token 已失效，需要重新登录
        return finish(
          TokenRefreshResult.authError('Refresh token invalid (401)'),
        );
      }

      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['accessToken'] != null) {
        final newAccessToken = data['accessToken'] as String;

        final validation = validateToken(newAccessToken, isAuthToken: false);
        if (validation == TokenValidationResult.valid) {
          // 代次校验：期间若发生过登出/新登录，丢弃这次陈旧回包，
          // 避免旧账号 access token 覆盖新会话(#1)。
          if (gen != _tokenGeneration) {
            LogUtils.w(
              '$_tag 刷新回包代次过期 ($gen != $_tokenGeneration)，丢弃陈旧 access token',
            );
            // 被新会话取代：非认证失败，调用方不得据此登出(HIGH#1)。
            return finish(TokenRefreshResult.superseded());
          }

          await _saveAccessToken(newAccessToken);

          LogUtils.i('$_tag Access token 刷新成功');
          return finish(TokenRefreshResult.success(newAccessToken));
        } else {
          LogUtils.e('$_tag 返回的 access token 无效: $validation');
          return finish(TokenRefreshResult.authError('Invalid token received'));
        }
      }

      LogUtils.e(
        '$_tag Token 刷新响应无效 '
        '(status: ${response.statusCode}, dataType: ${data.runtimeType})',
      );
      return finish(
        TokenRefreshResult.authError(
          'Invalid refresh response (status: ${response.statusCode})',
        ),
      );
    } on dio.DioException catch (e) {
      LogUtils.e('$_tag Token 刷新失败: ${e.type} - ${e.message}');

      TokenRefreshResult result;

      if (e.response?.statusCode == 401) {
        // Refresh token 已失效，需要重新登录
        result = TokenRefreshResult.authError('Refresh token invalid (401)');
      } else if (_isNetworkError(e)) {
        // 网络错误，可以稍后重试
        result = TokenRefreshResult.networkError('Network error: ${e.message}');
      } else {
        // 其他服务器错误
        result = TokenRefreshResult.networkError(
          'Server error: ${e.response?.statusCode ?? e.type}',
        );
      }

      return finish(result);
    } catch (e) {
      LogUtils.e('$_tag Token 刷新时发生未知错误', error: e);
      return finish(TokenRefreshResult.networkError('Unknown error: $e'));
    }
  }

  /// 判断是否为网络错误
  bool _isNetworkError(dio.DioException e) {
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
      case dio.DioExceptionType.connectionError:
        return true;
      case dio.DioExceptionType.unknown:
        // 检查是否为 HandshakeException 或其他网络相关异常
        final error = e.error;
        if (error != null) {
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('handshake') ||
              errorStr.contains('socket') ||
              errorStr.contains('connection') ||
              errorStr.contains('network')) {
            return true;
          }
        }
        return false;
      default:
        return false;
    }
  }

  /// 启动后台刷新定时器
  void startBackgroundRefresh({bool immediateCheck = true}) {
    stopBackgroundRefresh();

    // 立即检查是否需要刷新（可在启动阶段延后到 UI Ready 之后执行）
    if (immediateCheck) {
      _checkAndRefreshIfNeeded();
    }

    // 定期检查
    _backgroundRefreshTimer = Timer.periodic(
      _backgroundRefreshInterval,
      (_) => _checkAndRefreshIfNeeded(),
    );

    LogUtils.d('$_tag 后台刷新定时器已启动 (immediateCheck=$immediateCheck)');
  }

  /// 停止后台刷新定时器
  void stopBackgroundRefresh() {
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = null;
  }

  /// 检查并在需要时刷新 token
  Future<void> _checkAndRefreshIfNeeded() async {
    // 以 refresh token 为准：access token 可能丢失，但只要 refresh 有效就应重建(#4)。
    if (!hasRefreshToken) return;

    if (isAuthTokenExpired) {
      LogUtils.w('$_tag Auth token 已过期，停止后台刷新');
      stopBackgroundRefresh();
      // 通知上层执行登出/清理，而不是默默把用户晾在"已登录"假象里(#2)。
      onAuthInvalidated?.call('background_auth_token_expired');
      return;
    }

    if (isAccessTokenExpired) {
      LogUtils.d('$_tag Access token 即将过期，执行后台刷新');
      final result = await refreshAccessToken();
      if (result.success) {
        // 定时器刷新成功也要驱动状态机收敛到 authenticated(A3/A4)。
        onRefreshSucceeded?.call();
      } else if (result.isAuthError) {
        LogUtils.w('$_tag 后台刷新失败且需要重新登录');
        stopBackgroundRefresh();
        onAuthInvalidated?.call(
          result.errorMessage ?? 'background_refresh_auth_error',
        );
      }
    }
  }

  /// 应用恢复到前台时调用。
  /// 返回 null 表示无需处理；返回 authError 表示 refresh token 已失效，
  /// 由上层(AuthService)决定清理并登出(#4)。
  Future<TokenRefreshResult?> onAppResumed() async {
    if (!hasRefreshToken) return null;

    LogUtils.d('$_tag 应用恢复到前台，检查 token 状态');

    if (isAuthTokenExpired) {
      LogUtils.w('$_tag Auth token 已过期');
      return TokenRefreshResult.authError('Refresh token expired on resume');
    }

    // 如果 access token 已经过期或即将过期，立即刷新
    if (isAccessTokenExpired) {
      LogUtils.d('$_tag Access token 需要刷新');
      return await refreshAccessToken();
    }

    return null;
  }

  /// 清除所有 token
  Future<void> clearTokens() async {
    stopBackgroundRefresh();

    // 结束会话：递增代次，使任何在途的旧刷新回包失效(#1)。
    _tokenGeneration++;

    _authToken = null;
    _accessToken = null;
    _authTokenExpireTime = null;
    _accessTokenExpireTime = null;

    // 结束在途刷新的等待者并复位共享状态。代次已递增，
    // 在途刷新的回包稍后会被 finish() 判为非当前代次而忽略(HIGH#1)。
    final pending = _refreshCompleter;
    _isRefreshing = false;
    _refreshCompleter = null;
    _refreshingGeneration = -1;
    if (pending != null && !pending.isCompleted) {
      pending.complete(TokenRefreshResult.authError('Tokens cleared'));
    }

    // 登出墓碑：递增并持久化会话作废代次，使「删除失败而残留的旧 token」
    // 在下次启动被代次校验作废，无法复活(HIGH#3)。
    final secureWasHealthy = _storage.isSecureStorageAvailable;
    final nextCounter = (await _readRevocationCounter()) + 1;
    await _storage.writeSecureData(
      KeyConstants.authRevocationCounter,
      nextCounter.toString(),
    );
    await _storage.deleteSecureData(KeyConstants.authTokenStamp);

    await _storage.deleteSecureData(KeyConstants.authToken);
    await _storage.deleteSecureData(KeyConstants.accessToken);

    // 兜底清理账号绑定的用户缓存：不依赖 UserService 是否已注册(#5)。
    try {
      await _storage.deleteSecureData(KeyConstants.cachedUserData);
      await _storage.deleteSecureData(KeyConstants.cachedUserDataTimestamp);
      await _storage.deleteSecureData(KeyConstants.cachedUserDataSubject);
    } catch (e) {
      LogUtils.w('$_tag 清理用户缓存失败(忽略): $e');
    }

    // 只要安全存储当前不可用（无论是登出前就坏的、还是登出途中变坏的），
    // 都整体清空安全存储兜底——否则代次自增可能 no-op、删除可能残留，
    // 墓碑会在它最该生效的场景失效(A2)。
    if (!_storage.isSecureStorageAvailable) {
      LogUtils.w('$_tag 安全存储不可用，执行安全存储兜底清空 (wasHealthy=$secureWasHealthy)');
      await _storage.wipeSecureStorage();
    }

    LogUtils.d('$_tag 所有 token 已清除 (代次=$_tokenGeneration, 作废=$nextCounter)');
  }

  void dispose() {
    stopBackgroundRefresh();
  }
}
