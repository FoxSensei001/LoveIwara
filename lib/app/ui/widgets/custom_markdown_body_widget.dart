import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
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
import 'dart:async';
import 'package:i_iwara/app/utils/markdown_formatter.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/app/ui/widgets/emoji_preview_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class CustomMarkdownBody extends StatefulWidget {
  final String data;
  final String? originalData; // 用于翻译的原始文本，如果为null则使用data
  final bool? initialShowUnprocessedText;
  final bool clickInternalLinkByUrlLaunch; // 当为true时，内部链接也使用urllaunch打开
  final bool showTranslationButton; // 是否显示翻译按钮
  final MarkdownTranslationController? translationController; // 外部控制器
  final EdgeInsetsGeometry padding; // 新增的 padding 参数
  final double? maxImageHeight; // 限制 Markdown 图片最大高度（null 表示不限制）
  final bool skipMarkdownProcessing; // 当内容已预处理时跳过本地格式化

  const CustomMarkdownBody({
    super.key,
    required this.data,
    this.originalData,
    this.initialShowUnprocessedText,
    this.clickInternalLinkByUrlLaunch = false,
    this.showTranslationButton = false,
    this.translationController,
    this.padding = EdgeInsets.zero, // 默认 padding 为 0
    this.maxImageHeight,
    this.skipMarkdownProcessing = false,
  });

  @override
  State<CustomMarkdownBody> createState() => _CustomMarkdownBodyState();
}

class _CustomMarkdownBodyState extends State<CustomMarkdownBody> {
  String _displayData = '';
  bool _showOriginal = false;
  bool _hasProcessedContent = false;
  late final ConfigService _configService;
  final _markdownGenerator = MarkdownGenerator(
    linesMargin: const EdgeInsets.symmetric(vertical: 4),
  );
  final _markdownFormatter = MarkdownFormatter();
  int _markdownProcessToken = 0;
  int _translationProcessToken = 0;

  // 内部翻译相关状态
  bool _isTranslating = false;
  String? _translatedText;
  String? _rawTranslatedText; // 存储未格式化的翻译文本
  bool _isTranslationComplete = false; // 标记翻译是否完成
  TranslationService? _translationService;
  StreamSubscription<String>? _translationStreamSubscription;

  TranslationService get _resolvedTranslationService {
    return _translationService ??= Get.find<TranslationService>();
  }

  @override
  void dispose() {
    _markdownProcessToken++;
    _translationProcessToken++;
    _translationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    if (widget.showTranslationButton) {
      _resolvedTranslationService;
    }
    _displayData = widget.data;
    _showOriginal =
        widget.initialShowUnprocessedText ??
        _configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    if (widget.skipMarkdownProcessing) {
      _hasProcessedContent = false;
    } else {
      _processMarkdown(widget.data);
    }
  }

  @override
  void didUpdateWidget(CustomMarkdownBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showTranslationButton && widget.showTranslationButton) {
      _resolvedTranslationService;
    }

