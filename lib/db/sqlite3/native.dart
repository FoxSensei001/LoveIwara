import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';

Future<CommonDatabase> openSqliteDb({String? customPath}) async {
  LogUtils.i('打开数据库', 'DatabaseService');
  String dbPath;
  
  if (customPath != null) {
    dbPath = customPath;
    LogUtils.i('使用自定义数据库路径：$dbPath', 'DatabaseService');
  } else {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String appDirPath = p.join(documentsDirectory.path, CommonConstants.applicationName);
    dbPath = p.join(appDirPath, "i_iwara.db");
    LogUtils.i('数据库路径：$dbPath', 'DatabaseService');

    // 确保目录存在
    if (!await Directory(appDirPath).exists()) {
      await Directory(appDirPath).create(recursive: true);
      LogUtils.i('创建目录：$appDirPath', 'DatabaseService');
    }
  }

  final db = sqlite3.open(dbPath);
  _enableWal(db);
  return db;
}

/// 开 WAL（write-ahead logging）。
///
/// # ⛔ 为什么必须开
///
/// 默认的 `journal_mode=delete` 下，**未提交的页是就地写进主库文件的**，旧页放在
/// 旁边的 `-journal` 里。Android 自动备份没有排除 `i_iwara.db`
/// （android/app/src/main/res/xml/backup_rules.xml 只排了安全存储与
/// install_marker），备份代理若正好在一个写事务开着的时候拷走 `.db` 而**不拷
/// `-journal`**，还原出来的就是一个半套用状态——表建了一半、header 的
/// `user_version` 可能已经前进。那是「版本号已前进但表/列缺失」这种 drift 在
/// 生产环境唯一一条机械上成立的来路（见 `DatabaseService.ensureCriticalSchema`）。
///
/// WAL 下改动先落 `-wal`，主库文件**始终是一个自洽的旧快照**，单独被拷走也只是
/// 回到上一个 checkpoint，不会半套。
///
/// # ⚠️ 失败不致命
///
/// 个别文件系统（无共享内存的网络盘等）开不了 WAL。开不了就退回原来的模式继续跑
/// ——它是加固，不是启动前提，不该因此让整个应用打不开。
void _enableWal(CommonDatabase db) {
  try {
    // journal_mode 会写进库 header、持久有效；每次打开都设一遍是自愈，成本可忽略。
    // ⛔ 必须在任何事务之外执行（这里是刚 open、迁移之前，满足条件）。
    final result = db.select('PRAGMA journal_mode=WAL;');
    final mode = result.isEmpty
        ? '?'
        : '${result.first.values.first}'.toLowerCase();
    if (mode == 'wal') {
      LogUtils.i('journal_mode=wal', 'DatabaseService');
    } else {
      LogUtils.w('开启 WAL 未生效，当前 journal_mode=$mode', 'DatabaseService');
    }
  } catch (e) {
    LogUtils.w('开启 WAL 失败，沿用默认 journal_mode: $e', 'DatabaseService');
  }
}
