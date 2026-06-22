// auth_service.dart
// 认证服务 - 负责用户登录、登出和认证状态管理

import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/iwara_site_headers.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart' show CommonUtils;

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../models/api_result.model.dart';
import '../models/captcha.model.dart';
import 'http_client_factory.dart';
import 'message_service.dart';
import 'token_manager.dart';
import 'iwara_network_service.dart';

/// 登录会话状态机：登录态的唯一权威来源。
/// UI 仍可读 [AuthService.isAuthenticated]（由本枚举派生），
/// 但所有状态迁移都集中在 [AuthService._transitionTo]。
enum AuthSessionState {
  /// 无 token
  unauthenticated,

  /// 启动/前台恢复时刷新中（UI 视作登录中，不闪退登录）
  refreshing,

  /// refresh token 有效
  authenticated,

  /// token 有效但网络刷新/拉资料失败，沿用缓存
  degradedOffline,

  /// refresh token 失效/过期 → 需重新登录
  expired,
}

/// 认证服务
/// 使用 TokenManager 管理 token，专注于用户登录/登出逻辑
class AuthService extends GetxService {
  static const String _tag = '认证服务';

  final MessageService _messageService = Get.find<MessageService>();
  late final TokenManager _tokenManager;

  // 独立的 Dio 实例用于登录/注册等不需要认证的请求
  // site header 通过拦截器动态注入（见 buildIwaraSiteHeaderInterceptor），
  // 避免 baked-in header + 切站时手动同步的时序坑。
  final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      baseUrl: CommonConstants.iwaraApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // 统一的认证状态管理：sessionState 为权威源，_isAuthenticated 为派生镜像，
  // 兼容现有 UI 调用点与 authStateStream（Stream<bool>）。
  final Rx<AuthSessionState> sessionState = AuthSessionState.unauthenticated.obs;
  final RxBool _isAuthenticated = false.obs;
  bool get isAuthenticated => _isAuthenticated.value;

  bool _isReady = false;
  bool _pendingInitialRefresh = false;

  // 认证状态变化流
  Stream<bool> get authStateStream => _isAuthenticated.stream;

  /// 唯一的状态迁移点。更新 sessionState 并把 _isAuthenticated 镜像为
  /// {authenticated, degradedOffline, refreshing} → true，其余 → false。
  void _transitionTo(AuthSessionState next) {
    final prev = sessionState.value;
    if (prev != next) {
      sessionState.value = next;
      LogUtils.d('$_tag 会话状态: $prev -> $next');
    }
    final boolAuth = next == AuthSessionState.authenticated ||
        next == AuthSessionState.degradedOffline ||
        next == AuthSessionState.refreshing;
    if (_isAuthenticated.value != boolAuth) {
      _isAuthenticated.value = boolAuth;
    }
  }

  // 代理 TokenManager 的属性
  String? get authToken => _tokenManager.authToken;
  String? get accessToken => _tokenManager.accessToken;
  bool get hasToken => _tokenManager.hasToken;
  bool get hasRefreshToken => _tokenManager.hasRefreshToken;
  bool get isAuthTokenExpired => _tokenManager.isAuthTokenExpired;
  bool get isAccessTokenExpired => _tokenManager.isAccessTokenExpired;
  bool get isAccessTokenActuallyExpired =>
      _tokenManager.isAccessTokenActuallyExpired;
  int get accessTokenRemainingSeconds =>
      _tokenManager.accessTokenRemainingSeconds;

  /// 检查 token 是否有效（用于 UI 判断）
  bool get isTokenValid =>
      hasToken && !isAuthTokenExpired && !isAccessTokenActuallyExpired;

  /// 获取 TokenManager（供 ApiService 使用）
  TokenManager get tokenManager => _tokenManager;

