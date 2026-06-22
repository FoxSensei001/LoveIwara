import 'dart:io';
import 'dart:convert';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/foundation.dart'; // 用于 compute()
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 配置备份服务，用于导出和导入数据库中各表的内容（不包含下载记录表）。
///
/// 导出的内容覆盖 app_config（应用设置）、history_records / video_playback_history（浏览与播放历史）、
/// 收藏夹、表情包等用户数据，因此本功能同时承担「设置 + 历史记录」跨设备同步的职责。
class ConfigBackupService extends GetxService {
  // 默认构造函数
  ConfigBackupService();

  bool _isTaskRunning = false;

  /// 导出时不参与的表（下载任务与本机强相关，迁移到其他设备无意义）。
  static const Set<String> _excludedTables = {'download_tasks'};

  /// app_config 中属于敏感信息的配置键（API 密钥、会话令牌、可能含账号密码的代理地址、
  /// 可能内嵌路径 token 的自建/中转网关地址）。
  /// 默认导出时会被剔除，避免备份文件被分享/上传云端后泄露凭据。
  static final Set<String> _sensitiveConfigKeys = {
    ConfigKey.AI_TRANSLATION_API_KEY.key,
    ConfigKey.AI_TRANSLATION_BASE_URL.key,
    ConfigKey.DEEPLX_API_KEY.key,
    ConfigKey.DEEPLX_DL_SESSION.key,
    ConfigKey.DEEPLX_BASE_URL.key,
    ConfigKey.PROXY_URL.key,
  };

