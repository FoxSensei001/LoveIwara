import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/app/ui/widgets/translation_powered_by_widget.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:i_iwara/app/utils/markdown_formatter.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/app/ui/widgets/emoji_preview_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';

class CustomMarkdownBody extends StatefulWidget {
  final String data;
  final String? originalData; // 用于翻译的原始文本，如果为null则使用data
  final bool? initialShowUnprocessedText;
  final bool clickInternalLinkByUrlLaunch; // 当为true时，内部链接也使用urllaunch打开
  final bool showTranslationButton; // 是否显示翻译按钮
  final bool translationButtonAtTop; // 翻译按钮是否显示在正文上方
  final MarkdownTranslationController? translationController; // 外部控制器
  final EdgeInsetsGeometry padding; // 新增的 padding 参数
  final double? maxImageHeight; // 限制 Markdown 图片最大高度（null 表示不限制）
  final bool skipMarkdownProcessing; // 当内容已预处理时跳过本地格式化
  final bool showHorizontalRules; // 是否显示 markdown 中的 hr 分隔线
  final String Function(String url)? urlPreprocessor; // 页面级 markdown url 预处理
  // 点击文本中的时间节点（如 1:01）时的跳转回调；为 null 时不解析时间节点
  final void Function(Duration position)? onTimestampSeek;
  // 点击正文纯文本 / 段落空白处的回调（如评论区「点按任意处回复」）。
  // SelectionArea 自带 tap 识别器且在手势竞技场里赢过外层 InkWell（更深者
  // 胜），外面包点击层接不到；必须由这里在 SelectionArea 内侧接住再透传。
  // 链接 / 图片 / 时间节点等 span 级手势比这层更深，依旧优先。
  final VoidCallback? onTap;
  // 长按正文的回调（如评论区长按弹操作菜单）。同样挂在 SelectionArea 内侧，
  // 会取代其长按选中文本的默认行为——调用方应在菜单里提供「选择复制」入口。
  // 参数是长按落点的全局坐标：菜单要贴着手指弹（见 showCommentActionsMenu），
  // 拿不到落点就只能贴着整段正文弹，长评论下会离手指很远。
  final void Function(Offset globalPosition)? onLongPress;
  // 内容处理状态变化回调：本文与格式化结果有差异时为 true。post-frame 触发，
  // 调用方可安全 setState。
  //
  // 「显示原始文本」的开关不再由本组件自己画在正文下方——它一律由外层放进
  // 已有的动作栏 / 标题行，用 only-icon 的 `MarkdownOriginalTextToggle`
  // 呈现：本回调告诉外层「有没有可切换的差异」（决定那枚钮出不出现），
  // [initialShowUnprocessedText] 回来受控当前状态。
  final ValueChanged<bool>? onProcessedContentChanged;

  const CustomMarkdownBody({
    super.key,
    required this.data,
    this.originalData,
    this.initialShowUnprocessedText,
    this.clickInternalLinkByUrlLaunch = false,
    this.showTranslationButton = false,
    this.translationButtonAtTop = false,
    this.translationController,
    this.padding = EdgeInsets.zero, // 默认 padding 为 0
    this.maxImageHeight,
    this.skipMarkdownProcessing = false,
    this.showHorizontalRules = true,
    this.urlPreprocessor,
    this.onTimestampSeek,
    this.onTap,
    this.onLongPress,
    this.onProcessedContentChanged,
  });

  @override
  State<CustomMarkdownBody> createState() => _CustomMarkdownBodyState();
}

class _CustomMarkdownBodyState extends State<CustomMarkdownBody> {
  static const _normalImageFadeInDuration = Duration(milliseconds: 120);
  static const _normalImageResizeDuration = Duration(milliseconds: 180);
  String _displayData = '';
  bool _showOriginal = false;
  bool _hasProcessedContent = false;
  late final ConfigService _configService;
  final _markdownGenerator = MarkdownGenerator(
    linesMargin: const EdgeInsets.symmetric(vertical: 4),
  );
  final _markdownFormatter = MarkdownFormatter();

  // Records the current markdown's *rendered* non-emoji images, in order.
  // This lets the full-screen viewer swipe through previous/next images.
  List<_MarkdownNormalImageRecord> _lastRenderedNormalImages = const [];

  Map<String, String> get _iwaraImageHeaders => {
    'referer': Get.find<AppService>().currentSiteMode.baseUrl,
  };
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

