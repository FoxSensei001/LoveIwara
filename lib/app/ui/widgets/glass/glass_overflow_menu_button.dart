import 'dart:async';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// header 动作胶囊里「更多」菜单的一个条目。
///
/// 只描述「这枚动作长什么样、按下去做什么」，至于它最终是**菜单里的一行**还是
/// **胶囊上的一枚图标位**，由 [GlassOverflowMenuButton] 按条目数量自己决定。
class GlassMenuAction {
  const GlassMenuAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.destructive = false,
    this.showsLoading = false,
  });

  /// 菜单行左侧的图标；只剩这一条被提到胶囊上时，它就是按钮本身的图标。
  final IconData icon;

  /// 菜单行的文案；提到胶囊上时降级为 tooltip。
  final String label;

  final FutureOr<void> Function() onSelected;

  /// 破坏性动作（删除一类），菜单里用红色。
  final bool destructive;

  /// 耗时动作（刷新一类）：被提到胶囊上单独显示时，按钮自己跟着 Future 走
  /// 沙漏态（[GlassAsyncIconButton]）。菜单行里不需要——弹层一关本身就是反馈。
  ///
  /// 代价是这枚位子在 `⋮` ↔ 单动作之间互换时没有图标交叉过渡（widget 类型变了），
  /// 换来的是每次点按都有「已经在做了」的反馈；耗时动作按这个取舍来。
  final bool showsLoading;
}

/// 「更多」菜单位：条目多了是 `⋮` 弹菜单，只剩一条时**直接把那条动作显示出来**。
///
/// 起因是论坛帖子列表页在宽屏下的实况——搜索键已经被提到胶囊上了，`⋮` 点开只剩
/// 孤零零一个「瀑布流/分页」。为了一个选项让用户多点一次、还多看一次弹层，
/// 是纯粹的浪费：这时该显示的就是那枚动作本身。
///
/// 三档（[actions] 由调用方用 `if (...)` 现场过滤，这里只看最终条数）：
///   - 0 条 → 整个按钮位收起（外层若在 [GlassButtonGroup] 里，请自行套
///     `GlassGroupSlot` 让宽度收得有过渡）；
///   - 1 条 → 直接渲染成该动作的图标位，点按即执行，label 降级为 tooltip；
///   - ≥2 条 → `⋮`，点开弹菜单。
///
/// 三档共用同一个 [GlassIconButton]（菜单不用 `PopupMenuButton` 而是自己
/// [showGlassMenu]），所以 widget 类型全程不变，`⋮` ↔ 具体动作图标的互换自动走
/// [GlassIconButton] 内置的 `GlassAnimatedIcon` 缩放交叉过渡，而不是瞬间跳一下
/// ——这条是「液态玻璃 header 形变词汇表」里对按钮位换图标的统一要求。
class GlassOverflowMenuButton extends StatelessWidget {
  const GlassOverflowMenuButton({
    super.key,
    required this.actions,
    this.tooltip,
    this.standalone = false,
  });

  final List<GlassMenuAction> actions;

  /// `⋮` 态的 tooltip；不传用系统的「显示菜单」。
  /// 收起成单个动作时一律用该动作自己的 label，与此项无关。
  final String? tooltip;

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (actions.length == 1) {
      final action = actions.single;
      if (action.showsLoading) {
        return GlassAsyncIconButton(
          icon: Icon(action.icon),
          tooltip: action.label,
          standalone: standalone,
          onPressed: () async => action.onSelected(),
        );
      }
      return GlassIconButton(
        icon: Icon(action.icon),
        tooltip: action.label,
        standalone: standalone,
        onPressed: action.onSelected,
      );
    }

    return Builder(
      builder: (anchorContext) => GlassIconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        standalone: standalone,
        onPressed: () => _openMenu(anchorContext),
      ),
    );
  }

  Future<void> _openMenu(BuildContext anchorContext) async {
    final selected = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        for (var i = 0; i < actions.length; i++)
          GlassMenuOption<int>(
            value: i,
            icon: actions[i].icon,
            label: actions[i].label,
            destructive: actions[i].destructive,
          ),
      ],
    );

    if (selected == null) return;
    // 菜单是自带路由的弹层，选完这一帧按钮可能已经不在树上了
    if (selected < 0 || selected >= actions.length) return;
    actions[selected].onSelected();
  }
}

/// 与 [GlassButtonGroup] 里其它图标位等宽的「更多」菜单位。
///
/// [GlassOverflowMenuButton] 自身不锁尺寸（独立圆钮场景要跟 pillHeight 走），
/// 进胶囊组时统一用这个包一层，省得每处都抄一遍 40×40 的 SizedBox。
class GlassGroupOverflowMenuButton extends StatelessWidget {
  const GlassGroupOverflowMenuButton({
    super.key,
    required this.actions,
    this.tooltip,
  });

  final List<GlassMenuAction> actions;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: GlassTokens.groupIconButtonSize,
      height: GlassTokens.groupIconButtonSize,
      child: GlassOverflowMenuButton(actions: actions, tooltip: tooltip),
    );
  }
}
