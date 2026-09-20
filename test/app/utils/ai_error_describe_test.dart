import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/ai_error_describe.dart';

/// 仿 `openai_dart` 的 `AuthenticationException`：字段齐、**但 toString 只印
/// message**。这正是 2026-09-20 实测踩到的形状——服务端明明说了"key 被停用"，
/// 用户看到的却是一句"Unknown error"。
class _FakeAuthException implements Exception {
  _FakeAuthException({required this.message, this.body, this.code});

  final int statusCode = 401;
  final String message;
  final Map<String, dynamic>? body;
  final String? code;

  @override
  String toString() => 'AuthenticationException: $message';
}

/// 仿 `googleai_dart` / `ollama_dart` 那一族：有 statusCode 与 message，**没有 body**。
class _FakeStatusOnlyException implements Exception {
  _FakeStatusOnlyException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

void main() {
  group('SDK 异常：把服务端原文捞回来', () {
    test('⛔ toString 丢掉的 body 必须捞回来（真实踩到的那一例）', () {
      final e = _FakeAuthException(
        // SDK 认不出回包形状时写死的占位
        message: 'Unknown error',
        body: {'code': 'API_KEY_DISABLED', 'message': 'API key is disabled'},
      );
      final out = describeRequestError(e);
      expect(out, contains('HTTP 401'));
      expect(out, contains('API key is disabled'));
      expect(
        out,
        isNot(contains('Unknown error')),
        reason: '"Unknown error" 是占位，不是服务端说的话，不该露给用户',
      );
    });

    test('没有 body 时退而用 message', () {
      final out = describeRequestError(
        _FakeStatusOnlyException(429, 'rate limit exceeded'),
      );
      expect(out, contains('HTTP 429'));
      expect(out, contains('rate limit exceeded'));
    });

    test('message 是占位且没有 body 时，至少把 code 报出来', () {
      final out = describeRequestError(
        _FakeAuthException(message: 'Unknown error', code: 'invalid_api_key'),
      );
      expect(out, contains('HTTP 401'));
      expect(out, contains('invalid_api_key'));
    });

    test('⛔ 只有 HTTP 状态、别的什么都没有时，不要顶掉原本的 toString', () {
      // 这种情况下 'HTTP 401' 比 toString 的信息量还少，应当放弃接管
      expect(
        describeSdkApiError(_FakeAuthException(message: 'Unknown error')),
        isNull,
      );
    });

    test('普通异常不走这条路', () {
      expect(describeSdkApiError(const FormatException('bad json')), isNull);
      expect(
        describeRequestError(const FormatException('bad json')),
        contains('bad json'),
      );
    });
  });

  group('dio 异常', () {
    test('状态码 + 回包片段', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 503,
          data: {'msg': '服务端忙'},
        ),
        type: DioExceptionType.badResponse,
      );
      final out = describeRequestError(e);
      expect(out, contains('HTTP 503'));
      expect(out, contains('服务端忙'));
    });

    test('连不上时报 dio 的类型名（与语言无关，方便贴给开发者）', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
        message: 'failed to connect',
      );
      expect(describeRequestError(e), contains('connectionError'));
    });
  });

  test('过长的原因要截断，不能整段糊到弹窗上', () {
    final out = truncateForMessage('x' * 900);
    expect(out.length, lessThanOrEqualTo(401));
    expect(out, endsWith('…'));
  });
}