    // 外部受控的「显示原始文本」开关（如全站公告卡片自己的动作行）
    if (oldWidget.initialShowUnprocessedText !=
            widget.initialShowUnprocessedText &&
        widget.initialShowUnprocessedText != null &&
        widget.initialShowUnprocessedText != _showOriginal) {
      setState(() {
        _showOriginal = widget.initialShowUnprocessedText!;
      });
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
      // 换行符 -> 硬换行（`  \n`）属于纯渲染层面的调整，原文与渲染结果
      // 视觉上基本一致，不应被视为“加工痕迹”，否则任何含换行的纯文本都会
      // 误触发“显示原始文本”按钮。因此这里不把它计入 hasChanges。
      final newProcessed = _markdownFormatter.replaceNewlines(processed);
      processed = newProcessed;
      if (!_isCurrentMarkdownTask(token)) return;
    } catch (e) {
      LogUtils.e('替换换行符时发生错误', error: e, tag: 'CustomMarkdownBody');
    }

    // 时间节点高亮：仅在提供跳转回调时启用，作为最后一步避免被链接格式化加前缀
    if (widget.onTimestampSeek != null) {
      try {
        final newProcessed = _markdownFormatter.formatTimestamps(processed);
        if (newProcessed != processed) hasChanges = true;
        processed = newProcessed;
        if (!_isCurrentMarkdownTask(token)) return;
      } catch (e) {
        LogUtils.e('格式化时间节点时发生错误', error: e, tag: 'CustomMarkdownBody');
      }
    }

