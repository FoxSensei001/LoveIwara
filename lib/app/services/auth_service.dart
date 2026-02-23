// auth_service.dart
// 认证服务 - 负责用户登录、登出和认证状态管理

import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
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

/// 认证服务
/// 使用 TokenManager 管理 token，专注于用户登录/登出逻辑
class AuthService extends GetxService {
  static const String _tag = '认证服务';

  final MessageService _messageService = Get.find<MessageService>();
  late final TokenManager _tokenManager;

  // 独立的 Dio 实例用于登录/注册等不需要认证的请求
  final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      baseUrl: CommonConstants.iwaraApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'x-site': CommonConstants.iwaraSiteHost,
        'Referer': CommonConstants.iwaraBaseUrl,
        'Origin': CommonConstants.iwaraBaseUrl,
      },
    ),
  );

  // 统一的认证状态管理
  final RxBool _isAuthenticated = false.obs;
  bool get isAuthenticated => _isAuthenticated.value;

  // 认证状态变化流
  Stream<bool> get authStateStream => _isAuthenticated.stream;

  // 代理 TokenManager 的属性
  String? get authToken => _tokenManager.authToken;
  String? get accessToken => _tokenManager.accessToken;
  bool get hasToken => _tokenManager.hasToken;
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
  }

  /// 初始化认证服务
  Future<AuthService> init() async {
    try {
      // 初始化 TokenManager
      await _tokenManager.init();

      if (_tokenManager.hasToken) {
        // 验证 token 有效性
        if (_tokenManager.isAuthTokenExpired) {
          LogUtils.i('$_tag Auth token 已过期，需要重新登录');
          await _handleTokenExpiredSilently();
          return this;
        }

        // 如果 access token 需要刷新，同步开始刷新（但不等待结果）
        // 这样 isRefreshing 标志会立即设置为 true
        if (_tokenManager.isAccessTokenExpired) {
          LogUtils.i('$_tag Access token 需要刷新，开始刷新');
          // 同步调用，让 isRefreshing 立即变为 true
          _startRefreshWithoutWaiting();
        }

        // 设置认证状态
        _isAuthenticated.value = true;

        // 启动后台刷新定时器
        _tokenManager.startBackgroundRefresh();
      }

      LogUtils.d('$_tag 初始化完成 - isAuthenticated: ${_isAuthenticated.value}');
    } catch (e) {
      LogUtils.e('$_tag 初始化失败', error: e);
      await _handleTokenExpiredSilently();
    }
    return this;
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
          } else if (result.isAuthError) {
            LogUtils.w('$_tag 后台刷新失败，需要重新登录: ${result.errorMessage}');
            _handleTokenExpiredSilently();
          } else {
            LogUtils.w('$_tag 后台刷新遇到网络错误: ${result.errorMessage}');
            // 网络错误不清理 token，等待下次重试
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
    await _tokenManager.onAppResumed();
    _updateAuthenticationState();
  }

  /// 更新认证状态
  void _updateAuthenticationState() {
    final wasAuthenticated = _isAuthenticated.value;
    final isNowAuthenticated =
        _tokenManager.hasToken && !_tokenManager.isAuthTokenExpired;

    if (wasAuthenticated != isNowAuthenticated) {
      _isAuthenticated.value = isNowAuthenticated;
      LogUtils.d('$_tag 认证状态变化: $wasAuthenticated -> $isNowAuthenticated');
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

      if (response.statusCode == 200 && response.data['token'] != null) {
        LogUtils.d('$_tag 登录成功，保存 auth token');

        // 保存 auth token
        await _tokenManager.saveAuthToken(response.data['token']);

        // 刷新获取 access token
        LogUtils.d('$_tag 获取 access token...');
        final refreshResult = await _tokenManager.refreshAccessToken();

        if (!refreshResult.success) {
          LogUtils.e('$_tag 获取 access token 失败: ${refreshResult.errorMessage}');
          await _tokenManager.clearTokens();
          return ApiResult.fail(t.errors.loginFailed);
        }

        // 更新认证状态
        _isAuthenticated.value = true;

        // 启动后台刷新
        _tokenManager.startBackgroundRefresh();

        LogUtils.i('$_tag 登录完成');
        return ApiResult.success();
      }

      return ApiResult.fail(response.data['message'] ?? t.errors.loginFailed);
    } catch (e) {
      LogUtils.e('$_tag 登录失败', error: e);
      return ApiResult.fail(_getErrorMessage(e));
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _tokenManager.clearTokens();
      _isAuthenticated.value = false;

      try {
        Get.find<UserService>().handleLogout();
      } catch (e) {
        LogUtils.e('$_tag 通知 UserService 登出失败', error: e);
      }

      LogUtils.d('$_tag 用户已登出');
    } catch (e) {
      LogUtils.e('$_tag 登出过程中发生错误', error: e);
      _isAuthenticated.value = false;
    }
  }

  /// 处理 token 过期（显示提示）
  Future<void> handleTokenExpired() async {
    if (!_isAuthenticated.value) return;

    await _tokenManager.clearTokens();
    _isAuthenticated.value = false;

    try {
      Get.find<UserService>().handleLogout();
    } catch (e) {
      LogUtils.e('$_tag 通知 UserService 登出失败', error: e);
    }

    _messageService.showMessage(t.errors.pleaseLoginAgain, MDToastType.warning);

    LogUtils.d('$_tag 用户已登出（token 过期）');
  }

  /// 静默处理 token 过期
  Future<void> _handleTokenExpiredSilently() async {
    if (!_isAuthenticated.value && !_tokenManager.hasToken) return;

    await _tokenManager.clearTokens();
    _isAuthenticated.value = false;

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
      if (response.statusCode == 200) {
        LogUtils.d('$_tag 成功获取验证码');
        return ApiResult.success(data: Captcha.fromJson(response.data));
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
      final data = {'email': email, 'locale': PlatformDispatcher.instance.locale.countryCode ?? 'en'};
      final response = await _dio.post(
        '/user/register',
        data: data,
        options: dio.Options(headers: headers),
      );

      if (response.statusCode == 201 &&
          response.data['message'] ==
              ApiMessage.registerEmailInstructionsSent.value) {
        LogUtils.d('$_tag 注册成功，邮件指令已发送');
        return ApiResult.success();
      }
      return ApiResult.fail(
        response.data['message'] ?? t.errors.registerFailed,
      );
    } on dio.DioException catch (e) {
      LogUtils.e('$_tag 注册失败: ${e.message}');
      if (e.response?.data != null) {
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
      if (e.response?.data is Map && e.response!.data.containsKey('message')) {
        final message = e.response!.data['message'] as String?;
        switch (message) {
          case "errors.invalidLogin":
            return t.errors.invalidLogin;
          case "errors.invalidCaptcha":
            return t.errors.invalidCaptcha;
          case "errors.tooManyRequests":
            return t.errors.tooManyRequests;
        }
      }
    }
    return CommonUtils.parseExceptionMessage(e);
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
