import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/services/webdav/webdav_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本机文件根页上的一个来源。
///
/// # 为什么不是一条 ListTile
///
/// 它以前是。一行图标 + 名字 + 路径，横着铺满整页——平板上就是三条从屏幕左边
/// 拉到右边的长条，中间全是空的，也看不出这个来源里到底有什么。
///
/// 来源是用户进入自己文件的**第一道门**，那扇门上该写着门后有什么：一张封面、
/// 一句「N 个视频 · N 张图片」。这些数字本来只有点进去才看得到，现在提前一层
/// 摆出来，用户在根页就能挑。
///
/// 外形与目录卡同一副（[LocalContainerCard]）：来源就是最外面的那一层目录，
/// 标题前的种类图标（已下载 / 设备视频 / NAS / 文件夹）说清它是哪一种。
class LocalSourceCardWidget extends StatelessWidget {
  const LocalSourceCardWidget({
    super.key,
    required this.source,
    required this.coverPath,
    required this.videoCount,
    required this.imageCount,
    this.childFolderCount = 0,
    required this.onOpen,
    required this.onMenu,
    this.pinned = false,
    this.scanning = false,
    this.queued = false,
    this.probed = true,
  });

  /// 排队等别的源扫完。副标题说「排队等待扫描」，计数行不下「是空的」的结论。
  final bool queued;

  /// 计数全为 0 时能不能下「是空的」这个结论。NAS 只收录打开过的层，
  /// 没列到东西不等于空，调用点对它传 false。
  final bool probed;

  final LocalMediaSource source;
  final String? coverPath;
  final int videoCount;
  final int imageCount;

  /// 「已下载」这张卡用它显示已下载图库的个数：图库是容器，和子目录同一种东西，
  /// 所以共用文件夹那枚图标。
  final int childFolderCount;

  /// 这个来源被设为常用了。⛔ 别忘了接：不接就是"在文件目录里收藏了、卡片上却
  /// 什么都不长"（2026-09-11 用户报的），星怎么画归 [LocalContainerCard]。
  final bool pinned;

  final bool scanning;
  final VoidCallback onOpen;

  /// 打开「重新扫描 / 移除」菜单；[BuildContext] 是菜单的锚点。
  final void Function(BuildContext anchorContext) onMenu;

  /// 给定格宽下一张来源卡的总高，交给 `LocalGridMetrics.delegate`。
  static double extentFor(BuildContext context, double cellWidth) =>
      LocalContainerCard.extentFor(context, cellWidth);

  IconData get _icon => iconOf(source);

  /// 按来源种类的图标。顶栏「移除来源」的选择列表也用它，和卡片同一套。
  static IconData iconOf(LocalMediaSource source) => switch (source.kind) {
    // 描边款：卡片标题前那一枚与目录卡的文件夹图标同一套线稿。
    LocalMediaSourceKind.downloads => Icons.download_outlined,
    LocalMediaSourceKind.mediastore => Icons.video_library_outlined,
    LocalMediaSourceKind.webdav => Icons.dns_outlined,
    LocalMediaSourceKind.unknown => Icons.help_outline_rounded,
    LocalMediaSourceKind.directory ||
    LocalMediaSourceKind.bookmark => Icons.folder_outlined,
  };

  /// 卡片第二行：内建源的说明、NAS 的主机路径或故障原因、目录的路径。
  /// 顶栏「移除来源」的选择列表也用它——那里曾经把 `dav:/…` 原样露给用户。
  static String subtitleOf(LocalMediaSource source) {
    final t = slang.t.localMedia;
    if (source.isBuiltIn) return t.builtInSourceHint;
    if (source.kind == LocalMediaSourceKind.mediastore) {
      return t.mediaStoreSourceName;
    }
    if (source.isInert) return t.unknownSourceHint;
    if (source.isRemote) {
      // 连不上 / 要重新登录时，副标题直接说原因——这比地址重要。
      final state = source.remoteState;
      if (state != null && state != LocalMediaRemoteState.ok) {
        return WebDavService.describeState(state);
      }
      // 「主机/服务端路径」——`dav:/` 前缀是库内形状，不给用户看。
      final host = Uri.tryParse(source.uri ?? '')?.host ?? '';
      final path = source.path;
      final serverPath = DavPath.isDav(path) ? DavPath.toServerPath(path!) : '';
      return '$host$serverPath';
    }
    return source.path ?? '';
  }

