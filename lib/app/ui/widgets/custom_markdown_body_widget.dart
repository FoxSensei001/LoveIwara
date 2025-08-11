import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/app/ui/widgets/translation_powered_by_widget.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:i_iwara/app/utils/markdown_formatter.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/app/ui/widgets/emoji_preview_dialog.dart';
import 'package:i_iwara/common/constants.dart';

class CustomMarkdownBody extends StatefulWidget {
  final String data;
  final String? originalData; // 用于翻译的原始文本，如果为null则使用data
  final bool? initialShowUnprocessedText;
  final bool clickInternalLinkByUrlLaunch; // 当为true时，内部链接也使用urllaunch打开
  final bool showTranslationButton; // 是否显示翻译按钮
  final MarkdownTranslationController? translationController; // 外部控制器
  final EdgeInsetsGeometry padding; // 新增的 padding 参数

  const CustomMarkdownBody({
    super.key,
    required this.data,
    this.originalData,
    this.initialShowUnprocessedText,
    this.clickInternalLinkByUrlLaunch = false,
    this.showTranslationButton = false,
    this.translationController,
    this.padding = EdgeInsets.zero, // 默认 padding 为 0
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
  final _markdownFormatter = MarkdownFormatter();

  // 内部翻译相关状态
  bool _isTranslating = false;
  String? _translatedText;
  String? _rawTranslatedText; // 存储未格式化的翻译文本
  bool _isTranslationComplete = false; // 标记翻译是否完成
  late final TranslationService _translationService;
  StreamSubscription<String>? _translationStreamSubscription;

  @override
  void dispose() {
    _isProcessing = false;
    _translationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    if (widget.showTranslationButton) {
      _translationService = Get.find<TranslationService>();
    }
    _displayData = widget.data;
    _showOriginal = widget.initialShowUnprocessedText ??
        _configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    _processMarkdown(widget.data);

    // 如果提供了外部控制器，监听其变化
    if (widget.translationController != null) {
      widget.translationController!.translatedText.listen((translatedText) {
        // 不需要setState，因为我们在build中使用Obx
      });
    }
  }

  @override
  void didUpdateWidget(CustomMarkdownBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.originalData != widget.originalData) {
      if (mounted) {
        setState(() {
          _displayData = widget.data;
          _translatedText = null; // 当内容变化时清除翻译结果
        });
      }
      _processMarkdown(widget.data);

      // 如果控制器发生变化或内容变化时有控制器，清除控制器中的翻译结果
      if (widget.translationController != null) {
        widget.translationController!.clearTranslation();
      }
    }
  }

  Future<void> _processMarkdown(String data) async {
    if (!mounted) return;
    _isProcessing = true;
    String processed = data;
    bool hasChanges = false;

    try {
      String newProcessed = await _markdownFormatter.formatLinks(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (!mounted || !_isProcessing) return;
    } catch (e) {
      LogUtils.e('格式化链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      String newProcessed = _markdownFormatter.formatMarkdownLinks(processed);
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
      String newProcessed = _markdownFormatter.formatMentions(processed);
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
      String newProcessed = _markdownFormatter.replaceNewlines(processed);
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

  // 处理翻译
  Future<void> _handleTranslation() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
      _isTranslationComplete = false;
      _rawTranslatedText = null;
      _translatedText = null;
    });

    // 取消之前的流订阅
    await _translationStreamSubscription?.cancel();
    _translationStreamSubscription = null;

    // 获取用于翻译的原始文本
    final textToTranslate = widget.originalData ?? widget.data;

    // 尝试使用流式翻译
    final stream = _translationService.translateStream(textToTranslate);
    if (stream != null) {
      _translationStreamSubscription = stream.listen((translatedText) {
        if (mounted) {
          setState(() {
            // 在翻译过程中只更新原始文本，不进行格式化
            _rawTranslatedText = translatedText;
            if (!_isTranslationComplete) {
              _translatedText = _rawTranslatedText;
            }
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            _rawTranslatedText = t.common.translateFailedPleaseTryAgainLater;
            _translatedText = _rawTranslatedText;
            _isTranslating = false;
            _isTranslationComplete = true;
          });
        }
      }, onDone: () {
        if (mounted) {
          // 翻译完成后，先标记翻译完成，再进行格式化处理
          setState(() {
            _isTranslationComplete = true;
            // 保持翻译中状态，但显示翻译已完成
            _translatedText = _rawTranslatedText;
          });
          
          // 在后台进行格式化处理
          _processTranslatedText();
        }
      });
      return;
    }

    // 如果流式翻译不可用或被禁用，使用普通翻译
    final result = await _translationService.translate(textToTranslate);
    if (result.isSuccess && mounted) {
      setState(() {
        _rawTranslatedText = result.data;
        _translatedText = _rawTranslatedText;
        _isTranslationComplete = true;
      });
      // 翻译完成后，进行格式化处理
      _processTranslatedText();
    } else if (mounted) {
      setState(() {
        _rawTranslatedText = t.common.translateFailedPleaseTryAgainLater;
        _translatedText = _rawTranslatedText;
        _isTranslating = false;
        _isTranslationComplete = true;
      });
    }
  }

  // 处理翻译文本的格式化
  Future<void> _processTranslatedText() async {
    if (_rawTranslatedText == null || 
        _rawTranslatedText == t.common.translateFailedPleaseTryAgainLater) {
      setState(() {
        _isTranslating = false;
      });
      return;
    }

    try {
      final processed = await _markdownFormatter.processTranslatedText(_rawTranslatedText!);
      
      if (mounted) {
        setState(() {
          _translatedText = processed;
          _isTranslating = false;
        });
      }
    } catch (e) {
      LogUtils.e('格式化翻译文本时发生错误', error: e, tag: 'CustomMarkdownBody');
      if (mounted) {
        setState(() {
          _translatedText = _rawTranslatedText;
          _isTranslating = false;
        });
      }
    }
  }

  /// 判断是否为表情包图片，并获取表情包规格
  /// 
  /// 识别规则：
  /// 1. alt文本为"emo"（标准格式，默认中等大小）
  /// 2. alt文本为"emo:text-i"、"emo:mid-i"、"emo:large-i"（指定大小）
  /// 3. alt文本包含"emoji"、"表情"、"贴图"、"sticker"、"emoticon"等关键词
  /// 
  /// 返回值：如果是表情包返回对应的EmojiSize，否则返回null
  EmojiSize? _getEmojiSize(String url, Map<String, String> attributes) {
    final altText = attributes['alt'] ?? '';
    
    // 检查是否为标准表情格式
    if (altText == 'emo') {
      return EmojiSize.medium; // 默认中等大小
    }
    
    // 检查是否为指定大小的表情格式
    if (altText.startsWith('emo:')) {
      final suffix = altText.substring(4); // 去掉"emo:"
      final size = EmojiSize.fromAltSuffix(suffix);
      if (size != null) {
        return size;
      }
      // 如果不是有效的规格，回退到默认中等大小
      return EmojiSize.medium;
    }
    
    return null;
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

  // 构建翻译按钮
  Widget _buildTranslationButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _isTranslating ? null : () => _handleTranslation(),
          icon: _isTranslating
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.translate,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        // 不设置间隙，紧靠着放置
        TranslationLanguageSelector(
          compact: true,
          extrimCompact: true,
          selectedLanguage: _configService.currentTranslationSort,
          onLanguageSelected: (sort) {
            _configService.updateTranslationLanguage(sort);
            if (_translatedText != null) {
              _handleTranslation();
            }
          },
        ),
      ],
    );
  }

