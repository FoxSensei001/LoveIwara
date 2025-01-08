import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../models/api_result.model.dart';
import '../models/captcha.model.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final StorageService _storage = StorageService();
  final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: CommonConstants.iwaraApiBaseUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  static const String _tag = '认证服务';

  String? _authToken;

  String? get authToken => _authToken;
  String? _accessToken;

  String? get accessToken => _accessToken;

  bool get hasToken => _authToken != null && _accessToken != null;

  // 刷新token的completer
  Completer<void>? _refreshTokenCompleter;

  Timer? _tokenRefreshTimer;

  // 添加token刷新锁
  bool _isRefreshing = false;

  // 添加token过期时间
  DateTime? _tokenExpireTime;
  
  // 检查token是否过期
  bool get isTokenExpired {
    if (_tokenExpireTime == null) return true;
    return DateTime.now().isAfter(_tokenExpireTime!);
  }

  // 添加token过期时间解析
  int? _getTokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      return payload['exp'] as int?;
    } catch (e) {
      LogUtils.e('Token解析失败', tag: _tag, error: e);
      return null;
    }
  }

  // 添加 token 过期时间管理
  DateTime? _authTokenExpireTime;
  DateTime? _accessTokenExpireTime;
  
  // 添加提前刷新的时间阈值(比如提前5分钟刷新)
  static const int _refreshThreshold = 5 * 60; // 5分钟,单位秒

  // 更新 token 过期检查逻辑
  bool get isAuthTokenExpired {
    if (_authToken == null || _authTokenExpireTime == null) return true;
    return DateTime.now().isAfter(_authTokenExpireTime!);
  }

  bool get isAccessTokenExpired {
    if (_accessToken == null || _accessTokenExpireTime == null) return true;
    // 提前5分钟就视为过期,触发刷新
    return DateTime.now().add(const Duration(seconds: _refreshThreshold))
        .isAfter(_accessTokenExpireTime!);
  }

  // 更新 token 解析和保存逻辑
  void _updateTokenExpireTime(String token, bool isAuthToken) {
    try {
      final expiration = _getTokenExpiration(token);
      if (expiration != null) {
        final expireTime = DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
        if (isAuthToken) {
          _authTokenExpireTime = expireTime;
          LogUtils.d('$_tag Auth token 过期时间: $_authTokenExpireTime');
        } else {
          _accessTokenExpireTime = expireTime;
          LogUtils.d('$_tag Access token 过期时间: $_accessTokenExpireTime');
        }
      }
    } catch (e) {
      LogUtils.e('Token过期时间解析失败', tag: _tag, error: e);
    }
  }

  // 修改 token 保存逻辑
  Future<void> _saveTokens(String authToken, String accessToken) async {
    _authToken = authToken;
    _accessToken = accessToken;
    
    // 更新过期时间
    _updateTokenExpireTime(authToken, true);
    _updateTokenExpireTime(accessToken, false);
    
    // 保存到存储
    await _storage.writeSecureData(KeyConstants.authToken, authToken);
    await _storage.writeSecureData(KeyConstants.accessToken, accessToken);
    
    // 更新认证状态
    _isAuthenticated.value = true;
    
    // 启动刷新定时器
    _startTokenRefreshTimer();
  }

  // 添加队列处理并发刷新
  final Queue<Future<bool>> _refreshQueue = Queue();
  
  // 添加一个统一的状态管理
  final RxBool _isAuthenticated = false.obs;
  bool get isAuthenticated => hasToken && isTokenValid;

  // 修改 token 检查逻辑
  bool get isTokenValid {
    final valid = !isAuthTokenExpired && !isAccessTokenExpired;
    assert(() {
      LogUtils.d('$_tag Token 有效性检查: authToken=${!isAuthTokenExpired}, accessToken=${!isAccessTokenExpired}');
      return true;
    }());
    return valid;
  }

  // 修改刷新 token 的逻辑
  Future<bool> refreshAccessToken() async {
    LogUtils.d('刷新 access token', _tag);
    if (_isRefreshing) {
      try {
        await _refreshTokenCompleter?.future;
        return true;
      } catch (e) {
        return false;
      }
    }

    // 检查 auth token
    if (isAuthTokenExpired) {
      LogUtils.w('Auth token 已过期', _tag);
      await _handleTokenExpired();
      return false;
    }

    final future = () async {
      _isRefreshing = true;
      _refreshTokenCompleter = Completer<void>();

      try {
        final response = await _dio.post('/user/token',
            options: dio.Options(headers: {'Authorization': 'Bearer $_authToken'}));

        if (response.statusCode == 200 && response.data['accessToken'] != null) {
          // 使用 _saveTokens 更新 token
          await _saveTokens(_authToken!, response.data['accessToken']);
          LogUtils.d('Access token 刷新成功', _tag);
          return true;
        }
        throw AuthServiceException(response.data['message'] ?? t.errors.unknownError);
      } catch (e) {
        LogUtils.e('刷新token失败', tag: _tag, error: e);
        await _handleTokenExpired();
        rethrow;
      } finally {
        _isRefreshing = false;
        _refreshTokenCompleter?.complete();
        _refreshTokenCompleter = null;
      }
    }();
    
    _refreshQueue.add(future);
    return future;
  }

  // 添加统一的 token 过期处理
  Future<void> _handleTokenExpired() async {
    _isAuthenticated.value = false;
    await logout();
    // 通知其他服务
    try {
      Get.find<UserService>().handleLogout();
    } catch (e) {
      LogUtils.e('通知用户退出失败', tag: _tag, error: e);
    }
    // 显示提示并跳转
    showToastWidget(MDToastWidget(
      message: t.errors.pleaseLoginAgain,
      type: MDToastType.warning
    ));
  }

  // resetProxy
  void resetProxy() {
    _dio.httpClientAdapter = IOHttpClientAdapter();
  }

  // 初始化
  Future<AuthService> init() async {
    try {
      _authToken = await _storage.readSecureData(KeyConstants.authToken);
      _accessToken = await _storage.readSecureData(KeyConstants.accessToken);

      if (_authToken != null && _accessToken != null) {
        // 更新过期时间
        _updateTokenExpireTime(_authToken!, true);
        _updateTokenExpireTime(_accessToken!, false);
        
        LogUtils.d('$_tag 初始化完成\n'
            'Auth token 过期时间: $_authTokenExpireTime\n'
            'Access token 过期时间: $_accessTokenExpireTime');

        // 检查是否需要刷新
        if (isAccessTokenExpired && !isAuthTokenExpired) {
          await refreshAccessToken();
        } else if (!isAccessTokenExpired) {
          _startTokenRefreshTimer();
          _isAuthenticated.value = true;
        }
      } else {
        LogUtils.w('$_tag token读取失败，执行清理');
        await logout();
      }
    } catch (e) {
      LogUtils.e('认证服务初始化失败', tag: _tag, error: e);
      await logout();
    }
    return this;
  }

  // 优化刷新定时器逻辑
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    
    if (_accessTokenExpireTime == null) return;

    final now = DateTime.now();
    final timeUntilRefresh = _accessTokenExpireTime!
        .subtract(const Duration(seconds: _refreshThreshold))
        .difference(now);

    if (timeUntilRefresh.isNegative) {
      // 立即刷新
      refreshAccessToken();
    } else {
      // 设置定时器在过期前刷新
      _tokenRefreshTimer = Timer(timeUntilRefresh, () async {
        if (hasToken) {
          await refreshAccessToken();
        }
      });
    }
  }

  // 在服务销毁时取消定时任务
  @override
  void onClose() {
    _tokenRefreshTimer?.cancel();
    super.onClose();
  }

  // 修改登录方法
  Future<ApiResult> login(String email, String password) async {
    try {
      final response = await _dio.post('/user/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        // 使用 _saveTokens 来保存和更新 token
        await _saveTokens(response.data['token'], response.data['accessToken'] ?? '');
        
        // 如果没有 accessToken,需要刷新获取
        if (response.data['accessToken'] == null) {
          final refreshResult = await refreshAccessToken();
          if (!refreshResult) {
            return ApiResult.fail(t.errors.loginFailed);
          }
        }
        
        return ApiResult.success();
      }
      return ApiResult.fail(response.data['message'] ?? t.errors.loginFailed);
    } catch (e) {
      LogUtils.e('登录失败', tag: _tag, error: e);
      return ApiResult.fail(_getErrorMessage(e));
    }
  }

  // 添加错误处理方法
  String _getErrorMessage(Object e) {
    if (e is dio.DioException) {
      String message = e.response?.data['message'];
      switch (message) {
        case "errors.invalidLogin":
          return t.errors.invalidLogin;
        case "errors.invalidCaptcha":
          return t.errors.invalidCaptcha;
        case "errors.tooManyRequests":
          return t.errors.tooManyRequests;
        default:
          return message;
      }
    }
    return t.errors.unknownError;
  }

  // 修改登出方法
  Future<void> logout() async {
    try {
      _authToken = null;
      _accessToken = null;
      _tokenExpireTime = null;
      _tokenRefreshTimer?.cancel();
      _isAuthenticated.value = false;
      await _storage.deleteSecureData(KeyConstants.authToken);
      await _storage.deleteSecureData(KeyConstants.accessToken);
      LogUtils.d('用户已登出', _tag);
    } catch (e) {
      LogUtils.e('登出过程中发生错误', tag: _tag, error: e);
      _authToken = null;
      _accessToken = null;
      _tokenExpireTime = null;
      _isAuthenticated.value = false;
    }
  }

  // 抓取注册验证码
  Future<ApiResult<Captcha>> fetchCaptcha() async {
    try {
      final response = await _dio.get('/captcha');
      if (response.statusCode == 200) {
        LogUtils.d('成功获取验证码', _tag);
        return ApiResult.success(data: Captcha.fromJson(response.data));
      } else {
        return ApiResult.fail(t.errors.failedToFetchCaptcha);
      }
    } on dio.DioException catch (e) {
      LogUtils.e('抓取验证码失败: ${e.message}', tag: _tag);
      return ApiResult.fail(t.errors.networkError);
    } catch (e) {
      LogUtils.e('未知错误: $e', tag: _tag);
      return ApiResult.fail(t.errors.unknownError);
    }
  }

  // 注册新用户
  Future<ApiResult> register(
      String email, String captchaId, String captchaAnswer) async {
    try {
      final headers = {
        'X-Captcha': '$captchaId:$captchaAnswer',
      };
      final data = {
        'email': email,
        'locale': Get.locale?.countryCode ?? 'en',
      };
      final response = await _dio.post(
        '/user/register',
        data: data,
        options: dio.Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data['message'] == 'register.emailInstructionsSent') {
        LogUtils.d('注册成功，邮件指令已发送', _tag);
        return ApiResult.success();
      } else {
        return ApiResult.fail(
            response.data['message'] ?? t.errors.registerFailed);
      }
    } on dio.DioException catch (e) {
      LogUtils.e('注册失败: ${e.message}', tag: _tag);
      if (e.response != null && e.response?.data != null) {
        var errorMessage = e.response!.data['errors']?[0]['message'] ??
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
      } else {
        return ApiResult.fail(t.errors.networkError);
      }
    } catch (e) {
      LogUtils.e('注册过程中发生意外错误: $e', tag: _tag);
      return ApiResult.fail(t.errors.unknownError);
    }
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
