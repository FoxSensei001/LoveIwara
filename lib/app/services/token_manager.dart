// token_manager.dart
// 专业的 Token 管理器，处理 token 刷新的并发控制和生命周期管理

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import 'storage_service.dart';

/// Token 验证结果枚举
enum TokenValidationResult {
  valid, // 有效
  expired, // 过期
  invalid, // 无效
  wrongType, // 类型错误
  malformed // 格式错误
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
  bool get isRefreshing => _isRefreshing;

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

  TokenManager() {
    _initTokenDio();
  }

  void _initTokenDio() {
    _tokenDio = dio.Dio(dio.BaseOptions(
      baseUrl: CommonConstants.iwaraApiBaseUrl,
      connectTimeout: _tokenRequestTimeout,
      receiveTimeout: _tokenRequestTimeout,
      sendTimeout: _tokenRequestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _tokenDio.options.persistentConnection = false;

    // 配置 HTTP 客户端适配器
    _tokenDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.idleTimeout = Duration.zero;
        return client;
      },
    );
  }

  /// 初始化 - 从存储中加载 token
  Future<void> init() async {
    try {
      _authToken = await _storage.readSecureData(KeyConstants.authToken);
      _accessToken = await _storage.readSecureData(KeyConstants.accessToken);

      if (_authToken != null) {
        _updateTokenExpireTime(_authToken!, isAuthToken: true);
      }
      if (_accessToken != null) {
        _updateTokenExpireTime(_accessToken!, isAuthToken: false);
      }

      LogUtils.d('$_tag 初始化完成 - '
          'hasAuthToken: ${_authToken != null}, '
          'hasAccessToken: ${_accessToken != null}, '
          'authTokenExpired: $isAuthTokenExpired, '
          'accessTokenExpired: $isAccessTokenExpired');
    } catch (e) {
      LogUtils.e('$_tag 初始化失败', error: e);
    }
  }

