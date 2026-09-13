import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
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
/// 外形与目录卡同族（[LocalContainerCard] 那只夹子）：来源就是最外面的那一层
/// 目录，长得一样是对的——要跟媒体卡分开的是**它们俩一起**。
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
  });

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

  /// 封面以下那块文字区的高度：名字 + 路径 + 计数三行。
  static double textExtent(BuildContext context) =>
      LocalContainerCard.textExtentOf(context, lines: 3);

  /// 给定格宽下一张来源卡的总高，交给 `LocalGridMetrics.delegate`。
  static double extentFor(BuildContext context, double cellWidth) =>
      LocalContainerCard.extentFor(
        cellWidth: cellWidth,
        coverAspectRatio: LocalFolderCardWidget.coverAspectRatio,
        textExtent: textExtent(context),
      );

  IconData get _icon => source.isBuiltIn
      ? Icons.download_rounded
      : source.kind == LocalMediaSourceKind.mediastore
      ? Icons.video_library_rounded
      : Icons.folder_rounded;

  String get _subtitle {
    final t = slang.t.localMedia;
    if (source.isBuiltIn) return t.builtInSourceHint;
    if (source.kind == LocalMediaSourceKind.mediastore) {
      return t.mediaStoreSourceName;
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
      coverAspectRatio: LocalFolderCardWidget.coverAspectRatio,
      onTap: onOpen,
      // ⛔ 这一行就是 2026-09-11 那个 bug 的位置：以前这里只画了一枚 ⋮、给那枚 ⋮
      // 接了长按，却**没有**把长按递给整张卡——长按子目录有菜单、长按来源没反应。
      // 现在两个入口都由 [LocalContainerCard] 按这一个回调发。
      onMenu: onMenu,
      pinned: pinned,
      cover: _buildCover(context),
      // 扫描中把角标套上转圈指示器，同时保留 ⋮ 菜单入口和点击响应——扫描中想移除、
      // 设为常用、改封面等操作随时都能点得动，绝不能把入口藏掉。
      trailing: scanning
          ? LocalCardBadge(
              child: Builder(
                builder: (anchorContext) => GlassTapArea(
                  onTap: () => onMenu(anchorContext),
                  onLongPress: () => onMenu(anchorContext),
                  opensOverlay: true,
                  longPressOpensOverlay: true,
                  child: Padding(
                    padding: const EdgeInsets.all(
                      LocalCardMenuBadge.iconPadding,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: LocalCardMenuBadge.iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(
                          Icons.more_vert,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
      lines: <Widget>[
        Text(
          source.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          scanning
              ? slang.t.localMedia.scanning(count: videoCount + imageCount)
              : _subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scanning
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        LocalFolderCountLine(
          childFolderCount: childFolderCount,
          videoCount: videoCount,
          imageCount: imageCount,
        ),
      ],
    );
  }
}

/// 来源网格末尾那一格「添加」。
///
/// 添加动作本来是列表下面孤零零一排按钮：来源少的时候它悬在一片空白中间，来源多
/// 的时候又要滚到底才够得着。做成网格里的最后一格，它就永远跟在来源后面，位置随
/// 内容走，也把那一行的空格填上了。
///
/// 外形也是那只夹子，只是空心的——它要占的正是「下一只夹子」的位置。
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

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        shape: LocalFolderShape(
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add_rounded, size: 30, color: color),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  slang.t.localMedia.addFolder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
