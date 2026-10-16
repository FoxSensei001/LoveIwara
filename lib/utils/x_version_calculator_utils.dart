import 'dart:convert';
import 'package:crypto/crypto.dart';

/// XVersion请求头计算器
/// 用于获取发起请求时的X-Version头
/// 详情请看：https://github.com/yt-dlp/yt-dlp/issues/6549
class XVersionCalculatorUtil {
  /// 内置盐值，官网前端换盐之前一直有效
  static const String defaultSalt = 'mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN';

  /// 当前使用的盐值。官网换盐后由 XVersionSaltService 从官网前端提取并替换。
  static String salt = defaultSalt;

  /// 算给定URL的X-Version头
  ///
  /// [url] 是要计算X-Version的完整URL字符串；[withSalt] 不传时用当前的 [salt]。
  /// 返回值是计算得到的X-Version字符串。
  static String calculateXVersion(String url, {String? withSalt}) {
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

    // 拼接字符串：<uuid>_<expires>_<salt>
    final concatenatedString = '${uuid}_${expires}_${withSalt ?? salt}';

    // 将拼接的字符串转换为UTF-8编码的字节
    final bytes = utf8.encode(concatenatedString);

    // 计算SHA-1哈希
    final digest = sha1.convert(bytes);

    // 返回十六进制的哈希值
    return digest.toString();
  }
}
