import 'dart:ui';

/// 布局计算结果
class LayoutResult {
  final bool isWideScreen;
  final Size renderVideoSize;
  final double aspectRatio;
  final Size screenSize;
  final double paddingTop;

  const LayoutResult({
    required this.isWideScreen,
    required this.renderVideoSize,
    required this.aspectRatio,
    required this.screenSize,
    required this.paddingTop,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayoutResult &&
          other.isWideScreen == isWideScreen &&
          other.renderVideoSize == renderVideoSize &&
          other.aspectRatio == aspectRatio &&
          other.screenSize == screenSize &&
          other.paddingTop == paddingTop);

  @override
  int get hashCode =>
      isWideScreen.hashCode ^
      renderVideoSize.hashCode ^
      aspectRatio.hashCode ^
      screenSize.hashCode ^
      paddingTop.hashCode;

  @override
  String toString() {
    return 'LayoutResult(isWideScreen: $isWideScreen, renderVideoSize: $renderVideoSize, aspectRatio: $aspectRatio, screenSize: $screenSize, paddingTop: $paddingTop)';
  }
}

/// 图库滚动区域高度计算结果
class GalleryScrollerHeightResult {
  final double maxHeight;
  final bool isMobile;
  final bool isTablet;
  final Size screenSize;

  const GalleryScrollerHeightResult({
    required this.maxHeight,
    required this.isMobile,
    required this.isTablet,
    required this.screenSize,
  });

  @override
  String toString() {
    return 'GalleryScrollerHeightResult(maxHeight: $maxHeight, isMobile: $isMobile, isTablet: $isTablet, screenSize: $screenSize)';
  }
}

/// 布局计算器，提供缓存功能避免重复计算
class LayoutCalculator {
  // 缓存相关变量
  Size? _lastScreenSize;
  double? _lastAspectRatio;
  double? _lastPaddingTop;
  LayoutResult? _cachedResult;

  // 图库高度计算缓存
  Size? _lastGalleryScreenSize;
  double? _lastGalleryPaddingTop;
  GalleryScrollerHeightResult? _cachedGalleryResult;

  // 侧边栏最小宽度常量
  static const double sideColumnMinWidth = 400.0;

  // 图片滚动区域高度计算常量
  static const double minImageScrollerHeight = 200.0; // 最小高度
  static const double maxImageScrollerHeight = 600.0; // 最大高度
  static const double mobileHeightRatio = 0.35; // 手机端高度比例
  static const double tabletHeightRatio = 0.45; // 平板端高度比例
  static const double desktopHeightRatio = 0.55; // 桌面端高度比例
  
  // 设备类型判断阈值
  static const double mobileMaxWidth = 600.0; // 手机最大宽度
  static const double tabletMaxWidth = 1024.0; // 平板最大宽度

  /// 计算图库图片滚动区域的最大高度
  GalleryScrollerHeightResult calculateGalleryScrollerHeight({
    required Size screenSize,
    required double paddingTop,
  }) {
    // 检查是否需要重新计算
    if (_shouldRecalculateGallery(screenSize, paddingTop)) {
      _cachedGalleryResult = _performGalleryCalculation(screenSize, paddingTop);
      _lastGalleryScreenSize = screenSize;
      _lastGalleryPaddingTop = paddingTop;
    }
    
    return _cachedGalleryResult!;
  }

  /// 判断是否需要重新计算图库布局
  bool _shouldRecalculateGallery(Size screenSize, double paddingTop) {
    return _lastGalleryScreenSize != screenSize ||
        _lastGalleryPaddingTop != paddingTop ||
        _cachedGalleryResult == null;
  }

  /// 执行图库高度计算
  GalleryScrollerHeightResult _performGalleryCalculation(Size screenSize, double paddingTop) {
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // 完全基于屏幕宽度判断设备类型，不依赖平台检测
    final isMobile = screenWidth <= mobileMaxWidth;
    final isTablet = screenWidth > mobileMaxWidth && screenWidth <= tabletMaxWidth;
    
    // 根据屏幕宽度选择高度比例
    double heightRatio;
    if (isMobile) {
      heightRatio = mobileHeightRatio;
    } else if (isTablet) {
      heightRatio = tabletHeightRatio;
    } else {
      heightRatio = desktopHeightRatio;
    }
    
    // 计算基础高度
    double baseHeight = screenHeight * heightRatio;
    
    // 在窄屏设备上，考虑状态栏和底部安全区域的影响
    if (isMobile) {
      // 减去状态栏高度的影响
      baseHeight = (screenHeight - paddingTop) * heightRatio;
      
      // 如果屏幕很高（长屏设备），适当减少比例
      final aspectRatio = screenHeight / screenWidth;
      if (aspectRatio > 2.0) {
        baseHeight *= 0.85; // 长屏设备进一步减少高度
      }
    }
    
    // 应用最小和最大高度限制
    final maxHeight = baseHeight.clamp(minImageScrollerHeight, maxImageScrollerHeight);
    
    return GalleryScrollerHeightResult(
      maxHeight: maxHeight,
      isMobile: isMobile,
      isTablet: isTablet,
      screenSize: screenSize,
    );
  }

