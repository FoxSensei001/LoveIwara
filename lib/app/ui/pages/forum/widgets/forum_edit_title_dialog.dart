import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

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
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.titleCanNotBeEmpty,
          type: MDToastType.error,
        ),
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
        showToastWidget(
          MDToastWidget(
            message: result.message,
            type: MDToastType.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

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
                      slang.t.forum.editTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: AppService.tryPop,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                maxLength: maxTitleLength,
                decoration: InputDecoration(
                  labelText: slang.t.forum.title,
                  border: const OutlineInputBorder(),
                  counterText: '$_currentTitleLength / $maxTitleLength',
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(slang.t.forum.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
