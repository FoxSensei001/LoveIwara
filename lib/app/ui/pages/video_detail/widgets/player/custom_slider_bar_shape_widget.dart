import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../../../utils/common_utils.dart';
import '../../../../../../utils/easy_throttle.dart';
import '../../controllers/my_video_state_controller.dart';

/// 自定义的视频进度条组件
class CustomVideoProgressbar extends StatefulWidget {
  final MyVideoStateController controller;

  const CustomVideoProgressbar({super.key, required this.controller});

  @override
  _CustomVideoProgressbarState createState() => _CustomVideoProgressbarState();
}

class _CustomVideoProgressbarState extends State<CustomVideoProgressbar> {
  // 临时值，用于存储用户拖动的滑动条值（以秒为单位）
  double? _draggingValue;
  bool _dragging = false;

  // 用于存储悬停或长按的滑动条值（以秒为单位）
  double? _hoverValue;

  // 用于存储悬停或长按的像素位置，用于定位标签
  double? _hoverPosition;

  // GlobalKey 用于获取滑动条的 RenderBox
  final GlobalKey _sliderKey = GlobalKey();

  // 缓存常用的Paint对象
  final Paint _activePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final Paint _inactivePaint = Paint()
    ..color = Colors.white.withOpacity(0.3)
    ..style = PaintingStyle.fill;

  final Paint _bufferedPaint = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..style = PaintingStyle.fill;

  final Paint _hoverPaint = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..style = PaintingStyle.fill;

  // 用于判断当前是否为移动端
  bool get isMobile =>
      GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isFuchsia;

  // 添加节流机制（节流当前播放进度和总时长更新）
  Timer? _throttleTimer;
  double _throttledCurrentValue = 0.0;
  double _maxValueStored = 0.0;

  // 缓存上一次的缓冲区列表，用于比较是否需要更新
  List<BufferRange> _lastBufferRanges = [];

  // 当未拖拽时，当前显示的进度值：拖拽时用拖拽值，否则用节流后的值
  double get _currentValue => _dragging
      ? (_draggingValue ?? _throttledCurrentValue)
      : _throttledCurrentValue;

  // 节流器标签
  String videoProgressThrottleKey = 'video_progressbar:';
  String longPressMoveThrottleKey = 'long_press_move:';

