import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
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
/// 药丸 + 计数），其余渲染成透明图标位；标了 [overflow] 的、以及超出
/// [GlassSelectionBarContent.maxInlineSecondary] 的收进行尾一枚「更多」。
class GlassSelectionAction {
  const GlassSelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.loading = false,
    this.overflow = false,
  });

  /// 收进「更多」菜单而不是摆成一枚图标位。
  ///
  /// 给不常用、或者按所选内容才冒出来的动作用：动作行的宽度随选中项变来变去，
  /// 读起来是按钮在跳。放进菜单还有文字标签，比一枚只有 tooltip 的图标好认。
  final bool overflow;

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

/// 页面把自己的选择状态「翻译」给 [SelectionPopScope] 的通用键鼠多选。
///
/// 全站十处批量选择各有各的存法（通用控制器的 `RxSet<String>`、页面自己的
/// `Set<int>`、`类型:id` 拼成的复合键……），这里不强求统一存储，只要求页面
/// 回答几个问题。key 一律按 [Object] 传，页面在闭包里自己转回原类型。
///
/// [loadedKeys] 与 [replaceSelection] 成对：给了它们才有 Shift 连选、全选
/// （Cmd/Ctrl+A 与 header 全选键）、反选。懒加载列表只能覆盖**已加载**的部分；
/// 页面拿不到有序列表的（数据源藏在子组件里）不给，只剩 Cmd/Ctrl+点击。
class SelectionModel {
  const SelectionModel({
    required this.enter,
    required this.isSelected,
    required this.toggle,
    this.loadedKeys,
    this.replaceSelection,
  }) : assert(
         (loadedKeys == null) == (replaceSelection == null),
         'loadedKeys 与 replaceSelection 必须成对给',
       );

  /// 进入选择态（已在选择态时不会被调用）。
  final VoidCallback enter;
  final bool Function(Object key) isSelected;
  final void Function(Object key) toggle;

  /// 屏幕上从上到下的已加载项 key。
  final List<Object> Function()? loadedKeys;

  /// 把选中集合整个换成 [keys]（只会是 [loadedKeys] 的子集）。
  final void Function(Set<Object> keys)? replaceSelection;

  bool get canSelectLoaded => loadedKeys != null;

  bool allLoadedSelected() {
    final keys = loadedKeys?.call() ?? const [];
    return keys.isNotEmpty && keys.every(isSelected);
  }

  /// 全选已加载的；已经全选时全部取消。
  void toggleSelectAll() {
    final keys = loadedKeys?.call();
    if (keys == null || keys.isEmpty) return;
    replaceSelection!(allLoadedSelected() ? <Object>{} : keys.toSet());
  }

  void invert() {
    final keys = loadedKeys?.call();
    if (keys == null) return;
    replaceSelection!({
      for (final k in keys)
        if (!isSelected(k)) k,
    });
  }

  /// 把 [from] 到 [to] 之间（含两端）加进选中。任一端不在已加载列表里时
  /// 退化成只选 [to]。
  void selectRange(Object from, Object to) {
    final keys = loadedKeys?.call();
    final i = keys?.indexOf(from) ?? -1;
    final j = keys?.indexOf(to) ?? -1;
    if (keys == null || i < 0 || j < 0) {
      if (!isSelected(to)) toggle(to);
      return;
    }
    final (lo, hi) = i <= j ? (i, j) : (j, i);
    replaceSelection!({
      for (final k in keys)
        if (isSelected(k)) k,
      ...keys.sublist(lo, hi + 1),
    });
  }
}

