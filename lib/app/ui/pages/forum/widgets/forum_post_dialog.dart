import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/markdown_preview_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class ForumPostDialog extends StatefulWidget {
  const ForumPostDialog({super.key, this.onSubmit, this.initCategoryId});

  final VoidCallback? onSubmit;
  final String? initCategoryId;

  @override
  State<ForumPostDialog> createState() => _ForumPostDialogState();
}

class _ForumPostDialogState extends State<ForumPostDialog> {
  final ForumService _forumService = Get.find<ForumService>();
  final ConfigService _configService = Get.find<ConfigService>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  bool _isLoading = false;
  int _currentTitleLength = 0;
  int _currentBodyLength = 0;
  String? _selectedCategoryId;
  List<ForumCategoryTreeModel>? _categories;
  PostCooldownModel? _cooldown;
  Timer? _cooldownTimer;
  int _remainingSeconds = 0;
  bool _isLoadingCategories = true;
  String? _loadError;
  late EmojiSize _selectedEmojiSize;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey =
      GlobalKey<EnhancedEmojiTextFieldState>();

  // 标题最大长度
  static const int maxTitleLength = 100;
  // 内容最大长度
  static const int maxBodyLength = 20000;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _selectedCategoryId = widget.initCategoryId;

    _titleController.addListener(() {
      if (mounted) {
        setState(() {
          _currentTitleLength = _titleController.text.length;
        });
      }
    });

    _bodyController.addListener(() {
      if (mounted) {
        setState(() {
          _currentBodyLength = _bodyController.text.length;
        });
      }
    });

    _loadInitialData();