    if (_isCurrentMarkdownTask(token) &&
        (_displayData != processed || _hasProcessedContent != hasChanges)) {
      setState(() {
        _displayData = processed;
        _hasProcessedContent = hasChanges;
      });
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
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () async => NaviService.navigateToAuthorProfilePage(urlInfo.id!),
        );
        return true;
      case IwaraUrlType.image:
        if (urlInfo.id == null) return false;
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () => NaviService.navigateToGalleryDetailPage(urlInfo.id!),
        );
        return true;
      case IwaraUrlType.video:
        if (urlInfo.id == null) return false;
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () => NaviService.navigateToVideoDetailPage(urlInfo.id!),
        );
        return true;
      case IwaraUrlType.playlist:
        if (urlInfo.id == null) return false;
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () async =>
              NaviService.navigateToPlayListDetail(urlInfo.id!, isMine: false),
        );
        return true;
      case IwaraUrlType.post:
        if (urlInfo.id == null) return false;
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () async => NaviService.navigateToPostDetailPage(urlInfo.id!, null),
        );
        return true;
      case IwaraUrlType.forum:
        if (urlInfo.id == null) return false;
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () async => NaviService.navigateToForumThreadListPage(urlInfo.id!),
        );
        return true;
      case IwaraUrlType.forumThread:
        if (urlInfo.id == null || urlInfo.secondaryId == null) return false;
        NaviService.navigateInSiteMode(
          urlInfo.site,
          () async => NaviService.navigateToForumThreadDetailPage(
            urlInfo.id!,
            urlInfo.secondaryId!,
          ),
        );
        return true;
      case IwaraUrlType.rule:
      case IwaraUrlType.unknown:
        return false;
    }
  }

  Future<bool> _confirmOpenExternalLink(String url) async {
    if (!mounted) return false;

    // Extract domain or IP from URL
    final uri = Uri.tryParse(url);
    final displayUrl = uri?.host ?? url;

    final shouldContinue = await showAppDialog<bool>(
      Builder(
        builder: (dialogContext) => GlassAlertDialog(
          title: t.common.externalLinkWarning,
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
            GlassDialogAction(
              label: t.common.cancelExternalLink,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            // 打开外链是这张弹窗里「有风险」的那一侧，走 destructive 语义色
            GlassDialogAction(
              label: t.common.continueToExternalLink,
              destructive: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ),
      dialogContext: context,
      barrierDismissible: false,
      useRootNavigator: false,
    );

    return shouldContinue == true;
  }

  void _showLinkOpenFailedToast(String href) {
    LogUtils.e('无法打开链接: $href', tag: 'CustomMarkdownBody');
    showAppToast(
      t.errors.errorWhileOpeningLink(link: href),
      type: AppToastType.error,
      position: AppToastPosition.top,
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

  Future<IwaraSite?> _pickSiteForRelativeIwaraLink(String url) async {
    if (!mounted) {
      return null;
    }

    final displayPath = url.trim();

    return showAppDialog<IwaraSite>(
      Builder(
        builder: (dialogContext) {
          final colorScheme = Theme.of(dialogContext).colorScheme;

          GlassDialogAction buildSiteButton(IwaraSite site) {
            final label = site == IwaraSite.ai
                ? t.siteMode.aiSite
                : t.siteMode.mainSite;

            return GlassDialogAction(
              label: t.siteMode.openInSite(site: label),
              onPressed: () => Navigator.of(dialogContext).pop(site),
            );
          }

          return GlassAlertDialog(
            title: t.siteMode.chooseLinkTargetTitle,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.siteMode.chooseLinkTargetDescription),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      displayPath,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.siteMode.chooseLinkTargetHint,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            actions: [
              GlassDialogAction(
                label: t.common.cancel,
                emphasized: false,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              buildSiteButton(IwaraSite.main),
              buildSiteButton(IwaraSite.ai),
            ],
          );
        },
      ),
      dialogContext: context,
      barrierDismissible: false,
      useRootNavigator: false,
    );
  }

  Future<String?> _resolveTapTargetUrl(String url) async {
    final normalizedUrl =
        widget.urlPreprocessor?.call(url.trim()) ?? url.trim();
    if (!UrlUtils.isRelativeIwaraPath(normalizedUrl)) {
      return normalizedUrl;
    }

    final selectedSite = await _pickSiteForRelativeIwaraLink(normalizedUrl);
    if (selectedSite == null) {
      return null;
    }

    return UrlUtils.resolveRelativeIwaraUrl(normalizedUrl, selectedSite);
  }

  void _onTapLink(String url) async {
    try {
      // 优先拦截时间节点跳转链接（如 iwaraseek://61）
      final trimmedUrl = url.trim();
      if (trimmedUrl.startsWith(MarkdownFormatter.timestampScheme)) {
        final secondsStr = trimmedUrl
            .substring(MarkdownFormatter.timestampScheme.length)
            .trim();
        final seconds = int.tryParse(secondsStr);
        if (seconds != null && widget.onTimestampSeek != null) {
          widget.onTimestampSeek!(Duration(seconds: seconds));
        }
        return;
      }

      final resolvedUrl = await _resolveTapTargetUrl(url);
      if (resolvedUrl == null || resolvedUrl.isEmpty) {
        return;
      }

      final resolvedUri = Uri.tryParse(resolvedUrl);
      if (resolvedUri == null) {
        _showLinkOpenFailedToast(resolvedUrl);
        return;
      }

      if (!widget.clickInternalLinkByUrlLaunch &&
          DeepLinkService.canHandleLink(resolvedUrl)) {
        Get.find<DeepLinkService>().processLink(resolvedUri);
        return;
      }

      final urlInfo = UrlUtils.parseUrl(resolvedUrl);

      if (!widget.clickInternalLinkByUrlLaunch &&
          urlInfo.isIwaraUrl &&
          _handleInternalIwaraLink(urlInfo)) {
        return;
      }

      if (!urlInfo.isIwaraUrl) {
        final shouldContinue = await _confirmOpenExternalLink(resolvedUrl);
        if (!shouldContinue) return;
      }

      await _launchUrlFromString(resolvedUrl);
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
              onTap: widget.onTap,
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
                  onTap: widget.onTap,
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
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
            ),
        ],
      ),
    );
  }

  ImageItem _buildImageItem(String normalizedUrl, {required String id}) {
    return ImageItem(
      url: normalizedUrl,
      data: ImageItemData(
        id: id,
        url: normalizedUrl,
        originalUrl: normalizedUrl,
      ),
      headers: _iwaraImageHeaders,
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
    Object? identity,
  ) {
    if (emojiSize != null) {
      EmojiPreviewDialog.show(context: context, emojiUrl: normalizedUrl);
      return;
    }

    // Prefer the rendered image list so the viewer can swipe across all images
    // in this markdown (order matches what's shown on screen).
    final records = _lastRenderedNormalImages;
    final hasRecords = records.isNotEmpty;

    int initialIndex = 0;
    if (hasRecords) {
      // 先按身份令牌对（同一个 URL 在一篇里出现多次时，只有它分得清点的是哪一张）；
      // 对不上再退回按 URL 找。
      initialIndex = records.indexWhere((r) => identical(r.identity, identity));
      if (initialIndex < 0) {
        initialIndex = records.indexWhere((r) => r.url == normalizedUrl);
      }
      if (initialIndex < 0) initialIndex = 0;
    }

    final imageItems = hasRecords
        ? records
              .asMap()
              .entries
              .map(
                (entry) => _buildImageItem(
                  entry.value.url,
                  id: 'markdown:${entry.key}',
                ),
              )
              .toList(growable: false)
        : [_buildImageItem(normalizedUrl, id: 'markdown:0')];

    pushPhotoViewWrapperOverlay(
      context: context,
      imageItems: imageItems,
      initialIndex: initialIndex,
      menuItemsBuilder: (_, imageItem) => _buildImageMenuItems(imageItem),
    );
  }

  Widget _buildEmojiImage(String normalizedUrl, EmojiSize emojiSize) {
    return Container(
      margin: emojiSize.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(emojiSize.borderRadius),
        child: CachedNetworkImage(
          imageUrl: normalizedUrl,
          httpHeaders: _iwaraImageHeaders,
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
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return ClipRRect(
      borderRadius: borderRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxImageHeight ?? double.infinity,
        ),
        child: AnimatedSize(
          duration: _normalImageResizeDuration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: CachedNetworkImage(
            imageUrl: normalizedUrl,
            httpHeaders: _iwaraImageHeaders,
            fadeInDuration: _normalImageFadeInDuration,
            placeholderFadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (context, url) => _DelayedMarkdownImagePlaceholder(
              height: normalImagePlaceholderHeight,
              borderRadius: borderRadius,
            ),
            errorWidget: (context, url, error) => Container(
              width: double.infinity,
              height: normalImagePlaceholderHeight,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: borderRadius,
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
      ),
    );
  }

  Widget _buildMarkdownImage(
    BuildContext context,
    String url,
    Map<String, String> attributes,
    double? maxImageHeight,
    double normalImagePlaceholderHeight,
    List<_MarkdownNormalImageRecord> normalImageRecords,
  ) {
    try {
      final preprocessedUrl =
          widget.urlPreprocessor?.call(url.trim()) ?? url.trim();
      final normalizedUrl = UrlUtils.upgradeIwaraHttpToHttps(preprocessedUrl);
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

      // 每张非表情图配一枚**身份令牌**。它曾经兼任 Hero 标签（图片飞进大图页），
      // Hero 已于 2026-09-05 整只移除，令牌留着还有用：一篇正文里同一个 URL 可能
      // 出现好几次，只有引用相等分得清用户点的是哪一张（见 [_handleMarkdownImageTap]）。
      final Object? identity = emojiSize == null ? Object() : null;

      // Keep a list of rendered non-emoji images so we can open a paged viewer.
      if (identity != null) {
        normalImageRecords.add(
          _MarkdownNormalImageRecord(url: normalizedUrl, identity: identity),
        );
      }

      return GestureDetector(
        onTap: () => _handleMarkdownImageTap(
          context,
          normalizedUrl,
          emojiSize,
          identity,
        ),
        child: MouseRegion(cursor: SystemMouseCursors.click, child: image),
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
    List<_MarkdownNormalImageRecord> normalImageRecords,
  ) {
    final baseConfig = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    final baseTable = baseConfig.table;

    return baseConfig.copy(
      configs: [
        widget.showHorizontalRules
            ? baseConfig.hr
            : const HrConfig(height: 0, color: Colors.transparent),
        // 当表格列较多、宽度超出屏幕时，包裹一层横向滚动以便查看被遮挡的列
        TableConfig(
          columnWidths: baseTable.columnWidths,
          defaultColumnWidth: baseTable.defaultColumnWidth,
          textDirection: baseTable.textDirection,
          border: baseTable.border,
          defaultVerticalAlignment: baseTable.defaultVerticalAlignment,
          textBaseline: baseTable.textBaseline,
          headerRowDecoration: baseTable.headerRowDecoration,
          bodyRowDecoration: baseTable.bodyRowDecoration,
          headerStyle: baseTable.headerStyle,
          bodyStyle: baseTable.bodyStyle,
          headPadding: baseTable.headPadding,
          bodyPadding: baseTable.bodyPadding,
          wrapper: (table) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        ),
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
            normalImageRecords,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(MarkdownConfig config) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _markdownGenerator.buildWidgets(
        _showOriginal ? widget.data : _displayData,
        config: config,
      ),
    );
    if (widget.onTap != null || widget.onLongPress != null) {
      // 必须挂在 SelectionArea 内侧（见 onTap / onLongPress 字段注释）
      // 长按走 GlassLongPressMenuArea：除了给出落点，它还会把这根按着的
      // 手指交给弹出来的菜单（按住不抬手直接划到某一条上松手即选中）。
      content = GlassLongPressMenuArea(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        onMenu: widget.onLongPress,
        child: content,
      );
    }
    return SelectionArea(child: content);
  }

  /// 翻译结果区的出现 / 消失过渡：淡入淡出 + 高度自顶部展开收起。
  /// [content] 为 null 表示隐藏；消失时旧内容会完整走一遍反向动画。
  Widget _animatedTranslationReveal(Widget? content) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      // 默认 layoutBuilder 会把新旧子项居中叠放，翻译块是顶部对齐的流式内容，
      // 过渡期间需按左上角锚定，否则收起时会从中间往两头缩
      layoutBuilder: (currentChild, previousChildren) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [...previousChildren, ?currentChild],
      ),
      child: content == null
          ? const SizedBox.shrink(key: ValueKey('translation-hidden'))
          : KeyedSubtree(
              key: const ValueKey('translation-visible'),
              child: content,
            ),
    );
  }

  Widget _buildTranslationSection(BuildContext context) {
    if (widget.translationController != null) {
      return Obx(() {
        final controller = widget.translationController!;
        final Widget? content = !controller.hasTranslation
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildTranslatedContent(
                    context,
                    customText: controller.translatedText.value,
                    isTranslating: controller.isTranslating.value,
                    isTranslationComplete:
                        controller.isTranslationComplete.value,
                  ),
                ],
              );
        return _animatedTranslationReveal(content);
      });
    }

    final Widget? content =
        widget.showTranslationButton && _translatedText != null
        ? Column(
            children: [
              const SizedBox(height: 8),
              _buildTranslatedContent(context),
            ],
          )
        : null;
    return _animatedTranslationReveal(content);
  }

  Widget _buildTranslationControls(BuildContext context) {
    if (!widget.showTranslationButton) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildTranslationButton(context)],
        ),
      ],
    );
  }

  /// 上次通知给外部的处理状态；build 里比对，变化才 post-frame 通知。
  bool? _lastNotifiedProcessed;

  void _notifyProcessedContent() {
    final cb = widget.onProcessedContentChanged;
    if (cb == null) return;
    final v = _hasProcessedContent;
    if (_lastNotifiedProcessed == v) return;
    _lastNotifiedProcessed = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) cb(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    _notifyProcessedContent();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxImageHeight = widget.maxImageHeight;
    final normalImagePlaceholderHeight = maxImageHeight != null
        ? maxImageHeight.clamp(120.0, 260.0).toDouble()
        : 200.0;

    // Collect the images rendered during this build (in order).
    final normalImageRecords = <_MarkdownNormalImageRecord>[];
    final config = _buildMarkdownConfig(
      context,
      isDark,
      maxImageHeight,
      normalImagePlaceholderHeight,
      normalImageRecords,
    );

    final markdownContent = _buildMarkdownContent(config);
    _lastRenderedNormalImages = normalImageRecords;

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.translationButtonAtTop) _buildTranslationControls(context),
          markdownContent,
          if (!widget.translationButtonAtTop)
            _buildTranslationControls(context),
          _buildTranslationSection(context),
        ],
      ),
    );
  }
}

class _MarkdownNormalImageRecord {
  final String url;

  /// 这一张在本次渲染里的身份令牌，见 [_MarkdownRenderer] 里造它的地方。
  final Object identity;

  const _MarkdownNormalImageRecord({required this.url, required this.identity});
}

class _DelayedMarkdownImagePlaceholder extends StatefulWidget {
  static const _delay = Duration(milliseconds: 120);

  final double height;
  final BorderRadius borderRadius;

  const _DelayedMarkdownImagePlaceholder({
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_DelayedMarkdownImagePlaceholder> createState() =>
      _DelayedMarkdownImagePlaceholderState();
}

class _DelayedMarkdownImagePlaceholderState
    extends State<_DelayedMarkdownImagePlaceholder> {
  Timer? _timer;
  bool _showShimmer = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_DelayedMarkdownImagePlaceholder._delay, () {
      if (!mounted) return;
      setState(() {
        _showShimmer = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showShimmer) {
      return SizedBox(width: double.infinity, height: widget.height);
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}
