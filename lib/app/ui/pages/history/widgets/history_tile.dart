import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_state.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 历史卡片的两种形态：窄屏长条、宽屏网格（与下载列表 R3 同一套取舍）。
enum HistoryTileLayout { row, grid }

/// 历史页的一条记录。
///
/// # 长条回答什么
///
/// 「这是哪条、看到哪了」。封面左、两行标题、一行说明（进度 · 作者 · 时间），
/// 封面底边一条进度条。**浏览时间交给分组标题**（今天 / 昨天 / 本周…），不在
/// 每张卡上再印一遍。
///
/// # 删掉了什么
///
/// 原先外面套的那层 `Card`（6~8 圆角，与内层 14 圆角打架）、底下拼的灰色 footer、
/// 每张卡上常驻的红色垃圾桶（滑动时极易误触）、类型色块——类型只由封面右下角
/// 的徽标交代（▶ 时长 / 🖼 张数 / 💬 回复数 / 📝）。删除收进 ⋮ 菜单末尾，删了可以撤销。
///
/// # 手势（与全站媒体卡一致）
///
/// 点 = 打开；长按 / 右键 = 预览弹窗（视频、图库）；⋮ = 操作菜单。帖子与论坛没有
/// 预览弹窗，长按 / 右键直接开菜单。选择态下点 = 勾选。
class HistoryTile extends StatefulWidget {
  const HistoryTile({
    super.key,
    required this.record,
    required this.layout,
    required this.selectionMode,
    required this.selected,
    required this.onOpen,
    required this.onRemove,
    required this.onToggleSelect,
  });

  final HistoryRecord record;
  final HistoryTileLayout layout;
  final bool selectionMode;
  final bool selected;
  final Future<void> Function(HistoryRecord record) onOpen;
  final void Function(HistoryRecord record) onRemove;
  final VoidCallback onToggleSelect;

  static const double radius = LocalCardShell.radius;

  /// 网格每格的高（交给 `mainAxisExtent`）。
  static double gridExtentFor(BuildContext context, double cellWidth) =>
      LocalCardShell.extentFor(context, cellWidth);

  static const EdgeInsetsDirectional _rowPad = EdgeInsetsDirectional.fromSTEB(
    12,
    9,
    0,
    9,
  );
  static const double _rowGap = 4;

  /// 长条的封面宽。
  static double rowCoverWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 400 ? 118 : 132;

