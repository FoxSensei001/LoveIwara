import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「这份配置最终会请求到哪个地址」的实时预览。
///
/// # ⭐ 为什么值得专门做一个控件
///
/// dartantic 把 `baseUrl` **原样当前缀**拼上各家的路径，所以用户填
/// `https://host/` 而不是 `https://host/v1` 时，请求会打到 `https://host//chat/
/// completions` → 404。而 404 长得像「模型名写错了」「这家挂了」「网络不通」，
/// 用户会去怀疑前三样，唯独不会怀疑那个他照着别人截图抄下来的地址。
///
/// 把最终 URL 摆出来，这个错误就从「查半天」变成「一眼看见」。
///
/// ⚠️ 只是**预览**：真正的拼接由 dartantic 各 provider 内部完成，这里是按它们
/// 的路径模板重写的一份。路径模板变了这里会不准，但不准的预览也比没有强——
/// 它要回答的问题是「我的地址是不是少/多了一段」，那部分永远是对的。
class AiEndpointPreview extends StatelessWidget {
  const AiEndpointPreview({
    super.key,
    required this.kind,
    required this.baseUrl,
  });

  /// 见 [AiProviderKind]。
  final String kind;

  /// 已经合并过目录的那个地址（空串＝这一家用 SDK 内置地址）。
  final String baseUrl;

  /// 各家聊天接口的路径。与 dartantic_ai 3.4.2 各 provider 内部一致。
  static String _chatPath(String kind) => switch (kind) {
    AiProviderKind.anthropic => '/messages',
    AiProviderKind.google => '/v1beta/models/<model>:generateContent',
    AiProviderKind.ollama => '/api/chat',
    _ => '/chat/completions',
  };

  /// 预览文本。地址为空或不支持自定义时回 null（＝没什么好预览的）。
  static String? previewUrl(String kind, String baseUrl) {
    if (!AiProviderKind.supportsCustomBaseUrl(kind)) return null;
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return null;
    // ⛔ 故意**不**把结尾的 `/` 吃掉：`https://host//chat/completions` 里那个
    // 多出来的斜杠正是我们要让用户看见的东西。
    return '$trimmed${_chatPath(kind)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final url = previewUrl(kind, baseUrl);
    if (url == null) return const SizedBox.shrink();

    // 少 / 多一段路径最常见的两种写法，就地点名。
    final warning = _warn(t, baseUrl.trim(), kind);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.ai.endpointPreview(url: url),
          style: TextStyle(
            fontSize: 11,
            height: 1.35,
            fontFamily: 'monospace',
            color: cs.onSurfaceVariant,
          ),
        ),
        if (warning != null) ...[
          const SizedBox(height: 4),
          Text(
            warning,
            style: TextStyle(fontSize: 11, height: 1.35, color: cs.error),
          ),
        ],
      ],
    );
  }

  static String? _warn(slang.Translations t, String baseUrl, String kind) {
    if (baseUrl.endsWith('/')) return t.ai.endpointTrailingSlash;
    // 只对 OpenAI 兼容那支提醒版本段：另外两家的路径模板自带版本。
    if (kind != AiProviderKind.openai) return null;
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasAuthority) return null;
    final hasVersion = uri.pathSegments.any(
      (s) => RegExp(r'^v\d+([a-z]+\d*)?$').hasMatch(s),
    );
    return hasVersion ? null : t.ai.endpointMissingVersion;
  }
}
