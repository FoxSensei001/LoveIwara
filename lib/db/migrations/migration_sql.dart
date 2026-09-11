/// 迁移里反复要用的几个幂等原语。
///
/// # 为什么要有这个文件
///
/// 2026-09-11 给迁移链路补了一条「在已迁移完的库上把每条迁移再跑一遍」的测试
/// （test/db/migration_manager_test.dart），30 条里有 7 条跑不过。成因就三类：
///
/// 1. `CREATE INDEX` / `CREATE TRIGGER` 忘了 `IF NOT EXISTS`（同文件的
///    `CREATE TABLE` 反倒写了）——v1、v2；
/// 2. `ALTER TABLE ADD COLUMN` 没先查 `PRAGMA table_info`——v13、v14、v15
///    （v18、v19 手抄过一份检查，抄的次数多了就该收口）；
/// 3. 种子数据直接 `INSERT`，重跑撞 UNIQUE——v4。
///
/// 幂等本身不是为了让迁移"可以随便重跑"：正常路径上有 `user_version` 闸门，
/// 每条只会跑一次。它是为了在**版本号与实际 schema 对不上**的时候（
/// `DatabaseService._ensureDownloadCategorySchema` 的注释承认这种状态发生过）
/// 还能被救回来，而不是每次启动都撞同一句 `duplicate column name`。
///
/// ⛔ 加列之后紧跟着的**回填**不能无条件跑。典型反例是 v14：它按创建时间给
/// 收藏夹重排 `display_order`，如果在列已存在的库上重跑，会把用户自己调过的
/// 顺序整个冲掉。所以 [addColumnIfMissing] 返回「这次是不是真的加了」，
/// 回填只在返回 true 时做。
library;

import 'package:sqlite3/common.dart';

/// 表上是否已有这一列。表不存在时返回 false。
bool hasColumn(CommonDatabase db, String table, String column) {
  // table_info 对不存在的表返回空结果集，不抛异常。
  for (final row in db.select("PRAGMA table_info('$table')")) {
    if (row['name'] == column) return true;
  }
  return false;
}

/// 缺列才加。
///
/// 返回 **这次调用是否真的加了列**——调用方常常需要区分「刚加上」和「本来就有」：
/// 只有前者才该跑紧随其后的一次性回填。见本文件顶部关于 v14 的说明。
///
/// [definition] 是列名之后的那段，例如 `'TEXT'`、`'INTEGER NOT NULL DEFAULT 0'`。
bool addColumnIfMissing(
  CommonDatabase db,
  String table,
  String column,
  String definition,
) {
  if (hasColumn(db, table, column)) return false;
  db.execute('ALTER TABLE $table ADD COLUMN $column $definition;');
  return true;
}

/// 表是否存在。
bool tableExists(CommonDatabase db, String table) {
  final rows = db.select(
    "SELECT name FROM sqlite_master WHERE type='table' AND name = ?;",
    [table],
  );
  return rows.isNotEmpty;
}
