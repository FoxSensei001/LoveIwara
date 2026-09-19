import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_file_health.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_error_label.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_actions.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 下载卡片的两种形态。
///
/// - [row]：长条。进行中的任务永远用它；窄屏上已完成的也用它。
/// - [grid]：封面在上、文字在下的网格卡（[LocalCardShell]，与本机文件、线上
///   视频卡同一副外壳）。只给宽屏上的已完成历史用。
enum DownloadTileLayout { row, grid }

/// 列表页告诉子树两件事：这一片用哪种形态，长按一张卡做什么。
///
/// 卡片自己不看屏宽——同一宽度下进行中区是行、历史区是格，只有页面知道当下
/// 是哪一片。长按也由页面给：下载页的长按是「进多选」，而 [LocalCardShell]
/// 默认的长按是开菜单，不从这里覆盖就会被卡片自己的 InkWell 抢走。
class DownloadTileLayoutScope extends InheritedWidget {
  const DownloadTileLayoutScope({
    super.key,
    required this.layout,
    this.onLongPress,
    required super.child,
  });

  final DownloadTileLayout layout;
  final ValueChanged<DownloadTask>? onLongPress;

  static DownloadTileLayoutScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DownloadTileLayoutScope>();

  static DownloadTileLayout of(BuildContext context) =>
      _of(context)?.layout ?? DownloadTileLayout.row;

  @override
  bool updateShouldNotify(DownloadTileLayoutScope oldWidget) =>
      layout != oldWidget.layout || onLongPress != oldWidget.onLongPress;
}

/// 卡片说明行里的作者。
class DownloadTileAuthor {
  const DownloadTileAuthor({required this.name, this.onTap});

  final String name;
  final VoidCallback? onTap;
}

/// 进度按什么计：视频 / 文件是字节，图库是张数（图库任务的
/// `downloadedBytes / totalBytes` 存的就是张数）。
enum DownloadProgressUnit { bytes, images }

/// 视频 / 图库 / 其他三类下载共用的卡片骨架。
///
/// # 长条卡回答什么
///
/// 进行中：「这是哪条、到哪了、点哪暂停」。封面贴着卡片左沿、上下顶满，
/// **封面本身就是主操作**——中间一枚圆钮，外圈就是进度环，点封面即暂停 / 继续 /
/// 重试。右侧因此不再有按钮列，标题能完整摆两行；状态只剩一行字（数字等宽），
/// 只有失败才着错误色。
///
/// 已完成：「这是哪部、谁的」。封面上是时长 / 张数胶囊，说明行是作者（可点）加
/// 一小段补充（大小），点整张卡即打开。
///
/// # 删掉了什么
///
/// 状态胶囊（分区头已说明状态）、作者头像、封面上的清晰度角标、底边 3px 进度条、
/// 图库封面上的黑色蒙层圆环、已完成卡上的播放钮、手机上图库卡那块空占位、窄屏
/// 另起的一套两行状态写法。三类卡各写一份的主操作钮与状态文案也收回到这里。
class DownloadTaskTile extends StatefulWidget {
  const DownloadTaskTile({
    super.key,
    required this.task,
    required this.cover,
    required this.title,
    this.titleIcon,
    this.author,
    this.completedMeta,
    this.coverBadges = const [],
    this.progressUnit = DownloadProgressUnit.bytes,
    this.onTap,
    this.handlers = const DownloadTaskActionHandlers(),
  });

  final DownloadTask task;

  /// 封面本体，铺满封面区。
  final Widget cover;

  /// 已完成时叠在封面角上的小胶囊（时长、张数、扩展名），各自带好
  /// [Positioned]。进行中不画——那时封面中央是操作钮，角上再挂东西就乱了。
  final List<Widget> coverBadges;

  final String title;

  /// 标题前的种类图标（图库）。
  final IconData? titleIcon;

  final DownloadTileAuthor? author;

  /// 已完成时说明行作者后面那一小段（大小）。
  final String? completedMeta;

  final DownloadProgressUnit progressUnit;

  final VoidCallback? onTap;
  final DownloadTaskActionHandlers handlers;

  /// 与 [LocalCardShell] 同一个圆角：选择态叠层按它描边。
  static const double radius = LocalCardShell.radius;

  /// 格形态每格有多高（交给网格的 `mainAxisExtent`）。
  static double gridExtentFor(BuildContext context, double cellWidth) =>
      LocalCardShell.extentFor(context, cellWidth);

  @override
  State<DownloadTaskTile> createState() => _DownloadTaskTileState();
}

