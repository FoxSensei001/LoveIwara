import 'package:i_iwara/app/models/video.model.dart' as video_model;
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 智能视频缓存管理器
class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  // 缓存存储
  final Map<String, _CacheItem<video_model.Video>> _videoInfoCache = {};
  final Map<String, _CacheItem<List<VideoSource>>> _videoSourceCache = {};
  
  // 缓存配置
  static const int _maxVideoInfoCacheSize = 20;
  static const int _maxVideoSourceCacheSize = 30;
  static const Duration _cacheExpiration = Duration(minutes: 30);
  
  // 线程安全锁
  bool _isCleaningCache = false;
  
  /// 获取视频信息
  video_model.Video? getVideoInfo(String videoId) {
    final item = _videoInfoCache[videoId];
    if (item == null || item.isExpired) {
      if (item != null) {
        _videoInfoCache.remove(videoId);
        LogUtils.d('移除过期的视频信息缓存: $videoId', 'VideoCacheManager');
      }
      return null;
    }
    item.updateAccessTime();
    return item.data;
  }
  
  /// 缓存视频信息
  void cacheVideoInfo(String videoId, video_model.Video video) {
    _videoInfoCache[videoId] = _CacheItem(video);
    LogUtils.d('缓存视频信息: $videoId', 'VideoCacheManager');
    _cleanupIfNeeded();
  }
  
  /// 获取视频源
  List<VideoSource>? getVideoSources(String fileUrl) {
    final item = _videoSourceCache[fileUrl];
    if (item == null || item.isExpired) {
      if (item != null) {
        _videoSourceCache.remove(fileUrl);
        LogUtils.d('移除过期的视频源缓存: ${_truncateUrl(fileUrl)}', 'VideoCacheManager');
      }
      return null;
    }
    item.updateAccessTime();
    return item.data;
  }
  
  /// 缓存视频源
  void cacheVideoSources(String fileUrl, List<VideoSource> sources) {
    _videoSourceCache[fileUrl] = _CacheItem(sources);
    LogUtils.d('缓存视频源: ${_truncateUrl(fileUrl)}, 数量: ${sources.length}', 'VideoCacheManager');
    _cleanupIfNeeded();
  }
  
  /// 智能清理缓存
  void _cleanupIfNeeded() {
    if (_isCleaningCache) return;
    
    // 清理过期项
    final expiredVideoInfo = _videoInfoCache.entries.where((e) => e.value.isExpired).length;
    final expiredVideoSource = _videoSourceCache.entries.where((e) => e.value.isExpired).length;
    
    _videoInfoCache.removeWhere((key, item) => item.isExpired);
    _videoSourceCache.removeWhere((key, item) => item.isExpired);
    
    if (expiredVideoInfo > 0 || expiredVideoSource > 0) {
      LogUtils.d('清理过期缓存 - 视频信息: $expiredVideoInfo, 视频源: $expiredVideoSource', 'VideoCacheManager');
    }
    
    // 如果仍然超出限制，清理最少使用的项
    if (_videoInfoCache.length > _maxVideoInfoCacheSize) {
      final removed = _cleanupLRU(_videoInfoCache, _maxVideoInfoCacheSize);
      LogUtils.d('LRU清理视频信息缓存: $removed 项', 'VideoCacheManager');
    }
    
    if (_videoSourceCache.length > _maxVideoSourceCacheSize) {
      final removed = _cleanupLRU(_videoSourceCache, _maxVideoSourceCacheSize);
      LogUtils.d('LRU清理视频源缓存: $removed 项', 'VideoCacheManager');
    }
  }
  
  /// LRU清理策略
  int _cleanupLRU<T>(Map<String, _CacheItem<T>> cache, int maxSize) {
    if (cache.length <= maxSize) return 0;
    
    _isCleaningCache = true;
    int removedCount = 0;
    
    try {
      final entries = cache.entries.toList();
      entries.sort((a, b) => a.value.lastAccessTime.compareTo(b.value.lastAccessTime));
      
      final toRemove = entries.take(cache.length - maxSize);
      for (final entry in toRemove) {
        cache.remove(entry.key);
        removedCount++;
      }
    } finally {
      _isCleaningCache = false;
    }
    
    return removedCount;
  }
  
  /// 强制清理所有缓存
  void clearAll() {
    final videoInfoCount = _videoInfoCache.length;
    final videoSourceCount = _videoSourceCache.length;
    
    _videoInfoCache.clear();
    _videoSourceCache.clear();
    
    LogUtils.d('清理所有缓存 - 视频信息: $videoInfoCount, 视频源: $videoSourceCount', 'VideoCacheManager');
  }
  
  /// 清理特定视频的相关缓存
  void clearVideoCache(String videoId) {
    _videoInfoCache.remove(videoId);
    LogUtils.d('清理视频缓存: $videoId', 'VideoCacheManager');
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final videoInfoStats = _getCacheTypeStats(_videoInfoCache);
    final videoSourceStats = _getCacheTypeStats(_videoSourceCache);
    
    return {
      'videoInfo': videoInfoStats,
      'videoSource': videoSourceStats,
      'totalMemoryEstimate': _estimateMemoryUsage(),
    };
  }
  
  /// 获取特定类型缓存的统计信息
  Map<String, int> _getCacheTypeStats<T>(Map<String, _CacheItem<T>> cache) {
    final now = DateTime.now();
    int expiredCount = 0;
    int validCount = 0;
    
    for (final item in cache.values) {
      if (item.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }
    
    return {
      'total': cache.length,
      'valid': validCount,
      'expired': expiredCount,
    };
  }
  
  /// 估算内存使用量（KB）
  int _estimateMemoryUsage() {
    // 粗略估算：每个视频信息约2KB，每个视频源列表约1KB
    return (_videoInfoCache.length * 2) + (_videoSourceCache.length * 1);
  }
  
  /// 截断URL用于日志显示
  String _truncateUrl(String url) {
    if (url.length <= 50) return url;
    return '${url.substring(0, 25)}...${url.substring(url.length - 20)}';
  }
  
  /// 打印缓存状态（调试用）
  void printCacheStatus() {
    final stats = getCacheStats();
    LogUtils.d('缓存状态: $stats', 'VideoCacheManager');
  }
}

/// 缓存项包装器
class _CacheItem<T> {
  final T data;
  final DateTime createdTime;
  DateTime lastAccessTime;
  
  _CacheItem(this.data) 
    : createdTime = DateTime.now(),
      lastAccessTime = DateTime.now();
  
  bool get isExpired {
    return DateTime.now().difference(createdTime) > VideoCacheManager._cacheExpiration;
  }
  
  void updateAccessTime() {
    lastAccessTime = DateTime.now();
  }
  
  Duration get age => DateTime.now().difference(createdTime);
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessTime);
}
