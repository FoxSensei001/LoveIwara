import 'package:i_iwara/utils/logger_utils.dart';
import 'base_repository.dart';

class SignInRepository extends BaseRepository {
  SignInRepository._privateConstructor();
  static final SignInRepository instance = SignInRepository._privateConstructor();

  // 检查用户今天是否已签到
  Future<Map<String, dynamic>?> checkIfSignedInToday(String userId) async {
    try {
      final now = DateTime.now();
      final dateStr = now.toIso8601String().split('T').first; // 获取日期部分
      final db = databaseService.database;
      final result = db.select(
        'SELECT status, reason FROM sign_in_records WHERE user_id = ? AND date = ?',
        [userId, dateStr],
      );
      if (result.isNotEmpty) {
        return {
          'status': result.first['status'] as int,
          'reason': result.first['reason'] as String?,
        };
      }
      return null;
    } catch (e) {
      LogUtils.e('检查签到状态时出错', error: e);
      rethrow;
    }
  }

  // 执行签到操作
  Future<void> signIn(String userId, {required bool isSuccess, String? reason}) async {
    try {
      final now = DateTime.now();
      final dateStr = now.toIso8601String().split('T').first; // 获取日期部分
      final db = databaseService.database;

      // 检查今天是否已有签到记录
      final existing = db.select(
        'SELECT * FROM sign_in_records WHERE user_id = ? AND date = ?',
        [userId, dateStr],
      );

      if (existing.isEmpty) {
        // 插入新记录
        db.execute(
          'INSERT INTO sign_in_records(user_id, date, status, reason) VALUES (?, ?, ?, ?)',
          [userId, dateStr, isSuccess ? 1 : 0, reason],
        );
      } else {
        // 更新现有记录
        db.execute(
          'UPDATE sign_in_records SET status = ?, reason = ? WHERE user_id = ? AND date = ?',
          [isSuccess ? 1 : 0, reason, userId, dateStr],
        );
      }
    } catch (e) {
      LogUtils.e('签到失败', error: e);
      rethrow;
    }
  }

  // 获取用户的签到记录列表
  Future<List<Map<String, dynamic>>> getSignInRecords(String userId) async {
    try {
      final db = databaseService.database;
      final result = db.select(
        'SELECT date, status, reason FROM sign_in_records WHERE user_id = ? ORDER BY date DESC',
        [userId],
      );
      return result.map((row) => {
        'date': DateTime.parse(row['date'] as String),
        'status': row['status'] as int,
        'reason': row['reason'] as String?,
      }).toList();
    } catch (e) {
      LogUtils.e('获取签到记录时出错', error: e);
      rethrow;
    }
  }

  // 获取用户的总成功签到次数
  Future<int> getTotalSignIns(String userId) async {
    try {
      final db = databaseService.database;
      final result = db.select(
        'SELECT COUNT(*) as total FROM sign_in_records WHERE user_id = ? AND status = 1',
        [userId],
      );
      LogUtils.d('获取用户的总签到次数：$result', 'SignInRepository');
      if (result.isNotEmpty) {
        return result.first['total'] as int;
      }
      return 0;
    } catch (e) {
      LogUtils.e('获取总签到次数时出错', error: e);
      rethrow;
    }
  }

  // 获取用户的连续签到天数
  Future<int> getConsecutiveSignIns(String userId) async {
    try {
      final db = databaseService.database;
      final result = db.select(
        'SELECT date, status FROM sign_in_records WHERE user_id = ? ORDER BY date DESC',
        [userId],
      );

      int streak = 0;
      DateTime currentDay = DateTime.now();
      // 将 currentDay 设置为当天的午夜，避免时间差异影响
      currentDay = DateTime(currentDay.year, currentDay.month, currentDay.day);

      for (var row in result) {
        final date = DateTime.parse(row['date'] as String);
        final flooredDate = DateTime(date.year, date.month, date.day);
        final status = row['status'] as int;

        if (status != 1) break;

        final difference = currentDay.difference(flooredDate).inDays;

        if (difference == 0) {
          streak += 1;
          currentDay = currentDay.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      return streak;
    } catch (e) {
      LogUtils.e('获取连续签到次数时出错', error: e);
      rethrow;
    }
  }
}
