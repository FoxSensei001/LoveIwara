import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/vr/vr_format_menu.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/widgets/player_tip_metrics.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「这可能是一段 VR 视频」的建议提示。
///
/// # 它为什么存在
///
/// 「这是不是 VR 片」原理上不可知：Iwara 不给格式元数据，文件里也没有球面标记。
/// 检测器能做到的最好程度是「文本像 + 宽高比 ≈2:1」，而 2.0:1 本身是一种真实存在
/// 的电影画幅——照着它自动换几何，撞上就会把一部普通片当场拆成两半，观感是「视频
/// 坏了」。所以画面**永远不自动变**，机器把话说出来，最后一步交给眼睛。
///
/// # 几何与密度
///
/// 与续播提示共用 [player_tip_metrics] 那一份几何：住在底部工具栏的 Column 里、
/// 强制单行、窄屏按优先级逐层脱衣服而不是换行。理由见那个文件与
/// `ResumePositionTip` 的类文档，这里不再重复——但**别自作主张换行**：
/// [bottomToolbarEstimatedHeight] 按「一条一种高度」记账。
///
/// # 只收纯值
///
/// 与 `ResumePositionTip` 同一考虑：不收 `MyVideoStateController`，这样它能在窄到
/// 200px 的约束下被直接 widget 测，不必搭起整套 GetX 服务。
class VrSuggestionTip extends StatelessWidget {
  const VrSuggestionTip({
    super.key,
    required this.format,
    required this.isFullScreen,
    required this.onOpenPicker,
    required this.onDismiss,
  });

  /// 机器猜的那一档，用来把话说具体（「这可能是 VR180 左右」而不是干巴巴的
  /// 「这可能是 VR」）——用户据此判断猜得对不对，比一句泛泛的提醒有用得多。
  final VrSourceFormat format;

  final bool isFullScreen;

  /// 打开播放模式菜单。传出去的是**动作按钮自己的 context**：菜单要贴着它弹，
  /// 拿外层的 context 会让面板飞到工具栏中央去。
  final ValueChanged<BuildContext> onOpenPicker;

  /// 「×」：这条提示到此为止。建议本身还留着，顶栏那枚钮随时够得着。
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double fontSize = resumeTipFontSize(isFullScreen: isFullScreen);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextStyle labelStyle = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
    );
    final TextStyle actionStyle = labelStyle.copyWith(
      fontWeight: FontWeight.w600,
    );
    final String actionLabel = t.vrFormat.suggestionAction;
    final double iconSize = fontSize + 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: kResumeTipGap),
      // 外层 Row 负责靠左；Flexible 让胶囊最宽不超过工具栏宽度，
      // 因而内部的 Flexible 文字拿得到有界约束，可以正常省略。
      child: Row(
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double actionWidth =
                    measurePlayerTipText(actionLabel, actionStyle, scaler) +
                    kResumeTipActionHPad * 2;
                final ResumeTipDensity density = resolveResumeTipDensity(
                  maxWidth: constraints.maxWidth,
                  actionWidth: actionWidth,
                  iconWidth: iconSize,
                  closeWidth: kResumeTipActionHeight,
                );

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kResumeTipHPad,
                    vertical: kResumeTipVPad,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (density == ResumeTipDensity.full) ...[
                        Icon(
                          Icons.threesixty,
                          size: iconSize,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: kResumeTipGapInner),
                      ],
                      Flexible(
                        child: Text(
                          // 窄屏（density 一降就说明这块地方摆不下完整句子）只说
                          // 「这可能是 VR 视频」；宽屏才把猜的那一档念出来。窗口
                          // 小的时候，一句被省略号砍掉一半的长句还不如一句短的。
                          density == ResumeTipDensity.full
                              ? t.vrFormat.suggestionTitle(
                                  format: vrFormatLabel(format),
                                )
                              : t.vrFormat.suggestionTitleShort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: labelStyle,
                        ),
                      ),
                      const SizedBox(width: kResumeTipGapInner),
                      _VrTipAction(
                        label: actionLabel,
                        style: actionStyle,
                        // 极窄档才让按钮文字也省略：宁可按钮难看，也不能溢出——
                        // 溢出的子组件会画到播放条上，把那一片点击整个吃掉。
                        allowShrink: density == ResumeTipDensity.minimal,
                        onOpenPicker: onOpenPicker,
                      ),
                      if (density == ResumeTipDensity.full) ...[
                        const SizedBox(width: kResumeTipGapTight),
                        _VrTipCloseButton(
                          tooltip: t.vrFormat.suggestionDismiss,
                          size: kResumeTipActionHeight,
                          onTap: onDismiss,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 提示上的主动作（「以 VR 播放」）。
///
/// 走 [GlassPressable] 而不是 `InkWell`，为的是 `opensOverlay: true` 那一句：它按
/// 下去开的是玻璃菜单，所以长按也该开，而且要能**按住不抬手直接划到某一档松手
/// 选中**（见 `GlassTapArea.opensOverlay`）。组件猜不出 onTap 会干什么，只能由
/// 调用点声明。
///
/// 高度钉死为 [kResumeTipActionHeight] 而不是交给按钮自己撑：
/// [bottomToolbarEstimatedHeight] 要按这个数预留，按钮自己算高度就会两边漂移。
class _VrTipAction extends StatelessWidget {
  const _VrTipAction({
    required this.label,
    required this.style,
    required this.allowShrink,
    required this.onOpenPicker,
  });

  final String label;
  final TextStyle style;

  /// 极窄档下允许文字省略，见 [ResumeTipDensity.minimal]。
  final bool allowShrink;
  final ValueChanged<BuildContext> onOpenPicker;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return Builder(
      builder: (anchorContext) => GlassPressable(
        opensOverlay: true,
        onTap: () => onOpenPicker(anchorContext),
        builder: (context, pressed) => SizedBox(
          height: kResumeTipActionHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kResumeTipActionHPad,
              ),
              // 用 Row 而不是 Center：Flexible 只有直接放在 Flex 里才合法，
              // 放进 Center 会触发 "Incorrect use of ParentDataWidget"。
              // Row 的 crossAxisAlignment 默认就是 center，垂直居中效果一样。
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [allowShrink ? Flexible(child: text) : text],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 关闭按钮。提示本身到点自动消失，这里只是给一个「我看到了，现在就收起」的出口。
class _VrTipCloseButton extends StatelessWidget {
  const _VrTipCloseButton({
    required this.tooltip,
    required this.size,
    required this.onTap,
  });

  final String tooltip;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GlassPressable(
        onTap: onTap,
        builder: (context, pressed) => SizedBox.square(
          dimension: size,
          child: const Icon(Icons.close, color: Colors.white70, size: 15),
        ),
      ),
    );
  }
}
