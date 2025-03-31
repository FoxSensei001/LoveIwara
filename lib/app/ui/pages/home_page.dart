import 'package:flutter/material.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:get/get.dart';

/// 可刷新页面的抽象接口
abstract class HomeWidgetInterface {
  void refreshCurrent();
  
  /// 用于查找已创建但未被访问到的widget实例
  static HomeWidgetInterface? findInstance(String widgetName) {
    // 根据名称查找特定类型的实例
    switch (widgetName) {
      case 'PopularVideoListPage':
        try {
          // 尝试使用Get查找controller来访问页面
          final controller = Get.find<dynamic>(tag: 'video');
          LogUtils.d('通过controller(video)查找到PopularVideoListPage');
          return null; // 因为无法直接返回页面实例，后续通过controller刷新
        } catch (e) {
          LogUtils.e('查找PopularVideoListPage实例失败: $e');
        }
        break;
      case 'PopularGalleryListPage':
        try {
          // 尝试使用Get查找controller来访问页面
          final controller = Get.find<dynamic>(tag: 'gallery');
          LogUtils.d('通过controller(gallery)查找到PopularGalleryListPage');
          return null; // 因为无法直接返回页面实例，后续通过controller刷新
        } catch (e) {
          LogUtils.e('查找PopularGalleryListPage实例失败: $e');
        }
        break;
    }
    return null;
  }
}

/// 可刷新的 StatefulWidget 基类
mixin RefreshableMixin on Widget implements HomeWidgetInterface {
  @override
  void refreshCurrent() {
    LogUtils.d('RefreshableMixin.refreshCurrent() called on $runtimeType', 'RefreshableMixin');
  }
} 