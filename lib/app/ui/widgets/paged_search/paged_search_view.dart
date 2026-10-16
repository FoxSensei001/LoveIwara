import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:loading_more_list/loading_more_list.dart';

/// 搜索状态与结果里随列表内容变的文案（数的是「项」还是「位用户」）。
///
/// 各页传自己的一套，组件按 [PagedSearchLabelsOf] 在构建时取当前语言的版本。
class PagedSearchLabels {
  const PagedSearchLabels({
    required this.all,
    required this.scopeLoaded,
    required this.scopeAll,
    required this.loadedCount,
    required this.noLoadedMatches,
    required this.noAllMatches,
    required this.probing,
    required this.complete,
    required this.incomplete,
    required this.progress,
    required this.longWait,
    required this.failed,
    required this.cancelled,
    required this.seconds,
    required this.minutes,
    required this.continueSearch,
  });

  /// 通用计量「项」，最爱等媒体列表用。
  factory PagedSearchLabels.items(slang.Translations t) {
    final l = t.pagedSearch;
    return PagedSearchLabels(
      all: l.all,
      scopeLoaded: l.scopeLoaded,
      scopeAll: l.scopeAll,
      loadedCount: l.loadedCount,
      noLoadedMatches: l.noLoadedMatches,
      noAllMatches: l.noAllMatches,
      probing: l.probing,
      complete: l.complete,
      incomplete: l.incomplete,
      progress: l.progress,
      longWait: l.longWait,
      failed: l.failed,
      cancelled: l.cancelled,
      seconds: l.seconds,
      minutes: l.minutes,
      continueSearch: l.continueSearch,
    );
  }

  final String all;
  final String scopeLoaded;
  final String scopeAll;
  final String Function({required Object count, required Object total})
  loadedCount;
  final String noLoadedMatches;
  final String noAllMatches;
  final String probing;
  final String Function({
    required Object count,
    required Object size,
    required Object rounds,
  })
  complete;
  final String incomplete;
  final String Function({
    required Object current,
    required Object total,
    required Object size,
    required Object done,
    required Object rounds,
    required Object time,
  })
  progress;
  final String longWait;
  final String failed;
  final String cancelled;
  final String Function({required Object value}) seconds;
  final String Function({required Object value}) minutes;
  final String continueSearch;
}

typedef PagedSearchLabelsOf = PagedSearchLabels Function(slang.Translations t);

/// 搜索结果视图：有搜索词（或选了「整个列表」）时，用结果列表盖在浏览列表上。
/// 默认是与浏览时同列宽的瀑布网格，[PagedSearchView.list] 是单列。
///
/// 浏览列表始终保持挂载（只是 Offstage），清空搜索词后回到原来的那一页、原来的
/// 滚动位置；它在被盖住期间换用内部的滚动控制器，外部控制器（回顶浮钮在听）
/// 交给结果网格。
class PagedSearchView<T> extends StatefulWidget {
  const PagedSearchView({
    super.key,
    required this.search,
    required this.scrollController,
    required this.paddingTop,
    required this.browseBuilder,
    required this.itemBuilder,
    required SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
    this.gridDelegate,
    this.labels = PagedSearchLabels.items,
  });

  /// 单列结果，[itemBuilder] 拿到的宽度是整行宽。
  const PagedSearchView.list({
    super.key,
    required this.search,
    required this.scrollController,
    required this.paddingTop,
    required this.browseBuilder,
    required this.itemBuilder,
    this.labels = PagedSearchLabels.items,
  }) : gridDelegate = null;

  final PagedSearchController<T> search;
  final ScrollController scrollController;
  final double paddingTop;
  final Widget Function(ScrollController controller) browseBuilder;

  /// 与浏览列表同一个卡片构建函数，[width] 是本列实际宽度。
  final Widget Function(BuildContext context, T item, double width) itemBuilder;

  /// 与浏览列表同一个瀑布 delegate，结果网格的列数和列宽才会与浏览时一致；
  /// 为 null 时是单列。
  final SliverWaterfallFlowDelegateWithMaxCrossAxisExtent? gridDelegate;

  final PagedSearchLabelsOf labels;

  @override
  State<PagedSearchView<T>> createState() => _PagedSearchViewState<T>();
}

class _PagedSearchViewState<T> extends State<PagedSearchView<T>> {
  final ScrollController _hiddenScrollController = ScrollController();

