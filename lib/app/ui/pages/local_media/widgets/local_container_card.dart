import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';

/// 「容器」这一族卡片的外形与骨架：来源、目录，凡是**点进去还有东西**的都长这样。
///
/// # 为什么要单独有这么一族
///
/// 2026-09-11 用户原话：「文件夹和视频的卡片长得好像啊，不然用户分不清」。
/// 当时两边用的是同一套语言——一张顶天立地的封面、底下两行字、右上角一枚 ⋮，
/// 差别只剩文字内容。可文字要读，形状不用读：一屏几十格滑过去，用户是靠轮廓
/// 认东西的，轮廓一样就等于没有区别。
///
/// 所以差异必须做在**形状**上，而不是颜色深浅或者多加一枚小角标：
///
/// - **卡片本体是一只文件夹的剪影**（左上角一枚翻页舌 [tabHeight]）。这是所有人
///   不用学就认得的符号，缩到手机上一格 150px 宽也还认得出。
/// - **封面是「装在里面」的**：四周留 [coverInset] 的边，自己带圆角，浮在夹子
///   的底色上。媒体卡的封面是**顶到边**的——封面即内容本身；容器卡的封面只是
///   里面某一件东西的样子，留边就是在说这件事。
/// - **底色带一点主色**，跟媒体卡的中性卡面分开。
///
/// 反过来，媒体卡那边加了「时长胶囊」这类只有媒体才会有的东西（见
/// `local_media_item_card.dart`），两边是一起往相反方向拉开的。
///
/// # ⛔ 差异只做一份
///
/// 目录卡和来源卡都从这里取外形，别再各自画一遍——两边一分家，下次改夹子的
/// 舌头就会只改到一半（本项目已有明确要求：同类问题按机制修，不要一处一处改）。
class LocalContainerCard extends StatelessWidget {
  const LocalContainerCard({
    super.key,
    required this.cover,
    required this.lines,
    this.leading,
    this.trailing,
    this.pinned = false,
    this.onMenu,
    this.onTap,
    this.onLongPress,
    this.coverAspectRatio = 16 / 10,
  });

  /// 夹子左上那枚翻页舌的高度。卡片总高比封面 + 文字多出的就是它。
  static const double tabHeight = 13;

  /// 封面四周留的边——「装在夹子里」这个观感全靠它。
  static const double coverInset = 6;

  /// 封面自己的圆角。比卡片本体的小一档，看起来才像是叠在上面的一张纸。
  static const double coverRadius = 9;

  /// 卡片本体的圆角。
  static const double bodyRadius = 15;

  /// 封面上那几枚角标（⋮ / 星 / 转圈）离封面边的距离。
  ///
  /// ⛔ 这是**两族卡片共用**的一个数：容器卡和媒体卡常常并排出现，角标的大小和
  /// 离边距离一分家，一眼就能看出两边不是一套东西。之前容器卡是 1（⋮ 的圆底正
  /// 好贴死在封面圆角上）、媒体卡是 2、星标又是 6，三处各写各的。
  static const double badgeInset = 6;

  /// 文字区上下的固定内边距，[textExtentOf] 的常数项就是它。
  static const EdgeInsets textPadding = EdgeInsets.fromLTRB(10, 8, 10, 10);

  /// 一张容器卡在给定格宽下的总高。
  ///
  /// 网格靠 `mainAxisExtent` 铺，行高必须**算得出来**而不是量出来；这里是唯一
  /// 的算法出处，调用方只管把格宽递进来。
  ///
  /// [textExtent] 是文字区的高度（含 [textPadding]），由各张卡按自己有几行字
  /// 给出，见 `LocalFolderCardWidget.textExtent`。
  static double extentFor({
    required double cellWidth,
    required double coverAspectRatio,
    required double textExtent,
  }) {
    final coverWidth = math.max(1.0, cellWidth - coverInset * 2);
    return tabHeight + coverInset + coverWidth / coverAspectRatio + textExtent;
  }

