import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 处理Markdown文本格式化的工具类
class MarkdownFormatter {
  // 单例实例
  static final MarkdownFormatter _instance = MarkdownFormatter._internal();

  // 工厂构造函数
  factory MarkdownFormatter() => _instance;

  // 内部构造函数
  MarkdownFormatter._internal();

  String get _currentBaseUrl {
    if (Get.isRegistered<AppService>()) {
      return Get.find<AppService>().currentSiteMode.baseUrl;
    }
    return IwaraSite.main.baseUrl;
  }

  /// 各类型链接的匹配正则。提为 static final，只在首次访问时编译一次，
  /// 避免每次 formatLinks 调用（评论/简介/论坛正文高频复用）都重新编译 7 个复杂正则。
  static final Map<IwaraUrlType, RegExp> _linkPatterns = {
    IwaraUrlType.video: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/video/([a-zA-Z0-9]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
    IwaraUrlType.forum: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/forum/([^/\s]+)/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
    IwaraUrlType.image: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/image/([a-zA-Z0-9]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
    IwaraUrlType.profile: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/profile/([^/\s]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
    IwaraUrlType.playlist: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/playlist/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
    IwaraUrlType.post: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/post/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
    IwaraUrlType.rule: RegExp(
      r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/rule/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
      caseSensitive: false,
    ),
  };

  /// 格式化链接
  Future<String> formatLinks(String data) async {
    String updatedData = data;
    for (var entry in _linkPatterns.entries) {
      updatedData = await formatLinkType(updatedData, entry.key, entry.value);
    }

    return updatedData;
  }

  /// 格式化特定类型的链接
  Future<String> formatLinkType(
    String data,
    IwaraUrlType type,
    RegExp pattern,
  ) async {
    final matches = pattern.allMatches(data).toList();
    if (matches.isEmpty) return data;

    String updatedData = data;
    final processedUrls = <String>{};

    for (final match in matches) {
      final originalUrl = match.group(0)!;
      if (processedUrls.contains(originalUrl)) continue;
      processedUrls.add(originalUrl);

      String idToFetch;
      String idForFallback;

      if (type == IwaraUrlType.forum && match.groupCount >= 2) {
        idToFetch = match.group(2)!;
        idForFallback = match.group(2)!;
      } else {
        idToFetch = match.group(1)!;
        idForFallback = match.group(1)!;
      }

      final info = await fetchInfo(type, idToFetch);
      final emoji = UrlUtils.getIwaraTypeEmoji(type);

      // 将 emoji 放在 Markdown 链接语法外面
      final linkText = info.isSuccess
          ? info.data?.replaceAll(RegExp(r'[\[\]\(\)]'), '') ?? ''
          : '${type.name.capitalize} $idForFallback'.replaceAll(
              RegExp(r'[\[\]\(\)]'),
              '',
            );

      final replacement = '$emoji [$linkText]($originalUrl)';
      updatedData = updatedData.replaceAll(originalUrl, replacement);
    }

    return updatedData;
  }

  /// 获取信息
  Future<ApiResult<String>> fetchInfo(IwaraUrlType type, String id) async {
    LightService? lightService;
    try {
      lightService = Get.find<LightService>();
    } catch (e) {
      LogUtils.e('LightService 未找到', tag: 'MarkdownFormatter', error: e);
      return ApiResult.fail(t.errors.serviceNotInitialized);
    }

    try {
      switch (type) {
        case IwaraUrlType.video:
          return lightService.fetchLightVideoTitle(id);
        case IwaraUrlType.forum:
          return lightService.fetchLightForumTitle(id);
        case IwaraUrlType.image:
          return lightService.fetchLightImageTitle(id);
        case IwaraUrlType.profile:
          final result = await lightService.fetchLightProfile(id);
          if (result.isSuccess && result.data != null) {
            return ApiResult.success(data: result.data!['name'] as String);
          }
          return ApiResult.fail(result.message);
        case IwaraUrlType.playlist:
          final result = await lightService.fetchPlaylistInfo(id);
          if (result.isSuccess && result.data != null) {
            return ApiResult.success(data: result.data.toString());
          }
          return ApiResult.fail(result.message);
        case IwaraUrlType.rule:
          return lightService.fetchRule(id);
        default:
          return ApiResult.fail(t.errors.unknownType);
      }
    } catch (e) {
      LogUtils.e('获取信息失败', tag: 'MarkdownFormatter', error: e);
      return ApiResult.fail(t.errors.errorWhileFetching);
    }
  }

  /// 行内代码块匹配（`code`）。提为 static final，避免每次 splitByCodeBlocks 重新编译。
  static final RegExp _codeBlockPattern = RegExp(r'`[^`]+`');

  /// Markdown 链接匹配（`[label](url)`）。供 processNonCodeBlockLinks 与
  /// _formatTimestampsInNonCodeBlock 共用，避免每次重新编译。
  static final RegExp _markdownLinkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  /// 纯文本中的裸 URL 匹配（排除已在 Markdown 链接/括号内的情况）。
  static final RegExp _plainLinkPattern = RegExp(
    r'(?<![\[\(])' // 确保前面不是 [ 或 (
    r'(?<!\]\()' // 确保前面不是 ](
    r'https?://[^\s\[\]\(\)]+' // 匹配URL，不包含markdown特殊字符
    r'(?![\]\)])', // 确保后面不是 ] 或 )
    caseSensitive: false,
  );

  /// 格式化Markdown链接
  String formatMarkdownLinks(String data) {
    // 将文本分割成代码块和非代码块部分
    List<String> segments = splitByCodeBlocks(data);
    List<String> processed = [];

    // 处理每个片段
    for (int i = 0; i < segments.length; i++) {
      // 偶数索引为非代码块内容，需要处理链接
      if (i % 2 == 0) {
        processed.add(processNonCodeBlockLinks(segments[i]));
      } else {
        // 奇数索引为代码块内容，保持原样
        processed.add(segments[i]);
      }
    }

    return processed.join('');
  }

  /// 将文本按代码块分割
  List<String> splitByCodeBlocks(String text) {
    List<String> segments = [];
    int lastEnd = 0;

    for (Match match in _codeBlockPattern.allMatches(text)) {
      // 添加代码块前的文本
      if (match.start > lastEnd) {
        segments.add(text.substring(lastEnd, match.start));
      }
      // 添加代码块
      segments.add(text.substring(match.start, match.end));
      lastEnd = match.end;
    }

    // 添加最后一段文本
    if (lastEnd < text.length) {
      segments.add(text.substring(lastEnd));
    }

    return segments;
  }

  /// 处理非代码块中的链接
  String processNonCodeBlockLinks(String text) {
    // 匹配URL，但不包括已经是markdown格式的链接和代码块中的链接
    final segments = <String>[];
    int lastEnd = 0;

    // 先找出所有markdown格式的链接
    for (final match in _markdownLinkPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        // 处理markdown链接之间的文本
        segments.add(processPlainLinks(text.substring(lastEnd, match.start)));
      }

      String matchText = text.substring(match.start, match.end);
      final label = match.group(1) ?? '';
      final url = match.group(2) ?? '';

      // 检查是否为图片
      bool isImage = false;
      // 1. 检查标签内部是否像图片 (针对误匹配的嵌套结构)
      if (label.trimLeft().startsWith('![')) {
        isImage = true;
      }
      // 2. 检查前一个字符是否为 ! (针对标准图片语法 ![alt](src))
      if (match.start > 0 && text[match.start - 1] == '!') {
        isImage = true;
      }

      // 如果不是图片，且前面没有 Emoji，则添加链接图标前缀
      if (!isImage && !_hasEmojiPrefix(text, match.start)) {
        final prefix = _getLinkPrefix(url);
        matchText = '$prefix$matchText';
      }

      segments.add(matchText);
      lastEnd = match.end;
    }

    // 处理最后一段文本
    if (lastEnd < text.length) {
      segments.add(processPlainLinks(text.substring(lastEnd)));
    }

    return segments.join('');
  }

  /// 检查指定位置前面是否已经有了 Emoji 或图标
  bool _hasEmojiPrefix(String text, int index) {
    if (index <= 0) return false;

    // 截取链接前面的文本
    String preText = text.substring(0, index).trimRight();

    // 检查是否以已知 Emoji 结尾
    final emojis = ['🎬', '📌', '🖼️', '👤', '🎵', '💬', '📜', '❓', '🔗'];
    for (final emoji in emojis) {
      if (preText.endsWith(emoji)) {
        return true;
      }
    }

    // 检查是否以 Favicon 图片结尾 (![emo:text-i](...))
    if (preText.endsWith(')')) {
      final lastImgStart = preText.lastIndexOf('![');
      if (lastImgStart != -1) {
        final potentialImg = preText.substring(lastImgStart);
        if (potentialImg.contains('emo:') || potentialImg.contains('icon:')) {
          return true;
        }
      }
    }

    return false;
  }

  /// 处理纯文本中的链接
  String processPlainLinks(String text) {
    return text.replaceAllMapped(_plainLinkPattern, (match) {
      final url = match.group(0)!;
      // 既然是纯文本链接，前面肯定没有方括号包裹，直接替换即可
      // 但为了保险起见，这里不需要检查 _hasEmojiPrefix，因为正则排除已经在链接里的情况
      return '${_getLinkPrefix(url)}[$url]($url)';
    });
  }

  /// 判断链接目标是否为真正的网址（绝对 http/https 链接且含主机名）。
  ///
  /// 用于过滤掉相对地址、锚点(#xxx)、mailto: 以及夹带的特殊字符等，
  /// 这些不是网页链接，不应在前面渲染链接图标。
  bool _isWebUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    final scheme = uri.scheme.toLowerCase();
    return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
  }

  /// 获取链接前缀图标
  String _getLinkPrefix(String url) {
    // 非网址（相对地址、锚点、特殊字符等）不加图标，避免误判为网页链接
    if (!_isWebUrl(url)) {
      return '';
    }

    // 1. 尝试识别 Iwara 特殊链接
    final info = UrlUtils.parseUrl(url);
    if (info.isIwaraUrl && info.type != IwaraUrlType.unknown) {
      return '${UrlUtils.getIwaraTypeEmoji(info.type)} ';
    }

    // 2. 尝试获取 Favicon
    final faviconUrl = UrlUtils.getFaviconUrl(url);
    if (faviconUrl.isNotEmpty) {
      return '![emo:icon-i]($faviconUrl) ';
    }

    // 3. 默认图标
    return '🔗 ';
  }

  /// 将文本中的换行符替换为两个空格和换行符
  String replaceNewlines(String data) {
    return data.replaceAll(RegExp(r'\n'), '  \n');
  }

  /// 自定义协议：时间节点跳转链接（如 `iwaraseek://61` 表示第 61 秒）
  static const String timestampScheme = 'iwaraseek://';

  /// 匹配形如 `1:01`、`1：01`(中文冒号)、`1:23:45` 的时间节点。
  static final RegExp _timestampPattern = RegExp(
    r'(?<![\d:：/])(\d{1,2})[:：](\d{1,2})(?:[:：](\d{1,2}))?(?![\d:：])',
  );

  /// 将文本中的时间节点格式化为可点击的 Markdown 链接。
  ///
  /// 仅处理普通文本片段，跳过代码块与已存在的 Markdown 链接，避免破坏
  /// 链接文字/URL（例如 URL 路径里的 `12:30`）。
  String formatTimestamps(String data) {
    // 先按代码块切分，偶数索引为普通文本，奇数索引为代码块（保持原样）
    final segments = splitByCodeBlocks(data);
    final processed = <String>[];
    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        processed.add(_formatTimestampsInNonCodeBlock(segments[i]));
      } else {
        processed.add(segments[i]);
      }
    }
    return processed.join('');
  }

  /// 在非代码块文本中处理时间节点，跳过已存在的 Markdown 链接片段。
  String _formatTimestampsInNonCodeBlock(String text) {
    final buffer = StringBuffer();
    int lastEnd = 0;

    for (final match in _markdownLinkPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        buffer.write(_replaceTimestamps(text.substring(lastEnd, match.start)));
      }
      // Markdown 链接片段保持原样
      buffer.write(text.substring(match.start, match.end));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      buffer.write(_replaceTimestamps(text.substring(lastEnd)));
    }

    return buffer.toString();
  }

  /// 在纯文本中执行时间节点替换。
  String _replaceTimestamps(String text) {
    return text.replaceAllMapped(_timestampPattern, (match) {
      final original = match.group(0)!;
      final Duration? duration;
      if (match.group(3) != null) {
        // 时:分:秒
        duration = CommonUtils.parseTimestamp(
          hours: match.group(1),
          minutes: match.group(2)!,
          seconds: match.group(3)!,
        );
      } else {
        // 分:秒
        duration = CommonUtils.parseTimestamp(
          minutes: match.group(1)!,
          seconds: match.group(2)!,
        );
      }
      // 非法时间（如 1:99）保持原样
      if (duration == null) return original;
      return '⏱ [$original]($timestampScheme${duration.inSeconds})';
    });
  }

  /// @ 用户名匹配，提为 static final 避免每次 formatMentions 重新编译。
  /// 额外排除 `[`，避免在 Markdown 链接标题中重复包裹用户名。
  static final RegExp _mentionPattern = RegExp(
    r'(?<![\/\w\[])@([\w\u4e00-\u9fa5]+)',
  );

  /// 将文本中的 @ 用户名格式化为 Markdown 链接
  String formatMentions(String data) {
    return data.replaceAllMapped(_mentionPattern, (match) {
      final mention = match.group(0);
      final username = match.group(1);
      if (username == null) return mention ?? '';
      // 给提及也加上默认的用户图标
      return '👤 [$mention]($_currentBaseUrl/profile/$username)';
    });
  }

  /// 处理翻译后的文本格式化
  Future<String> processTranslatedText(String rawText) async {
    String processed = rawText;

    // 进行各种格式化处理
    processed = await formatLinks(processed);
    processed = formatMarkdownLinks(processed);
    processed = formatMentions(processed);
    processed = replaceNewlines(processed);

    return processed;
  }
}
