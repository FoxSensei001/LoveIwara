import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 标签翻译纠错 / 反馈入口（项目 issue）。
const String kTagTranslationFeedbackUrl =
    'https://github.com/FoxSensei001/LoveIwara/issues/98';

/// 复制文本到剪贴板并提示。
void copyTagText(String text) {
  final data = DataWriterItem();
  data.add(Formats.plainText(text));
  SystemClipboard.instance?.write([data]);
  showToastWidget(
    MDToastWidget(
      message: slang.t.common.copiedToClipboard,
      type: MDToastType.success,
    ),
    position: ToastPosition.bottom,
    duration: const Duration(seconds: 1),
  );
}

/// 弹出标签详情：同时展示「译文」与「原始标签」，并各自提供复制按钮。
Future<void> showTagDetailDialog(BuildContext context, Tag tag) {
  final translation = TagLocalizationService.displayName(tag.id);
  return showDialog(
    context: context,
    builder: (context) {
      final t = slang.Translations.of(context);
      return AlertDialog(
        title: Text(t.common.tagInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TagDetailCopyRow(
              label: t.common.tagTranslation,
              value: translation,
            ),
            const SizedBox(height: 12),
            _TagDetailCopyRow(
              label: t.common.tagOriginalKey,
              value: tag.id,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // 翻译纠错 / 反馈引导
            const TagTranslationFeedbackLink(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.close),
          ),
        ],
      );
    },
  );
}

/// 弹出「标签本地化」引导说明：解释译名来源、搜索方式，并提供反馈入口。
Future<void> showTagLocalizationGuideDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      final t = slang.Translations.of(context);
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.translate,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(t.common.tagLocalizationGuideTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.common.tagLocalizationGuideContent,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              const TagTranslationFeedbackLink(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.close),
          ),
        ],
      );
    },
  );
}

/// 翻译纠错 / 反馈引导链接（弹窗底部复用）。
class TagTranslationFeedbackLink extends StatelessWidget {
  const TagTranslationFeedbackLink({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => launchUrl(
        Uri.parse(kTagTranslationFeedbackUrl),
        mode: LaunchMode.externalApplication,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          children: [
            Icon(
              Icons.feedback_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                t.common.tagTranslationFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 标签详情弹窗里的一行：左侧标签名+取值，右侧复制按钮。
class _TagDetailCopyRow extends StatelessWidget {
  final String label;
  final String value;

  const _TagDetailCopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: t.common.copy,
          onPressed: () => copyTagText(value),
        ),
      ],
    );
  }
}