  /// 长条的高：16:9 封面与「两行标题 + 一行说明」取高的那个。
  static double rowExtentFor(BuildContext context) {
    final text =
        _rowPad.vertical +
        LocalCardText.titleExtent(context) +
        _rowGap +
        LocalCardText.metaExtent(context);
    return math.max(rowCoverWidth(context) * 9 / 16, text).ceilToDouble();
  }

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile>
    with MediaCardActionState<HistoryTile> {
  HistoryRecord get record => widget.record;
  Object? get _data => record.originalData;

  @override
  Video? get actionVideo => _data is Video ? _data as Video : null;
  @override
  ImageModel? get actionGallery =>
      _data is ImageModel ? _data as ImageModel : null;
  @override
  String get actionMediaId => record.itemId;
  @override
  bool get baseLiked => actionVideo?.liked ?? actionGallery?.liked ?? false;
  @override
  int get baseLikeCount =>
      actionVideo?.numLikes ?? actionGallery?.numLikes ?? 0;

  @override
  Future<void> openMediaDetail() => widget.onOpen(record);

  bool get _isMedia => actionVideo != null || actionGallery != null;

  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  String get _title {
    final t = record.title.trim();
    return t.isEmpty ? slang.t.common.noTitle : t;
  }

  /// 封面底边进度条的高（时长胶囊相应上移，不压住它）。
  static const double _progressHeight = 4;

  IconData? get _typeIcon => switch (record.itemType) {
    'image' => Icons.photo_library_outlined,
    'post' => Icons.article_outlined,
    'thread' => Icons.forum_outlined,
    _ => null,
  };

  // ------------------------------------------------------------------ 手势

  void _onTap() {
    if (widget.selectionMode) {
      widget.onToggleSelect();
    } else {
      widget.onOpen(record);
    }
  }

  /// 长按：媒体开预览，其它开菜单；选择态下长按也只是勾选。
  void _onLongPress(BuildContext anchorContext) {
    if (widget.selectionMode) {
      widget.onToggleSelect();
    } else if (_isMedia) {
      openPreview();
    } else {
      _openMenu(anchorContext);
    }
  }

  void _onSecondaryTap(BuildContext anchorContext, TapUpDetails details) {
    if (widget.selectionMode) return;
    if (_isMedia) {
      openPreview();
    } else {
      _openMenu(anchorContext, globalPosition: details.globalPosition);
    }
  }

  MediaMenuExtraAction get _removeAction => MediaMenuExtraAction(
    label: slang.t.historyPage.removeFromHistory,
    icon: Icons.delete_outline,
    destructive: true,
    onSelected: () => widget.onRemove(record),
  );

  Future<void> _openMenu(
    BuildContext anchorContext, {
    Offset? globalPosition,
  }) async {
    if (_isMedia) {
      await showMediaActionMenu(
        anchorContext: anchorContext,
        video: actionVideo,
        gallery: actionGallery,
        globalPosition: globalPosition,
        likedOverride: effectiveLiked,
        onLikeChanged: applyLikeToggle,
        onPreview: openPreview,
        extraActions: [_removeAction],
      );
      return;
    }
    final user = _authorUser;
    final t = slang.Translations.of(anchorContext);
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      globalAnchor: globalPosition == null ? null : globalPosition & Size.zero,
      priorityNearAnchor: true,
      entries: [
        if (user != null && user.username.trim().isNotEmpty)
          GlassMenuOption<String>(
            value: 'author',
            label: t.mediaMenu.viewAuthor,
            icon: Icons.person_outline,
          ),
        GlassMenuOption<String>(
          value: 'remove',
          label: t.historyPage.removeFromHistory,
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    );
    switch (picked) {
      case 'author':
        NaviService.navigateToAuthorProfilePage(
          user!.username,
          initialUser: user,
        );
      case 'remove':
        widget.onRemove(record);
    }
  }

  User? get _authorUser => switch (_data) {
    final PostModel p => p.user,
    final ForumThreadModel th => th.user,
    _ => null,
  };

  // ------------------------------------------------------------------ 说明行

  static String _clock(int ms) {
    final total = ms ~/ 1000;
    final h = total ~/ 3600, m = (total % 3600) ~/ 60, s = total % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
  }

  String? _progressText(slang.Translations t) {
    if (record.isFinished) return t.historyPage.finished;
    final played = record.playedMs;
    if (played == null) return null;
    return t.historyPage.watchedTo(time: _clock(played));
  }

  /// 「今天 / 昨天」组里写钟点，更早的组里写日期——组标题已经给了粗粒度。
  String? _viewedAt(BuildContext context) {
    final at = record.updatedAt;
    if (at == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final l = MaterialLocalizations.of(context);
    if (!day.isBefore(today.subtract(const Duration(days: 1)))) {
      return l.formatTimeOfDay(
        TimeOfDay.fromDateTime(at),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );
    }
    return l.formatShortMonthDay(at);
  }

  Widget _meta(BuildContext context) {
    final t = slang.Translations.of(context);
    final progress = _progressText(t);
    final rest = [
      if ((record.author ?? '').trim().isNotEmpty) record.author!.trim(),
      ?_viewedAt(context),
    ].join(' · ');
    if (progress == null) return LocalCardText.metaText(context, rest);
    // 只给「看到 m:ss」上色，作者与时间保持次要色：整行染色读不出重点。
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: progress,
            style: record.isFinished
                ? null
                : TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
          ),
          if (rest.isNotEmpty) TextSpan(text: ' · $rest'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: LocalCardText.metaStyle(theme),
    );
  }

  // ------------------------------------------------------------------ 封面

  Widget _cover(BuildContext context, {required double width}) {
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final url = record.thumbnailUrl ?? '';
    final Widget image = url.isEmpty
        ? _TextCover(
            tint: record.itemType == 'thread'
                ? cs.tertiaryContainer
                : cs.secondaryContainer,
            user: _authorUser,
            icon: _typeIcon ?? Icons.history,
            width: width,
          )
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            memCacheWidth: (width * dpr).round(),
            fadeInDuration: const Duration(milliseconds: 120),
            placeholder: (_, _) =>
                ColoredBox(color: cs.surfaceContainerHighest),
            errorWidget: (_, _, _) => ColoredBox(
              color: cs.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
          );

    final video = actionVideo;
    final gallery = actionGallery;
    final data = _data;
    final progress = record.progress;
    const inset = LocalContainerCard.badgeInset;

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        image,
        if (video != null)
          Positioned(
            right: inset,
            bottom: inset + (progress == null ? 0 : _progressHeight),
            child: LocalPlaybackPill(duration: video.minutesDuration),
          ),
        if (gallery != null)
          Positioned(
            right: inset,
            bottom: inset,
            child: LocalCountPill(
              icon: Icons.photo_library_outlined,
              count: gallery.numImages,
            ),
          ),
        // 类型只由封面右下角的徽标交代（▶ 时长 / 🖼 张数 / 💬 回复数 / 📝），
        // 标题前不再另挂图标——否则同一列标题的起点参差不齐。
        if (!_isMedia && _typeIcon != null)
          Positioned(
            right: inset,
            bottom: inset,
            child: LocalCountPill(
              icon: _typeIcon!,
              count: data is ForumThreadModel ? data.numPosts : null,
            ),
          ),
        if (progress != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _progressHeight,
            child: _ProgressBar(value: progress, finished: record.isFinished),
          ),
      ],
    );
    // 帖子 / 论坛没有预览弹窗，也就没有 Hero（它们的 tag 算不出来）。
    if (!_isMedia) return stack;
    // 封面是「卡 → 预览弹窗」那段 Hero 的起点，开关见 [previewHeroEnabled]。
    return HeroMode(
      enabled: previewHeroEnabled,
      child: Hero(key: previewHeroKey, tag: previewHeroTag, child: stack),
    );
  }

