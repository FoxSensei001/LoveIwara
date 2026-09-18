import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 手动输入下载路径（高级）。只负责收一条**看上去像绝对路径**的字符串；
/// 能不能用、要不要授权、确认与写配置，一律交给调用方走同一条
/// `applyDownloadLocation` 流程——这里绝不写配置、也不建目录。
///
/// 取消返回 null。
Future<String?> showManualDownloadPathDialog({String initialPath = ''}) {
  return showAppDialog<String>(
    _ManualDownloadPathDialog(initialPath: initialPath),
  );
}

class _ManualDownloadPathDialog extends StatefulWidget {
  const _ManualDownloadPathDialog({required this.initialPath});

  final String initialPath;

  @override
  State<_ManualDownloadPathDialog> createState() =>
      _ManualDownloadPathDialogState();
}

class _ManualDownloadPathDialogState extends State<_ManualDownloadPathDialog> {
  // ⛔ controller 归弹窗自己的 State 管：showAppDialog 的 future 在出场动画
  // 跑完才 resolve，但调用方若在 whenComplete 里 dispose 仍可能早于最后一帧。
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialPath,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final t = slang.t.download.location;
    final value = _controller.text.trim();
    String? error;
    if (value.isEmpty) {
      error = t.manualEmpty;
    } else if (!p.isAbsolute(value)) {
      error = t.manualNotAbsolute;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context, rootNavigator: true).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.location;
    final cs = Theme.of(context).colorScheme;
    return GlassAlertDialog(
      title: t.manualTitle,
      maxWidth: 520,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassInputSurface(
            borderRadius: 12,
            error: _error != null,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: null,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: glassFieldDecoration(
                context,
                label: t.manualLabel,
                hint: t.manualHint,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
            ),
          ),
          AnimatedSize(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            alignment: Alignment.topLeft,
            child: _error == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      _error!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: cs.error),
                    ),
                  ),
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        GlassDialogAction(label: t.manualSubmit, onPressed: _submit),
      ],
    );
  }
}
