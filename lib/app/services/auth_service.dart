import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../models/api_result.model.dart';
import '../models/captcha.model.dart';
import 'storage_service.dart';
import 'message_service.dart';

// 添加token验证结果枚举
enum TokenValidationResult {
  valid,  // 有效
  expired,  // 过期
  invalid,  // 无效
  wrongType,  // 类型错误
  malformed // 格式错误
}

class AuthService extends GetxService {
  final StorageService _storage = StorageService();
  final MessageService _messageService = Get.find<MessageService>();
  final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: CommonConstants.iwaraApiBaseUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  static const String _tag = '认证服务';

  /// access_token 有效期约1小时（1736997366 - 1736993766 = 3600秒），用于访问API
  /// refresh_token(auth_token) 有效期约30天（1739268222 - 1736676222 = 2592000秒）, 用于刷新access_token
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

  // token过期时间解析, 此处返回的是秒级的时间戳
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

  // token类型检查
  String? _getTokenType(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      return payload['type'] as String?;
    } catch (e) {
      LogUtils.e('Token类型解析失败', tag: _tag, error: e);
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
      final type = _getTokenType(token);
      if (type == null) {
        LogUtils.e('Token类型解析失败', tag: _tag);
        return;
      }

      // 验证token类型是否正确
      if (isAuthToken && type != 'refresh_token') {
        LogUtils.e('Auth token类型错误: $type', tag: _tag);
        return;
      }
      if (!isAuthToken && type != 'access_token') {
        LogUtils.e('Access token类型错误: $type', tag: _tag);
        return;
      }

      final expiration = _getTokenExpiration(token);
      // 秒级的时间戳, 对应最终的过期时间
      if (expiration != null) {
        if (isAuthToken) {
          _authTokenExpireTime = DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
          LogUtils.d('$_tag Auth token 过期时间: $_authTokenExpireTime');
        } else {
          _accessTokenExpireTime = DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
          LogUtils.d('$_tag Access token 过期时间: $_accessTokenExpireTime');
        }
      }
    } catch (e) {
      LogUtils.e('Token过期时间解析失败', tag: _tag, error: e);
    }
  }

  // 修改 token 保存逻辑
  Future<void> _saveTokens(String authToken, String accessToken) async {
    // 验证token类型
    final authType = _getTokenType(authToken);
    final accessType = _getTokenType(accessToken);

    if (authType != 'refresh_token') {
      LogUtils.e('Auth token类型错误: $authType', tag: _tag);
      throw AuthServiceException('Invalid auth token type');
    }
    if (accessType != 'access_token') {
      LogUtils.e('Access token类型错误: $accessType', tag: _tag);
      throw AuthServiceException('Invalid access token type');
    }

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

  // 添加一个统一的状态管理
  final RxBool _isAuthenticated = false.obs;
  bool get isAuthenticated => hasToken && isTokenValid;

  // 修改 token 检查逻辑
  bool get isTokenValid {
    final valid = !isAuthTokenExpired && !isAccessTokenExpired;
    assert(() {
      // LogUtils.d('$_tag Token 有效性检查: authToken=${!isAuthTokenExpired}, accessToken=${!isAccessTokenExpired}');
      return true;
    }());
    return valid;
  }

  // 添加token验证方法
  TokenValidationResult validateToken(String token, bool isAuthToken) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return TokenValidationResult.malformed;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final type = payload['type'] as String?;
      if (type == null) return TokenValidationResult.invalid;
      
      if (isAuthToken && type != 'refresh_token') return TokenValidationResult.wrongType;
      if (!isAuthToken && type != 'access_token') return TokenValidationResult.wrongType;
      
      final exp = payload['exp'] as int?;
      if (exp == null) return TokenValidationResult.invalid;
      
      final expireTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (DateTime.now().isAfter(expireTime)) return TokenValidationResult.expired;
      
      return TokenValidationResult.valid;
    } catch (e) {
      LogUtils.e('Token验证失败', tag: _tag, error: e);
      return TokenValidationResult.malformed;
    }
  }

  // 初始化方法
  Future<AuthService> init() async {
    try {
      _authToken = await _storage.readSecureData(KeyConstants.authToken);
      _accessToken = await _storage.readSecureData(KeyConstants.accessToken);

      if (_authToken != null && _accessToken != null) {
        // 验证两个token
        final authTokenResult = validateToken(_authToken!, true);
        final accessTokenResult = validateToken(_accessToken!, false);
        
        // 记录验证结果
        LogUtils.d('$_tag Token验证结果:\n'
            'Auth token: $authTokenResult\n'
            'Access token: $accessTokenResult');
        
        // 处理不同的验证结果
        if (authTokenResult == TokenValidationResult.malformed || 
            authTokenResult == TokenValidationResult.invalid ||
            authTokenResult == TokenValidationResult.wrongType) {
          // token格式错误或类型错误，直接清理
          await _handleTokenExpiredSilently();
          return this;
        }
        
        if (accessTokenResult == TokenValidationResult.malformed || 
            accessTokenResult == TokenValidationResult.invalid ||
            accessTokenResult == TokenValidationResult.wrongType) {
          // access token有问题，尝试刷新
          if (authTokenResult == TokenValidationResult.valid) {
            _updateTokenExpireTime(_authToken!, true);
            final success = await refreshAccessToken();
            if (success) {
              _isAuthenticated.value = true;
            } else {
              await _handleTokenExpiredSilently();
            }
          } else {
            await _handleTokenExpiredSilently();
          }
          return this;
        }
        
        // 更新过期时间
        _updateTokenExpireTime(_authToken!, true);
        _updateTokenExpireTime(_accessToken!, false);
        
        // 检查是否需要刷新
        if (isAccessTokenExpired && !isAuthTokenExpired) {
          final success = await refreshAccessToken();
          if (success) {
            _isAuthenticated.value = true;
          } else {
            await _handleTokenExpiredSilently();
          }
        } else if (!isAccessTokenExpired) {
          _startTokenRefreshTimer();
          _isAuthenticated.value = true;
        }
      }
    } catch (e) {
      LogUtils.e('认证服务初始化失败', tag: _tag, error: e);
      await _handleTokenExpiredSilently();
    }
    return this;
  }

  // token刷新逻辑
  static const int maxRefreshRetries = 3;
  static const Duration refreshRetryDelay = Duration(seconds: 1);
  
  Future<bool> refreshAccessToken() async {
    if (!hasToken) {
      LogUtils.w('用户未登录，无法刷新token', _tag);
      return false;
    }

    // 验证auth token
    final authTokenResult = validateToken(_authToken!, true);
    if (authTokenResult != TokenValidationResult.valid) {
      LogUtils.w('Auth token无效，状态: $authTokenResult', _tag);
      await handleTokenExpired();
      return false;
    }

    if (_isRefreshing) {
      try {
        LogUtils.i('等待当前刷新完成...', _tag);
        await _refreshTokenCompleter?.future;
        return hasToken && isTokenValid;
      } catch (e) {
        LogUtils.e('等待token刷新失败', tag: _tag, error: e);
        return false;
      }
    }

    _isRefreshing = true;
    _refreshTokenCompleter = Completer<void>();

    for (int retry = 0; retry < maxRefreshRetries; retry++) {
      try {
        if (retry > 0) {
          LogUtils.i('第${retry + 1}次尝试刷新token...', _tag);
          await Future.delayed(refreshRetryDelay * retry);
        }

        final response = await _dio.post(
          '/user/token',
          options: dio.Options(
            headers: {'Authorization': 'Bearer $_authToken'},
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        if (response.statusCode == 200 && response.data['accessToken'] != null) {
          final newAccessToken = response.data['accessToken'];
          final tokenResult = validateToken(newAccessToken, false);
          
          if (tokenResult == TokenValidationResult.valid) {
            _accessToken = newAccessToken;
            _updateTokenExpireTime(newAccessToken, false);
            await _storage.writeSecureData(KeyConstants.accessToken, newAccessToken);
            
            LogUtils.d('Access token 刷新成功', _tag);
            _refreshTokenCompleter?.complete();
            return true;
          } else {
            LogUtils.e('刷新获取的token无效，状态: $tokenResult', tag: _tag);
            continue;
          }
        }
        
        LogUtils.e('刷新token失败：响应无效', tag: _tag);
        continue;
      } on dio.DioException catch (e) {
        if (e.type == dio.DioExceptionType.connectionTimeout ||
            e.type == dio.DioExceptionType.sendTimeout ||
            e.type == dio.DioExceptionType.receiveTimeout) {
          LogUtils.w('刷新token超时，将重试', _tag);
          continue;
        }
        
        if (e.response?.statusCode == 401) {
          LogUtils.e('刷新token失败：auth token已失效', tag: _tag);
          break;
        }
        
        LogUtils.e('刷新token失败', tag: _tag, error: e);
        continue;
      } catch (e) {
        LogUtils.e('刷新token失败', tag: _tag, error: e);
        continue;
      }
    }

    _refreshTokenCompleter?.completeError('Failed after $maxRefreshRetries retries');
    await handleTokenExpired();
    return false;
  }

  // 错误处理方法
  Future<void> handleTokenExpired() async {
    if (!_isAuthenticated.value) return;
    
    _isAuthenticated.value = false;
    _authToken = null;
    _accessToken = null;
    _authTokenExpireTime = null;
    _accessTokenExpireTime = null;
    
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;

    await _storage.deleteSecureData(KeyConstants.authToken);
    await _storage.deleteSecureData(KeyConstants.accessToken);
    
    try {
      Get.find<UserService>().handleLogout();
    } catch (e) {
      LogUtils.e('通知用户服务登出失败', tag: _tag, error: e);
    }
    
    _messageService.showMessage(
      t.errors.pleaseLoginAgain,
      MDToastType.warning,
    );

    LogUtils.d('用户已登出', _tag);
  }

  // resetProxy
  void resetProxy() {
    _dio.httpClientAdapter = IOHttpClientAdapter();
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
      // 立即刷新，但使用Future.microtask避免阻塞
      Future.microtask(() async {
        if (hasToken) {
          await refreshAccessToken();
        }
      });
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

  // 登录方法
  Future<ApiResult> login(String email, String password) async {
    try {
      LogUtils.i('开始登录流程...', _tag);

      final response = await _dio.post('/user/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        LogUtils.i('登录成功，保存token...', _tag);
        
        // 使用 _saveTokens 来保存和更新 token
        await _saveTokens(response.data['token'], response.data['accessToken'] ?? '');
        
        // 如果没有 accessToken,需要刷新获取
        if (response.data['accessToken'] == null) {
          LogUtils.i('需要刷新token...', _tag);
          
          final refreshResult = await refreshAccessToken();
          if (!refreshResult) {
            return ApiResult.fail(t.errors.loginFailed);
          }
        }
        
        LogUtils.i('登录流程完成', _tag);
        return ApiResult.success();
      }
      return ApiResult.fail(response.data['message'] ?? t.errors.loginFailed);
    } catch (e) {
      LogUtils.e('登录失败', tag: _tag, error: e);
      return ApiResult.fail(_getErrorMessage(e));
    }
  }

  // 错误处理方法
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

  // 登出方法
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

  // 静默处理token过期
  Future<void> _handleTokenExpiredSilently() async {
    // 如果已经是未登录状态,直接返回
    if (!_isAuthenticated.value) return;
    
    _isAuthenticated.value = false;
    _authToken = null;
    _accessToken = null;
    _authTokenExpireTime = null;
    _accessTokenExpireTime = null;
    
    // 停止定时器
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;

    // 清除存储的token
    await _storage.deleteSecureData(KeyConstants.authToken);
    await _storage.deleteSecureData(KeyConstants.accessToken);
    
    // 通知其他服务
    try {
      Get.find<UserService>().handleLogout();
    } catch (e) {
      LogUtils.e('通知用户服务登出失败', tag: _tag, error: e);
    }

    LogUtils.d('用户已静默登出', _tag);
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
