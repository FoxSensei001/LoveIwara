import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_group_detail_page.dart';

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
        _groupImageCounts[group.groupId] = _emojiService.getEmojiImageCount(group.groupId);
        _groupImages[group.groupId] = _emojiService.getEmojiImages(group.groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表情包库'),
        actions: [
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
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _groups.removeAt(oldIndex);
                  _groups.insert(newIndex, item);
                  
                  // 更新数据库中的排序
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
        leading: Container(
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
        title: Text(group.name),
        subtitle: Text('$imageCount张图片'),
        trailing: Row(
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
    // 当从详情页返回时刷新数据
    _loadData();
  }

  void _showCreateGroupDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建表情包分组'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '分组名称',
            hintText: '请输入分组名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
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
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(EmojiGroup group) {
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑分组名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '分组名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
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
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(EmojiGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分组'),
        content: const Text('确定要删除这个表情包分组吗？分组内的所有图片也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _emojiService.deleteEmojiGroup(group.groupId);
              Navigator.pop(context);
              _loadData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}