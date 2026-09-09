import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v25：分类升格成**本地库**的组织维度，给它补上唯一那条用得着的索引。
///
/// # 升格是什么意思
///
/// 分类原本是**下载模块**的概念（v18 把 `category_id` 挂在 `download_tasks`
/// 上）。本机源加进来之后若不升格，来源切换里会并排站着两种条目——**下载来的
/// 能分类、拷进来的不能分类**。用户会立刻问为什么，而这个"为什么"没有任何用户
/// 能理解的答案，它只反映了我们的实现顺序（工作线文档 §10.7）。
///
/// 所以权威挪到 `local_media_items.category_id`（列 v23 就留好了，不用加）。
/// 桶本身仍然共用 `download_categories` 表——那只是一张"名字 + 顺序"的表，
/// 跟它是谁建的没关系，再建一张一模一样的才是真的乱。
///
/// # ⛔ 为什么只有一条索引
///
/// 上一轮曾经想顺手把 `download_task_id` 也建上，又删了：`EXPLAIN QUERY PLAN`
/// 证明当时没有任何查询会选到它，而每条索引都要在首扫那 5 万次插入上各交一份钱。
///
/// # ⛔ 列顺序：`source_id` 必须排在 `category_id` 前面
///
/// 第一版写成 `(kind, category_id, missing, …)`，理由是"分类是独立于来源的维度"。
/// 那是**照着一个不存在的查询**设计的：`_loadPage` 在 `sourceId == null` 时直接
/// 返回，分类计数也是按当前来源算的（数字必须和点进去看到的那张墙同口径），
/// 所以**每一条真实查询都带着 `source_id`**。
///
/// 拿 2 万行、v23+v24 索引全在场的库实测（查询逐字照抄调用点发出的那三条）：
///
/// ```
/// (kind, category_id, …)      按分类翻页  SEARCH ... (kind=? AND category_id=? AND missing=?)   ← source_id 退化成逐行回表
///                             未分类那支  SEARCH ... USING INDEX idx_local_items_page_name      ← 根本没选它
///                             分类计数    SEARCH ... (kind=?)                                   ← 非覆盖，扫全库视频行
/// (kind, source_id, category_id, …)
///                             按分类翻页  SEARCH ... (kind=? AND source_id=? AND category_id=? AND missing=?)
///                             未分类那支  同上，一样全约束住
///                             分类计数    SEARCH ... USING COVERING INDEX (kind=? AND source_id=?)
/// ```
///
/// 不筛分类的老查询仍然走 v24 的 `idx_local_items_page_name`，没有被带坏。
///
/// 尾部列顺序照抄 v24 的教训：`ORDER BY sort_name, name, id` 的**兜底列必须都在
/// 索引里**，少一个 SQLite 就退回 `USE TEMP B-TREE FOR ORDER BY`，每翻一页把整个
/// 匹配集重排一遍——而 sqlite3 是同步 API，这些全落在 UI 线程上。
class MigrationV25LocalMediaCategory extends Migration {
  @override
  int get version => 25;

  @override
  String get description => '本地库按分类筛选/计数的索引（分类升格为本地库维度）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v25：本地库分类索引');

    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_category
        ON local_media_items(kind, source_id, category_id, missing, sort_name, name, id);
    ''');

    LogUtils.i('已应用迁移v25：本地库分类索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v25');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_category;');
    LogUtils.i('已回滚迁移v25：本地库分类索引已删除');
  }
}