    if (oldWidget.data != widget.data ||
        oldWidget.originalData != widget.originalData) {
      _translationProcessToken++;
      _translationStreamSubscription?.cancel();
      _translationStreamSubscription = null;
      if (mounted) {
        setState(() {
          _displayData = widget.data;
          _translatedText = null; // 当内容变化时清除翻译结果
          _rawTranslatedText = null;
          _isTranslating = false;
          _isTranslationComplete = false;
          _hasProcessedContent = false;
        });
      }
      if (!widget.skipMarkdownProcessing) {
        _processMarkdown(widget.data);
      }

      // 如果控制器发生变化或内容变化时有控制器，清除控制器中的翻译结果
      if (widget.translationController != null) {
        widget.translationController!.clearTranslation();
      }
    }
  }

  bool _isCurrentMarkdownTask(int token) {
    return mounted && token == _markdownProcessToken;
  }

  bool _isCurrentTranslationTask(int token) {
    return mounted && token == _translationProcessToken;
  }

  Future<void> _processMarkdown(String data) async {
    final token = ++_markdownProcessToken;
    String processed = data;
    bool hasChanges = false;

    try {
      final newProcessed = await _markdownFormatter.formatLinks(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (!_isCurrentMarkdownTask(token)) return;
    } catch (e) {
      LogUtils.e('格式化链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      final newProcessed = _markdownFormatter.formatMarkdownLinks(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (!_isCurrentMarkdownTask(token)) return;
    } catch (e) {
      LogUtils.e('格式化 Markdown 链接时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      final newProcessed = _markdownFormatter.formatMentions(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (!_isCurrentMarkdownTask(token)) return;
    } catch (e) {
      LogUtils.e('格式化提及时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    try {
      final newProcessed = _markdownFormatter.replaceNewlines(processed);
      if (newProcessed != processed) hasChanges = true;
      processed = newProcessed;
      if (_isCurrentMarkdownTask(token) &&
          (_displayData != processed || _hasProcessedContent != hasChanges)) {
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
    final token = ++_translationProcessToken;

    if (_isCurrentTranslationTask(token)) {
      setState(() {
        _isTranslating = true;
        _isTranslationComplete = false;
        _rawTranslatedText = null;
        _translatedText = null;
      });
    }

    // 取消之前的流订阅
    await _translationStreamSubscription?.cancel();
    _translationStreamSubscription = null;

    // 获取用于翻译的原始文本
    final textToTranslate = widget.originalData ?? widget.data;

    // 尝试使用流式翻译
    final stream = _resolvedTranslationService.translateStream(textToTranslate);
    if (stream != null) {
      _translationStreamSubscription = stream.listen(
        (translatedText) {
          if (_isCurrentTranslationTask(token)) {
            setState(() {
              // 在翻译过程中只更新原始文本，不进行格式化
              _rawTranslatedText = translatedText;
              if (!_isTranslationComplete) {
                _translatedText = _rawTranslatedText;
              }
            });
          }
        },
        onError: (error) {
          if (_isCurrentTranslationTask(token)) {
            setState(() {
              _rawTranslatedText = t.common.translateFailedPleaseTryAgainLater;
              _translatedText = _rawTranslatedText;
              _isTranslating = false;
              _isTranslationComplete = true;
            });
          }
        },
        onDone: () {
          if (_isCurrentTranslationTask(token)) {
            // 翻译完成后，先标记翻译完成，再进行格式化处理
            setState(() {
              _isTranslationComplete = true;
              // 保持翻译中状态，但显示翻译已完成
              _translatedText = _rawTranslatedText;
            });

            // 在后台进行格式化处理
            _processTranslatedText(token);
          }
        },
      );
      return;
    }

    // 如果流式翻译不可用或被禁用，使用普通翻译
    final result = await _resolvedTranslationService.translate(textToTranslate);
    if (!_isCurrentTranslationTask(token)) return;

    if (result.isSuccess) {
      setState(() {
        _rawTranslatedText = result.data;
        _translatedText = _rawTranslatedText;
        _isTranslationComplete = true;
      });
      // 翻译完成后，进行格式化处理
      _processTranslatedText(token);
    } else {
      setState(() {
        _rawTranslatedText = t.common.translateFailedPleaseTryAgainLater;
        _translatedText = _rawTranslatedText;
        _isTranslating = false;
        _isTranslationComplete = true;
      });
    }
  }

  // 处理翻译文本的格式化
  Future<void> _processTranslatedText(int token) async {
    if (!_isCurrentTranslationTask(token)) return;
    if (_rawTranslatedText == null ||
        _rawTranslatedText == t.common.translateFailedPleaseTryAgainLater) {
      setState(() {
        _isTranslating = false;
      });
      return;
    }

    try {
      final processed = await _markdownFormatter.processTranslatedText(
        _rawTranslatedText!,
      );

      if (_isCurrentTranslationTask(token)) {
        setState(() {
          _translatedText = processed;
          _isTranslating = false;
        });
      }
    } catch (e) {
      LogUtils.e('格式化翻译文本时发生错误', error: e, tag: 'CustomMarkdownBody');
      if (_isCurrentTranslationTask(token)) {
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
  EmojiSize? _getEmojiSize(Map<String, String> attributes) {
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

  bool _handleInternalIwaraLink(IwaraUrlInfo urlInfo) {
    switch (urlInfo.type) {
      case IwaraUrlType.profile:
        if (urlInfo.id == null) return false;
        NaviService.navigateToAuthorProfilePage(urlInfo.id!);
        return true;
      case IwaraUrlType.image:
        if (urlInfo.id == null) return false;
        NaviService.navigateToGalleryDetailPage(urlInfo.id!);
        return true;
      case IwaraUrlType.video:
        if (urlInfo.id == null) return false;
        NaviService.navigateToVideoDetailPage(urlInfo.id!);
        return true;
      case IwaraUrlType.playlist:
        if (urlInfo.id == null) return false;
        NaviService.navigateToPlayListDetail(urlInfo.id!, isMine: false);
        return true;
      case IwaraUrlType.post:
        if (urlInfo.id == null) return false;
        NaviService.navigateToPostDetailPage(urlInfo.id!, null);
        return true;
      case IwaraUrlType.forum:
        if (urlInfo.id == null) return false;
        NaviService.navigateToForumThreadListPage(urlInfo.id!);
        return true;
      case IwaraUrlType.forumThread:
        if (urlInfo.id == null || urlInfo.secondaryId == null) return false;
        NaviService.navigateToForumThreadDetailPage(
          urlInfo.id!,
          urlInfo.secondaryId!,
        );
        return true;
      case IwaraUrlType.rule:
      case IwaraUrlType.unknown:
        return false;
    }
  }

  Future<bool> _confirmOpenExternalLink(String url) async {
    // Extract domain or IP from URL
    final uri = Uri.tryParse(url);
    final displayUrl = uri?.host ?? url;

    final shouldContinue = await showAppDialog<bool>(
      Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(t.common.externalLinkWarning),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.common.externalLinkWarningMessage),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      dialogContext,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 20,
                        color: Theme.of(dialogContext).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayUrl,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(dialogContext).colorScheme.primary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.primary,
              ),
              child: Text(
                t.common.cancelExternalLink,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(t.common.continueToExternalLink),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    return shouldContinue == true;
  }

  void _showLinkOpenFailedToast(String href) {
    LogUtils.e('无法打开链接: $href', tag: 'CustomMarkdownBody');
    showToastWidget(
      MDToastWidget(
        message: t.errors.errorWhileOpeningLink(link: href),
        type: MDToastType.error,
      ),
      position: ToastPosition.top,
    );
  }

  Future<void> _launchUrlFromString(String href) async {
    final uri = Uri.tryParse(href);
    if (uri == null) {
      _showLinkOpenFailedToast(href);
      return;
    }
    await _launchUrl(uri, href);
  }

  void _onTapLink(String url) async {
    try {
      final urlInfo = UrlUtils.parseUrl(url);

      if (!widget.clickInternalLinkByUrlLaunch &&
          urlInfo.isIwaraUrl &&
          _handleInternalIwaraLink(urlInfo)) {
        return;
      }

      if (!urlInfo.isIwaraUrl) {
        final shouldContinue = await _confirmOpenExternalLink(url);
        if (!shouldContinue) return;
      }

      await _launchUrlFromString(url);
    } catch (e) {
      LogUtils.e('处理链接点击时发生错误', tag: 'CustomMarkdownBody', error: e);
      _showLinkOpenFailedToast(url);
    }
  }

  Future<void> _launchUrl(Uri uri, String href) async {
    try {
      final didLaunch = await launchUrl(uri);
      if (!didLaunch) {
        _showLinkOpenFailedToast(href);
      }
    } catch (e) {
      LogUtils.e('打开链接时发生错误: $href', tag: 'CustomMarkdownBody', error: e);
      _showLinkOpenFailedToast(href);
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
  Widget _buildTranslatedContent(
    BuildContext context, {
    String? customText,
    bool? isTranslating,
    bool? isTranslationComplete,
  }) {
    final translatedText = customText ?? _translatedText;
    if (translatedText == null) return const SizedBox.shrink();
    final effectiveIsTranslating = isTranslating ?? _isTranslating;
    final effectiveIsTranslationComplete =
        isTranslationComplete ?? _isTranslationComplete;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
              if (effectiveIsTranslating && effectiveIsTranslationComplete)
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
              translationPoweredByWidget(context, fontSize: 10),
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
          else if (!effectiveIsTranslationComplete && effectiveIsTranslating)
            // 翻译中显示纯文本，不使用Markdown渲染
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (effectiveIsTranslating)
                  LinearProgressIndicator(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
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
              skipMarkdownProcessing: true,
              clickInternalLinkByUrlLaunch: widget.clickInternalLinkByUrlLaunch,
              maxImageHeight: widget.maxImageHeight,
            ),
        ],
      ),
    );
  }

  ImageItem _buildImageItem(String normalizedUrl) {
    return ImageItem(
      url: normalizedUrl,
      data: ImageItemData(
        id: '',
        url: normalizedUrl,
        originalUrl: normalizedUrl,
      ),
    );
  }

  List<MenuItem> _buildImageMenuItems(ImageItem item) {
    return [
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
      if (GetPlatform.isDesktop)
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
  }

  void _handleMarkdownImageTap(
    BuildContext context,
    String normalizedUrl,
    EmojiSize? emojiSize,
    Object? heroTag,
  ) {
    if (emojiSize != null) {
      EmojiPreviewDialog.show(context: context, emojiUrl: normalizedUrl);
      return;
    }

    final item = _buildImageItem(normalizedUrl);
    pushPhotoViewWrapperOverlay(
      context: context,
      imageItems: [item],
      initialIndex: 0,
      menuItemsBuilder: (_, imageItem) => _buildImageMenuItems(imageItem),
      heroTagBuilder: heroTag == null ? null : (_) => heroTag,
    );
  }

  Widget _buildEmojiImage(String normalizedUrl, EmojiSize emojiSize) {
    return Container(
      margin: emojiSize.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(emojiSize.borderRadius),
        child: CachedNetworkImage(
          imageUrl: normalizedUrl,
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
                child: const CircularProgressIndicator(strokeWidth: 2),
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
    );
  }

  Widget _buildNormalImage(
    String normalizedUrl,
    double? maxImageHeight,
    double normalImagePlaceholderHeight,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxImageHeight ?? double.infinity,
        ),
        child: CachedNetworkImage(
          imageUrl: normalizedUrl,
          httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: normalImagePlaceholderHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: double.infinity,
            height: normalImagePlaceholderHeight,
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          fit: maxImageHeight == null ? BoxFit.cover : BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildMarkdownImage(
    BuildContext context,
    String url,
    Map<String, String> attributes,
    double? maxImageHeight,
    double normalImagePlaceholderHeight,
  ) {
    try {
      final normalizedUrl = UrlUtils.upgradeIwaraHttpToHttps(url);
      final parsedUri = Uri.tryParse(normalizedUrl);
      if (parsedUri == null || !parsedUri.hasAbsolutePath) {
        throw FormatException(t.errors.invalidUrl);
      }

      final emojiSize = _getEmojiSize(attributes);
      final image = emojiSize != null
          ? _buildEmojiImage(normalizedUrl, emojiSize)
          : _buildNormalImage(
              normalizedUrl,
              maxImageHeight,
              normalImagePlaceholderHeight,
            );

      final Object? heroTag = emojiSize == null ? Object() : null;
      final imageWithOptionalHero = heroTag == null
          ? image
          : Hero(tag: heroTag, child: image);

      return GestureDetector(
        onTap: () =>
            _handleMarkdownImageTap(context, normalizedUrl, emojiSize, heroTag),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: imageWithOptionalHero,
        ),
      );
    } catch (e) {
      LogUtils.e('图片加载失败', tag: 'CustomMarkdownBody', error: e);
      return const Icon(Icons.error);
    }
  }

  MarkdownConfig _buildMarkdownConfig(
    BuildContext context,
    bool isDark,
    double? maxImageHeight,
    double normalImagePlaceholderHeight,
  ) {
    return (isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig)
        .copy(
          configs: [
            LinkConfig(
              onTap: _onTapLink,
              style: TextStyle(
                decoration: TextDecoration.none, // 移除下划线
                color: isDark ? Colors.blue[300] : Colors.blue, // 保持链接颜色
              ),
            ),
            ImgConfig(
              builder: (url, attributes) => _buildMarkdownImage(
                context,
                url,
                attributes,
                maxImageHeight,
                normalImagePlaceholderHeight,
              ),
            ),
          ],
        );
  }

  Widget _buildMarkdownContent(MarkdownConfig config) {
    return SelectionArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _markdownGenerator.buildWidgets(
          _showOriginal ? widget.data : _displayData,
          config: config,
        ),
      ),
    );
  }

  Widget _buildProcessedTextToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
        icon: Icon(
          _showOriginal ? Icons.format_paint : Icons.format_paint_outlined,
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
    );
  }

  Widget _buildTranslationSection(BuildContext context) {
    if (widget.translationController != null) {
      return Obx(() {
        final controller = widget.translationController!;
        if (!controller.hasTranslation) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildTranslatedContent(
              context,
              customText: controller.translatedText.value,
              isTranslating: controller.isTranslating.value,
              isTranslationComplete: controller.isTranslationComplete.value,
            ),
          ],
        );
      });
    }

    if (widget.showTranslationButton) {
      return Column(
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildTranslationButton(context)],
          ),
          if (_translatedText != null) ...[
            const SizedBox(height: 8),
            _buildTranslatedContent(context),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxImageHeight = widget.maxImageHeight;
    final normalImagePlaceholderHeight = maxImageHeight != null
        ? maxImageHeight.clamp(120.0, 260.0).toDouble()
        : 200.0;
    final config = _buildMarkdownConfig(
      context,
      isDark,
      maxImageHeight,
      normalImagePlaceholderHeight,
    );

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMarkdownContent(config),
          if (_hasProcessedContent) ...[
            const SizedBox(height: 8),
            _buildProcessedTextToggle(),
          ],
          _buildTranslationSection(context),
        ],
      ),
    );
  }
}