  /// 静态方法，用于在后台 isolate 中进行 JSON 序列化
  static String _encodeData(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// 在 _encodeData 函数后添加新的静态函数 _decodeData，用于在后台 isolate 中解析 JSON
  static Map<String, dynamic> _decodeData(String content) {
    return jsonDecode(content) as Map<String, dynamic>;
  }

  /// 导出数据库中所有用户配置表的数据（排除下载记录表），
  /// 并将其保存成 JSON 文件（默认文件名：i_iwara_backup.json）。
  ///
  /// [includeSensitive] 为 true 时才会把 API 密钥 / 会话令牌 / 代理地址等敏感配置写入备份，
  /// 默认 false。
  Future<void> exportConfig({bool includeSensitive = false}) async {
    if (_isTaskRunning) {
      showToastWidget(MDToastWidget(message: slang.t.common.taskRunning, type: MDToastType.error));
      return;
    }
    _isTaskRunning = true;
    _showLoading();
    try {
      // 获取数据库实例
      final db = DatabaseService().database;
      // 查询所有用户自定义的表，不包含系统表（sqlite_*）
      final tablesResult = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );
      final List<String> tableNames = [];
      for (final row in tablesResult) {
        final tableName = row['name'] as String;
        if (_excludedTables.contains(tableName)) continue;
        tableNames.add(tableName);
      }

      // 当前数据库 schema 版本，便于导入端判断兼容性 / 排查问题
      int dbVersion = 0;
      try {
        final versionResult = db.select('PRAGMA user_version;');
        if (versionResult.isNotEmpty) {
          dbVersion = versionResult.first['user_version'] as int;
        }
      } catch (_) {
        // 读取失败不影响导出
      }

      // 构建待导出的数据，按表名分组
      final Map<String, dynamic> exportedData = {
        // 保持为 1 以兼容旧版本应用的导入校验；新增字段仅作元信息使用
        "format_version": 1,
        "app_version": CommonConstants.VERSION,
        "db_version": dbVersion,
        "platform": Platform.operatingSystem,
        "include_sensitive": includeSensitive,
        "tables": <String, dynamic>{},
      };
      for (final table in tableNames) {
        final rows = db.select("SELECT * FROM $table;");
        final List<Map<String, dynamic>> rowsData = [];
        for (final row in rows) {
          final rowMap = Map<String, dynamic>.from(row);
          // 过滤敏感配置项
          if (!includeSensitive &&
              table == 'app_config' &&
              _sensitiveConfigKeys.contains(rowMap['key'])) {
            continue;
          }
          rowsData.add(rowMap);
        }
        exportedData["tables"][table] = rowsData;
      }

      // 后台 isolate 中进行 JSON 序列化
      final jsonString = await compute(_encodeData, exportedData);

      if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台：使用 try-finally 确保临时文件被删除
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/${CommonConstants.applicationName}_backup.json';
        final tempFile = File(tempFilePath);
        try {
          await tempFile.writeAsString(jsonString);
          final params = SaveFileDialogParams(
            sourceFilePath: tempFilePath,
          );
          final savedPath = await FlutterFileDialog.saveFile(params: params);
          if (savedPath == null) {
            // 用户取消保存
            showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.info));
          } else {
            showToastWidget(MDToastWidget(message: slang.t.settings.exportConfigSuccess, type: MDToastType.success));
          }
        } finally {
          // 确保临时文件无论如何都被删除
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      } else {
        // 桌面平台：弹出保存文件对话框
        final fileSaveLocation = await fs.getSaveLocation(
          acceptedTypeGroups: [const fs.XTypeGroup(label: 'JSON', extensions: ['json'])],
          suggestedName: '${CommonConstants.applicationName}_backup.json',
        );
        if (fileSaveLocation == null) {
          showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.info));
          return;
        }
        final file = File(fileSaveLocation.path);
        await file.writeAsString(jsonString);
        showToastWidget(MDToastWidget(message: slang.t.settings.exportConfigSuccess, type: MDToastType.success));
      }
    } catch (e) {
      LogUtils.e("配置导出失败: ${e.toString()}", error: e, tag: "ConfigBackupService");
      throw Exception("配置导出失败: ${e.toString()}");
    } finally {
      _hideLoading();
      _isTaskRunning = false;
    }
  }

  /// 从 JSON 文件导入配置数据，将对应数据写入各数据库表中（排除下载记录表）。
  ///
  /// 导入会先选择并解析文件，再整体覆盖现有数据。为兼容不同应用版本之间的 schema 差异，
  /// 仅导入当前数据库中确实存在的表与列，未知表 / 未知列会被安全跳过。
  /// 返回 true 表示确实完成了一次导入；用户取消选择文件时返回 false。
  /// 导入失败会抛出异常，由调用方处理。
  Future<bool> importConfig() async {
    if (_isTaskRunning) {
      showToastWidget(MDToastWidget(message: slang.t.common.taskRunning, type: MDToastType.error));
      return false;
    }
    _isTaskRunning = true;
    _showLoading();
    try {
      String content;
      if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台：使用 FlutterFileDialog 选择文件
        const params = OpenFileDialogParams();
        final filePath = await FlutterFileDialog.pickFile(params: params);
        if (filePath == null) {
          showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.info));
          return false; // 用户取消选择
        }
        final file = File(filePath);
        content = await file.readAsString();
      } else {
        // 桌面平台：使用 file_selector 弹出打开文件对话框
        const typeGroup = fs.XTypeGroup(label: 'JSON', extensions: ['json']);
        final fs.XFile? file = await fs.openFile(acceptedTypeGroups: [typeGroup]);
        if (file == null) {
          showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.info));
          return false; // 用户取消选择
        }
        content = await file.readAsString();
      }

      // 在后台 isolate 中解析 JSON
      final Map<String, dynamic> importData = await compute(_decodeData, content);

      // 兼容 format_version 1 及以上（新版本只新增元信息字段，结构向后兼容）
      final formatVersion = importData["format_version"];
      if (formatVersion is! int || formatVersion < 1) {
        throw Exception("不兼容的配置文件格式");
      }
      if (importData["tables"] is! Map) {
        throw Exception("配置文件缺少有效的数据表内容");
      }

      final Map<String, dynamic> tablesData = Map<String, dynamic>.from(importData["tables"]);
      final db = DatabaseService().database;

      // 当前数据库中实际存在的表，避免导入旧 / 新备份中已不存在的表
      final existingTables = <String>{};
      for (final row in db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      )) {
        existingTables.add(row['name'] as String);
      }

      // 禁用外键约束并开启事务
      db.execute('PRAGMA foreign_keys = OFF;');
      db.execute('BEGIN TRANSACTION;');
      try {
        for (final tableName in tablesData.keys) {
          if (_excludedTables.contains(tableName)) continue; // 跳过下载记录表
          if (!existingTables.contains(tableName)) {
            LogUtils.w('导入时跳过当前数据库中不存在的表: $tableName', 'ConfigBackupService');
            continue;
          }

          // 当前表的真实列集合，用于过滤备份中多余 / 缺失的列（处理版本间 schema 漂移）
          final currentColumns = <String>{};
          for (final col in db.select("PRAGMA table_info('$tableName');")) {
            currentColumns.add(col['name'] as String);
          }

          // 清空已有数据
          db.execute("DELETE FROM $tableName;");
          final List<dynamic> rowsList = tablesData[tableName];
          if (rowsList.isEmpty) continue;

          // 收集所有行出现过的列的并集（容忍被篡改导致行间列不一致的文件），
          // 再与当前表实际存在的列取交集，避免写入已不存在的列。
          final backupColumns = <String>{};
          for (final row in rowsList) {
            backupColumns.addAll(Map<String, dynamic>.from(row as Map).keys);
          }
          final columns = backupColumns
              .where((c) => currentColumns.contains(c))
              .toList();
          if (columns.isEmpty) {
            LogUtils.w('导入时表 $tableName 无可用列，已跳过', 'ConfigBackupService');
            continue;
          }
          final String columnsJoined = columns.join(', ');
          final String placeholders = List.filled(columns.length, '?').join(', ');
          final stmt = db.prepare("INSERT INTO $tableName ($columnsJoined) VALUES ($placeholders);");
          for (final row in rowsList) {
            final Map<String, dynamic> rowMap = Map<String, dynamic>.from(row);
            final values = columns.map((c) => rowMap[c]).toList();
            stmt.execute(values);
          }
          stmt.close();
        }
        db.execute('COMMIT;');
      } catch (e) {
        db.execute('ROLLBACK;');
        rethrow;
      } finally {
        db.execute('PRAGMA foreign_keys = ON;');
      }
      return true;
    } catch (e) {
      LogUtils.e("配置导入失败: ${e.toString()}", error: e, tag: "ConfigBackupService");
      throw Exception("配置导入失败: ${e.toString()}");
    } finally {
      _hideLoading();
      _isTaskRunning = false;
    }
  }

  void _showLoading() {
    showAppDialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoading() {
    if (OverlayTracker.instance.hasOverlay) {
      AppService.tryPop();
    }
  }
}
