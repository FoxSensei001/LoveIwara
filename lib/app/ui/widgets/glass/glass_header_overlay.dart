import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_content_brightness.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 「header 悬浮在列表之上」的通用骨架。
///
/// - [body]：铺满整个区域的列表；调用方自己用 `paddingTop = headerExtent`
///   让出首屏位置（视口不能在外面套 Padding，否则内容滚不到 header 背后）。
/// - 顶部渐变蒙层从 0 覆盖到 [headerExtent] 再往下一段尾巴（长度按
///   [GlassTokens.scrimFadeTail] 的标定比例算，标准单行 header 正好是
///   [GlassTokens.headerFadeExtent] 24）。平台段为 [solidExtent]（一般是状态栏
///   高度，没有状态栏传 0）——**只盖状态栏**，header 行本身是淡出的一部分。
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
///   用 `GlassGroupSlot` 包；尾部固定一个 `GlassGroupOverflowMenuButton`
///   （或自己 `GlassIconButton` + `showGlassMenu`），窄屏功能收进这里。
///   **不要再用 `PopupMenuButton`**——它吐出来的是块不透明的 Material 卡片，
///   跟玻璃胶囊接不上（见 `glass_menu.dart`）。
/// - header 行里这几块玻璃之间一律留 `SizedBox(width: 8)`：`liquid: true` 时
///   本组件会把整行收进一个 [GlassBlendGroup]，那 8px 正是
///   [GlassTokens.chromeBlend] 标定的「刚好不粘连、拖近才融合」的距离。
///   间距改了就要连着 blend 一起改，否则要么静止态就糊成一条，要么怎么拖
///   都不融合。
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
    this.blendHeader = true,
    this.contentAware = false,
  });

  /// header 行的字色 / 图标色跟着**身后真正滚过去的内容**走，而不是一律跟主题
  /// 的明暗（见 [GlassAdaptiveChrome]）。浅色主题下滚过一张深色大图时，header
  /// 会整行换成浅色一档，反之亦然。
  ///
  /// 只在 [liquid] 为真、且全局是真玻璃档时有意义——Material 档下 header 是不
  /// 透明的面，身后什么都透不过来，本开关整条链自动归零。
  ///
  /// # 代价
  ///
  /// 开着的页面在**滚动期间**每 180ms 会对 [body] + 蒙层做一次降采样
  /// `toImage` 回读（静止时零开销）。列表越重这一下越贵，所以默认关，逐页开。
  ///
  /// # ⛔ 采样区是「[body] + 蒙层」，不含 header 自己
  ///
  /// 见 [GlassSampledContent] 的说明：蒙层必须算进去（它是一层实色面纱，已经
  /// 改变了 header 底下的观感），header 必须排除（否则判决改底色、底色又改下
  /// 次读数，来回自激）。
  final bool contentAware;

  /// header 行里并排的几块玻璃是否收进**同一层**、靠近时互相吞并
  /// （见 [GlassBlendGroup]）。只在 [liquid] 为真时有意义。
  ///
  /// 默认开：头像圆钮被按住往右拖时，跟手形变会把它与中间那只胶囊之间的
  /// 8px 间隙吃掉并融成一坨——与浮动底栏上「搜索圆钮拖向栏目胶囊」是同一种
  /// 语言。要关掉的只有一种情形：header 里有玻璃要做
  /// [GlassSurface.materialize] 材质淡入（同一层玻璃只有一份材质，淡入在
  /// 融合态下无效，debug 下有 assert 盯着）。
  final bool blendHeader;

  /// 本页的浮层 chrome（[header] 与 [extra]）改用真液态玻璃
  /// （[chromeGlassBackend]，真玻璃档下是 `liquid_glass_widgets` 那一档）。
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
    // 列表本体永远留在传统档：它是滚动容器，装不得 lens。
    final Widget content = liquid
        ? LiquidGlassScope(backend: flatGlassBackend(context), child: body)
        : body;
    final Widget scrim = EdgeFadeScrim.headerOverlay(
      headerExtent: headerExtent,
      plateauExtent: solidExtent,
    );

    Widget? headerRow = header;
    if (headerRow != null) {
      // 融合层只能包**这一行**：它是一层玻璃 + 一次背景采样，包大了会
      // 把整页都拖进同一次采样里。非液态档下它是纯透传。
      if (blendHeader) headerRow = GlassBlendGroup(child: headerRow);
      // 内容感知必须在融合层**外面**：翻面换的是整行的配色，融合层里那份材质
      // 也得跟着一起走。
      if (contentAware) {
        headerRow = GlassAdaptiveChrome(debugLabel: 'header', child: headerRow);
      }
    }

    final Widget stack = Stack(
      // 所有子项都是 Positioned；松约束下也要撑满，别被某个非 Positioned 的占位压成 0 高
      fit: StackFit.expand,
      children: [
        if (contentAware)
          // 被采样区 = 列表 + 蒙层，一个 Stack 收成一块（见 [contentAware]）。
          // 布局与不开时完全一致：还是这两个 Positioned，只是外面多一层
          // 撑满的 Stack。
          Positioned.fill(
            child: GlassSampledContent(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: content),
                  Positioned(top: 0, left: 0, right: 0, child: scrim),
                ],
              ),
            ),
          )
        else ...[
          Positioned.fill(child: content),
          Positioned(top: 0, left: 0, right: 0, child: scrim),
        ],
        if (headerRow != null)
          Positioned(
            top: headerTop,
            left: 0,
            right: 0,
            height: headerHeight ?? GlassTokens.headerRowHeight,
            child: headerRow,
          ),
        ...extra,
      ],
    );
    final Widget scoped = liquid
        ? LiquidGlassScope(backend: chromeGlassBackend(context), child: stack)
        : stack;
    // 采样器套在最外层：它只是一个 InheritedWidget + 一个 ScrollNotification
    // 监听，不参与布局。
    return contentAware ? GlassContentAwareHost(child: scoped) : scoped;
  }
}
