import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';

Future<CommonDatabase> openSqliteDb() async {
  LogUtils.i('打开数据库', 'DatabaseService');
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String appDirPath = p.join(documentsDirectory.path, CommonConstants.applicationName);
  String path = p.join(appDirPath, "i_iwara.db");
  LogUtils.i('数据库路径：$path', 'DatabaseService');

  // 确保目录存在
  if (!await Directory(appDirPath).exists()) {
    await Directory(appDirPath).create(recursive: true);
    LogUtils.i('创建目录：$appDirPath', 'DatabaseService');
  }

  return sqlite3.open(path);
}
