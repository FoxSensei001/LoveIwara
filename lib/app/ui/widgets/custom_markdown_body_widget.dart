import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class CustomMarkdownBody extends StatefulWidget {
  final String data;
  final bool? initialShowUnprocessedText;
  final bool clickInternalLinkByUrlLaunch; // 当为true时，内部链接也使用urllaunch打开

  const CustomMarkdownBody({
    super.key,
    required this.data,
    this.initialShowUnprocessedText,
    this.clickInternalLinkByUrlLaunch = false,
  });

  @override
  State<CustomMarkdownBody> createState() => _CustomMarkdownBodyState();
}

class _CustomMarkdownBodyState extends State<CustomMarkdownBody> {
  String _displayData = "";
  bool _isProcessing = false;
  bool _showOriginal = false;
  bool _hasProcessedContent = false;
  late final ConfigService _configService;
  final _markdownGenerator = MarkdownGenerator(
    linesMargin: const EdgeInsets.symmetric(vertical: 4),
  );

  @override
  void dispose() {
    _isProcessing = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    _displayData = widget.data;
    _showOriginal = widget.initialShowUnprocessedText ??
        _configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    _processMarkdown(widget.data);
  }

  @override
  void didUpdateWidget(CustomMarkdownBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      if (mounted) {
        setState(() {
          _displayData = widget.data;
        });
      }
      _processMarkdown(widget.data);
    }
  }

  Future<void> _processMarkdown(String data) async {
    if (!mounted) return;
    _isProcessing = true;
    String processed = data;
    bool hasChanges = false;

    try {
      String newProcessed = await _formatLinks(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (!mounted || !_isProcessing) return;
    } catch (e) {
      LogUtils.e('格式化链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      String newProcessed = _formatMarkdownLinks(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (mounted && _isProcessing) {
        setState(() {
          _displayData = processed;
        });
      }
    } catch (e) {
      LogUtils.e('格式化 Markdown 链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      String newProcessed = _formatMentions(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (mounted && _isProcessing) {
        setState(() {
          _displayData = processed;
        });
      }
    } catch (e) {
      LogUtils.e('格式化提及时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      String newProcessed = _replaceNewlines(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (mounted && _isProcessing) {
        setState(() {
          _displayData = processed;
          _hasProcessedContent = hasChanges;
        });
      }
    } catch (e) {
      LogUtils.e('替换换行符时发生错误', error: e, tag: 'CustomMarkdownBody');
    }
  }

  Future<String> _formatLinks(String data) async {
    final patterns = {
      IwaraUrlType.video: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/video/([a-zA-Z0-9]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.forum: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/forum/([^/\s]+)/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.image: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/image/([a-zA-Z0-9]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.profile: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/profile/([^/\s]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.playlist: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/playlist/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.post: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/post/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.rule: RegExp(
          r'(?<![\]\(])(?:@\s*)?https?://(?:www\.)?iwara\.tv/rule/([a-zA-Z0-9-]+)(?:/[^\s]*)?',
          caseSensitive: false),
    };

    String updatedData = data;
    for (var entry in patterns.entries) {
      updatedData = await _formatLinkType(updatedData, entry.key, entry.value);
    }

    return updatedData;
  }

  Future<String> _formatLinkType(
      String data, IwaraUrlType type, RegExp pattern) async {
    final matches = pattern.allMatches(data).toList();
    if (matches.isEmpty) return data;

    String updatedData = data;
    final processedUrls = <String>{}; 

    for (final match in matches) {
      if (!mounted || !_isProcessing) return updatedData;

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

      final info = await _fetchInfo(type, idToFetch);
      final emoji = UrlUtils.getIwaraTypeEmoji(type);

      // 将 emoji 放在 Markdown 链接语法外面
      final linkText = info.isSuccess 
          ? info.data?.replaceAll(RegExp(r'[\[\]\(\)]'), '') ?? ''
          : '${type.name.capitalize} $idForFallback'.replaceAll(RegExp(r'[\[\]\(\)]'), '');

      final replacement = '$emoji [$linkText]($originalUrl)';
      updatedData = updatedData.replaceAll(originalUrl, replacement);
    }

    if (mounted && _isProcessing) {
      setState(() {
        _displayData = updatedData;
      });
    }
    return updatedData;
  }

  Future<ApiResult<String>> _fetchInfo(IwaraUrlType type, String id) async {
    LightService? lightService;
    try {
      lightService = Get.find<LightService>();
    } catch (e) {
      LogUtils.e('LightService 未找到', tag: 'CustomMarkdownBody', error: e);
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
      LogUtils.e('获取信息失败', tag: 'CustomMarkdownBody', error: e);
      return ApiResult.fail(t.errors.errorWhileFetching);
    }
  }

  /// 将文本中的链接格式化为 Markdown 链接
  String _formatMarkdownLinks(String data) {
    // 将文本分割成代码块和非代码块部分
    List<String> segments = _splitByCodeBlocks(data);
    List<String> processed = [];

    // 处理每个片段
    for (int i = 0; i < segments.length; i++) {
      // 偶数索引为非代码块内容，需要处理链接
      if (i % 2 == 0) {
        processed.add(_processNonCodeBlockLinks(segments[i]));
      } else {
        // 奇数索引为代码块内容，保持原样
        processed.add(segments[i]);
      }
    }

    return processed.join('');
  }

  /// 将文本按代码块分割
  List<String> _splitByCodeBlocks(String text) {
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
  String _processNonCodeBlockLinks(String text) {
    // 匹配URL，但不包括已经是markdown格式的链接和代码块中的链接
    final markdownLinkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final segments = <String>[];
    int lastEnd = 0;

    // 先找出所有markdown格式的链接，保持它们不变
    for (final match in markdownLinkPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        // 处理markdown链接之间的文本
        segments.add(_processPlainLinks(text.substring(lastEnd, match.start)));
      }
      // 保持markdown链接不变
      segments.add(text.substring(match.start, match.end));
      lastEnd = match.end;
    }

    // 处理最后一段文本
    if (lastEnd < text.length) {
      segments.add(_processPlainLinks(text.substring(lastEnd)));
    }

    return segments.join('');
  }

  /// 处理纯文本中的链接
  String _processPlainLinks(String text) {
    final linkPattern = RegExp(
      r'(?<![\[\(])' // 确保前面不是 [ 或 (
      r'(?<!\]\()' // 确保前面不是 ](
      r'https?://[^\s\[\]\(\)]+' // 匹配URL，不包含markdown特殊字符
      r'(?![\]\)])', // 确保后面不是 ] 或 )
      caseSensitive: false,
    );

    return text.replaceAllMapped(linkPattern, (match) {
      final url = match.group(0)!;
      final emoji = _getUrlTypeEmoji(url);
      // 将 emoji 放在 Markdown 链接语法外面
      return '$emoji [$url]($url)';
    });
  }

  /// 根据URL获取对应的图标
  String _getUrlTypeEmoji(String url) {
    final uri = Uri.tryParse(url.toLowerCase());
    if (uri == null) return '🔗';

    // 网站特定图标映射
    final Map<String, String> siteEmojis = {
      'github.com': '📦',
      'youtube.com': '📺',
      'youtu.be': '📺',
      'twitter.com': '🐦',
      'x.com': '🐦',
      'facebook.com': '👥',
      'instagram.com': '📸',
      'linkedin.com': '💼',
      'medium.com': '📝',
      'reddit.com': '📱',
      'stackoverflow.com': '💻',
      'discord.com': '💬',
      'telegram.org': '📨',
      'whatsapp.com': '💭',
      'docs.google.com': '📄',
      'drive.google.com': '💾',
      'maps.google.com': '🗺️',
      'play.google.com': '🎮',
      'apple.com': '🍎',
      'microsoft.com': '🪟',
      'amazon.com': '🛒',
      'netflix.com': '🎬',
      'spotify.com': '🎵',
      'twitch.tv': '🎮',
      'wikipedia.org': '📚',
      'notion.so': '📝',
      'figma.com': '🎨',
      'gitlab.com': '📦',
      'bitbucket.org': '📦',
      'npm.com': '📦',
      'docker.com': '🐳',
      'kubernetes.io': '⚓',
    };

    // 检查是否为已知网站
    final host = uri.host.replaceAll('www.', '');
    for (final entry in siteEmojis.entries) {
      if (host.contains(entry.key)) {
        return entry.value;
      }
    }

    // 根据URL路径判断类型
    final path = uri.path.toLowerCase();
    if (path.contains('.pdf')) return '📄';
    if (path.contains('.zip') || path.contains('.rar')) return '📦';
    if (path.contains('.mp3') || path.contains('.wav')) return '🎵';
    if (path.contains('.mp4') || path.contains('.mov')) return '🎥';
    if (path.contains('.jpg') || path.contains('.png')) return '🖼️';
    if (path.contains('.doc') || path.contains('.txt')) return '📝';
    if (path.contains('api') || path.contains('docs')) return '📚';

    // 默认图标
    return '🔗';
  }

  /// 将文本中的换行符替换为两个空格和换行符
  String _replaceNewlines(String data) {
    return data.replaceAll(RegExp(r'\n'), '  \n');
  }

  /// 将文本中的 @ 用户名格式化为 Markdown 链接
  String _formatMentions(String data) {
    final mentionPattern =
        RegExp(r'(?<![\/\w])@([\w\u4e00-\u9fa5]+)'); // 确保 @ 前不是 / 或字母数字字符
    return data.replaceAllMapped(mentionPattern, (match) {
      final mention = match.group(0);
      final username = match.group(1);
      if (username == null) return mention ?? '';
      return '[$mention](https://www.iwara.tv/profile/$username)';
    });
  }

  void _onTapLink(String url) async {
    try {
      final urlInfo = UrlUtils.parseUrl(url);

      if (!widget.clickInternalLinkByUrlLaunch && urlInfo.isIwaraUrl) {
        switch (urlInfo.type) {
          case IwaraUrlType.profile:
            if (urlInfo.id != null) {
              NaviService.navigateToAuthorProfilePage(urlInfo.id!);
            }
            break;
          case IwaraUrlType.image:
            if (urlInfo.id != null) {
              NaviService.navigateToGalleryDetailPage(urlInfo.id!);
            }
            break;
          case IwaraUrlType.video:
            if (urlInfo.id != null) {
              NaviService.navigateToVideoDetailPage(urlInfo.id!);
            }
            break;
          case IwaraUrlType.playlist:
            if (urlInfo.id != null) {
              NaviService.navigateToPlayListDetail(urlInfo.id!, isMine: false);
            }
            break;
          case IwaraUrlType.post:
            if (urlInfo.id != null) {
              NaviService.navigateToPostDetailPage(urlInfo.id!, null);
            }
            break;
          case IwaraUrlType.forum:
            if (urlInfo.id != null) {
              NaviService.navigateToForumThreadListPage(urlInfo.id!);
            }
            break;
          case IwaraUrlType.forumThread:
            if (urlInfo.id != null && urlInfo.secondaryId != null) {
              NaviService.navigateToForumThreadDetailPage(
                  urlInfo.id!, urlInfo.secondaryId!);
            }
            break;
          case IwaraUrlType.rule:
          case IwaraUrlType.unknown:
            await _launchUrl(Uri.parse(url), url);
            break;
        }
      } else {
        await _launchUrl(Uri.parse(url), url);
      }
    } catch (e) {
      LogUtils.e('处理链接点击时发生错误', tag: 'CustomMarkdownBody', error: e);
      showToastWidget(
          MDToastWidget(
              message: t.errors.errorWhileOpeningLink(link: url),
              type: MDToastType.error),
          position: ToastPosition.top);
    }
  }

  Future<void> _launchUrl(Uri uri, String href) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      LogUtils.e('无法打开链接: $href', tag: 'CustomMarkdownBody');
      showToastWidget(
          MDToastWidget(
              message: t.errors.errorWhileOpeningLink(link: href),
              type: MDToastType.error),
          position: ToastPosition.top);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.theme.brightness == Brightness.dark;
    final config =
        (isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig)
            .copy(configs: [
      LinkConfig(
        onTap: _onTapLink,
        style: TextStyle(
          decoration: TextDecoration.none, // 移除下划线
          color: isDark ? Colors.blue[300] : Colors.blue, // 保持链接颜色
        ),
      ),
      ImgConfig(
        builder: (url, attributes) {
          try {
            final parsedUri = Uri.tryParse(url);
            if (parsedUri == null || !parsedUri.hasAbsolutePath) {
              throw FormatException(t.errors.invalidUrl);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  // 进入图片详情页
                  ImageItem item = ImageItem(
                      url: url,
                      data: ImageItemData(id: '', url: url, originalUrl: url));
                  final menuItems = [
                    MenuItem(
                      title: t.galleryDetail.copyLink,
                      icon: Icons.copy,
                      onTap: () => ImageUtils.copyLink(item),
                    ),
                    MenuItem(
                      title: t.galleryDetail.copyImage,
                      icon: Icons.copy,
                      onTap: () => ImageUtils.copyImage(item),
                    ),
                    if (GetPlatform.isDesktop && !GetPlatform.isWeb)
                      MenuItem(
                        title: t.galleryDetail.saveAs,
                        icon: Icons.download,
                        onTap: () => ImageUtils.downloadImageToAppDirectory(item),
                      ),
                    MenuItem(
                      title: t.galleryDetail.saveToAlbum,
                      icon: Icons.save,
                      onTap: () => ImageUtils.downloadImageToAppDirectory(item),
                    ),
                  ];
                  NaviService.navigateToPhotoViewWrapper(
                      imageItems: [item],
                      initialIndex: 0,
                      menuItemsBuilder: (context, item) => menuItems);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '图片加载失败',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            LogUtils.e('图片加载失败', tag: 'CustomMarkdownBody', error: e);
            return const Icon(Icons.error);
          }
        },
      ),
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectionArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _markdownGenerator.buildWidgets(
                    _showOriginal ? widget.data : _displayData,
                    config: config,
                  ),
                ),
              ),
              if (_hasProcessedContent) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    icon: Icon(
                      _showOriginal
                          ? Icons.format_paint
                          : Icons.format_paint_outlined,
                      size: 14,
                    ),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      _showOriginal
                          ? t.common.showProcessedText
                          : t.common.showOriginalText,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _showOriginal = !_showOriginal;
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (false) // 开关，这样写方便我之后调试
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: Text(
                      '复制原文',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.data));
                      showToastWidget(
                        MDToastWidget(
                            message: '复制原文成功',
                            type: MDToastType.success),
                        position: ToastPosition.top,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: Text(
                      '复制处理后',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _displayData));
                      showToastWidget(
                        MDToastWidget(
                            message: '复制处理后成功',
                            type: MDToastType.success),
                        position: ToastPosition.top,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
