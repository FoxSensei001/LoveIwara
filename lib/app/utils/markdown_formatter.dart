import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 处理Markdown文本格式化的工具类
class MarkdownFormatter {
  // 单例实例
  static final MarkdownFormatter _instance = MarkdownFormatter._internal();

  // 工厂构造函数
  factory MarkdownFormatter() => _instance;

  // 内部构造函数
  MarkdownFormatter._internal();

  /// 格式化链接
  Future<String> formatLinks(String data) async {
    final patterns = {
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

    String updatedData = data;
    for (var entry in patterns.entries) {
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
    final codeBlockPattern = RegExp(r'`[^`]+`');
    List<String> segments = [];
    int lastEnd = 0;

    for (Match match in codeBlockPattern.allMatches(text)) {
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
    final markdownLinkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final segments = <String>[];
    int lastEnd = 0;

    // 先找出所有markdown格式的链接
    for (final match in markdownLinkPattern.allMatches(text)) {
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
    final linkPattern = RegExp(
      r'(?<![\[\(])' // 确保前面不是 [ 或 (
      r'(?<!\]\()' // 确保前面不是 ](
      r'https?://[^\s\[\]\(\)]+' // 匹配URL，不包含markdown特殊字符
      r'(?![\]\)])', // 确保后面不是 ] 或 )
      caseSensitive: false,
    );

    return text.replaceAllMapped(linkPattern, (match) {
      final url = match.group(0)!;
      // 既然是纯文本链接，前面肯定没有方括号包裹，直接替换即可
      // 但为了保险起见，这里不需要检查 _hasEmojiPrefix，因为正则排除已经在链接里的情况
      return '${_getLinkPrefix(url)}[$url]($url)';
    });
  }

  /// 获取链接前缀图标
  String _getLinkPrefix(String url) {
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

  /// 将文本中的 @ 用户名格式化为 Markdown 链接
  String formatMentions(String data) {
    // 额外排除 `[`，避免在 Markdown 链接标题中重复包裹用户名
    final mentionPattern = RegExp(r'(?<![\/\w\[])@([\w\u4e00-\u9fa5]+)');
    return data.replaceAllMapped(mentionPattern, (match) {
      final mention = match.group(0);
      final username = match.group(1);
      if (username == null) return mention ?? '';
      // 给提及也加上默认的用户图标
      return '👤 [$mention](https://www.iwara.tv/profile/$username)';
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
