import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/download/download_task.model.dart'
    hide FileSystemException;
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 「移动已下载文件」几张弹窗共用的明细积木：统计条、可折叠分组、条目行、
/// 路径断点高亮。
///
/// # 宽窄屏两套排法（分界 [GlassTokens.dialogWideBreakpoint]）
///
/// - **宽屏（PC / 平板横屏）**：面板放宽到 [relocationDialogMaxWidth]，条目行
///   直接摊开「从 / 到」两行路径（单行省略，悬停出全路径），桌面端每行带
///   「在文件夹中显示」。空间够，信息就一次给全。
/// - **窄屏（手机）**：面板贴近屏宽，条目行只放标题 + 一句原因，路径收进
///   「显示路径」里，点开才出现、可整段选中复制。手机上一屏摆十几条长路径
///   只会是一片噪音。
bool isRelocationWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= GlassTokens.dialogWideBreakpoint;

const double relocationDialogMaxWidth = 720;

/// 窄屏把面板边距收到 12：明细是列表，横向每一点都要给正文。
EdgeInsets relocationDialogInset(BuildContext context) =>
    isRelocationWide(context)
    ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
    : const EdgeInsets.symmetric(horizontal: 12, vertical: 16);

bool get _isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

String formatRelocationBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

String formatRelocationDate(DateTime time) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)}';
}

/// 任务的人话标题：视频 / 图库用 Iwara 上的标题，其余退回文件名。
String relocationTaskTitle(DownloadTask task) {
  final data = task.extData?.data;
  String? title;
  if (data != null) {
    title = switch (task.extData!.type) {
      DownloadTaskExtDataType.video => VideoDownloadExtData.fromJson(
        data,
      ).title,
      DownloadTaskExtDataType.gallery => GalleryDownloadExtData.fromJson(
        data,
      ).title,
    };
  }
  if (title != null && title.trim().isNotEmpty) return title.trim();
  final name = task.fileName.trim();
  return name.isNotEmpty ? name : p.basename(task.savePath);
}

IconData relocationTaskIcon(DownloadTask task) {
  if (task.extData?.type == DownloadTaskExtDataType.gallery) {
    return Icons.photo_library_outlined;
  }
  if (task.mediaType == 'video' ||
      task.extData?.type == DownloadTaskExtDataType.video) {
    return Icons.movie_outlined;
  }
  return Icons.image_outlined;
}

/// 单个任务的体积描述：图库的 totalBytes 存的是图片张数，不是字节。
String relocationTaskSize(DownloadTask task, {int? bytes}) {
  final t = slang.t.download.relocation;
  if (bytes != null) return formatRelocationBytes(bytes);
  if (task.extData?.type == DownloadTaskExtDataType.gallery) {
    return t.galleryImages(count: task.totalBytes);
  }
  return task.totalBytes > 0 ? formatRelocationBytes(task.totalBytes) : '';
}

Future<void> revealInFileManager(String target) async {
  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', ['/select,', target]);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', target]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [p.dirname(target)]);
    }
  } catch (e) {
    LogUtils.w('打开文件管理器失败: $e', 'RelocationDetail');
  }
}

void copyPathToClipboard(String target) {
  Clipboard.setData(ClipboardData(text: target));
  showAppToast(
    slang.t.download.relocation.pathCopied,
    type: AppToastType.success,
  );
}

// ---------------------------------------------------------------------------
// 统计条
// ---------------------------------------------------------------------------

class RelocationStat {
  const RelocationStat({
    required this.label,
    required this.value,
    this.caption,
    this.tone = RelocationTone.neutral,
  });

  final String label;
  final String value;
  final String? caption;
  final RelocationTone tone;
}

enum RelocationTone { neutral, positive, warning, danger }

Color relocationToneColor(ColorScheme cs, RelocationTone tone) =>
    switch (tone) {
      RelocationTone.neutral => cs.onSurfaceVariant,
      RelocationTone.positive => cs.primary,
      RelocationTone.warning => Colors.orange.shade700,
      RelocationTone.danger => cs.error,
    };

/// 顶部一排数字：宽屏横排均分，窄屏也横排但更紧（最多 3 格，文字不换行）。
class RelocationStatsBar extends StatelessWidget {
  const RelocationStatsBar({super.key, required this.stats});

  final List<RelocationStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final wide = isRelocationWide(context);
    // 等高：只有某一格带副标题（体积）时，其余格子也要一样高。
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) SizedBox(width: wide ? 12 : 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 14 : 10,
                  vertical: wide ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stats[i].value,
                      maxLines: 1,
                      style:
                          (wide
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: relocationToneColor(cs, stats[i].tone),
                              ),
                    ),
                    if (stats[i].caption != null)
                      Text(
                        stats[i].caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 「目标位置」那一格：路径完整可选中，桌面端带「在文件夹中显示」。
class RelocationDestinationBox extends StatelessWidget {
  const RelocationDestinationBox({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.destination,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SelectableText(path, style: _monoStyle(theme)),
              ],
            ),
          ),
          _PathActions(target: path),
        ],
      ),
    );
  }
}

