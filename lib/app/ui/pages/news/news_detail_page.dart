import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/iwara_news_service.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart'
    show CommonErrorWidget;
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key, this.postId, this.postUrl, this.previewData})
    : assert(postId != null || postUrl != null || previewData != null);

  final int? postId;
  final String? postUrl;
  final NewsDetailExtra? previewData;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final IwaraNewsService _newsService = Get.find<IwaraNewsService>();

  IwaraNewsDetail? _detail;
  String? _error;
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _reload() async {
    await _fetchDetail(forceRefresh: true);
  }

  Future<void> _switchLanguage(String url) async {
    await _fetchDetail(overrideUrl: url);
  }

  Future<void> _fetchDetail({
    bool forceRefresh = false,
    String? overrideUrl,
  }) async {
    final hadContent = _detail != null || widget.previewData != null;
    setState(() {
      _isLoading = true;
      if (!hadContent || forceRefresh) {
        _error = null;
      }
    });

    try {
      final detail = await _loadDetail(overrideUrl: overrideUrl);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _error = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = CommonUtils.parseExceptionMessage(error);
        _isLoading = false;
      });
    }
  }

  Future<IwaraNewsDetail> _loadDetail({String? overrideUrl}) {
    final targetUrl =
        overrideUrl ?? widget.postUrl ?? widget.previewData?.postUrl;
    if (targetUrl != null && targetUrl.isNotEmpty) {
      return _newsService.fetchPostDetailByUrl(targetUrl);
    }
    final targetPostId = widget.postId ?? widget.previewData?.postId;
    return _newsService.fetchPostDetail(targetPostId!);
  }

  Future<void> _openInBrowser(String url) async {
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        showGlassToast(
          slang.t.news.openInBrowser,
          type: GlassToastType.warning,
        );
      }
    } catch (error) {
      if (!mounted) return;
      showGlassToast(
        CommonUtils.parseExceptionMessage(error),
        type: GlassToastType.error,
      );
    }
  }

  String _languageLabel(IwaraNewsLanguage language) {
    switch (language) {
      case IwaraNewsLanguage.en:
        return 'English';
      case IwaraNewsLanguage.ja:
        return '日本語';
      case IwaraNewsLanguage.zh:
        return '简体中文';
    }
  }

  String _normalizeNewsMarkdownUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return '${CommonConstants.iwaraNewsBaseUrl}$trimmed';
    }

    return trimmed;
  }

  /// header 标题：有正文 / 预览用真实标题，出错 / 空态用兜底标题，
  /// 首次加载给 null 显示 shimmer 占位。
  String? _resolveHeaderTitle(slang.Translations t) {
    final detailTitle = _detail?.title;
    if (detailTitle != null && detailTitle.isNotEmpty) return detailTitle;
    final previewTitle = widget.previewData?.title;
    if (previewTitle != null && previewTitle.isNotEmpty) {
      return previewTitle;
    }
    if (_error != null || !_isLoading) return t.news.title;
    return null;
  }

  /// 钉在顶部的玻璃 header 行：返回圆钮 / 标题胶囊 / 动作胶囊。
  Widget _buildHeader(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.arrow_back),
            tooltip: t.common.back,
            onPressed: () => AppService.tryPop(),
          ),
          const SizedBox(width: 8),
          // 标题胶囊：点按/长按弹出完整标题弹窗（长标题被截断时的出口）
          Expanded(child: GlassTitlePill(title: _resolveHeaderTitle(t))),
          const SizedBox(width: 8),
          _buildActionGroup(context),
        ],
      ),
    );
  }

  /// 右侧动作胶囊：浏览器打开 · 语言切换 · 刷新。
  ///
  /// 浏览器打开 / 语言切换要等正文就绪，用 [GlassGroupSlot] 随加载完成
  /// 「挤进」胶囊；刷新键走 [GlassIconButton.loading] 的沙漏反馈。
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    final detail = _detail;
    return GlassButtonGroup(
      children: [
        GlassGroupSlot(
          visible: detail != null,
          child: GlassIconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: t.news.openInBrowser,
            onPressed: detail == null
                ? null
                : () => _openInBrowser(detail.link),
          ),
        ),
        GlassGroupSlot(
          visible: detail != null && detail.translationLinks.length > 1,
          // child 是急切求值的，detail 未就绪时放一个同尺寸占位
          child: detail == null
              ? const SizedBox(
                  width: GlassTokens.groupIconButtonSize,
                  height: GlassTokens.groupIconButtonSize,
                )
              : _NewsDetailLanguageButton(
                  languages: detail.translationLinks,
                  currentLanguage: detail.language,
                  languageLabelBuilder: _languageLabel,
                  onSelected: (language) async {
                    if (language == detail.language) return;
                    final url = detail.translationLinks[language];
                    if (url != null && url.isNotEmpty) {
                      await _switchLanguage(url);
                    }
                  },
                ),
        ),
        GlassIconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: t.common.refresh,
          loading: _isLoading,
          onPressed: _reload,
        ),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮（窄屏；宽屏双列各自滚动不提供）。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            offset: visible ? Offset.zero : const Offset(0, 0.4),
            child: AnimatedOpacity(
              duration: GlassTokens.motionDuration,
              opacity: visible ? 1 : 0,
              child: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.vertical_align_top),
                tooltip: t.common.scrollToTop,
                onPressed: _scrollToTop,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBody(
    BuildContext context, {
    required bool isWideLayout,
    required double effectiveTopPadding,
    required double availableWideHeight,
    required String? heroTag,
  }) {
    final bottomInset = 12 + MediaQuery.paddingOf(context).bottom;

    if (isWideLayout) {
      return Padding(
        padding: EdgeInsets.fromLTRB(12, effectiveTopPadding + 6, 12, 0),
        child: SizedBox(
          height: availableWideHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: _NewsDetailLoadingContent(
                    showContentCard: false,
                    overviewHeroTag: heroTag,
                    horizontalPadding: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: const _NewsDetailLoadingContent(
                    showOverviewCard: false,
                    horizontalPadding: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: effectiveTopPadding + 4),
          _NewsDetailLoadingContent(
            overviewHeroTag: heroTag,
            horizontalPadding: MediaQuery.sizeOf(context).width <= 600
                ? 10
                : 12,
          ),
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildContentBody(
    BuildContext context, {
    required _ResolvedNewsData resolved,
    required bool isWideLayout,
    required double effectiveTopPadding,
    required double availableWideHeight,
    required String? heroTag,
  }) {
    final bottomInset = 12 + MediaQuery.paddingOf(context).bottom;

    if (isWideLayout) {
      return Padding(
        padding: EdgeInsets.fromLTRB(12, effectiveTopPadding + 6, 12, 0),
        child: SizedBox(
          height: availableWideHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: _NewsDetailContent(
                    resolved: resolved,
                    detail: _detail,
                    isLoading: _isLoading,
                    errorMessage: _error,
                    onRetry: _reload,
                    urlPreprocessor: _normalizeNewsMarkdownUrl,
                    showContentCard: false,
                    includeTopSpacing: false,
                    horizontalPadding: 0,
                    overviewHeroTag: heroTag,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: _NewsDetailContent(
                    resolved: resolved,
                    detail: _detail,
                    isLoading: _isLoading,
                    errorMessage: _error,
                    onRetry: _reload,
                    urlPreprocessor: _normalizeNewsMarkdownUrl,
                    showOverviewCard: false,
                    includeTopSpacing: false,
                    horizontalPadding: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isSmallScreen = MediaQuery.sizeOf(context).width <= 600;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: effectiveTopPadding + 4),
          _NewsDetailContent(
            resolved: resolved,
            detail: _detail,
            isLoading: _isLoading,
            errorMessage: _error,
            onRetry: _reload,
            urlPreprocessor: _normalizeNewsMarkdownUrl,
            includeTopSpacing: false,
            horizontalPadding: isSmallScreen ? 10 : 12,
            overviewHeroTag: heroTag,
          ),
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isWideLayout = screenWidth >= 1080;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final double effectiveTopPadding = headerExtent;
    final availableWideHeight =
        (MediaQuery.sizeOf(context).height - effectiveTopPadding - 6).clamp(
          200.0,
          double.infinity,
        );

    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.vertical &&
                notification.depth == 0) {
              _showBackToTop.value = notification.metrics.pixels >= 300;
            }
            return false;
          },
          child: _buildStateBody(
            context,
            isWideLayout: isWideLayout,
            headerExtent: headerExtent,
            effectiveTopPadding: effectiveTopPadding,
            availableWideHeight: availableWideHeight,
          ),
        ),
        // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
        header: _buildHeader(context),
        extra: [
          // 回到顶部浮钮（窄屏；宽屏双列各自滚动不提供）
          if (!isWideLayout) _buildScrollToTopFab(context),
        ],
      ),
    );
  }

  Widget _buildStateBody(
    BuildContext context, {
    required bool isWideLayout,
    required double headerExtent,
    required double effectiveTopPadding,
    required double availableWideHeight,
  }) {
    final t = slang.Translations.of(context);
    final preview = widget.previewData;
    final hasShellContent = _detail != null || preview != null;

    if (_error != null && !hasShellContent && !_isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: CommonErrorWidget(
          text: _error ?? t.errors.errorWhileLoadingPost,
          children: [
            ElevatedButton(onPressed: _reload, child: Text(t.common.retry)),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(t.common.back),
            ),
          ],
        ),
      );
    }

    if (_isLoading && !hasShellContent) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWideLayout ? 1220 : 940),
            child: _buildLoadingBody(
              context,
              isWideLayout: isWideLayout,
              effectiveTopPadding: effectiveTopPadding,
              availableWideHeight: availableWideHeight,
              heroTag: preview?.heroTag,
            ),
          ),
        ),
      );
    }

    if (!hasShellContent) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: MyEmptyWidget(message: t.common.noData, onRefresh: _reload),
      );
    }

    final resolved = _ResolvedNewsData.from(
      detail: _detail,
      preview: preview,
      fallbackTitle: t.news.title,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWideLayout ? 1220 : 940),
          child: _buildContentBody(
            context,
            resolved: resolved,
            isWideLayout: isWideLayout,
            effectiveTopPadding: effectiveTopPadding,
            availableWideHeight: availableWideHeight,
            heroTag: preview?.heroTag,
          ),
        ),
      ),
    );
  }
}

