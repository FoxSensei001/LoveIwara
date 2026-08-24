import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// # 批量选择态的统一表达
///
/// 全站十处批量能力（下载 / 删除 / 移至分类 / 取消最爱 / 移出播放列表 …）
/// 共用这一套控件。进入选择态是**一次页面级的模式切换**，而不是"在角落里
/// 加几个浮钮"——三层同时形变，全部走 [GlassTokens] 的时值与曲线：
///
/// 1. **header 中间胶囊** 换成 [GlassSelectionSummary]（已选 N 项 + 全选），
///    由页面自己用 [GlassCapsuleMorph] 包住，与分段胶囊单壳交接；
/// 2. **与选择无关的键**（刷新 / 瀑布分页 / 更多）用 `GlassGroupSlot` 收走，
///    只留「多选 ↔ 退出」那一枚在原位做图标交叉过渡；
/// 3. **动作区**：
///    - 瀑布流模式 → [GlassSelectionDock]，从底部浮上来的独立玻璃胶囊；
///    - 分页模式 → **不另起一条**，由 `PaginationBar` 读取
///      [BatchSelectionScope] 把自己的内容换成动作行（见
///      `common_media_list_widgets.dart`）。底部永远只有一条栏。
///
/// 列表项那一层见 [GlassSelectableOverlay]。
///
/// 被本文件取代的历史实现：`batch_action_fab_widget.dart`（左下角一列
/// Material FAB，与玻璃语言完全脱节）、`batch_select_bottom_bar_widget.dart`
/// （BottomSheet 版，全项目零引用的死代码）。

/// 一枚批量操作。
///
/// [GlassSelectionDock] / 分页栏取 `actions.first` 作为**主操作**（实心语义色
/// 药丸 + 计数），其余渲染成透明图标位。
class GlassSelectionAction {
  const GlassSelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.loading = false,
  });

  final IconData icon;

  /// 主操作位上会作为文字显示；次操作位上作为 tooltip。
  final String label;

  /// 为 null 表示不可用（置灰）。
  final VoidCallback? onPressed;

  /// 危险动作：主操作位用 `colorScheme.error` 实心。
  final bool destructive;

  /// 正在执行：主操作位换成沙漏并置灰，与 `GlassIconButton.loading` 同源。
  final bool loading;
}

/// 把当前页面的选择态往下广播，供**深埋在列表内部**的 `PaginationBar` 取用。
///
/// 分页栏由 `MediaListView` 在内部渲染，页面拿不到它；而选择态与批量动作是
/// 页面级的状态。层层透传要穿过 `FavoriteVideoList` / `SubscriptionVideoList`
/// / `SearchList…` 一串包装组件，每个都得多加两个参数——用 InheritedWidget
/// 把这条链整个省掉。
///
/// 页面在 `body` 外面套一层即可；没有套的页面（论坛 / 帖子详情）分页栏行为
/// 完全不变。
class BatchSelectionScope extends InheritedWidget {
  const BatchSelectionScope({
    super.key,
    required this.active,
    required this.selectedCount,
    required this.actions,
    required this.onClear,
    required super.child,
  });

  /// 当前是否处于选择态。
  final bool active;
  final int selectedCount;
  final List<GlassSelectionAction> actions;
  final VoidCallback onClear;

  static BatchSelectionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BatchSelectionScope>();

  @override
  bool updateShouldNotify(BatchSelectionScope oldWidget) => true;
}

/// 选择态下吃掉一次返回。
///
/// 安卓系统返回键 / iOS 侧滑返回 / 桌面 Esc 在选择态下应当**先退出选择态**，
/// 而不是把整页弹掉——用户辛苦勾了几十项，一次误触就全没了，还只能回头去点
/// 右上角那枚 ☒。收口前全站十个批量页面没有一个接了 `PopScope`。
///
/// 优先级由既有的 `PopCoordinator` 统一裁决（弹窗 / 遮罩层先于页面消费返回），
/// 这里只负责「页面自己还有一层状态没退」这一档。iOS 侧滑同样受
/// `canPop` 约束，手势在选择态下直接不响应，不会滑到一半再弹回去。
class SelectionPopScope extends StatelessWidget {
  const SelectionPopScope({
    super.key,
    required this.active,
    required this.onExit,
    required this.child,
  });

  final bool active;
  final VoidCallback onExit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !active,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !active) return;
        onExit();
      },
      child: child,
    );
  }
}