class _DownloadTaskTileState extends State<DownloadTaskTile> {
  DownloadTask get task => widget.task;

  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  void _openMenuAt(TapUpDetails details) => showDownloadTaskMenu(
    context,
    task,
    globalPosition: details.globalPosition,
    handlers: widget.handlers,
  );

  VoidCallback? _longPress(BuildContext context) {
    final onLongPress = DownloadTileLayoutScope._of(context)?.onLongPress;
    return onLongPress == null ? null : () => onLongPress(task);
  }

  @override
  Widget build(BuildContext context) {
    final body = DownloadTileLayoutScope.of(context) == DownloadTileLayout.grid
        ? _buildGrid(context)
        : _buildRow(context);
    return RepaintBoundary(
      child: GestureDetector(
        onSecondaryTapUp: _isDesktop ? _openMenuAt : null,
        child: body,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 长条
  // ---------------------------------------------------------------------------

  /// 长条的高：16:9 封面与「两行标题 + 一行状态」取高的那个。封面宽度固定，
  /// 文字一撑高，封面就按 cover 裁得更方一点，不会把卡片挤变形。
  static double _rowHeight(BuildContext context, double coverWidth) {
    final text =
        _rowPad.vertical +
        LocalCardText.titleExtent(context) +
        _rowGap +
        LocalCardText.metaExtent(context);
    return math.max(coverWidth * 9 / 16, text).ceilToDouble();
  }

  static const EdgeInsetsDirectional _rowPad = EdgeInsetsDirectional.fromSTEB(
    12,
    9,
    0,
    9,
  );
  static const double _rowGap = 4;

  Widget _buildRow(BuildContext context) {
    final theme = Theme.of(context);
    final scale = DownloadUiScale.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final coverWidth = (narrow ? 118.0 : 132.0) * scale;
    const borderRadius = BorderRadius.all(
      Radius.circular(LocalCardShell.radius),
    );

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
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: _longPress(context),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 2,
            child: Builder(
              builder: (context) => SizedBox(
                height: _rowHeight(context, coverWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: coverWidth, child: _buildRowCover(context)),
                    Expanded(
                      child: Padding(
                        padding: _rowPad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: LocalCardText.titleExtent(context),
                              child: _DownloadTitle(
                                title: widget.title,
                                icon: widget.titleIcon,
                              ),
                            ),
                            _buildMeta(context),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2 * scale, right: 2),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: DownloadTaskMoreButton(
                          task: task,
                          handlers: widget.handlers,
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
    );
  }

  /// 长条的封面：进行中是「封面 + 压暗 + 中央操作钮（外圈进度环）」，点封面
  /// 就是主操作；已完成是「封面 + 角标」，点它与点卡片一样是打开。
  Widget _buildRowCover(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      return _CompletedCover(
        task: task,
        cover: widget.cover,
        badges: widget.coverBadges,
        compactMissing: true,
      );
    }
    return _ActiveCover(task: task, cover: widget.cover);
  }

  // ---------------------------------------------------------------------------
  // 格
  // ---------------------------------------------------------------------------

  Widget _buildGrid(BuildContext context) {
    return LocalCardShell(
      cover: _CompletedCover(
        task: task,
        cover: widget.cover,
        badges: widget.coverBadges,
        compactMissing: false,
      ),
      title: widget.title,
      titleIcon: widget.titleIcon,
      meta: _buildMeta(context),
      onTap: widget.onTap,
      onMenu: (anchorContext) =>
          showDownloadTaskMenu(anchorContext, task, handlers: widget.handlers),
      onLongPress: _longPress(context),
    );
  }

  // ---------------------------------------------------------------------------
  // 说明行
  // ---------------------------------------------------------------------------

  /// 卡片上唯一一行小字。进行中报进度，已完成报出处；两种都只有一行。
  Widget _buildMeta(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      return _CompletedMeta(
        task: task,
        author: widget.author,
        extra: widget.completedMeta,
      );
    }
    if (task.status == DownloadStatus.failed) {
      return DownloadErrorLabel(task: task);
    }
    return Obx(() {
      DownloadService.to.getProgressTrigger(task.id).value;
      final theme = Theme.of(context);
      final downloading = task.status == DownloadStatus.downloading;
      return LocalCardText.metaText(
        context,
        _progressLine(context, task, widget.progressUnit),
        color: downloading ? theme.colorScheme.primary : null,
      );
    });
  }
}

/// 进行中任务的那一行状态字。
///
/// - 下载中：`42% · 3.1 MB/s · 剩 1:04`（总大小未知时退成 `128 MB · 3.1 MB/s`）
/// - 暂停：`暂停中 · 120 MB / 300 MB`
/// - 等待：`等待中`
///
/// 图库按张数：`12 / 40 · 30%`。
String _progressLine(
  BuildContext context,
  DownloadTask task,
  DownloadProgressUnit unit,
) {
  final t = slang.Translations.of(context).download;
  final done = task.downloadedBytes;
  final total = task.totalBytes;
  final images = unit == DownloadProgressUnit.images;
  String amount(int v) => images ? '$v' : formatDownloadBytes(v);
  final percent = total > 0
      ? '${(done / total * 100).clamp(0, 100).floor()}%'
      : null;

  switch (task.status) {
    case DownloadStatus.pending:
      return t.waiting;
    case DownloadStatus.paused:
      final progress = total > 0
          ? '${amount(done)} / ${amount(total)}'
          : amount(done);
      return '${t.paused} · $progress';
    case DownloadStatus.downloading:
      if (images) {
        return [total > 0 ? '$done / $total' : '$done', ?percent].join(' · ');
      }
      final speed = task.speed > 0
          ? '${formatDownloadBytes(task.speed)}/s'
          : null;
      String? eta;
      if (task.speed > 0 && total > done) {
        eta = t.remainingTime(
          time: _formatEta(((total - done) / task.speed).ceil()),
        );
      }
      return [percent ?? amount(done), ?speed, ?eta].join(' · ');
    case DownloadStatus.failed:
    case DownloadStatus.completed:
      return '';
  }
}

String _formatEta(int seconds) {
  String two(int v) => v.toString().padLeft(2, '0');
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
}

/// 字节数的展示：≥10 取整，否则留一位小数（`3.1 MB`、`305 MB`）。
String formatDownloadBytes(num bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  final text = size >= 10 || unit == 0
      ? size.round().toString()
      : size.toStringAsFixed(1);
  return '$text ${units[unit]}';
}

/// 标题：与 [LocalCardText] 同一副字样（14 号 / 1.22 行高 / w700，恒两行）。
class _DownloadTitle extends StatelessWidget {
  const _DownloadTitle({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          if (icon != null) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                icon,
                size: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const TextSpan(text: ' '),
          ],
          TextSpan(text: title),
        ],
      ),
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

/// 已完成卡的说明行：作者（可点进主页）· 补充。
///
/// 文件确认不在时整行换成错误色的「文件已不在」，可能还能找回的换成次要色的
/// 「暂时找不到」——不必点开才知道。可见即检查（[DownloadFileHealth.noteVisible]）
/// 挂在封面上，这里只读结果。
class _CompletedMeta extends StatelessWidget {
  const _CompletedMeta({required this.task, this.author, this.extra});

  final DownloadTask task;
  final DownloadTileAuthor? author;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    // 没就绪时 Obx 里一个 Rx 都读不到，会报「improper use of GetX」。
    if (!DownloadFileHealth.isReady) return _normal(context);
    final health = DownloadFileHealth.to;
    return Obx(() {
      final state = health.stateOf(task.id);
      final t = slang.Translations.of(context).download.actions;
      final cs = Theme.of(context).colorScheme;
      final Widget child = switch (state) {
        DownloadFileState.missing => LocalCardText.metaText(
          context,
          t.fileMissing,
          color: cs.error,
        ),
        DownloadFileState.pending => LocalCardText.metaText(
          context,
          t.filePending,
        ),
        _ => _normal(context),
      };
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: KeyedSubtree(key: ValueKey(state), child: child),
      );
    });
  }

  Widget _normal(BuildContext context) {
    final name = author?.name ?? '';
    final tail = extra;
    final parts = [
      if (name.isNotEmpty) name,
      if (tail != null && tail.isNotEmpty) tail,
    ];
    final text = LocalCardText.metaText(context, parts.join(' · '));
    final onTap = author?.onTap;
    if (onTap == null || name.isEmpty) return text;
    return Align(
      alignment: Alignment.centerLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: text),
      ),
    );
  }
}

