import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CrashRecoveryDialog {
  static Future<void> show(
    BuildContext context,
    CrashRecoveryResult crashInfo,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CrashRecoveryDialogWidget(crashInfo: crashInfo),
    );
  }
}

class _CrashRecoveryDialogWidget extends StatefulWidget {
  final CrashRecoveryResult crashInfo;

  const _CrashRecoveryDialogWidget({required this.crashInfo});

  @override
  State<_CrashRecoveryDialogWidget> createState() =>
      _CrashRecoveryDialogWidgetState();
}

class _CrashRecoveryDialogWidgetState
    extends State<_CrashRecoveryDialogWidget> {
  static const String _supportEmail = 'miximixihuabulaji@proton.me';

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.error,
        size: 32,
      ),
      title: Text(t.crashRecoveryDialog.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.crashRecoveryDialog.description),
          const SizedBox(height: 12),
          if (widget.crashInfo.previousVersion != null)
            Text(
              t.crashRecoveryDialog.previousVersion(
                version: widget.crashInfo.previousVersion!,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (widget.crashInfo.previousStartTime != null)
            Text(
              t.crashRecoveryDialog.previousStart(
                time: _formatTime(widget.crashInfo.previousStartTime!),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (widget.crashInfo.fatalError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                t.crashRecoveryDialog.lastException(
                  message: _limitText(widget.crashInfo.fatalError!.message, 120),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          if (widget.crashInfo.lastHangEvent != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.crashInfo.lastHangEvent!.recovered
                    ? t.crashRecoveryDialog.lastHangRecovered
                    : t.crashRecoveryDialog.lastHangStalled(
                        stalledMs: widget.crashInfo.lastHangEvent!.stalledMs,
                      ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            t.crashRecoveryDialog.exportGuide,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.crashRecoveryDialog.privacyHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _copySupportEmail,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _supportEmail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.crashRecoveryDialog.issueWarning,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.crashRecoveryDialog.acknowledge),
        ),
      ],
    );
  }

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(slang.t.crashRecoveryDialog.supportEmailCopied),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _limitText(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...';
  }
}
