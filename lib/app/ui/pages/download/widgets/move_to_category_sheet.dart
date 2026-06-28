import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_category_manage_page.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 打开「移至分类」底部弹窗。返回 true 表示发生了移动（调用方据此退出多选等）。
///
/// 单选语义：点击某个分类（或「未分类」）即刻把 [taskIds] 全部移入并关闭。
Future<bool?> showMoveToCategorySheet(
  BuildContext context,
  List<String> taskIds,
) {
  if (taskIds.isEmpty) return Future.value(false);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MoveToCategorySheet(taskIds: taskIds),
  );
}

class _MoveToCategorySheet extends StatefulWidget {
  final List<String> taskIds;
  const _MoveToCategorySheet({required this.taskIds});

  @override
  State<_MoveToCategorySheet> createState() => _MoveToCategorySheetState();
}

class _MoveToCategorySheetState extends State<_MoveToCategorySheet> {
  final DownloadService _service = Get.find<DownloadService>();
  final TextEditingController _newController = TextEditingController();

  List<DownloadCategory> _categories = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cats = await _service.getAllCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _move(String? categoryId, String? categoryTitle) async {
    if (_isMoving) return;
    setState(() => _isMoving = true);
    final t = slang.Translations.of(context);
    try {
      await _service.assignTasksToCategory(widget.taskIds, categoryId);
      if (!mounted) return;
      showToastWidget(
        MDToastWidget(
          message: categoryId == null
              ? t.download.category.moveToUncategorizedSuccess
              : t.download.category.moveSuccess(title: categoryTitle ?? ''),
          type: MDToastType.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMoving = false);
      showToastWidget(
        MDToastWidget(
          message: t.download.category.moveFailed,
          type: MDToastType.error,
        ),
      );
    }
  }

  Future<void> _createAndMove() async {
    final name = _newController.text.trim();
    if (name.isEmpty || _isCreating || _isMoving) return;
    setState(() => _isCreating = true);
    final t = slang.Translations.of(context);
    final cat = await _service.createCategory(title: name);
    if (!mounted) return;
    setState(() => _isCreating = false);
    if (cat == null) {
      showToastWidget(
        MDToastWidget(
          message: t.download.category.createFailed,
          type: MDToastType.error,
        ),
      );
      return;
    }
    await _move(cat.id, cat.title);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题 + 管理入口
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.taskIds.length > 1
                            ? t.download.category.moveToWithCount(
                                count: widget.taskIds.length,
                              )
                            : t.download.category.moveTo,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DownloadCategoryManagePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: Text(t.download.category.manage),
                    ),
                  ],
                ),
              ),
              // 内联新建分类
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newController,
                        enabled: !_isCreating && !_isMoving,
                        decoration: InputDecoration(
                          hintText: t.download.category.newCategoryHint,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _createAndMove(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: _isCreating
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _createAndMove,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // 未分类（退回 NULL）
                      ListTile(
                        leading: const Icon(Icons.folder_off_outlined),
                        title: Text(t.download.category.uncategorized),
                        onTap: _isMoving ? null : () => _move(null, null),
                      ),
                      for (final c in _categories)
                        ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(
                            c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '${c.itemCount ?? 0}',
                            style: theme.textTheme.bodySmall,
                          ),
                          onTap: _isMoving ? null : () => _move(c.id, c.title),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
