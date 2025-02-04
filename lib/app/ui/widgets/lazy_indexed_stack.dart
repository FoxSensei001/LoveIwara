import 'package:flutter/material.dart';

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
    final child = widget.itemBuilders[index](context);
    _cache[index] = child;
    return child;
  }

  /// 当系统内存紧张时，释放非当前显示页面的缓存
  void releaseNonCurrent() {
    for (int i = 0; i < _cache.length; i++) {
      if (i != widget.index) {
        _cache[i] = null;
      }
    }
    if (mounted) {
      setState(() {}); // 重建
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List.generate(widget.itemBuilders.length, (index) {
      // 当前页面始终调用构建器，并返回缓存结果
      if (index == widget.index) {
        return _buildChild(index);
      }
      // 如果缓存中有值则返回，没有则返回空容器
      return _cache[index] ?? const SizedBox.shrink();
    });
    return IndexedStack(
      index: widget.index,
      children: children,
    );
  }
} 