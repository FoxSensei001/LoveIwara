import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

class MessageService extends GetxService {
  final List<_QueuedMessage> _messageQueue = [];
  _QueuedMessage? _pendingSiteModeToast;
  bool _isReady = false;

  void markReady() {
    _isReady = true;
    _processQueue();
  }

  void showMessage(String message, MDToastType type) {
    if (!_isReady) {
      _messageQueue.add(_QueuedMessage(message, type));
    } else {
      _showToast(message, type);
    }
  }

  /// 展示一条固定在屏幕底部、可点击跳转的提示（例如「下载完成」引导跳转下载列表）。
  /// 点击整个提示区域即可触发 [onTap]；[actionIcon] 为 null 时不显示跳转图标
  /// （例如已身处目标页面，无需再引导跳转）。
  void showActionableMessage(
    String message,
    MDToastType type, {
    VoidCallback? onTap,
    IconData? actionIcon,
  }) {
    showToastWidget(
      MDToastWidget(
        message: message,
        type: type,
        onTap: onTap,
        rightIcon: actionIcon != null
            ? Icon(actionIcon, color: Colors.white, size: 18)
            : null,
      ),
      position: ToastPosition.bottom,
      handleTouch: onTap != null,
    );
  }

  void queueMessage(String message, MDToastType type) {
    _messageQueue.add(_QueuedMessage(message, type));
  }

  void queuePendingSiteModeToast(String message, MDToastType type) {
    _pendingSiteModeToast = _QueuedMessage(message, type);
  }

  void showPendingSiteModeToastIfAny() {
    final pendingToast = _pendingSiteModeToast;
    if (pendingToast == null) {
      return;
    }

    _pendingSiteModeToast = null;
    _showToast(pendingToast.message, pendingToast.type);
  }

  void _processQueue() {
    if (!_isReady) return;

    for (var message in _messageQueue) {
      _showToast(message.message, message.type);
    }
    _messageQueue.clear();
  }

  void _showToast(String message, MDToastType type) {
    showToastWidget(MDToastWidget(message: message, type: type));
  }
}

class _QueuedMessage {
  final String message;
  final MDToastType type;

  _QueuedMessage(this.message, this.type);
}