  // 构建翻译结果内容
  Widget _buildTranslatedContent(BuildContext context, {String? customText}) {
    final translatedText = customText ?? _translatedText;
    if (translatedText == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, size: 14),
              const SizedBox(width: 4),
              Text(
                t.common.translationResult,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_isTranslating && _isTranslationComplete)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.common.loading,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              translationPoweredByWidget(context, fontSize: 10)
            ],
          ),
          const SizedBox(height: 8),
          if (translatedText == t.common.translateFailedPleaseTryAgainLater)
            SelectableText(
              translatedText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            )
          else if (!_isTranslationComplete && _isTranslating)
            // 翻译中显示纯文本，不使用Markdown渲染
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isTranslating)
                  LinearProgressIndicator(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 8),
                SelectableText(
                  translatedText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            )
          else
            // 翻译完成后使用Markdown渲染
            CustomMarkdownBody(
              data: translatedText,
              showTranslationButton: false,
            ),
        ],
      ),
    );
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
            
            // 判断是否为表情包并获取规格
            final emojiSize = _getEmojiSize(url, attributes);
            final isEmoji = emojiSize != null;
            
            return GestureDetector(
              onTap: () {
                if (isEmoji) {
                  // 表情包点击时显示预览弹窗
                  EmojiPreviewDialog.show(
                    context: context,
                    emojiUrl: url,
                  );
                } else {
                  // 普通图片进入图片详情页
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
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: isEmoji 
                  ? Container(
                      // 表情包使用动态布局
                      margin: emojiSize!.margin,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(emojiSize.borderRadius),
                        child: CachedNetworkImage(
                          imageUrl: url,
                           httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                          placeholder: (context, url) => Container(
                            width: emojiSize.displaySize,
                            height: emojiSize.displaySize,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(emojiSize.borderRadius),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: emojiSize.displaySize * 0.4,
                                height: emojiSize.displaySize * 0.4,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: emojiSize.displaySize,
                            height: emojiSize.displaySize,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(emojiSize.borderRadius),
                            ),
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: emojiSize.displaySize * 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          fit: BoxFit.contain,
                          width: emojiSize.displaySize,
                          height: emojiSize.displaySize,
                        ),
                      ),
                    )
                  : ClipRRect(
                      // 普通图片保持原有样式
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
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
                                t.errors.error,
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
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Markdown内容
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

              // 原始文本显示切换 - 移动到这里，紧跟在Markdown内容之后
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

              // 处理翻译结果显示
              // 1. 如果使用外部控制器，监听控制器状态
              if (widget.translationController != null) ...[
                Obx(() {
                  final controller = widget.translationController!;
                  if (controller.hasTranslation) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (controller.isTranslating.value && !controller.isTranslationComplete.value)
                          // 翻译中显示纯文本，不使用Markdown渲染
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.translate, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      t.common.translationResult,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const Spacer(),
                                    translationPoweredByWidget(context, fontSize: 10)
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.translatedText.value ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _buildTranslatedContent(context,
                              customText: controller.translatedText.value),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ]
              // 2. 如果使用内部翻译功能
              else if (widget.showTranslationButton) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTranslationButton(context),
                  ],
                ),
                if (_translatedText != null) ...[
                  const SizedBox(height: 8),
                  _buildTranslatedContent(context),
                ],
              ],

            ],
          ),
        );
      },
    );
  }
}