  @override
  void dispose() {
    _hiddenScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.search,
      builder: (context, _) {
        final search = widget.search;
        final showing = search.showingResults;
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: showing,
              child: TickerMode(
                enabled: !showing,
                child: widget.browseBuilder(
                  showing ? _hiddenScrollController : widget.scrollController,
                ),
              ),
            ),
            if (showing) _buildResults(context, search),
          ],
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, PagedSearchController<T> search) {
    final labels = widget.labels(slang.Translations.of(context));
    final items = search.results;
    final delegate = widget.gridDelegate;
    // 顶部留白属于滚动内容：卡片能从悬浮的玻璃 header 下面滚过去。
    final padding = EdgeInsets.fromLTRB(
      MediaListView.listHorizontalPadding,
      widget.paddingTop,
      MediaListView.listHorizontalPadding,
      computeBottomSafeInset(MediaQuery.of(context)) + 8,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth =
            constraints.maxWidth - MediaListView.listHorizontalPadding * 2;
        final cardWidth = delegate == null
            ? rowWidth
            : MediaLayoutUtils.resolveWaterfallChildWidth(
                sliverCrossAxisExtent: rowWidth,
                maxCrossAxisExtent: delegate.maxCrossAxisExtent,
                crossAxisSpacing: delegate.crossAxisSpacing,
              );
        final children = SliverChildBuilderDelegate(
          (context, index) =>
              widget.itemBuilder(context, items[index], cardWidth),
          childCount: items.length,
        );
        return CustomScrollView(
          controller: widget.scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: items.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          search.loading || search.awaitingConfirmation
                              ? labels.incomplete
                              : search.searchAll && search.complete
                              ? labels.noAllMatches
                              : labels.noLoadedMatches,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : delegate == null
                  ? SliverList(delegate: children)
                  : SliverWaterfallFlow(
                      gridDelegate: delegate,
                      delegate: children,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class PagedSearchDetailsDialog extends StatelessWidget {
  const PagedSearchDetailsDialog({
    super.key,
    required this.search,
    this.labels = PagedSearchLabels.items,
  });
  final PagedSearchController<dynamic> search;
  final PagedSearchLabelsOf labels;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: search,
    builder: (context, _) {
      final t = slang.Translations.of(context);
      final l = labels(t);
      void close() => Navigator.of(context, rootNavigator: true).pop();
      return GlassAlertDialog(
        title: l.all,
        scrollable: true,
        content: PagedSearchStatus(search: search, labels: labels),
        actions: [
          if (search.searchAll &&
              (search.loading || search.awaitingConfirmation))
            GlassDialogAction(
              label: t.common.cancel,
              emphasized: false,
              onPressed: () {
                search.cancel();
                close();
              },
            ),
          if (search.searchAll &&
              (search.awaitingConfirmation ||
                  search.error != null ||
                  search.cancelled))
            GlassDialogAction(
              label: search.awaitingConfirmation
                  ? l.continueSearch
                  : t.common.retry,
              onPressed: () {
                search.startAll(confirmed: true);
                close();
              },
            ),
        ],
      );
    },
  );
}

class PagedSearchStatus extends StatelessWidget {
  const PagedSearchStatus({
    super.key,
    required this.search,
    this.labels = PagedSearchLabels.items,
  });
  final PagedSearchController<dynamic> search;
  final PagedSearchLabelsOf labels;

  @override
  Widget build(BuildContext context) {
    final labels = this.labels(slang.Translations.of(context));
    final scheme = Theme.of(context).colorScheme;
    final seconds = search.estimatedRemaining.inSeconds;
    final time = seconds >= 60
        ? labels.minutes(value: (seconds / 60).ceil())
        : labels.seconds(value: seconds.clamp(1, 59));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels.loadedCount(
              count: search.loadedCount,
              total: search.totalCount?.toString() ?? '?',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (search.searchAll) ...[
            if (search.loading) ...[
              LinearProgressIndicator(
                value: search.probing || (search.totalCount ?? 0) == 0
                    ? null
                    : (search.scannedCount / search.totalCount!).clamp(0, 1),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              search.probing
                  ? labels.probing
                  : search.complete
                  ? labels.complete(
                      count: search.scannedCount,
                      size: search.pageSize ?? 0,
                      rounds: search.completedRequests,
                    )
                  : search.pageSize == null
                  ? labels.incomplete
                  : labels.progress(
                      current: search.scannedCount,
                      total: search.totalCount ?? 0,
                      size: search.pageSize!,
                      done: search.completedRequests,
                      rounds: search.estimatedRequests,
                      time: time,
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (search.awaitingConfirmation ||
                (search.loading && search.needsLongWaitWarning))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labels.longWait,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (search.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labels.failed,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            if (search.cancelled) Text(labels.cancelled),
          ],
        ],
      ),
    );
  }
}
