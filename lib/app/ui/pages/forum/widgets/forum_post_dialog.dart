import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class ForumPostDialog extends StatefulWidget {
  const ForumPostDialog({
    super.key,
    this.onSubmit,
    this.initCategoryId,
  });

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
                    Text(
                      _titleController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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

  Future<void> _showRulesDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => RulesAgreementDialog(
          scrollController: scrollController,
        ),
      ),
    );

    if (result == true) {
      await _configService.setSetting(ConfigService.RULES_AGREEMENT_KEY, true);
      if (mounted) {
        _handleSubmit();
      }
    }
  }

  void _handleSubmit() async {
    if (_currentTitleLength > maxTitleLength || _currentTitleLength == 0) {
      return;
    }
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;
    if (_selectedCategoryId == null) {
      showToastWidget(
        MDToastWidget(
          message: t.forum.errors.pleaseSelectCategory,
          type: MDToastType.error,
        ),
      );
      return;
    }

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.titleCanNotBeEmpty,
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

    final bool hasAgreed = _configService[ConfigService.RULES_AGREEMENT_KEY];
    if (!hasAgreed) {
      await _showRulesDialog();
      return;
    }

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
        );
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

  Widget _buildLoadingDropdown() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loadError ?? t.errors.unknownError,
                      style: TextStyle(color: Colors.red[400], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.red[200]!),
              ),
            ),
            child: IconButton(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              tooltip: t.common.refresh,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCoolingDown =
        _cooldown?.limited == true && _remainingSeconds > 0;

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
                      t.forum.createThread,
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
                        onPressed: () => AppService.tryPop(),
                        icon: const Icon(Icons.close),
                        tooltip: t.common.close,
                      ),
                    ],
                  ),
                ],
              ),
              if (isCoolingDown) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        t.forum.cooldownRemaining(
                          minutes: (_remainingSeconds ~/ 60).toString(),
                          seconds: (_remainingSeconds % 60).toString(),
                        ),
                        style: const TextStyle(color: Colors.orange),
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
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.6,
                        minChildSize: 0.3,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) => Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.forum.selectCategory,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                              child: ListView.builder(
                                controller: scrollController,
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
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ...category.children.where((sub) => !sub.locked).map((sub) => 
                                        ListTile(
                                          selected: _selectedCategoryId == sub.id,
                                          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                                          contentPadding: const EdgeInsets.fromLTRB(32, 4, 16, 4),
                                          title: Text(
                                            sub.label,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: sub.description.isNotEmpty ? Text(
                                            sub.description,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ) : null,
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
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.forum.selectCategory,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCategoryId != null
                                  ? _categories!
                                      .expand((cat) => cat.children)
                                      .firstWhere((sub) => sub.id == _selectedCategoryId)
                                      .label
                                  : t.forum.selectCategory,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedCategoryId != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // 标题输入框
              TextField(
                controller: _titleController,
                maxLines: 1,
                maxLength: maxTitleLength,
                decoration: InputDecoration(
                  labelText: t.common.title,
                  hintText: t.common.enterTitle,
                  border: const OutlineInputBorder(),
                  counterText: '$_currentTitleLength/$maxTitleLength',
                  errorText: _currentTitleLength > maxTitleLength
                      ? t.errors.exceedsMaxLength(max: maxTitleLength.toString())
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // 内容输入框
              TextField(
                controller: _bodyController,
                maxLines: 5,
                maxLength: maxBodyLength,
                decoration: InputDecoration(
                  labelText: t.common.content,
                  hintText: t.common.writeYourContentHere,
                  border: const OutlineInputBorder(),
                  counterText: '$_currentBodyLength/$maxBodyLength',
                  errorText: _currentBodyLength > maxBodyLength
                      ? t.errors.exceedsMaxLength(max: maxBodyLength.toString())
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Obx(() {
                    final bool hasAgreed =
                        _configService[ConfigService.RULES_AGREEMENT_KEY];
                    return TextButton.icon(
                      onPressed: () => _showRulesDialog(),
                      icon: Icon(
                        hasAgreed
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      label: Text(t.common.agreeToRules),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  }),
                  TextButton(
                    onPressed: () => AppService.tryPop(),
                    child: Text(t.common.cancel),
                  ),
                  ElevatedButton(
                    onPressed: isCoolingDown ||
                            (_currentTitleLength > maxTitleLength ||
                                _currentTitleLength == 0) ||
                            (_currentBodyLength > maxBodyLength ||
                                _currentBodyLength == 0) ||
                            _selectedCategoryId == null
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
