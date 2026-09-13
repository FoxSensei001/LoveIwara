import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 本机文件浏览页里的一个视频条目。
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
/// 2026-09-11 用户原话：「文件夹和视频的卡片长得好像啊，不然用户分不清」。目录卡
/// 那边改成了一只夹子（[LocalContainerCard]：翻页舌 + 封面留边 + 带主色的底），
/// 这边则朝反方向拉开：
///
/// - **封面顶到边**，四角只有卡片自己的圆角——封面即内容本身，不是「装在里面的
///   某一件」。
/// - **封面上压一枚时长胶囊**（拿不到时长就退成一枚播放三角）。这是全世界的
///   播放器都在用的记号，它出现在哪张卡上，哪张卡就是能播的。
///
/// 所以时长**不在**下面那排角标里——同一个数字印两遍是白占地方，而印在封面上
/// 才顺带把「这是段视频」也说了。
///
/// # ⛔ 长按必须配一枚看得见的 ⋮
///
/// 只留长按是不行的——**用户根本不知道有这个功能**（2026-09-10 用户原话）。手势是
/// 快捷方式，不是入口；入口得看得见。所以封面右上角常驻一枚 ⋮，和长按指向同一个
/// 菜单。加了 ⋮ 就别再把长按摘掉：两者是同一个动作的两种够得着的方式。
class LocalMediaItemCard extends StatefulWidget {
  const LocalMediaItemCard({
    super.key,
    required this.item,
    required this.onOpen,
    this.width,
    this.onMenu,
  });

  final LocalMediaItem item;

  /// 这一格的宽度。封面的解码尺寸由 [LocalCoverImage] 按实际约束算，不读它。
  final double? width;

  final Future<void> Function() onOpen;

  /// 打开这一条的操作菜单。封面右上角那枚 ⋮ 与长按整卡都走它；不传则两者都没有。
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
    return title == null || title.isEmpty ? widget.item.name : title;
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
    final hasCover =
        (item.kind == LocalMediaItemKind.image && item.path.isNotEmpty) ||
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

  /// 体积 / 分辨率这两枚角标。
  ///
  /// 这些原本只在长按弹出的信息弹窗里，现在直接印在卡面上：一屏能一眼比出
  /// 「哪个是完整片、哪个是几十秒的片段」，比逐个长按有用得多。
  ///
  /// ⛔ 时长不在这里，它在封面上那枚胶囊里（见类文档）。
  List<Widget> _metaChips() {
    final item = _item;
    return <Widget>[
      if (item.sizeBytes != null)
        _MetaChip(
          icon: Icons.storage_outlined,
          label: _formatBytes(item.sizeBytes!),
        ),
      if (item.width != null && item.height != null)
        _MetaChip(
          icon: Icons.aspect_ratio_outlined,
          label: '${item.width}x${item.height}',
        ),
    ];
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
  Widget build(BuildContext context) => _buildCard(context);

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final author = _author;

    return SizedBox(
      width: widget.width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: Builder(
          builder: (cardContext) => InkWell(
            onTap: () => widget.onOpen(),
            onLongPress: widget.onMenu == null
                ? null
                : () => widget.onMenu!(cardContext),
            borderRadius: radius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _coverWithDerivation(),
                    if (_item.kind == LocalMediaItemKind.video)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: _PlaybackPill(
                          duration: _item.durationMs == null
                              ? null
                              : _formatDuration(_item.durationMs!),
                        ),
                      ),
                    Positioned(
                      top: LocalContainerCard.badgeInset,
                      left: LocalContainerCard.badgeInset,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        // 图片没有精选（见 [LocalMediaItem.supportsFavorite]）：
                        // 库里若还留着旧的标记，这里也不画——判据只有那一份。
                        child:
                            _item.supportsFavorite && _item.favoritedAt != null
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
                            : const SizedBox.shrink(
                                key: ValueKey('favorited_none'),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 36,
                        child: Text(
                          _title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(spacing: 8, runSpacing: 4, children: _metaChips()),
                      if (author != null) ...[
                        const SizedBox(height: 7),
                        Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDuration(int milliseconds) {
    return CommonUtils.formatDuration(
      Duration(milliseconds: milliseconds.clamp(0, 864000000)),
    );
  }

  static String _formatBytes(int bytes) =>
      LocalMediaItemCard.formatBytes(bytes);
}

class _Cover extends StatelessWidget {
  const _Cover({required this.item, this.remoteCover});

  static const BorderRadius _radius = BorderRadius.vertical(
    top: Radius.circular(14),
  );

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
    } else if (item.kind == LocalMediaItemKind.image && item.path.isNotEmpty) {
      child = LocalCoverImage(
        path: item.path,
        placeholder: _placeholder(scheme),
      );
    } else {
      child = _placeholder(scheme);
    }

    return ClipRRect(
      borderRadius: _radius,
      child: AspectRatio(aspectRatio: 16 / 9, child: child),
    );
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

/// 封面右下角那枚时长胶囊——「这张卡是能播的」。
///
/// ⛔ 底色写死成半透明黑、字写死成白，**不跟主题走**：它压在用户自己的封面上，
/// 而封面什么颜色都可能是。跟着 `colorScheme` 走的话，浅色主题下就是白底黑字压在
/// 一张过曝的截图上，等于没有。
///
/// 时长可能还没派生出来（[LocalMediaItem.durationMs] 为空），那时只剩一枚播放
/// 三角——记号在就够了，宁可少一个数字，也不能让这张卡看起来不是视频。
class _PlaybackPill extends StatelessWidget {
  const _PlaybackPill({this.duration});

  final String? duration;

  @override
  Widget build(BuildContext context) {
    final label = duration;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, label == null ? 4 : 5, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.play_arrow_rounded, size: 13, color: Colors.white),
            if (label != null) ...<Widget>[
              const SizedBox(width: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
