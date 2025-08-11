import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/services/upload_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/common/constants.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

enum _ImportMenuAction { addByUrl, batchImport, uploadLocal }

class EmojiGroupDetailSheet extends StatefulWidget {
  final EmojiGroup group;

  const EmojiGroupDetailSheet({super.key, required this.group});

  @override
  State<EmojiGroupDetailSheet> createState() => _EmojiGroupDetailSheetState();
}

class _EmojiGroupDetailSheetState extends State<EmojiGroupDetailSheet> {
  late EmojiLibraryService _emojiService;
  late UploadService _uploadService;
  List<EmojiImage> _images = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<int> _selectedImages = {};

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();
    _uploadService = Get.find<UploadService>();
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.group.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isSelectionMode) ...[
                  PopupMenuButton<_ImportMenuAction>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) {
                      switch (action) {
                        case _ImportMenuAction.addByUrl:
                          _showUrlInputDialog();
                          break;
                        case _ImportMenuAction.batchImport:
                          _showBatchImportDialog();
                          break;
                        case _ImportMenuAction.uploadLocal:
                          _showLocalUploadDialog();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final t = Translations.of(context);
                      return [
                        PopupMenuItem(
                          value: _ImportMenuAction.addByUrl,
                           child: Row(
                             children: [
                               const Icon(Icons.link, size: 18),
                               const SizedBox(width: 8),
                               Text(t.emoji.addImageByUrl),
                             ],
                           ),
                        ),
                        PopupMenuItem(
                          value: _ImportMenuAction.batchImport,
                           child: Row(
                             children: [
                               const Icon(Icons.file_upload, size: 18),
                               const SizedBox(width: 8),
                               Text(t.emoji.batchImport),
                             ],
                           ),
                        ),
                        PopupMenuItem(
                          value: _ImportMenuAction.uploadLocal,
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file, size: 18),
                              const SizedBox(width: 8),
                              Text(t.emoji.uploadLocalImages),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () => _toggleSelectionMode(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      shape: const CircleBorder(),
                    ),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: _selectedImages.length == _images.length ? _clearSelection : _selectAllImages,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      shape: const CircleBorder(),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showBatchDeleteDialog(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSelectionMode,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: _isLoading
                ? _buildGridShimmer()
                : _images.isEmpty
                    ? _buildEmptyState()
                    : _buildImageGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = Translations.of(context);
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
          Text(
            t.emoji.noEmojis,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.emoji.clickToAddEmojis,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddImagesDialog(),
            icon: const Icon(Icons.add),
            label: Text(t.emoji.addEmojis),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3; // 默认3列
    
    // 根据屏幕宽度动态调整列数
    if (screenWidth > 1200) {
      crossAxisCount = 8; // 超宽屏显示8列
    } else if (screenWidth > 900) {
      crossAxisCount = 6; // 宽屏显示6列
    } else if (screenWidth > 600) {
      crossAxisCount = 4; // 中等屏幕显示4列
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image.thumbnailUrl ?? image.url,
                    fit: BoxFit.cover,
                    headers: const {'referer': CommonConstants.iwaraBaseUrl},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
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
                      color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
    final t = Translations.of(context);
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
                        t.emoji.imagePreview,
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
                      headers: const {'referer': CommonConstants.iwaraBaseUrl},
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(t.emoji.imageLoadFailed, style: const TextStyle(color: Colors.grey)),
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
                        label: Text(t.emoji.delete, style: const TextStyle(color: Colors.red)),
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
                        label: Text(t.emoji.close),
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
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.deleteImage),
        content: Text(t.emoji.confirmDeleteImage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              _emojiService.deleteEmojiImage(image.imageId);
              Navigator.pop(context);
              _loadImages();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.emoji.delete),
          ),
        ],
      ),
    );
  }

  void _showBatchDeleteDialog() {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.batchDelete),
        content: Text(t.emoji.confirmBatchDelete(count: _selectedImages.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
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
                SnackBar(content: Text(t.emoji.deleteSuccess)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.emoji.delete),
          ),
        ],
      ),
    );
  }

  void _showAddImagesDialog() {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.addImage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(t.emoji.addImageByUrl),
              onTap: () {
                Navigator.pop(context);
                _showUrlInputDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: Text(t.emoji.batchImport),
              onTap: () {
                Navigator.pop(context);
                _showBatchImportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(t.emoji.uploadLocalImages),
              onTap: () {
                Navigator.pop(context);
                _showLocalUploadDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog() {
    final t = Translations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.addImageUrl),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: t.emoji.imageUrl,
            hintText: t.emoji.enterImageUrl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
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
            child: Text(t.emoji.add),
          ),
        ],
      ),
    );
  }

  void _showBatchImportDialog() {
    final t = Translations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.emoji.batchImport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.emoji.enterJsonUrlArray),
            const SizedBox(height: 8),
            Text(
              t.emoji.formatExample,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: t.emoji.pasteJsonUrlArray,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.emoji.cancel),
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
                    SnackBar(content: Text(t.emoji.importSuccess(count: urlStrings.length))),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.emoji.jsonFormatError)),
                  );
                }
              }
            },
            child: Text(t.emoji.import),
          ),
        ],
      ),
    );
  }

  void _showLocalUploadDialog() async {
    try {
      // 选择图片文件
      final files = await _uploadService.pickImageFiles();
      if (files.isEmpty) {
        return; // 用户取消选择
      }

      // 显示上传进度对话框
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
         useRootNavigator: true,
        builder: (context) => _buildUploadProgressDialog(files.length),
      );

      // 批量上传图片
      final uploadedImages = await _uploadService.uploadImageFiles(files);

      // 关闭进度对话框
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (uploadedImages.isNotEmpty) {
        // 将上传的图片添加到表情包组
        final urls = uploadedImages.map((img) => img.originalUrl).toList();
        _emojiService.addEmojiImagesBatch(widget.group.groupId, urls);

        // 刷新图片列表
        _loadImages();

        // 显示成功消息
        if (mounted) {
          final successCount = uploadedImages.length;
          final failedCount = files.length - successCount;
          String message = t.emoji.uploadSuccess(count: successCount);
          if (failedCount > 0) {
            message += '，${t.emoji.uploadFailed(count: failedCount)}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: successCount > 0 ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        // 所有上传都失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.emoji.uploadFailedMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 关闭可能存在的进度对话框
      if (mounted) {
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        if (rootNavigator.canPop()) {
          rootNavigator.pop();
        }
      }

      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.emoji.uploadErrorMessage(error: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUploadProgressDialog(int totalFiles) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.cloud_upload, color: Colors.blue),
          const SizedBox(width: 8),
          Text(t.emoji.uploadingImages),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(t.emoji.uploadingImagesProgress(count: totalFiles)),
          const SizedBox(height: 8),
          Text(
            t.emoji.doNotCloseDialog,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 加载骨架屏
  Widget _buildGridShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (screenWidth > 1200) {
      crossAxisCount = 8;
    } else if (screenWidth > 900) {
      crossAxisCount = 6;
    } else if (screenWidth > 600) {
      crossAxisCount = 4;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: crossAxisCount * 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

// 静态方法用于显示 sheet
class EmojiGroupDetailPage {
  static void show(BuildContext context, EmojiGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiGroupDetailSheet(group: group),
    );
  }
}