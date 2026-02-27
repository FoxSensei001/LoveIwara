import 'dart:io';
import 'package:flutter/gestures.dart'
    show PointerSignalEvent, PointerScrollEvent;
import 'package:flutter/services.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:photo_view/photo_view.dart';

/// 图库控制逻辑类，处理键盘、音量键等控制
class GalleryControls {
  static const platform = MethodChannel('i_iwara/volume_key');

  final List<PhotoViewController> controllers;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(bool fine)? onZoomIn;
  final Function(bool fine)? onZoomOut;

  bool isCtrlPressed = false;
  int currentIndex = 0;

  final double _zoomInterval = 0.2;
  final double _fineZoomInterval = 0.1;

  GalleryControls({
    required this.controllers,
    this.onNext,
    this.onPrevious,
    this.onZoomIn,
    this.onZoomOut,
  });

  /// 初始化音量键监听（仅移动平台）
  Future<void> initVolumeKeyListener() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // 设置方法调用处理器
      platform.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onVolumeKeyUp':
            onPrevious?.call();
            break;
          case 'onVolumeKeyDown':
            onNext?.call();
            break;
        }
        return Future<void>.value();
      });

      // 启用音量键监听
      await platform.invokeMethod('enableVolumeKeyListener');
    } catch (e) {
      LogUtils.e('音量键监听初始化失败: $e', tag: 'GalleryControls');
      return Future<void>.value();
    }
    return Future<void>.value();
  }

  /// 禁用音量键监听
  void disableVolumeKeyListener() {
    if (Platform.isAndroid || Platform.isIOS) {
      platform.invokeMethod('disableVolumeKeyListener');
    }
  }

  /// 处理键盘按键事件
  ///
  /// 返回值表示本次事件是否触发了「实际动作」（翻页/缩放/重置等），便于调用方决定是否刷新 UI。
  bool handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.controlLeft ||
            event.logicalKey == LogicalKeyboardKey.controlRight)) {
      isCtrlPressed = true;
      return false;
    }
    if (event is KeyUpEvent &&
        (event.logicalKey == LogicalKeyboardKey.controlLeft ||
            event.logicalKey == LogicalKeyboardKey.controlRight)) {
      isCtrlPressed = false;
      return false;
    }

    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.pageDown:
        onNext?.call();
        return true;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.pageUp:
        onPrevious?.call();
        return true;
      case LogicalKeyboardKey.arrowUp:
        zoomIn();
        return true;
      case LogicalKeyboardKey.arrowDown:
        zoomOut();
        return true;
      case LogicalKeyboardKey.equal:
      case LogicalKeyboardKey.numpadAdd:
        zoomIn();
        return true;
      case LogicalKeyboardKey.minus:
      case LogicalKeyboardKey.numpadSubtract:
        zoomOut();
        return true;
      case LogicalKeyboardKey.digit0:
      case LogicalKeyboardKey.numpad0:
        resetZoom();
        return true;
    }

    return false;
  }

  /// 处理鼠标滚轮事件
  void handlePointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (isCtrlPressed) {
        if (pointerSignal.scrollDelta.dy > 0) {
          zoomOut(fine: true);
        } else {
          zoomIn(fine: true);
        }
      } else {
        if (pointerSignal.scrollDelta.dy > 0) {
          onNext?.call();
        } else {
          onPrevious?.call();
        }
      }
    }
  }

  /// 放大
  void zoomIn({bool fine = false}) {
    if (currentIndex >= controllers.length) return;

    final scale = controllers[currentIndex].scale;
    if (scale != null) {
      controllers[currentIndex].scale =
          scale + (fine ? _fineZoomInterval : _zoomInterval);
    }
    onZoomIn?.call(fine);
  }

  /// 缩小
  void zoomOut({bool fine = false}) {
    if (currentIndex >= controllers.length) return;

    final scale = controllers[currentIndex].scale;
    if (scale != null && scale > 0.5) {
      controllers[currentIndex].scale =
          scale - (fine ? _fineZoomInterval : _zoomInterval);
    }
    onZoomOut?.call(fine);
  }

  /// 重置缩放与位置（Telegram Desktop 常见 0 键行为）
  void resetZoom() {
    if (currentIndex >= controllers.length) return;
    controllers[currentIndex]
      ..scale = 1.0
      ..position = Offset.zero;
  }

  /// 双击缩放处理
  void handleDoubleTap(int index) {
    if (index >= controllers.length) return;

    final scale = controllers[index].scale;
    if (scale != null) {
      if (scale > 1.0) {
        // 如果当前已放大，则缩小到原始大小
        controllers[index].scale = 1.0;
      } else {
        // 如果当前是原始大小，则放大到2倍
        controllers[index].scale = 2.0;
      }
    }
  }

  /// 更新当前索引
  void updateCurrentIndex(int index) {
    currentIndex = index;
  }
}
