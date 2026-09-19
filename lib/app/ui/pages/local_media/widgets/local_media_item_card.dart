import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/local_media/local_vr_hints.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_image_thumb.dart';
import 'package:i_iwara/app/utils/local_vr_filename_detector.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 本机文件浏览页里的一个媒体条目：视频是「封面 + 标题 + 出处」，图片是一格纯方图。
///
/// 本地文件不是一个缺少网络字段的 `Video`：扫描来的文件没有作者、官方标题或远端
/// 封面，所以这里直接用文件语义排版。下载条目才通过 `download_task_id` 补上任务
/// 保存的元数据作为装饰，不把假造的线上模型塞进线上操作菜单。
///
/// # ⛔ 这里没有 ⋮，长按也不是预览
///
/// 曾经有过：卡片右下角一枚 ⋮（预览 / 移到分类），长按整卡弹一张信息弹窗。两个都
/// 是把**下载列表**的语义搬到了本机文件上——「分类」是下载任务的收纳维度，本机文件
/// 只是磁盘上的文件，不归任何分类管；而那张预览弹窗里的时长 / 体积 / 分辨率，本来
/// 就该直接印在卡片上，用一次弹窗去换它们是白绕一圈。
///
/// 所以信息全部前移到卡面，**点击＝播放**。菜单里剩下的是文件管理器本来就该有的
/// 动作（设置封面 / 删除），由调用方决定，卡片自己不决定弹什么。
///
/// # ⛔ 别长得像文件夹
///
/// 2026-09-11 用户原话：「文件夹和视频的卡片长得好像啊，不然用户分不清」。那之后
/// 试过把外形分家（夹子剪影 vs 顶到边的封面），2026-09-19 用户选了统一成线上视频
/// 卡同款外壳（[LocalCardShell]）；同日用户又嫌差异不够，容器卡加了叠纸轮廓。
/// 所以区分由这几处记号承担，**都别拿掉**：
///
/// - 容器卡背后有两层纸边、封面右下是「文件夹 + 项数」胶囊（[LocalContainerCard]）；
/// - 容器卡的标题前有种类图标（文件夹 / NAS / 图库），视频卡没有；
/// - 视频封面右下角**恒有**一枚时长胶囊（拿不到时长就退成一枚播放三角）。这是
///   全世界的播放器都在用的记号，它出现在哪张卡上，哪张卡就是能播的。
///
/// 机器信息（时长 / 画质 / VR / 进度）全在封面角标上，字只剩标题和一行出处。
///
/// # ⛔ 长按必须配一枚看得见的 ⋮
///
/// 只留长按是不行的——**用户根本不知道有这个功能**（2026-09-10 用户原话）。手势是
/// 快捷方式，不是入口；入口得看得见。视频卡的 ⋮ 挂在出处那一行右端，图片格没有
/// 文字行、⋮ 在封面右上角；两者都和长按指向同一个菜单。加了 ⋮ 就别再把长按摘掉：
/// 两者是同一个动作的两种够得着的方式。
///
/// # ⛔ 高度写死，别再回瀑布流
///
/// 原先走瀑布流：有没有作者行、角标换不换行，每张卡高度都不一样，滚动时要逐张
/// layout 才知道下一张摆在哪。现在一张卡＝16:9 封面 + [LocalCardText] 那块定高
/// 文字（两行标题 + 一行说明），总高由 [extentFor] 从格宽算出，网格用
/// `SliverGrid` + `mainAxisExtent` 铺。所以：
///
/// - 说明只有**一行**（作者，没有就写所在文件夹），超出省略，不许加第二行；
/// - 想往卡面上加东西，只能加在封面上（角标），不能加在文字区里。
///
/// # 卡面上不写的东西
///
/// 2026-09-19 用户：「里面是有非必要信息的，也可以移除」。体积、「1920x1080」
/// 这串分辨率、文件扩展名都拿掉了：画质只在够得上 1080P 时做成封面角标，体积在
/// 信息弹窗里。**别再往卡面上加数字**——每加一个，一屏几十张卡就多几十个要读的东西。
class LocalMediaItemCard extends StatefulWidget {
  const LocalMediaItemCard({
    super.key,
    required this.item,
    required this.onOpen,
    this.onMenu,
    this.showFolder = true,
  });

