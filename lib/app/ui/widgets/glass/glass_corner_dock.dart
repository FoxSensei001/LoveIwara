import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

/// header 那一行是不是该卸货了：窄屏（≤ [kCornerDockBreakpoint]）时为真。
///
/// 口径与全站 chrome 的 `isWide` 判定同源（`width > 600`），只是反过来说，
/// 免得每个页面各写一遍不等号、日后想调阈值要满仓库找 600。
bool useCornerDock(BuildContext context) =>
    MediaQuery.sizeOf(context).width <= kCornerDockBreakpoint;

/// 窄/宽屏分界。与 header 上既有的 `isWide` 判定（热门列表 / 订阅页）同一个数。
const double kCornerDockBreakpoint = 600;

/// 坞在底部占掉的那条空间：[rows] 格坞高 + 格间距 + 它距底的 16。列表要额外
/// 让出这么多，否则最后一行永远压在坞底下——浮动底栏那条
/// [GlassTokens.floatingBarReservedExtent] 是同一个道理。
///
/// ⛔ [rows] 要按**最多几格**填，不是此刻几格。右下角坞常常是两格（回顶浮钮
/// 一格、动作胶囊一格），而回顶钮按滚动显隐、动作组在选择态整只退场——跟着实
/// 时变的话，列表底部让位会随手指一跳一跳。宁可常年多让一格的高度。
///
/// ⛔ 这里一度写死成单格（`pillHeight + 16` ＝ 60）。右下角两格实际占 96，于是
/// 瀑布流下差 52px、分页下差 34px，「最后一行被浮钮压住」在两种模式下都在发生，
/// 只是分页模式下卡片正好卡在那一条上，最先被看出来。
double cornerDockReserve([int rows = 1]) {
  assert(rows >= 1, '坞至少一格；整只不在场请传 CornerDockBottomInset.active: false');
  return GlassTokens.pillHeight * rows +
      GlassTokens.chromeGap * (rows - 1) +
      16;
}

/// 给 [child] 的底部安全区加上坞占掉的那一条（[cornerDockReserve]）。
///
/// 只包**列表本体**，别包整只 `GlassHeaderOverlay`：坞自己也是按底部安全区
/// 定位的，把它一起包进来就成了「坞把自己顶上去」的循环。
///
/// # ⛔ 底部还钉着别的常驻浮层时（分页栏），抬高的这一条不是给它的
///
/// 抬高走的是 `MediaQuery.padding.bottom`，而**列表内容**和**分页栏**读的是
/// 同一个值（`MediaListView._buildPaginatedView` 既拿它算内容的 `reservedBottom`，
/// 又把它当 `paddingBottom` 喂给 `PaginationBar`）。于是一抬两个都动：内容让位
/// 是对的（它确实被坞盖着），分页栏却会跟着浮起来 60px、底下露出一条空档。
///
/// 早先的办法是分页模式下整只不开（`active: false`），代价是**坞那一条彻底没人
/// 让**——坞被抬到了分页栏之上，而内容只让出了分页栏的高度，最后一行卡片就压在
/// 坞底下。
///
/// 现在两件事分开：照常抬安全区（内容因此让够），同时用 [reserveOf] 把「这里头
/// 有多少是坞借走的」透下去，让按安全区定位的常驻浮层自己减回去。
class CornerDockBottomInset extends StatelessWidget {
  const CornerDockBottomInset({
    super.key,
    required this.child,
    this.active = true,
    this.rows = 1,
  });

  final Widget child;

  /// 坞此刻是否在场（窄屏才在）。为假时整只透传。
  final bool active;

  /// 两个下角里**最高的那一坞**最多堆几格。列表是整宽的，最后一行横跨左右，
  /// 所以按高的那边算。见 [cornerDockReserve] 关于「按最多、不按此刻」的说明。
  final int rows;

  /// 此处的底部安全区里，有多少是坞借去的。没有坞就是 0。
  ///
  /// ⭐ 给「贴着屏幕底缘、按安全区定位」的东西用（分页栏那一族）：坞那一条是
  /// **浮在它上面的 chrome**，不是安全区，跟着抬就会把自己顶飞。列表内容不必
  /// 问这个数——它本来就该躲开坞。
  static double reserveOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_CornerDockReserve>()
          ?.reserve ??
      0;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    final mq = MediaQuery.of(context);
    final double reserve = cornerDockReserve(rows);
    // 列表读的是 computeBottomSafeInset（padding / viewPadding / 手势区取最大），
    // 所以这里也得从那个最大值往上加，光加 padding.bottom 可能被别的项盖过去。
    final double bottom = computeBottomSafeInset(mq) + reserve;
    return _CornerDockReserve(
      reserve: reserve,
      child: MediaQuery(
        data: mq.copyWith(padding: mq.padding.copyWith(bottom: bottom)),
        child: child,
      ),
    );
  }
}