TextStyle? _monoStyle(ThemeData theme, {Color? color}) => theme
    .textTheme
    .bodySmall
    ?.copyWith(fontFamily: 'monospace', color: color, height: 1.35);

/// 路径旁的小图标键不要 48 的默认触控框：一行路径会被撑得比文字高一倍。
/// 36 仍够手指点（且两枚之间不贴死）。
const _compactButton = BoxConstraints.tightFor(width: 36, height: 36);

/// 路径旁的小动作：桌面「在文件夹中显示」，各端「复制路径」。
class _PathActions extends StatelessWidget {
  const _PathActions({required this.target, this.revealable = true});

  final String target;
  final bool revealable;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isDesktop && revealable)
          IconButton(
            visualDensity: VisualDensity.compact,
            constraints: _compactButton,
            padding: EdgeInsets.zero,
            iconSize: 18,
            tooltip: t.revealInFolder,
            icon: const Icon(Icons.open_in_new),
            onPressed: () => revealInFileManager(target),
          ),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: _compactButton,
          padding: EdgeInsets.zero,
          iconSize: 18,
          tooltip: t.copyPath,
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => copyPathToClipboard(target),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 分组
// ---------------------------------------------------------------------------

/// 一组条目：标题行（图标 + 名称 + 计数）可点折叠。条目多时默认折叠由调用方
/// 决定——「将跳过」这类用户最想看原因的组默认展开。
class RelocationSection extends StatefulWidget {
  const RelocationSection({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.children,
    this.tone = RelocationTone.neutral,
    this.subtitle,
    this.initiallyExpanded = true,
    this.trailing,
  });

  /// 标题行右侧、折叠箭头之前的小动作（如「全选」）。
  final Widget? trailing;

  final IconData icon;
  final String title;
  final int count;
  final List<Widget> children;
  final RelocationTone tone;
  final String? subtitle;
  final bool initiallyExpanded;

  @override
  State<RelocationSection> createState() => _RelocationSectionState();
}

class _RelocationSectionState extends State<RelocationSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = relocationToneColor(cs, widget.tone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(widget.icon, size: 18, color: color),
                const SizedBox(width: 8),
                // ⛔ 标题与计数一起吃掉剩余宽度，箭头贴右；标题用 Flexible 配
                // Spacer 的话两者平分剩余空间，箭头停在半路、标题提前折行。
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${widget.count}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 4, 6),
                        child: Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ...widget.children,
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 条目行
// ---------------------------------------------------------------------------

/// 一条任务：标题、体积、一句具体原因（带语气色），以及「从 / 到」两条路径。
///
/// 路径的呈现随屏宽而变，见本文件顶部说明。
class RelocationItemRow extends StatefulWidget {
  const RelocationItemRow({
    super.key,
    required this.task,
    this.size,
    this.detail,
    this.detailTone = RelocationTone.neutral,
    this.extraDetail,
    this.fromPath,
    this.toPath,
    this.fromRevealable = true,
    this.toRevealable = true,
    this.action,
    this.actionTone = RelocationTone.positive,
    this.leading,
    this.onTap,
  });

  final DownloadTask task;
  final String? size;

  /// 这一条将被怎么处理（「将重新下载」「将移除」），跟在原因后面、带箭头。
  final String? action;
  final RelocationTone actionTone;

  /// 行首控件（如勾选框），放在类型图标之前。
  final Widget? leading;

  /// 点整行（如打开单条详情）。
  final VoidCallback? onTap;

  /// 具体原因 / 状态，一句话。
  final String? detail;
  final RelocationTone detailTone;

  /// 第二句补充（如系统原始错误），弱化显示。
  final String? extraDetail;
  final String? fromPath;
  final String? toPath;

  /// 路径还在不在：不在的就不给「在文件夹中显示」。
  final bool fromRevealable;
  final bool toRevealable;

  @override
  State<RelocationItemRow> createState() => _RelocationItemRowState();
}

