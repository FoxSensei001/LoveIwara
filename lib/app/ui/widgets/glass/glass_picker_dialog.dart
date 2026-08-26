import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_measured_box.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「选择器弹窗」的统一骨架：标题行 + 若干行控件浮在列表之上，列表铺满整个
/// 弹窗、用 `paddingTop` 让出 header 高度，从 header 背后滚过去。
///
/// # 为什么要有这个收口点
///
/// 本地收藏 / 播放列表 / 搜索标签 / oreno3d 标签四张弹窗原本各自抄了一份同样
/// 的 `Stack + EdgeFadeScrim + Column` 配方，各自在文件顶部手写
/// `_kXxxRowHeight = 8 + 44` 这样的常数去「猜」自己有多高。猜错了没人知道：
///
///   - 玻璃输入框（[GlassPickerField]）实测是 **48**，不是 44
///     （`prefixIcon` 的默认约束 `kMinInteractiveDimension` 顶着）；
///   - `IconButton.filled(constraints: tightFor(44, 44))` 实测也是 **48**
///     （`MaterialTapTargetSize.padded` 会再套一层 48 的点击区）。
///
/// 于是每多一行输入框，header 就比声明的高 4：本地收藏 / 播放列表两张各有两行
/// 输入框，8px 的尾部留白被吃干净，列表首屏正好顶在控件底缘上（用户报障的
/// 「毫无空隙」）；另外两张各剩 4。
///
/// 现在高度由本组件**实测**（[_MeasuredBox]），[bodyBuilder] 收到的
/// `headerExtent` 一定等于屏幕上真实的 header 底缘 + [tailSpacing]，
/// 字号放大 / 换语言 / 以后加减一行都不用再改常数。
/// 横向留白同理，一律 [hPadding]，列表也用同一个数，别再一处 12 一处 16 一处 20。
class GlassPickerDialog extends StatefulWidget {
  const GlassPickerDialog({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.titleActions = const <Widget>[],
    this.rows = const <GlassPickerRow>[],
    this.onClose,
    this.constraints = const BoxConstraints(maxWidth: 600, maxHeight: 800),
  });

  /// 全站选择器弹窗的横向留白——header 每一行、列表内容都用它。
  static const double hPadding = 16;

  /// 标题行上方留白 / 标题行与下一行之间的留白。
  static const double titleTopPadding = 16;
  static const double titleBottomGap = 4;

  /// header 里相邻两行之间的留白。
  static const double rowGap = 8;

  /// header 底缘与列表首屏之间的呼吸位——这一段必须真的空出来。
  static const double tailSpacing = 8;

  /// 玻璃输入框行的实测高度（见类文档：`prefixIcon` 把它顶到 48）。
  static const double fieldRowHeight = 48;

  final String title;

  /// 标题行右侧、关闭钮左边的附加圆钮（自动按 8 的间距排开）。
  final List<Widget> titleActions;

  /// 标题行下方的控件行（搜索框、新建框、分段胶囊……）。
  final List<GlassPickerRow> rows;

  /// 关闭钮动作，默认 [AppService.tryPop]。
  final VoidCallback? onClose;

  /// 列表主体。`headerExtent` 是**实测**的 header 总高（已含 [tailSpacing]），
  /// 直接当滚动视图的 `padding.top` 用；横向留白用 [hPadding]。
  final Widget Function(BuildContext context, double headerExtent) bodyBuilder;

  final BoxConstraints constraints;

  @override
  State<GlassPickerDialog> createState() => _GlassPickerDialogState();
}

/// header 里的一行控件。[height] 只用来算首帧的预估高度，真实高度以实测为准。
class GlassPickerRow {
  const GlassPickerRow({
    required this.child,
    this.height = GlassTokens.pillHeight,
    this.gap = GlassPickerDialog.rowGap,
  });

  /// 玻璃输入框（或以输入框定高的一整行，如「输入 + 新建圆钮」）。
  const GlassPickerRow.field({required Widget child})
    : this(child: child, height: GlassPickerDialog.fieldRowHeight);

  final Widget child;
  final double height;
  final double gap;
}

class _GlassPickerDialogState extends State<GlassPickerDialog> {
  /// 首帧用预估值，布局跑完立刻换成实测值（默认字号下两者相等，看不到跳变）。
  late double _headerHeight = _estimatedHeaderHeight;
  late double _titleRowHeight = _estimatedTitleRowHeight;

  double get _estimatedTitleRowHeight =>
      GlassPickerDialog.titleTopPadding +
      GlassTokens.pillHeight +
      GlassPickerDialog.titleBottomGap;

  double get _estimatedHeaderHeight {
    double height = _estimatedTitleRowHeight;
    for (final row in widget.rows) {
      height += row.gap + row.height;
    }
    return height;
  }

  void _onHeaderMeasured(Size size) {
    if ((size.height - _headerHeight).abs() < 0.5) return;
    setState(() => _headerHeight = size.height);
  }

  void _onTitleRowMeasured(Size size) {
    if ((size.height - _titleRowHeight).abs() < 0.5) return;
    setState(() => _titleRowHeight = size.height);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double headerExtent = _headerHeight + GlassPickerDialog.tailSpacing;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: widget.constraints,
        child: Stack(
          children: [
            // 主体：列表铺满整个区域，用 paddingTop 让出 header 高度，让内容
            // 可以从上方玻璃 header 背后滚过去（与首页/作者页/搜索页同款
            // Stack + EdgeFadeScrim 模式，见 GlassHeaderOverlay）。
            Positioned.fill(child: widget.bodyBuilder(context, headerExtent)),
            // 顶部渐变蒙层：只有标题行恒定不透明，其余连同伸进内容区的尾巴
            // 一起走 smoothstep（曲线与页面档一致）。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: EdgeFadeScrim.headerOverlay(
                headerExtent: headerExtent,
                plateauExtent: _titleRowHeight,
              ),
            ),
            // 顶部玻璃控件行。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassMeasuredBox(
                onSize: _onHeaderMeasured,
                child: Column(
                  children: [
                    GlassMeasuredBox(
                      onSize: _onTitleRowMeasured,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          GlassPickerDialog.hPadding,
                          GlassPickerDialog.titleTopPadding,
                          GlassPickerDialog.hPadding,
                          GlassPickerDialog.titleBottomGap,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            for (final action in widget.titleActions) ...[
                              action,
                              const SizedBox(width: 8),
                            ],
                            GlassIconButton(
                              standalone: true,
                              icon: const Icon(Icons.close),
                              tooltip: t.common.close,
                              onPressed:
                                  widget.onClose ?? () => AppService.tryPop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final row in widget.rows)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          GlassPickerDialog.hPadding,
                          row.gap,
                          GlassPickerDialog.hPadding,
                          0,
                        ),
                        child: row.child,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择器弹窗里的玻璃胶囊输入框：半透明底色 + 细描边，与全局玻璃控件一致。
///
/// 定高交给 `prefixIcon` 的默认约束（48），四张弹窗共用同一份，
/// 不要再各自抄 `_buildGlassField` / `_fieldDecoration`。
class GlassPickerField extends StatelessWidget {
  const GlassPickerField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GlassTokens.stroke(colorScheme), width: 0.6),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
