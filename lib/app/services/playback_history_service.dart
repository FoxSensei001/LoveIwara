import 'package:get/get.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

class PlaybackHistoryService extends GetxService {
  static PlaybackHistoryService get to => Get.find();
  
  late final CommonDatabase _db;

  PlaybackHistoryService() {
    _db = DatabaseService().database;
  }

  // 初始化服务，清理7天前的记录
  Future<void> init() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final timestamp = sevenDaysAgo.millisecondsSinceEpoch ~/ 1000;
      
      _db.prepare('''
        DELETE FROM video_playback_history 
        WHERE created_at < ?
      ''').execute([timestamp]);
      
      LogUtils.i('已清理7天前的播放记录', 'PlaybackHistoryService');
    } catch (e) {
      LogUtils.e('清理播放记录失败', tag: 'PlaybackHistoryService', error: e);
    }
  }

  // 保存播放记录
  Future<void> savePlaybackHistory(String videoId, int totalDuration, int playedDuration) async {
    try {
      if (totalDuration <= 8000) return; // 总时长小于8秒不记录
      
      final remainingDuration = totalDuration - playedDuration;
      if (remainingDuration <= 7000) {
        // 如果剩余时长小于7秒，删除记录
        await deletePlaybackHistory(videoId);
        return;
      }

      _db.prepare('''
        INSERT OR REPLACE INTO video_playback_history 
        (video_id, total_duration, played_duration, updated_at)
        VALUES (?, ?, ?, ?)
      ''').execute([
        videoId,
        totalDuration,
        playedDuration,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ]);
    } catch (e) {
      LogUtils.e('保存播放记录失败', tag: 'PlaybackHistoryService', error: e);
    }
  }

  // 获取播放记录
  Future<Map<String, dynamic>?> getPlaybackHistory(String videoId) async {
    try {
      final stmt = _db.prepare('''
        SELECT * FROM video_playback_history 
        WHERE video_id = ?
      ''');
      
      final results = stmt.select([videoId]);
      if (results.isEmpty) return null;
      
      return results.first;
    } catch (e) {
      LogUtils.e('获取播放记录失败', tag: 'PlaybackHistoryService', error: e);
      return null;
    }
  }

  // 删除播放记录
  Future<void> deletePlaybackHistory(String videoId) async {
    try {
      _db.prepare('''
        DELETE FROM video_playback_history 
        WHERE video_id = ?
      ''').execute([videoId]);
    } catch (e) {
      LogUtils.e('删除播放记录失败', tag: 'PlaybackHistoryService', error: e);
    }
  }
}