/// 选择态的页面级外壳：返回键 / 侧滑 / Esc 先退选择态，并（给了 [model] 时）
/// 提供全站统一的键鼠多选。
///
/// 安卓系统返回键 / iOS 侧滑返回 / 桌面 Esc 在选择态下应当**先退出选择态**，
/// 而不是把整页弹掉——用户辛苦勾了几十项，一次误触就全没了，还只能回头去点
/// 右上角那枚 ☒。优先级由既有的 `PopCoordinator` 统一裁决（弹窗 / 遮罩层先于
/// 页面消费返回），这里只负责「页面自己还有一层状态没退」这一档。iOS 侧滑同样
/// 受 `canPop` 约束，手势在选择态下直接不响应。
///
/// # 键鼠多选（Finder / 资源管理器的读法）
///
/// - Cmd（macOS）/ Ctrl + 点击：切换这一项，不在选择态就顺手进入；
/// - Shift + 点击：从上一次点的那一项连选到这一项（需要 [SelectionModel.loadedKeys]）；
/// - Cmd/Ctrl + A：全选已加载的，再按一次取消（同上）；
/// - Delete（macOS 另认 ⌘⌫）：坞上的主操作是破坏性的（删除 / 取消最爱 /
///   移出…）就触发它，与点那枚按钮完全一样；
/// - Esc：退出选择态。
///
/// 点击要落到每一项上，所以列表项外面要包一层 [SelectableItem]。header 的全选键
/// 与坞上「更多」里的反选，只要 [model] 给了已加载列表就自动出现。
///
/// 快捷键挂在 [HardwareKeyboard] 上而不是某个 `Focus` 上：列表里没有常驻焦点，
/// 挂在 Focus 上会时灵时不灵（播放器快捷键失效就是这么来的）。代价是得自己判：
/// 本页不在最上面、被藏在后台 tab（TickerMode 关着）、焦点在输入框里，一律不管。
class SelectionPopScope extends StatefulWidget {
  const SelectionPopScope({
    super.key,
    required this.active,
    required this.onExit,
    required this.child,
    this.model,
  });

  final bool active;
  final VoidCallback onExit;
  final Widget child;

  /// 不给就只有「返回 / Esc 先退选择态」。
  final SelectionModel? model;

  @override
  State<SelectionPopScope> createState() => _SelectionPopScopeState();
}

class _SelectionPopScopeState extends State<SelectionPopScope> {
  /// Cmd/Ctrl 或 Shift 正按着：每一项上盖一层接点击的透明层（见 [SelectableItem]）。
  final ValueNotifier<bool> _modifierHeld = ValueNotifier<bool>(false);

  /// Shift 连选的起点：最近一次不带 Shift 按下的那一项。
  Object? _anchor;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void didUpdateWidget(SelectionPopScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) _anchor = null;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _modifierHeld.dispose();
    super.dispose();
  }

  static bool get _isMac => defaultTargetPlatform == TargetPlatform.macOS;

  /// 「点击改为选中」用哪个键：macOS 是 Cmd（Ctrl+点击在那儿是右键），其余 Ctrl。
  static bool get _toggleModifierPressed => _isMac
      ? HardwareKeyboard.instance.isMetaPressed
      : HardwareKeyboard.instance.isControlPressed;

  bool get _listening {
    if (!mounted) return false;
    // 弹窗 / 菜单 / 新页面在上面时按键归它们；藏在后台 tab 里的页面不接。
    if (ModalRoute.of(context)?.isCurrent == false) return false;
    if (!TickerMode.valuesOf(context).enabled) return false;
    return !isTextInputFocused();
  }

  bool _onKey(KeyEvent event) {
    final model = widget.model;
    if (model != null && mounted) {
      final held =
          _toggleModifierPressed || HardwareKeyboard.instance.isShiftPressed;
      if (_modifierHeld.value != held) _modifierHeld.value = held;
    }

    if (event is! KeyDownEvent || !_listening) return false;
    final key = event.logicalKey;
    final keyboard = HardwareKeyboard.instance;

    if (key == LogicalKeyboardKey.escape) {
      if (!widget.active) return false;
      widget.onExit();
      return true;
    }

    if (model == null) return false;

    if (key == LogicalKeyboardKey.keyA &&
        _toggleModifierPressed &&
        !keyboard.isShiftPressed &&
        !keyboard.isAltPressed &&
        model.canSelectLoaded) {
      if (!widget.active) model.enter();
      model.toggleSelectAll();
      return true;
    }

    if (!widget.active) return false;
    final plain =
        !keyboard.isMetaPressed &&
        !keyboard.isControlPressed &&
        !keyboard.isAltPressed &&
        !keyboard.isShiftPressed;
    // macOS 的笔记本键盘没有 Delete 键，Finder 用 ⌘⌫。
    final isDelete =
        (key == LogicalKeyboardKey.delete && plain) ||
        (key == LogicalKeyboardKey.backspace &&
            (_isMac ? keyboard.isMetaPressed : plain));
    if (!isDelete) return false;
    final scope = context.getInheritedWidgetOfExactType<BatchSelectionScope>();
    final primary = scope == null || scope.actions.isEmpty
        ? null
        : scope.actions.first;
    if (scope == null ||
        scope.selectedCount == 0 ||
        primary == null ||
        !primary.destructive ||
        primary.loading ||
        primary.onPressed == null) {
      return false;
    }
    primary.onPressed!();
    return true;
  }

  /// 按着修饰键点了某一项（由 [SelectableItem] 转来）。
  void _modifierClick(Object key, void Function(Object key)? onToggle) {
    final model = widget.model;
    if (model == null) return;
    final anchor = _anchor;
    if (!widget.active) model.enter();
    if (HardwareKeyboard.instance.isShiftPressed &&
        anchor != null &&
        model.canSelectLoaded) {
      model.selectRange(anchor, key);
      return;
    }
    (onToggle ?? model.toggle)(key);
    _anchor = key;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.active,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !widget.active) return;
        widget.onExit();
      },
      child: _SelectionGestureScope(
        state: this,
        model: widget.model,
        active: widget.active,
        child: widget.child,
      ),
    );
  }
}

