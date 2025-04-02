import 'package:flutter/material.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import '../pages/home_page.dart';

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
      // 获取当前显示的页面
      final currentWidget = _cache[widget.index];
      if (currentWidget is HomeWidgetInterface) {
        // 刷新当前页面
        (currentWidget as HomeWidgetInterface).refreshCurrent();
      }
    } else {
      // 如果索引超出范围，打印日志
      LogUtils.w('LazyIndexedStack.refreshCurrent: 索引超出范围 ${widget.index}');
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