import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../utils/common_utils.dart';
import '../../controllers/my_video_state_controller.dart';

/// 自定义的视频进度条组件
class CustomVideoProgressbar extends StatefulWidget {
  final MyVideoStateController controller;

  const CustomVideoProgressbar({super.key, required this.controller});

  @override
  State<CustomVideoProgressbar> createState() => _CustomVideoProgressbarState();
}

class _CustomVideoProgressbarState extends State<CustomVideoProgressbar> {
  // 临时值，用于存储用户拖动的滑动条值（以秒为单位）
  double? _draggingValue;
  bool _dragging = false;

  // 用于存储悬停或长按的滑动条值（以秒为单位）
  double? _hoverValue;

  // 用于存储悬停或长按的像素位置，用于定位标签
  double? _hoverPosition;

  // 拖拽相关状态
  double? _dragStartX; // 拖拽起始的 X 坐标
  double? _dragStartValue; // 拖拽起始时的进度值（秒）
  double? _trackWidth; // 进度条总宽度
  bool _hasMoved = false; // 是否已经移动（用于区分单击和拖拽）

  // Tooltip 渐隐时保持最后位置
  double? _lastTooltipX;
  double? _lastTooltipTime;
  bool _tooltipVisible = false;

  // GlobalKey 用于获取进度条的 RenderBox
  final GlobalKey _progressBarKey = GlobalKey();

  // 缓存常用的Paint对象
  final Paint _activePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final Paint _inactivePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  final Paint _bufferedPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..style = PaintingStyle.fill;

  final Paint _hoverPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..style = PaintingStyle.fill;

  final Paint _thumbPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  // 用于判断当前是否为移动端
  bool get isMobile =>
      GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isFuchsia;

  // 缓存上一次的缓冲区列表，用于比较是否需要更新
  List<BufferRange> _lastBufferRanges = [];

  // 进度条高度
  static const double _trackHeight = 4.0;
  // Cursor 半径
  static const double _thumbRadius = 6.0;
  // Cursor 覆盖区域半径（用于扩大点击区域）
  static const double _thumbOverlayRadius = 16.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _draggingValue = null;
    _hoverValue = null;
    _hoverPosition = null;
    _dragStartX = null;
    _dragStartValue = null;
    _trackWidth = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题色
    final primaryColor = Theme.of(context).colorScheme.primary;

    // 动态更新Paint对象的颜色
    _activePaint.color = primaryColor;
    _thumbPaint.color = primaryColor;

