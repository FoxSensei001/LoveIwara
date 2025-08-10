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
  bool _isSelectionMode = false;
  Set<int> _selectedImages = {};

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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedImages.clear();
      }
    });
  }

  void _toggleImageSelection(int imageId) {
    setState(() {
      if (_selectedImages.contains(imageId)) {
        _selectedImages.remove(imageId);
      } else {
        _selectedImages.add(imageId);
      }
    });
  }

  void _selectAllImages() {
    setState(() {
      _selectedImages = _images.map((img) => img.imageId).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddImagesDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: () => _showBatchImportDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () => _toggleSelectionMode(),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectedImages.length == _images.length ? _clearSelection : _selectAllImages,
            ),
            if (_selectedImages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showBatchDeleteDialog(),
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
            ),
          ],
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
        final isSelected = _selectedImages.contains(image.imageId);
        
        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleImageSelection(image.imageId);
            }
          },
          onTap: () {
            if (_isSelectionMode) {
              _toggleImageSelection(image.imageId);
            } else {
              _showImagePreview(image);
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
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
              if (_isSelectionMode)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview(EmojiImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '图片预览',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              // 图片内容
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image.url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('图片加载失败', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '加载中... ${(loadingProgress.cumulativeBytesLoaded / 1024).toStringAsFixed(1)}KB',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // 操作按钮
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteImageDialog(image);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('删除', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('关闭'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
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

  void _showBatchDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除选中的${_selectedImages.length}张图片吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              for (final imageId in _selectedImages) {
                _emojiService.deleteEmojiImage(imageId);
              }
              Navigator.pop(context);
              _toggleSelectionMode();
              _loadImages();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('成功删除${_selectedImages.length}张图片')),
              );
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