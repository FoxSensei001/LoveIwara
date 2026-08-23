import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// [GlassAlertDialog] 正文下方一个动作按钮的描述。
///
/// 收口前，80 处裸 `AlertDialog` 各自手写 `actions:` 列表——按钮顺序、
/// 危险色（`cs.error` vs 硬编码红）、要不要 `FilledButton` 都不统一。这里
/// 把「按下去发生什么」和「长什么样」拆开：调用点只给语义（label + 是否
/// 危险动作），颜色/组件类型由这一处决定。
class GlassDialogAction {
  const GlassDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.emphasized = true,
  });

  final String label;

  /// 传 `null` 表示这个动作暂时禁用（例如提交进行中）——原样透传给
  /// `TextButton`/`FilledButton`，行为与它们直接传 `onPressed: null` 一致。
  final VoidCallback? onPressed;

  /// 危险动作（删除/清空一类不可逆操作）：按钮用 `cs.error` 语义色。
  final bool destructive;

  /// 是否是本弹窗的主动作（`FilledButton`）。次要动作（取消一类）传 false
  /// 走 `TextButton`。列表里最多应该有一个 emphasized 动作。
  final bool emphasized;
}

/// `AlertDialog` 的收口替代品——统一标题行 / 关闭钮 / 动作按钮的结构与配色。
///
/// 面板背景这一轮刻意留在**传统档**（`GlassSurface` 默认跟随祖先
/// `LiquidGlassScope`，弹窗挂在根 Navigator 上取不到页面的 scope，天然落回
/// plain，见 `liquid_glass_material.dart`）：`GlassDialogRoute` 的出入场还是
/// `FadeTransition`，套液态 lens 会复现 `showGlassMenu` 那次「文字先到、玻璃
/// 后补」的闪烁。等 [GlassDialogTransition] 换成不含透明度层的入场，再回来把
/// 面板材质接上液态——调用点不用跟着改。
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
  });

  final String title;
  final Widget? content;
  final List<GlassDialogAction> actions;

  /// 标题行是否带右上角玻璃圆钮关闭键。约定统一走 [GlassIconButton]
  /// （`standalone: true`），不要在调用点各写各的关闭图标。
  final bool showCloseButton;

  /// 正文过长时是否允许内部滚动（对齐 `AlertDialog(scrollable: true)`）。
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    Widget? body = content;
    if (scrollable && body != null) {
      body = SingleChildScrollView(child: body);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GlassSurface(
          height: null,
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleLarge),
                    ),
                    if (showCloseButton) ...[
                      const SizedBox(width: 8),
                      GlassIconButton(
                        standalone: true,
                        icon: const Icon(Icons.close),
                        tooltip: t.common.close,
                        onPressed: () => AppService.tryPop(),
                      ),
                    ],
                  ],
                ),
                if (body != null) ...[
                  const SizedBox(height: 16),
                  Flexible(child: body),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _buildAction(cs, actions[i]),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction(ColorScheme cs, GlassDialogAction action) {
    if (!action.emphasized) {
      return TextButton(
        onPressed: action.onPressed,
        style: action.destructive
            ? TextButton.styleFrom(foregroundColor: cs.error)
            : null,
        child: Text(action.label),
      );
    }
    return FilledButton(
      onPressed: action.onPressed,
      style: action.destructive
          ? FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            )
          : null,
      child: Text(action.label),
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