  // ------------------------------------------------------------------ 形态

  @override
  Widget build(BuildContext context) {
    final body = widget.layout == HistoryTileLayout.grid
        ? _buildGrid(context)
        : _buildRow(context);
    return RepaintBoundary(
      child: Builder(
        builder: (anchorContext) => GestureDetector(
          onSecondaryTapUp: _isDesktop
              ? (d) => _onSecondaryTap(anchorContext, d)
              : null,
          child: Stack(
            children: [
              body,
              // 选择态：角标勾选片 + 选中描边（全站统一）。常驻挂载以获得进出过渡。
              Positioned.fill(
                child: IgnorePointer(
                  child: GlassSelectableOverlay(
                    selectionMode: widget.selectionMode,
                    selected: widget.selected,
                    borderRadius: BorderRadius.circular(HistoryTile.radius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => LocalCardShell(
        cover: _cover(context, width: constraints.maxWidth),
        title: _title,
        meta: _meta(context),
        onTap: _onTap,
        onMenu: widget.selectionMode ? null : (a) => _openMenu(a),
        onLongPress: () => _onLongPress(context),
      ),
    );
  }

  Widget _buildRow(BuildContext context) {
    final theme = Theme.of(context);
    final coverWidth = HistoryTile.rowCoverWidth(context);
    const borderRadius = BorderRadius.all(Radius.circular(HistoryTile.radius));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Builder(
          builder: (cardContext) => InkWell(
            onTap: _onTap,
            onLongPress: () => _onLongPress(cardContext),
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 2,
              child: Builder(
                builder: (context) => SizedBox(
                  height: HistoryTile.rowExtentFor(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: coverWidth,
                        child: _cover(context, width: coverWidth),
                      ),
                      Expanded(
                        child: Padding(
                          padding: HistoryTile._rowPad,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: LocalCardText.titleExtent(context),
                                child: _RowTitle(title: _title),
                              ),
                              _meta(context),
                            ],
                          ),
                        ),
                      ),
                      // 选择态下 ⋮ 让位（淡出而不是硬切），整张卡只剩「勾选」一个动作。
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: widget.selectionMode ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: widget.selectionMode,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2, right: 2),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: _isMedia
                                  ? MediaActionMenuButton(
                                      video: actionVideo,
                                      gallery: actionGallery,
                                      likedOverride: effectiveLiked,
                                      onLikeChanged: applyLikeToggle,
                                      onPreview: openPreview,
                                      extraActions: [_removeAction],
                                    )
                                  : _MoreButton(onOpen: _openMenu),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 封面底边的观看进度。看完的那条用次要色铺满，读起来是「看过了」而不是「在看」。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.finished});

  final double value;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 进度条压在画面上，要的是「亮」：浅色主题的 primary 是深色调，压在深色
    // 画面上几乎看不见，改用它的浅色调（inversePrimary）；深色主题的 primary
    // 本来就是浅色调。底轨用白色半透明，深浅画面上都读得出「总长」。
    final fill = finished
        ? Colors.white.withValues(alpha: 0.75)
        : theme.brightness == Brightness.light
        ? theme.colorScheme.inversePrimary
        : theme.colorScheme.primary;
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.28),
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: value,
        child: ColoredBox(color: fill),
      ),
    );
  }
}

/// 帖子 / 论坛没有封面：按类型着色的底 + 作者头像，一眼能认出「谁的哪类帖子」，
/// 而不是一整块灰底像加载失败。类型徽标由 [_HistoryTileState._cover] 叠在右下角。
class _TextCover extends StatelessWidget {
  const _TextCover({
    required this.tint,
    required this.user,
    required this.icon,
    required this.width,
  });

  final Color tint;
  final User? user;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = (width / 4).clamp(28.0, 44.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Color.lerp(tint, cs.surface, 0.55)!],
        ),
      ),
      child: Center(
        child: user != null
            ? IgnorePointer(
                child: AvatarWidget(user: user, size: size),
              )
            : Icon(
                icon,
                size: size,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
      ),
    );
  }
}

/// 长条标题：与 [LocalCardText] 同一副字样（14 号 / 1.22 行高 / w700，恒两行）。
class _RowTitle extends StatelessWidget {
  const _RowTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      strutStyle: const StrutStyle(
        fontSize: 14,
        height: 1.22,
        forceStrutHeight: true,
      ),
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 14,
        height: 1.22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// 帖子 / 论坛那条的 ⋮（媒体用的是 [MediaActionMenuButton]）。同一副尺寸。
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onOpen});

  final Future<void> Function(BuildContext anchorContext) onOpen;

  @override
  Widget build(BuildContext context) {
    return GlassTapArea(
      onTap: () => onOpen(context),
      onLongPress: () => onOpen(context),
      opensOverlay: true,
      longPressOpensOverlay: true,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Icon(
          Icons.more_vert,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
