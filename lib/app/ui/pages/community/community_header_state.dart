import 'package:flutter/scheduler.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';

/// 在**安全时机**跑一次「往上报状态」的写入。
///
/// 子页更新 header 状态有两类时机：
/// - 点按回调、异步请求回来——随时可写；
/// - `initState` / `didChangeDependencies` / `didUpdateWidget`——这些跑在
///   build 阶段**里面**。
///
/// 后者同步写 notifier，会让已经建过的祖先 `ValueListenableBuilder`
/// （社区 header 的动作胶囊就是）在 build 期间 `markNeedsBuild`，直接抛
/// 「setState() or markNeedsBuild() called during build」。所以统一在这里探测
/// 调度阶段，处在 build 阶段就推到本帧结束再写。
void runOutsideBuildPhase(VoidCallback action) {
  final binding = SchedulerBinding.instance;
  if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
    binding.addPostFrameCallback((_) => action());
    return;
  }
  action();
}

/// 论坛半边要在社区 header 上反映的状态。
///
/// 只放**真正影响按钮长相**的那几项。动作本身（发帖 / 搜索 / 刷新 / 切分页）
/// 的按钮由 `CommunityPage` 统一构建，点按时才通过 `ForumPage.globalKey`
/// 回调进论坛页——这样首帧就有完整的按钮胶囊，不会等子页 State 挂上来才补出来。
class ForumHeaderState {
  const ForumHeaderState({
    this.showPaginationToggle = true,
    this.isPaginated = false,
  });

  /// 瀑布流 / 分页切换只作用于「最近」列表；切到某个分类版块时该键要挤出去。
  final bool showPaginationToggle;

  /// 「最近」列表当前是否为分页模式（决定切换键的图标与 tooltip）。
  final bool isPaginated;

  static const ForumHeaderState initial = ForumHeaderState();

  @override
  bool operator ==(Object other) =>
      other is ForumHeaderState &&
      other.showPaginationToggle == showPaginationToggle &&
      other.isPaginated == isPaginated;

  @override
  int get hashCode => Object.hash(showPaginationToggle, isPaginated);
}

/// 新闻半边要在社区 header 上反映的状态。见 [ForumHeaderState] 的说明。
class NewsHeaderState {
  const NewsHeaderState({this.language, this.isLoading = false});

  /// 当前语言；null 表示还没从 locale 推导出来。
  final IwaraNewsLanguage? language;

  /// 当前分类正在加载——刷新键据此置成沙漏态。
  final bool isLoading;

  static const NewsHeaderState initial = NewsHeaderState();

  @override
  bool operator ==(Object other) =>
      other is NewsHeaderState &&
      other.language == language &&
      other.isLoading == isLoading;

  @override
  int get hashCode => Object.hash(language, isLoading);
}
