import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/common/widgets/input/base_input_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';

/// 基础底部弹窗输入组件
class BaseBottomSheetInput extends StatefulWidget {
  final String title;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final bool showEmojiPicker;
  final bool showTranslation;
  final bool showMarkdownHelp;
  final bool showPreview;
  final bool showRulesAgreement;
  final Function(String)? onSubmit;
  final bool isLoading;
  final String? errorText;
  final String? initialContent;
  final bool enabled;
  final FocusNode? focusNode;
  final IconData? titleIcon;
  final String? submitText;

  /// 这条回复冲着哪一楼去，透传给 [BaseInputWidget.quote]。
  final ReplyQuote? quote;

  /// 本弹窗是否参与小尾巴，透传给 [BaseInputWidget.allowSignature]。
  final bool allowSignature;

  /// 标题行要不要那枚跳设置的齿轮。
  ///
  /// 评论 / 回复 / 发帖这一族要（用户正对着小尾巴开关，改内容该一步到位）；
  /// 借这只底座做别的事的场合不要——「编辑个人简介」弹窗上挂一枚「评论设置」
  /// 是跑题的。
  final bool showSettingsShortcut;

  const BaseBottomSheetInput({
    super.key,
    required this.title,
    required this.hintText,
    this.maxLength = 1000,
    this.maxLines = 5,
    this.showEmojiPicker = false,
    this.showTranslation = true,
    this.showMarkdownHelp = true,
    this.showPreview = true,
    this.showRulesAgreement = false,
    this.onSubmit,
    this.isLoading = false,
    this.errorText,
    this.initialContent,
    this.enabled = true,
    this.focusNode,
    this.titleIcon,
    this.submitText,
    this.quote,
    this.allowSignature = true,
    this.showSettingsShortcut = true,
  });

  @override
  State<BaseBottomSheetInput> createState() => _BaseBottomSheetInputState();
}

class _BaseBottomSheetInputState extends State<BaseBottomSheetInput> {
  late TextEditingController _controller;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey =
      GlobalKey<EnhancedEmojiTextFieldState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String text) {
    widget.onSubmit?.call(text);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 外壳（背景 + 圆角 + 拖拽把手 + 安全区）统一走 GlassBottomSheet；
    // 标题行仍自己用 GlassComposerHeader（带 titleIcon），所以关掉它的内建
    // 标题参数（showCloseButton 无 title 时本就不生效，显式传 false 表意）。
    // padding: EdgeInsets.zero —— 保留原来两段各自的内边距，改动最小、观感不变。
    return GlassBottomSheet(
      showCloseButton: false,
      padding: EdgeInsets.zero,
      // 与 [BaseDialogInput] 同一个理由：输入框是恒定高度
      // （minLines == maxLines），矮屏 + 键盘弹起时这一列会超出弹层高度上限。
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部标题栏：标题 + 玻璃关闭圆钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: GlassComposerHeader(
              title: widget.title,
              icon: widget.titleIcon,
              onClose: _handleCancel,
              // 齿轮：用户正对着小尾巴开关，想改内容就该一步到位，而不是
              // 关掉弹窗自己去设置树里翻。放关闭键左边（GlassComposerHeader
              // 的 trailing 槽），关闭永远在最右端不挪窝。
              trailing: widget.showSettingsShortcut
                  ? GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.tune),
                      tooltip: slang.t.settings.chatSettings.name,
                      onPressed: NaviService.navigateToChatSettingsPage,
                    )
                  : null,
            ),
          ),
          // 内容区域
          // 外壳 GlassBottomSheet 已统一负责让出键盘与系统安全区（导航条/手势条），
          // 这里不再叠加 computeSheetBottomInset，避免底部间距被重复撑开。
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: BaseInputWidget(
              controller: _controller,
              title: widget.title,
              hintText: widget.hintText,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              showEmojiPicker: widget.showEmojiPicker,
              showTranslation: widget.showTranslation,
              showMarkdownHelp: widget.showMarkdownHelp,
              showPreview: widget.showPreview,
              showRulesAgreement: widget.showRulesAgreement,
              onSubmit: _handleSubmit,
              isLoading: widget.isLoading,
              errorText: widget.errorText,
              initialContent: widget.initialContent,
              enabled: widget.enabled,
              focusNode: widget.focusNode,
              emojiTextFieldKey: widget.showEmojiPicker
                  ? _emojiTextFieldKey
                  : null,
              submitText: widget.submitText,
              quote: widget.quote,
              allowSignature: widget.allowSignature,
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示底部弹窗输入框的便捷方法
class BottomSheetInputHelper {
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    required String hintText,
    int maxLength = 1000,
    int maxLines = 5,
    bool showEmojiPicker = false,
    bool showTranslation = true,
    bool showMarkdownHelp = true,
    bool showPreview = true,
    bool showRulesAgreement = false,
    String? initialContent,
    IconData? titleIcon,
    String? submitText,
  }) async {
    String? result;

    await showGlassBottomSheet<String>(
      context: context,
      builder: (context) => BaseBottomSheetInput(
        title: title,
        hintText: hintText,
        maxLength: maxLength,
        maxLines: maxLines,
        showEmojiPicker: showEmojiPicker,
        showTranslation: showTranslation,
        showMarkdownHelp: showMarkdownHelp,
        showPreview: showPreview,
        showRulesAgreement: showRulesAgreement,
        initialContent: initialContent,
        titleIcon: titleIcon,
        submitText: submitText,
        onSubmit: (text) {
          result = text;
          Navigator.of(context).pop();
        },
      ),
    );

    return result;
  }
}
