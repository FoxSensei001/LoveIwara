import 'package:flutter/material.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
typedef SlideChangeCallback = void Function(
    double leftRatio, double middleRatio, double rightRatio);

class ThreeSectionSlider extends StatefulWidget {
  /// 回调函数，当滑块滑动结束时触发，返回左、中、右三部分的比例
  final SlideChangeCallback? onSlideChangeCallback;
  final double initialLeftRatio;
  final double initialMiddleRatio;
  final double initialRightRatio;

  const ThreeSectionSlider({
    super.key,
    this.onSlideChangeCallback,
    required this.initialLeftRatio,
    required this.initialMiddleRatio,
    required this.initialRightRatio,
  });

  @override
  State<ThreeSectionSlider> createState() => _ThreeSectionSliderState();
}

class _ThreeSectionSliderState extends State<ThreeSectionSlider> {
  late double leftRatio;
  late double middleRatio;
  late double rightRatio;
  final double minSideRatio = 0.2;

  @override
  void initState() {
    super.initState();
    leftRatio = widget.initialLeftRatio;
    middleRatio = widget.initialMiddleRatio;
    rightRatio = widget.initialRightRatio;
  }

  void _updateRatios(int dividerIndex, double delta) {
    setState(() {
      if (dividerIndex == 0) {
        // 移动左侧分隔线
        double newLeftRatio =
            (leftRatio + delta).clamp(minSideRatio, 0.5 - minSideRatio / 2);
        double change = newLeftRatio - leftRatio;
        leftRatio = rightRatio = newLeftRatio;
        middleRatio -= change * 2;
      } else {
        // 移动右侧分隔线
        double newRightRatio =
            (rightRatio - delta).clamp(minSideRatio, 0.5 - minSideRatio / 2);
        double change = newRightRatio - rightRatio;
        leftRatio = rightRatio = newRightRatio;
        middleRatio -= change * 2;
      }
    });
  }

  void _onSlideChangeFinished() {
    LogUtils.d('左侧: ${(leftRatio * 100).toStringAsFixed(1)}% | '
        '中间: ${(middleRatio * 100).toStringAsFixed(1)}% | '
        '右侧: ${(rightRatio * 100).toStringAsFixed(1)}%');
    // 调用外部回调
    if (widget.onSlideChangeCallback != null) {
      widget.onSlideChangeCallback!(leftRatio, middleRatio, rightRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      children: [
        // 三段式滑块
        SizedBox(
          height: 50,
          child: Row(
            children: [
              _buildSection(Colors.red, leftRatio, t.settings.left),
              _buildDivider(0),
              _buildSection(Colors.green, middleRatio, t.settings.middle),
              _buildDivider(1),
              _buildSection(Colors.blue, rightRatio, t.settings.right),
            ],
          ),
        ),
        // 显示比例
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${t.settings.left}: ${(leftRatio * 100).toStringAsFixed(1)}% | '
            '${t.settings.middle}: ${(middleRatio * 100).toStringAsFixed(1)}% | '
            '${t.settings.right}: ${(rightRatio * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(Color color, double ratio, String label) {
    return Expanded(
      flex: (ratio * 100).round(),
      child: Container(
        color: color,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(int index) {
    return GestureDetector(
      onPanUpdate: (details) {
        double delta = details.delta.dx / context.size!.width;
        _updateRatios(index, delta);
      },
      onPanEnd: (_) => _onSlideChangeFinished(),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 20,
          color: Colors.transparent,
          child: const VerticalDivider(
            color: Colors.black,
            thickness: 2,
            width: 20,
          ),
        ),
      ),
    );
  }
}
