import 'dart:convert';

import 'package:dio/dio.dart';

/// 把异常拍平成一句「人能看懂、且能据此改配置」的具体原因。
///
/// dio 的异常默认 `toString()` 很长且把关键信息（状态码、服务端回包）埋在中间，
/// 这里统一抽成 `类型 / HTTP 状态 / 回包片段` 三段，供 UI 直接展示。
///
/// 来历：原本是 `TranslationService._describeError`。AI 调用抽成独立一层之后，
/// 翻译（Google / DeepLX 两条 dio 路）与 AI 两边都要用同一套措辞——两边各写一份
/// 的话，同一个 401 在两处会长得不一样。
String describeRequestError(Object e) {
  if (e is DioException) {
    final parts = <String>[];
    final status = e.response?.statusCode;
    if (status != null) {
      parts.add('HTTP $status');
    }
    // 直接用 dio 的类型名（connectionError / receiveTimeout ...）：
    // 与语言无关，也方便用户把原文贴给开发者
    if (e.type != DioExceptionType.badResponse &&
        e.type != DioExceptionType.unknown) {
      parts.add(e.type.name);
    }
    final body = stringifyResponseBody(e.response?.data);
    if (body.isNotEmpty) {
      parts.add(body);
    } else {
      final msg = e.message?.trim();
      if (msg != null && msg.isNotEmpty) parts.add(msg);
      final inner = e.error;
      if (inner != null) parts.add(inner.toString());
    }
    return truncateForMessage(parts.join(' | '));
  }
  final sdk = describeSdkApiError(e);
  if (sdk != null) return truncateForMessage(sdk);
  return truncateForMessage(e.toString());
}

/// 把 dartantic 底下那几个 SDK 抛的 `ApiException` 一族拍平。
///
/// # ⛔ 为什么非要单独处理：`toString()` 会把服务端原文丢掉
///
/// 2026-09-20 拿真中转站实测：一把被停用的 key，
///
/// - `listModels`（我们自己驱动）如实报出 `{"code":"API_KEY_DISABLED",
///   "message":"API key is disabled"}`；
/// - 聊天那条路只给一句 **`AuthenticationException: Unknown error`**。
///
/// 两个原因叠出来的：
/// 1. `Agent.send` 内部走的是**流式**那条路，而 `openai_dart` 的
///    `parseStreamError` 只认 `{"error":{"message":…}}` 这一种形状，认不出来就
///    写死 `'Unknown error'`——而国内中转普遍是 `{"code":…,"message":…}` 平铺；
/// 2. 它其实把整份 JSON 放进了 `ApiException.body`，但 `AuthenticationException`
///    **重写了 `toString()`**，只印 message，`statusCode` 和 `body` 全不印。
///
/// 于是用户看到的是"未知错误"，而服务端明明已经说清楚了"这把 key 被停用了"。
/// 对着"未知错误"没人查得下去，这正是 `login-network-diagnostics` 那次要防的事。
///
/// # 为什么用 dynamic 而不是 import 那几个包
///
/// `openai_dart` / `googleai_dart` / `ollama_dart` 各有一个**互不相干**的
/// `ApiException`（没有共同基类），全是 dartantic 的传递依赖。要类型安全就得
/// 把三个包都提成直接依赖并写三份分支；而它们碰巧都有 `statusCode` / `message`
/// 字段，用鸭子类型一份就覆盖全部，将来 dartantic 换底也不用跟着改。
String? describeSdkApiError(Object e) {
  final dynamic dyn = e;

  // 没有 statusCode 就不是这一族，交还给调用方按 toString 处理。
  final status = _readOrNull<int>(() => dyn.statusCode as int?);
  if (status == null) return null;

  final parts = <String>['HTTP $status'];

  // 服务端原文是真相，优先用它。
  final bodyText = stringifyResponseBody(
    _readOrNull<Object>(() => dyn.body as Object?),
  );
  if (bodyText.isNotEmpty) {
    parts.add(bodyText);
  } else {
    final message = _readOrNull<String>(() => dyn.message as String?)?.trim();
    // ⛔ 'Unknown error' 是 SDK 认不出回包形状时写死的占位，不是服务端说的话。
    // 把它当成"没有信息"，好让下面的 code 字段有机会露面。
    if (message != null && message.isNotEmpty && message != 'Unknown error') {
      parts.add(message);
    }
  }

  final code = _readOrNull<String>(() => dyn.code as String?)?.trim();
  if (code != null && code.isNotEmpty && !parts.join(' ').contains(code)) {
    parts.add(code);
  }

  return parts.length == 1 ? null : parts.join(' | ');
}

/// 读一个可能不存在的字段。字段不存在（[NoSuchMethodError]）或类型不对都返回 null。
T? _readOrNull<T>(T? Function() read) {
  try {
    return read();
  } catch (_) {
    return null;
  }
}

/// 把服务端回包转成一行可读文本（对象走 json，长文本截断）。
String stringifyResponseBody(dynamic data) {
  if (data == null) return '';
  try {
    final text = data is String ? data : jsonEncode(data);
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  } catch (_) {
    return data.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

String truncateForMessage(String text, {int max = 400}) {
  final trimmed = text.trim();
  if (trimmed.length <= max) return trimmed;
  return '${trimmed.substring(0, max)}…';
}

/// 统一的失败文案：`失败原因前缀: 具体细节`。
String failMessageWith(String prefix, Object error) =>
    '$prefix: ${describeRequestError(error)}';