/// header 中间胶囊在选择态下的内容：「已选 N 项」+ 全选 / 取消全选。
///
/// 无壳——玻璃壳由外层的 [GlassCapsuleMorph] 提供，这样它与分段胶囊 /
/// 标题胶囊 / 搜索框之间是**同一只壳在换内容**，不是两只胶囊硬切。
class GlassSelectionSummary extends StatelessWidget {
  const GlassSelectionSummary({
    super.key,
    required this.selectedCount,
    required this.allSelected,
    required this.onToggleAll,
  });

  final int selectedCount;

  /// 当前列表是否已被全选（决定全选键的图标与语义）。
  final bool allSelected;

  /// 为 null 时不显示全选键（例如列表尚未加载出任何项）。
  final VoidCallback? onToggleAll;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 14),
        Icon(Icons.checklist, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t.common.selectedRecords(num: selectedCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        // 全选键：图标在原位做缩放交叉过渡（全选 ↔ 取消全选），不是瞬间替换
        GlassGroupSlot(
          visible: onToggleAll != null,
          child: GlassIconButton(
            icon: Icon(allSelected ? Icons.remove_done : Icons.done_all),
            tooltip: allSelected
                ? t.common.cancelSelectAll
                : t.common.selectAll,
            onPressed: onToggleAll,
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }
}

/// 动作行本体：`[主操作(计数)] [次操作…] │ [清空所选]`。
///
/// 同时供 [GlassSelectionDock]（瀑布流）与分页栏（分页模式）使用，保证两种
/// 布局下的按钮语言完全一致。
class GlassSelectionBarContent extends StatelessWidget {
  const GlassSelectionBarContent({
    super.key,
    required this.selectedCount,
    required this.actions,
    required this.onClear,
    this.leading,
    this.showEmptyHint = true,
    this.standaloneButtons = false,
  });

  final int selectedCount;
  final List<GlassSelectionAction> actions;
  final VoidCallback onClear;

  /// 行首附加内容（分页模式塞「‹ 页码 ›」）。
  final Widget? leading;

  /// 0 选中时是否显示「选择项目以继续」提示。
  ///
  /// 独立浮条（[GlassSelectionDock]）要显示——否则坞里空空如也；分页栏那边
  /// 行首已经有页码占位，再加提示会挤，交给主操作的置灰态表达即可。
  final bool showEmptyHint;

  /// 图标钮是否各自带玻璃壳。
  ///
  /// 坞里不用（外面已经有一整只玻璃胶囊，里面再套壳就是壳中壳）；分页栏里
  /// 要用——那条栏本身没有壳，旁边的翻页钮就是独立玻璃圆钮，不带壳的图标会
  /// 显得像半个没画完的按钮。
  final bool standaloneButtons;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool hasSelection = selectedCount > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?leading,
        // 0 选中 → 提示文案；选中后提示宽度收到 0、动作组从 0 长出。
        // 坞的外壳自始至终没有消失过，不存在「选第一项时凭空冒出一坨按钮」。
        if (showEmptyHint)
          GlassGroupSlot(
            visible: !hasSelection,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                t.common.selectItemsToContinue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        // 没有提示文案时（分页栏），动作组常驻并以置灰表达「还没选东西」——
        // 否则选择态下这一段会完全空掉，用户看不到接下来该干什么。
        GlassGroupSlot(
          visible: hasSelection || !showEmptyHint,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actions.isNotEmpty)
                _PrimaryAction(
                  action: actions.first,
                  count: selectedCount,
                  enabled: hasSelection,
                ),
              for (final action in actions.skip(1)) ...[
                // 带壳那一档间距走 chromeGap：分页栏里这一排是收在同一层
                // 玻璃里的（见 GlassChromeLayer），间距小于融合阈值会让几枚
                // 圆钮在静止态就糊成一条。无壳那档只是图标间的留白，不受限。
                SizedBox(width: standaloneButtons ? GlassTokens.chromeGap : 2),
                GlassIconButton(
                  standalone: standaloneButtons,
                  size: standaloneButtons ? 36 : null,
                  iconSize: standaloneButtons ? 18 : GlassTokens.iconSize,
                  icon: Icon(action.icon),
                  tooltip: action.label,
                  loading: action.loading,
                  onPressed: hasSelection ? action.onPressed : null,
                ),
              ],
              SizedBox(width: standaloneButtons ? GlassTokens.chromeGap : 6),
              if (!standaloneButtons) ...[_Divider(), const SizedBox(width: 2)],
              GlassIconButton(
                standalone: standaloneButtons,
                size: standaloneButtons ? 36 : null,
                iconSize: standaloneButtons ? 18 : GlassTokens.iconSize,
                icon: const Icon(Icons.layers_clear),
                tooltip: t.common.clearSelection,
                onPressed: hasSelection ? onClear : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.45),
    );
  }
}

/// 主操作：实心语义色药丸 + 选中计数。
///
/// 下载走 `primary`，删除 / 取消最爱这类不可逆动作走 `error`——语义色本身就是
/// 警示，不需要再给按钮起一个含糊的「确认」名字。
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.action,
    required this.count,
    this.enabled = true,
  });

  final GlassSelectionAction action;
  final int count;

  /// 外部闸门（0 选中时置灰）；与 [GlassSelectionAction.onPressed] 是与关系。
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool active = enabled && action.onPressed != null && !action.loading;
    final Color bg = !active
        ? cs.surfaceContainerHighest
        : (action.destructive ? cs.error : cs.primary);
    final Color fg = !active
        ? cs.onSurface.withValues(alpha: 0.38)
        : (action.destructive ? cs.onError : cs.onPrimary);

    // 底色与前景色一起插值：只给底色套 AnimatedContainer 的话，「0 选中 →
    // 选中 1 项」时药丸底色在平滑推移、图标和文字却已经跳完色，读起来是
    // 「按钮闪了一下」。按下的暗化再混到当前帧的基色上（按下要跟手，走更短的
    // pressDuration，与状态色分层）。
    return GlassAnimatedColors(
      colors: [bg, fg],
      builder: (context, c) {
        final Color animatedBg = c[0];
        final Color animatedFg = c[1];
        return GlassPressable(
          onTap: active ? action.onPressed : null,
          scale: 0.96,
          builder: (context, pressed) => AnimatedContainer(
            duration: GlassTokens.pressDuration,
            curve: Curves.easeOut,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: pressed
                  ? Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.12),
                      animatedBg,
                    )
                  : animatedBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 执行中原位换沙漏，与 GlassIconButton.loading 同一套语言
                GlassAnimatedIcon(
                  icon: Icon(
                    action.loading ? Icons.hourglass_top : action.icon,
                    size: 18,
                    color: animatedFg,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: animatedFg,
                  ),
                ),
                const SizedBox(width: 6),
                // 位数变化时药丸宽度平滑伸缩，不瞬跳
                AnimatedSize(
                  duration: GlassTokens.motionDuration,
                  curve: GlassTokens.motionCurve,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: animatedFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 瀑布流模式下的底部动作坞。
///
/// 根部返回 [Positioned]，与被它取代的 `BatchActionFab` 一样，直接丢进
/// `GlassHeaderOverlay.extra`。
///
/// **分页模式下不要用它**：那时动作行由分页栏自己承载（见
/// [BatchSelectionScope]），底部不该出现第二条玻璃。传 `paginated: true`
/// 它会自动隐身。
class GlassSelectionDock extends StatefulWidget {
  /// 各参数省略时从最近的 [BatchSelectionScope] 取——页面通常已经为分页栏
  /// 套了一层 scope，这里不必再抄一遍，写 `GlassSelectionDock(paginated: …)`
  /// 就够了。
  const GlassSelectionDock({
    super.key,
    this.paginated = false,
    this.extraBottomInset = 0,
    this.visible,
    this.selectedCount,
    this.actions,
    this.onClear,
  });

  final bool? visible;
  final int? selectedCount;
  final List<GlassSelectionAction>? actions;
  final VoidCallback? onClear;

  /// 当前列表处于分页模式：动作行归分页栏，本坞隐身。
  final bool paginated;

  /// 额外的底部让位（例如页面自带的其它浮层）。
  final double extraBottomInset;

  @override
  State<GlassSelectionDock> createState() => _GlassSelectionDockState();
}

class _GlassSelectionDockState extends State<GlassSelectionDock>
    with SingleTickerProviderStateMixin {
  /// 出场比入场干脆一点：退场不该让人等。
  static const Duration _exitDuration = Duration(milliseconds: 160);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
    reverseDuration: _exitDuration,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = BatchSelectionScope.maybeOf(context);
    final bool show =
        (widget.visible ?? scope?.active ?? false) && !widget.paginated;

    // 在 build 里驱动控制器是安全的：forward/reverse 只会通知 *status*
    // 监听器，而 AnimatedBuilder 订阅的是 value，不会在构建期触发重建。
    // 加这层守卫只为避免每帧都重启一次 ticker。
    final status = _controller.status;
    if (show) {
      if (status != AnimationStatus.completed &&
          status != AnimationStatus.forward) {
        _controller.forward();
      }
    } else if (status != AnimationStatus.dismissed &&
        status != AnimationStatus.reverse) {
      _controller.reverse();
    }

    final double bottom =
        computeBottomSafeInset(MediaQuery.of(context)) +
        16 +
        widget.extraBottomInset;

    // 根部必须稳定返回 Positioned（Stack 的直接子级）。内容在退场动画跑完后
    // 整个卸载——常驻挂载会让每个页面白白构建一整排按钮，也会让「没进选择态
    // 时不该存在的按钮」在 widget 树里被找到。
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      // ⛔ 这里曾经在最外面裹 `Opacity(opacity: v)`——它会 saveLayer 把子树
      // 隔离，坞身上那块玻璃的 backdrop 采样在整段出入场里都吃不到背景，读
      // 起来是「按钮先浮上来、玻璃质感后补」（同 GlassReveal 那条原语的说明）。
      // 位移/缩放是纯 Transform 可以留，淡入改走 GlassSurface.materialize。
      //
      // 为此把玻璃壳从 AnimatedBuilder 的 `child:` 挪进 builder 里——
      // materialize 逐帧变化，壳没法再当作「不随动画重建的常量子树」缓存。
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isDismissed && !show) return const SizedBox.shrink();
          final double v = show
              ? GlassTokens.motionCurve.transform(_controller.value)
              : Curves.easeInCubic.transform(_controller.value);
          return IgnorePointer(
            ignoring: !show,
            child: Transform.translate(
              // 从底部「浮上来」：位移 + 缩放 + 材质淡入三者同时发生
              offset: Offset(0, (1 - v) * 16),
              child: Transform.scale(
                scale: 0.92 + 0.08 * v,
                // 留出左右边距：坞是居中浮条，贴到屏幕边缘既难看也容易被
                // 系统手势区吃掉
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: GlassSurface(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialize: v,
                      child: AnimatedSize(
                        duration: GlassTokens.groupMorphDuration,
                        curve: GlassTokens.groupSlotCurve,
                        clipBehavior: Clip.hardEdge,
                        child: GlassSelectionBarContent(
                          selectedCount:
                              widget.selectedCount ?? scope?.selectedCount ?? 0,
                          actions:
                              widget.actions ??
                              scope?.actions ??
                              const <GlassSelectionAction>[],
                          onClear: widget.onClear ?? scope?.onClear ?? () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 列表项上的选择态表达：**不盖死内容**。
///
/// 现状（被本组件取代）是整片 20% / 45% 的黑遮罩加一枚居中 40px 的
/// `check_circle`，缩略图基本看不清——而批量删除恰恰是最需要看清自己在删
/// 什么的场合。这里把「可选 / 已选」的信息挤到角标与描边上：
///
/// - 未选：右上角一枚半透明玻璃空心圈；
/// - 已选：圈变成 `primary` 实心 + 勾，卡片长出 2px `primary` 描边，
///   内容只压暗 6%。
///
/// 放进各卡片既有的 `overlay` / `contentOverlay` 槽位即可；本身
/// [IgnorePointer]，点击仍由卡片自己的 `InkWell` 处理。
class GlassSelectableOverlay extends StatelessWidget {
  const GlassSelectableOverlay({
    super.key,
    required this.selectionMode,
    required this.selected,
    this.borderRadius = BorderRadius.zero,
  });

  final bool selectionMode;
  final bool selected;

  /// 与所在卡片（或缩略图）的圆角保持一致，否则描边会切出直角。
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: AnimatedOpacity(
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
        opacity: selectionMode ? 1 : 0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 选中压暗——只 6%，缩略图仍可辨认
            AnimatedContainer(
              duration: GlassTokens.motionDuration,
              curve: GlassTokens.motionCurve,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: selected ? 0.06 : 0),
                borderRadius: borderRadius,
                border: Border.all(
                  color: selected ? cs.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            Positioned(top: 6, right: 6, child: _Tick(selected: selected)),
          ],
        ),
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedScale(
      duration: GlassTokens.motionDuration,
      // 勾上时轻微过冲，读起来是「被摁下去」而不是换了张图
      curve: Curves.easeOutBack,
      scale: selected ? 1.08 : 1,
      child: AnimatedContainer(
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? cs.primary : Colors.white.withValues(alpha: 0.16),
          border: Border.all(
            color: selected ? cs.primary : Colors.white.withValues(alpha: 0.85),
            width: 1.5,
          ),
        ),
        child: AnimatedOpacity(
          duration: GlassTokens.motionDuration,
          opacity: selected ? 1 : 0,
          child: Icon(Icons.check, size: 15, color: cs.onPrimary),
        ),
      ),
    );
  }
}