  AuthService() {
    _tokenManager = TokenManager();
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClientFactory.instance.createHttpClient,
    );
    _dio.interceptors.add(buildIwaraSiteHeaderInterceptor());
  }

  /// 初始化认证服务
  Future<AuthService> init() async {
    try {
      // Attach shared CookieJar + Cloudflare handler (iwrqk-style network stack).
      try {
        final networkService = Get.find<IwaraNetworkService>();
        networkService.registerDio(_dio);
        _tokenManager.attachNetworkService(networkService);
      } catch (e) {
        LogUtils.w('$_tag 网络服务未就绪，跳过 Cloudflare/Cookie 注入: $e');
      }

      // 初始化 TokenManager
      await _tokenManager.init();

      // 后台刷新发现 refresh token 失效时，统一走静默登出清理(#2)。
      _tokenManager.onAuthInvalidated = (reason) {
        LogUtils.w('$_tag 收到 TokenManager 认证失效通知: $reason');
        _handleTokenExpiredSilently();
      };

      // 后台定时器刷新成功时，把会话状态从 refreshing/degradedOffline
      // 收敛到 authenticated(A3/A4)。
      _tokenManager.onRefreshSucceeded = () {
        _updateAuthenticationState();
      };

      // 以 refresh token 为准：access token 可能因写入/迁移失败而丢失，
      // 但只要 refresh token 仍有效就应重建会话，而非假登出(#4)。
      if (_tokenManager.hasRefreshToken) {
        // 验证 token 有效性
        if (_tokenManager.isAuthTokenExpired) {
          LogUtils.i('$_tag Auth token 已过期，需要重新登录');
          await _handleTokenExpiredSilently();
          return this;
        }

        // 如果 access token 缺失或需要刷新，同步开始刷新（但不等待结果）
        // 这样 isRefreshing 标志会立即设置为 true
        if (_tokenManager.isAccessTokenExpired) {
          LogUtils.i('$_tag Access token 需要刷新，开始刷新');
          // 启动阶段延后到 UI Ready（避免 Cloudflare challenge 在无 context 时发生）
          if (_canRunCloudflareChallengeNow()) {
            _startRefreshWithoutWaiting();
          } else {
            _pendingInitialRefresh = true;
            LogUtils.d('$_tag UI 未就绪，延后 access token 刷新');
          }
        }

        // 设置认证状态：access token 缺失/待刷新(含 UI 未就绪而延后的 pending)
        // 一律视为「会话恢复中」refreshing，避免把无可用 access token 的会话
        // 误显示成完整登录(MEDIUM#4)；access 有效才是 authenticated。
        _transitionTo(
          _tokenManager.isAccessTokenExpired
              ? AuthSessionState.refreshing
              : AuthSessionState.authenticated,
        );

        // 启动后台刷新定时器
        _tokenManager.startBackgroundRefresh(immediateCheck: false);
      }

      LogUtils.d('$_tag 初始化完成 - isAuthenticated: ${_isAuthenticated.value}');
    } catch (e) {
      LogUtils.e('$_tag 初始化失败', error: e);
      await _handleTokenExpiredSilently();
    }
    return this;
  }

  /// App 首帧就绪后调用（允许展示 Cloudflare challenge）。
  void markReady() {
    if (_isReady) return;
    _isReady = true;
    var startedImmediateRefresh = _tokenManager.isRefreshing;

    if (_pendingInitialRefresh && _tokenManager.isAccessTokenExpired) {
      _pendingInitialRefresh = false;
      LogUtils.d('$_tag UI Ready，开始延后的 access token 刷新');
      // 明确处于会话恢复中，直到刷新成功才转 authenticated(MEDIUM#4)。
      _transitionTo(AuthSessionState.refreshing);
      _startRefreshWithoutWaiting();
      startedImmediateRefresh = true;
    }

    // Ensure the background refresh timer is active and run the first check
    // only after UI is ready (Cloudflare challenge needs a valid context).
    // 以 refresh token 为准：access 可能缺失/重建中，仍需调度刷新与重试(HIGH#1)。
    if (_tokenManager.hasRefreshToken && !_tokenManager.isAuthTokenExpired) {
      _tokenManager.startBackgroundRefresh(
        immediateCheck: !startedImmediateRefresh,
      );
    }
  }

  bool _canRunCloudflareChallengeNow() {
    try {
      if (!Get.isRegistered<IwaraNetworkService>()) return false;
      return Get.find<IwaraNetworkService>().hasContext;
    } catch (_) {
      return false;
    }
  }

  /// 开始刷新 token，但不等待结果
  /// 这样可以让 isRefreshing 标志立即设置为 true
  void _startRefreshWithoutWaiting() {
    // 调用 refreshAccessToken()，它会立即设置 isRefreshing = true
    // 然后在后台处理结果
    _tokenManager
        .refreshAccessToken()
        .then((result) {
          if (result.success) {
            LogUtils.d('$_tag 后台刷新 token 成功');
            // 把状态从 refreshing 收敛到 authenticated，避免 sessionState 卡在刷新中(M2)。
            _updateAuthenticationState();
          } else if (result.isAuthError) {
            LogUtils.w('$_tag 后台刷新失败，需要重新登录: ${result.errorMessage}');
            _handleTokenExpiredSilently();
          } else {
            LogUtils.w('$_tag 后台刷新遇到网络错误: ${result.errorMessage}');
            // 网络错误不清理 token：refresh token 仍有效则进入降级离线态(而非永远卡在
            // refreshing)，后台定时器会继续重试(HIGH#1)。
            if (_tokenManager.hasRefreshToken &&
                !_tokenManager.isAuthTokenExpired) {
              _transitionTo(AuthSessionState.degradedOffline);
            }
          }
        })
        .catchError((e) {
          LogUtils.e('$_tag 后台刷新异常', error: e);
        });
  }

  /// 刷新 access token（供外部调用）
  Future<bool> refreshAccessToken() async {
    final result = await _tokenManager.refreshAccessToken();

    if (result.success) {
      _updateAuthenticationState();
      return true;
    }

    if (result.isAuthError) {
      // 认证错误，不自动处理登出，让调用者决定
      LogUtils.w('$_tag Token 刷新失败（认证错误）: ${result.errorMessage}');
    }

    return false;
  }

  /// 应用恢复到前台时调用
  Future<void> onAppResumed() async {
    final result = await _tokenManager.onAppResumed();
    // refresh token 已失效：真正清理并登出，不要只翻 flag 留下脏 token(#4)。
    if (result != null && result.isAuthError) {
      LogUtils.w('$_tag 前台恢复发现认证失效，执行静默登出: ${result.errorMessage}');
      await _handleTokenExpiredSilently();
      return;
    }
    // 网络错误：refresh token 仍有效但刷新失败 → 降级离线态(M1)，不登出。
    if (result != null &&
        !result.success &&
        _tokenManager.hasRefreshToken &&
        !_tokenManager.isAuthTokenExpired) {
      LogUtils.w('$_tag 前台恢复刷新遇网络错误，进入降级离线态: ${result.errorMessage}');
      _transitionTo(AuthSessionState.degradedOffline);
      return;
    }
    _updateAuthenticationState();
  }

  /// 更新认证状态
  void _updateAuthenticationState() {
    final isNowAuthenticated =
        _tokenManager.hasToken && !_tokenManager.isAuthTokenExpired;
    if (isNowAuthenticated) {
      _transitionTo(AuthSessionState.authenticated);
    } else if (sessionState.value != AuthSessionState.unauthenticated) {
      _transitionTo(AuthSessionState.expired);
    }
  }

  /// 登录
  Future<ApiResult> login(String email, String password) async {
    try {
      LogUtils.d('$_tag 开始登录...');

      final response = await _dio.post(
        '/user/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['token'] != null) {
        LogUtils.d('$_tag 登录成功，staging 提交会话');

        // staging/commit：先隔离用候选 refresh token 换 access token，
        // 成功才提交为当前会话；失败不摧毁旧会话(MEDIUM#4)。
        final staged = await _tokenManager.loginWithRefreshToken(data['token']);

        if (!staged.success) {
          LogUtils.e('$_tag 登录换取 access token 失败: ${staged.errorMessage}');
          // 注意：不调用 clearTokens，旧会话(若有)保持不变。
          return ApiResult.fail(
            staged.isAuthError ? t.errors.loginFailed : t.errors.networkError,
          );
        }

        // 更新认证状态
        _transitionTo(AuthSessionState.authenticated);

        // 切号场景下 bool 流可能不触发(authenticated→authenticated)，
        // 主动清空旧账号的内存资料，避免新账号资料加载完成前显示旧账号(A5)。
        try {
          Get.find<UserService>().beginReauth();
        } catch (_) {}

        // 启动后台刷新
        _tokenManager.startBackgroundRefresh();
        LogUtils.i('$_tag 登录完成');
        return ApiResult.success();
      }

      final message = (data is Map<String, dynamic>) ? data['message'] : null;
      final dataSummary = data is Map<String, dynamic>
          ? 'keys=${data.keys.take(8).join(",")}'
          : 'type=${data.runtimeType}';
      LogUtils.w(
        '$_tag 登录接口返回非成功结果 '
        '(status=${response.statusCode}, message=${message ?? "null"}, $dataSummary)',
      );
      return ApiResult.fail(
        _resolveLoginErrorMessage(
          statusCode: response.statusCode,
          data: data,
          fallback: t.errors.loginFailed,
        ),
      );
    } catch (e) {
      if (e is dio.DioException) {
        LogUtils.e(
          '$_tag 登录请求异常 '
          '(type=${e.type}, status=${e.response?.statusCode}, uri=${e.requestOptions.uri})',
          error: e.response?.data ?? e.message ?? e.error,
          stackTrace: e.stackTrace,
        );
      } else {
        LogUtils.e('$_tag 登录失败', error: e);
      }
      return ApiResult.fail(_getErrorMessage(e));
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _tokenManager.clearTokens();
      _transitionTo(AuthSessionState.unauthenticated);

      try {
        Get.find<UserService>().handleLogout();
      } catch (e) {
        LogUtils.e('$_tag 通知 UserService 登出失败', error: e);
      }

      LogUtils.d('$_tag 用户已登出');
    } catch (e) {
      LogUtils.e('$_tag 登出过程中发生错误', error: e);
      _transitionTo(AuthSessionState.unauthenticated);
    }
  }

  /// 处理 token 过期（显示提示）。
  /// 始终清理 token —— 即使 _isAuthenticated 已为 false，也可能残留脏 token(#4)。
  Future<void> handleTokenExpired() async {
    final hadSession = _isAuthenticated.value || _tokenManager.hasToken;

    await _tokenManager.clearTokens();
    _transitionTo(AuthSessionState.expired);

    try {
      Get.find<UserService>().handleLogout();
    } catch (e) {
      LogUtils.e('$_tag 通知 UserService 登出失败', error: e);
    }

    // 仅在原先确有会话时提示，避免无会话时的误报 toast。
    if (hadSession) {
      _messageService.showMessage(
        t.errors.pleaseLoginAgain,
        MDToastType.warning,
      );
    }

    LogUtils.d('$_tag 用户已登出（token 过期）');
  }

  /// 静默处理 token 过期。始终清理 token，确保不残留脏 token(#4)。
  Future<void> _handleTokenExpiredSilently() async {
    await _tokenManager.clearTokens();
    _transitionTo(AuthSessionState.expired);

    try {
      Get.find<UserService>().handleLogout();
    } catch (e) {
      LogUtils.e('$_tag 通知 UserService 登出失败', error: e);
    }

    LogUtils.d('$_tag 用户已静默登出');
  }

  /// 获取验证码
  Future<ApiResult<Captcha>> fetchCaptcha() async {
    try {
      final response = await _dio.get('/captcha');
      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        LogUtils.d('$_tag 成功获取验证码');
        return ApiResult.success(data: Captcha.fromJson(data));
      }
      return ApiResult.fail(t.errors.failedToFetchCaptcha);
    } on dio.DioException catch (e) {
      LogUtils.e('$_tag 获取验证码失败: ${e.message}');
      return ApiResult.fail(t.errors.networkError);
    } catch (e) {
      LogUtils.e('$_tag 未知错误: $e');
      return ApiResult.fail(t.errors.unknownError);
    }
  }

  /// 注册新用户
  Future<ApiResult> register(
    String email,
    String captchaId,
    String captchaAnswer,
  ) async {
    try {
      final headers = {'X-Captcha': '$captchaId:$captchaAnswer'};
      final data = {
        'email': email,
        'locale': PlatformDispatcher.instance.locale.countryCode ?? 'en',
      };
      final response = await _dio.post(
        '/user/register',
        data: data,
        options: dio.Options(headers: headers),
      );

      final responseData = response.data;
      if (response.statusCode == 201 &&
          responseData is Map<String, dynamic> &&
          responseData['message'] ==
              ApiMessage.registerEmailInstructionsSent.value) {
        LogUtils.d('$_tag 注册成功，邮件指令已发送');
        return ApiResult.success();
      }
      final message = (responseData is Map<String, dynamic>)
          ? responseData['message']
          : null;
      return ApiResult.fail(message ?? t.errors.registerFailed);
    } on dio.DioException catch (e) {
      LogUtils.e('$_tag 注册失败: ${e.message}');
      if (e.response?.data is Map<String, dynamic>) {
        var errorMessage =
            e.response!.data['errors']?[0]['message'] ??
            e.response!.data['message'] ??
            t.errors.unknownError;
        switch (errorMessage) {
          case 'errors.invalidEmail':
            return ApiResult.fail(t.errors.invalidEmail);
          case 'errors.emailAlreadyExists':
            return ApiResult.fail(t.errors.emailAlreadyExists);
          case 'errors.invalidCaptcha':
            return ApiResult.fail(t.errors.invalidCaptcha);
          case 'errors.tooManyRequests':
            return ApiResult.fail(t.errors.tooManyRequests);
          default:
            return ApiResult.fail(errorMessage);
        }
      }
      return ApiResult.fail(t.errors.networkError);
    } catch (e) {
      LogUtils.e('$_tag 注册过程中发生意外错误: $e');
      return ApiResult.fail(t.errors.unknownError);
    }
  }

  /// 验证 token（供外部使用）
  TokenValidationResult validateToken(String token, bool isAuthToken) {
    return _tokenManager.validateToken(token, isAuthToken: isAuthToken);
  }

  /// 获取错误信息
  String _getErrorMessage(Object e) {
    if (e is dio.DioException) {
      final resolved = _resolveLoginErrorMessage(
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
      if (resolved != t.errors.loginFailed) {
        return resolved;
      }
    }
    return CommonUtils.parseExceptionMessage(e);
  }

  String _resolveLoginErrorMessage({
    int? statusCode,
    dynamic data,
    String? fallback,
  }) {
    if (statusCode == 429) {
      return t.errors.tooManyRequests;
    }

    final String? serverMessage = _extractServerMessage(data);
    final String? mappedMessage = _mapServerMessage(serverMessage);
    if (mappedMessage != null) {
      return mappedMessage;
    }

    if (serverMessage != null &&
        serverMessage.isNotEmpty &&
        !_looksLikeHtml(serverMessage)) {
      return serverMessage;
    }

    if (statusCode != null) {
      return '${t.errors.network.basicPrefix}${t.errors.network.serverError} ($statusCode)';
    }

    return fallback ?? t.errors.loginFailed;
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map<String, dynamic> && first['message'] is String) {
          return first['message'] as String;
        }
      }
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
    }
    if (data is String) return data;
    return null;
  }

  String? _mapServerMessage(String? message) {
    if (message == null || message.isEmpty) return null;
    switch (message) {
      case 'errors.invalidLogin':
        return t.errors.invalidLogin;
      case 'errors.invalidCaptcha':
        return t.errors.invalidCaptcha;
      case 'errors.tooManyRequests':
        return t.errors.tooManyRequests;
      default:
        return null;
    }
  }

  bool _looksLikeHtml(String text) {
    final normalized = text.trimLeft().toLowerCase();
    return normalized.startsWith('<!doctype html') ||
        normalized.startsWith('<html');
  }

  @override
  void onClose() {
    _tokenManager.dispose();
    super.onClose();
  }
}

// 自定义异常类
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);
}

class InvalidCredentialsException extends AuthServiceException {
  InvalidCredentialsException(super.message);
}

class NetworkException extends AuthServiceException {
  NetworkException(super.message);
}

class UnauthorizedException extends AuthServiceException {
  UnauthorizedException(super.message);
}