class _SelectionGestureScope extends InheritedWidget {
  const _SelectionGestureScope({
    required this.state,
    required this.model,
    required this.active,
    required super.child,
  });

  final _SelectionPopScopeState state;
  final SelectionModel? model;
  final bool active;

  static _SelectionGestureScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SelectionGestureScope>();

  @override
  bool updateShouldNotify(_SelectionGestureScope oldWidget) => true;
}

/// 列表里可被选中的一项：接住 Cmd/Ctrl/Shift + 点击。
///
/// 修饰键按着时在这一项上盖一层透明的接点击层——卡片自己的 InkWell 会把点击
/// 当成「打开」，没法在它身上半路改道；松开修饰键这层就撤掉，点击照旧落回卡片。
/// 同时记下每次不带 Shift 按下的那一项，作为 Shift 连选的起点（选择态下的普通
/// 点击仍由卡片 / 页面自己处理，这里只是旁听）。
///
/// 上面没有带 [SelectionModel] 的 [SelectionPopScope] 时原样返回 [child]，
/// 所以通用卡片可以无条件包它。触屏没有修饰键，行为不变。
class SelectableItem extends StatelessWidget {
  const SelectableItem({
    super.key,
    required this.itemKey,
    required this.child,
    this.onToggle,
  });

  /// 与页面 [SelectionModel] 用的 key 同一种值。
  final Object itemKey;

