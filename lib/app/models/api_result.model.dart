import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Result
class ApiResult<T> {
  final String message;
  final int code;
  final T? data;
  final Object? exception;

  bool get isSuccess => code == 200; // 改为通过状态码判断成功
  bool get isFail => !isSuccess;

  // 私有化构造函数
  ApiResult._(this.message, this.data, this.code, {this.exception});

  // 成功
  factory ApiResult.success({
    String? message, 
    T? data, 
    int code = 200,
    String? custMessage
  }) {
    return ApiResult._(custMessage ?? message ?? slang.t.common.success, data, code);
  }

  // 失败
  factory ApiResult.fail(String message,
      {T? data, int code = 500, Object? exception}) {
    return ApiResult._(message, data, code, exception: exception);
  }
  
  @override
  String toString() {
    return 'ApiResult{message: $message, code: $code, data: $data, isSuccess: $isSuccess, exception: $exception}';
  }
}

// 测试结果模型
class AITestResult {
  final String? rawResponse;
  final String? translatedText;
  final bool connectionValid;
  final String custMessage;

  AITestResult({
    this.rawResponse,
    this.translatedText,
    this.connectionValid = false,
    required this.custMessage
  });
  
  @override
  String toString() {
    return 'AITestResult{connectionValid: $connectionValid, custMessage: $custMessage, rawResponse: $rawResponse, translatedText: $translatedText}';
  }
}
