import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

class MessageService extends GetxService {
  final List<_QueuedMessage> _messageQueue = [];
  _QueuedMessage? _pendingSiteModeToast;
  bool _isReady = false;

  void markReady() {
    _isReady = true;
    _processQueue();
  }

  void showMessage(String message, AppToastType type) {
    if (!_isReady) {
      _messageQueue.add(_QueuedMessage(message, type));
    } else {
      showAppToast(message, type: type);
    }
  }

  /// 展示一条固定在屏幕底部、可点击跳转的提示（例如「下载完成」引导跳转下载列表）。
  /// 点击整个提示区域即可触发 [onTap]；[actionIcon] 为 null 时不显示跳转图标
  /// （例如已身处目标页面，无需再引导跳转）。
  void showActionableMessage(
    String message,
    AppToastType type, {
    VoidCallback? onTap,
    IconData? actionIcon,
  }) {
    showAppToast(
      message,
      type: type,
      position: AppToastPosition.bottom,
      actionIcon: actionIcon,
      onAction: onTap,
    );
  }

  void queueMessage(String message, AppToastType type) {
    _messageQueue.add(_QueuedMessage(message, type));
  }

  void queuePendingSiteModeToast(String message, AppToastType type) {
    _pendingSiteModeToast = _QueuedMessage(message, type);
  }

  void showPendingSiteModeToastIfAny() {
    final pendingToast = _pendingSiteModeToast;
    if (pendingToast == null) {
      return;
    }

    _pendingSiteModeToast = null;
    showAppToast(pendingToast.message, type: pendingToast.type);
  }

  /// 启动前攒下的消息在路由就绪后一次性放出来。
  ///
  /// 以前这里要按 2.6 秒间隔一条条错峰——那时同一时刻只能存在一条 toast，一次
  /// 性发出去的结果是用户只看得到最后一条。现在提示会自己堆叠（见
  /// [appToastMaxVisible]），不需要再排队等。
  void _processQueue() {
    if (!_isReady || _messageQueue.isEmpty) return;

    final pending = List<_QueuedMessage>.from(_messageQueue);
    _messageQueue.clear();
    for (final message in pending) {
      showAppToast(message.message, type: message.type);
    }
  }
}

class _QueuedMessage {
  final String message;
  final AppToastType type;

  _QueuedMessage(this.message, this.type);
}