  /// 出处那一行没有作者时写不写所在文件夹。
  ///
  /// 聚合墙（所有视频 / 精选）里写：同名文件散在各处，文件夹就是出处。目录页里
  /// 不写——用户正站在这个文件夹里，那一行改写修改时间。
  final bool showFolder;

  final LocalMediaItem item;

  /// 给定格宽下一格的总高，交给 `LocalGridMetrics.delegate`。
  ///
  /// 图片是纯方图（格高＝格宽），视频是封面 + [LocalCardText]。
  static double extentFor(
    BuildContext context,
    double cellWidth,
    LocalMediaItemKind kind,
  ) => kind == LocalMediaItemKind.image
      ? cellWidth
      : LocalCardShell.extentFor(context, cellWidth);

  final Future<void> Function() onOpen;

  /// 打开这一条的操作菜单。那枚 ⋮ 与长按整卡都走它；不传则两者都没有。
  ///
  /// [BuildContext] 是菜单的锚点：⋮ 传它自己的，长按传卡片的。
  final void Function(BuildContext anchorContext)? onMenu;

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    var index = 0;
    var value = bytes.toDouble();
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    final precision = index == 0
        ? 0
        : value >= 10
        ? 1
        : 2;
    return '${value.toStringAsFixed(precision)} ${units[index]}';
  }

  @override
  State<LocalMediaItemCard> createState() => _LocalMediaItemCardState();
}

class _LocalMediaItemCardState extends State<LocalMediaItemCard> {
  /// 下载任务里存的视频元数据，[_loadDownloadTask] 取回时**解析一次**存下来。
  ///
  /// ⛔ 别改回每次访问现解的 getter：一次 build 要读标题 / 作者 / 远端封面三处，
  /// 就是一张卡三遍 `fromJson`，一屏几十张卡在滚动里反复 build。
  VideoDownloadExtData? _ext;
  LocalMediaItem? _derivedItem;
  bool _derivationRequested = false;

  /// 这张卡现在露在外面吗。
  ///
  /// ⛔ 存下来是因为 [VisibilityDetector] **只在可见性变化时**回调，见
  /// [didUpdateWidget] 里那段。
  bool _visible = false;

  LocalMediaItem get _item => _derivedItem ?? widget.item;

  String get _title {
    final title = _ext?.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    // 扩展名不是标题的一部分：一墙都是 .mp4，写出来只是噪音。
    final name = widget.item.name;
    final stem = p.basenameWithoutExtension(name);
    return stem.isEmpty ? name : stem;
  }

  String? get _author {
    final author = _ext?.authorName?.trim();
    return author == null || author.isEmpty ? null : author;
  }

  String? get _remoteCover {
    final cover = _ext?.thumbnail?.trim();
    return cover == null || cover.isEmpty ? null : cover;
  }

  @override
  void initState() {
    super.initState();
    _loadDownloadTask();
    _loadProgress();
    _progressSub = LocalMediaRepository.progressChanges.listen((id) {
      if (id == '*' || id == widget.item.id) _loadProgress(rebuild: true);
    });
  }

  /// 这一条的观看进度。视频才有；一次主键查询，只在挂上、换条目、进度变了时读。
  ///
  /// 卡片自己读而不是让每个调用点批量传：墙、目录页、预览区好几处在画这张卡，
  /// 让它们各自接一遍，迟早有一处漏掉（见 [[prefer-mechanism-fix-over-per-callsite]]）。
  ({int positionMs, int? durationMs, bool completed})? _progress;
  StreamSubscription<String>? _progressSub;

  void _loadProgress({bool rebuild = false}) {
    if (widget.item.kind != LocalMediaItemKind.video) {
      _progress = null;
      return;
    }
    final next = LocalMediaRepository().getProgress(widget.item.id);
    if (rebuild && mounted) {
      setState(() => _progress = next);
    } else {
      _progress = next;
    }
  }

