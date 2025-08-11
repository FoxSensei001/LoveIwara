import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/app/services/config_service.dart';

class NewConversationDialog extends StatefulWidget {
  const NewConversationDialog({
    super.key,
    this.initUserId,
    this.onSubmit,
  });

  final String? initUserId;
  final VoidCallback? onSubmit;

  @override
  State<NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<NewConversationDialog> {
  final ConversationService _conversationService = Get.find<ConversationService>();
  final ConfigService _configService = Get.find<ConfigService>();
  late TextEditingController _bodyController;
  late TextEditingController _titleController;
  bool _isLoading = false;
  int _currentBodyLength = 0;
  User? _selectedUser;
  late EmojiSize _selectedEmojiSize;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey = GlobalKey<EnhancedEmojiTextFieldState>();

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
    _selectedEmojiSize = EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;

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
                      originalData: _bodyController.text,
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

  void _showUserSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _UserSearchSheet(
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
      showToastWidget(
        MDToastWidget(
          message: t.conversation.errors.pleaseSelectAUser,
          type: MDToastType.error,
        ),
      );
      return;
    }

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.conversation.errors.pleaseEnterATitle,
          type: MDToastType.error,
        ),
      );
      return;
    }

    // 检查标题长度
    if (_titleController.text.length > maxTitleLength) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.exceedsMaxLength(max: maxTitleLength.toString()),
          type: MDToastType.error,
        ),
      );
      return;
    }

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
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t.conversation.startConversation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
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
                  IconButton(
                    onPressed: _showEmojiPicker,
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    tooltip: t.emoji.selectEmoji,
                  ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        tooltip: t.common.close,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 选择用户
              InkWell(
                onTap: _showUserSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _selectedUser == null
                            ? Text(
                                t.conversation.errors.clickToSelectAUser,
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              )
                            : Row(
                                children: [
                                  AvatarWidget(
                                    user: _selectedUser,
                                    size: 40
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildUserName(context, _selectedUser!, fontSize: 14),
                                        Text(
                                          '@${_selectedUser!.username}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).hintColor,
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
              const SizedBox(height: 16),
              // 标题输入框
              TextField(
                controller: _titleController,
                maxLength: maxTitleLength,
                decoration: InputDecoration(
                  labelText: t.conversation.title,
                  hintText: t.conversation.errors.pleaseEnterATitle,
                  border: const OutlineInputBorder(),
                  counterText: '${_titleController.text.length}/$maxTitleLength',
                ),
              ),
              const SizedBox(height: 16),
              // 内容输入框
              EnhancedEmojiTextField(
                key: _emojiTextFieldKey,
                controller: _bodyController,
                maxLines: 5,
                maxLength: maxBodyLength,
                decoration: InputDecoration(
                  hintText: t.common.writeYourContentHere,
                  errorText: _currentBodyLength > maxBodyLength
                      ? t.errors.exceedsMaxLength(max: maxBodyLength.toString())
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.common.cancel),
                  ),
                  const SizedBox(width: 8),
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
      ),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final Function(User) onUserSelected;

  const _UserSearchSheet({
    required this.onUserSelected,
  });

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final ConversationService _conversationService = Get.find<ConversationService>();
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
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.conversation.selectAUser,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: AvatarWidget(
                    user: user,
                  ),
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