  @override
  void initState() {
    super.initState();
    // 初始化节流数值
    _throttledCurrentValue =
        widget.controller.currentPosition.value.inSeconds.toDouble();
    _maxValueStored =
        widget.controller.totalDuration.value.inSeconds.toDouble();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // 加上当前的时间戳
    videoProgressThrottleKey += timestamp;
    longPressMoveThrottleKey += timestamp;

    // 使用EasyThrottle进行节流更新
    _throttleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_dragging) {
        EasyThrottle.throttle(
          videoProgressThrottleKey,
          const Duration(milliseconds: 100),
          () {
            double newVal =
                widget.controller.currentPosition.value.inSeconds.toDouble();
            double newMax =
                widget.controller.totalDuration.value.inSeconds.toDouble();
            // 当数值变化超过 0.1 秒时更新
            if ((newVal - _throttledCurrentValue).abs() >= 0.1 ||
                (_maxValueStored - newMax).abs() >= 0.1) {
              setState(() {
                _throttledCurrentValue = newVal;
                _maxValueStored = newMax;
              });
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _draggingValue = null;
    _hoverValue = null;
    _hoverPosition = null;
    _throttleTimer?.cancel();
    EasyThrottle.cancel(videoProgressThrottleKey);
    EasyThrottle.cancel(longPressMoveThrottleKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.0,
              // 使用自定义的圆形滑块
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6.0,
                pressedElevation: 4.0,
              ),
              // 设置滑块的覆盖效果
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16.0,
              ),
              // 使用自定义的轨道形状，并传入缓冲区段列表
              trackShape: CustomSliderTrackShape(
                hoverValue: _hoverValue,
                currentValue: _currentValue,
                bufferRanges: _getOptimizedBufferRanges(),
                maxValue: _maxValueStored > 0 ? _maxValueStored : 1.0,
                activePaint: _activePaint,
                inactivePaint: _inactivePaint,
                bufferedPaint: _bufferedPaint,
                hoverPaint: _hoverPaint,
              ),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.3),
              valueIndicatorColor: Colors.white,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.black,
              ),
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              key: _sliderKey,
              value: _currentValue.clamp(
                  0.0, _maxValueStored > 0 ? _maxValueStored : 1.0),
              min: 0.0,
              max: _maxValueStored > 0 ? _maxValueStored : 1.0,
              focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
              autofocus: false,
              label: CommonUtils.formatDuration(
                  Duration(seconds: _currentValue.toInt())),
              onChangeStart: (value) {
                setState(() {
                  _draggingValue = value;
                  _dragging = true;
                });
                widget.controller.setInteracting(true);
                widget.controller.showSeekPreview(true);
                widget.controller
                    .updateSeekPreview(Duration(seconds: value.toInt()));
              },
              onChanged: (value) {
                EasyThrottle.throttle(
                  'progress_change',
                  const Duration(milliseconds: 16),
                  () {
                    setState(() {
                      _draggingValue = value;
                    });
                    widget.controller
                        .updateSeekPreview(Duration(seconds: value.toInt()));
                  },
                );
              },
              onChangeEnd: (value) async {
                setState(() {
                  _dragging = false;
                });
                if (isMobile) {
                  await HapticFeedback.lightImpact();
                }
                widget.controller.sliderDragLoadFinished.value = false;
                widget.controller.handleSeek(Duration(seconds: value.toInt()));
                widget.controller.setInteracting(false);
                widget.controller.showSeekPreview(false);
              },
            ),
          ),
          // 显示悬停或长按标签
          if (_hoverValue != null && _hoverPosition != null)
            _buildHoverPreview(),
        ],
      ),
    );
  }

  // 优化缓冲区列表，避免频繁更新
  List<BufferRange> _getOptimizedBufferRanges() {
    final currentRanges = widget.controller.buffers.toList();

    // 如果缓冲区没有变化，直接返回缓存的列表
    if (_areBufferRangesEqual(currentRanges, _lastBufferRanges)) {
      return _lastBufferRanges;
    }

    // 更新缓存并返回新列表
    _lastBufferRanges = List.from(currentRanges);
    return currentRanges;
  }

  // 比较两个缓冲区列表是否相等
  bool _areBufferRangesEqual(List<BufferRange> list1, List<BufferRange> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].start != list2[i].start || list1[i].end != list2[i].end) {
        return false;
      }
    }

    return true;
  }

  Widget _buildHoverPreview() {
    return Positioned(
      left: _hoverPosition! - 30,
      bottom: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          CommonUtils.formatDuration(Duration(seconds: _hoverValue!.toInt())),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// 自定义的滑动条轨道形状，用于实现鼠标悬停效果和显示多个缓冲区段
class CustomSliderTrackShape extends SliderTrackShape {
  final double? hoverValue;
  final double currentValue;
  final List<BufferRange> bufferRanges;
  final double maxValue;
  final Paint activePaint;
  final Paint inactivePaint;
  final Paint bufferedPaint;
  final Paint hoverPaint;

  CustomSliderTrackShape({
    this.hoverValue,
    required this.currentValue,
    required this.bufferRanges,
    required this.maxValue,
    required this.activePaint,
    required this.inactivePaint,
    required this.bufferedPaint,
    required this.hoverPaint,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 计算当前播放位置的比例
    double currentRatio = (currentValue / maxValue).clamp(0.0, 1.0);
    double currentX = trackRect.left + currentRatio * trackRect.width;

    // 绘制未播放部分
    context.canvas.drawRect(
      Rect.fromLTRB(currentX, trackRect.top, trackRect.right, trackRect.bottom),
      inactivePaint,
    );

    // 绘制已播放部分
    context.canvas.drawRect(
      Rect.fromLTRB(trackRect.left, trackRect.top, currentX, trackRect.bottom),
      activePaint,
    );

    // 绘制缓冲区段
    for (BufferRange range in bufferRanges) {
      double startRatio = (range.start.inSeconds / maxValue).clamp(0.0, 1.0);
      double endRatio = (range.end.inSeconds / maxValue).clamp(0.0, 1.0);
      double startX = trackRect.left + startRatio * trackRect.width;
      double endX = trackRect.left + endRatio * trackRect.width;

      // 确保缓冲区段在已播放部分之后
      if (endX <= currentX) continue;

      // 缓冲区段的起始点不能小于当前播放位置
      if (startX < currentX) {
        startX = currentX;
      }

      // 绘制缓冲区段
      context.canvas.drawRect(
        Rect.fromLTRB(startX, trackRect.top, endX, trackRect.bottom),
        bufferedPaint,
      );
    }

    // 如果有悬停值且悬停值在未播放区域，则增强该区域的颜色
    if (hoverValue != null && hoverValue! > currentValue) {
      double hoverRatio = (hoverValue! / maxValue).clamp(0.0, 1.0);
      double hoverX = trackRect.left + hoverRatio * trackRect.width;

      // 确保hoverX不超过轨道右边界
      hoverX = hoverX.clamp(trackRect.left, trackRect.right);

      // 绘制从当前播放位置到hover位置的增强颜色
      context.canvas.drawRect(
        Rect.fromLTRB(currentX, trackRect.top, hoverX, trackRect.bottom),
        hoverPaint,
      );
    }
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

/// 定义缓冲区段的类
class BufferRange {
  final Duration start;
  final Duration end;

  BufferRange({required this.start, required this.end});

  /// 合并两个重叠或相邻的缓冲区段
  bool overlapsOrAdjacent(BufferRange other) {
    return end >= other.start && other.end >= start;
  }

  /// 合并两个缓冲区段，返回一个新的缓冲区段
  BufferRange merge(BufferRange other) {
    return BufferRange(
      start: start < other.start ? start : other.start,
      end: end > other.end ? end : other.end,
    );
  }
}
