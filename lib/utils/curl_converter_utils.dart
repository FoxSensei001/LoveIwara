import 'package:dio/dio.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// DioException 转 curl 命令工具类
class CurlConverterUtils {
  static const String _tag = 'CurlConverterUtils';

  /// 将 DioException 转换为 curl 命令并打印
  /// 
  /// [exception] DioException 异常对象
  /// [printToConsole] 是否打印到控制台，默认为 true
  /// [logLevel] 日志级别，默认为 LogLevel.debug
  /// 
  /// 返回生成的 curl 命令字符串
  static String convertDioExceptionToCurl(
    DioException exception, {
    bool printToConsole = true,
    LogLevel logLevel = LogLevel.debug,
  }) {
    try {
      final curlCommand = _buildCurlCommand(exception);
      
      if (printToConsole) {
        _printCurlCommand(curlCommand, logLevel);
      }
      
      return curlCommand;
    } catch (e) {
      LogUtils.e('转换 DioException 到 curl 命令失败', tag: _tag, error: e);
      return '';
    }
  }

  /// 构建 curl 命令
  static String _buildCurlCommand(DioException exception) {
    final requestOptions = exception.requestOptions;
    final method = requestOptions.method.toUpperCase();
    final url = _buildFullUrl(requestOptions);
    
    final List<String> curlParts = ['curl'];
    
    // 添加请求方法
    if (method != 'GET') {
      curlParts.add('-X $method');
    }
    
    // 添加请求头
    if (requestOptions.headers.isNotEmpty) {
      for (final entry in requestOptions.headers.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // 跳过一些不需要的头部
        if (_shouldSkipHeader(key)) continue;
        
        if (value != null && value.toString().isNotEmpty) {
          curlParts.add('-H "$key: $value"');
        }
      }
    }
    
    // 添加查询参数
    if (requestOptions.queryParameters.isNotEmpty) {
      final queryString = _buildQueryString(requestOptions.queryParameters);
      if (queryString.isNotEmpty) {
        final separator = url.contains('?') ? '&' : '?';
        curlParts.add('"$url$separator$queryString"');
      } else {
        curlParts.add('"$url"');
      }
    } else {
      curlParts.add('"$url"');
    }
    
    // 添加请求体
    if (requestOptions.data != null) {
      final data = _formatRequestBody(requestOptions.data);
      if (data.isNotEmpty) {
        curlParts.add('-d "$data"');
      }
    }
    
    return curlParts.join(' ');
  }

  /// 构建完整的 URL
  static String _buildFullUrl(RequestOptions requestOptions) {
    String url = requestOptions.uri.toString();
    
    // 如果 baseUrl 不在 uri 中，需要手动拼接
    if (!url.startsWith('http')) {
      final baseUrl = requestOptions.baseUrl;
      if (baseUrl.isNotEmpty) {
        url = '$baseUrl$url';
      }
    }
    
    return url;
  }

  /// 构建查询参数字符串
  static String _buildQueryString(Map<String, dynamic> queryParameters) {
    final List<String> params = [];
    
    for (final entry in queryParameters.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value != null) {
        if (value is List) {
          // 处理数组参数
          for (final item in value) {
            params.add('$key=${Uri.encodeComponent(item.toString())}');
          }
        } else {
          params.add('$key=${Uri.encodeComponent(value.toString())}');
        }
      }
    }
    
    return params.join('&');
  }

  /// 格式化请求体
  static String _formatRequestBody(dynamic data) {
    if (data == null) return '';
    
    if (data is String) {
      return data;
    } else if (data is Map) {
      // 简单处理 Map 类型，实际项目中可能需要更复杂的 JSON 处理
      return data.toString();
    } else {
      return data.toString();
    }
  }

  /// 判断是否应该跳过某个头部
  static bool _shouldSkipHeader(String headerName) {
    final skipHeaders = [
      'content-length',
      'host',
      'connection',
      'accept-encoding',
    ];
    
    return skipHeaders.contains(headerName.toLowerCase());
  }

  /// 打印 curl 命令
  static void _printCurlCommand(String curlCommand, LogLevel logLevel) {
    final separator = '=' * 80;
    final message = '''
$separator
🔧 DioException 转换为 curl 命令:
$separator
$curlCommand
$separator
''';
    
    switch (logLevel) {
      case LogLevel.debug:
        LogUtils.d(message, _tag);
        break;
      case LogLevel.info:
        LogUtils.i(message, _tag);
        break;
      case LogLevel.warning:
        LogUtils.w(message, _tag);
        break;
      case LogLevel.error:
        LogUtils.e(message, tag: _tag);
        break;
    }
  }

  /// 批量转换多个 DioException
  static List<String> convertMultipleDioExceptions(
    List<DioException> exceptions, {
    bool printToConsole = true,
    LogLevel logLevel = LogLevel.debug,
  }) {
    final List<String> curlCommands = [];
    
    for (int i = 0; i < exceptions.length; i++) {
      final exception = exceptions[i];
      LogUtils.d('转换第 ${i + 1} 个 DioException', _tag);
      
      final curlCommand = convertDioExceptionToCurl(
        exception,
        printToConsole: printToConsole,
        logLevel: logLevel,
      );
      
      if (curlCommand.isNotEmpty) {
        curlCommands.add(curlCommand);
      }
    }
    
    return curlCommands;
  }

  /// 从异常中提取有用的调试信息
  static Map<String, dynamic> extractDebugInfo(DioException exception) {
    final requestOptions = exception.requestOptions;
    
    return {
      'method': requestOptions.method,
      'url': _buildFullUrl(requestOptions),
      'headers': requestOptions.headers,
      'queryParameters': requestOptions.queryParameters,
      'data': requestOptions.data,
      'responseStatus': exception.response?.statusCode,
      'responseHeaders': exception.response?.headers.map,
      'responseData': exception.response?.data,
      'errorType': exception.type.toString(),
      'errorMessage': exception.message,
    };
  }
}

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/*
使用示例:

1. 在 API 服务的 catch 块中使用:
```dart
try {
  final response = await _apiService.get('/videos');
  return ApiResult.success(data: response.data);
} on DioException catch (e) {
  // 转换为 curl 命令并打印
  CurlConverterUtils.convertDioExceptionToCurl(e);
  
  // 或者获取 curl 命令字符串
  final curlCommand = CurlConverterUtils.convertDioExceptionToCurl(
    e, 
    printToConsole: false
  );
  
  // 使用原有的错误处理
  final errorMessage = CommonUtils.parseExceptionMessage(e);
  return ApiResult.fail(errorMessage, exception: e);
}
```

2. 在拦截器中使用:
```dart
onError: (error, handler) async {
  if (error is DioException) {
    // 自动转换为 curl 命令并打印
    CurlConverterUtils.convertDioExceptionToCurl(
      error,
      logLevel: LogLevel.error
    );
  }
  return handler.next(error);
}
```

3. 提取调试信息:
```dart
final debugInfo = CurlConverterUtils.extractDebugInfo(dioException);
print('请求方法: ${debugInfo['method']}');
print('请求URL: ${debugInfo['url']}');
print('响应状态: ${debugInfo['responseStatus']}');
```
*/