  /// 切换这一项的自定义做法（默认走 [SelectionModel.toggle]）。给通用卡片用：
  /// 卡片手上有对象本身，而有的选择状态按对象存。
  final VoidCallback? onToggle;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = _SelectionGestureScope.maybeOf(context);
    if (scope == null || scope.model == null) return child;
    final state = scope.state;
    final toggle = onToggle;
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kPrimaryButton &&
            !HardwareKeyboard.instance.isShiftPressed) {
          state._anchor = itemKey;
        }
      },
      // passthrough：列表项拿到的约束原样交给 child。默认的 loose 会把网格格子
      // 给的紧约束放松，撑满格子的卡片就缩成了内容大小。
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          ValueListenableBuilder<bool>(
            valueListenable: state._modifierHeld,
            builder: (context, held, _) => held
                ? Positioned.fill(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => state._modifierClick(
                          itemKey,
                          toggle == null ? null : (_) => toggle(),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// 键盘焦点是否在某个输入框里。
///
/// 页面级键盘快捷键（挂在 [HardwareKeyboard] 上的那种）必须先问这一句：返回
/// true 会把按键从输入法那里截走，搜索框里打空格就成了「暂停」、按退格就成了
/// 「删除」。
bool isTextInputFocused() {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  return focused.widget is EditableText ||
      focused.findAncestorWidgetOfExactType<EditableText>() != null;
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

  /// 为 null 时：上面的 [SelectionPopScope] 给了带已加载列表的
  /// [SelectionModel] 就用它（与 Cmd/Ctrl+A 同一件事），否则不显示全选键。
  final VoidCallback? onToggleAll;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final model = _SelectionGestureScope.maybeOf(context)?.model;
    final fromModel =
        this.onToggleAll == null && (model?.canSelectLoaded ?? false);
    final allSelected = fromModel
        ? model!.allLoadedSelected()
        : this.allSelected;
    final onToggleAll = fromModel ? model!.toggleSelectAll : this.onToggleAll;

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

  /// 主操作之外最多摆几枚图标位，多出来的顺次进「更多」。
  static const int maxInlineSecondary = 4;

  Future<void> _openMore(
    BuildContext anchorContext,
    List<GlassSelectionAction> items,
  ) async {
    final picked = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        for (var i = 0; i < items.length; i++)
          GlassMenuOption<int>(
            value: i,
            label: items[i].label,
            icon: items[i].icon,
            destructive: items[i].destructive,
            enabled: items[i].onPressed != null && !items[i].loading,
          ),
      ],
    );
    if (picked != null) items[picked].onPressed?.call();
  }

  /// 把次操作分成「摆出来的」与「收进更多的」。
  ///
  /// [fits]：宽度上最多还能摆几枚（含「更多」自己那一枚）；分页栏那档不量宽，
  /// 传 null 只按 [maxInlineSecondary] 截。
  static ({List<GlassSelectionAction> inline, List<GlassSelectionAction> more})
  _split(List<GlassSelectionAction> actions, {int? fits}) {
    final secondary = [
      for (final a in actions.skip(1))
        if (!a.overflow) a,
    ];
    final flagged = [
      for (final a in actions.skip(1))
        if (a.overflow) a,
    ];
    var cap = maxInlineSecondary;
    if (fits != null) {
      final needMore = flagged.isNotEmpty || secondary.length > fits;
      cap = cap.clamp(0, needMore ? (fits - 1).clamp(0, fits) : fits);
    }
    return (
      inline: secondary.take(cap).toList(),
      more: [...secondary.skip(cap), ...flagged],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool hasSelection = selectedCount > 0;
    final model = _SelectionGestureScope.maybeOf(context)?.model;
    // 页面给了已加载列表，就自动在「更多」里补一条反选——各页不用各写一遍。
    final actions = [
      ...this.actions,
      if (model != null && model.canSelectLoaded)
        GlassSelectionAction(
          icon: Icons.flip,
          label: t.common.invertSelection,
          overflow: true,
          onPressed: model.invert,
        ),
    ];
    final primary = actions.isEmpty ? null : actions.first;

    Widget group(BoxConstraints? constraints) {
      final labeled = !standaloneButtons;
      int? fits;
      if (labeled && constraints != null && constraints.hasBoundedWidth) {
        final primaryWidth = primary == null
            ? 0.0
            : _PrimaryAction.estimateWidth(context, primary, selectedCount);
        final clearWidth = _LabeledAction.widthFor(
          context,
          t.common.clearSelection,
        );
        final rest = constraints.maxWidth - primaryWidth - clearWidth - 12;
        fits = (rest / (_LabeledAction.maxWidth + 2)).floor().clamp(0, 99);
      }
      final split = _split(actions, fits: fits);

      Widget button({
        required IconData icon,
        required String label,
        required VoidCallback? onPressed,
        bool loading = false,
        bool destructive = false,
        bool opensOverlay = false,
      }) {
        if (labeled) {
          return _LabeledAction(
            icon: icon,
            label: label,
            loading: loading,
            destructive: destructive,
            opensOverlay: opensOverlay,
            onPressed: onPressed,
          );
        }
        return GlassIconButton(
          standalone: true,
          size: 36,
          iconSize: 18,
          icon: Icon(icon),
          tooltip: label,
          loading: loading,
          onPressed: onPressed,
        );
      }

      // 带壳那一档间距走 chromeGap：分页栏里这一排是收在同一层玻璃里的
      // （见 GlassChromeLayer），间距小于融合阈值会让几枚圆钮在静止态就糊成
      // 一条。带字那档只是按钮间的留白，不受限。
      final gap = SizedBox(width: labeled ? 2 : GlassTokens.chromeGap);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (primary != null)
            _PrimaryAction(
              action: primary,
              count: selectedCount,
              enabled: hasSelection,
            ),
          if (labeled) const SizedBox(width: 4),
          for (final action in split.inline) ...[
            gap,
            button(
              icon: action.icon,
              label: action.label,
              loading: action.loading,
              destructive: action.destructive,
              onPressed: hasSelection ? action.onPressed : null,
            ),
          ],
          if (split.more.isNotEmpty) ...[
            gap,
            Builder(
              builder: (anchorContext) => button(
                icon: Icons.more_horiz,
                label: t.common.more,
                opensOverlay: true,
                onPressed: hasSelection
                    ? () => _openMore(anchorContext, split.more)
                    : null,
              ),
            ),
          ],
          SizedBox(width: labeled ? 4 : GlassTokens.chromeGap),
          if (labeled) ...[_Divider(), const SizedBox(width: 4)],
          button(
            icon: Icons.layers_clear,
            label: t.common.clearSelection,
            onPressed: hasSelection ? onClear : null,
          ),
        ],
      );
    }

    Widget content(BoxConstraints? constraints) => Row(
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
          // 带字那档要量宽：摆不下的顺次进「更多」，窄手机上不会挤爆。
          child: group(constraints),
        ),
      ],
    );

    // 带字那档要量宽：摆不下的顺次进「更多」，窄手机上不会挤爆。量的是这一整行
    // 拿到的约束——里面的 Row / GlassGroupSlot 给子级的宽度是无限的，量不出来。
    if (standaloneButtons) return content(null);
    return LayoutBuilder(builder: (context, c) => content(c));
  }
}

