import 'package:dio/dio.dart';

enum ApiFailureKind {
  networkTimeout,
  authRefreshFailed,
  unauthorized,
  forbidden,
  privateVideo,
  cloudflareBlocked,
  connectionFailed,
  requestCancelled,
  serverError,
  unexpected,
}

class ApiFailureDetails {
  const ApiFailureDetails({
    required this.kind,
    this.statusCode,
    this.apiMessage,
  });

  final ApiFailureKind kind;
  final int? statusCode;
  final String? apiMessage;
}

class ApiFailureResolver {
  static ApiFailureDetails resolve(dynamic error) {
    if (error is! DioException) {
      return const ApiFailureDetails(kind: ApiFailureKind.unexpected);
    }

    final response = error.response;
    final statusCode = response?.statusCode;
    final apiMessage = _extractApiMessage(response?.data);

    if (error.requestOptions.extra['auth_refresh_failed'] == true) {
      // 只有「refresh token 被服务端判失效」才是要重新登录；刷新撞上断网、超时
      // 是网络问题，说成「请重新登录」会把用户引去重登，而 token 本来完好。
      return ApiFailureDetails(
        kind: isRefreshFailureAuthRelated(error.requestOptions)
            ? ApiFailureKind.authRefreshFailed
            : ApiFailureKind.connectionFailed,
        statusCode: statusCode,
        apiMessage: apiMessage,
      );
    }

    if (_isCloudflareBlocked(response)) {
      return ApiFailureDetails(
        kind: ApiFailureKind.cloudflareBlocked,
        statusCode: statusCode,
        apiMessage: apiMessage,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiFailureDetails(
          kind: ApiFailureKind.networkTimeout,
          statusCode: statusCode,
          apiMessage: apiMessage,
        );
      case DioExceptionType.cancel:
        return ApiFailureDetails(
          kind: ApiFailureKind.requestCancelled,
          statusCode: statusCode,
          apiMessage: apiMessage,
        );
      case DioExceptionType.connectionError:
        return ApiFailureDetails(
          kind: ApiFailureKind.connectionFailed,
          statusCode: statusCode,
          apiMessage: apiMessage,
        );
      case DioExceptionType.badResponse:
        return _resolveBadResponse(statusCode, apiMessage);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (statusCode != null) {
          return _resolveBadResponse(statusCode, apiMessage);
        }
        return ApiFailureDetails(
          kind: _looksLikeConnectionFailure(error)
              ? ApiFailureKind.connectionFailed
              : ApiFailureKind.unexpected,
          statusCode: statusCode,
          apiMessage: apiMessage,
        );
    }
  }

  static ApiFailureDetails _resolveBadResponse(
    int? statusCode,
    String? apiMessage,
  ) {
    if (statusCode == 401) {
      return ApiFailureDetails(
        kind: ApiFailureKind.unauthorized,
        statusCode: statusCode,
        apiMessage: apiMessage,
      );
    }

    if (statusCode == 403 && apiMessage == 'errors.privateVideo') {
      return ApiFailureDetails(
        kind: ApiFailureKind.privateVideo,
        statusCode: statusCode,
        apiMessage: apiMessage,
      );
    }

    if (statusCode == 403 && apiMessage == 'errors.forbidden') {
      return ApiFailureDetails(
        kind: ApiFailureKind.forbidden,
        statusCode: statusCode,
        apiMessage: apiMessage,
      );
    }

    return ApiFailureDetails(
      kind: ApiFailureKind.serverError,
      statusCode: statusCode,
      apiMessage: apiMessage,
    );
  }

  /// 刷新失败的原因是否为认证失效（而非网络）。原因串由 ApiService
  /// `_markAuthRefreshFailed` 写入；缺原因时按认证失效处理（保持旧行为）。
  static bool isRefreshFailureAuthRelated(RequestOptions options) {
    final reason = options.extra['authRefreshFailureReason'];
    if (reason is! String) return true;
    return reason.startsWith('refresh_auth_failed') ||
        reason == 'retry_401_after_refresh_success';
  }

  static bool _isCloudflareBlocked(Response<dynamic>? response) {
    if (response == null) return false;
    if (response.extra['cloudflare'] == true) return true;
    final cfMitigated = response.headers.value('cf-mitigated');
    return cfMitigated != null && cfMitigated.contains('challenge');
  }

  static bool _looksLikeConnectionFailure(DioException error) {
    final errorString = (error.message ?? error.error?.toString() ?? '')
        .toLowerCase();
    return errorString.contains('handshake') ||
        errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('reset');
  }

  static String? _extractApiMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
