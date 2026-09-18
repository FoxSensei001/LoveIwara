import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_file_health.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_error_label.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_status_colors.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_actions.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 下载卡片的两种形态。
///
/// - [row]：横排一行。进行中的任务永远用它——进度、速度要横着读；窄屏上
///   已完成的也用它。
/// - [grid]：封面在上、文字在下的网格卡。只给宽屏上的已完成历史用：那里
///   封面才是认东西的主要线索，一行只摆一张是在浪费屏幕。
enum DownloadTileLayout { row, grid }

/// 列表页告诉子树「这一片用哪种形态」。卡片自己不看屏宽——同一宽度下进行中
/// 区是行、历史区是格，只有页面知道当下是哪一片。
class DownloadTileLayoutScope extends InheritedWidget {
  const DownloadTileLayoutScope({
    super.key,
    required this.layout,
    required super.child,
  });

  final DownloadTileLayout layout;

  static DownloadTileLayout of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<DownloadTileLayoutScope>()
          ?.layout ??
      DownloadTileLayout.row;

  @override
  bool updateShouldNotify(DownloadTileLayoutScope oldWidget) =>
      layout != oldWidget.layout;
}

/// 卡片上的作者一栏。
class DownloadTileAuthor {
  const DownloadTileAuthor({required this.name, this.avatarUrl, this.onTap});

  final String name;
  final String? avatarUrl;
  final VoidCallback? onTap;
}

/// 视频 / 图库 / 其他三类下载共用的卡片骨架。
///
/// 三类只在「封面区画什么、点了做什么、状态文字怎么写」上不同，这些由各自的
/// 适配器（`*_download_task_item_widget.dart`）以槽位交进来；外形、进度条、
/// 右键菜单、文件失效标记、行 / 格两种形态都只在这里写一份。
class DownloadTaskTile extends StatefulWidget {
  const DownloadTaskTile({
    super.key,
    required this.task,
    required this.cover,
    required this.title,
    required this.statusBuilder,
    required this.primaryAction,
    this.author,
    this.coverBadges = const [],
    this.coverOverlay,
    this.gridMeta,
    this.onTap,
    this.handlers = const DownloadTaskActionHandlers(),
    this.showPlayHint = false,
  });

  final DownloadTask task;

  /// 封面本体，铺满封面区（16:9）。
  final Widget cover;

  /// 叠在封面角上的小胶囊（清晰度、时长、张数），各自带好 [Positioned]。
  final List<Widget> coverBadges;

  /// 盖在封面上的整片（图库下载中的环形进度）。
  final Widget? coverOverlay;

  final String title;
  final DownloadTileAuthor? author;

  /// 行形态的状态一格。放在进度触发器的 Obx 里调，读到的是最新字节数。
  final WidgetBuilder statusBuilder;

  /// 行形态右上角的主操作（暂停 / 继续 / 重试 / 播放）。
  final Widget primaryAction;

  /// 格形态作者后面那一小段（大小、日期）。
  final String? gridMeta;

  final VoidCallback? onTap;
  final DownloadTaskActionHandlers handlers;

  /// 格形态悬停时在封面中央画一枚播放钮（视频用）。
  final bool showPlayHint;

  /// 行形态的封面宽度（未乘缩放系数）。
  static const double rowCoverWidth = 128;

  static const double radius = 14;

  /// 格形态每格有多高：16:9 封面 + 文字区。网格用它定 `mainAxisExtent`
  /// （见 `LocalGridMetrics.delegate`）——高度是卡片自己的事，调用点别拼公式。
  static double gridExtentFor(BuildContext context, double cellWidth) {
    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final scale = DownloadUiScale.of(context);
    double lineHeight(TextStyle? style, int lines) {
      final painter = TextPainter(
        text: TextSpan(text: List.filled(lines, 'Ag').join('\n'), style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: lines,
      )..layout();
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final title = lineHeight(_titleStyle(theme), 2);
    final meta = lineHeight(theme.textTheme.bodySmall, 1);
    // 元信息那一行里还站着 40 高的「更多」钮，按两者里高的算。
    final metaRow = meta > 40 * scale ? meta : 40 * scale;
    return (cellWidth * 9 / 16 + _gridPadTop + title + 2 + metaRow + 6)
        .ceilToDouble();
  }

  static const double _gridPadTop = 10;

  static TextStyle? _titleStyle(ThemeData theme) =>
      theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);

  @override
  State<DownloadTaskTile> createState() => _DownloadTaskTileState();
}

class _DownloadTaskTileState extends State<DownloadTaskTile> {
  bool _hovered = false;

  DownloadTask get task => widget.task;

  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  void _openMenu(TapUpDetails details) => showDownloadTaskMenu(
    context,
    task,
    globalPosition: details.globalPosition,
    handlers: widget.handlers,
  );

