import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 评论 / 论坛楼层 / 私信长按操作弹层：复制全文、选择复制、回复、翻译、删除。
///
/// 正文里的 SelectionArea 长按选中已被长按手势替代（见
/// CustomMarkdownBody.onLongPress），「选择复制」在弹窗里补回自由选取能力。
/// [onReply] / [onTranslate] / [onDelete] 为 null 时不显示对应项（锁定帖 /
/// 子回复 / 对方消息不可删等场景）。
Future<void> showCommentActionsSheet({
  required BuildContext context,
  required String text,
  VoidCallback? onReply,
  VoidCallback? onTranslate,
  VoidCallback? onDelete,
}) {
  final t = slang.Translations.of(context);
  final colorScheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          top: 8,
          bottom: computeSheetBottomInset(sheetContext) + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽把手
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(t.common.copy),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Clipboard.setData(ClipboardData(text: text));
                showGlassToast(
                  t.common.copiedToClipboard,
                  type: GlassToastType.success,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(t.common.selectCopy),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showSelectCopyDialog(text);
              },
            ),
            if (onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: Text(t.common.reply),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onReply();
                },
              ),
            if (onTranslate != null)
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(t.common.translate),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onTranslate();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  t.common.delete,
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onDelete();
                },
              ),
          ],
        ),
      );
    },
  );
}

/// 「选择复制」：弹出可自由选取的原文对话框。
void _showSelectCopyDialog(String text) {
  showAppDialog(_SelectCopyDialog(text: text));
}

class _SelectCopyDialog extends StatelessWidget {
  const _SelectCopyDialog({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.text_fields, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.common.selectCopy,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    text,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
