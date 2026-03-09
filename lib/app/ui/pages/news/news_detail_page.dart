import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/iwara_news_service.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart'
    show CommonErrorWidget;
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

  @override
  void initState() {
    super.initState();
    _fetchDetail();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(slang.t.news.openInBrowser)));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(CommonUtils.parseExceptionMessage(error))),
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    _ResolvedNewsData resolved,
  ) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final detail = _detail;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.7),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Text(
        resolved.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      actions: [
        if (detail != null) ...[
          IconButton(
            onPressed: () => _openInBrowser(detail.link),
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: t.news.openInBrowser,
          ),
          if (detail.translationLinks.length > 1)
            _NewsDetailLanguageButton(
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
        ],
        IconButton(
          onPressed: _isLoading ? null : _reload,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: t.common.refresh,
        ),
      ],
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
          const SafeArea(child: SizedBox.shrink()),
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
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final preview = widget.previewData;
    final hasShellContent = _detail != null || preview != null;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final effectiveTopPadding =
        MediaQuery.paddingOf(context).top + kToolbarHeight;
    final isWideLayout = screenWidth >= 1080;
    final availableWideHeight =
        (MediaQuery.sizeOf(context).height - effectiveTopPadding - 6).clamp(
          200.0,
          double.infinity,
        );

    if (_error != null && !hasShellContent && !_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(
          context,
          _ResolvedNewsData.fallback(title: t.news.title),
        ),
        body: CommonErrorWidget(
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
      final loadingResolved = _ResolvedNewsData.fallback(title: t.news.title);
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, loadingResolved),
        body: DecoratedBox(
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
        ),
      );
    }

    if (!hasShellContent) {
      return Scaffold(
        appBar: _buildAppBar(
          context,
          _ResolvedNewsData.fallback(title: t.news.title),
        ),
        body: MyEmptyWidget(message: t.common.noData, onRefresh: _reload),
      );
    }

    final resolved = _ResolvedNewsData.from(
      detail: _detail,
      preview: preview,
      fallbackTitle: t.news.title,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, resolved),
      body: DecoratedBox(
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

  factory _ResolvedNewsData.fallback({required String title}) =>
      _ResolvedNewsData(
        title: title,
        publishedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        featuredImageUrl: null,
      );

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
    final theme = Theme.of(context);

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
                Text(
                  slang.t.common.content,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (detail != null && errorMessage != null) ...[
              _NewsDetailInlineError(message: errorMessage!, onRetry: onRetry),
              const SizedBox(height: 12),
            ],
            if (detail != null)
              Stack(
                children: [
                  CustomMarkdownBody(
                    data: detail!.contentMarkdown,
                    padding: EdgeInsets.zero,
                    maxImageHeight: 420,
                    showHorizontalRules: false,
                    urlPreprocessor: urlPreprocessor,
                  ),
                  if (isLoading)
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              )
            else if (errorMessage != null)
              MyEmptyWidget(message: errorMessage!, onRefresh: onRetry)
            else
              const _NewsDetailSkeletonBody(),
          ],
        ),
      ),
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
    return PopupMenuButton<IwaraNewsLanguage>(
      initialValue: currentLanguage,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: null,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.translate_rounded,
                size: 16,
                color: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
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