  @override
  Widget build(BuildContext context) {
    final layout = DownloadTileLayoutScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final clickable = widget.onTap != null;

    final body = layout == DownloadTileLayout.grid
        ? _buildGrid(context)
        : _buildRow(context);

    return RepaintBoundary(
      child: DownloadActionButtonTheme(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onSecondaryTapUp: _openMenu,
            child: Material(
              color: _hovered && _isDesktop
                  ? cs.surfaceContainer
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(DownloadTaskTile.radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                mouseCursor: clickable
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                splashFactory: clickable
                    ? InkSparkle.splashFactory
                    : NoSplash.splashFactory,
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 行
  // ---------------------------------------------------------------------------

  Widget _buildRow(BuildContext context) {
    final theme = Theme.of(context);
    final scale = DownloadUiScale.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final coverWidth =
        (narrow ? 104.0 : DownloadTaskTile.rowCoverWidth) * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10 * scale, 10 * scale, 4, 10 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: coverWidth,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildCover(context, compact: true),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: DownloadTaskTile._titleStyle(theme),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.author != null) ...[
                      SizedBox(height: 4 * scale),
                      _buildAuthor(context, widget.author!),
                    ],
                    SizedBox(height: 6 * scale),
                    Obx(() {
                      DownloadService.to.getProgressTrigger(task.id).value;
                      return widget.statusBuilder(context);
                    }),
                    DownloadErrorLabel(task: task),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.primaryAction,
                  DownloadTaskMoreButton(task: task, handlers: widget.handlers),
                ],
              ),
            ],
          ),
        ),
        _ProgressEdge(task: task),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 格
  // ---------------------------------------------------------------------------

  Widget _buildGrid(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final author = widget.author;
    final metaParts = [
      if (author != null && author.name.isNotEmpty) author.name,
      if (widget.gridMeta != null && widget.gridMeta!.isNotEmpty)
        widget.gridMeta!,
      // 网格没有按天分组的日期标题，日期挪到每张卡上。
      if (task.createdAt case final created?) _shortDate(created),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildCover(context, compact: false),
        ),
        _ProgressEdge(task: task),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            10,
            DownloadTaskTile._gridPadTop,
            2,
            0,
          ),
          child: Text(
            widget.title,
            style: DownloadTaskTile._titleStyle(theme),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  metaParts.join(' · '),
                  style: muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DownloadTaskMoreButton(task: task, handlers: widget.handlers),
            ],
          ),
        ),
      ],
    );
  }

  static String _shortDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    final md = '${two(date.month)}-${two(date.day)}';
    return date.year == DateTime.now().year ? md : '${date.year}-$md';
  }

  // ---------------------------------------------------------------------------
  // 共用
  // ---------------------------------------------------------------------------

  Widget _buildAuthor(BuildContext context, DownloadTileAuthor author) {
    final theme = Theme.of(context);
    final scale = DownloadUiScale.of(context);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarWidget(avatarUrl: author.avatarUrl, size: 18 * scale),
        SizedBox(width: 6 * scale),
        Flexible(
          child: Text(
            author.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
    if (author.onTap == null) return row;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: author.onTap, child: row),
    );
  }

  /// 封面区：封面 + 角标 + 覆盖层 + 文件失效标记 + 悬停播放钮。
  ///
  /// 文件确认不在时封面褪成灰、角上挂一枚「文件已不在」——不必点开才知道。
  /// 格形态不走 [DownloadErrorLabel]（那一格会改变卡片高度，网格行高是定死
  /// 的），所以「可见即检查」也在这里报一次。
  Widget _buildCover(BuildContext context, {required bool compact}) {
    final cs = Theme.of(context).colorScheme;
    final health = DownloadFileHealth.isReady ? DownloadFileHealth.to : null;
    if (task.status == DownloadStatus.completed) health?.noteVisible(task);

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 8 : 0),
      child: ColoredBox(
        color: cs.surfaceContainerHighest,
        child: Obx(() {
          final state = health?.stateOf(task.id);
          final missing = state == DownloadFileState.missing;
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: missing ? 0.45 : 1,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                    missing ? _greyscale : _identity,
                  ),
                  child: widget.cover,
                ),
              ),
              ...widget.coverBadges,
              ?widget.coverOverlay,
              if (!compact)
                Positioned(
                  left: 6,
                  top: 6,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: missing
                        ? _MissingChip(key: const ValueKey('missing'))
                        : const SizedBox.shrink(key: ValueKey('ok')),
                  ),
                ),
              if (!compact && widget.showPlayHint)
                Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: _hovered && !missing ? 1 : 0,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  static const List<double> _identity = [
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  static const List<double> _greyscale = [
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

class _MissingChip extends StatelessWidget {
  const _MissingChip({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: cs.onErrorContainer,
            ),
            const SizedBox(width: 4),
            Text(
              slang.Translations.of(context).download.actions.fileMissing,
              style: TextStyle(fontSize: 12, color: cs.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}

/// 贴着卡片下沿的一根细进度条：只有没下完的任务才有，下完时收起来。
class _ProgressEdge extends StatelessWidget {
  const _ProgressEdge({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      DownloadService.to.getProgressTrigger(task.id).value;
      final done = task.status == DownloadStatus.completed;
      final color = downloadStatusColor(context, task.status);
      final value = task.totalBytes > 0
          ? (task.downloadedBytes / task.totalBytes).clamp(0.0, 1.0)
          : null;
      return AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: done
            ? const SizedBox(width: double.infinity)
            : LinearProgressIndicator(
                // 等待中不画走马灯：还没开始，别让人以为在动。
                value: task.status == DownloadStatus.pending ? 0 : value,
                minHeight: 3,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
      );
    });
  }
}
