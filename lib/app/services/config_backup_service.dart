import 'dart:io';
import 'dart:convert';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/foundation.dart'; // 用于 compute()
import 'package:i_iwara/i18n/strings.g.dart' as slang;
/// 配置备份服务，用于导出和导入数据库中各表的内容（不包含下载记录表）
class ConfigBackupService extends GetxService {
  // 默认构造函数
  ConfigBackupService();

  bool _isTaskRunning = false;

  /// 静态方法，用于在后台 isolate 中进行 JSON 序列化
  static String _encodeData(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// 在 _encodeData 函数后添加新的静态函数 _decodeData，用于在后台 isolate 中解析 JSON
  static Map<String, dynamic> _decodeData(String content) {
    return jsonDecode(content) as Map<String, dynamic>;
  }

  /// 导出数据库中所有用户配置表的数据（排除下载记录表），
  /// 并将其保存成 JSON 文件（默认文件名：i_iwara_backup.json）
  Future<void> exportConfig() async {
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
        if (tableName == 'download_tasks') continue;
        tableNames.add(tableName);
      }
      
      // 构建待导出的数据，按表名分组
      final Map<String, dynamic> exportedData = {
        "format_version": 1,
        "tables": <String, dynamic>{},
      };
      for (final table in tableNames) {
        final rows = db.select("SELECT * FROM $table;");
        final List<Map<String, dynamic>> rowsData = [];
        for (final row in rows) {
          rowsData.add(Map<String, dynamic>.from(row));
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
          await FlutterFileDialog.saveFile(params: params);
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
          showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.error));
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
  
  /// 从 JSON 文件导入配置数据，将对应数据写入各数据库表中（排除下载记录表）
  Future<void> importConfig() async {
    if (_isTaskRunning) {
      showToastWidget(MDToastWidget(message: slang.t.common.taskRunning, type: MDToastType.error));
      return;
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
          showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.error));
          return; // 用户取消选择
        }
        final file = File(filePath);
        content = await file.readAsString();
      } else {
        // 桌面平台：使用 file_selector 弹出打开文件对话框
        const typeGroup = fs.XTypeGroup(label: 'JSON', extensions: ['json']);
        final fs.XFile? file = await fs.openFile(acceptedTypeGroups: [typeGroup]);
        if (file == null) {
          showToastWidget(MDToastWidget(message: slang.t.common.operationCancelled, type: MDToastType.error));
          return; // 用户取消选择
        }
        content = await file.readAsString();
      }
      
      // 在后台 isolate 中解析 JSON
      final Map<String, dynamic> importData = await compute(_decodeData, content);
      
      if (importData["format_version"] != 1) {
        throw Exception("不兼容的配置文件格式");
      }

      
      final Map<String, dynamic> tablesData = Map<String, dynamic>.from(importData["tables"]);
      final db = DatabaseService().database;
      // 禁用外键约束并开启事务
      db.execute('PRAGMA foreign_keys = OFF;');
      db.execute('BEGIN TRANSACTION;');
      try {
        for (final tableName in tablesData.keys) {
          if (tableName == 'download_tasks') continue; // 跳过下载记录表
          // 清空已有数据
          db.execute("DELETE FROM $tableName;");
          final List<dynamic> rowsList = tablesData[tableName];
          if (rowsList.isEmpty) continue;
          final firstRow = rowsList.first as Map<String, dynamic>;
          final columns = firstRow.keys.toList();
          final String columnsJoined = columns.join(', ');
          final String placeholders = List.filled(columns.length, '?').join(', ');
          final stmt = db.prepare("INSERT INTO $tableName ($columnsJoined) VALUES ($placeholders);");
          for (final row in rowsList) {
            final Map<String, dynamic> rowMap = Map<String, dynamic>.from(row);
            final values = columns.map((c) => rowMap[c]).toList();
            stmt.execute(values);
          }
          stmt.dispose();
        }
        db.execute('COMMIT;');
      } catch (e) {
        db.execute('ROLLBACK;');
        rethrow;
      } finally {
        db.execute('PRAGMA foreign_keys = ON;');
      }
      showToastWidget(MDToastWidget(message: slang.t.settings.importConfigSuccess, type: MDToastType.success));
    } catch (e) {
      LogUtils.e("配置导入失败: ${e.toString()}", error: e, tag: "ConfigBackupService");
      throw Exception("配置导入失败: ${e.toString()}");
    } finally {
      _hideLoading();
      _isTaskRunning = false;
    }
  }
  
  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }
  
  void _hideLoading() {
    if (Get.isDialogOpen == true) {
      AppService.tryPop();
    }
  }
} 