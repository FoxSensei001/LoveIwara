import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 拼装目录卡片的计数摘要。
///
/// 依次检查直接子目录数、视频数和图片数，只保留大于 0 的项分别格式化并用中点连接。
/// 若三者皆为 0，则回退到文件夹为空的文案。
String formatLocalFolderCounts({
  required int childFolderCount,
  required int videoCount,
  required int imageCount,

  /// null ＝ 还没真的把这个目录列出来看过。
  ///
  /// ⛔ 这种情况下**不许**回退到「这个文件夹是空的」——那是一句结论，而我们
  /// 此刻没有资格下结论。写错的代价是用户看着「空的」却点进去发现满满一屏。
  bool probed = true,
}) {
  final parts = <String>[];
  if (childFolderCount > 0) {
    parts.add(slang.t.localMedia.browse.folderCount(count: childFolderCount));
  }
  if (videoCount > 0) {
    parts.add(slang.t.localMedia.browse.videoCount(count: videoCount));
  }
  if (imageCount > 0) {
    parts.add(slang.t.localMedia.browse.imageCount(count: imageCount));
  }
  if (parts.isEmpty) {
    return probed ? slang.t.localMedia.browse.emptyFolder : '';
  }
  return parts.join(' · ');
}

/// 容器卡（目录 / 来源）第二行那串计数：**图标 + 数字**，不是一句话。
///
/// # 为什么不用 [formatLocalFolderCounts] 那串文字
///
/// 「3 个文件夹 · 128 个视频 · 1204 张图片」在一张 150px 宽的卡上必然被截成
/// 「3 个文件夹 · 128 个视…」——最该看见的数字反而被切掉，而那三个量词占掉了
/// 大半行宽。图标一枚 13px 就把"这是什么"说清楚了，省下的宽度全留给数字。
///
/// # ⛔ 三处防线，缺一条就会在窄卡上出事
///
/// 1. 数字压短（`CommonUtils.formatFriendlyNumber`）：一个有一万两千张图的
///    目录写成「1.2万」，不是「12000」；
/// 2. 每一格都是 [Flexible]：真挤不下时是数字省略，不是溢出报黄条；
/// 3. 计数为 0 的那一格**整个不出现**——占着位置写个 0 既没信息又抢宽度。
///
/// 文字版仍旧留给读屏（[Semantics.label]）：图标对读屏用户什么都不是。
class LocalFolderCountLine extends StatelessWidget {
  const LocalFolderCountLine({
    super.key,
    this.childFolderCount = 0,
    this.videoCount = 0,
    this.imageCount = 0,
    this.probed = true,
  });

  final int childFolderCount;
  final int videoCount;
  final int imageCount;

  /// null 语义同 [formatLocalFolderCounts]：还没真的看过这个目录，不许下
  /// 「这是空的」这个结论。
  final bool probed;

  static const double _iconSize = 13;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = LocalCardText.metaStyle(theme);
    final text = formatLocalFolderCounts(
      childFolderCount: childFolderCount,
      videoCount: videoCount,
      imageCount: imageCount,
      probed: probed,
    );

    final entries = <({IconData icon, int count})>[
      if (childFolderCount > 0)
        (icon: Icons.folder_outlined, count: childFolderCount),
      if (videoCount > 0) (icon: Icons.movie_outlined, count: videoCount),
      if (imageCount > 0) (icon: Icons.image_outlined, count: imageCount),
    ];

