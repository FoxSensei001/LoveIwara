import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/downloaded_gallery_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 「下载完成图库」那一栏：应用下载过的图库，一格一个。
///
/// # ⛔ 图库读的是**下载任务表**，不是本地库
///
/// 2026-09-11 拍板（用户选的 B 案）。本机文件的其它几栏都走 `local_media_items`，
/// 图库不走，理由是它根本没在里面：[DownloadsLibrarySyncService] 只收
/// `completedVideoTasks`，图库任务的 `save_path` 指向一个**文件夹**而不是文件。
///
/// 让同步服务把图库也摊进本地库是评估过的另一条路（A 案），被否掉的理由有两条，
/// 任一条单独都够：
///
/// 1. **一个 200 张的图库会把「所有图片」那面墙冲垮**。用户在那一栏想看的是自己
///    机器里的照片，前两屏却全是某个下载图库的内页。
/// 2. **同步成本从"每个任务 1 次 stat"涨到"1 次 listdir + M 次 stat"**，而这套
///    全量同步是每次打开本页都跑一次的，sqlite3 和文件 IO 全落在主 isolate 上。
///
/// 代价是图库拿不到本地库那套能力（单张图收藏、观看进度、按分辨率排序）——
/// 那些能力作用在"一个下载好的图库"上本来也没什么意义。
///
/// # 这份数据现在有**两个**去处
///
/// 2026-09-11 晚：用户报「割裂」——「文件目录 › 已下载」里只有视频没有图库，
/// 明明两者是同一批下载来的东西。所以 `local_folder_browse_page` 在「已下载」
/// 这个源的根层也画同一批图库（`_loadDownloadedGalleries`），一格一个，点开去
/// 同一个详情页。⛔ 它同样**只读任务表**，上面那两条否决理由一字未变。
///
/// 两处共用 [DownloadedGalleryRow] / [DownloadedGalleryCard]（在
/// `downloaded_gallery_card.dart`）。⛔ 卡片长什么样、封面怎么取、脏 ext_data
/// 怎么丢——只能在那一处改，别在这儿再抄一份。
///
/// 这一栏与那一处的分工：这一栏**分页**、装得下全部；那一处是顺带展示，硬上限
/// 500 条。
///
/// # ⛔ 卡片必须是**容器卡**
///
/// 一个图库是「点进去还有东西」的容器，和目录卡、来源卡同族（见
/// [LocalContainerCard] 的类注释：差异做在形状上，不是文字上）。别拿媒体卡画它
/// ——那会让用户以为点下去直接是一张图。
class DownloadedGalleryWall extends StatefulWidget {
  const DownloadedGalleryWall({super.key, required this.headerExtent});

  final double headerExtent;

  @override
  State<DownloadedGalleryWall> createState() => _DownloadedGalleryWallState();
}

class _DownloadedGalleryWallState extends State<DownloadedGalleryWall> {
  static const String _tag = 'DownloadedGalleryWall';
  static const int _pageSize = 60;

  final ScrollController _scrollController = ScrollController();
  final List<DownloadedGalleryRow> _rows = <DownloadedGalleryRow>[];

  int _offset = 0;
  bool _loading = false;
  bool _exhausted = false;

  /// 每次 [_reload] 自增。在途的那一次取数拿着旧号回来时，靠它整只作废。
  ///
  /// ⛔ 只判 `mounted` 不够：下拉刷新把 `_rows`/`_offset` 归零时，上一次
  /// `getCompletedDownloadTasks` 可能还在飞。它回来时 widget 当然还挂着，
  /// 于是旧那一页会被推进刚归零的游标、塞进刚清空的列表，还顺手把新那一次
  /// 持有的 `_loading` 闸门放掉。
  int _generation = 0;

  /// 首屏还没回来。⛔ 与 `_rows.isEmpty` 不是一回事：这一栏取数是**真异步**的
  /// （`getCompletedDownloadTasks` 走 await），不分清楚的话，加载那一瞬间会先闪
  /// 一屏「还没有下载完成的图库」再换成内容。
  bool _firstLoadPending = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(_loadMore());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600 &&
        !_loading &&
        !_exhausted) {
      unawaited(_loadMore());
    }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    _generation++;
    setState(() {
      _rows.clear();
      _offset = 0;
      _exhausted = false;
      _loading = false;
      _firstLoadPending = true;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _exhausted) return;
    _loading = true;
    final generation = _generation;
    try {
      if (!Get.isRegistered<DownloadService>()) {
        _exhausted = true;
        return;
      }
      final tasks = await DownloadService.to.repository
          .getCompletedDownloadTasks(
            offset: _offset,
            limit: _pageSize,
            mediaType: 'gallery',
          );
      if (!mounted || generation != _generation) return;
      // ⛔ 游标按**这一页取回来的原始条数**推进，不是按 `_rows` 涨了多少：下面
      // 会丢掉解析不出 ext_data 的脏行，拿过滤后的条数推进会让那几条的位置被
      // 反复重取，翻页原地打转。
      _offset += tasks.length;
      if (tasks.length < _pageSize) _exhausted = true;
      _rows.addAll(tasks.map(DownloadedGalleryRow.of).nonNulls);
      setState(() => _firstLoadPending = false);
    } catch (e, s) {
      LogUtils.e('读取已下载图库失败', tag: _tag, error: e, stackTrace: s);
      if (!mounted || generation != _generation) return;
      setState(() => _firstLoadPending = false);
      _exhausted = true;
    } finally {
      // ⛔ 只放自己那一轮的闸门：作废的那一次放掉的会是**新一轮**持有的。
      if (generation == _generation) _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = LocalGridMetrics.resolve(
          availableWidth: constraints.maxWidth - 32,
          maxCellWidth: 260,
        );
        return RefreshIndicator(
          displacement: widget.headerExtent,
          onRefresh: _reload,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SizedBox(height: widget.headerExtent + 12),
              ),
              if (_rows.isEmpty && !_firstLoadPending)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmpty(context),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: metrics.delegate(
                      DownloadedGalleryCard.extentFor(
                        context,
                        metrics.cellWidth,
                      ),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final row = _rows[index];
                        return DownloadedGalleryCard(
                          row: row,
                          onDeleted: () {
                            if (mounted) {
                              setState(() {
                                _rows.removeWhere((e) => e.taskId == row.taskId);
                              });
                            }
                          },
                        );
                      },
                      childCount: _rows.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              slang.t.localMedia.browse.emptyDownloadedGalleries,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