  /// 文字区高度：[lines] 行正文 + [textPadding]，跟着系统字号缩放。
  ///
  /// ⛔ 别写成常数：用户把字体调到最大时，写死的高度会把最后一行切掉半截。
  /// 上限钉在 2 倍——再大只能靠省略号，不能让网格无限长高。
  ///
  /// 每行 20 是「一行正文 + 行间距」量出来的 19 再留 1px 余量；贴着量真机上会
  /// 吐 `BOTTOM OVERFLOWED BY 1.00 PIXELS`，字体度量各机不同，不留余量必翻车。
  static double textExtentOf(BuildContext context, {required int lines}) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return textPadding.vertical + 20 * lines * scale;
  }

  /// 夹子里那张封面。会被裁成 [coverRadius] 的圆角。
  final Widget cover;

  /// 封面以下的几行字，从上到下。行数要和 [textExtentOf] 传的一致。
  final List<Widget> lines;

  /// 封面左上角的角标。留空时由 [pinned] 自动画那枚星；只有要画**别的东西**
  /// （「下载完成图库」那枚下载完成角标）时才传。
  final Widget? leading;

  /// 封面右上角的角标。留空时由 [onMenu] 自动画那枚 ⋮；只有要画**别的东西**
  /// （来源卡扫描中那枚转圈）时才传。
  final Widget? trailing;

  /// 这张卡代表的东西被设为常用了：左上角画一枚星。
  ///
  /// ⛔ 星标由这一层画，别再让每张卡自己拼一遍：来源卡就是因为自己没拼，
  /// 在「文件目录」里把一个来源设为常用之后**卡片上什么都不长**，用户得切到
  /// 「常用目录」才看得到那枚星（2026-09-11 用户报的）。同 [onMenu] 那条理由——
  /// 同一族卡片的共同特征归这一层，卡片只负责说"我是不是"。
  final bool pinned;

  /// 「更多操作」。给了它，这张卡就**同时**长出右上角那枚 ⋮ 和整卡长按，两个入口
  /// 走同一份菜单。
  ///
  /// # ⛔ 别再回到「每张卡自己画 ⋮、自己接 onLongPress」那一套
  ///
  /// 来源卡就是那么漏掉长按的：它画了 ⋮、也给那枚 ⋮ 接了长按，唯独忘了把
  /// `onLongPress` 递给这一层——于是长按子目录有菜单、长按来源没反应
  /// （2026-09-11 用户报的正是这个）。手势由这一层统一发，卡片只负责说"我有哪些
  /// 操作"，就没有哪张卡还能漏。
  final void Function(BuildContext anchorContext)? onMenu;

  final VoidCallback? onTap;

  /// 覆盖长按。⛔ 一般**不要传**：长按默认就是 [onMenu]，两个入口一份菜单是这一
  /// 族卡片的约定。只有确实要让长按做别的事时才用它。
  final VoidCallback? onLongPress;

  final double coverAspectRatio;

  /// 夹子的底色：中性卡面掺一点主色。
  ///
  /// 单靠深浅差在深色主题上会糊成一片，掺主色才是能同时在明暗两套主题里站住的
  /// 差异。分量刻意压得很低——它是背景，抢眼的应该是封面。
  static Color bodyColor(ColorScheme scheme) => Color.alphaBlend(
    scheme.primary.withValues(alpha: 0.07),
    scheme.surfaceContainerHigh,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: bodyColor(theme.colorScheme),
      clipBehavior: Clip.antiAlias,
      shape: const LocalFolderShape(),
      // Builder 是为了拿到**卡片自己**那层 context 当菜单锚点：长按整张卡时，
      // 菜单该贴着这张卡开，而不是贴着调用方那个撑满整条 sliver 的 context。
      child: Builder(
        builder: (cardContext) => InkWell(
          onTap: onTap,
          onLongPress:
              onLongPress ??
              (onMenu == null ? null : () => onMenu!(cardContext)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: tabHeight),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: coverInset),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(coverRadius),
                  child: AspectRatio(
                    aspectRatio: coverAspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        cover,
                        ?_leadingBadge(theme),
                        ?_menuBadge(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: textPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: lines,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 左上角那枚角标：[leading] 优先，没传就按 [pinned] 画那枚常用星。
  Widget? _leadingBadge(ThemeData theme) {
    final Widget? content =
        leading ??
        (pinned
            ? LocalCardBadge(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : null);
    if (content == null) return null;
    return Positioned(top: badgeInset, left: badgeInset, child: content);
  }

  /// 右上角那枚角标：[trailing] 优先，没传就按 [onMenu] 画标准的 ⋮。
  Widget? _menuBadge() {
    final Widget? content =
        trailing ??
        (onMenu == null ? null : LocalCardMenuBadge(onMenu: onMenu!));
    if (content == null) return null;
    return Positioned(top: badgeInset, right: badgeInset, child: content);
  }
}

/// 一只文件夹的剪影：左上角一枚翻页舌，其余是普通圆角矩形。
///
/// 舌头宽度按卡片宽度取比例（窄屏上也还是一枚舌头，不是一条横杠），右端斜切下来
/// 接到本体，转角都用二次贝塞尔抹圆——直角的舌头看着像个缺口，不像夹子。
///
/// ⛔ 裁剪归 [Material]（`clipBehavior` + `shape`），别在外面再套一层 `ClipPath`：
/// 多一层裁剪就多一次离屏合成，一屏几十格是要还的。
class LocalFolderShape extends OutlinedBorder {
  const LocalFolderShape({
    super.side = BorderSide.none,
    this.tabHeight = LocalContainerCard.tabHeight,
    this.bodyRadius = LocalContainerCard.bodyRadius,
  });

  final double tabHeight;
  final double bodyRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  LocalFolderShape copyWith({
    BorderSide? side,
    double? tabHeight,
    double? bodyRadius,
  }) => LocalFolderShape(
    side: side ?? this.side,
    tabHeight: tabHeight ?? this.tabHeight,
    bodyRadius: bodyRadius ?? this.bodyRadius,
  );

  @override
  ShapeBorder scale(double t) => LocalFolderShape(
    side: side.scale(t),
    tabHeight: tabHeight * t,
    bodyRadius: bodyRadius * t,
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  Path _path(Rect rect) {
    final r = math.min(bodyRadius, math.min(rect.width, rect.height) / 2);
    // 舌角比本体的角小一档：一样大会把那点斜切吃光，看起来就成了圆角缺口。
    final tr = r * 0.45;
    final th = math.min(tabHeight, rect.height / 3);
    // 舌头占卡宽的三分之一多一点。窄屏上给个下限，宽屏上留住右边的空当——两头
    // 不夹住的话，平板上它会长成半张卡宽的一条横杠，夹子的形就没了。
    final tabWidth = (rect.width * 0.38).clamp(
      math.min(56.0, rect.width * 0.5),
      math.max(56.0, rect.width - r * 3),
    );
    final slant = th * 0.85;

    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;
    final bodyTop = top + th;
    final tabRight = left + tabWidth;

    return Path()
      ..moveTo(left, top + tr)
      ..quadraticBezierTo(left, top, left + tr, top)
      ..lineTo(tabRight - slant - tr * 0.5, top)
      // 舌头右上角 → 斜切 → 落到本体上沿，两头各抹一个小圆角。
      ..quadraticBezierTo(
        tabRight - slant,
        top,
        tabRight - slant + tr * 0.35,
        top + tr * 0.6,
      )
      ..lineTo(tabRight - tr * 0.35, bodyTop - tr * 0.6)
      ..quadraticBezierTo(tabRight, bodyTop, tabRight + tr, bodyTop)
      ..lineTo(right - r, bodyTop)
      ..quadraticBezierTo(right, bodyTop, right, bodyTop + r)
      ..lineTo(right, bottom - r)
      ..quadraticBezierTo(right, bottom, right - r, bottom)
      ..lineTo(left + r, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - r)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(_path(rect.deflate(side.strokeInset)), side.toPaint());
  }

  @override
  bool operator ==(Object other) =>
      other is LocalFolderShape &&
      other.side == side &&
      other.tabHeight == tabHeight &&
      other.bodyRadius == bodyRadius;

  @override
  int get hashCode => Object.hash(side, tabHeight, bodyRadius);
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
