import 'dart:async';

import 'package:sqlite3/common.dart';

/// 迁移基类
///
/// # ⛔ 这里没有 `down()`，而且不该再加回来
///
/// 2026-09-11 之前每个子类都被强制实现一份 `down()`，31 个文件各写了一段回滚
/// SQL。全仓库只有一处调用，还是在测试里拿它做清理。删掉的理由有三条，一条比
/// 一条硬：
///
/// 1. **降级在这个架构里不可能实现。** 降级意味着运行旧版二进制，而旧版里压根
///    没有新迁移的 `down()` 代码。装回旧版的正解已经写在
///    [MigrationManager.runMigrations] 里了——`user_version` 高于已知最高版本
///    时什么都不做 + 告警，那才是这个架构对降级的回答。
/// 2. **那 31 份 SQL 已经错了，只是没人看得见。** 其中 17 份在 `down()` 里写
///    `PRAGMA user_version = N-1`，而版本号由 manager 统一负责这条契约早就立了
///    （见 [MigrationManager.runMigrations] 的文档）。一半的实现遵守着一个废除
///    已久的约定，八个月没人发现——因为它们从不执行。
/// 3. **它们是未测试代码。** 灾难现场里，未测试的回滚 SQL 比没有回滚 SQL 更
///    危险，因为它会被信任。
///
/// 「改成非抽象的默认空实现」也不行：那是把「你忘了写 down()」静默换成
/// 「down() 什么都不做」，正是这个模块一直在消灭的那类沉默失败。
///
/// 真要删表，就在需要的地方写那一句 `DROP TABLE`——CREATE 就在二十行开外。
abstract class Migration {
  /// 迁移版本
  ///
  /// ⛔ 新迁移必须**大于当前最大值**，绝不能回填历史空洞：
  /// [MigrationManager.runMigrations] 只跑 `version > user_version` 的迁移，
  /// 回填的那条在版本号已经越过它的设备上永远不会执行，且不报错。
  int get version;

  /// 迁移描述。会出现在失败时抛出的异常消息里，写得具体一点。
  String get description;

  /// 执行迁移操作（允许同步或异步实现）。
  ///
  /// ⛔ **必须幂等**：在一个已经套用过它的库上重跑不许抛错，也不许改坏数据。
  /// 正常路径上有 `user_version` 闸门保证只跑一次，幂等是为了版本号与实际
  /// schema 对不上时还能被救回来。可用的原语见 `migration_sql.dart`
  /// （`addColumnIfMissing` / `tableExists`）。
  /// test/db/migration_manager_test.dart 里有一条闸门逐条验这件事。
  FutureOr<void> up(CommonDatabase db);
}