    // 初始化表情尺寸
    final savedSizeSuffix = _configService[ConfigKey.DEFAULT_EMOJI_SIZE];
    _selectedEmojiSize =
        EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingCategories = true;
      _loadError = null;
    });

    // 加载分类树
    final categoryResult = await _forumService.getForumCategoryTree();
    if (categoryResult.isSuccess) {
      if (mounted) {
        setState(() {
          _categories = categoryResult.data;
          _isLoadingCategories = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loadError = categoryResult.message;
          _isLoadingCategories = false;
        });
      }
    }

    // 检查冷却时间
    await _checkCooldown();
  }

  Future<void> _checkCooldown() async {
    final cooldownResult = await _forumService.fetchPostCollingInfo();
    if (cooldownResult.isSuccess && cooldownResult.data != null) {
      if (mounted) {
        setState(() {
          _cooldown = cooldownResult.data;
          if (_cooldown!.limited) {
            _remainingSeconds = _cooldown!.remaining;
            _startCooldownTimer();
          }
        });
      }
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

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
            _checkCooldown();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _showPreview() {
    MarkdownPreviewHelper.showPreviewWithTitle(
      context,
      _bodyController.text,
      _titleController.text,
    );
  }

  void _showMarkdownHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  Future<void> _showRulesDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            RulesAgreementDialog(scrollController: scrollController),
      ),
    );

    if (result == true) {
      // 只记录「已同意」，不代发内容——用户仍需自己按提交键
      await _configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, true);
    }
  }

  void _handleSubmit() async {
    if (_currentTitleLength > maxTitleLength || _currentTitleLength == 0) {
      return;
    }
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;
    if (_selectedCategoryId == null) {
      showGlassToast(
        t.forum.errors.pleaseSelectCategory,
        type: GlassToastType.error,
      );
      return;
    }

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showGlassToast(t.errors.titleCanNotBeEmpty, type: GlassToastType.error);
      return;
    }

    // 检查内容是否为空
    if (_bodyController.text.trim().isEmpty) {
      showGlassToast(t.errors.contentCanNotBeEmpty, type: GlassToastType.error);
      return;
    }

    // 未同意规则时提交键本就是禁用态，这里只兜底拦一道
    if (!_configService[ConfigKey.RULES_AGREEMENT_KEY]) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _forumService.postThread(
      _selectedCategoryId!,
      _titleController.text,
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
        AppService.tryPop();
        // 跳转到帖子详情页
        NaviService.navigateToForumThreadDetailPage(
          result.data!.section,
          result.data!.id,
          initialThread: result.data,
        );
      }
    } else {
      showGlassToast(result.message, type: GlassToastType.error);
    }
  }

  Widget _buildLoadingDropdown() {
    return GlassInputSurface(
      child: const SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassInputSurface(
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.error_outline, color: colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _loadError ?? t.errors.unknownError,
                style: TextStyle(color: colorScheme.error, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: const Icon(Icons.refresh),
              tooltip: t.common.refresh,
              color: colorScheme.error,
              onPressed: _loadInitialData,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  /// 分类选择器：玻璃壳里的「标签 + 当前值 + 箭头」，点开走底部弹窗选择。
  Widget _buildCategorySelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasSelection = _selectedCategoryId != null;
    return GlassInputSurface(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _showCategoryPicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.forum.selectCategory,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hasSelection
                          ? _categories!
                                .expand((cat) => cat.children)
                                .firstWhere(
                                  (sub) => sub.id == _selectedCategoryId,
                                )
                                .label
                          : t.forum.selectCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: hasSelection
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: GlassComposerHeader(
                title: t.forum.selectCategory,
                icon: Icons.label_outline,
                onClose: () => Navigator.pop(context),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: computeSheetBottomInset(context),
                ),
                itemCount: _categories?.length ?? 0,
                itemBuilder: (context, index) {
                  final category = _categories![index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...category.children
                          .where((sub) => !sub.locked)
                          .map(
                            (sub) => ListTile(
                              selected: _selectedCategoryId == sub.id,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.fromLTRB(
                                32,
                                4,
                                16,
                                4,
                              ),
                              title: Text(
                                sub.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: sub.description.isNotEmpty
                                  ? Text(
                                      sub.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = sub.id;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCoolingDown =
        _cooldown?.limited == true && _remainingSeconds > 0;

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
                title: t.forum.createPost,
                icon: Icons.post_add,
                onClose: () => AppService.tryPop(),
              ),
              if (isCoolingDown) ...[
                const SizedBox(height: 8),
                // 冷却提示：与列表项 chip 同款软色胶囊
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.forum.cooldownRemaining(
                            minutes: (_remainingSeconds ~/ 60).toString(),
                            seconds: (_remainingSeconds % 60).toString(),
                          ),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // 分类选择
              if (_isLoadingCategories)
                _buildLoadingDropdown()
              else if (_loadError != null)
                _buildErrorWidget()
              else
                _buildCategorySelector(context),
              const SizedBox(height: 16),
              // 标题输入框
              GlassInputSurface(
                child: TextField(
                  controller: _titleController,
                  maxLines: 1,
                  maxLength: maxTitleLength,
                  decoration: glassFieldDecoration(
                    context,
                    label: t.common.title,
                    hint: t.common.enterTitle,
                    counterText: '$_currentTitleLength/$maxTitleLength',
                    errorText: _currentTitleLength > maxTitleLength
                        ? t.errors.exceedsMaxLength(
                            max: maxTitleLength.toString(),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 内容输入框（支持表情）
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
              // 工具行：翻译 · 表情 · MD 帮助 · 预览
              GlassComposerToolbar(
                onTranslate: () {
                  showTranslationDialog(
                    context,
                    text: _bodyController.text,
                    defaultLanguageKeyMode: false,
                  );
                },
                translateEnabled: _bodyController.text.isNotEmpty,
                onEmoji: _showEmojiPicker,
                onMarkdownHelp: _showMarkdownHelp,
                onPreview: _showPreview,
              ),
              const SizedBox(height: 16),
              Obx(() {
                final bool hasAgreed =
                    _configService[ConfigKey.RULES_AGREEMENT_KEY];
                final bool canSubmit =
                    hasAgreed &&
                    !isCoolingDown &&
                    _currentTitleLength > 0 &&
                    _currentTitleLength <= maxTitleLength &&
                    _currentBodyLength > 0 &&
                    _currentBodyLength <= maxBodyLength &&
                    _selectedCategoryId != null;
                return GlassComposerActions(
                  rulesAgreed: hasAgreed,
                  onRulesTap: () => _showRulesDialog(),
                  onSubmit: canSubmit ? _handleSubmit : null,
                  // 只差「同意规则」时：按钮仍可点，点下去弹规则全文
                  onBlockedTap: !hasAgreed ? () => _showRulesDialog() : null,
                  isLoading: _isLoading,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