class _ResolvedNewsData {
  const _ResolvedNewsData({
    required this.title,
    required this.publishedAt,
    required this.updatedAt,
    required this.featuredImageUrl,
  });

  factory _ResolvedNewsData.from({
    required IwaraNewsDetail? detail,
    required NewsDetailExtra? preview,
    required String fallbackTitle,
  }) {
    return _ResolvedNewsData(
      title: detail?.title ?? preview?.title ?? fallbackTitle,
      publishedAt:
          detail?.publishedAt ?? preview?.publishedAt ?? DateTime.now(),
      updatedAt: detail?.updatedAt ?? preview?.updatedAt ?? DateTime.now(),
      featuredImageUrl: detail?.featuredImageUrl ?? preview?.featuredImageUrl,
    );
  }

  final String title;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final String? featuredImageUrl;

  bool get hasImage =>
      featuredImageUrl != null && featuredImageUrl!.trim().isNotEmpty;
}

class _NewsDetailContent extends StatelessWidget {
  const _NewsDetailContent({
    required this.resolved,
    required this.detail,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.urlPreprocessor,
    this.showOverviewCard = true,
    this.showContentCard = true,
    this.includeTopSpacing = true,
    this.horizontalPadding = 12,
    this.overviewHeroTag,
  });

  final _ResolvedNewsData resolved;
  final IwaraNewsDetail? detail;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final String Function(String url) urlPreprocessor;
  final bool showOverviewCard;
  final bool showContentCard;
  final bool includeTopSpacing;
  final double horizontalPadding;
  final String? overviewHeroTag;

