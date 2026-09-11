import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/db/sqlite3/sqlite3.dart' show openSqliteDb;
import 'package:i_iwara/utils/logger_utils.dart';

/// 库必须以 WAL 模式打开。
///
/// # ⛔ 这条闸门挡的是什么
///
/// 默认 `journal_mode=delete` 下未提交的页**就地写进主库文件**，旧页在旁边的
/// `-journal` 里。Android 自动备份没有排除 `i_iwara.db`，备份代理若在写事务开着
/// 时拷走 `.db` 而不拷 `-journal`，还原出来就是半套用的 DDL——那是「版本号已前进
/// 但表/列缺失」在生产环境唯一一条机械上成立的来路。
///
/// WAL 下主库文件始终是一个自洽的旧快照，单独被拷走只是回到上一个 checkpoint。
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  test('⛔ openSqliteDb 打开的库必须是 WAL 模式', () async {
    final dir = await Directory.systemTemp.createTemp('iwara_wal_test');
    addTearDown(() => dir.deleteSync(recursive: true));

    final db = await openSqliteDb(customPath: '${dir.path}/t.db');
    addTearDown(db.close);

    final mode = db
        .select('PRAGMA journal_mode;')
        .first
        .values
        .first
        .toString()
        .toLowerCase();
    expect(mode, 'wal');
  });

  test('WAL 是持久设置：重新打开同一个库仍是 wal', () async {
    final dir = await Directory.systemTemp.createTemp('iwara_wal_test2');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/t.db';

    final first = await openSqliteDb(customPath: path);
    first.execute('CREATE TABLE t(x);');
    first.close();

    final second = await openSqliteDb(customPath: path);
    addTearDown(second.close);
    expect(
      second
          .select('PRAGMA journal_mode;')
          .first
          .values
          .first
          .toString()
          .toLowerCase(),
      'wal',
    );
  });
}
