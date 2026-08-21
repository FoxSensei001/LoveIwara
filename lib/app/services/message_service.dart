import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';

class MessageService extends GetxService {
  final List<_QueuedMessage> _messageQueue = [];
  _QueuedMessage? _pendingSiteModeToast;
  bool _isReady = false;

  /// 队列里的消息一条条放，不要一次性全弹。
  ///
  /// 同一时刻只保留一条 toast（见 [showGlassToast]），一次性 for 循环发出去
  /// 的结果是用户只看得到最后一条。
  static const Duration _queueGap = Duration(milliseconds: 2600);

  void markReady() {
    _isReady = true;
    _processQueue();
  }

  void showMessage(String message, GlassToastType type) {
    if (!_isReady) {
      _messageQueue.add(_QueuedMessage(message, type));
    } else {
      showGlassToast(message, type: type);
    }
  }

  /// 展示一条固定在屏幕底部、可点击跳转的提示（例如「下载完成」引导跳转下载列表）。
  /// 点击整个提示区域即可触发 [onTap]；[actionIcon] 为 null 时不显示跳转图标
  /// （例如已身处目标页面，无需再引导跳转）。
  void showActionableMessage(
    String message,
    GlassToastType type, {
    VoidCallback? onTap,
    IconData? actionIcon,
  }) {
    showGlassToast(
      message,
      type: type,
      position: GlassToastPosition.bottom,
      actionIcon: actionIcon,
      onAction: onTap,
    );
  }

  void queueMessage(String message, GlassToastType type) {
    _messageQueue.add(_QueuedMessage(message, type));
  }

  void queuePendingSiteModeToast(String message, GlassToastType type) {
    _pendingSiteModeToast = _QueuedMessage(message, type);
  }

  void showPendingSiteModeToastIfAny() {
    final pendingToast = _pendingSiteModeToast;
    if (pendingToast == null) {
      return;
    }

    _pendingSiteModeToast = null;
    showGlassToast(pendingToast.message, type: pendingToast.type);
  }

  void _processQueue() {
    if (!_isReady || _messageQueue.isEmpty) return;

    final pending = List<_QueuedMessage>.from(_messageQueue);
    _messageQueue.clear();
    for (var i = 0; i < pending.length; i++) {
      final message = pending[i];
      if (i == 0) {
        showGlassToast(message.message, type: message.type);
        continue;
      }
      Timer(_queueGap * i, () {
        showGlassToast(message.message, type: message.type);
      });
    }
  }
}

class _QueuedMessage {
  final String message;
  final GlassToastType type;

  _QueuedMessage(this.message, this.type);
}
