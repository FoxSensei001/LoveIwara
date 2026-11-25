import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart' as video_model;
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/services/iwara_site_headers.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
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

  /// 条目是在哪个站点、哪个账号下取的。读的时候对不上就当没缓存：
  /// - 详情里的 `liked`、私密视频能不能看都跟账号走；
  /// - 主站模式下缓存了 AI 站的视频，切站后再点它不会再收到 differentSite，
  ///   自动切站就失灵了。
  /// 以前只有点进去过的视频才会进缓存，悬停预取之后鼠标停一下就进，所以补上。
  @visibleForTesting
  static String Function() contextKey = _defaultContextKey;

  /// 此刻的「站点 + 账号」标记（同 [contextKey]）。请求发出前记一份，回来时
  /// 对一下，就知道中途有没有切站 / 换号。
  static String currentContextKey() => contextKey();

  static String _defaultContextKey() {
    final site = currentIwaraSiteOrMain().name;
    final userId = Get.isRegistered<UserService>()
        ? Get.find<UserService>().currentUser.value?.id
        : null;
    if (userId != null) return '$site|$userId';
    // 没拿到用户 id 时分清「登着但资料还没加载 / 加载失败」与「没登录」：
    // 两者都记成 `-` 的话，登着时取的详情（带这个号的 liked）退出登录后照样命中。
    final loggedIn =
        Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().hasRefreshToken;
    return '$site|${loggedIn ? '?' : '-'}';
  }
  
  /// 获取视频信息
  video_model.Video? getVideoInfo(String videoId) {
    final item = _videoInfoCache[videoId];
    if (item == null || item.isExpired || item.contextKey != contextKey()) {
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

  /// 更新缓存中视频信息的部分字段
  void updateVideoInfoFields(String videoId, Map<String, dynamic> fields) {
    final item = _videoInfoCache[videoId];
    if (item == null || item.contextKey != contextKey()) {
      // 换过站点 / 账号的旧条目不能借这次更新换成当前身份的条目
      if (item != null) _videoInfoCache.remove(videoId);
      LogUtils.w('尝试更新不存在的缓存项: $videoId', 'VideoCacheManager');
      return;
    }

    // 使用 copyWith 更新字段
    try {
      video_model.Video updatedVideo = item.data.copyWith(
        liked: fields['liked'] as bool?,
        numLikes: fields['numLikes'] as int?,
      );

      // 更新缓存项
      _videoInfoCache[videoId] = _CacheItem(updatedVideo);
      LogUtils.d('更新缓存视频字段: $videoId, 字段: ${fields.keys.join(', ')}', 'VideoCacheManager');
    } catch (e) {
      LogUtils.e('更新缓存视频字段失败: $videoId', tag: 'VideoCacheManager', error: e);
    }
  }

  /// 更新缓存中视频的作者信息（用于关注、取关）
  void updateVideoAuthor(String videoId, User updatedUser) {
    final item = _videoInfoCache[videoId];
    if (item == null || item.contextKey != contextKey()) {
      // 换过站点 / 账号的旧条目不能借这次更新换成当前身份的条目
      if (item != null) _videoInfoCache.remove(videoId);
      LogUtils.w('尝试更新不存在的缓存项: $videoId', 'VideoCacheManager');
      return;
    }

    try {
      final updatedVideo = item.data.copyWith(user: updatedUser);
      _videoInfoCache[videoId] = _CacheItem(updatedVideo);
      LogUtils.d('更新缓存作者信息: $videoId, authorId: ${updatedUser.id}', 'VideoCacheManager');
    } catch (e) {
      LogUtils.e('更新缓存作者信息失败: $videoId', tag: 'VideoCacheManager', error: e);
    }
  }
  
  /// 获取视频源
  List<VideoSource>? getVideoSources(String fileUrl) {
    final item = _videoSourceCache[fileUrl];
    if (item == null || item.isExpired || item.contextKey != contextKey()) {
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
  
  /// 删掉某个视频的源缓存（例如刷新拿到的是签名失效时的 360 清单，
  /// 留着旧条目只会让重开时用上快过期的链接）
  void removeVideoSources(String fileUrl) {
    _videoSourceCache.remove(fileUrl);
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
  final String contextKey;
  DateTime lastAccessTime;
  
  _CacheItem(this.data) 
    : createdTime = DateTime.now(),
      contextKey = VideoCacheManager.contextKey(),
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