  Widget _buildCover(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(child: Icon(_icon, size: 30, color: scheme.outline)),
    );
    final path = coverPath;
    if (path == null || path.isEmpty) return placeholder;
    return LocalCoverImage(path: path, placeholder: placeholder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LocalContainerCard(
      onTap: onOpen,
      // ⛔ 这一行就是 2026-09-11 那个 bug 的位置：以前这里只画了一枚 ⋮、给那枚 ⋮
      // 接了长按，却**没有**把长按递给整张卡——长按子目录有菜单、长按来源没反应。
      // 现在两个入口都由 [LocalContainerCard] 按这一个回调发。
      onMenu: onMenu,
      pinned: pinned,
      cover: _buildCover(context),
      // 扫描中在封面右上角挂一枚转圈；⋮ 在说明行右端，扫描中照样点得动。
      trailing: scanning
          ? LocalCardBadge(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          : null,
      title: source.displayName,
      // 种类图标行内挂在名字前：已下载 / 设备视频 / NAS / 文件夹一眼分得开，
      // 不用再靠下面那行路径去猜。
      titleIcon: _icon,
      itemCount: probed && !queued
          ? childFolderCount + videoCount + imageCount
          : null,
      meta: _statusOrCounts(context, theme),
    );
  }

  /// 说明行：正常时是计数；扫描中 / 排队 / NAS 出故障 / 认不出的源时换成那句状态。
  ///
  /// ⛔ 路径与内建源说明（「『已下载』由下载模块自动维护」）不上卡面：一张卡只该
  /// 回答「里面有什么」，路径是要用时才查的东西，在菜单的信息里。
  Widget _statusOrCounts(BuildContext context, ThemeData theme) {
    final t = slang.t.localMedia;
    if (scanning) {
      return LocalCardText.metaText(
        context,
        t.scanning(count: videoCount + imageCount),
        color: theme.colorScheme.primary,
      );
    }
    if (queued) {
      return LocalCardText.metaText(
        context,
        t.scanQueued,
        color: theme.colorScheme.primary,
      );
    }
    final remoteState = source.remoteState;
    if (source.isRemote &&
        remoteState != null &&
        remoteState != LocalMediaRemoteState.ok) {
      return LocalCardText.metaText(
        context,
        WebDavService.describeState(remoteState),
        color: theme.colorScheme.error,
      );
    }
    if (source.isInert) {
      return LocalCardText.metaText(
        context,
        t.unknownSourceHint,
        color: theme.colorScheme.error,
      );
    }
    return LocalFolderCountLine(
      childFolderCount: childFolderCount,
      videoCount: videoCount,
      imageCount: imageCount,
      probed: probed,
    );
  }
}

/// 来源网格末尾那一格「添加」。
///
/// 添加动作本来是列表下面孤零零一排按钮：来源少的时候它悬在一片空白中间，来源多
/// 的时候又要滚到底才够得着。做成网格里的最后一格，它就永远跟在来源后面，位置随
/// 内容走，也把那一行的空格填上了。
///
/// 外壳与来源卡同一副，只是空心的——它要占的正是「下一张来源卡」的位置。
class LocalAddSourceCard extends StatelessWidget {
  const LocalAddSourceCard({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    // 与来源卡同一副外壳（[LocalCardShell]），只是空心的：虚一档的描边、没有
    // 阴影、封面位置换成一枚加号。它占的正是「下一张来源卡」的位置，形状对得上，
    // 一排看过去才不参差。
    const radius = BorderRadius.all(Radius.circular(LocalCardShell.radius));
    // 来源卡上沿有叠纸（[LocalContainerCard.stackReveal]），空心那格让出同样一截，
    // 一排卡片的上沿才齐。
    return Padding(
      padding: const EdgeInsets.only(top: LocalContainerCard.stackReveal),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1.2,
            ),
          ),
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: LocalCardShell.coverAspectRatio,
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: Icon(Icons.add_rounded, size: 32, color: color),
                  ),
                ),
                Expanded(
                  child: LocalCardText(
                    title: slang.t.localMedia.addSource,
                    // 名字只写「添加来源」的话，用户不知道 NAS 也从这里进
                    // （2026-09-19：入口原先叫「添加文件夹」，连 NAS 的人根本想不到点它）。
                    meta: LocalCardText.metaText(
                      context,
                      slang.t.localMedia.addSourceKinds,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