    // 一个都没有：还是那句话（「这个文件夹是空的」/ 没资格下结论时是空串）。
    if (entries.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Semantics(
      label: text,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    entries[i].icon,
                    size: _iconSize,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      CommonUtils.formatFriendlyNumber(entries[i].count),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 本机文件里的一个目录：封面 + 名字 + 计数。
///
/// 目录不是抽象的路标，它就是「里面那些东西」的入口——一眼看见封面就知道该不该
/// 进去，这比一行文件名快得多。
///
/// # ⛔ 外形归 [LocalCardShell]，这里只管填内容
///
/// 卡片外壳（与线上视频卡同款）全在 [LocalCardShell]，来源卡、图库卡、视频卡都用
/// 同一份。别在这里另画一套。
///
/// # ⛔ 高度必须写死
///
/// 卡片高度由 [extentFor] 从格宽推出，调用方靠 `mainAxisExtent` 铺网格。
/// 行高一致，网格才不会因为名字换不换行而参差。
///
/// # ⛔ 别再加「紧凑行」这个密度
///
/// 加过一版 `dense`（76 高的一行），配一枚顶栏切换钮，当天就删了：两档的差别只是
/// 卡片大一点还是小一点，没有哪一档能做到另一档做不到的事，换来的却是每个区块两条
/// 渲染分支。密度是**全局**设置的事（列数/断点，见 `MediaLayoutUtils`），不是每页
/// 挂一枚钮。
class LocalFolderCardWidget extends StatelessWidget {
  const LocalFolderCardWidget({
    super.key,
    required this.folder,
    required this.onOpen,
    this.onMenu,
    this.pinned = false,
    this.hidden = false,
  });

  /// 封面宽高比。与媒体卡同一个（见 [LocalCardShell]），封面选择弹窗也用它。
  static const double coverAspectRatio = LocalCardShell.coverAspectRatio;

  /// 给定格宽下一张目录卡的总高，交给 `LocalGridMetrics.delegate`。
  static double extentFor(BuildContext context, double cellWidth) =>
      LocalContainerCard.extentFor(context, cellWidth);

  final LocalMediaFolder folder;
  final VoidCallback onOpen;
  final void Function(BuildContext anchorContext)? onMenu;
  final bool pinned;

  /// 用户把这个目录隐藏了，此刻是因为「显示隐藏的文件夹」开着才画出来的。
  ///
  /// 它必须**一眼与普通目录分得开**：否则用户打开开关之后看到的是一屏分不清
  /// 藏没藏的卡片，"取消哪一个"全靠回忆。半透明 + 名字前一枚闭眼图标，两样一起
  /// 上——只靠透明度的话，一张本来就偏暗的封面看不出区别。
  final bool hidden;

  Widget _buildCover(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final coverPath = folder.coverPath;
    final placeholder = ColoredBox(
      // 缺封面时一块比卡面深一档的底 + 文件夹图标，看得出「这里本该有张封面」。
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.folder_rounded, size: 30, color: colorScheme.outline),
      ),
    );

    if (coverPath == null || coverPath.isEmpty) return placeholder;
    // 解码尺寸归 [LocalCoverImage]（封面可能是相机直出的原图）。
    return LocalCoverImage(path: coverPath, placeholder: placeholder);
  }

  @override
  Widget build(BuildContext context) {
    final Widget tile = _buildCard(context);
    // 隐藏的与"已经不在了"的用同一档半透明：两者对用户都是"这张卡不算数"，
    // 分两档深浅只会让人以为其中一档还有别的含义。
    return (folder.missing || hidden)
        ? Opacity(opacity: 0.45, child: tile)
        : tile;
  }

  Widget _buildCard(BuildContext context) {
    return LocalContainerCard(
      onTap: onOpen,
      // ⛔ ⋮ 角标和长按都由 [LocalContainerCard] 按这一个回调统一发，别在这里
      // 再画一份（来源卡当初就是那样漏掉长按的）。
      onMenu: onMenu,
      cover: _buildCover(context),
      // 常用星也归 [LocalContainerCard]（同 ⋮ 与长按），这里只说"我是不是"。
      pinned: pinned,
      title: folder.name,
      // 种类图标：外壳与视频卡一样，靠它一眼认出「这是个文件夹」。
      // 隐藏的换成闭眼——和普通目录一眼分得开，不用靠回忆。
      titleIcon: hidden ? Icons.visibility_off_outlined : Icons.folder_outlined,
      // 没真的列过这个目录时不下数字（同 [LocalFolderCountLine] 的 probed）。
      itemCount: folder.probedAt == null
          ? null
          : folder.childFolderCount + folder.videoCount + folder.imageCount,
      meta: LocalFolderCountLine(
        childFolderCount: folder.childFolderCount,
        videoCount: folder.videoCount,
        imageCount: folder.imageCount,
        probed: folder.probedAt != null,
      ),
    );
  }
}