  Widget _buildMetaChip({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewShared(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.sizeOf(context).width <= 600;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resolved.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: resolved.featuredImageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SelectableText(
              resolved.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.25,
                fontSize: isSmallScreen ? 20 : 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final theme = Theme.of(context);
    final sharedOverview = overviewHeroTag == null
        ? _buildOverviewShared(context)
        : Hero(tag: overviewHeroTag!, child: _buildOverviewShared(context));

    final showUpdated = !resolved.updatedAt.isAtSameMomentAs(
      resolved.publishedAt,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sharedOverview,
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetaChip(
                  context: context,
                  icon: Icons.calendar_today_rounded,
                  text: CommonUtils.formatFriendlyTimestamp(
                    resolved.publishedAt,
                  ),
                ),
                if (showUpdated)
                  _buildMetaChip(
                    context: context,
                    icon: Icons.edit_calendar_rounded,
                    text: CommonUtils.formatFriendlyTimestamp(
                      resolved.updatedAt,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return _NewsDetailContentCard(
      detail: detail,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
      urlPreprocessor: urlPreprocessor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (includeTopSpacing) {
      children.add(const SizedBox(height: 4));
    }
    if (showOverviewCard) {
      children.add(_buildOverviewCard(context));
    }
    if (showOverviewCard && showContentCard) {
      children.add(const SizedBox(height: 12));
    }
    if (showContentCard) {
      children.add(_buildContentCard(context));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// 公告正文卡片。
///
/// 单独拆成有状态组件，只为托住「显示原始文本」的开关状态：
/// CustomMarkdownBody 的行内开关已关闭，那枚 only-icon 钮收进了卡片标题行
/// （「内容」那一行）的右端。
class _NewsDetailContentCard extends StatefulWidget {
  const _NewsDetailContentCard({
    required this.detail,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.urlPreprocessor,
  });

  final IwaraNewsDetail? detail;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final String Function(String url) urlPreprocessor;

  @override
  State<_NewsDetailContentCard> createState() => _NewsDetailContentCardState();
}

class _NewsDetailContentCardState extends State<_NewsDetailContentCard> {
  late bool _showOriginal;
  bool _hasProcessedContent = false;

  @override
  void initState() {
    super.initState();
    _showOriginal = Get.find<ConfigService>()[ConfigKey
        .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = widget.detail;
    final errorMessage = widget.errorMessage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    slang.t.common.content,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                MarkdownOriginalTextToggle(
                  visible: detail != null && _hasProcessedContent,
                  showOriginal: _showOriginal,
                  onChanged: (v) => setState(() => _showOriginal = v),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (detail != null && errorMessage != null) ...[
              _NewsDetailInlineError(
                message: errorMessage,
                onRetry: widget.onRetry,
              ),
              const SizedBox(height: 12),
            ],
            if (detail != null)
              Stack(
                children: [
                  CustomMarkdownBody(
                    data: detail.contentMarkdown,
                    padding: EdgeInsets.zero,
                    maxImageHeight: 420,
                    showHorizontalRules: false,
                    urlPreprocessor: widget.urlPreprocessor,
                    initialShowUnprocessedText: _showOriginal,
                    onProcessedContentChanged: (hasProcessed) {
                      if (_hasProcessedContent == hasProcessed) return;
                      setState(() => _hasProcessedContent = hasProcessed);
                    },
                  ),
                  if (widget.isLoading)
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              )
            else if (errorMessage != null)
              MyEmptyWidget(message: errorMessage, onRefresh: widget.onRetry)
            else
              const _NewsDetailSkeletonBody(),
          ],
        ),
      ),
    );
  }
}

class _NewsDetailLoadingContent extends StatelessWidget {
  const _NewsDetailLoadingContent({
    this.showOverviewCard = true,
    this.showContentCard = true,
    this.horizontalPadding = 12,
    this.overviewHeroTag,
  });

  final bool showOverviewCard;
  final bool showContentCard;
  final double horizontalPadding;
  final String? overviewHeroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];
    if (showOverviewCard) {
      children.add(
        _NewsDetailSkeletonCard(
          heroTag: overviewHeroTag,
          child: const _NewsDetailOverviewSkeletonBody(),
        ),
      );
    }
    if (showOverviewCard && showContentCard) {
      children.add(const SizedBox(height: 12));
    }
    if (showContentCard) {
      children.add(
        const _NewsDetailSkeletonCard(child: _NewsDetailContentSkeletonBody()),
      );
    }

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _NewsDetailSkeletonCard extends StatelessWidget {
  const _NewsDetailSkeletonCard({required this.child, this.heroTag});

  final Widget child;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: child,
      ),
    );

    if (heroTag == null) {
      return card;
    }
    return Hero(tag: heroTag!, child: card);
  }
}

class _NewsDetailOverviewSkeletonBody extends StatelessWidget {
  const _NewsDetailOverviewSkeletonBody();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageHeight = screenWidth <= 600 ? 184.0 : 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: imageHeight,
          radius: 12,
        ),
        const SizedBox(height: 12),
        const _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: 24,
          radius: 8,
        ),
        const SizedBox(height: 10),
        const _NewsDetailSkeletonBlock(width: 228, height: 24, radius: 8),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _NewsDetailSkeletonBlock(width: 128, height: 28, radius: 999),
            _NewsDetailSkeletonBlock(width: 154, height: 28, radius: 999),
          ],
        ),
      ],
    );
  }
}

