import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v24：给本地库的「按名称分页」补两条真正用得上的索引。
///
/// # ⛔ v23 那三条索引一条都排不动这个 ORDER BY
///
/// v23 建的是 `(source_id, missing, sort_name)` 一族。而列表实际发出去的是：
///
/// ```sql
/// SELECT * FROM local_media_items
///  WHERE kind = ? AND source_id = ? AND missing = 0
///  ORDER BY sort_name ASC, name ASC, id ASC
///  LIMIT ? OFFSET ?
/// ```
///
/// 两处对不上，各自致命：
///
/// 1. **`kind` 不在索引里**，而它在 WHERE 的每一条查询里都出现（列表只要视频）。
/// 2. **`name` / `id` 不在索引里**，而它们是 ORDER BY 的一部分——那条 `id` 兜底
///    不是可有可无的，去掉它分页就会重复/漏行（见 `LocalMediaRepository._orderBy`）。
///
/// 结果是 SQLite 退回 `USE TEMP B-TREE FOR ORDER BY`：**每翻一页都把整个匹配集
/// 重排一遍**，OFFSET 一点忙都帮不上。不带 `source_id` 的「全部」那一支更糟，
/// 直接 `SCAN local_media_items` 全表。
///
/// 而 sqlite3 是**同步** API，这些全落在 UI 线程上；`PlaybackQueue.ensureContains`
/// 一次最多连发 8 个 `loadMore()`，正好卡在换片那一刻。
///
/// 实测（`EXPLAIN QUERY PLAN`，同一份 schema）：
///
/// ```
/// 建索引前：SEARCH ... USING INDEX idx_local_items_modified + USE TEMP B-TREE FOR ORDER BY
///          SCAN local_media_items                          + USE TEMP B-TREE FOR ORDER BY   ← 「全部」
/// 建索引后：SEARCH ... USING INDEX idx_local_items_page_name                                 ← 无临时 B 树
///          SEARCH ... USING COVERING INDEX idx_local_items_page_name_all                     ← countItems 顺带变成覆盖扫描
/// ```
///
/// # 为什么是新的一版而不是改 v23
///
/// 已经跑过 v23 的机器 `user_version` 停在 23，改 v23 的建表语句对它们不会重放。
/// 索引是纯增量的东西，单独一版最省心（`IF NOT EXISTS`，重复执行无害）。
///
/// # 为什么不给另外四档排序也各补一条
///
/// 「最近添加 / 最近修改 / 时长 / 大小」都是 `xx DESC, id ASC` 这种**混方向**的
/// 排序，一条普通索引排不动，得按方向声明。而今天所有调用点（卡片墙、「接着看」
/// 抽屉、沉浸面板）走的都是 `nameAsc`——本机文件多半是一整季躺在一个目录里，
/// 自然序才是用户要的那个顺序。等哪一档真的被用起来了再按需补，先建四条没人走的
/// 索引只会拖慢每一次扫描写入。
class MigrationV24LocalMediaPagingIndex extends Migration {
  @override
  int get version => 24;

  @override
  String get description => '本地库按名称分页的两条索引（消掉 TEMP B-TREE 与全表扫描）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v24：本地库分页索引');

    // 限定某个源（卡片墙、「接着看」里选了某个源、以及带 folder_path 的那一支：
    // 前三列等值命中之后按 sort_name 顺序扫，folder_path 当过滤条件，顺序不破）。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_name
        ON local_media_items(kind, source_id, missing, sort_name, name, id);
    ''');

    // 不限定源的「全部」那一支。没有它这条查询是整表 SCAN。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_name_all
        ON local_media_items(kind, missing, sort_name, name, id);
    ''');

    LogUtils.i('已应用迁移v24：本地库分页索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v24');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_name;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_name_all;');
    LogUtils.i('已回滚迁移v24：本地库分页索引已删除');
  }
}
