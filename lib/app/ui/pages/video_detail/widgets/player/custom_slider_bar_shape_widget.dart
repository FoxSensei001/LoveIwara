import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../../../../../../utils/common_utils.dart';
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

  // 用于判断当前是否为移动端
  bool get isMobile =>
      GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isFuchsia;

  // 将平台判断逻辑提取为getter
  bool get _shouldHandleHover => !isMobile;

  // 添加计算值的getter
  double get _currentValue {
    if ((widget.controller.videoBuffering.value && 
         !widget.controller.sliderDragLoadFinished.value) || 
        _dragging) {
      return _draggingValue ?? 0.0;
    }
    return widget.controller.currentPosition.value.inSeconds.toDouble();
  }

  double get _maxValue => 
      widget.controller.totalDuration.value.inSeconds.toDouble();

  @override
  void dispose() {
    _draggingValue = null;
    _hoverValue = null;
    _hoverPosition = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onLongPressStart: isMobile ? _handleLongPress : null,
          onLongPressMoveUpdate: isMobile ? _handleLongPressMoveUpdate : null,
          onLongPressEnd: isMobile ? _handleLongPressEnd : null,
          child: MouseRegion(
            onEnter: _shouldHandleHover ? _handleMouseEnter : null,
            onExit: _shouldHandleHover ? _handleMouseExit : null,
            onHover: _shouldHandleHover ? _handleMouseHover : null,
            child: Obx(() {
              return Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12.0,
                      ),
                      // 使用自定义的轨道形状，并传入缓冲区段列表
                      trackShape: CustomSliderTrackShape(
                        hoverValue: _hoverValue,
                        currentValue: _currentValue,
                        bufferRanges: widget.controller.buffers,
                        maxValue: _maxValue,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.1),
                      valueIndicatorColor: Colors.white,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    child: Slider(
                      key: _sliderKey,
                      value: _currentValue.clamp(0.0, _maxValue > 0 ? _maxValue : 1.0),
                      min: 0.0,
                      max: _maxValue > 0 ? _maxValue : 1.0,
                      onChangeStart: (value) {
                        setState(() {
                          _draggingValue = value;
                          _dragging = true;
                        });
                        widget.controller.setInteracting(true);
                      },
                      onChanged: (value) {
                        setState(() {
                          _draggingValue = value;
                        });
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
                      },
                      // 计算总时长和当前播放位置的百分比
                      divisions: _maxValue > 0 ? _maxValue.toInt() : 1,
                      label: CommonUtils.formatDuration(Duration(
                        seconds:
                            _draggingValue?.toInt() ?? _currentValue.toInt() ?? 0,
                      )),
                    ),
                  ),
                  // 显示悬停或长按标签
                  if (_hoverValue != null && _hoverPosition != null)
                    Positioned(
                      left: _hoverPosition! - 30, // 调整标签位置
                      bottom: 40, // 标签距离滑动条的距离
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          CommonUtils.formatDuration(
                              Duration(seconds: _hoverValue!.toInt())),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// 处理鼠标悬停事件
  void _handleMouseHover(PointerHoverEvent event) {
    _handleMouseHoverUpdate(event.position);
  }

  /// 处理移动端的长按事件
  void _handleLongPress(LongPressStartDetails details) {
    _handleLongPressUpdate(details.globalPosition);
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _handleLongPressUpdate(details.globalPosition);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _hoverValue = null;
      _hoverPosition = null;
    });
  }

  void _handleLongPressUpdate(Offset globalPosition) {
    if (!isMobile) return;

    RenderBox? box = _sliderKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset localPosition = box.globalToLocal(globalPosition);
      double relative = localPosition.dx / box.size.width;
      double max = _maxValue;
      double hoverValue = (relative * max).clamp(0.0, max);
      double hoverPosition = localPosition.dx.clamp(0.0, box.size.width);

      setState(() {
        _hoverValue = hoverValue;
        _hoverPosition = hoverPosition;
      });
    }
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    // 可以在这里添加鼠标进入时的逻辑
  }

  void _handleMouseExit(PointerExitEvent event) {
    setState(() {
      _hoverValue = null;
      _hoverPosition = null;
    });
  }

  void _handleMouseHoverUpdate(Offset globalPosition) {
    RenderBox? box = _sliderKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    try {
      Offset localPosition = box.globalToLocal(globalPosition);
      double relative = localPosition.dx / box.size.width;
      double max = _maxValue;
      
      if (max <= 0) return;
      
      double hoverValue = (relative * max).clamp(0.0, max);
      double hoverPosition = localPosition.dx.clamp(0.0, box.size.width);

      setState(() {
        _hoverValue = hoverValue;
        _hoverPosition = hoverPosition;
      });
    } catch (e) {
      LogUtils.e('处理鼠标悬停失败', error: e, tag: 'CustomVideoProgressbar');
    }
  }
}

/// 自定义的滑动条轨道形状，用于实现鼠标悬停效果和显示多个缓冲区段
class CustomSliderTrackShape extends SliderTrackShape {
  final double? hoverValue;
  final double currentValue;
  final List<BufferRange> bufferRanges;
  final double maxValue;

  CustomSliderTrackShape({
    this.hoverValue,
    required this.currentValue,
    required this.bufferRanges,
    required this.maxValue,
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

    final Paint activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.white
      ..style = PaintingStyle.fill;

    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint bufferedPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

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
      Paint hoverPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;

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
