import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class EmojiPreviewDialog extends StatelessWidget {
  final String emojiUrl;
  final String? emojiName;

  const EmojiPreviewDialog({super.key, required this.emojiUrl, this.emojiName});

  static void show({
    required BuildContext context,
    required String emojiUrl,
    String? emojiName,
  }) {
    showAppDialog(
      EmojiPreviewDialog(emojiUrl: emojiUrl, emojiName: emojiName),
    );
  }

  void _copyEmojiLink() {
    Clipboard.setData(ClipboardData(text: emojiUrl));
    showAppToast(
      t.emoji.copyEmojiLinkSuccess,
      type: AppToastType.success,
      position: AppToastPosition.top,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return GlassAlertDialog(
      title: emojiName ?? t.emoji.preview,
      content: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: emojiUrl,
            placeholder: (context, url) => Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
            fit: BoxFit.contain,
            width: 200,
            height: 200,
          ),
        ),
      ),
      actions: [
        GlassDialogAction(
          label: t.galleryDetail.copyLink,
          onPressed: _copyEmojiLink,
          emphasized: false,
        ),
      ],
    );
  }
}
