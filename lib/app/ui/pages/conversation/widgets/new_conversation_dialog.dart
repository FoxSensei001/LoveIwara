import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/app/services/config_service.dart';

class NewConversationDialog extends StatefulWidget {
  const NewConversationDialog({super.key, this.initUserId, this.onSubmit});

  final String? initUserId;
  final VoidCallback? onSubmit;

  @override
  State<NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<NewConversationDialog> {
  final ConversationService _conversationService =
      Get.find<ConversationService>();
  final ConfigService _configService = Get.find<ConfigService>();
  late TextEditingController _bodyController;
  late TextEditingController _titleController;
  bool _isLoading = false;
  int _currentBodyLength = 0;
  User? _selectedUser;
  late EmojiSize _selectedEmojiSize;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey =
      GlobalKey<EnhancedEmojiTextFieldState>();

  // 内容最大长度
  static const int maxBodyLength = 1000;
  static const int maxTitleLength = 100;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    _titleController = TextEditingController();

    _bodyController.addListener(() {
      if (mounted) {
        setState(() {
          _currentBodyLength = _bodyController.text.length;
        });
      }
    });

    // 初始化表情尺寸
    final savedSizeSuffix = _configService[ConfigKey.DEFAULT_EMOJI_SIZE];
    _selectedEmojiSize =
        EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;

    // 如果有初始用户ID，搜索用户信息
    if (widget.initUserId != null) {
      _searchUser(widget.initUserId!);
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerSheet(
        initialSize: _selectedEmojiSize,
        onEmojiSelected: (imageUrl, size) {
          _emojiTextFieldKey.currentState?.insertEmoji(imageUrl, size: size);
          Navigator.pop(context);
        },
        onSizeChanged: (size) {
          setState(() {
            _selectedEmojiSize = size;
          });
          _configService[ConfigKey.DEFAULT_EMOJI_SIZE] = size.altSuffix;
        },
      ),
    );
  }

  Future<void> _searchUser(String userId) async {
    final result = await _conversationService.searchUsers(id: userId);
    if (result.isSuccess && result.data != null) {
      final users = result.data!.results;
      if (users.isNotEmpty) {
        setState(() {
          _selectedUser = users.first;
        });
      }
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showPreview() {
    // 预览弹层自己托一份「显示原始文本」状态：那枚 only-icon 钮挂在
    // GlassComposerHeader 的 trailing 位（关闭钮左侧），正文行内开关已关闭。
    bool showOriginal =
        Get.find<ConfigService>()[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    bool hasProcessed = false;
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => GlassDraggableBottomSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
                child: GlassComposerHeader(
                  title: t.common.preview,
                  icon: Icons.preview,
                  onClose: () => Navigator.of(context).pop(),
                  trailing: MarkdownOriginalTextToggle(
                    style: MarkdownToggleStyle.glass,
                    visible: hasProcessed,
                    showOriginal: showOriginal,
                    onChanged: (v) => setSheetState(() => showOriginal = v),
                  ),
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
                        originalData: _bodyController.text,
                        clickInternalLinkByUrlLaunch: true,
                        initialShowUnprocessedText: showOriginal,
                        onProcessedContentChanged: (v) {
                          if (hasProcessed == v) return;
                          setSheetState(() => hasProcessed = v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMarkdownHelp() {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  void _showUserSearch() {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => GlassDraggableBottomSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _UserSearchSheet(
          scrollController: scrollController,
          onUserSelected: (user) {
            setState(() {
              _selectedUser = user;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;
    if (_selectedUser == null) {
      showGlassToast(
        t.conversation.errors.pleaseSelectAUser,
        type: GlassToastType.error,
      );
      return;
    }

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showGlassToast(
        t.conversation.errors.pleaseEnterATitle,
        type: GlassToastType.error,
      );
      return;
    }

    // 检查标题长度
    if (_titleController.text.length > maxTitleLength) {
      showGlassToast(
        t.errors.exceedsMaxLength(max: maxTitleLength.toString()),
        type: GlassToastType.error,
      );
      return;
    }

    // 检查内容是否为空
    if (_bodyController.text.trim().isEmpty) {
      showGlassToast(t.errors.contentCanNotBeEmpty, type: GlassToastType.error);
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _conversationService.createConversation(
      _selectedUser!.id,
      _titleController.text.trim(),
      _bodyController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (result.isSuccess) {
      if (mounted) {
        Navigator.pop(context);
        widget.onSubmit?.call();
      }
    } else {
      showGlassToast(result.message, type: GlassToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        _selectedUser != null &&
        _currentBodyLength > 0 &&
        _currentBodyLength <= maxBodyLength;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassComposerHeader(
                title: t.conversation.startConversation,
                icon: Icons.chat_bubble_outline,
                onClose: () => AppService.tryPop(),
              ),
              const SizedBox(height: 16),
              // 选择用户
              GlassInputSurface(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _showUserSearch,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _selectedUser == null
                              ? Text(
                                  t.conversation.errors.clickToSelectAUser,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : Row(
                                  children: [
                                    AvatarWidget(
                                      user: _selectedUser,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildUserName(
                                            context,
                                            _selectedUser!,
                                            fontSize: 14,
                                          ),
                                          Text(
                                            '@${_selectedUser!.username}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 标题输入框
              GlassInputSurface(
                child: TextField(
                  controller: _titleController,
                  maxLength: maxTitleLength,
                  decoration: glassFieldDecoration(
                    context,
                    label: t.conversation.title,
                    hint: t.conversation.errors.pleaseEnterATitle,
                    counterText:
                        '${_titleController.text.length}/$maxTitleLength',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 内容输入框
              GlassInputSurface(
                child: EnhancedEmojiTextField(
                  key: _emojiTextFieldKey,
                  controller: _bodyController,
                  maxLines: 5,
                  maxLength: maxBodyLength,
                  decoration: glassFieldDecoration(
                    context,
                    hint: t.common.writeYourContentHere,
                    errorText: _currentBodyLength > maxBodyLength
                        ? t.errors.exceedsMaxLength(
                            max: maxBodyLength.toString(),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _currentBodyLength = value.length;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 工具行：Markdown 帮助 · 预览 · 表情
              GlassComposerToolbar(
                onMarkdownHelp: _showMarkdownHelp,
                onPreview: _showPreview,
                onEmoji: _showEmojiPicker,
              ),
              const SizedBox(height: 16),
              GlassComposerActions(
                onSubmit: canSubmit ? _handleSubmit : null,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final Function(User) onUserSelected;
  final ScrollController scrollController;

  const _UserSearchSheet({
    required this.onUserSelected,
    required this.scrollController,
  });

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final ConversationService _conversationService =
      Get.find<ConversationService>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<User> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // 使用addPostFrameCallback确保在widget完全构建后再请求焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _conversationService.searchUsers(query: query);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess && result.data != null) {
          _searchResults.clear();
          _searchResults.addAll(result.data!.results);
        }
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
          child: GlassComposerHeader(
            title: t.conversation.selectAUser,
            icon: Icons.person_search,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: t.conversation.searchUsers,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: AvatarWidget(user: user),
                  title: buildUserName(context, user, fontSize: 14),
                  subtitle: Text('@${user.username}'),
                  onTap: () => widget.onUserSelected(user),
                );
              },
            ),
          ),
      ],
    );
  }
}
