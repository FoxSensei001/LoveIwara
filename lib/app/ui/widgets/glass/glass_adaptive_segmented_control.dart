import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 分段胶囊 **+「摆不下就退化成下拉钮」**——所有分段控件的唯一入口。
///
/// # 为什么不直接用 [GlassSegmentedControl]
///
/// 平铺的分段胶囊放不下时并不会报错，它只是**自己横向滚起来**：用户看到的是
/// 一条被裁掉的半截胶囊，露出「最新」和半个「点赞数」，剩下三段得横着拨才
/// 知道存在。约定早就定了——露不出 2.5 个完整段就该让位给下拉钮（见
/// [GlassSegmentedControl.minWidthFor]），但这条判定原先是**每个页面各抄一份**
/// 的十几行 `LayoutBuilder + GlassCapsuleMorph + 自建下拉触发位`，于是只有三处
/// header 抄到了，作者页那一行「最新 / 点赞数 / 观看次数 / 受欢迎 / 趋势」
/// 五段排序行一直是裸的（2026-08-26 报障）。
///
/// 现在这条规矩只有这一处实现，闸门见 `test/glass_style_guard_test.dart`
/// 「分段胶囊一律走 GlassAdaptiveSegmentedControl」。
///
/// # 尺寸从哪儿来
///
/// 「够不够」读的是**自己实际分到的宽度**（[LayoutBuilder]），不是按公式去猜
/// 同一行右侧还剩几个按钮——那份算术在按钮**正在**收放的那几百毫秒里恒为错，
/// 会让分段胶囊在右侧还没让出空间时就被塞进来、当场被裁掉半截。所以把本控件
/// 放进 `Expanded` / 定宽容器里就行，两侧的伸缩自然串成先后。
///
/// # 玻璃壳
///
/// 壳由常驻的 [GlassCapsuleMorph] 提供（分段那一支因此传 `flat: true`）：
/// 平铺 ↔ 下拉互换时胶囊宽度平滑伸缩，圆角与描边全程完整，而不是两只胶囊
/// 硬切（见 glass-liquid-morph 词汇表里的「胶囊↔胶囊互换必须单壳常驻」）。
class GlassAdaptiveSegmentedControl extends StatefulWidget {
  const GlassAdaptiveSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.progress,
    this.minVisibleItems = 2.5,
    this.dropdownOnly = false,
    this.replacement,
    this.alignment = Alignment.centerLeft,
    this.height = GlassTokens.pillHeight,
  });

  final List<GlassSegmentItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// 可选的连续「当前位置」（典型地传 `TabController.animation`）。
  ///
  /// 平铺时高亮块跟着横滑实时插值；退化成下拉钮后，触发位的文案同样接它
  /// ——横滑 `TabBarView` 时字跟着手指一格一格翻（见 [GlassFlipLabel]），
  /// 不是等滑完才换。没有 TabController 的调用点可以不传，文案改为跟着
  /// [selectedIndex] 跳。
  final ValueListenable<double>? progress;

  /// 平铺至少要完整露出几个段，低于这个数就退化成下拉钮。约定值 2.5。
  final double minVisibleItems;

  /// **这一页永远只要下拉钮那一支**，宽度够也不平铺。
  ///
  /// 给的是「这几段不配占满一整行」的场合：header 上已经有返回键、标题胶囊和
  /// 动作胶囊，排序只是跟着动作胶囊靠右站的一枚「当前是谁 ▾」，平铺开就成了
  /// 半行 tab（见 tag_media_list_page）。走这里而不是页面自己抄一份下拉钮，
  /// 是因为下拉那一支的触发位 / 跟手翻牌 / 菜单打勾三件事只该有一份实现。
  ///
  /// 真值时不再量宽（[minVisibleItems] 随之失效），所以本控件也就可以待在
  /// Row 的非 flex 位置上——那里读到的可用宽度是无限大，量了也是错的。
  final bool dropdownOnly;

  /// 页面级的「这只胶囊此刻不表示分段」替换内容（典型：批量选择态下改报
  /// 「已选 N 项」）。非空时直接顶掉分段 / 下拉两支，但**壳还是同一只**，
  /// 所以进出选择态照样是一次宽度形变而不是硬切。自带 `Key`。
  final Widget? replacement;

  /// 胶囊在可用宽度里靠哪边，同时也是宽度伸缩的锚点。
  final Alignment alignment;

  final double height;

  @override
  State<GlassAdaptiveSegmentedControl> createState() =>
      _GlassAdaptiveSegmentedControlState();
}