/// 坞里的一枚次操作：图标在上、文字在下。
///
/// 只有图标的一排按钮对鼠标用户够用（悬停有 tooltip），触屏上却没有悬停——
/// 用户只能靠猜，或者点了才知道。底部操作栏带字是各家相册 / 文件应用的通行
/// 做法；文字小一号、单行，宽度随文字伸缩并封顶，长了省略（悬停仍有全称）。
class _LabeledAction extends StatelessWidget {
  const _LabeledAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.destructive = false,
    this.opensOverlay = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool destructive;
  final bool opensOverlay;

  static const double height = 48;
  static const double minWidth = 52;
  static const double maxWidth = 84;
  static const double _hPad = 6;
  static const TextStyle _labelStyle = TextStyle(
    fontSize: 11,
    height: 1.1,
    fontWeight: FontWeight.w500,
  );

  static double widthFor(BuildContext context, String label) {
    // 必须并上主题的字体：裸 TextStyle 量的是默认字体，中文实际渲染用的字体
    // 更宽，量出来的宽度装不下、文字被省略掉。
    final painter = TextPainter(
      text: TextSpan(
        text: _barLabel(label),
        style: DefaultTextStyle.of(context).style.merge(_labelStyle),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final w = painter.width.ceilToDouble() + 2 + _hPad * 2;
    painter.dispose();
    return w.clamp(minWidth, maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !loading;
    final base = destructive ? cs.error : cs.onSurface;
    final fg = enabled ? base : cs.onSurface.withValues(alpha: 0.38);

    return Tooltip(
      message: label,
      child: GlassPressable(
        onTap: enabled ? onPressed : null,
        enabled: enabled,
        opensOverlay: opensOverlay,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          width: widthFor(context, label),
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: _hPad),
          decoration: BoxDecoration(
            color: pressed
                ? cs.onSurface.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassAnimatedIcon(
                icon: Icon(
                  loading ? Icons.hourglass_top : icon,
                  size: 20,
                  color: fg,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _barLabel(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: _labelStyle.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 动作名去掉结尾的「…」再上栏。
///
/// 「删除…」「移动文件到…」里的省略号是菜单的约定（点了还有一步对话框），
/// 在菜单里有意义；摆在底栏按钮上只是多占一格、把真正的字挤成省略。
String _barLabel(String label) =>
    label.replaceFirst(RegExp(r'(…|\.\.\.)$'), '');

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

  /// 药丸的宽度（坞量宽用，与下面的排版同一组常数）。
  static double estimateWidth(
    BuildContext context,
    GlassSelectionAction action,
    int count,
  ) {
    double textWidth(String text, FontWeight weight) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: DefaultTextStyle.of(
            context,
          ).style.merge(TextStyle(fontSize: 13, fontWeight: weight)),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final w = painter.width;
      painter.dispose();
      return w;
    }

    return 14 * 2 +
        18 +
        7 +
        textWidth(_barLabel(action.label), FontWeight.w600) +
        6 +
        textWidth('$count', FontWeight.w800);
  }

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
                  _barLabel(action.label),
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
                      // 次操作是「图标 + 字」两行（见 _LabeledAction），比默认
                      // 药丸高一档。
                      height: _LabeledAction.height + 8,
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
            Positioned(
              top: 6,
              right: 6,
              child: GlassSelectionTick(selected: selected),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassSelectionTick extends StatelessWidget {
  const GlassSelectionTick({super.key, required this.selected});

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
