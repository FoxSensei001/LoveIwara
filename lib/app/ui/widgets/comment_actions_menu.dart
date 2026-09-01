import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 评论 / 论坛楼层 / 私信长按操作菜单：复制全文、选择复制、回复、翻译、删除。
///
/// 正文里的 SelectionArea 长按选中已被长按手势替代（见
/// CustomMarkdownBody.onLongPress），「选择复制」在弹窗里补回自由选取能力。
/// [onReply] / [onTranslate] / [onDelete] 为 null 时不显示对应项（锁定帖 /
/// 子回复 / 对方消息不可删等场景）。
///
/// 面板贴着手指弹出（[globalPosition] 取长按落点，见 [showGlassMenu] 的
/// globalAnchor）——原来吐的是底部 sheet，一条只有四五项的菜单从屏幕底下升上来，
/// 既离手指远又和全站其它菜单不是一套东西。
Future<void> showCommentActionsMenu({
  required BuildContext context,
  required Offset globalPosition,
  required String text,
  VoidCallback? onReply,
  VoidCallback? onTranslate,
  VoidCallback? onDelete,
}) async {
  final t = slang.Translations.of(context);
  final action = await showGlassMenu<String>(
    anchorContext: context,
    globalAnchor: globalPosition & Size.zero,
    entries: [
      GlassMenuOption<String>(
        value: 'copy',
        icon: Icons.copy,
        label: t.common.copy,
      ),
      GlassMenuOption<String>(
        value: 'selectCopy',
        icon: Icons.text_fields,
        label: t.common.selectCopy,
      ),
      if (onReply != null)
        GlassMenuOption<String>(
          value: 'reply',
          icon: Icons.reply,
          label: t.common.reply,
        ),
      if (onTranslate != null)
        GlassMenuOption<String>(
          value: 'translate',
          icon: Icons.translate,
          label: t.common.translate,
        ),
      if (onDelete != null) ...[
        const GlassMenuSeparator(),
        GlassMenuOption<String>(
          value: 'delete',
          icon: Icons.delete_outline,
          label: t.common.delete,
          destructive: true,
        ),
      ],
    ],
  );
  switch (action) {
    case 'copy':
      await Clipboard.setData(ClipboardData(text: text));
      showAppToast(t.common.copiedToClipboard, type: AppToastType.success);
    case 'selectCopy':
      _showSelectCopyDialog(text);
    case 'reply':
      onReply!();
    case 'translate':
      onTranslate!();
    case 'delete':
      onDelete!();
  }
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