class _NewsDetailContentSkeletonBody extends StatelessWidget {
  const _NewsDetailContentSkeletonBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _NewsDetailSkeletonBlock(width: 18, height: 18, radius: 999),
            const SizedBox(width: 6),
            const _NewsDetailSkeletonBlock(width: 104, height: 18, radius: 8),
          ],
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 8),
        const _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: 14,
          radius: 8,
        ),
        const SizedBox(height: 8),
        const _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: 14,
          radius: 8,
        ),
        const SizedBox(height: 14),
        const _NewsDetailSkeletonBlock(width: 252, height: 14, radius: 8),
        const SizedBox(height: 8),
        const _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: 160,
          radius: 12,
        ),
        const SizedBox(height: 8),
        const _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: 14,
          radius: 8,
        ),
        const SizedBox(height: 8),
        const _NewsDetailSkeletonBlock(
          width: double.infinity,
          height: 14,
          radius: 8,
        ),
        const SizedBox(height: 8),
        const _NewsDetailSkeletonBlock(width: 216, height: 14, radius: 8),
      ],
    );
  }
}

class _NewsDetailSkeletonBlock extends StatelessWidget {
  const _NewsDetailSkeletonBlock({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 语言切换钮：与玻璃动作胶囊同尺寸的 40×40 菜单触发位（与其他页的
/// 尾部 PopupMenuButton 同一口径），菜单里勾选当前语言。
class _NewsDetailLanguageButton extends StatelessWidget {
  const _NewsDetailLanguageButton({
    required this.languages,
    required this.currentLanguage,
    required this.languageLabelBuilder,
    required this.onSelected,
  });

  final Map<IwaraNewsLanguage, String> languages;
  final IwaraNewsLanguage currentLanguage;
  final String Function(IwaraNewsLanguage language) languageLabelBuilder;
  final Future<void> Function(IwaraNewsLanguage language) onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: GlassTokens.groupIconButtonSize,
      height: GlassTokens.groupIconButtonSize,
      child: PopupMenuButton<IwaraNewsLanguage>(
        initialValue: currentLanguage,
        position: PopupMenuPosition.under,
        // 往下挪一点，别压住玻璃胶囊本身
        offset: const Offset(0, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tooltip: languageLabelBuilder(currentLanguage),
        onSelected: (language) {
          onSelected(language);
        },
        itemBuilder: (context) => [
          for (final entry in languages.entries)
            PopupMenuItem<IwaraNewsLanguage>(
              value: entry.key,
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(languageLabelBuilder(entry.key))),
                  if (entry.key == currentLanguage) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check, size: 18, color: colorScheme.primary),
                  ],
                ],
              ),
            ),
        ],
        icon: Icon(
          Icons.translate_rounded,
          size: GlassTokens.iconSize,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NewsDetailInlineError extends StatelessWidget {
  const _NewsDetailInlineError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              slang.t.common.retry,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsDetailSkeletonBody extends StatelessWidget {
  const _NewsDetailSkeletonBody();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget line(double width, {double height = 14}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(double.infinity, height: 18),
        const SizedBox(height: 10),
        line(double.infinity),
        const SizedBox(height: 8),
        line(double.infinity),
        const SizedBox(height: 8),
        line(220),
        const SizedBox(height: 18),
        line(double.infinity),
        const SizedBox(height: 8),
        line(double.infinity),
        const SizedBox(height: 8),
        line(180),
      ],
    );
  }
}