  /// 0~1；没看过、或看到头了（由「已看完」角标负责）时返回 null。
  double? get _progressFraction {
    final progress = _progress;
    if (progress == null || progress.completed) return null;
    final total = progress.durationMs ?? _item.durationMs;
    if (total == null || total <= 0 || progress.positionMs <= 0) return null;
    return (progress.positionMs / total).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LocalMediaItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ⛔ 父级递来的是**新的一份行快照**（重载、就地替换收藏状态、换了自定义封面）
    // 时，派生快照就过期了：它是更早那一刻的库状态，继续用它会盖住新快照里的
    // 收藏星标与封面路径（旧缩略图文件此时可能已被删掉）。派生结果早已落库，
    // 新快照里本来就带着，丢掉不亏。
    //
    // 只清快照、不复位 [_derivationRequested]：同一条目不需要再排一次派生队列。
    if (!identical(oldWidget.item, widget.item)) _derivedItem = null;
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.downloadTaskId != widget.item.downloadTaskId) {
      _ext = null;
      _derivedItem = null;
      _derivationRequested = false;
      _loadDownloadTask();
      _loadProgress();

      // ⛔ 光把 [_derivationRequested] 放回 false 是不够的，必须**主动**再问一次。
      //
      // [VisibilityDetector] 只在可见性**发生变化**时回调。用户换个排序/筛选时，
      // 这张卡的位置和可见度一点没变（1.0 → 1.0），变的只是它承载的条目——于是
      // 标志虽然复位了，却永远等不到那次回调来读它。
      //
      // 实测（2026-09-10，138 条的库）：切成时长升序后第一屏的 bulk_002~013
      // 一条都没补派生，而滚动新进视野的 bulk_029~033 全部正常。也就是说
      // **每次换排序，第一屏都是不补的那一屏**——偏偏那是用户最先看到的一屏。
      //
      // 只在露在外面时补：列表会在 cacheExtent 内预建一批卡片，那些还没露脸的
      // 不该现在就去排队。
      if (_visible) {
        _derivationRequested = true;
        unawaited(_ensureDerived());
      }
    }
  }

  /// 卡片进入视野时把这一条缺的派生数据补上：封面（sidecar 与缓存缩略图都没有时
  /// 抓一帧）以及时长 / 宽高。
  ///
  /// ⛔ **不能只在"没有封面"时才问**：有 sidecar 的条目照样可能缺时长和分辨率
  /// （扫描器只写文件名、大小、mtime），只看封面的话那两枚角标永远要等下一次
  /// 自然刷新才出得来。
  Future<void> _ensureDerived() async {
    final item = widget.item;
    if (item.missing || !Get.isRegistered<LocalMediaDerivationService>()) {
      return;
    }
    // NAS 条目：原图 / 同名图都在远端，只有拉进本机缓存的那张算「有封面」。
    final hasCover = DavPath.isDav(item.path)
        ? await _fileExists(item.thumbPath)
        : (item.kind == LocalMediaItemKind.image && item.path.isNotEmpty) ||
              await _fileExists(item.sidecarImagePath) ||
              await _fileExists(item.thumbPath);
    // 封面有了、元数据也齐了，这张卡没有要补的——省掉一次派生队列的往返。
    //
    // ⛔ 判据必须走 [LocalMediaItem.needsDerivedMetadata]，不许在这里另写一份：
    // 两边定义一分家，新加的可派生字段就会静默失效（见那个 getter 上的注释）。
    if (hasCover && !item.needsDerivedMetadata) return;

    final updated = await LocalMediaDerivationService.to.ensureDerived(
      item,
      // 到底抓不抓帧由服务按**最新的库状态**判（它会重查 sidecar / 缩略图还在不在），
      // 这里只表达"允许抓"，不在调用点复制一份同样的判断。
      generateThumbnail: true,
    );
    if (!mounted || updated == null || updated.id != widget.item.id) return;
    // 派生结果是行内变化，就地 setState 重绘即可——绝不惊动整面墙。
    setState(() => _derivedItem = updated);
  }

  static Future<bool> _fileExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;
    try {
      return await File(filePath).exists();
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadDownloadTask() async {
    final taskId = widget.item.downloadTaskId;
    if (taskId == null || taskId.isEmpty) return;
    if (!Get.isRegistered<DownloadService>()) return;
    final task = await DownloadService.to.repository.getTaskById(taskId);
    // ⛔ 只判 mounted 不够：卡片会被列表复用去承载别的条目，查询在飞的时候
    // [didUpdateWidget] 可能已经换了 taskId——旧任务的标题就会贴到新条目上。
    if (!mounted || task == null || widget.item.downloadTaskId != taskId) {
      return;
    }
    final ext = task.extData;
    if (ext == null || ext.type != DownloadTaskExtDataType.video) return;
    final VideoDownloadExtData parsed;
    try {
      parsed = VideoDownloadExtData.fromJson(ext.data);
    } catch (_) {
      return;
    }
    setState(() => _ext = parsed);
  }

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  /// 标题下面那一行出处：作者；没有作者时聚合墙写所在文件夹、目录页写修改时间。
  String _sourceLine() {
    final author = _author;
    if (author != null) return author;
    final item = _item;
    // 下载任务按 id 建的文件夹（「407963」）不是人起的名字，写出来只是噪音。
    // 同一个下载目录也可能被当成普通文件夹扫进来（来源不是「已下载」），所以
    // 按「有下载任务」和「名字全是数字」两条判，不按来源判。
    if (widget.showFolder &&
        item.sourceId != kDownloadsSourceId &&
        item.downloadTaskId == null) {
      final folder = p.basename(item.folderPath ?? p.dirname(item.path));
      if (folder.isNotEmpty &&
          folder != '.' &&
          folder != '/' &&
          !_digitsOnly.hasMatch(folder)) {
        return folder;
      }
    }
    final modified = item.modifiedAt;
    if (modified == null || modified <= 0) return '';
    return CommonUtils.formatFriendlyTimestamp(
      DateTime.fromMillisecondsSinceEpoch(modified),
      includeTime: false,
    );
  }

  /// 封面右上角的规格角标：VR 投影、画质。只写够得上说一声的——720P 以下不标，
  /// 标了也只是提醒用户「这个不清楚」，不值一枚角标。
  List<String> _specTags() {
    final item = _item;
    final tags = <String>[];
    final vr = _vrLabel(item.vrFormatJson);
    if (vr != null) tags.add(vr);
    if (item.width != null && item.height != null) {
      final short = math.min(item.width!, item.height!);
      if (short >= 2160) {
        tags.add('4K');
      } else if (short >= 1440) {
        tags.add('2K');
      } else if (short >= 1080) {
        tags.add('1080P');
      }
    }
    return tags;
  }

  String? _vrJson;
  String? _vrLabelCache;

  /// VR 线索是一串 JSON，按原串缓存，别每次 build 都解一遍。
  String? _vrLabel(String? json) {
    if (json == _vrJson) return _vrLabelCache;
    _vrJson = json;
    final hints = LocalVrHints.fromJson(json);
    _vrLabelCache =
        hints == null || hints.strength != LocalVrSignalStrength.strong
        ? null
        : switch (hints.projection) {
            VrProjection.equirect180 => 'VR180',
            VrProjection.equirect360 => 'VR360',
            VrProjection.fisheye => 'VR',
            VrProjection.flat || null => null,
          };
    return _vrLabelCache;
  }

  Widget _coverWithDerivation() {
    final item = _item;
    return VisibilityDetector(
      key: ValueKey<String>('local-media-cover-${item.id}'),
      onVisibilityChanged: (info) {
        // 记下来给 [didUpdateWidget] 用：换条目时得知道这张卡还露不露在外面。
        _visible = info.visibleFraction > 0;
        if (!_visible || _derivationRequested) return;
        _derivationRequested = true;
        unawaited(_ensureDerived());
      },
      child: _Cover(item: item, remoteCover: _remoteCover),
    );
  }

  @override
  Widget build(BuildContext context) => _item.kind == LocalMediaItemKind.image
      ? _buildImageTile(context)
      : _buildVideoCard(context);

  /// 视频：与线上视频卡同一副外壳（[LocalCardShell]），封面上是时长 / 画质 /
  /// 进度，下面是恒占两行的标题和一行出处。
  Widget _buildVideoCard(BuildContext context) {
    final theme = Theme.of(context);
    return LocalCardShell(
      onTap: () => widget.onOpen(),
      onMenu: widget.onMenu,
      title: _title,
      meta: LocalCardText.metaText(context, _sourceLine()),
      cover: Stack(
        fit: StackFit.expand,
        children: <Widget>[_coverWithDerivation(), ..._coverBadges(theme)],
      ),
    );
  }

  /// 图片：一格纯方图，不带任何字。文件名、宽高、体积对「挑一张看」都没用，
  /// 真要看在信息弹窗里。⋮ 没有文字行可挂，放在右上角。
  Widget _buildImageTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Builder(
      builder: (cellContext) => GestureDetector(
        onTap: () => widget.onOpen(),
        onLongPress: widget.onMenu == null
            ? null
            : () => widget.onMenu!(cellContext),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              LocalImageThumb(
                item: _item,
                placeholder: ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (widget.onMenu != null)
                Positioned(
                  top: LocalContainerCard.badgeInset,
                  right: LocalContainerCard.badgeInset,
                  child: LocalCardMenuBadge(onMenu: widget.onMenu!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _coverBadges(ThemeData theme) {
    final tags = _specTags();
    return <Widget>[
      // 看到哪了：封面底边一条细线，看完的换成左下角一枚勾。
      // 这是「回来接着看」在墙上唯一看得见的线索——没有它，用户
      // 只能记住自己看到了哪一集。
      if (_progressFraction case final fraction?)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 3,
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            color: theme.colorScheme.primary,
          ),
        ),
      if (_progress?.completed ?? false)
        Positioned(
          left: 6,
          bottom: 6,
          child: LocalCardBadge(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.check_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      Positioned(
        right: 6,
        bottom: 6,
        child: LocalPlaybackPill(
          duration: _item.durationMs == null
              ? null
              : _formatDuration(_item.durationMs!),
        ),
      ),
      if (tags.isNotEmpty)
        Positioned(
          top: 6,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < tags.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 4),
                LocalCoverTag(label: tags[i]),
              ],
            ],
          ),
        ),
      Positioned(
        top: LocalContainerCard.badgeInset,
        left: LocalContainerCard.badgeInset,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          // 图片没有精选（见 [LocalMediaItem.supportsFavorite]）：
          // 库里若还留着旧的标记，这里也不画——判据只有那一份。
          child: _item.supportsFavorite && _item.favoritedAt != null
              ? LocalCardBadge(
                  key: const ValueKey('favorited_badge'),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('favorited_none')),
        ),
      ),
    ];
  }

  static String _formatDuration(int milliseconds) {
    return CommonUtils.formatDuration(
      Duration(milliseconds: milliseconds.clamp(0, 864000000)),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.item, this.remoteCover});

  final LocalMediaItem item;
  final String? remoteCover;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // ⛔ 挑哪张图只认 [LocalMediaItem.coverImagePath]（自定义封面 > sidecar >
    // 抓帧缓存），别在这里另写一份优先级：原先这里是「sidecar 优先」，用户给
    // 带 sidecar 的视频换了封面，卡片上照旧是 sidecar。
    final cover = item.coverImagePath;
    final thumbnail = item.thumbPath;
    final Widget child;
    if (cover != null && cover.isNotEmpty) {
      child = LocalCoverImage(
        path: cover,
        placeholder: _placeholder(scheme),
        // 首选那张读不出来（sidecar 被挪走之类）时，抓帧缓存还能顶一下。
        errorBuilder: (context) =>
            thumbnail != null && thumbnail.isNotEmpty && thumbnail != cover
            ? LocalCoverImage(
                path: thumbnail,
                placeholder: _remoteOrPlaceholder(scheme),
              )
            : _remoteOrPlaceholder(scheme),
      );
    } else if (remoteCover != null) {
      child = _remote(scheme);
    } else if (item.kind == LocalMediaItemKind.image &&
        item.path.isNotEmpty &&
        !DavPath.isDav(item.path)) {
      child = LocalCoverImage(
        path: item.path,
        placeholder: _placeholder(scheme),
      );
    } else {
      child = _placeholder(scheme);
    }

    return child;
  }

  Widget _remote(ColorScheme scheme) => LayoutBuilder(
    builder: (context, constraints) => CachedNetworkImage(
      imageUrl: remoteCover!,
      fit: BoxFit.cover,
      memCacheWidth: LocalCoverImage.cacheWidthFor(
        context,
        constraints.maxWidth,
      ),
      errorWidget: (_, _, _) => _placeholder(scheme),
    ),
  );

  Widget _remoteOrPlaceholder(ColorScheme scheme) =>
      remoteCover != null ? _remote(scheme) : _placeholder(scheme);

  Widget _placeholder(ColorScheme scheme) => ColoredBox(
    color: scheme.surfaceContainerHighest,
    child: Center(
      child: Icon(
        item.kind == LocalMediaItemKind.image
            ? Icons.image_outlined
            : Icons.movie_outlined,
        color: scheme.onSurfaceVariant,
      ),
    ),
  );
}
