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
  void up(CommonDatabase db) {
    final storage = StorageService();
    // 遍历所有配置项，将存储中（如存在）的值迁移到数据库中
    for (final key in ConfigKey.values) {
      final storedValue = storage.readData(key.key);
      final valueToSave = storedValue ?? key.getDefaultValue(key);
      String valueStr = valueToSave is List ? jsonEncode(valueToSave) : valueToSave.toString();
      db.execute('''
        INSERT OR REPLACE INTO app_config (key, value)
        VALUES (?, ?)
      ''', [key.key, valueStr]);
    }
    db.execute('PRAGMA user_version = 7;');
    LogUtils.i('已应用迁移v7：将 config_service 的值从 StorageService 迁移到数据库');
  }

  @override
  void down(CommonDatabase db) {
    // 由于无法还原 StorageService 中的数据，此迁移不支持回滚
    LogUtils.i('迁移v7无法回滚');
  }
}
