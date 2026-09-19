import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/media_card_meta.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// 本机文件所有卡片的外壳：**与线上视频卡同一副样子**。
///
/// 白卡 + 一圈淡描边 + 一层很轻的阴影，封面 16:9 顶在上沿，下面是恒占两行的
/// 标题和一行说明，⋮ 在说明行右端。数值照抄 `VideoCardListItemWidget`
/// （14 圆角、outlineVariant 30% 描边、shadow 8% / 模糊 8 / 下移 3、标题 14 号
/// 1.22 行高 w700）。
///
/// # 为什么跟线上卡一个样
///
/// 2026-09-19 前后改了三版：夹子剪影 + 带主色底板、去底板把字落在页面上……用户
/// 都嫌丑。给了三种样式对照（线上同款 / 封面叠字 / 横向列表行），用户选了线上
/// 同款。本机文件与首页视频列表是同一个应用里的两块，卡片语言一致本身就是观感的
/// 一大半——各自一套，再精致也像拼起来的。
///
/// # 容器与媒体怎么分
///
/// 外壳一样，区别在**标题前的种类图标**（文件夹 / NAS / 已下载 / 图库）和说明行
/// 的内容（计数 vs 出处）；视频封面上有时长胶囊，容器没有。以前那只文件夹剪影
/// 已删：外形分家的代价是两族卡片高度、圆角、留白全都对不齐。
///
/// # ⛔ 定高
///
/// 网格用 `SliverGrid` + 固定 `mainAxisExtent` 铺，高度由 [extentFor] 从格宽
/// 算出。标题短到一行也占两行的位置（用户明确要求：标题默认显示两行），说明只许
/// 一行。想往卡面上加东西只能加在封面上（角标），不能加在文字区里。
class LocalCardShell extends StatelessWidget {
  const LocalCardShell({
    super.key,
    required this.cover,
    required this.title,
    required this.meta,
    this.titleIcon,
    this.onTap,
    this.onMenu,
    this.onLongPress,
  });

  /// 封面比例。两族卡片同一个，同一张网格里的行高才对得齐。
  static const double coverAspectRatio = 16 / 9;

  static const double radius = kMediaCardThumbnailRadius;

  /// 给定格宽下一张卡的总高。
  static double extentFor(BuildContext context, double cellWidth) =>
      cellWidth / coverAspectRatio + LocalCardText.blockExtent(context);

  /// 封面（连同压在上面的角标），会被裁进卡片上沿的圆角里。
  final Widget cover;

  final String title;
  final IconData? titleIcon;

  /// 说明行。纯文字用 [LocalCardText.metaText] 包一下。
  final Widget meta;

  final VoidCallback? onTap;

  /// 「更多操作」：⋮ 与长按整卡都开它。
  ///
  /// ⛔ ⋮ 与长按由这一层统一发，卡片只说「我有哪些操作」：来源卡当初就是自己画
  /// ⋮、忘了接长按，长按子目录有菜单、长按来源没反应（2026-09-11）。只留长按也
  /// 不行——用户不知道有这个功能（2026-09-10）。
  final void Function(BuildContext anchorContext)? onMenu;

