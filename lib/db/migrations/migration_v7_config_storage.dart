import 'package:i_iwara/app/services/config_service.dart';
import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'dart:convert';
import 'migration.dart';

class MigrationV7ConfigStorage extends Migration {
  @override
  int get version => 7;

  @override
  String get description => "将 config_service 的值从 StorageService 迁移到数据库";

  @override
  Future<void> up(CommonDatabase db) async {
    try {
      final storage = StorageService();
      if (!storage.initialized) {
        await storage.init();
      }

      // 遍历所有配置项，将存储中的值迁移到数据库中
      for (final key in ConfigKey.values) {
        try {
          final storedValue = storage.readData(key.key);
          if (storedValue != null) {
            String valueStr = storedValue is List ? jsonEncode(storedValue) : storedValue.toString();
            db.execute('''
              INSERT OR REPLACE INTO app_config (key, value)
              VALUES (?, ?)
            ''', [key.key, valueStr]);
          }
        } catch (e) {
          // 如果某个配置项处理失败，记录日志但继续处理其他配置项
          LogUtils.w('迁移配置项 ${key.key} 失败: $e');
          continue;
        }
      }

      db.execute('PRAGMA user_version = 7;');
      LogUtils.i('已应用迁移v7：将 config_service 的值从 StorageService 迁移到数据库');
    } catch (e) {
      LogUtils.e('迁移v7失败: $e');
      rethrow; // 重新抛出异常以便事务回滚
    }
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('迁移v7无法回滚');
  }
}
