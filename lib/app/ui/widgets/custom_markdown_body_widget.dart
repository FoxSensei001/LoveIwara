import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
        _configService[ConfigService.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
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

    try {
      processed = await _formatLinks(processed);
      if (!mounted || !_isProcessing) return;
    } catch (e) {
      LogUtils.e('格式化链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      processed = _formatMarkdownLinks(processed);
      if (mounted && _isProcessing) {
        setState(() {
          _displayData = processed;
        });
      }
    } catch (e) {
      LogUtils.e('格式化 Markdown 链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      processed = _formatMentions(processed);
      if (mounted && _isProcessing) {
        setState(() {
          _displayData = processed;
        });
      }
    } catch (e) {
      LogUtils.e('格式化提及时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      processed = _replaceNewlines(processed);
      if (mounted && _isProcessing) {
        setState(() {
          _displayData = processed;
        });
      }
    } catch (e) {
      LogUtils.e('替换换行符时发生错误', error: e, tag: 'CustomMarkdownBody');
    }
  }

  Future<String> _formatLinks(String data) async {
    final patterns = {
      IwaraUrlType.video: RegExp(
          r'(?<!\]\()https?://(?:www\.)?iwara\.tv/video/([a-zA-Z0-9]+)(?:/[^\s]*)?',
          caseSensitive: false),
      IwaraUrlType.forum: RegExp(
          r'(?<!\]\()https?://(?:www\.)?iwara\.tv/forum/[^/\s]+/([a-zA-Z0-9-]+)',
          caseSensitive: false),
      IwaraUrlType.image: RegExp(
          r'(?<!\]\()https?://(?:www\.)?iwara\.tv/image/([a-zA-Z0-9]+)',
          caseSensitive: false),
      IwaraUrlType.profile: RegExp(
          r'(?<!\]\()https?://(?:www\.)?iwara\.tv/profile/([^/\s]+)',
          caseSensitive: false),
      IwaraUrlType.playlist: RegExp(
          r'(?<!\]\()https?://(?:www\.)?iwara\.tv/playlist/([a-zA-Z0-9-]+)',
          caseSensitive: false),
      IwaraUrlType.post: RegExp(
          r'(?<!\]\()https?://(?:www\.)?iwara\.tv/post/([a-zA-Z0-9-]+)',
          caseSensitive: false),
    };

    for (var entry in patterns.entries) {
      data = await _formatLinkType(data, entry.key, entry.value);
    }

    return data;
  }

  Future<String> _formatLinkType(
      String data, IwaraUrlType type, RegExp pattern) async {
    final matches = pattern.allMatches(data).toList();
    if (matches.isEmpty) return data;

    for (final match in matches) {
      if (!mounted || !_isProcessing) return data;

      final id = match.group(1)!;
      final originalUrl = match.group(0)!;

      final info = await _fetchInfo(type, id);
      final emoji = UrlUtils.getIwaraTypeEmoji(type);
      
      final replacement = info.isSuccess
          ? '[$emoji ${info.data}]($originalUrl)'
          : '[$emoji ${type.name.capitalize} $id]($originalUrl)';

      data = data.replaceAll(originalUrl, replacement);

      if (mounted && _isProcessing) {
        setState(() {
          _displayData = data;
        });
      }
    }

    return data;
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
    // 匹配URL，但不包括结尾的标点符号和括号，且排除已经是markdown格式的链接
    final linkPattern = RegExp(
      r'(?<!\]\()(?<!https?://(?:www\.)?iwara\.tv/)\b'
      r'(https?://[^\s<\)"]+?)' // 非贪婪匹配，排除结尾的)和"
      r'(?=[\s\)"<]|$)', // 正向前瞻确保URL边界正确
      caseSensitive: false,
    );

    String processed = data;

    // 处理所有URL
    processed = processed.replaceAllMapped(linkPattern, (match) {
      final url = match.group(1)!;
      final emoji = UrlUtils.getDomainEmoji(url);
      return '$emoji [$url]($url)';
    });

    // 确保链接后的文本正确换行
    processed = processed.replaceAll(RegExp(r'\)\s+(?=[a-zA-Z])'), ')\n');

    return processed;
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
              NaviService.navigateToForumThreadDetailPage(urlInfo.id!, urlInfo.secondaryId!);
            }
            break;
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
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;

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
                  // start
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _markdownGenerator.buildWidgets(
                    _showOriginal ? widget.data : _displayData,
                    config: config.copy(configs: [
                      LinkConfig(
                        onTap: _onTapLink,
                      ),
                      ImgConfig(
                        builder: (url, attributes) {
                          try {
                            final parsedUri = Uri.tryParse(url);
                            if (parsedUri == null ||
                                !parsedUri.hasAbsolutePath) {
                              throw FormatException(t.errors.invalidUrl);
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            );
                          } catch (e) {
                            LogUtils.e('图片加载失败',
                                tag: 'CustomMarkdownBody', error: e);
                            return const Icon(Icons.error);
                          }
                        },
                      ),
                    ]),
                  ),
                ),
              ),
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
                      style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _showOriginal = !_showOriginal;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
