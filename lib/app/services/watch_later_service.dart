import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

/// 一次「加入稍后再看」的结果。
enum WatchLaterAddResult {
  /// 成功加入。
  added,

  /// 已经在列表里了（重复添加不报错，也不刷新加入时间）。
  alreadyExists,

  /// 写库失败。
  failed,
}

/// 「稍后再看」的本地队列。
///
/// # 它和「本地收藏」的分工
///
/// 本地收藏是**长期保存**（多文件夹、可分类、可打标签）；稍后再看是**临时
/// 队列**（有上限、会淘汰、带看完没看完）。所以是两张表、两套服务，不共用。
///
/// # ⛔ 三条不能忘的规则
///
/// 1. **只有应用在前台的观看才写 `watched`**（[_isForeground]）。后台挂着自动
///    连播划过的不算——否则 [_enforceCapacity] 会把用户从没真看过的东西当成
///    "已看完"静默淘汰掉。
/// 2. **失效只标记、不自动删**（[markInvalid]）。点一下东西就消失，在没有
///    undo 的情况下很惊悚。
/// 3. **淘汰在写路径跑**（[_enforceCapacity] 由 [_insert] 调用），不要在读路径
///    算——读路径每次都算一遍 500 条的排序纯属浪费。
class WatchLaterService extends GetxService {
  static WatchLaterService get to => Get.find();

  static const String _tag = 'WatchLaterService';

  /// 容量上限。满了静默淘汰，淘汰序见 [_enforceCapacity]。
  static const int capacity = 500;

  /// 判定「看完」的两条线，满足其一即可：
  /// 进度 ≥90%，或剩余不足 10 秒（长视频的片尾字幕不该拖着不算看完）。
  static const int watchedPermilThreshold = 900;
  static const Duration watchedRemainingThreshold = Duration(seconds: 10);

  late final CommonDatabase _db;

  /// 前台判定。生产走 [WidgetsBinding]；测试注入固定值。
  final bool Function() _isForeground;

  /// 任何写操作后自增，供列表页/卡片菜单跟着刷新。
  ///
  /// ⚠️ 订阅方请用 `rxEver` 而不是 GetX 的 `ever`——后者走 stream，取消一次
  /// 订阅之后会永久收不到（本项目踩过：「下载完成不进历史区」）。
  final RxInt watchLaterChangedNotifier = 0.obs;

  /// [database] 仅供测试注入内存库；生产走 [DatabaseService] 的单例连接。
  WatchLaterService({CommonDatabase? database, bool Function()? isForeground})
    : _isForeground = isForeground ?? _defaultForegroundCheck {
    _db = database ?? DatabaseService().database;
  }

  static bool _defaultForegroundCheck() {
    // 首帧之前 lifecycleState 还是 null，此时按前台处理：拿不准时宁可记下这次
    // 观看，也好过永远不记。真正要挡的是 paused / hidden / detached。
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null ||
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
  }

  int get _nowSeconds => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // ---------------------------------------------------------------- 查询

  /// 这一条在不在稍后再看里。走 `UNIQUE(item_id,item_type)` 索引，O(1)。
  bool contains(String itemId, WatchLaterItemType itemType) {
    try {
      final rows = _db.select(
        'SELECT 1 FROM watch_later WHERE item_id = ? AND item_type = ? LIMIT 1',
        [itemId, itemType.name],
      );
      return rows.isNotEmpty;
    } catch (e) {
      LogUtils.e('查询稍后再看状态失败', tag: _tag, error: e);
      return false;
    }
  }

