import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/common/widgets/input/base_input_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';

/// 基础对话框输入组件
class BaseDialogInput extends StatefulWidget {
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
  final VoidCallback? onCancel;
  final bool isLoading;
  final String? errorText;
  final String? initialContent;
  final bool enabled;
  final FocusNode? focusNode;
  final String? submitText;
  final String? cancelText;

  /// 标题左侧的小图标（与 [BaseBottomSheetInput] 对齐）。
  final IconData? titleIcon;

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

  const BaseDialogInput({
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
    this.onCancel,
    this.isLoading = false,
    this.errorText,
    this.initialContent,
    this.enabled = true,
    this.focusNode,
    this.submitText,
    this.cancelText,
    this.titleIcon,
    this.quote,
    this.allowSignature = true,
    this.showSettingsShortcut = true,
  });

  @override
  State<BaseDialogInput> createState() => _BaseDialogInputState();
}

class _BaseDialogInputState extends State<BaseDialogInput> {
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
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      // 液态档由 [GlassDialogRoute] 在路由层供，这里不用自己包。
      // ⛔ 整块内容必须可滚动：输入框现在是恒定高度（minLines == maxLines），
      // 个人简介那种 maxLines: 10 的弹窗在矮屏 + 键盘弹起时，标题行 + 输入区 +
      // 底栏加起来会超过 Dialog 给的高度，不滚就是一条 RenderFlex overflowed。
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题栏：标题 + 玻璃关闭圆钮
            GlassComposerHeader(
              title: widget.title,
              icon: widget.titleIcon,
              onClose: _handleCancel,
              // 齿轮：用户正对着小尾巴开关，想改内容就该一步到位，而不是
              // 关掉弹窗自己去设置树里翻。放关闭键左边（trailing 槽），
              // 关闭永远在最右端不挪窝。
              trailing: widget.showSettingsShortcut
                  ? GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.tune),
                      tooltip: slang.t.settings.chatSettings.name,
                      onPressed: NaviService.navigateToChatSettingsPage,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // 输入区域
            BaseInputWidget(
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
          ],
        ),
      ),
    );
  }
}
