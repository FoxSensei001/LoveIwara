import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class ConversationMessageBottomSheet extends StatefulWidget {
  const ConversationMessageBottomSheet({
    super.key,
    required this.conversationId,
    this.onSubmit,
  });

  final String conversationId;
  final VoidCallback? onSubmit;

  @override
  State<ConversationMessageBottomSheet> createState() => _ConversationMessageBottomSheetState();
}

class _ConversationMessageBottomSheetState extends State<ConversationMessageBottomSheet> {
  final ConversationService _conversationService = Get.find<ConversationService>();
  late TextEditingController _bodyController;
  bool _isLoading = false;
  int _currentBodyLength = 0;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey = GlobalKey<EnhancedEmojiTextFieldState>();

  // 内容最大长度
  static const int maxBodyLength = 1000;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();

    _bodyController.addListener(() {
      if (mounted) {
        setState(() {
          _currentBodyLength = _bodyController.text.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.common.preview,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMarkdownBody(
                      data: _bodyController.text,
                      clickInternalLinkByUrlLaunch: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkdownHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  void _showEmojiPickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_emotions),
                  const SizedBox(width: 8),
                  Text(
                    '选择表情包',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // 表情包选择器
            Expanded(
              child: EmojiPickerWidget(
                onEmojiSelected: (imageUrl) {
                  _insertEmoji(imageUrl);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insertEmoji(String imageUrl) {
    // 使用EnhancedEmojiTextField的内部方法插入表情
    final state = _emojiTextFieldKey.currentState;
    state?.insertEmoji(imageUrl);
    
    // 更新字符计数
    setState(() {
      _currentBodyLength = _bodyController.text.length;
    });
  }

  void _handleSubmit() async {
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;

    // 检查内容是否为空
    if (_bodyController.text.trim().isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.contentCanNotBeEmpty,
          type: MDToastType.error,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _conversationService.sendMessage(
      widget.conversationId,
      _bodyController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (result.isSuccess) {
      widget.onSubmit?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      showToastWidget(
        MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部标题栏
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.send_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    t.conversation.sendMessage,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 输入框
                EnhancedEmojiTextField(
                  key: _emojiTextFieldKey,
                  controller: _bodyController,
                  maxLines: 5,
                  maxLength: maxBodyLength, // 这个参数会被EnhancedEmojiTextField用于自定义字符计数
                  decoration: InputDecoration(
                    hintText: t.common.writeYourContentHere,
                    errorText: _currentBodyLength > maxBodyLength
                        ? t.errors.exceedsMaxLength(max: maxBodyLength.toString())
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentBodyLength = value.length;
                    });
                  },
                  enabled: !_isLoading,
                  onEmojiInserted: (imageUrl) {
                    setState(() {
                      _currentBodyLength = _bodyController.text.length;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // 操作按钮行
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: _bodyController.text.isNotEmpty
                          ? () {
                              Get.dialog(
                                TranslationDialog(
                                  text: _bodyController.text,
                                  defaultLanguageKeyMode: false,
                                ),
                                barrierDismissible: true,
                              );
                            }
                          : null,
                      icon: Icon(
                        Icons.translate,
                        color: _bodyController.text.isEmpty
                            ? Theme.of(context).disabledColor
                            : null,
                      ),
                      tooltip: t.common.translate,
                    ),
                    IconButton(
                      onPressed: _showEmojiPickerDialog,
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      tooltip: '表情包',
                    ),
                    IconButton(
                      onPressed: _showMarkdownHelp,
                      icon: const Icon(Icons.help_outline),
                      tooltip: t.markdown.markdownSyntax,
                    ),
                    IconButton(
                      onPressed: _showPreview,
                      icon: const Icon(Icons.preview),
                      tooltip: t.common.preview,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 底部操作按钮
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.common.cancel),
                    ),
                    ElevatedButton(
                      onPressed: (_currentBodyLength > maxBodyLength ||
                              _currentBodyLength == 0)
                          ? null
                          : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.common.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
使用示例：

// 显示对话消息输入底部弹窗
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => ConversationMessageBottomSheet(
    conversationId: conversationId,
    onSubmit: () {
      // 处理消息发送成功后的逻辑
      messageListRepository.refresh(true);
    },
  ),
);
*/ 