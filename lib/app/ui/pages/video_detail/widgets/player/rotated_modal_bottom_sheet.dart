import 'package:flutter/material.dart';

import '../../../../../routes/app_router.dart';
import '../../controllers/my_video_state_controller.dart';
import 'video_fullscreen_morph_overlay.dart';

/// 「应用内伪横屏全屏」下弹出与播放器方向一致的 bottom sheet。
///
/// 背景：手机端锁定竖屏时，全屏是用 `RotatedBox + FakeRotatedMediaQuery` 把播放器
/// 子树转 90° 假装横屏（见 [MyVideoStateController.enterFullscreen] /
/// [video_detail_page_v2] 里的伪横屏宿主）。而 `showModalBottomSheet` 会把 sheet
/// 作为一条路由推到 Navigator/Overlay 上，那个 Overlay 在 RotatedBox 之外，于是
/// sheet 按物理竖屏方向弹出——用户横着拿手机看，就变成从侧边冒出、文字方向差 90°。
///
/// 本方法在伪横屏时改用一条同样套上 `RotatedBox + FakeRotatedMediaQuery` 的自定义
/// 路由，让 sheet 落进和播放器一致的旋转坐标系；桌面 / 真横屏（如平板系统旋转）/
/// 竖屏时旋转圈数为 0，原样走标准 [showModalBottomSheet]，行为不变。
/// 播放器当前是否处于「应用内伪横屏」（需要把路由弹层旋转进播放器坐标系）。
///
/// 关键：旋转圈数必须从「物理（未旋转）context」推算——`resolveActiveFullscreenQuarterTurns`
/// 无参调用内部使用 `rootNavigatorKey.currentContext`。若传入工具栏 / sheet 里的 context，
/// 它已被 [FakeRotatedMediaQuery] 伪装成横屏（orientation==landscape），会被误判为 0。
bool playerOverlayNeedsRotation(MyVideoStateController controller) =>
    controller.isFullscreen.value &&
    (controller.resolveActiveFullscreenQuarterTurns() % 4) != 0;

Future<T?> showPlayerRotationAwareModalBottomSheet<T>({
  required BuildContext context,
  required MyVideoStateController controller,
  required WidgetBuilder builder,
  ShapeBorder? shape,
  // 传 null 走主题默认背景；传 Colors.transparent 让 sheet 内容自绘背景
  // （对齐 showAppBottomSheet 的默认透明底）。
  Color? backgroundColor,
  // 仅作用于非旋转的 showModalBottomSheet 回退分支；旋转分支的自定义路由是整页高度
  // 承载，天然等价于 isScrollControlled: true。
  bool isScrollControlled = true,
}) {
  final int turns = controller.resolveActiveFullscreenQuarterTurns() % 4;
  final bool needsRotation = controller.isFullscreen.value && turns != 0;

  if (!needsRotation) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: shape,
      backgroundColor: backgroundColor,
      builder: builder,
    );
  }

  final NavigatorState navigator =
      rootNavigatorKey.currentState ??
      Navigator.of(context, rootNavigator: true);
  final ThemeData theme = Theme.of(context);
  final Color sheetColor =
      backgroundColor ??
      theme.bottomSheetTheme.backgroundColor ??
      theme.colorScheme.surface;

  return navigator.push<T>(
    RawDialogRoute<T>(
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(
        context,
      ).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        // 先旋转（负责布局/绘制/命中测试），再用 FakeRotatedMediaQuery 让子树里的
        // MediaQuery 消费者（安全区、尺寸、DraggableScrollableSheet 的分数）读到
        // 旋转后的横屏值。SlideTransition 放在旋转坐标系内部，滑入方向才是视觉底部。
        return RotatedBox(
          quarterTurns: turns,
          child: FakeRotatedMediaQuery(
            quarterTurns: turns,
            child: SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                // 与标准 showModalBottomSheet 保持一致：Material 3 默认把 sheet 宽度
                // 限制在 640 并居中，否则伪横屏下会铺满整个横屏宽度（≈ 设备竖屏高度，
                // 手机上通常 > 640），观感与非旋转路径不一致。
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Material(
                    color: sheetColor,
                    shape: shape,
                    clipBehavior: Clip.antiAlias,
                    child: Builder(builder: builder),
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

/// 与 [showPlayerRotationAwareModalBottomSheet] 同理，但面向居中的 [showDialog]
/// 类弹窗（seek 跳转、手势指引等）。伪横屏时改推套上 `RotatedBox +
/// FakeRotatedMediaQuery` 的 [RawDialogRoute]，对话框自身仍居中，只是落进播放器的
/// 横屏坐标系；否则原样走标准 [showDialog]，行为不变。
Future<T?> showPlayerRotationAwareDialog<T>({
  required BuildContext context,
  required MyVideoStateController controller,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final int turns = controller.resolveActiveFullscreenQuarterTurns() % 4;
  final bool needsRotation = controller.isFullscreen.value && turns != 0;

  if (!needsRotation) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  final NavigatorState navigator =
      rootNavigatorKey.currentState ??
      Navigator.of(context, rootNavigator: true);

  return navigator.push<T>(
    RawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        context,
      ).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        // 对话框（AlertDialog / Dialog）自身居中；这里只负责把它旋转进横屏坐标系。
        // SafeArea 读旋转后的安全区，避免对话框压到刘海 / Home 指示条。
        return RotatedBox(
          quarterTurns: turns,
          child: FakeRotatedMediaQuery(
            quarterTurns: turns,
            child: SafeArea(child: Builder(builder: builder)),
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        // 与标准对话框一致的淡入；drive 复用路由 animation，无需释放 CurvedAnimation。
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: child,
        );
      },
    ),
  );
}

/// 单选列表项，用于 [showPlayerRotationAwareOptionSheet]。
class PlayerPickerOption<T> {
  final T value;
  final String label;
  final Widget? leading;
  final String? subtitle;
  final bool selected;

  const PlayerPickerOption({
    required this.value,
    required this.label,
    this.leading,
    this.subtitle,
    this.selected = false,
  });
}

/// 伪横屏全屏下替代 [PopupMenuButton] 的单选列表：菜单路由的定位与内容都在
/// RotatedBox 之外，无法随播放器旋转，故改用一个方向正确的 bottom sheet 承载
/// 选项列表。选中即 pop 出对应 value，由调用方执行原 onSelected 逻辑。
Future<T?> showPlayerRotationAwareOptionSheet<T>({
  required BuildContext context,
  required MyVideoStateController controller,
  String? title,
  required List<PlayerPickerOption<T>> options,
}) {
  return showPlayerRotationAwareModalBottomSheet<T>(
    context: context,
    controller: controller,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _PlayerOptionSheetBody<T>(title: title, options: options),
  );
}

class _PlayerOptionSheetBody<T> extends StatelessWidget {
  final String? title;
  final List<PlayerPickerOption<T>> options;

  const _PlayerOptionSheetBody({this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              itemCount: options.length,
              itemBuilder: (ctx, i) {
                final PlayerPickerOption<T> o = options[i];
                return ListTile(
                  leading: o.leading,
                  title: Text(o.label),
                  subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                  trailing: o.selected
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  selected: o.selected,
                  onTap: () => Navigator.of(ctx).pop(o.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
