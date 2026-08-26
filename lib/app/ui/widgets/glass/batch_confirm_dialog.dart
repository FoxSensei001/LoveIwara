import 'package:flutter/material.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 批量危险动作的**唯一**二次确认弹窗。
///
/// 收口前：批量删除下载 / 删除历史 / 删除播放列表 / 移出播放列表 / 取消最爱
/// 五处各写了一份 `AlertDialog`，措辞、按钮顺序、危险色用法都不一样，其中
/// 下载页那份还是裸 `showDialog`（不走 `GlassDialogRoute`，出入场动画与全站
/// 不是一套）。结构层面现在收进 [GlassAlertDialog]（标题行/关闭钮/按钮配色
/// 都是它管），这里只拼正文。
///
/// 相比原来的「确定要删除选中的 N 条记录吗？」，这里多做两件事：
///
/// - **说清楚删的是什么**：正文下方列出前几项的标题胶囊 + 「还有 N 项」。
///   批量操作最容易出的事故是"我以为我选的是别的"，而原来的弹窗把用户唯一
///   的核对机会关在了外面。
/// - **主按钮用语义色 + 具体动词**（「删除」/「取消最爱」），不是通用的
///   「确认」——按钮上写着什么，按下去就发生什么。
///
/// 不可逆的动作（删除已下载的文件）传 [warning] 再加一行红字。
///
/// 返回 `true` 表示用户确认。
Future<bool> showBatchConfirmDialog({
  required String title,
  required String message,
  required String confirmLabel,
  List<String> previewTitles = const [],
  int totalCount = 0,
  bool destructive = true,
  String? warning,
}) async {
  final result = await showAppDialog<bool>(
    _BatchConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      previewTitles: previewTitles,
      totalCount: totalCount,
      destructive: destructive,
      warning: warning,
    ),
  );
  return result == true;
}

class _BatchConfirmDialog extends StatelessWidget {
  const _BatchConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.previewTitles,
    required this.totalCount,
    required this.destructive,
    required this.warning,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final List<String> previewTitles;
  final int totalCount;
  final bool destructive;
  final String? warning;

  /// 预览最多列几项：再多就不是"核对"而是"又一份列表"了。
  static const int _maxPreview = 3;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final shown = previewTitles.take(_maxPreview).toList();
    final int remaining = totalCount - shown.length;

    return GlassAlertDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (shown.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final title in shown)
                  _PreviewChip(label: title, dashed: false),
                if (remaining > 0)
                  _PreviewChip(
                    label: t.common.andMoreItems(num: remaining),
                    dashed: true,
                  ),
              ],
            ),
          ],
          if (warning != null) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    warning!,
                    style: TextStyle(fontSize: 12.5, color: cs.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        GlassDialogAction(
          label: t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: confirmLabel,
          destructive: destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label, required this.dashed});

  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
        border: dashed
            ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.6))
            : null,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          color: dashed ? cs.onSurfaceVariant : cs.onSurface,
        ),
      ),
    );
  }
}
