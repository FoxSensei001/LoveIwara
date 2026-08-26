// 下载页“按比例缩放”支持（思路类似微信小程序 rpx，但带钳制）。
//
// 目标：手机窄屏上整页 UI（按钮 / 缩略图 / 间距 / 字号）按屏宽等比缩小，
// 让本为大屏设计的尺寸在小屏上不再笨重；而 PC / 平板大屏保持现状（系数封顶 1.0），
// 避免纯 rpx 在宽屏上把元素放得过大。
//
// 用法：
// 1. 在下载页 body 外层包一层 [DownloadScaleScope]，它会按屏宽计算系数，
//    并统一缩放子树内的文字（textScaler）与 IconButton。
// 2. 列表项内对写死的尺寸（缩略图 / padding / 头像等）乘以
//    `DownloadUiScale.of(context)` 得到的系数即可。
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

/// 计算下载页的缩放系数。
///
/// - `width <= [minWidth]`：取下限 [minScale]（极窄设备最多缩到这里）。
/// - `width >= [maxWidth]`：取 1.0（平板 / 桌面保持原始尺寸）。
/// - 区间内线性插值。
///
/// 典型手机：360dp ≈ 0.85，390dp ≈ 0.87，落在“适度缩小”的区间。
double resolveDownloadUiScale(
  double width, {
  double minWidth = 320,
  double maxWidth = 600,
  double minScale = 0.82,
  double maxScale = 1.0,
}) {
  if (width <= minWidth) return minScale;
  if (width >= maxWidth) return maxScale;
  final t = (width - minWidth) / (maxWidth - minWidth);
  return minScale + (maxScale - minScale) * t;
}

/// 通过 InheritedWidget 向列表项下发当前缩放系数，保证全页一致、随屏宽变化自动重建。
class DownloadUiScale extends InheritedWidget {
  final double scale;

  const DownloadUiScale({
    super.key,
    required this.scale,
    required super.child,
  });

  /// 读取当前缩放系数；不在 [DownloadScaleScope] 内时回退为 1.0（不缩放）。
  static double of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<DownloadUiScale>();
    return widget?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(DownloadUiScale oldWidget) =>
      scale != oldWidget.scale;
}

/// 下载页缩放作用域：按屏宽计算系数后，统一缩放子树内的
/// 文字（textScaler）与 IconButton（图标尺寸 / 内边距 / 触控区），
/// 并通过 [DownloadUiScale] 下发系数给需要手动缩放尺寸的列表项。
class DownloadScaleScope extends StatelessWidget {
  final Widget child;

  const DownloadScaleScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = resolveDownloadUiScale(mq.size.width);

    // 组合系统文字缩放与本页缩放（系统侧按线性近似，覆盖绝大多数场景）。
    final baseTextFactor = mq.textScaler.scale(1.0);
    final textScaler = TextScaler.linear(baseTextFactor * scale);

    return DownloadUiScale(
      scale: scale,
      child: MediaQuery(
        data: mq.copyWith(textScaler: textScaler),
        child: child,
      ),
    );
  }
}

/// 列表项操作按钮的样式：无背景、矩形、左右 padding 很小、按钮间不留间距。
///
/// 保留一定高度（约 40）以方便点击，但去掉 Material 强制的 48 圆形触控区与
/// 多余的水平视觉 padding，让多个按钮并排时横向紧凑、不被“隐形 padding”撑大。
///
/// 仅用于条目内的操作按钮（通过外包一层 [DownloadActionButtonTheme]），
/// 不影响搜索框 / 筛选栏里的图标按钮。
ButtonStyle downloadActionIconButtonStyle(double scale) {
  return IconButton.styleFrom(
    iconSize: 22 * scale,
    // 水平 padding 收到很小，按钮宽度基本贴着图标；垂直留一点以保证高度好按。
    padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 8 * scale),
    minimumSize: Size(0, 40 * scale),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

/// 给子树里的 [IconButton] 套上 [downloadActionIconButtonStyle]。
/// 包在条目操作按钮所在的 Row 外层即可，只影响其中的图标按钮。
class DownloadActionButtonTheme extends StatelessWidget {
  final Widget child;

  const DownloadActionButtonTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scale = DownloadUiScale.of(context);
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: downloadActionIconButtonStyle(scale),
      ),
      child: child,
    );
  }
}

/// 条目里那只「更多」按钮：外观和身边的 [IconButton] 一致（同一份
/// [downloadActionIconButtonStyle] 的尺寸），手感走全站玻璃那套。
///
/// 单独立一个组件，是因为它比邻座多两件事，而这两件都不能靠调用点各写一遍：
///   - **长按也能开菜单，且不抬手可以直接划到某一条上松手选中**——由
///     [GlassPressable.opensOverlay] 声明（见 `GlassTapArea.opensOverlay`）；
///     `IconButton` 接不了这条。
///   - **菜单要贴着这只按钮弹**，落点得拿按钮自身的 `RenderBox` 量，所以
///     [onPressed] 收到的是 [Builder] 给的 anchorContext，而不是外层那张卡片。
class DownloadMoreButton extends StatelessWidget {
  const DownloadMoreButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;

  /// 参数是这只按钮自身的 context，直接拿去当玻璃菜单的 `anchorContext`。
  final void Function(BuildContext anchorContext) onPressed;

  @override
  Widget build(BuildContext context) {
    final scale = DownloadUiScale.of(context);
    return Tooltip(
      message: tooltip,
      child: Builder(
        builder: (anchorContext) => GlassPressable(
          opensOverlay: true,
          onTap: () => onPressed(anchorContext),
          builder: (context, pressed) => SizedBox(
            height: 40 * scale,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              child: Center(
                child: Icon(
                  Icons.more_horiz,
                  size: 22 * scale,
                  // 与身边 IconButton 的默认前景色对齐（M3 的 icon button
                  // 取 onSurfaceVariant，裸 Icon 走的是 iconTheme）。
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
