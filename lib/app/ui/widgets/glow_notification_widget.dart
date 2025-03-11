import 'package:flutter/material.dart';

/// 统一处理滚动边缘效果的组件
/// 可用于任何滚动视图，防止出现过度滚动时的光晕效果
class GlowNotificationWidget extends StatelessWidget {
  final Widget child;
  final bool showGlowLeading;
  final ScrollController? scrollController;
  
  /// 添加滚动位置缓存键，用于在不同模式间恢复滚动位置
  final String? cacheKey;
  
  /// 添加滚动位置记录回调，方便外部保存滚动位置
  final Function(double position)? onScrollPositionChanged;

  const GlowNotificationWidget({
    super.key,
    required this.child,
    this.showGlowLeading = true,
    this.scrollController,
    this.cacheKey,
    this.onScrollPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 添加滚动监听器，用于保存滚动位置
    if (scrollController != null && onScrollPositionChanged != null) {
      // 防止重复添加监听器
      scrollController!.removeListener(_recordScrollPosition);
      scrollController!.addListener(_recordScrollPosition);
    }
    
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: child,
    );
  }
  
  // 记录滚动位置
  void _recordScrollPosition() {
    if (scrollController != null && 
        scrollController!.hasClients && 
        onScrollPositionChanged != null) {
      onScrollPositionChanged!(scrollController!.position.pixels);
    }
  }
} 