  /// 验证 token
  TokenValidationResult validateToken(String token, {required bool isAuthToken}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return TokenValidationResult.malformed;

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

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
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      final exp = payload['exp'] as int?;
      if (exp == null) return;

      final expireTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      if (isAuthToken) {
        _authTokenExpireTime = expireTime;
        LogUtils.d('$_tag Auth token 过期时间: $_authTokenExpireTime');
      } else {
        _accessTokenExpireTime = expireTime;
        LogUtils.d('$_tag Access token 过期时间: $_accessTokenExpireTime '
            '(剩余 ${accessTokenRemainingSeconds}s)');
      }
    } catch (e) {
      LogUtils.e('$_tag Token 过期时间解析失败', error: e);
    }
  }

  /// 保存 auth token（登录时调用）
  Future<void> saveAuthToken(String token) async {
    final validation = validateToken(token, isAuthToken: true);
    if (validation != TokenValidationResult.valid) {
      throw Exception('Invalid auth token: $validation');
    }

    _authToken = token;
    _updateTokenExpireTime(token, isAuthToken: true);
    await _storage.writeSecureData(KeyConstants.authToken, token);
    LogUtils.i('$_tag Auth token 已保存');
  }

  /// 保存 access token
  Future<void> _saveAccessToken(String token) async {
    final validation = validateToken(token, isAuthToken: false);
    if (validation != TokenValidationResult.valid) {
      throw Exception('Invalid access token: $validation');
    }

    _accessToken = token;
    _updateTokenExpireTime(token, isAuthToken: false);
    await _storage.writeSecureData(KeyConstants.accessToken, token);
    LogUtils.d('$_tag Access token 已保存');
  }

  /// 刷新 access token - 核心方法
  ///
  /// 并发控制：如果已经有刷新任务在进行，返回同一个 Future
  /// 这确保了多个并发的 401 错误只会触发一次刷新
  Future<TokenRefreshResult> refreshAccessToken() async {
    // 如果已经有刷新任务在进行，等待并返回相同的结果
    if (_isRefreshing && _refreshCompleter != null) {
      LogUtils.d('$_tag 刷新任务已在进行中，等待完成...');
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

    // 开始刷新
    _isRefreshing = true;
    _refreshCompleter = Completer<TokenRefreshResult>();

    LogUtils.d('$_tag 开始刷新 access token...');

    try {
      final response = await _tokenDio.post(
        '/user/token',
        options: dio.Options(
          headers: {'Authorization': 'Bearer $_authToken'},
        ),
      );

      if (response.statusCode == 200 && response.data['accessToken'] != null) {
        final newAccessToken = response.data['accessToken'] as String;

        final validation = validateToken(newAccessToken, isAuthToken: false);
        if (validation == TokenValidationResult.valid) {
          await _saveAccessToken(newAccessToken);

          LogUtils.i('$_tag Access token 刷新成功');
          final result = TokenRefreshResult.success(newAccessToken);
          _completeRefresh(result);
          return result;
        } else {
          LogUtils.e('$_tag 返回的 access token 无效: $validation');
          final result = TokenRefreshResult.authError('Invalid token received');
          _completeRefresh(result);
          return result;
        }
      }

      LogUtils.e('$_tag Token 刷新响应无效');
      final result = TokenRefreshResult.authError('Invalid refresh response');
      _completeRefresh(result);
      return result;
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
            'Server error: ${e.response?.statusCode ?? e.type}');
      }

      _completeRefresh(result);
      return result;
    } catch (e) {
      LogUtils.e('$_tag Token 刷新时发生未知错误', error: e);
      final result = TokenRefreshResult.networkError('Unknown error: $e');
      _completeRefresh(result);
      return result;
    }
  }

  void _completeRefresh(TokenRefreshResult result) {
    _isRefreshing = false;
    _refreshCompleter?.complete(result);
    _refreshCompleter = null;
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
  void startBackgroundRefresh() {
    stopBackgroundRefresh();

    // 立即检查是否需要刷新
    _checkAndRefreshIfNeeded();

    // 定期检查
    _backgroundRefreshTimer = Timer.periodic(
      _backgroundRefreshInterval,
      (_) => _checkAndRefreshIfNeeded(),
    );

    LogUtils.d('$_tag 后台刷新定时器已启动');
  }

  /// 停止后台刷新定时器
  void stopBackgroundRefresh() {
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = null;
  }

  /// 检查并在需要时刷新 token
  Future<void> _checkAndRefreshIfNeeded() async {
    if (!hasToken) return;

    if (isAuthTokenExpired) {
      LogUtils.w('$_tag Auth token 已过期，停止后台刷新');
      stopBackgroundRefresh();
      return;
    }

    if (isAccessTokenExpired) {
      LogUtils.d('$_tag Access token 即将过期，执行后台刷新');
      final result = await refreshAccessToken();
      if (!result.success && result.isAuthError) {
        LogUtils.w('$_tag 后台刷新失败且需要重新登录');
        stopBackgroundRefresh();
      }
    }
  }

  /// 应用恢复到前台时调用
  Future<void> onAppResumed() async {
    if (!hasToken) return;

    LogUtils.d('$_tag 应用恢复到前台，检查 token 状态');

    if (isAuthTokenExpired) {
      LogUtils.w('$_tag Auth token 已过期');
      return;
    }

    // 如果 access token 已经过期或即将过期，立即刷新
    if (isAccessTokenExpired) {
      LogUtils.d('$_tag Access token 需要刷新');
      await refreshAccessToken();
    }
  }

  /// 清除所有 token
  Future<void> clearTokens() async {
    stopBackgroundRefresh();

    _authToken = null;
    _accessToken = null;
    _authTokenExpireTime = null;
    _accessTokenExpireTime = null;

    if (_isRefreshing) {
      _completeRefresh(TokenRefreshResult.authError('Tokens cleared'));
    }

    await _storage.deleteSecureData(KeyConstants.authToken);
    await _storage.deleteSecureData(KeyConstants.accessToken);

    LogUtils.d('$_tag 所有 token 已清除');
  }

  /// 重置代理设置
  void resetProxy() {
    _tokenDio.httpClientAdapter = IOHttpClientAdapter();
  }

  void dispose() {
    stopBackgroundRefresh();
  }
}