  /// 覆盖长按。一般不传：长按默认就是 [onMenu]。
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const borderRadius = BorderRadius.all(Radius.circular(radius));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        // Builder 拿**卡片自己**那层 context 当长按菜单的锚点：菜单该贴着这张卡
        // 开，而不是贴着调用方那个撑满整条 sliver 的 context。
        child: Builder(
          builder: (cardContext) => InkWell(
            onTap: onTap,
            onLongPress:
                onLongPress ??
                (onMenu == null ? null : () => onMenu!(cardContext)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(aspectRatio: coverAspectRatio, child: cover),
                Expanded(
                  child: LocalCardText(
                    title: title,
                    titleIcon: titleIcon,
                    meta: meta,
                    onMenu: onMenu,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 「容器」卡：来源、目录、下载图库，凡是**点进去还有东西**的。
///
/// 外壳是 [LocalCardShell]，在它上面加两样视频卡没有的东西：
///
/// - **叠纸**：卡片背后从上沿露出两层纸边（[stackReveal]），轮廓一眼就是「一叠
///   东西」。这是跟视频拉开的主力——2026-09-19 用户在同款外壳上仍嫌「视频和文件夹
///   差异不够明显」，从叠纸 / 页签 / 封面拼贴三案里选了叠纸。拼贴没选：每张卡要
///   多查库、多解码几张图，跟定高提速的初衷相悖。
/// - **封面右下角的「文件夹 + 项数」胶囊**，占的正是视频卡「▶ 时长」胶囊的位置：
///   同一个位置，一边说「能播、多长」，一边说「能进、多少件」。
///
/// 封面上另有两个角标槽——左上（常用图钉，或调用方给的记号）、右上（扫描中的转圈）。
class LocalContainerCard extends StatelessWidget {
  const LocalContainerCard({
    super.key,
    required this.cover,
    required this.title,
    required this.meta,
    this.titleIcon,
    this.leading,
    this.trailing,
    this.pinned = false,
    this.onMenu,
    this.onTap,
    this.onLongPress,
    this.itemCount,
    this.countIcon = Icons.folder_outlined,
  });

  /// 叠纸从卡片上沿露出来的高度（两层各一半）。卡片总高比视频卡多出的就是它。
  static const double stackReveal = 12;

  /// 封面上那几枚角标（星 / 图钉 / 转圈 / 规格）离封面边的距离。
  ///
  /// ⛔ 这是**两族卡片共用**的一个数：容器卡和媒体卡常常并排出现，角标离边距离
  /// 一分家，一眼就能看出两边不是一套东西。
  static const double badgeInset = 6;

  /// 给定格宽下一张容器卡的总高。与媒体卡同一个算法（[LocalCardShell.extentFor]）。
  static double extentFor(BuildContext context, double cellWidth) =>
      stackReveal + LocalCardShell.extentFor(context, cellWidth);

  final Widget cover;
  final String title;

  /// 标题前的种类图标：容器与媒体长同一副外壳，靠它一眼分开。
  final IconData? titleIcon;

  /// 说明行（计数或状态）。
  final Widget meta;

  /// 封面左上角的角标。留空时由 [pinned] 自动画那枚图钉；只有要画**别的东西**
  /// （「下载完成图库」那枚下载完成角标）时才传。
  final Widget? leading;

  /// 封面右上角的状态角标（来源卡扫描中那枚转圈）。
  final Widget? trailing;

  /// 这张卡代表的东西被设为常用了：左上角画一枚图钉。
  ///
  /// ⛔ 图钉由这一层画，别再让每张卡自己拼一遍：来源卡就是因为自己没拼，
  /// 在「文件目录」里把一个来源设为常用之后**卡片上什么都不长**（2026-09-11）。
  final bool pinned;

  final void Function(BuildContext anchorContext)? onMenu;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 里面一共多少件（子目录 + 视频 + 图片），画在封面右下角的胶囊里。
  /// null＝还没数过，胶囊只剩一枚图标——记号在就够了，不猜数字。
  final int? itemCount;

  /// 胶囊里那枚图标。下载图库用相册图标，其余是文件夹。
  final IconData countIcon;

  /// 角标出入场的时长，与媒体卡精选星标那枚（`local_media_item_card.dart`）一致。
  static const Duration badgeSwitchDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = BorderSide(color: scheme.outlineVariant);
    // 纸边要一眼看得见：第一版用 surfaceContainerHigh/Highest，真机上跟页面底色
    // 几乎一样，叠纸等于没画。改成在卡面色上压一层前景色，深浅跟主题走。
    Color shade(double alpha) => Color.alphaBlend(
      scheme.onSurface.withValues(alpha: alpha),
      scheme.surface,
    );
    // 纸边只画露出来的那一截：一块顶上圆角的矩形，被前面的卡盖住下半。越靠后
    // 越窄、越深一档——不用 Opacity（那是一层 saveLayer，一屏几十张卡都要还）。
    Widget sheet(double inset, double top, Color color) => Positioned(
      left: inset,
      right: inset,
      top: top,
      height: LocalCardShell.radius * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.fromBorderSide(border),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(LocalCardShell.radius),
          ),
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        sheet(16, 0, shade(0.14)),
        sheet(8, stackReveal / 2, shade(0.07)),
        Padding(
          padding: const EdgeInsets.only(top: stackReveal),
          child: LocalCardShell(
            title: title,
            titleIcon: titleIcon,
            meta: meta,
            onTap: onTap,
            onMenu: onMenu,
            onLongPress: onLongPress,
            cover: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                cover,
                _leadingBadge(theme),
                _trailingBadge(),
                Positioned(
                  right: badgeInset,
                  bottom: badgeInset,
                  child: LocalCountPill(icon: countIcon, count: itemCount),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 左上角那枚角标：[leading] 优先，没传就按 [pinned] 画那枚常用图钉。
  Widget _leadingBadge(ThemeData theme) {
    final Widget content;
    if (leading != null) {
      content = KeyedSubtree(
        key: const ValueKey<String>('leading'),
        child: leading!,
      );
    } else if (pinned) {
      content = LocalCardBadge(
        key: const ValueKey<String>('pinned'),
        child: Padding(
          padding: const EdgeInsets.all(4),
          // 常用＝图钉，与「常用目录」栏同一枚；星只留给视频「精选」。两件事共用
          // 一颗星时，用户点了星却在精选栏里找不到它。
          child: Icon(
            Icons.push_pin_rounded,
            size: 15,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    } else {
      content = const SizedBox.shrink(key: ValueKey<String>('none'));
    }
    return Positioned(
      top: badgeInset,
      left: badgeInset,
      child: _BadgeSwitcher(child: content),
    );
  }

  /// 封面右上角的状态角标（来源卡扫描中那枚转圈）。
  Widget _trailingBadge() {
    final Widget content = trailing != null
        ? KeyedSubtree(
            key: const ValueKey<String>('trailing'),
            child: trailing!,
          )
        : const SizedBox.shrink(key: ValueKey<String>('none'));
    return Positioned(
      top: badgeInset,
      right: badgeInset,
      child: _BadgeSwitcher(child: content),
    );
  }
}

/// 卡片封面以下那块字：**标题恒占两行 + 一行说明**，⋮ 挂在说明行右端。
///
/// 标题短到一行也占两行的位置（用户要求「默认显示两行」）：一排卡片的说明行因此
/// 落在同一条水平线上，卡片也才定得了高。
///
/// # 只写人要读的东西
///
/// 标题回答「这是什么」，说明回答「它从哪来 / 里面有什么」。机器信息（时长、画质、
/// VR、进度）一律做成封面角标；路径、体积这类要用时才查的东西在信息弹窗里，不上
/// 卡面（2026-09-19 用户：「里面有非必要信息」）。
///
/// # ⛔ 行高是强制的，不是量出来的
///
/// 标题与说明都挂 `forceStrutHeight` 的 [StrutStyle]：每一行的高度就是
/// 「字号 × 行高系数」，不会因为混进一个 emoji、换了一个回退字体而多出一两像素
/// ——那一两像素在定高的格子里就是 `BOTTOM OVERFLOWED`。[blockExtent] 与这里
/// 画字用的是同一组常数。
///
/// 字号跟着系统缩放，但夹在 2 倍以内（同一个 [TextScaler] 既用来算高、也用来
/// 画字）。再大只能靠省略号，不能让网格无限长高。
class LocalCardText extends StatelessWidget {
  const LocalCardText({
    super.key,
    required this.title,
    required this.meta,
    this.titleIcon,
    this.onMenu,
  });

  final String title;
  final IconData? titleIcon;
  final Widget meta;
  final void Function(BuildContext anchorContext)? onMenu;

  static const int titleLines = 2;

  // 标题字样与线上视频卡（`VideoCardListItemWidget`）一致。
  static const double _titleSize = 14;
  static const double _titleHeight = 1.22;
  static const double _metaSize = 12;
  static const double _metaHeight = 1.4;

  /// 文字区的内边距。右边比左边窄：说明行右端那枚 ⋮ 自带点击留白。
  static const EdgeInsets padding = EdgeInsets.fromLTRB(10, 10, 4, 5);

  /// 标题右侧补回的那一截，让标题与左边对称（说明行靠 ⋮ 的留白对称）。
  static const double _titleEndInset = 6;

  /// 标题与说明行之间的缝。
  static const double gap = 5;

  /// ⋮ 那一格的边长。说明行至少这么高。
  static const double menuExtent = 28;

  static TextScaler scalerOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2);

  /// 标题那两行的高度。+1 是给浮点取整留的余量。
  static double titleExtent(BuildContext context) =>
      (scalerOf(context).scale(_titleSize) * _titleHeight * titleLines)
          .ceilToDouble() +
      1;

  /// 一条说明行的字高。
  static double metaExtent(BuildContext context) =>
      (scalerOf(context).scale(_metaSize) * _metaHeight).ceilToDouble() + 1;

  static double _rowExtent(BuildContext context) =>
      math.max(metaExtent(context), menuExtent);

  /// 整块文字区（含 [padding]）的高度。
  static double blockExtent(BuildContext context) =>
      padding.vertical + titleExtent(context) + gap + _rowExtent(context);

  static const StrutStyle _metaStrut = StrutStyle(
    fontSize: _metaSize,
    height: _metaHeight,
    forceStrutHeight: true,
  );

  /// 说明行的字样：12 号、次要色、等宽数字。
  static TextStyle? metaStyle(ThemeData theme, {Color? color}) =>
      theme.textTheme.bodySmall?.copyWith(
        fontSize: _metaSize,
        height: _metaHeight,
        color: color ?? theme.colorScheme.onSurfaceVariant,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      );

  /// 一条纯文字的说明行。
  static Widget metaText(BuildContext context, String text, {Color? color}) =>
      Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        strutStyle: _metaStrut,
        style: metaStyle(Theme.of(context), color: color),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: _titleSize,
      height: _titleHeight,
      fontWeight: FontWeight.w700,
    );
    // 子树里的字（包括调用方塞进来的说明行）一律用算高时那一把尺子。
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 2,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: titleExtent(context),
              child: Padding(
                padding: const EdgeInsets.only(right: _titleEndInset),
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      if (titleIcon != null) ...<InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            titleIcon,
                            size: 15,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const TextSpan(text: ' '),
                      ],
                      TextSpan(text: title),
                    ],
                  ),
                  maxLines: titleLines,
                  overflow: TextOverflow.ellipsis,
                  strutStyle: const StrutStyle(
                    fontSize: _titleSize,
                    height: _titleHeight,
                    forceStrutHeight: true,
                  ),
                  style: titleStyle,
                ),
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: _rowExtent(context),
              child: Row(
                children: <Widget>[
                  Expanded(child: meta),
                  if (onMenu != null) _MenuDots(onMenu: onMenu!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 说明行右端那枚 ⋮：不带底色，只是一枚次要色的图标（线上卡同一个位置）。
class _MenuDots extends StatelessWidget {
  const _MenuDots({required this.onMenu});

  final void Function(BuildContext anchorContext) onMenu;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (anchorContext) => GlassTapArea(
      onTap: () => onMenu(anchorContext),
      onLongPress: () => onMenu(anchorContext),
      opensOverlay: true,
      longPressOpensOverlay: true,
      child: SizedBox.square(
        dimension: LocalCardText.menuExtent,
        child: Icon(
          Icons.more_vert,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

/// 容器卡左右两个角标槽的出入场。
///
/// ⛔ 两个槽都**恒挂**这一层，内容为空时是一枚带 key 的 `SizedBox.shrink`，
/// 别改回「没内容就整个 Positioned 不出现」：那样设为常用的星、扫描中的转圈
/// 都是硬切出现、硬切消失（本项目要求出现与消失都必须有动画）。
///
/// 切换判据是子节点的 key（`pinned` / `menu` / `trailing` …），由调用方按
/// 「这一槽现在是哪种东西」给出——同一种东西内部的变化（图标颜色之类）不重播。
class _BadgeSwitcher extends StatelessWidget {
  const _BadgeSwitcher({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: LocalContainerCard.badgeSwitchDuration,
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation, child: child),
    ),
    child: child,
  );
}

/// 卡片封面右上角那枚 ⋮。
///
/// ⛔ 容器卡、媒体卡、图片格子共用这一份，别再各自拼一遍：三处原本是三段一模一样
/// 的 `DecoratedBox + GlassTapArea + Icon`，尺寸却各写各的，改一处只能改到三分之
/// 一。点按与长按都开同一份菜单，锚点取这枚按钮自己的 context。
class LocalCardMenuBadge extends StatelessWidget {
  const LocalCardMenuBadge({super.key, required this.onMenu});

  /// 图标本体的大小。
  static const double iconSize = 18;

  /// 图标四周的内边距。加上 [iconSize] 就是这枚圆底的直径（34）——两族卡片并排
  /// 时靠它保证 ⋮ 一样大。
  static const double iconPadding = 8;

  final void Function(BuildContext anchorContext) onMenu;

  @override
  Widget build(BuildContext context) => LocalCardBadge(
    child: Builder(
      builder: (anchorContext) => GlassTapArea(
        onTap: () => onMenu(anchorContext),
        onLongPress: () => onMenu(anchorContext),
        opensOverlay: true,
        longPressOpensOverlay: true,
        child: Padding(
          padding: const EdgeInsets.all(iconPadding),
          child: Icon(
            Icons.more_vert,
            size: iconSize,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}

/// 容器卡封面上那枚圆形角标的底（星标 / ⋮ / 转圈都套它）。
class LocalCardBadge extends StatelessWidget {
  const LocalCardBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
      shape: BoxShape.circle,
    ),
    child: child,
  );
}

/// 封面右下角那枚「这是一段视频」的胶囊（播放三角 + 可选时长）。
///
/// ⛔ 底色写死成半透明黑、字写死成白，**不跟主题走**：它压在用户自己的封面上，
/// 而封面什么颜色都可能是。跟着 `colorScheme` 走的话，浅色主题下就是白底黑字压在
/// 一张过曝的截图上，等于没有。
///
/// 时长可能拿不到（本地库还没派生出 `durationMs`、或者这一格根本不来自本地库），
/// 那时只剩一枚播放三角——记号在就够了，宁可少一个数字，也不能让这一格看起来
/// 不是视频。
///
/// ⛔ 媒体卡与「已下载图库」里混着的短片共用这一份：两处原本一个有一个没有，于是
/// 同一个 `.webm` 在媒体墙上是「一段视频」、在图库网格里是「一张读不出来的图」。
class LocalPlaybackPill extends StatelessWidget {
  const LocalPlaybackPill({super.key, this.duration});

  final String? duration;

  @override
  Widget build(BuildContext context) {
    final label = duration;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, label == null ? 4 : 5, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.play_arrow_rounded, size: 13, color: Colors.white),
            if (label != null) ...<Widget>[
              const SizedBox(width: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 封面右上角的规格角标（「4K」「VR180」）。
///
/// 与 [LocalPlaybackPill] 同一副样子——半透明黑底、白字、写死不跟主题走，理由
/// 同那边：它压在用户自己的封面上。两枚记号长得一样，读起来才是「封面上的一组
/// 规格」，而不是两套装饰。
class LocalCoverTag extends StatelessWidget {
  const LocalCoverTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );
}

/// 容器卡封面右下角那枚「图标 + 项数」胶囊，与视频卡的 [LocalPlaybackPill] 占
/// 同一个位置、同一副样子（半透明黑底白字，理由同那边）。
class LocalCountPill extends StatelessWidget {
  const LocalCountPill({super.key, required this.icon, this.count});

  final IconData icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    // 0 件不写数字：「📁 0」读起来像出错了，空不空由说明行那句话交代。
    final label = (count ?? 0) > 0 ? count : null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 2, label == null ? 5 : 6, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13, color: Colors.white),
            if (label != null) ...<Widget>[
              const SizedBox(width: 3),
              Text(
                CommonUtils.formatFriendlyNumber(label),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
