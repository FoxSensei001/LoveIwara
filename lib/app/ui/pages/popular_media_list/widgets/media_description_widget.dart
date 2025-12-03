import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
  late GlobalKey _contentKey;
  late GlobalKey _measureKey;
  // 使用翻译控制器
  late final MarkdownTranslationController _translationController;
  final ConfigService _configService = Get.find();
  bool _hasOverflow = false;
  static const double _defaultMaxHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _contentKey = GlobalKey();
    _measureKey = GlobalKey();
    _translationController = MarkdownTranslationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
  }

  @override
  void didUpdateWidget(MediaDescriptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 description 内容变化时，重新检测溢出
    if (oldWidget.description != widget.description) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkOverflow();
      });
    }
  }

  void _checkOverflow() {
    // 使用隐藏的测量 widget 来获取内容的实际高度
    final RenderBox? measureBox =
        _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (measureBox != null && measureBox.hasSize) {
      final contentHeight = measureBox.size.height;
      final hasOverflow = contentHeight > _defaultMaxHeight;
      if (_hasOverflow != hasOverflow) {
        setState(() {
          _hasOverflow = hasOverflow;
        });
      }
    }
  }

  Widget _buildTranslationButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => IconButton(
            onPressed: _translationController.isTranslating.value
                ? null
                : () => _handleTranslation(),
            icon: _translationController.isTranslating.value
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
        ),
        TranslationLanguageSelector(
          compact: true,
          selectedLanguage: _configService.currentTranslationSort,
          onLanguageSelected: (sort) {
            _configService.updateTranslationLanguage(sort);
            if (_translationController.hasTranslation) {
              _handleTranslation();
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleTranslation() async {
    // 直接使用原始description进行翻译
    await _translationController.translate(widget.description ?? '', originalText: widget.description);
    // 翻译后重新检测溢出
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
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
              Row(
                children: [
                  Icon(Icons.description, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    t.mediaList.personalIntroduction,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              _buildTranslationButton(context),
            ],
          ),
          const SizedBox(height: 8),
          // 隐藏的测量 widget，用于检测内容的实际高度
          Offstage(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomMarkdownBody(
                    key: _measureKey,
                    data: widget.description ?? '',
                    originalData: widget.description,
                    showTranslationButton: false,
                    translationController: _translationController,
                  ),
                ],
              ),
            ),
          ),
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
                      maxHeight: expanded || !_hasOverflow 
                          ? double.infinity 
                          : _defaultMaxHeight,
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      key: _contentKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomMarkdownBody(
                            data: widget.description ?? '',
                            originalData: widget.description,
                            showTranslationButton: false,
                            translationController: _translationController,
                          ),
                          if (!expanded && _hasOverflow) const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!expanded && _hasOverflow)
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
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.0),
                                Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.common.expand,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_hasOverflow) const SizedBox(height: 4),
          if (expanded && _hasOverflow)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.isDescriptionExpanded.value = false;
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.common.collapse,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }
}
