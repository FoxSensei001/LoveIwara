import 'dart:convert';
import 'package:crypto/crypto.dart';

/// XVersion请求头计算器
/// 用于获取发起请求时的X-Version头
/// 详情请看：https://github.com/yt-dlp/yt-dlp/issues/6549
class XVersionCalculatorUtil {
  // salt
  static const String _staticString = 'mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN';

  /// 算给定URL的X-Version头
  ///
  /// [url] 是要计算X-Version的完整URL字符串。
  /// 返回值是计算得到的X-Version字符串。
  static String calculateXVersion(String url) {
    // 解析URL
    final uri = Uri.parse(url);

    // 获取查询参数中的'expires'值
    final expires = uri.queryParameters['expires'];
    if (expires == null) {
      throw ArgumentError('URL中缺少expires参数');
    }

    // 获取路径的最后一个组件（UUID）
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      throw ArgumentError('URL路径无效，无法获取UUID');
    }
    final uuid = pathSegments.last;

    // 拼接字符串：<uuid>_<expires>_5nFp9kmbNnHdAFhaqMvt
    final concatenatedString = '${uuid}_${expires}_$_staticString';

    // 将拼接的字符串转换为UTF-8编码的字节
    final bytes = utf8.encode(concatenatedString);

    // 计算SHA-1哈希
    final digest = sha1.convert(bytes);

    // 返回十六进制的哈希值
    return digest.toString();
  }
}
