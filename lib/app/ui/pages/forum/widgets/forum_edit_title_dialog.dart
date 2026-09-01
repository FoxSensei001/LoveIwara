import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ForumEditTitleDialog extends StatefulWidget {
  final String postId;
  final String initialTitle;
  final ThreadDetailRepository repository;
  final VoidCallback? onSubmit;

  const ForumEditTitleDialog({
    super.key,
    required this.postId,
    required this.initialTitle,
    required this.repository,
    this.onSubmit,
  });

  @override
  State<ForumEditTitleDialog> createState() => _ForumEditTitleDialogState();
}

class _ForumEditTitleDialogState extends State<ForumEditTitleDialog> {
  final ForumService _forumService = Get.find<ForumService>();
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;
  static const int maxTitleLength = 128;
  int _currentTitleLength = 0;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _currentTitleLength = widget.initialTitle.length;
    _titleController.addListener(() {
      setState(() {
        _currentTitleLength = _titleController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_currentTitleLength > maxTitleLength || _currentTitleLength == 0) {
      return;
    }

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showAppToast(
        slang.t.errors.titleCanNotBeEmpty,
        type: AppToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _forumService.editThreadTitle(
      widget.repository.categoryId,
      widget.repository.threadId,
      _titleController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        widget.onSubmit?.call();
        AppService.tryPop();
      } else {
        showAppToast(result.message, type: AppToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

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
                title: slang.t.forum.editTitle,
                icon: Icons.title,
                onClose: AppService.tryPop,
              ),
              const SizedBox(height: 16),
              GlassInputSurface(
                child: TextField(
                  controller: _titleController,
                  maxLength: maxTitleLength,
                  decoration: glassFieldDecoration(
                    context,
                    label: slang.t.forum.title,
                    counterText: '$_currentTitleLength / $maxTitleLength',
                  ),
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(height: 16),
              GlassComposerActions(
                onSubmit:
                    _currentTitleLength > 0 &&
                        _currentTitleLength <= maxTitleLength
                    ? _handleSubmit
                    : null,
                submitText: t.forum.submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