/// [CornerDockBottomInset.reserveOf] 的载体。
class _CornerDockReserve extends InheritedWidget {
  const _CornerDockReserve({required this.reserve, required super.child});

  final double reserve;

  @override
  bool updateShouldNotify(_CornerDockReserve oldWidget) =>
      oldWidget.reserve != reserve;
}

/// [GlassCornerDock] 挂在哪个下角。
enum GlassDockCorner { bottomLeft, bottomRight }

/// 屏幕下角的浮动 chrome 坞：**窄屏时 header 摆不下的东西沉到这里**。
///
/// # 为什么要有它
///
/// 详情 / 列表页的 header 是一行定死的 56：
///
///     [返回] [ 标题 / 搜索胶囊 ] [ 分段 排序 筛选 收藏 ⋮ ]
///
/// 宽屏读起来很顺，360dp 上却是一场灾难——右侧胶囊里五六枚 40px 的图标位
/// 加上返回钮就吃掉 260+，中间那只本该是主角的胶囊只剩四五十像素，标题永远
/// 是省略号。既有的办法是把动作往 `⋮` 里塞，但那是把「摆不下」翻译成
/// 「找不到」：筛选的小红点、当前排序是谁，全都藏进了一层菜单。
///
/// 这只坞换个方向解：**header 只留身份（返回 + 标题/搜索），动作整组挪到
/// 拇指够得着的下角**。左下角放「我在看什么、怎么排」（分段 / 排序），右下角
/// 放「怎么筛、还能干什么」（筛选 / 收藏 / 更多）以及回顶浮钮——两坨各自成组，
/// 与它们在 header 上时的分工一模一样，只是换了个位置。
///
/// # 约定
///
/// - 本组件**返回 `AnimatedPositioned`**，只能直接放进 [GlassHeaderOverlay.extra]
///   （Stack 的直接子级）。外面套任何东西都会让它当场失去定位。
/// - 供档不用管：`GlassHeaderOverlay(liquid: true)` 已经在整个 Stack 之上开好
///   了 chrome 档，坞里的玻璃直接就是真玻璃。
/// - ⛔ **不要把坞里的几块玻璃收进 [GlassBlendGroup]**。坞里的东西是会来会走的
///   （回顶浮钮按滚动显隐、动作组在选择态整只退场），出入场靠
///   [GlassReveal] 的材质淡入，而融合层里同一层玻璃只有一份材质、淡入直接失效
///   （见 `GlassChromeLayer` 的类注释）。这里宁可多一层采样。
/// - [children] 自上而下排，间距 [GlassTokens.chromeGap]——与 header 行里那 8px
///   同一个数，两处读起来才是同一种排布。
/// - 底部让位统一为「安全区 + 16 + [extraBottomInset]」：分页模式下把
///   `PaginationBar.barHeight` 传进来，坞会整体抬到分页栏之上。
class GlassCornerDock extends StatelessWidget {
  const GlassCornerDock({
    super.key,
    required this.corner,
    required this.children,
    this.extraBottomInset = 0,
    this.sideMargin = 16,
  });

  final GlassDockCorner corner;

  /// 自上而下堆叠的浮层件。已经在退场（[GlassReveal] 收干净）的项会自己塌成
  /// 零尺寸，坞不必知道谁在场。
  final List<Widget> children;

  /// 额外的底部让位（分页栏一类页面自带的常驻底部浮层）。
  final double extraBottomInset;

  /// 距屏幕侧缘的距离。与回顶浮钮历来用的 16 一致。
  final double sideMargin;

  @override
  Widget build(BuildContext context) {
    final bool left = corner == GlassDockCorner.bottomLeft;
    final double bottom =
        computeBottomSafeInset(MediaQuery.of(context)) + 16 + extraBottomInset;

    final List<Widget> column = [];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) column.add(const SizedBox(height: GlassTokens.chromeGap));
      column.add(children[i]);
    }

    // 让位是动画的：分页模式一开，底部会推上来一条分页栏
    // （[GlassTokens.bottomBarDuration]），坞得跟着它一起升，而不是瞬间跳高
    // 46px 再干等栏滑上来。首帧不动画（AnimatedPositioned 的语义），所以进页面
    // 时坞直接就在正确高度。
    return AnimatedPositioned(
      duration: GlassTokens.bottomBarDuration,
      curve: GlassTokens.motionCurve,
      left: left ? sideMargin : null,
      right: left ? null : sideMargin,
      bottom: bottom,
      // 只钉一侧的 Positioned 给子级的是**无界**宽度约束（RenderStack 的
      // 规矩：左右都不钉就不 tighten）。坞里可能站着按可用宽度决定形态的东西
      // （分段胶囊那一族），无界宽度下它们量到的是 Infinity；这里补一条
      // 「屏宽减两侧留白」的上界，既让量宽有意义，也保证长文案不会顶出屏幕。
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: (MediaQuery.sizeOf(context).width - sideMargin * 2).clamp(
            0.0,
            double.infinity,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: left
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: column,
        ),
      ),
    );
  }
}