class _RelocationItemRowState extends State<RelocationItemRow> {
  bool _showPaths = false;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final wide = isRelocationWide(context);
    final hasPaths = widget.fromPath != null || widget.toPath != null;
    // 正文与标题左对齐：类型图标 18 + 间距 10；有行首控件（勾选框，固定 36 宽）时再让出它。
    final indent = widget.leading == null ? 28.0 : 64.0;
    final pathsVisible = wide || _showPaths;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              widget.leading == null ? 12 : 4,
              10,
              wide ? 8 : 12,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.leading != null) widget.leading!,
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        relocationTaskIcon(widget.task),
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        relocationTaskTitle(widget.task),
                        maxLines: wide ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.size != null && widget.size!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        widget.size!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.detail != null)
                  Padding(
                    padding: EdgeInsets.only(left: indent, top: 4),
                    child: Text(
                      widget.detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: relocationToneColor(cs, widget.detailTone),
                      ),
                    ),
                  ),
                if (widget.action != null)
                  Padding(
                    padding: EdgeInsets.only(left: indent, top: 2),
                    child: Text(
                      '→ ${widget.action!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: relocationToneColor(cs, widget.actionTone),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (widget.onTap != null)
                  Padding(
                    padding: EdgeInsets.only(left: indent, top: 2),
                    child: Text(
                      '${t.tapForDetail} ›',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                      ),
                    ),
                  ),
                if (widget.extraDetail != null)
                  Padding(
                    padding: EdgeInsets.only(left: indent, top: 2),
                    child: SelectableText(
                      widget.extraDetail!,
                      style: _monoStyle(theme, color: cs.onSurfaceVariant),
                    ),
                  ),
                if (hasPaths && !wide)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RelocationTextLink(
                      padding: EdgeInsets.only(
                        left: indent,
                        right: 8,
                        top: 6,
                        bottom: 6,
                      ),
                      icon: _showPaths ? Icons.expand_less : Icons.expand_more,
                      label: _showPaths ? t.hidePaths : t.showPaths,
                      onTap: () => setState(() => _showPaths = !_showPaths),
                    ),
                  ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: hasPaths && pathsVisible
                      ? Padding(
                          padding: EdgeInsets.only(left: indent, top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.fromPath != null)
                                _PathLine(
                                  label: t.from,
                                  path: widget.fromPath!,
                                  wide: wide,
                                  revealable: widget.fromRevealable,
                                ),
                              if (widget.toPath != null)
                                _PathLine(
                                  label: t.to,
                                  path: widget.toPath!,
                                  wide: wide,
                                  revealable: widget.toRevealable,
                                ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 「从 / 到」一行。宽屏单行省略 + 悬停看全；窄屏整段折行、可选中。
class _PathLine extends StatelessWidget {
  const _PathLine({
    required this.label,
    required this.path,
    required this.wide,
    required this.revealable,
  });

  final String label;
  final String path;
  final bool wide;
  final bool revealable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelWidget = SizedBox(
      width: 44,
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
    if (wide) {
      return Row(
        children: [
          labelWidget,
          Expanded(
            child: Tooltip(
              message: path,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _monoStyle(theme),
              ),
            ),
          ),
          _PathActions(target: path, revealable: revealable),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: labelWidget),
          Expanded(child: SelectableText(path, style: _monoStyle(theme))),
          _PathActions(target: path, revealable: revealable),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 路径断点
// ---------------------------------------------------------------------------

/// 把一条路径分成「仍然存在」与「已经不在」两截上色，一眼看出断在哪一级。
class PathBreakView extends StatelessWidget {
  const PathBreakView({
    super.key,
    required this.path,
    required this.existingPrefix,
  });

  final String path;

  /// [path] 里仍然存在的最长前缀；为 null 表示整条都不在。
  final String? existingPrefix;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final prefix = existingPrefix;
    final String kept;
    final String lost;
    if (prefix != null &&
        (p.isWithin(prefix, path) || p.equals(prefix, path))) {
      kept = prefix;
      lost = path.substring(prefix.length);
    } else {
      kept = '';
      lost = path;
    }
    final base = _monoStyle(theme);
    final lostColor = cs.error;

    Widget legendDot(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.recordedLocation,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (kept.isNotEmpty) ...[
                legendDot(cs.onSurface, t.legendExists),
                const SizedBox(width: 10),
              ],
              legendDot(lostColor, t.legendMissing),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                tooltip: t.copyPath,
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => copyPathToClipboard(path),
              ),
            ],
          ),
          SelectableText.rich(
            TextSpan(
              style: base,
              children: [
                TextSpan(
                  text: kept,
                  style: base?.copyWith(color: cs.onSurface),
                ),
                TextSpan(
                  text: lost,
                  style: base?.copyWith(
                    color: lostColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: lostColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 行内的轻量文字开关（显示路径 / 全选一类）。
///
/// 它不是动作键：在一排详情里摆一只按钮胶囊太重，只做成可点的主色文字。
class RelocationTextLink extends StatelessWidget {
  const RelocationTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