    return RepaintBoundary(
      child: Obx(() {
        // 在 Obx 内部访问响应式值，确保能够监听到变化
        final toShowCurrentPosition =
            widget.controller.toShowCurrentPosition.value;
        final totalDuration = widget.controller.totalDuration.value;
        final isHorizontalDragging = widget.controller.isHorizontalDragging.value;
        final previewPosition = widget.controller.previewPosition.value;
        // 访问 animationController.value 以确保响应式系统追踪它（虽然 AnimatedBuilder 应该能独立工作）
        final _ = widget.controller.animationController.value; // 用于触发响应式更新

        // 计算当前值：
        // 1. 如果正在拖拽进度条，使用拖拽值
        // 2. 如果正在横向拖拽，使用预览位置
        // 3. 否则使用实时值
        final currentValue = _dragging
            ? (_draggingValue ?? toShowCurrentPosition.inSeconds.toDouble())
            : (isHorizontalDragging
                ? previewPosition.inSeconds.toDouble()
                : toShowCurrentPosition.inSeconds.toDouble());
        final maxValue = totalDuration.inSeconds > 0
            ? totalDuration.inSeconds.toDouble()
            : 1.0;

        // 使用 LayoutBuilder 获取组件宽度，用于计算滑块的像素位置
        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;

            // 决定 Tooltip 显示的数据和位置
            double? tooltipX;
            double? tooltipTime;
            final isPreviewReady = widget.controller.isPreviewPlayerReady.value;

            if (_dragging) {
              // 场景 A：拖拽中 -> 强制显示在滑块上方
              // 将当前时间转换为像素位置
              final double ratio = (currentValue / maxValue).clamp(0.0, 1.0);
              tooltipX = ratio * maxWidth;
              tooltipTime = currentValue;
              
              // 更新预览播放器位置（限流）
              if (isPreviewReady) {
                widget.controller.updatePreviewSeek(Duration(seconds: currentValue.toInt()));
              }
            } else if (isHorizontalDragging) {
              // 场景 C：横向拖动播放器 -> 显示在 cursor 位置
              // 将预览位置转换为像素位置
              final double ratio = (currentValue / maxValue).clamp(0.0, 1.0);
              tooltipX = ratio * maxWidth;
              tooltipTime = currentValue;
              
              // 更新预览播放器位置（限流）
              if (isPreviewReady) {
                widget.controller.updatePreviewSeek(Duration(seconds: currentValue.toInt()));
              }
            } else if (_hoverValue != null && _hoverPosition != null) {
              // 场景 B：仅悬停 -> 显示在鼠标位置
              tooltipX = _hoverPosition;
              tooltipTime = _hoverValue;
              
              // 更新预览播放器位置（限流）
              if (isPreviewReady) {
                widget.controller.updatePreviewSeek(Duration(seconds: _hoverValue!.toInt()));
              }
            }

            // 缓存最后一次有效的位置与时间，用于淡出时“原地消失”
            if (tooltipX != null && tooltipTime != null) {
              _lastTooltipX = tooltipX;
              _lastTooltipTime = tooltipTime;
              _tooltipVisible = true;
            } else if (_lastTooltipX != null && _lastTooltipTime != null) {
              // 没有新的 tooltip，但之前有位置，则用缓存位置淡出
              tooltipX = _lastTooltipX;
              tooltipTime = _lastTooltipTime;
              _tooltipVisible = false;
            }

            return Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none, // 允许子组件溢出 Stack 边界，防止 Tooltip 被裁切
              children: [
                GestureDetector(
                  key: _progressBarKey,
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    // 记录点击位置，用于可能的单击跳转
                    _handleTapDown(details, maxValue);
                  },
                  onTap: () {
                    // 处理纯单击（没有拖拽）
                    if (_dragStartValue != null && !_dragging) {
                      widget.controller.handleSeek(
                        Duration(seconds: _dragStartValue!.toInt()),
                      );
                      _dragStartX = null;
                      _dragStartValue = null;
                    }
                  },
                  onPanStart: (details) {
                    // 拖拽开始
                    _handlePanStart(details, currentValue, maxValue);
                  },
                  onPanUpdate: (details) {
                    // 拖拽更新
                    _handlePanUpdate(details, maxValue);
                  },
                  onPanEnd: (details) async {
                    // 拖拽结束
                    await _handlePanEnd();
                  },
                  onPanCancel: () async {
                    // 拖拽取消
                    await _handlePanEnd();
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click, // 鼠标悬浮时显示手型指针
                    onHover: (event) {
                      // 鼠标悬停处理
                      _handleMouseHover(event, maxValue);
                    },
                    onExit: (_) {
                      // 鼠标离开
                      setState(() {
                        _hoverValue = null;
                        _hoverPosition = null;
                      });
                    },
                    child: Container(
                      height: _thumbOverlayRadius * 2,
                      width: maxWidth,
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: Size(maxWidth, _thumbOverlayRadius * 2),
                        painter: _ProgressBarPainter(
                          hoverValue: _hoverValue,
                          currentValue: currentValue,
                          bufferRanges: _getOptimizedBufferRanges(),
                          maxValue: maxValue,
                          activePaint: _activePaint,
                          inactivePaint: _inactivePaint,
                          bufferedPaint: _bufferedPaint,
                          hoverPaint: _hoverPaint,
                          thumbPaint: _thumbPaint,
                          trackHeight: _trackHeight,
                          thumbRadius: _thumbRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                // 统一显示 Tooltip (无论是拖拽还是悬停)，带淡入淡出效果
                if (tooltipX != null && tooltipTime != null)
                  _buildTooltip(
                    tooltipX,
                    tooltipTime,
                    visible: _tooltipVisible,
                    trackWidth: maxWidth,
                  ),
              ],
            );
          },
        );
      }),
    );
  }

  // 处理单击（记录点击位置）
  void _handleTapDown(TapDownDetails details, double maxValue) {
    // 只记录点击位置，不立即跳转
    // 如果后续没有拖拽，则在 onPanEnd 中处理为单击
    final RenderBox? renderBox =
        _progressBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final double width = renderBox.size.width;
    final double localX = details.localPosition.dx;
    final double ratio = (localX / width).clamp(0.0, 1.0);
    final double targetValue = ratio * maxValue;

    // 保存点击位置，用于后续判断是否为单击
    _dragStartX = localX;
    _dragStartValue = targetValue;
  }

  // 处理拖拽开始
  void _handlePanStart(DragStartDetails details, double currentValue, double maxValue) {
    final RenderBox? renderBox =
        _progressBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 拖拽时，从当前播放位置开始，而不是点击位置
    // 记录拖拽起始的 X 坐标（用于计算移动距离）
    final double startX = details.localPosition.dx;
    // 拖拽起始时的进度值应该是当前播放位置
    final double startValue = currentValue;

    setState(() {
      _dragStartX = startX;
      _dragStartValue = startValue;
      _trackWidth = renderBox.size.width;
      _dragging = true;
      _draggingValue = startValue;
      _hasMoved = false;
    });

    widget.controller.setInteracting(true);
    widget.controller.showSeekPreview(true);
    widget.controller.updateSeekPreview(
      Duration(seconds: startValue.toInt()),
    );
  }

  // 处理拖拽更新
  void _handlePanUpdate(DragUpdateDetails details, double maxValue) {
    if (_dragStartX == null || _dragStartValue == null || _trackWidth == null) {
      return;
    }

    // 计算移动距离
    final double deltaX = details.localPosition.dx - _dragStartX!;
    
    // 如果移动距离超过阈值（3 像素），标记为已移动
    if (deltaX.abs() > 3.0) {
      _hasMoved = true;
    }

    // 计算进度调整比例（1:1 效果）
    final double deltaRatio = deltaX / _trackWidth!;
    // 计算新进度值
    double newValue = _dragStartValue! + (deltaRatio * maxValue);
    // 限制在范围内
    newValue = newValue.clamp(0.0, maxValue);

    setState(() {
      _draggingValue = newValue;
    });

    widget.controller.updateSeekPreview(
      Duration(seconds: newValue.toInt()),
    );
  }

  // 处理拖拽结束
  Future<void> _handlePanEnd() async {
    // 如果没有移动，视为单击，直接跳转到点击位置
    if (!_hasMoved && _dragStartValue != null) {
      widget.controller.handleSeek(
        Duration(seconds: _dragStartValue!.toInt()),
      );
      setState(() {
        _dragging = false;
        _hasMoved = false;
      });
      widget.controller.setInteracting(false);
      widget.controller.showSeekPreview(false);
      _dragStartX = null;
      _dragStartValue = null;
      _trackWidth = null;
      return;
    }

    if (!_dragging || _draggingValue == null) {
      // 清理状态
      setState(() {
        _dragging = false;
        _hasMoved = false;
      });
      _dragStartX = null;
      _dragStartValue = null;
      _trackWidth = null;
      return;
    }

    setState(() {
      _dragging = false;
      _hasMoved = false;
    });

    if (isMobile) {
      await HapticFeedback.lightImpact();
    }

    widget.controller.sliderDragLoadFinished.value = false;
    widget.controller.handleSeek(
      Duration(seconds: _draggingValue!.toInt()),
    );
    widget.controller.setInteracting(false);
    widget.controller.showSeekPreview(false);

    // 清理拖拽状态
    _dragStartX = null;
    _dragStartValue = null;
    _trackWidth = null;
  }

  // 处理鼠标悬停
  void _handleMouseHover(PointerEvent event, double maxValue) {
    final RenderBox? renderBox =
        _progressBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final double width = renderBox.size.width;
    final double localX = event.localPosition.dx;
    final double ratio = (localX / width).clamp(0.0, 1.0);
    final double hoverValue = ratio * maxValue;

    setState(() {
      _hoverValue = hoverValue;
      _hoverPosition = localX;
    });
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

  // Tooltip 宽度常量
  static const double _tooltipWidth = 160.0;

  // 通用的 Tooltip 构建方法（带淡入淡出效果）
  Widget _buildTooltip(
    double xPosition,
    double timeValue, {
    bool visible = true,
    required double trackWidth,
  }) {
    // 基础高度：Thumb半径 + 间距（toolbar 展开时，tooltip 距离进度条的距离）
    const double baseBottom = _thumbOverlayRadius + 10;
    // 细进度条高度 + 期望的 tooltip 距离细进度条的间距
    // 当 toolbar 收缩时，tooltip 应该距离屏幕底部这个距离
    const double thinProgressBarOffset = 3.0 + 12.0; // 细进度条 3px + 间距 12px

    final isPreviewReady = widget.controller.isPreviewPlayerReady.value;

    // 计算 tooltip 的水平偏移量，确保不超出进度条边界
    // tooltip 宽度的一半
    const double halfTooltipWidth = _tooltipWidth / 2;
    // 默认居中偏移 -0.5
    double horizontalOffset = -0.5;

    // 左边界检查：如果 tooltip 左边会超出
    if (xPosition < halfTooltipWidth) {
      // 计算需要的偏移量，使 tooltip 左边缘对齐到左边缘（留 4px 边距）
      horizontalOffset = -(xPosition - 4) / _tooltipWidth;
      horizontalOffset = horizontalOffset.clamp(-1.0, 0.0);
    }
    // 右边界检查：如果 tooltip 右边会超出（使用进度条宽度而非屏幕宽度）
    else if (xPosition > trackWidth - halfTooltipWidth) {
      // 计算需要的偏移量，使 tooltip 右边缘对齐到右边缘（留 4px 边距）
      horizontalOffset = -1.0 + (trackWidth - xPosition - 4) / _tooltipWidth;
      horizontalOffset = horizontalOffset.clamp(-1.0, 0.0);
    }

    return AnimatedBuilder(
      animation: widget.controller.animationController,
      builder: (context, child) {
        // 获取 toolbar 的动画值：1.0 表示展开，0.0 表示收缩
        final double toolbarValue = widget.controller.animationController.value;

        // 当工具栏完全收缩时，不渲染主进度条上的预览 Tooltip
        if (toolbarValue <= 0.0) {
          return const SizedBox.shrink();
        }
        // 获取 bottomBarAnimation 的偏移量（y 值）
        final double bottomBarOffsetY = widget.controller.bottomBarAnimation.value.dy;

        // 获取屏幕高度来计算实际的滑动距离
        final double screenHeight = MediaQuery.of(context).size.height;
        // bottomBarAnimation 的 Offset(0, 1) 表示向下滑动一个屏幕高度
        // 所以实际的滑动距离 = bottomBarOffsetY * screenHeight
        final double actualSlideDistance = bottomBarOffsetY * screenHeight;

        // 计算动态的 bottom 值：
        // - 当 toolbar 展开时（toolbarValue = 1, bottomBarOffsetY = 0）：tooltip 在进度条上方 baseBottom 距离
        // - 当 toolbar 收缩时（toolbarValue = 0, bottomBarOffsetY = 1）：整个 toolbar 向下滑动
        //   此时 tooltip 应该相对于屏幕底部定位，距离底部 thinProgressBarOffset
        //
        //   由于 tooltip 的 bottom 是相对于 Stack 的，而 Stack 在 toolbar 中
        //   当 toolbar 向下滑动 actualSlideDistance 时，tooltip 也会跟着向下滑动
        //   如果 tooltip 的 bottom = thinProgressBarOffset，那么 tooltip 实际距离屏幕底部 = thinProgressBarOffset + actualSlideDistance
        //   这太远了，看不到
        //
        //   正确的计算逻辑：
        //   - 展开时：bottom = baseBottom (26)
        //   - 收缩时：tooltip 应该距离屏幕底部 thinProgressBarOffset (15)
        //     由于 toolbar 向下滑动 actualSlideDistance，tooltip 的 bottom 需要 = thinProgressBarOffset + actualSlideDistance
        //     这样当 toolbar 向下滑动后，tooltip 实际距离屏幕底部 = (thinProgressBarOffset + actualSlideDistance) - actualSlideDistance = thinProgressBarOffset
        final double dynamicBottom = toolbarValue == 1.0
            ? baseBottom  // 展开时，使用基础位置
            : thinProgressBarOffset + actualSlideDistance;  // 收缩时，需要加上滑动距离，以补偿 toolbar 的向下滑动

        return Positioned(
          left: xPosition,
          // 距离底部的位置：根据 toolbar 状态动态调整，避免被遮挡
          bottom: dynamicBottom,
          child: FractionalTranslation(
            // 根据位置动态调整水平偏移，确保 tooltip 不超出边界
            translation: Offset(horizontalOffset, 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: visible ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !visible,
                child: _buildPreviewTooltipContent(timeValue, isPreviewReady),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建预览 tooltip 内容（包含预览视频画面）
  Widget _buildPreviewTooltipContent(double timeValue, bool isPreviewReady) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 优先使用预览视频画面；如果暂不可用，则仅展示时间信息
          if (isPreviewReady && widget.controller.previewVideoController != null)
            Container(
              width: 160,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Video(
                controller: widget.controller.previewVideoController!,
                controls: null,
                fit: BoxFit.cover,
              ),
            ),
          // 时间文本
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              CommonUtils.formatDuration(Duration(seconds: timeValue.toInt())),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 自定义进度条绘制器
class _ProgressBarPainter extends CustomPainter {
  final double? hoverValue;
  final double currentValue;
  final List<BufferRange> bufferRanges;
  final double maxValue;
  final Paint activePaint;
  final Paint inactivePaint;
  final Paint bufferedPaint;
  final Paint hoverPaint;
  final Paint thumbPaint;
  final double trackHeight;
  final double thumbRadius;

  _ProgressBarPainter({
    this.hoverValue,
    required this.currentValue,
    required this.bufferRanges,
    required this.maxValue,
    required this.activePaint,
    required this.inactivePaint,
    required this.bufferedPaint,
    required this.hoverPaint,
    required this.thumbPaint,
    required this.trackHeight,
    required this.thumbRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算轨道矩形
    final double trackTop = (size.height - trackHeight) / 2;
    final Rect trackRect = Rect.fromLTWH(0, trackTop, size.width, trackHeight);

    // 计算当前播放位置的比例
    double currentRatio = (currentValue / maxValue).clamp(0.0, 1.0);
    double currentX = trackRect.left + currentRatio * trackRect.width;

    // 绘制未播放部分
    canvas.drawRect(
      Rect.fromLTRB(currentX, trackRect.top, trackRect.right, trackRect.bottom),
      inactivePaint,
    );

    // 绘制已播放部分
    canvas.drawRect(
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
      canvas.drawRect(
        Rect.fromLTRB(startX, trackRect.top, endX, trackRect.bottom),
        bufferedPaint,
      );
    }

    // 绘制 cursor（圆形滑块）
    // 确保 cursor 的 X 坐标在可绘制区域内，避免在两端被裁剪
    final double thumbCenterY = size.height / 2;
    final double thumbX = currentX.clamp(thumbRadius, size.width - thumbRadius);
    canvas.drawCircle(
      Offset(thumbX, thumbCenterY),
      thumbRadius,
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) {
    return oldDelegate.hoverValue != hoverValue ||
        oldDelegate.currentValue != currentValue ||
        oldDelegate.bufferRanges.length != bufferRanges.length ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.activePaint.color != activePaint.color ||
        oldDelegate.thumbPaint.color != thumbPaint.color;
  }
}

/// 自定义的滑动条轨道形状，用于实现鼠标悬停效果和显示多个缓冲区段
/// 注意：此类已不再使用，保留仅用于参考
@Deprecated('已替换为 _ProgressBarPainter')
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
