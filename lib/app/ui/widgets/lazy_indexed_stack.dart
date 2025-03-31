import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import 'package:get/get.dart';

/// LazyIndexedStack：实现懒加载并缓存页面。
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<WidgetBuilder> itemBuilders;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.itemBuilders,
  });

  @override
  LazyIndexedStackState createState() => LazyIndexedStackState();
}

class LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<Widget?> _cache;
  bool _isReleasing = false; // 防止重复释放

  @override
  void initState() {
    super.initState();
    _cache = List<Widget?>.filled(widget.itemBuilders.length, null, growable: false);
  }

  /// 获取指定索引对应的子页面，若尚未构建，则进行构建并缓存
  Widget _buildChild(int index) {
    if (_cache[index] != null) {
      return _cache[index]!;
    }
    try {
      final child = widget.itemBuilders[index](context);
      _cache[index] = child;
      return child;
    } catch (e, stackTrace) {
      // 如果构建失败，打印日志并返回错误显示的Widget
      debugPrint("Error building widget at index $index: $e\n$stackTrace");
      return Container(
        color: Colors.red,
        child: const Center(child: Text('Error building widget')),
      );
    }
  }

  /// 当系统内存紧张时，释放非当前显示页面的缓存
  void releaseNonCurrent() {
    if (_isReleasing) return;
    _isReleasing = true;
    for (int i = 0; i < _cache.length; i++) {
      if (i != widget.index) {
        _cache[i] = null;
      }
    }
    // 延迟调用 setState，避免阻塞 UI 线程
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
      _isReleasing = false;
    });
  }

  /// 刷新当前显示的页面
  void refreshCurrent() {
    if (widget.index >= 0 && widget.index < _cache.length) {
      final currentWidget = _cache[widget.index];
      debugPrint('LazyIndexedStack.refreshCurrent: currentWidget=${currentWidget.runtimeType}');
      if (currentWidget is HomeWidgetInterface) {
        debugPrint('LazyIndexedStack.refreshCurrent: currentWidget is HomeWidgetInterface, calling refreshCurrent()');
        (currentWidget as HomeWidgetInterface).refreshCurrent();
      } else {
        debugPrint('LazyIndexedStack.refreshCurrent: currentWidget is NOT HomeWidgetInterface');
        
        // 尝试查找特定类型的接口实例
        String widgetTypeName = '';
        String controllerTag = '';
        if (widget.index == 0) {
          widgetTypeName = 'PopularVideoListPage';
          controllerTag = 'video';
        }
        else if (widget.index == 1) {
          widgetTypeName = 'PopularGalleryListPage';
          controllerTag = 'gallery';
        }
        else if (widget.index == 2) {
          widgetTypeName = 'SubscriptionsPage';
          controllerTag = 'subscriptions';
        }
        else if (widget.index == 3) {
          widgetTypeName = 'ForumPage';
          controllerTag = 'forum';
        }
        
        if (widgetTypeName.isNotEmpty) {
          debugPrint('LazyIndexedStack.refreshCurrent: 尝试查找 $widgetTypeName 实例');
          final instance = HomeWidgetInterface.findInstance(widgetTypeName);
          if (instance != null) {
            debugPrint('LazyIndexedStack.refreshCurrent: 找到 $widgetTypeName 实例，调用refreshCurrent()');
            instance.refreshCurrent();
          } else {
            debugPrint('LazyIndexedStack.refreshCurrent: 未找到 $widgetTypeName 实例，尝试通过controller刷新');
            try {
              final controller = Get.find<dynamic>(tag: controllerTag);
              if (controllerTag == 'video' || controllerTag == 'gallery') {
                final popularController = Get.find<dynamic>(tag: controllerTag);
                debugPrint('LazyIndexedStack.refreshCurrent: 找到controller: ${popularController.runtimeType}');
                if (popularController != null) {
                  popularController.refreshPageUI();
                  debugPrint('LazyIndexedStack.refreshCurrent: 已通过controller刷新页面');
                }
              }
            } catch (e) {
              debugPrint('LazyIndexedStack.refreshCurrent: 通过controller刷新失败: $e');
            }
          }
        }
      }
    } else {
      debugPrint('LazyIndexedStack.refreshCurrent: Invalid index ${widget.index} or empty cache');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List.generate(widget.itemBuilders.length, (index) {
      if (index == widget.index) {
        return _buildChild(index);
      }
      // 当缓存不存在时返回空容器
      return _cache[index] ?? const SizedBox.shrink();
    });
    return IndexedStack(
      index: widget.index,
      children: children,
    );
  }
} 