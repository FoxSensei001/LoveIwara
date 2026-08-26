import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/swipe_back_guard.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// `Slider` 的收口替代品。
///
/// 与 [GlassSwitchListTile] 同一个理由：设置页里的滑块恒在滚动容器里，不接
/// 真液态 lens，只统一颜色到 [GlassTokens]。是 `Slider` 的直接替换，参数
/// 透传，不改变调用点的行为。
///
/// 自带独立三色轨道（`ThreeSectionSlider`）不在此列——那是自绘控件，不是
/// `Slider`，样式已经自成一套。
///
/// 外面那层 [SwipeBackAbsorber] 是必需的：Material `Slider` 的横向拖拽识别器建在
/// `_RenderSlider` 里，不经过 `GestureDetector`，[SwipeBackScrollGuard] 认不出来，
/// 于是 iOS 上「整页跟手侧滑返回」会抢走向右拖动滑块的手势。
class GlassSlider extends StatelessWidget {
  const GlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.onChangeStart,
    this.onChangeEnd,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SwipeBackAbsorber(
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: cs.primary,
          inactiveTrackColor: GlassTokens.fill(cs),
          thumbColor: cs.primary,
          overlayColor: cs.primary.withValues(alpha: 0.12),
        ),
        child: Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
        ),
      ),
    );
  }
}
