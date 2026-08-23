import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// [GlassAlertDialog] 正文下方一个动作按钮的描述。
///
/// 收口前，80 处裸 `AlertDialog` 各自手写 `actions:` 列表——按钮顺序、
/// 危险色（`cs.error` vs 硬编码红）、要不要强调都不统一，且清一色裸
/// `TextButton`/`FilledButton`。这里把「按下去发生什么」和「长什么样」
/// 拆开：调用点只给语义（label + 是否危险动作），渲染统一走
/// `GlassButtonGroup` + `GlassTextActionButton`——多个动作键共处同一坨玻璃，
/// 按住会一起蠕动。
class GlassDialogAction {
  const GlassDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.emphasized = true,
  });

  final String label;

  /// 传 `null` 表示这个动作暂时禁用（例如提交进行中）——原样透传给
  /// `GlassTextActionButton.onPressed`，行为与它直接传 `onPressed: null` 一致。
  final VoidCallback? onPressed;

  /// 危险动作（删除/清空一类不可逆操作）：文字转 `cs.error` 语义色。
  final bool destructive;

  /// 是否是本弹窗的主动作：转主色 + 字重加粗。次要动作（取消一类）传 false
  /// 留默认色。列表里最多应该有一个 emphasized 动作。
  final bool emphasized;
}

