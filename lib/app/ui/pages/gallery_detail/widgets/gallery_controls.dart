import 'dart:io';
import 'package:flutter/gestures.dart'
    show PointerSignalEvent, PointerScrollEvent;
import 'package:flutter/services.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
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
  final VoidCallback? onResetZoom;

  /// 下面三条只在**当前这一页是视频**时才有事可做，所以返回值是「这一下有没有
  /// 真的做成」：翻到一张静态图上按空格，键仍然被作用域吃掉（否则方向键那套会
  /// 被 `WidgetsApp` 翻译成焦点移动），但不该假装播放了什么。
  final bool Function()? onTogglePlayPause;

  /// `forward` 为真是快进，否则快退。
  final bool Function(bool forward)? onSeek;

  final bool Function()? onToggleMute;

  int currentIndex = 0;

  final double _zoomInterval = 0.2;
  final double _fineZoomInterval = 0.1;

  GalleryControls({
    required this.controllers,
    this.onNext,
    this.onPrevious,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetZoom,
    this.onTogglePlayPause,
    this.onSeek,
    this.onToggleMute,
  });

  /// 统一快捷键派发
  bool dispatch(ShortcutAction action) {
    switch (action) {
      case ShortcutAction.galleryNext:
        onNext?.call();
        return true;
      case ShortcutAction.galleryPrevious:
        onPrevious?.call();
        return true;
      case ShortcutAction.galleryZoomIn:
        zoomIn();
        return true;
      case ShortcutAction.galleryZoomOut:
        zoomOut();
        return true;
      case ShortcutAction.galleryResetZoom:
        resetZoom();
        return true;
      case ShortcutAction.galleryPlayPause:
        return onTogglePlayPause?.call() ?? false;
      case ShortcutAction.gallerySeekForward:
        return onSeek?.call(true) ?? false;
      case ShortcutAction.gallerySeekBackward:
        return onSeek?.call(false) ?? false;
      case ShortcutAction.galleryToggleMute:
        return onToggleMute?.call() ?? false;
      default:
        return false;
    }
  }

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

  /// 处理鼠标滚轮事件。
  ///
  /// Ctrl 状态**实时问硬件**，不自己维护。此前这里读的是一个由
  /// `@Deprecated` 且全项目无人调用的 `handleKeyPress` 负责写入的字段，
  /// 于是它恒为 false —— 按住 Ctrl 滚滚轮一直在翻页而不是缩放。
  /// 自己跟踪修饰键状态就是这个 bug 本身，`KeyChord._modifiersMatch()`
  /// 早就是直接读 [HardwareKeyboard] 的，这里与之保持一致。
  void handlePointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (HardwareKeyboard.instance.isControlPressed) {
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
    onResetZoom?.call();
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
