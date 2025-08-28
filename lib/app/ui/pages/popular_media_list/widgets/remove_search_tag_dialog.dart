import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class RemoveSearchTagDialog extends StatefulWidget {
  final Function(List<String>) onRemoveIds;
  final RxList<Tag> videoSearchTagHistory;

  const RemoveSearchTagDialog({
    super.key,
    required this.onRemoveIds,
    required this.videoSearchTagHistory
  });

  @override
  State<RemoveSearchTagDialog> createState() => _RemoveSearchTagDialogState();
}

class _RemoveSearchTagDialogState extends State<RemoveSearchTagDialog> {
  Set<String> selectedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
          maxHeight: 800,
        ),
        child: Column(
          children: [
            Text(t.search.removeTag, style: const TextStyle(fontSize: 20)),
            _buildHeader(context),
            const Divider(),
            Expanded(
              child: _buildTagGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSelectAllButton(context),
          const SizedBox(width: 8),
          _buildDeleteButton(context),
          const Spacer(),
          const SizedBox(width: 8),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildSelectAllButton(BuildContext context) {
    final t = slang.Translations.of(context);
    return Stack(
      children: [
        ElevatedButton(
          onPressed: _toggleSelectAll,
          child: Text(
              selectedIds.length == widget.videoSearchTagHistory.length
                  ? t.common.cancelSelectAll
                  : t.common.selectAll
          ),
        ),
        if (selectedIds.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${selectedIds.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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
      onPressed: () => Navigator.of(context).pop(),
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
          tag.id,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
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

  void _toggleSelectAll() {
    setState(() {
      if (selectedIds.length == widget.videoSearchTagHistory.length) {
        selectedIds.clear();
      } else {
        selectedIds = widget.videoSearchTagHistory
            .map((e) => e.id)
            .toSet();
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