import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class RemoveSearchTagDialog extends StatefulWidget {
  final Function(List<String>) onRemoveIds;
  final RxList<Tag> videoSearchTagHistory;

  const RemoveSearchTagDialog({
    super.key,
    required this.onRemoveIds,
    required this.videoSearchTagHistory,
  });

  @override
  State<RemoveSearchTagDialog> createState() => _RemoveSearchTagDialogState();
}

class _RemoveSearchTagDialogState extends State<RemoveSearchTagDialog> {
  Set<String> selectedIds = <String>{};

  /// 标签是否展示原始 key（false 时展示当前语言译名）。
  bool _showOriginal = false;

  /// 是否存在「译名 ≠ 原始 key」的标签——只有此时切换按钮才有意义。
  bool get _hasMeaningfulTranslation {
    for (final tag in widget.videoSearchTagHistory) {
      if (TagLocalizationService.displayName(tag.id) != tag.id) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        child: Column(
          children: [
            Text(t.search.removeTag, style: const TextStyle(fontSize: 20)),
            _buildHeader(context),
            const Divider(),
            Expanded(child: _buildTagGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildDeleteButton(context),
          const Spacer(),
          // 切换标签显示：原始 key / 当前译文
          if (_hasMeaningfulTranslation)
            IconButton(
              icon: Icon(_showOriginal ? Icons.translate : Icons.tag),
              tooltip: _showOriginal
                  ? t.common.showTranslatedTag
                  : t.common.showOriginalTag,
              onPressed: () => setState(() => _showOriginal = !_showOriginal),
            ),
          const SizedBox(width: 8),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final t = slang.Translations.of(context);
    return ElevatedButton(
      onPressed: selectedIds.isEmpty ? null : _deleteSelected,
      child: Text(t.common.delete),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => AppService.tryPop(),
    );
  }

  Widget _buildTagGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3,
        ),
        itemCount: widget.videoSearchTagHistory.length,
        itemBuilder: (context, index) => _buildTagItem(index),
      ),
    );
  }

  Widget _buildTagItem(int index) {
    final tag = widget.videoSearchTagHistory[index];
    final isSelected = selectedIds.contains(tag.id);

    return GestureDetector(
      onTap: () => _toggleSelection(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          _showOriginal ? tag.id : TagLocalizationService.displayName(tag.id),
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _toggleSelection(int index) {
    final tag = widget.videoSearchTagHistory[index];
    setState(() {
      if (selectedIds.contains(tag.id)) {
        selectedIds.remove(tag.id);
      } else {
        selectedIds.add(tag.id);
      }
    });
  }

  void _deleteSelected() {
    if (selectedIds.isEmpty) return;
    widget.onRemoveIds(selectedIds.toList());
    setState(() {
      selectedIds.clear();
    });
  }
}
