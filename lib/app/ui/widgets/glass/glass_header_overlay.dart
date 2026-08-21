import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 「header 悬浮在列表之上」的通用骨架。
///
/// - [body]：铺满整个区域的列表；调用方自己用 `paddingTop = headerExtent`
///   让出首屏位置（视口不能在外面套 Padding，否则内容滚不到 header 背后）。
/// - 顶部渐变蒙层从 0 覆盖到 [headerExtent] + [GlassTokens.headerFadeExtent]，
///   平台段为 [solidExtent]（一般是状态栏高度，没有状态栏传 0）。
/// - [header]：放在 [headerTop] 处的一行玻璃控件（可为 null，只要蒙层 + 留白）。
///
/// # 详情 / 二级列表页标准配方
///
/// 带返回键的页面统一长这样（参考 thread_detail_page / thread_list_page /
/// search_result）：
///
/// - `headerExtent = statusBar + GlassTokens.headerRowHeight`，
///   `headerTop = solidExtent = statusBar`。
/// - header 行：横向 padding 16，三段式
///   「返回圆钮（`GlassIconButton(standalone: true)` + `AppService.tryPop`）
///   / 中间 `GlassTitlePill`（可点按弹全文，别手写死标题）
///   / 右侧 `GlassButtonGroup`」。胶囊里：仅宽屏直出的键和等数据就绪的键都
///   用 `GlassGroupSlot` 包；尾部固定一个 40×40 的 PopupMenuButton
///   （`offset: Offset(0, 8)`、圆角 12），窄屏功能收进这里。
/// - [body] 外包一层 `NotificationListener<ScrollNotification>`
///   （`depth == 0` 且纵向、`pixels >= 300`）驱动回到顶部浮钮的显隐；
///   浮钮放进 [extra]，`bottom = padding.bottom + 16 + (分页模式 ? 46 : 0)`
///   给底部分页栏让位。
/// - 下拉刷新 `RefreshIndicator.displacement = headerExtent`，指示器从
///   header 下方弹出。
/// - 分页模式两条路线：纯列表用 `MediaListView(isPaginated: true)`（数据源
///   须是 `ExtendedLoadingMoreBase`）；列表上方还有头部区块（主楼卡、公告）
///   时 MediaListView 塞不进 header sliver，手写
///   `Stack[RefreshIndicator(CustomScrollView(头部 sliver + 内容 sliver)),
///   Positioned(PaginationBar)]`，参考 thread_detail_page 的
///   `_buildPaginatedBody` / forum_page 的 `_buildRecentPaginated`。
class GlassHeaderOverlay extends StatelessWidget {
  const GlassHeaderOverlay({
    super.key,
    required this.body,
    required this.headerExtent,
    this.header,
    this.headerTop = 0,
    this.headerHeight,
    this.solidExtent = 0,
    this.extra = const [],
    this.liquid = false,
  });

  /// 本页的浮层 chrome（[header] 与 [extra]）改用真折射透镜。
  ///
  /// 开关放在这里而不是让页面自己包 `LiquidGlassScope`，是因为 [extra] 里的
  /// 每一项都必须是 `Positioned`（Stack 的直接子级）——在外面包一层
  /// InheritedWidget 会把 `Positioned` 埋起来，浮钮当场失去定位。这里从
  /// **整个 Stack 之上**打开，再单独给 [body] 关掉：列表在滚动容器里，lens
  /// 放进去会被 Android 的拉伸回弹渲染成纯黑（见 `liquid_glass_material.dart`）。
  final bool liquid;

  final Widget body;

  /// 列表需要让出的总高度（从区域顶部到 header 行底部）。
  final double headerExtent;

  final Widget? header;

  /// header 行距区域顶部的距离。
  final double headerTop;

  /// header 行高度；为 null 时用 [GlassTokens.headerRowHeight]。
  final double? headerHeight;

  /// 蒙层平台段高度（状态栏）。
  final double solidExtent;

  /// 叠在最上层的其他元素（如浮钮、批量操作 FAB）。
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final Widget stack = Stack(
      // 所有子项都是 Positioned；松约束下也要撑满，别被某个非 Positioned 的占位压成 0 高
      fit: StackFit.expand,
      children: [
        // 列表本体永远留在传统档：它是滚动容器，装不得 lens。
        Positioned.fill(
          child: liquid ? LiquidGlassScope(enabled: false, child: body) : body,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: EdgeFadeScrim.top(
            height: headerExtent + GlassTokens.headerFadeExtent,
            solidExtent: solidExtent,
          ),
        ),
        if (header != null)
          Positioned(
            top: headerTop,
            left: 0,
            right: 0,
            height: headerHeight ?? GlassTokens.headerRowHeight,
            child: header!,
          ),
        ...extra,
      ],
    );
    return liquid ? LiquidGlassScope(child: stack) : stack;
  }
}
