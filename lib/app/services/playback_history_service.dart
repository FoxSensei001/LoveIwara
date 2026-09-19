import 'package:get/get.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

/// 线上视频的续播进度（`video_playback_history`，按 Iwara videoId）。
///
/// # 行的三种状态
/// - 没有这一行：没看过 / 只看了开头几秒（当作没看）
/// - `played_duration < total_duration`：看到一半，下次从这里续播
/// - `played_duration == total_duration`：看完了（剩余不足 [finishThresholdMs] 时写成 played = total），浏览历史显示「已看完」，
///   续播从头放
///
/// 以前「看完」是靠删行表达的，历史页因此分不清「没看」和「看完」。
///
/// # 生命周期
/// 不按时间淘汰：进度跟着浏览历史走，删历史（单条 / 批量 / 按区间 / 自动清理）时
/// `HistoryRepository` 在同一事务里把对应进度一起删掉。
class PlaybackHistoryService extends GetxService {
  static PlaybackHistoryService get to => Get.find();

  late final CommonDatabase _db;

  PlaybackHistoryService() {
    _db = DatabaseService().database;
  }

  /// 剩余不足这么多就算看完。
  static const int finishThresholdMs = 7000;

  void _upsert(String videoId, int totalDuration, int playedDuration) {
    // ⛔ 不用 INSERT OR REPLACE：那是 delete + insert，会把 created_at 一起重置。
    _db.execute(
      '''
      INSERT INTO video_playback_history
        (video_id, total_duration, played_duration, updated_at)
      VALUES (?, ?, ?, strftime('%s','now'))
      ON CONFLICT(video_id) DO UPDATE SET
        total_duration = excluded.total_duration,
        played_duration = excluded.played_duration,
        updated_at = excluded.updated_at
      ''',
      [videoId, totalDuration, playedDuration],
    );
  }

  /// 按播放器退出时的位置记一笔：开头几秒当作没看（删行），末尾几秒当作看完。
  /// 页面播放器与沉浸播放器共用这一个口径。
  Future<void> recordPosition(
    String videoId,
    int totalDuration,
    int playedDuration,
  ) async {
    if (playedDuration <= 5000) {
      await deletePlaybackHistory(videoId);
      return;
    }
    await savePlaybackHistory(videoId, totalDuration, playedDuration);
  }

  // 保存播放记录
  Future<void> savePlaybackHistory(
    String videoId,
    int totalDuration,
    int playedDuration,
  ) async {
    try {
      if (totalDuration <= 8000) return; // 总时长小于8秒不记录
      if (totalDuration - playedDuration <= finishThresholdMs) {
        _upsert(videoId, totalDuration, totalDuration);
        return;
      }
      _upsert(videoId, totalDuration, playedDuration);
    } catch (e) {
      LogUtils.e('保存播放记录失败', tag: 'PlaybackHistoryService', error: e);
    }
  }

  // 获取播放记录
  Future<Map<String, dynamic>?> getPlaybackHistory(String videoId) async {
    try {
      final results = _db.select(
        'SELECT * FROM video_playback_history WHERE video_id = ?',
        [videoId],
      );
      if (results.isEmpty) return null;
      return results.first;
    } catch (e) {
      LogUtils.e('获取播放记录失败', tag: 'PlaybackHistoryService', error: e);
      return null;
    }
  }

  /// 续播起点：没有记录 / 已看完 → 从头；否则回退 4 秒。
  Future<Duration> resumePosition(String videoId) async {
    final history = await getPlaybackHistory(videoId);
    if (history == null) return Duration.zero;
    final played = history['played_duration'] as int;
    final total = history['total_duration'] as int;
    if (total <= 0 || total - played <= finishThresholdMs) return Duration.zero;
    return Duration(milliseconds: (played - 4000).clamp(0, total));
  }

  // 删除播放记录
  Future<void> deletePlaybackHistory(String videoId) async {
    try {
      _db.execute('DELETE FROM video_playback_history WHERE video_id = ?', [
        videoId,
      ]);
    } catch (e) {
      LogUtils.e('删除播放记录失败', tag: 'PlaybackHistoryService', error: e);
    }
  }
}
