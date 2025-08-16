import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_group_detail_page.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class EmojiLibraryPage extends StatefulWidget {

  const EmojiLibraryPage({super.key});

  @override
  State<EmojiLibraryPage> createState() => _EmojiLibraryPageState();
}

class _EmojiLibraryPageState extends State<EmojiLibraryPage> {
  late EmojiLibraryService _emojiService;
  List<EmojiGroup> _groups = [];
  final Map<int, List<EmojiImage>> _groupImages = {};
  final Map<int, int> _groupImageCounts = {};
  bool _isDragMode = false;

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _groups = _emojiService.getEmojiGroups();
      _groupImageCounts.clear();
      _groupImages.clear();

      for (final group in _groups) {
        _groupImageCounts[group.groupId] = _emojiService.getEmojiImageCount(
          group.groupId,
        );
        _groupImages[group.groupId] = _emojiService.getEmojiImages(
          group.groupId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.emoji.library),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(_isDragMode ? Icons.check : Icons.drag_handle),
            onPressed: () {
              setState(() {
                _isDragMode = !_isDragMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _groups.length,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _groups.removeAt(oldIndex);
                  _groups.insert(newIndex, item);

                  _emojiService.updateEmojiGroupsOrder(_groups);
                });
              },
              itemBuilder: (context, index) {
                return _buildGroupCard(_groups[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(EmojiGroup group, int index) {
    final imageCount = _groupImageCounts[group.groupId] ?? 0;

    return Card(
      key: ValueKey(group.groupId),
      margin: const EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isDragMode)
              ReorderableDragStartListener(
                index: index,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Icon(Icons.drag_handle),
                ),
              ),
            if (_isDragMode) const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: group.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        group.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              group.name.isNotEmpty ? group.name[0] : '?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        group.name.isNotEmpty ? group.name[0] : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        title: Text(group.name),
        subtitle: Text(t.emoji.imageCount(count: imageCount)),
        trailing: _isDragMode
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditGroupDialog(group),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteGroupDialog(group),
                  ),
                ],
              ),
        onTap: () {
          _navigateToGroupDetail(group);
        },
      ),
    );
  }

  void _navigateToGroupDetail(EmojiGroup group) {
    EmojiGroupDetailPage.show(context, group);
    _loadData();
  }

  void _showCreateGroupDialog() {
    final t = Translations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.createGroup),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: t.emoji.groupName,
            hintText: t.emoji.enterGroupName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _emojiService.createEmojiGroup(name);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: Text(t.emoji.create),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(EmojiGroup group) {
    final t = Translations.of(context);
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.editGroupName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: t.emoji.groupName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _emojiService.updateEmojiGroupName(group.groupId, name);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: Text(t.emoji.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(EmojiGroup group) {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.deleteGroup),
        content: Text(t.emoji.confirmDeleteGroup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              _emojiService.deleteEmojiGroup(group.groupId);
              Navigator.pop(context);
              _loadData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.emoji.delete),
          ),
        ],
      ),
    );
  }
}
