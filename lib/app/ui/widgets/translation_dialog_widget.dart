import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';

class TranslationDialog extends StatefulWidget {
  final String text;

  const TranslationDialog({
    super.key,
    required this.text,
  });

  @override
  State<TranslationDialog> createState() => _TranslationDialogState();
}

class _TranslationDialogState extends State<TranslationDialog> {
  final ConfigService _configService = Get.find();
  final TranslationService _translationService = Get.find();

  bool _isTranslating = false;
  String? _translatedText;
  String? _error;

  Future<void> _handleTranslation() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
      _error = null;
    });

    ApiResult<String> result = await _translationService.translate(widget.text);

    setState(() {
      _isTranslating = false;
      if (result.isSuccess) {
        _translatedText = result.data;
      } else {
        _error = result.message;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // 弹窗出现后自动开始翻译
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTranslation();
    });
  }

  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      initialValue: _configService.currentTranslationLanguage,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CommonConstants.translationSorts
                    .firstWhere((sort) =>
                        sort.extData ==
                        _configService.currentTranslationLanguage)
                    .label,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                size: 24,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (context) {
        return CommonConstants.translationSorts.map((sort) {
          return PopupMenuItem<String>(
            value: sort.extData,
            child: Text(sort.label),
          );
        }).toList();
      },
      onSelected: (value) {
        final sort = CommonConstants.translationSorts.firstWhere(
          (sort) => sort.extData == value,
        );
        _configService.updateTranslationLanguage(sort);
        setState(() {
          _translatedText = null;
        });
        _handleTranslation();
      },
    );
  }

  Widget _buildTextContainer(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: title == t.common.translationResult && _isTranslating
                    ? _buildShimmerLoading(theme)
                    : content,
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(11)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (title == t.common.translationResult)
                      Text(
                        'Powered by Google',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: '80%'.toString().contains('%') 
                ? MediaQuery.of(context).size.width * 0.8 
                : double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: '60%'.toString().contains('%') 
                ? MediaQuery.of(context).size.width * 0.6 
                : double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildLanguageSelector(),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 原文
                      _buildTextContainer(
                        context,
                        title: t.common.originalText,
                        content: SelectableText(widget.text),
                      ),

                      const SizedBox(height: 16),

                      // 译文
                      _buildTextContainer(
                        context,
                        title: t.common.translationResult,
                        content: _error != null
                            ? Text(
                                _error!,
                                style:
                                    TextStyle(color: theme.colorScheme.error),
                              )
                            : SelectableText(_translatedText ?? ''),
                      ),
                    ],
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
