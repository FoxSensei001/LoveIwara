import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

class VideoPlayerSkeletonWidget extends StatefulWidget {
  final MyVideoStateController controller;

  const VideoPlayerSkeletonWidget({super.key, required this.controller});

  @override
  State<VideoPlayerSkeletonWidget> createState() => _VideoPlayerSkeletonWidgetState();
}

class _VideoPlayerSkeletonWidgetState extends State<VideoPlayerSkeletonWidget> {
  final ConfigService _configService = Get.find();
  
  // 添加缓存的模糊背景
  String? _lastThumbnailUrl;
  Size? _lastSize;
  Widget? _sizedBlurredBackground;

  String _getLoadingMessage(BuildContext context) {
    switch (widget.controller.pageLoadingState.value) {
      case VideoDetailPageLoadingState.loadingVideoInfo:
        // return "正在获取视频信息...";
        return slang.t.videoDetail.skeleton.fetchingVideoInfo;
      case VideoDetailPageLoadingState.loadingVideoSource:
        // return "正在获取播放地址...";
        return slang.t.videoDetail.skeleton.fetchingVideoSources;
      case VideoDetailPageLoadingState.applyingSolution:
        // return "正在应用此分辨率...";
        return slang.t.videoDetail.skeleton.applyingSolution;
      case VideoDetailPageLoadingState.addingListeners:
        // return "正在添加监听器...";
        return slang.t.videoDetail.skeleton.addingListeners;
      case VideoDetailPageLoadingState.successFecthVideoDurationInfo:
        // return "成功获取视频资源，开始加载视频...";
        return slang.t.videoDetail.skeleton.successFecthVideoDurationInfo;
      case VideoDetailPageLoadingState.successFecthVideoHeightInfo:
        // return "加载完成";
        return slang.t.videoDetail.skeleton.successFecthVideoHeightInfo;
      case VideoDetailPageLoadingState.playerError:
        return widget.controller.videoErrorMessage.value ?? slang.t.videoDetail.skeleton.loadingVideo;
      case VideoDetailPageLoadingState.idle:
        // 如果是站外视频，不显示加载消息
        if (widget.controller.videoInfo.value?.isExternalVideo == true) {
          return "";
        }
        if (!widget.controller.videoPlayerReady.value) {
          return slang.t.videoDetail.skeleton.loadingVideo;
        }
        return "";
      default:
        return "";
    }
  }

  // 截取错误信息的前50个字符
  String _getTruncatedErrorMessage(String message) {
    if (message.length <= 50) {
      return message;
    }
    return '${message.substring(0, 50)}...';
  }

  // 显示错误详情底部弹窗
  void _showErrorDetailSheet(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: bottomPadding + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  slang.t.common.detail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.controller.videoSourceErrorMessage.value!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.controller.fetchVideoSource();
                },
                icon: const Icon(Icons.refresh),
                label: Text(slang.t.common.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 优化模糊背景创建方法
  void _updateBlurredBackground(String? thumbnailUrl, Size size) async {
    // 如果尺寸和URL都没变，不需要更新
    if (_lastSize == size && _lastThumbnailUrl == thumbnailUrl) {
      return;
    }

    _lastSize = size;
    _lastThumbnailUrl = thumbnailUrl;

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      _sizedBlurredBackground = Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
      return;
    }

    try {
      // 1. 首先加载原始图片
      final NetworkImage networkImage = NetworkImage(thumbnailUrl);
      final ImageStream stream = networkImage.resolve(ImageConfiguration());
      final Completer<ui.Image> completer = Completer<ui.Image>();
      
      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }));

      final ui.Image originalImage = await completer.future;

      // 2. 计算适当的绘制尺寸以保持宽高比
      final double imageAspectRatio = originalImage.width / originalImage.height;
      final double screenAspectRatio = size.width / size.height;
      
      double targetWidth = size.width;
      double targetHeight = size.height;
      double offsetX = 0;
      double offsetY = 0;

      if (imageAspectRatio > screenAspectRatio) {
        // 图片比屏幕更宽，以高度为基准
        targetWidth = size.height * imageAspectRatio;
        offsetX = -(targetWidth - size.width) / 2;
      } else {
        // 图片比屏幕更高，以宽度为基准
        targetHeight = size.width / imageAspectRatio;
        offsetY = -(targetHeight - size.height) / 2;
      }

      // 3. 创建一个自定义画布，使用目标尺寸
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // 4. 绘制图片并应用模糊效果
      final paint = Paint()
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20);
      
      // 使用计算后的偏移量和尺寸绘制图片
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
        Rect.fromLTWH(offsetX, offsetY, targetWidth, targetHeight),
        paint,
      );
      
      // 5. 将模糊后的图片转换为图像
      final blurredImage = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
      );
      
      // 6. 转换为字节数据
      final byteData = await blurredImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // 7. 创建新的缓存Widget
      if (mounted) {
        setState(() {
          _sizedBlurredBackground = Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.memory(
                    buffer,
                    fit: BoxFit.cover,
                    width: size.width,
                    height: size.height,
                  ),
                ),
              ),
            ],
          );
        });
      }

    } catch (e) {
      LogUtils.e('创建模糊背景失败: $e', tag: 'VideoPlayerSkeletonWidget');
      _sizedBlurredBackground = Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
    }
  }

  // 创建模糊背景方法
  Widget _createBlurredBackground(String? thumbnailUrl, Size size) {
    // 如果缓存不存在，触发异步更新
    if (_sizedBlurredBackground == null || 
        _lastSize != size || 
        _lastThumbnailUrl != thumbnailUrl) {
      _updateBlurredBackground(thumbnailUrl, size);
      
      // 返回一个占位的黑色背景
      return Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
    }
    
    // 返回缓存的模糊背景
    return _sizedBlurredBackground!;
  }

  @override
  Widget build(BuildContext context) {
    // 获取安全区域顶部padding，与my_video_screen.dart保持一致
    final double paddingTop = MediaQuery.paddingOf(context).top;
    final double paddingBottom = MediaQuery.paddingOf(context).bottom;
    
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // 剧院模式背景
          Obx(() {
            final isTheaterMode = _configService[ConfigKey.THEATER_MODE_KEY] as bool;
            if (!isTheaterMode) {
              return const SizedBox.shrink();
            }

            // 使用 LayoutBuilder 获取精确尺寸
            return LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final thumbnailUrl = widget.controller.videoInfo.value?.thumbnailUrl;
                return _createBlurredBackground(thumbnailUrl, size);
              },
            );
          }),
          // 为中心内容添加顶部padding以适配安全区域
          Positioned.fill(
            top: paddingTop,
            bottom: paddingBottom,
            child: Center(
              child: Obx(() {
                if (widget.controller.videoSourceErrorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTruncatedErrorMessage(widget.controller.videoSourceErrorMessage.value!),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showErrorDetailSheet(context),
                                      icon: const Icon(Icons.info_outline, size: 16),
                                      label: Text(slang.t.common.detail),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => widget.controller.fetchVideoSource(),
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: Text(slang.t.common.retry),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getLoadingMessage(context),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  );
                }
              }),
            ),
          ),
          // 返回按钮保持在安全区域内
          Positioned(
            top: paddingTop,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}