  /// 分页查询。
  ///
  /// [itemType] 为 null 时不按类型过滤（列表页现在是硬分两个 tab，用不到，但
  /// 抽屉之外的调用点可能需要全量）。
  /// [unwatchedOnly] 对应列表页那行 `全部 | 未看完`。
  /// [excludeExternal] 供播放器抽屉用：站外视频在内置播放器里播不了，留在连播
  /// 队列里只会让连播链撞上跨站 301 断掉。
  List<WatchLaterItem> query({
    WatchLaterItemType? itemType,
    bool unwatchedOnly = false,
    bool excludeExternal = false,
    bool excludeInvalid = false,
    WatchLaterSort sort = WatchLaterSort.recentlyAdded,
    int? limit,
    int offset = 0,
  }) {
    try {
      final where = <String>[];
      final args = <Object?>[];
      if (itemType != null) {
        where.add('item_type = ?');
        args.add(itemType.name);
      }
      if (unwatchedOnly) where.add('watched_at IS NULL');
      if (excludeExternal) where.add('is_external = 0');
      if (excludeInvalid) where.add('invalid_at IS NULL');

      final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
      final direction = sort == WatchLaterSort.recentlyAdded ? 'DESC' : 'ASC';
      // added_at 可能同秒（批量加入），拿自增 id 做次级键保证顺序稳定，
      // 否则分页翻页时会出现重复/漏项。
      final orderClause = 'ORDER BY added_at $direction, id $direction';
      final limitClause = limit == null ? '' : 'LIMIT ? OFFSET ?';
      if (limit != null) {
        args
          ..add(limit)
          ..add(offset);
      }

      final rows = _db.select(
        'SELECT * FROM watch_later $whereClause $orderClause $limitClause',
        args,
      );
      return rows.map((row) => WatchLaterItem.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('查询稍后再看列表失败', tag: _tag, error: e);
      return const <WatchLaterItem>[];
    }
  }

  int count({WatchLaterItemType? itemType, bool unwatchedOnly = false}) {
    try {
      final where = <String>[];
      final args = <Object?>[];
      if (itemType != null) {
        where.add('item_type = ?');
        args.add(itemType.name);
      }
      if (unwatchedOnly) where.add('watched_at IS NULL');
      final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
      final rows = _db.select(
        'SELECT COUNT(*) AS c FROM watch_later $whereClause',
        args,
      );
      return (rows.first['c'] as int?) ?? 0;
    } catch (e) {
      LogUtils.e('统计稍后再看数量失败', tag: _tag, error: e);
      return 0;
    }
  }

  // ---------------------------------------------------------------- 写入

  WatchLaterAddResult addVideo(Video video) {
    final item = WatchLaterItem.fromVideo(video);
    final result = _insert(item);
    // 站外视频在内置播放器里播不了，加入那一刻就当作"看过了"——它不该在
    // 「未看完」里排队等一个永远不会发生的播放。
    if (result == WatchLaterAddResult.added && item.isExternal) {
      _markWatchedInternal(item.itemId, item.itemType, permil: 1000);
    }
    return result;
  }

  WatchLaterAddResult addImageModel(ImageModel image) =>
      _insert(WatchLaterItem.fromImageModel(image));

  WatchLaterAddResult _insert(WatchLaterItem item) {
    try {
      if (contains(item.itemId, item.itemType)) {
        return WatchLaterAddResult.alreadyExists;
      }
      _db.execute(
        '''
        INSERT INTO watch_later
          (item_id, item_type, title, thumbnail_url, author, author_id,
           author_username, duration_ms, num_images, is_external,
           external_domain, added_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          item.itemId,
          item.itemType.name,
          item.title,
          item.thumbnailUrl,
          item.author,
          item.authorId,
          item.authorUsername,
          item.durationMs,
          item.numImages,
          item.isExternal ? 1 : 0,
          item.externalDomain,
          _nowSeconds,
        ],
      );
      // 新入池的条目进度从 0 起。上一轮留下的高水位不清掉的话，
      // [_updateProgressInternal] 会一路 `permil <= lastWritten` 提前返回，
      // 直到重看超过上次的进度为止——中间这段等于没在记进度。
      _lastWrittenPermil.remove('${item.itemType.name}:${item.itemId}');
      _enforceCapacity();
      _notifyChanged();
      return WatchLaterAddResult.added;
    } catch (e) {
      LogUtils.e('加入稍后再看失败', tag: _tag, error: e);
      return WatchLaterAddResult.failed;
    }
  }

  bool remove(String itemId, WatchLaterItemType itemType) {
    try {
      _db.execute(
        'DELETE FROM watch_later WHERE item_id = ? AND item_type = ?',
        [itemId, itemType.name],
      );
      _notifyChanged();
      return true;
    } catch (e) {
      LogUtils.e('从稍后再看移除失败', tag: _tag, error: e);
      return false;
    }
  }

  /// 把刚删掉的一条放回去（列表页滑动删除的「撤销」）。
  ///
  /// 连**加入时间**一起还原，不是当成新条目重新加——否则撤销之后它会跑到列表
  /// 顶端，用户会以为自己弄乱了顺序。观看进度与失效标记同理。
  bool restore(WatchLaterItem item) {
    try {
      _db.execute(
        '''
        INSERT OR REPLACE INTO watch_later
          (item_id, item_type, title, thumbnail_url, author, author_id,
           author_username, duration_ms, num_images, is_external,
           external_domain, added_at, watched_at, progress_permil, invalid_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          item.itemId,
          item.itemType.name,
          item.title,
          item.thumbnailUrl,
          item.author,
          item.authorId,
          item.authorUsername,
          item.durationMs,
          item.numImages,
          item.isExternal ? 1 : 0,
          item.externalDomain,
          item.addedAt.millisecondsSinceEpoch ~/ 1000,
          item.watchedAt == null
              ? null
              : item.watchedAt!.millisecondsSinceEpoch ~/ 1000,
          item.progressPermil,
          item.invalidAt == null
              ? null
              : item.invalidAt!.millisecondsSinceEpoch ~/ 1000,
        ],
      );
      // 撤销把进度一起还原了，去重水位得跟着回到那个值（同 [_insert] 的道理）。
      _lastWrittenPermil.remove('${item.itemType.name}:${item.itemId}');
      _notifyChanged();
      return true;
    } catch (e) {
      LogUtils.e('撤销移除失败', tag: _tag, error: e);
      return false;
    }
  }

  /// 批量移除（列表页的批量选择态）。整批走一个事务，避免删一半失败。
  int removeAll(Iterable<WatchLaterItem> items) {
    final targets = items.toList(growable: false);
    if (targets.isEmpty) return 0;
    try {
      _db.execute('BEGIN TRANSACTION;');
      try {
        final stmt = _db.prepare(
          'DELETE FROM watch_later WHERE item_id = ? AND item_type = ?',
        );
        try {
          for (final item in targets) {
            stmt.execute([item.itemId, item.itemType.name]);
          }
        } finally {
          stmt.close();
        }
        _db.execute('COMMIT;');
      } catch (e) {
        _db.execute('ROLLBACK;');
        rethrow;
      }
      _notifyChanged();
      return targets.length;
    } catch (e) {
      LogUtils.e('批量移除稍后再看失败', tag: _tag, error: e);
      return 0;
    }
  }

  /// 「一键清除已看完」。返回清掉的条数。
  int clearWatched({WatchLaterItemType? itemType}) {
    try {
      final args = <Object?>[];
      var sql = 'DELETE FROM watch_later WHERE watched_at IS NOT NULL';
      if (itemType != null) {
        sql += ' AND item_type = ?';
        args.add(itemType.name);
      }
      final before = _db.select(
        'SELECT COUNT(*) AS c FROM watch_later WHERE watched_at IS NOT NULL'
        '${itemType == null ? '' : ' AND item_type = ?'}',
        itemType == null ? const [] : [itemType.name],
      );
      final removed = (before.first['c'] as int?) ?? 0;
      _db.execute(sql, args);
      if (removed > 0) _notifyChanged();
      return removed;
    } catch (e) {
      LogUtils.e('清除已看完条目失败', tag: _tag, error: e);
      return 0;
    }
  }

  // ---------------------------------------------------------- 观看状态回写

  /// 播放器每隔一段时间上报一次进度；这里是「看完没看完」的**唯一**判定点。
  ///
  /// ⛔ 应用不在前台时**不写 `watched`**（但进度照记）：后台挂着自动连播划过
  /// 的一批视频，如果都被记成"看完"，[_enforceCapacity] 会把它们当成可淘汰项
  /// 静默清掉——用户回来会发现稍后再看自己少了东西。
  void reportPlaybackProgress({
    required String videoId,
    required Duration position,
    required Duration duration,
  }) {
    if (duration.inMilliseconds <= 0) return;
    final permil = ((position.inMilliseconds / duration.inMilliseconds) * 1000)
        .round()
        .clamp(0, 1000);
    final remaining = duration - position;
    final reachedEnd =
        permil >= watchedPermilThreshold || remaining <= watchedRemainingThreshold;

    if (reachedEnd && _isForeground()) {
      _markWatchedInternal(videoId, WatchLaterItemType.video, permil: permil);
    } else {
      _updateProgressInternal(videoId, WatchLaterItemType.video, permil);
    }
  }

  /// 图库没有连续进度可言：打开详情页即已看。
  void markGalleryOpened(String galleryId) {
    if (!_isForeground()) return;
    _markWatchedInternal(galleryId, WatchLaterItemType.image, permil: 1000);
  }

  /// 撞到「私有无权限 / 已删除」时打点。
  ///
  /// 同时标已看完：这一条永远不会被真正看完，留在「未看完」里排队没有意义。
  /// **只标记不删除**——列表页会把它画成灰卡片 + 「已失效」角标，删不删由用户定。
  void markInvalid(String itemId, WatchLaterItemType itemType) {
    try {
      final now = _nowSeconds;
      _db.execute(
        '''
        UPDATE watch_later
        SET invalid_at = COALESCE(invalid_at, ?),
            watched_at = COALESCE(watched_at, ?)
        WHERE item_id = ? AND item_type = ?
        ''',
        [now, now, itemId, itemType.name],
      );
      _notifyChanged();
    } catch (e) {
      LogUtils.e('标记稍后再看失效失败', tag: _tag, error: e);
    }
  }

  /// 这一条又能正常打开了：把失效标记摘掉。
  ///
  /// ⛔ 有这条恢复路径才敢在 404 上打失效标记。CDN / 边缘节点的瞬时 404 并不
  /// 罕见，而失效标记会让卡片变灰、还把它从「未看完」里踢出去——没有恢复手段
  /// 的话，一次抖动就把用户的条目永久废掉了。
  void clearInvalid(String itemId, WatchLaterItemType itemType) {
    try {
      _db.execute(
        'UPDATE watch_later SET invalid_at = NULL '
        'WHERE item_id = ? AND item_type = ? AND invalid_at IS NOT NULL',
        [itemId, itemType.name],
      );
      if (_db.updatedRows > 0) _notifyChanged();
    } catch (e) {
      LogUtils.e('清除失效标记失败', tag: _tag, error: e);
    }
  }

  /// 标记已看完。
  ///
  /// ⛔ **只在真的发生了「未看完 → 已看完」这次跃迁时才推通知**。
  ///
  /// 这条路径挂在播放器的 position 流上，视频过了 90% 之后**每一次位置回调**
  /// 都会走到这里。早先版本无条件 `_notifyChanged()`，于是一条 60 分钟的视频
  /// 在最后 6 分钟里会以每秒数次的频率推 notifier —— 而每一次都会连锁触发
  /// 「稍后再看池重查 DB + 详情页整页 setState + 列表页重查」。不在表里的视频
  /// （UPDATE 命中 0 行）同样会推，等于全 App 所有播放都在交这份税。
  void _markWatchedInternal(
    String itemId,
    WatchLaterItemType itemType, {
    required int permil,
  }) {
    try {
      // 只挑「还没标过」的行更新，`updatedRows` 就直接告诉我们有没有跃迁。
      _db.execute(
        '''
        UPDATE watch_later
        SET watched_at = ?, progress_permil = ?
        WHERE item_id = ? AND item_type = ? AND watched_at IS NULL
        ''',
        [_nowSeconds, permil, itemId, itemType.name],
      );
      final transitioned = _db.updatedRows > 0;

      if (!transitioned) {
        // 已经标过了：进度还是要往前推，但这不值得惊动任何人。
        _updateProgressInternal(itemId, itemType, permil);
        return;
      }
      _notifyChanged();
    } catch (e) {
      LogUtils.e('标记已看完失败', tag: _tag, error: e);
    }
  }

  /// 上次写进去的进度，按 `类型:id` 记。
  ///
  /// position 流每几百毫秒回调一次，而千分比在长视频上要好几秒才动一格——
  /// 不挡一道的话就是每秒好几条"值没变也照写"的 UPDATE。
  final Map<String, int> _lastWrittenPermil = <String, int>{};

  void _updateProgressInternal(
    String itemId,
    WatchLaterItemType itemType,
    int permil,
  ) {
    final cacheKey = '${itemType.name}:$itemId';
    final lastWritten = _lastWrittenPermil[cacheKey];
    if (lastWritten != null && permil <= lastWritten) return;
    _lastWrittenPermil[cacheKey] = permil;
    try {
      // 进度只往前推，不回退：用户拖回开头重看一段，不该把卡片上的进度条抹掉。
      _db.execute(
        '''
        UPDATE watch_later
        SET progress_permil = MAX(progress_permil, ?)
        WHERE item_id = ? AND item_type = ?
        ''',
        [permil, itemId, itemType.name],
      );
      // 命中 0 行 = 这一条已经不在池里了（被移除 / 一键清已看完 / 超容量淘汰）。
      // 顺手把缓存键摘掉，让这份 map 自己收敛，而不用去四个删除出口各补一刀。
      if (_db.updatedRows == 0) _lastWrittenPermil.remove(cacheKey);
    } catch (e) {
      LogUtils.e('更新观看进度失败', tag: _tag, error: e);
    }
  }

  // ---------------------------------------------------------------- 淘汰

  /// 超出 [capacity] 时静默淘汰。
  ///
  /// 淘汰序 `watched_at IS NULL ASC, added_at ASC`：
  /// **先淘汰已看完的**（SQLite 里 false=0 排在 true=1 前面，所以
  /// `watched_at IS NULL` 为 0 的——即已看完的——先出列），同组内最旧优先。
  /// 纯 FIFO 会静默删掉用户攒了很久还没看的那一条，是这个功能最伤的失败模式。
  void _enforceCapacity() {
    try {
      _db.execute(
        '''
        DELETE FROM watch_later
        WHERE id IN (
          SELECT id FROM watch_later
          ORDER BY (watched_at IS NULL) ASC, added_at ASC, id ASC
          LIMIT MAX(0, (SELECT COUNT(*) FROM watch_later) - ?)
        )
        ''',
        [capacity],
      );
    } catch (e) {
      LogUtils.e('稍后再看容量淘汰失败', tag: _tag, error: e);
    }
  }

  void _notifyChanged() => watchLaterChangedNotifier.value++;
}
