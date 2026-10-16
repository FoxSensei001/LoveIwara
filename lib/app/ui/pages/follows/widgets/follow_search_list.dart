import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follow_search_controller.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_view.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 关注页的搜索文案：计量是「位用户」。
PagedSearchLabels followSearchLabels(slang.Translations t) {
  final l = t.followSearch;
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

/// 关注 / 粉丝的搜索结果：单列用户卡，盖在保持挂载的浏览列表上。
class FollowSearchList extends StatelessWidget {
  const FollowSearchList({
    super.key,
    required this.search,
    required this.scrollController,
    required this.paddingTop,
    required this.browseBuilder,
  });

  final FollowSearchController search;
  final ScrollController scrollController;
  final double paddingTop;
  final Widget Function(ScrollController controller) browseBuilder;

  @override
  Widget build(BuildContext context) => PagedSearchView<User>.list(
    search: search,
    scrollController: scrollController,
    paddingTop: paddingTop,
    browseBuilder: browseBuilder,
    itemBuilder: (context, user, _) => UserCard(user: user),
    labels: followSearchLabels,
  );
}

class FollowSearchDetailsDialog extends StatelessWidget {
  const FollowSearchDetailsDialog({super.key, required this.search});
  final FollowSearchController search;

  @override
  Widget build(BuildContext context) =>
      PagedSearchDetailsDialog(search: search, labels: followSearchLabels);
}

/// 详情弹窗里的加载状态，与最爱页同一个组件。
typedef FollowSearchStatus = PagedSearchStatus;