  /// 计算布局，优先使用缓存
  LayoutResult calculateLayout({
    required Size screenSize,
    required double aspectRatio,
    required double paddingTop,
  }) {
    // 检查是否需要重新计算
    if (_shouldRecalculate(screenSize, aspectRatio, paddingTop)) {
      _cachedResult = _performCalculation(screenSize, aspectRatio, paddingTop);
      _lastScreenSize = screenSize;
      _lastAspectRatio = aspectRatio;
      _lastPaddingTop = paddingTop;
    }
    
    return _cachedResult!;
  }

  /// 判断是否需要重新计算
  bool _shouldRecalculate(Size screenSize, double aspectRatio, double paddingTop) {
    return _lastScreenSize != screenSize ||
        _lastAspectRatio != aspectRatio ||
        _lastPaddingTop != paddingTop ||
        _cachedResult == null;
  }

  /// 执行实际的布局计算
  LayoutResult _performCalculation(Size screenSize, double aspectRatio, double paddingTop) {
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 计算是否使用宽屏布局
    final isWideScreen = _shouldUseWideScreenLayout(screenHeight, screenWidth, aspectRatio);
    
    // 计算视频列的大小
    final renderVideoSize = _calcVideoColumnWidthAndHeight(
      screenWidth,
      screenHeight,
      aspectRatio,
      paddingTop,
    );

    return LayoutResult(
      isWideScreen: isWideScreen,
      renderVideoSize: renderVideoSize,
      aspectRatio: aspectRatio,
      screenSize: screenSize,
      paddingTop: paddingTop,
    );
  }

  /// 计算是否需要分两列显示
  bool _shouldUseWideScreenLayout(double screenHeight, double screenWidth, double videoRatio) {
    // 使用有效的视频比例，如果比例小于1，则使用1.7
    final effectiveVideoRatio = videoRatio < 1 ? 1.7 : videoRatio;
    // 视频的高度
    final videoHeight = screenWidth / effectiveVideoRatio;
    // 如果视频高度超过屏幕高度的70%，并且屏幕宽度足够
    return videoHeight > screenHeight * 0.7;
  }

  /// 计算视频列的宽度和高度
  Size _calcVideoColumnWidthAndHeight(
    double screenWidth,
    double screenHeight,
    double videoRatio,
    double paddingTop,
  ) {
    // 使用有效的视频比例，如果比例小于1，则使用1.7
    final effectiveVideoRatio = videoRatio < 1 ? 1.7 : videoRatio;
    
    // 先获取70%屏幕高度时的视频宽度
    double videoWidth = (screenHeight * 0.7) * effectiveVideoRatio;
    
    // 如果视频宽度加上侧边栏宽度小于屏幕宽度，就使用这个宽度
    double renderVideoWidth;
    double renderVideoHeight;
    
    if (videoWidth + sideColumnMinWidth < screenWidth) {
      renderVideoWidth = videoWidth;
      renderVideoHeight = renderVideoWidth / effectiveVideoRatio + paddingTop;
    } else {
      renderVideoWidth = screenWidth - sideColumnMinWidth;
      renderVideoHeight = renderVideoWidth / effectiveVideoRatio + paddingTop;
    }

    return Size(renderVideoWidth, renderVideoHeight);
  }

  /// 清理缓存
  void clearCache() {
    _lastScreenSize = null;
    _lastAspectRatio = null;
    _lastPaddingTop = null;
    _cachedResult = null;
    
    // 清理图库缓存
    _lastGalleryScreenSize = null;
    _lastGalleryPaddingTop = null;
    _cachedGalleryResult = null;
  }

  /// 强制重新计算
  LayoutResult forceRecalculate({
    required Size screenSize,
    required double aspectRatio,
    required double paddingTop,
  }) {
    clearCache();
    return calculateLayout(
      screenSize: screenSize,
      aspectRatio: aspectRatio,
      paddingTop: paddingTop,
    );
  }

  /// 强制重新计算图库布局
  GalleryScrollerHeightResult forceRecalculateGallery({
    required Size screenSize,
    required double paddingTop,
  }) {
    clearCache();
    return calculateGalleryScrollerHeight(
      screenSize: screenSize,
      paddingTop: paddingTop,
    );
  }

  /// 获取缓存状态信息
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedResult': _cachedResult != null,
      'lastScreenSize': _lastScreenSize?.toString(),
      'lastAspectRatio': _lastAspectRatio,
      'lastPaddingTop': _lastPaddingTop,
      'cachedResult': _cachedResult?.toString(),
      'hasCachedGalleryResult': _cachedGalleryResult != null,
      'lastGalleryScreenSize': _lastGalleryScreenSize?.toString(),
      'lastGalleryPaddingTop': _lastGalleryPaddingTop,
      'cachedGalleryResult': _cachedGalleryResult?.toString(),
    };
  }
} 