import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'dart:convert';

class EmojiGroupDetailPage extends StatefulWidget {
  final EmojiGroup group;

  const EmojiGroupDetailPage({super.key, required this.group});

  @override
  State<EmojiGroupDetailPage> createState() => _EmojiGroupDetailPageState();
}

class _EmojiGroupDetailPageState extends State<EmojiGroupDetailPage> {
  late EmojiLibraryService _emojiService;
  List<EmojiImage> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      _isLoading = true;
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      final images = _emojiService.getEmojiImages(widget.group.groupId);
      setState(() {
        _images = images;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddImagesDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => _showBatchImportDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? _buildEmptyState()
              : _buildImageGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_emotions_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无表情包',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角按钮添加表情包',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddImagesDialog(),
            icon: const Icon(Icons.add),
            label: const Text('添加表情包'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        return GestureDetector(
          onLongPress: () => _showDeleteImageDialog(image),
          onTap: () => _showImagePreview(image),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image.thumbnailUrl ?? image.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePreview(EmojiImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Image.network(
                  image.url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 64),
                    );
                  },
                ),
              ),
              OverflowBar(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteImageDialog(image);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('删除'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteImageDialog(EmojiImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确定要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _emojiService.deleteEmojiImage(image.imageId);
              Navigator.pop(context);
              _loadImages();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加图片'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('通过URL添加'),
              onTap: () {
                Navigator.pop(context);
                _showUrlInputDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加图片URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '图片URL',
            hintText: '请输入图片URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                _emojiService.addEmojiImage(widget.group.groupId, url);
                Navigator.pop(context);
                _loadImages();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showBatchImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量导入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请输入JSON格式的URL数组:'),
            const SizedBox(height: 8),
            const Text(
              '格式示例:\n["url1", "url2", "url3"]',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请粘贴JSON格式的URL数组',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final jsonText = controller.text.trim();
              if (jsonText.isNotEmpty) {
                try {
                  final List<dynamic> urls = json.decode(jsonText);
                  final List<String> urlStrings = urls.cast<String>();
                  _emojiService.addEmojiImagesBatch(widget.group.groupId, urlStrings);
                  Navigator.pop(context);
                  _loadImages();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('成功导入${urlStrings.length}张图片')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON格式错误，请检查输入')),
                  );
                }
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }
}