class _GlassAdaptiveSegmentedControlState
    extends State<GlassAdaptiveSegmentedControl> {
  /// 没传 [GlassAdaptiveSegmentedControl.progress] 时自己造一个：下拉钮的
  /// 文案（[GlassFlipLabel]）只接连续下标，没有 TabController 的调用点也得
  /// 有个能翻牌的信号源，这里就用当前选中项本身。
  ValueNotifier<double>? _fallbackProgress;

  ValueListenable<double> get _progress =>
      widget.progress ??
      (_fallbackProgress ??= ValueNotifier<double>(
        widget.selectedIndex.toDouble(),
      ));

  @override
  void didUpdateWidget(GlassAdaptiveSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress == null) {
      _fallbackProgress?.value = widget.selectedIndex.toDouble();
    }
  }

  @override
  void dispose() {
    _fallbackProgress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useSegmented =
            !widget.dropdownOnly &&
            constraints.maxWidth >=
            GlassSegmentedControl.minWidthFor(
              context,
              widget.items,
              minVisibleItems: widget.minVisibleItems,
            );
        // widthFactor 1 —— 胶囊只占自己那么宽，不去认领整条可用宽度：
        // 这样它能和同一行里紧跟着的东西（最爱页的站点徽标）贴在一起，
        // 而 [alignment] 仍是宽度伸缩的锚点。
        return Align(
          alignment: widget.alignment,
          widthFactor: 1.0,
          child: GlassCapsuleMorph(
            height: widget.height,
            alignment: widget.alignment,
            child:
                widget.replacement ??
                (useSegmented
                    ? GlassSegmentedControl(
                        key: const ValueKey('segmented'),
                        flat: true,
                        height: widget.height,
                        selectedIndex: widget.selectedIndex,
                        progress: widget.progress,
                        onChanged: widget.onChanged,
                        items: widget.items,
                      )
                    : KeyedSubtree(
                        key: const ValueKey('dropdown'),
                        child: _buildDropdown(context),
                      )),
          ),
        );
      },
    );
  }

  /// 过窄时的入口：下拉菜单（代替分段胶囊）。
  /// 只渲染「文字 + 箭头」的无壳内容，玻璃壳由外层 [GlassCapsuleMorph] 提供。
  ///
  /// 触发位本身收口在 [GlassDropdownTrigger]（与下载页的分类下拉共用一份）。
  Widget _buildDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassDropdownTrigger(
      height: widget.height,
      onTap: _openMenu,
      // 段自带图标时触发位也带上：下拉钮是这一行「此刻是谁」的唯一读法，
      // 比平铺版少一半信息量已经够了，图标不该再丢。
      child: IconTheme.merge(
        data: IconThemeData(
          color: colorScheme.onSurface,
          size: GlassSegmentedControl.itemIconSize,
        ),
        child: GlassFlipLabel(
          progress: _progress,
          labels: [for (final item in widget.items) item.label],
          icons: widget.items.any((item) => item.icon != null)
              ? [for (final item in widget.items) item.icon]
              : null,
          iconSize: GlassSegmentedControl.itemIconSize,
          iconGap: GlassSegmentedControl.itemIconGap,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _openMenu(BuildContext anchorContext) async {
    final int index = widget.selectedIndex;
    final int? picked = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        for (var i = 0; i < widget.items.length; i++)
          GlassMenuOption<int>(
            value: i,
            label: widget.items[i].label,
            leading: widget.items[i].icon,
            selected: i == index,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    widget.onChanged(picked);
  }
}
