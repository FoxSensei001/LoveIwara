import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// NavigatorObserver that tracks the count of PopupRoute overlays (dialogs, bottom sheets).
/// Replaces Get.isDialogOpen / Get.isBottomSheetOpen.
class OverlayTracker extends NavigatorObserver {
  OverlayTracker._(this.scope);

  /// One NavigatorObserver instance can only be attached to a single Navigator.
  /// We use two observers (root + shell) but share a global counter.
  static final OverlayTracker root = OverlayTracker._('root');
  static final OverlayTracker shell = OverlayTracker._('shell');

  /// Backward-compatible accessor for read-only usage.
  /// Do NOT attach [instance] to another Navigator.
  static OverlayTracker get instance => root;

  final String scope;

  static final RxInt _overlayCount = 0.obs;

  /// Whether any overlay (dialog / bottom sheet) is currently visible.
  bool get hasOverlay => _overlayCount.value > 0;

  /// Reactive overlay count – can be used inside Obx.
  int get overlayCount => _overlayCount.value;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PopupRoute) {
      _overlayCount.value++;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is PopupRoute && _overlayCount.value > 0) {
      _overlayCount.value--;
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (route is PopupRoute && _overlayCount.value > 0) {
      _overlayCount.value--;
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute is PopupRoute && _overlayCount.value > 0) {
      _overlayCount.value--;
    }
    if (newRoute is PopupRoute) {
      _overlayCount.value++;
    }
  }

  /// Force-reset overlay count (e.g. after navigation stack reset).
  void reset() {
    _overlayCount.value = 0;
  }
}