/// 已完成的封面：封面 + 角标，文件确认不在时褪成灰并挂一枚「文件已不在」。
class _CompletedCover extends StatelessWidget {
  const _CompletedCover({
    required this.task,
    required this.cover,
    required this.badges,
    required this.compactMissing,
  });

  final DownloadTask task;
  final Widget cover;
  final List<Widget> badges;

  /// 长条的封面窄，失效标记只画图标（说明行已经写着「文件已不在」）。
  final bool compactMissing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final health = DownloadFileHealth.isReady ? DownloadFileHealth.to : null;
    health?.noteVisible(task);

    return ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Obx(() {
        final missing = health?.stateOf(task.id) == DownloadFileState.missing;
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
                child: cover,
              ),
            ),
            ...badges,
            // 移动文件等批量操作期间，服务把这条标成「处理中」：已完成卡没有
            // 操作钮可换成转圈，就在封面上压一层。
            IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: DownloadService.to.isTaskProcessing(task.id)
                    ? const ColoredBox(
                        key: ValueKey('processing'),
                        color: Colors.black45,
                        child: Center(
                          child: SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('idle')),
              ),
            ),
            PositionedDirectional(
              start: 6,
              top: 6,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: missing
                    ? _MissingChip(
                        key: const ValueKey('missing'),
                        compact: compactMissing,
                      )
                    : const SizedBox.shrink(key: ValueKey('ok')),
              ),
            ),
          ],
        );
      }),
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
  const _MissingChip({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = Icon(
      Icons.warning_amber_rounded,
      size: 14,
      color: cs.onErrorContainer,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 6, vertical: 3),
        child: compact
            ? icon
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
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

/// 进行中的封面：它本身就是主操作钮。
///
/// 封面压暗一层，中央一枚圆钮，外圈是进度环：
///
/// | 状态   | 压暗 | 圆钮                | 外圈        | 点了     |
/// |--------|------|---------------------|-------------|----------|
/// | 下载中 | 浅   | 暂停                | 白色，按进度 | 暂停     |
/// | 等待   | 深   | 暂停                | 只有轨道     | 暂停     |
/// | 暂停   | 深   | 继续                | 半透明，停在当前进度 | 继续 |
/// | 失败   | 深   | 重试（错误色底）     | 无          | 重试     |
///
/// 服务正在处理这条（暂停 / 继续的过渡期）时圆钮换成转圈、不响应点击。
class _ActiveCover extends StatelessWidget {
  const _ActiveCover({required this.task, required this.cover});

  final DownloadTask task;
  final Widget cover;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final scale = DownloadUiScale.of(context);
    final status = task.status;
    final downloading = status == DownloadStatus.downloading;
    final failed = status == DownloadStatus.failed;

    final (
      IconData icon,
      String tooltip,
      VoidCallback action,
    ) = switch (status) {
      DownloadStatus.paused => (
        Icons.play_arrow_rounded,
        t.download.resume,
        () => DownloadService.to.resumeTask(task.id),
      ),
      DownloadStatus.failed => (
        Icons.refresh_rounded,
        t.common.retry,
        () => DownloadService.to.retryTask(task.id),
      ),
      _ => (
        Icons.pause_rounded,
        t.download.pause,
        () => DownloadService.to.pauseTask(task.id),
      ),
    };

    final dimension = 40 * scale;
    return Obx(() {
      final processing = DownloadService.to.isTaskProcessing(task.id);
      DownloadService.to.getProgressTrigger(task.id).value;
      final progress = task.totalBytes > 0
          ? (task.downloadedBytes / task.totalBytes).clamp(0.0, 1.0)
          : null;

      final Widget glyph = processing
          ? SizedBox.square(
              key: const ValueKey('processing'),
              dimension: dimension * 0.45,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              icon,
              key: ValueKey(icon),
              size: dimension * 0.55,
              color: failed ? cs.onErrorContainer : Colors.white,
            );

      return Tooltip(
        message: tooltip,
        child: Stack(
          fit: StackFit.expand,
          children: [
            cover,
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              color: Colors.black.withValues(alpha: downloading ? 0.28 : 0.5),
            ),
            Center(
              child: SizedBox.square(
                dimension: dimension,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: failed
                            ? cs.errorContainer
                            : Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                    if (!failed)
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          end: status == DownloadStatus.pending
                              ? 0
                              : progress ?? 0,
                        ),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) =>
                            CircularProgressIndicator(
                              // 总大小未知时在下的给转圈，别停在 0 像是卡住了。
                              value: downloading && progress == null
                                  ? null
                                  : value,
                              strokeWidth: 2.5 * scale,
                              strokeCap: StrokeCap.round,
                              color: downloading
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.55),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.22,
                              ),
                            ),
                      ),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: Tween(
                                begin: 0.6,
                                end: 1.0,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                        child: glyph,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 水波纹要画在最上层：画在底层 Material 上会被封面整张盖住。
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                // 处理中也要接住点击（空回调）：交出 null 会漏到外层整卡，视频卡外层
                // 是「进在线详情」，转圈时多点一下就跳走了。
                child: InkWell(onTap: processing ? () {} : action),
              ),
            ),
          ],
        ),
      );
    });
  }
}
