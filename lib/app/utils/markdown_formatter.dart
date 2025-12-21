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

    // 先找出所有markdown格式的链接，保持它们不变
    for (final match in markdownLinkPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        // 处理markdown链接之间的文本
        segments.add(processPlainLinks(text.substring(lastEnd, match.start)));
      }
      // 保持markdown链接不变
      segments.add(text.substring(match.start, match.end));
      lastEnd = match.end;
    }

    // 处理最后一段文本
    if (lastEnd < text.length) {
      segments.add(processPlainLinks(text.substring(lastEnd)));
    }

    return segments.join('');
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
      final faviconUrl = UrlUtils.getFaviconUrl(url);

      // 使用 Favicon (emo:text-i 表示文本高度的图标)
      // 如果获取失败(空字符串)，则回退到默认链接图标
      if (faviconUrl.isNotEmpty) {
        return '![emo:text-i]($faviconUrl) [$url]($url)';
      } else {
        return '🔗 [$url]($url)';
      }
    });
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
      return '[$mention](https://www.iwara.tv/profile/$username)';
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