/// `AlertDialog` 的收口替代品——统一标题行 / 关闭钮 / 动作按钮的结构与配色。
///
/// 2026-08-24 给内容接上液态：**面板背景本身不接**——`GlassSurface` 调用
/// 留在 scope 之外，读的是弹窗自己所在位置的祖先 `LiquidGlassScope`（挂在
/// 根 Navigator 上，天然没有祖先，落回 plain，背景与收口前一致）。只有
/// 标题行的关闭钮、动作行的 [GlassButtonGroup] 显式钉死
/// [kChromeGlassBackend]（与页面 header chrome 同一档），长出液态档的长按
/// 蠕动。此前面板整体留在传统档是因为 `GlassDialogRoute` 的出入场是
/// `FadeTransition`——套液态 lens 会复现 `showGlassMenu` 那次「文字先到、
/// 玻璃后补」的闪烁；[GlassDialogTransition] 现在已经不含任何透明度层，
/// 换成 [GlassDialogMotionScope] 把驱动动画递下来，这里读它驱动
/// `GlassSurface.materialize`（材质自身淡入，不建 saveLayer——面板背景虽然
/// 留在传统档，这条淡入照样安全、也照样接）。调用点不用跟着改，
/// `showAppDialog`/[showGlassAlertDialog] 照常打开。
///
/// 动作行（[actions]）走 [GlassButtonGroup] + `GlassTextActionButton`——多个
/// 动作键共处同一坨玻璃，按住会一起蠕动（[GlassButtonGroup.touchFlex]
/// 默认开），不是各自一只裸 `TextButton`/`FilledButton`。
///
/// 用 [showGlassAlertDialog] 打开，不要直接 `showDialog(GlassAlertDialog(...))`
/// ——出入场动画、安全区、主题继承都在那层。
class GlassAlertDialog extends StatelessWidget {
  const GlassAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions = const [],
    this.showCloseButton = true,
    this.scrollable = false,
    this.maxWidth = 400,
  });

  /// 传 `null` 跳过整个内建标题行（含右上角关闭钮）——用于标题位置需要放
  /// 自定义内容（搜索框、额外的图标动作）的场合，这时 [showCloseButton]
  /// 不再生效，调用方要自己在 [content] 里搭标题行和关闭键（关闭键仍应走
  /// `GlassIconButton(standalone: true)`，约定不变，只是不再由本组件代建）。
  final String? title;
  final Widget? content;
  final List<GlassDialogAction> actions;

  /// 标题行是否带右上角玻璃圆钮关闭键。约定统一走 [GlassIconButton]
  /// （`standalone: true`），不要在调用点各写各的关闭图标。[title] 为 null
  /// 时本项被忽略（整个标题行都不建）。
  final bool showCloseButton;

  /// 正文过长时是否允许内部滚动（对齐 `AlertDialog(scrollable: true)`）。
  final bool scrollable;

  /// 面板最大宽度。默认 400 是「提示/确认」这类短内容的舒适宽度；
  /// 标签浏览器、变量说明这类需要摆下一张列表或宽表格的内容可以调大。
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    Widget? body = content;
    if (scrollable && body != null) {
      body = SingleChildScrollView(child: body);
    }

    // 弹窗挂在根 Navigator 上，读不到入场动画就当静止态（materialize 恒为
    // 1）——单测、或未来别的路由实现之外套一层 GlassAlertDialog 时不会崩。
    final Animation<double>? motion = GlassDialogMotionScope.maybeOf(context);

    // ⛔ 只给「标题行的关闭钮」和「动作行的按钮组」接液态，别的一律不碰：
    //   - 面板背景（下面的 GlassSurface 调用）留在 scope 之外，读的是弹窗
    //     自己所在位置的祖先 scope（挂在根 Navigator 上，天然没有祖先，
    //     落回 plain，背景与收口前一致）；
    //   - [body] 是调用方给的任意内容，可能含 `ListView`/`SingleChildScrollView`
    //     （标签浏览器、变量说明这类列表型对话框）——lens 不该进滚动容器，
    //     scope 不能连它一起裹进去，只精确包这两处按钮。
    final closeButton = showCloseButton
        ? LiquidGlassScope(
            backend: kChromeGlassBackend,
            child: GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.close),
              tooltip: t.common.close,
              onPressed: () => AppService.tryPop(),
            ),
          )
        : null;

    final actionGroup = actions.isEmpty
        ? null
        : LiquidGlassScope(
            backend: kChromeGlassBackend,
            child: GlassButtonGroup(
              children: [
                for (final action in actions)
                  GlassTextActionButton(
                    label: action.label,
                    onPressed: action.onPressed,
                    emphasized: action.emphasized,
                    destructive: action.destructive,
                  ),
              ],
            ),
          );

    Widget buildSurface(double materialize) => GlassSurface(
      height: null,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      materialize: materialize,
      // 传统档的 GlassSurface 不建 Material 祖先（液态档的两个后端各自
      // 内部有一层，传统档没有）。弹窗正文常见 TextField / InkWell 一类
      // 依赖 Material 的控件，没有这一层会直接抛
      // "No Material widget found"（download_category_manage_page.dart /
      // search_dialog.dart 的输入框弹窗曾经踩过）。这里补一层透明
      // Material，不带颜色/阴影，纯粹补祖先，不影响玻璃材质的视觉。
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(title!, style: theme.textTheme.titleLarge),
                  ),
                  if (closeButton != null) ...[
                    const SizedBox(width: 8),
                    closeButton,
                  ],
                ],
              ),
            ],
            if (body != null) ...[
              const SizedBox(height: 16),
              Flexible(child: body),
            ],
            if (actionGroup != null) ...[
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: actionGroup),
            ],
          ],
        ),
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: motion == null
            ? buildSurface(1.0)
            : AnimatedBuilder(
                animation: motion,
                builder: (context, _) => buildSurface(motion.value),
              ),
      ),
    );
  }
}

/// 打开 [GlassAlertDialog]。语义与 `showDialog` 一致，出入场走
/// `showAppDialog`（[GlassDialogRoute]）。
Future<T?> showGlassAlertDialog<T>({
  required String title,
  Widget? content,
  List<GlassDialogAction> actions = const [],
  bool showCloseButton = true,
  bool scrollable = false,
  bool barrierDismissible = true,
  GlassDialogMotion motion = GlassDialogMotion.auto,
}) {
  return showAppDialog<T>(
    GlassAlertDialog(
      title: title,
      content: content,
      actions: actions,
      showCloseButton: showCloseButton,
      scrollable: scrollable,
    ),
    barrierDismissible: barrierDismissible,
    motion: motion,
  );
}
