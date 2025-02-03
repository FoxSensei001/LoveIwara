import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/widgets/translation_powered_by_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';

import '../../../widgets/custom_markdown_body_widget.dart';

class MediaDescriptionWidget extends StatefulWidget {
  final String? description;
  final RxBool isDescriptionExpanded;
  final int defaultMaxLines;

  const MediaDescriptionWidget({
    super.key,
    required this.description,
    required this.isDescriptionExpanded,
    this.defaultMaxLines = 3,
  });

  @override
  State<MediaDescriptionWidget> createState() => _MediaDescriptionWidgetState();
}

class _MediaDescriptionWidgetState extends State<MediaDescriptionWidget> {
  bool _showTranslationMenu = false;
  bool _isTranslating = false;
  String? _translatedText;
  final GlobalKey _contentKey = GlobalKey();
  bool _hasOverflow = false;

  final TranslationService _translationService = Get.find();
  final ConfigService _configService = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
  }

  void _checkOverflow() {
    final RenderBox? renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _hasOverflow = renderBox.size.height > 200;
      });
    }
  }

  Widget _buildTranslationButton(BuildContext context) {
    final configService = Get.find<ConfigService>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _isTranslating ? null : () => _handleTranslation(),
          icon: _isTranslating
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.translate,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        TranslationLanguageSelector(
          compact: true,
          selectedLanguage: configService.currentTranslationSort,
          onLanguageSelected: (sort) {
            configService.updateTranslationLanguage(sort);
            if (_translatedText != null) {
              _handleTranslation();
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleTranslation() async {
    if (_isTranslating) return;

    setState(() => _isTranslating = true);

    ApiResult<String> result = await _translationService.translate(widget.description ?? '');
    if (result.isSuccess) {
      setState(() {
        _translatedText = result.data;
        _isTranslating = false;
      });
    } else {
      setState(() {
        _translatedText = slang.t.errors.translationFailedPleaseTryAgainLater;
        _isTranslating = false;
      });
    }
  }

  Widget _buildTranslatedContent(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, size: 14),
              const SizedBox(width: 4),
              Text(
                t.common.translationResult,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              translationPoweredByWidget(context, fontSize: 10)
            ],
          ),
          const SizedBox(height: 8),
          if (_translatedText == t.errors.translationFailedPleaseTryAgainLater)
            Text(
              _translatedText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            )
          else
            CustomMarkdownBody(data: _translatedText!),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Obx(() {
      final expanded = widget.isDescriptionExpanded.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.mediaList.personalIntroduction,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTranslationButton(context),
            ],
          ),
          const SizedBox(height: 8),
          ClipRect(
            child: Stack(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: expanded ? double.infinity : 200,
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      key: _contentKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomMarkdownBody(data: widget.description ?? ''),
                          if (_translatedText != null) ...[
                            const SizedBox(height: 12),
                            _buildTranslatedContent(context),
                          ],
                          if (!expanded) 
                            const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!expanded)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.isDescriptionExpanded.value = true;
                          _checkOverflow();
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.surface.withOpacity(0),
                                Theme.of(context).colorScheme.surface.withOpacity(0.8),
                                Theme.of(context).colorScheme.surface,
                              ],
                              stops: const [0.0, 0.5, 0.8],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    t.common.expand,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (expanded)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  widget.isDescriptionExpanded.value = false;
                  _checkOverflow();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.common.collapse),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_up, size: 16),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
