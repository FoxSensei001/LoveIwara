import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

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
    this.loading = false,
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

  /// 这枚动作正在执行：文字原位换成转圈、按钮置灰。见
  /// [GlassTextActionButton.loading]。
  final bool loading;
}

/// `AlertDialog` 的收口替代品——统一标题行 / 关闭钮 / 动作按钮的结构与配色。
///
/// 液态档由 [GlassDialogRoute] 在路由层统一供（见 `glass_dialog_motion.dart`），
/// 本组件不自己包 scope。面板背景是不透明 `Material`，不是 `GlassSurface`，
/// 所以「弹窗背景不要变透明玻璃」这条要求照旧成立；变的只是标题行关闭钮和
/// 动作行按钮组的材质与手感。
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
    final cs = theme.colorScheme;

    Widget? body = content;
    if (scrollable && body != null) {
      body = SingleChildScrollView(child: body);
    }
    if (body != null) {
      // ⛔ [content] 显式关回传统档，别跟着路由那层液态 scope 走。
      //
      // 这条边界是 2026-08-24 用户在真机上纠正过的：弹窗**面板和正文**不该
      // 变成折射玻璃，只有关闭钮和动作行按钮组该换。而 [content] 是调用方
      // 给的任意内容——标签浏览器、变量说明这类还会往里塞
      // `ListView`/`SingleChildScrollView`，正是 lens 最不该进的地方。
      // 路由层供档是为了让「弹窗里的按钮」不再漏，不是为了把正文一起卷进来。
      body = LiquidGlassScope(backend: GlassBackend.plain, child: body);
    }

    // 液态档不在这里供了——[GlassDialogRoute] 已经在路由层给整张弹窗供上
    // （见 `glass_dialog_motion.dart`），本组件只管结构。面板背景仍是不透明
    // `Material`（不是 `GlassSurface`），不受 scope 影响，透底问题不会回来。
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
                    loading: action.loading,
                  ),
              ],
            ),
          );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
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
