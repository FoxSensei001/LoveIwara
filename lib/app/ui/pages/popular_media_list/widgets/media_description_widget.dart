import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/app/ui/widgets/markdown_translation_controller.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../../widgets/custom_markdown_body_widget.dart';

class MediaDescriptionWidget extends StatefulWidget {
  final String? description;
  final RxBool isDescriptionExpanded;
  final int defaultMaxLines;
  final void Function(Duration position)? onTimestampSeek;

  const MediaDescriptionWidget({
    super.key,
    required this.description,
    required this.isDescriptionExpanded,
    this.defaultMaxLines = 3,
    this.onTimestampSeek,
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

  /// 「显示原始文本」由标题行那枚 only-icon 钮受控（正文内置开关已关闭），
  /// 初值仍沿用全局设置项。三处正文（测量副本 / 展开态 / 折叠态）共用同一份状态。
  late bool _showOriginal;

  /// 正文加工前后确实有差异时才让那枚钮长出来。
  /// 由**离屏测量副本**上报——它常驻树上，不像可见正文那样在展开/折叠之间重建。
  bool _hasProcessedContent = false;
  static const double _defaultMaxHeight = 200.0;
  // 折叠态底部预留的空白带：正文视口比遮罩矮这么多，遮罩最后一行像素下面不放任何内容。
  // ShaderMask 的 dstIn 只作用在遮罩矩形内，矩形底边落在物理像素中间时最后一行可能没被
  // 完全覆盖，之前正文正好被裁在这条边上，于是漏出一道「没被渐隐」的清晰文字缝隙。
  static const double _fadeTailHeight = 24.0;
  // 渐隐从这里开始、到正文视口底部（也就是空白带顶部）刚好全透明，
  // 之后一直保持透明到遮罩底边。
  static const double _fadeStartStop = 0.55;
  static const double _fadeEndStop =
      (_defaultMaxHeight - _fadeTailHeight) / _defaultMaxHeight;

  @override
  void initState() {
    super.initState();
    _contentKey = GlobalKey();
    _measureKey = GlobalKey();
    _translationController = MarkdownTranslationController();
    _showOriginal = _configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
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

  /// 与评论区（comment_item_widget.dart）保持一致的胶囊高度
  static const double _translationPillHeight = 30.0;

  /// 翻译入口：翻译图标（翻译中转菊花）+ 紧凑语言选择器，合装进一个胶囊。
  /// 样式与 CommentItem._buildTranslationControls 保持一致。
  Widget _buildTranslationButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: _translationPillHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final busy = _translationController.isTranslating.value;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: busy ? null : _handleTranslation,
                child: Container(
                  height: _translationPillHeight,
                  padding: const EdgeInsets.only(left: 10, right: 4),
                  alignment: Alignment.center,
                  child: busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.translate,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                ),
              );
            }),
            // 收紧语言选择器（内部是默认 48 触摸目标的 IconButton）到胶囊高度
            Obx(
              () => SizedBox(
                width: 34,
                height: _translationPillHeight,
                child: IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      fixedSize: const Size(34, _translationPillHeight),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  child: TranslationLanguageSelector(
                    compact: true,
                    extrimCompact: true,
                    selectedLanguage: _configService.currentTranslationSort,
                    onLanguageSelected: (sort) {
                      _configService.updateTranslationLanguage(sort);
                      if (_translationController.hasTranslation) {
                        _handleTranslation();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTranslation() async {
    // 直接使用原始description进行翻译
    await _translationController.translate(
      widget.description ?? '',
      originalText: widget.description,
    );
    // 翻译后重新检测溢出
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
  }

  Widget _buildExpandButton(BuildContext context, String label) {
    return FilledButton.icon(
      onPressed: _expandDescription,
      icon: const Icon(Icons.keyboard_arrow_down),
      label: Text(label),
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
      ),
    );
  }

  void _expandDescription() {
    widget.isDescriptionExpanded.value = true;
    _checkOverflow();
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkdownOriginalTextToggle(
                    visible: _hasProcessedContent,
                    showOriginal: _showOriginal,
                    pillSize: _translationPillHeight,
                    padding: const EdgeInsets.only(right: 8),
                    onChanged: (v) {
                      setState(() => _showOriginal = v);
                      // 原文/处理后文本高度不同，折叠阈值要跟着重算
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _checkOverflow();
                      });
                    },
                  ),
                  _buildTranslationButton(context),
                ],
              ),
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
                    onTimestampSeek: widget.onTimestampSeek,
                    initialShowUnprocessedText: _showOriginal,
                    // 只由这份常驻的测量副本上报，避免展开/折叠切换时重复通知
                    onProcessedContentChanged: (hasProcessed) {
                      if (_hasProcessedContent == hasProcessed) return;
                      setState(() => _hasProcessedContent = hasProcessed);
                    },
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded || !_hasOverflow
                  ? SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        key: _contentKey,
                        child: CustomMarkdownBody(
                          data: widget.description ?? '',
                          originalData: widget.description,
                          showTranslationButton: false,
                          translationController: _translationController,
                          onTimestampSeek: widget.onTimestampSeek,
                          initialShowUnprocessedText: _showOriginal,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: _defaultMaxHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0.0, _fadeStartStop, _fadeEndStop],
                              // clamp（默认）保证 _fadeEndStop 之后一直是全透明
                            ).createShader(bounds),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    key: _contentKey,
                                    child: CustomMarkdownBody(
                                      data: widget.description ?? '',
                                      originalData: widget.description,
                                      showTranslationButton: false,
                                      translationController:
                                          _translationController,
                                      onTimestampSeek: widget.onTimestampSeek,
                                      initialShowUnprocessedText: _showOriginal,
                                    ),
                                  ),
                                ),
                                // 空白尾巴：正文永远不会画到遮罩底边上
                                const SizedBox(height: _fadeTailHeight),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 52,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _expandDescription,
                              child: Center(
                                child: _buildExpandButton(
                                  context,
                                  t.common.expand,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (_hasOverflow && expanded) const SizedBox(height: 8),
          if (_hasOverflow && expanded)
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
