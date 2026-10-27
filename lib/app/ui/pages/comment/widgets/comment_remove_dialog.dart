import 'package:material_ui/material_ui.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentRemoveDialog extends StatefulWidget {
  final Function onDelete;

  const CommentRemoveDialog({super.key, required this.onDelete});

  @override
  State<CommentRemoveDialog> createState() => _CommentRemoveDialogState();
}

class _CommentRemoveDialogState extends State<CommentRemoveDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.common.confirmDelete,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(t.common.areYouSureYouWantToDeleteThisItem),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.common.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await widget.onDelete();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.common.delete, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
