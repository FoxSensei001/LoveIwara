import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_remove_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common/constants.dart';
import '../../../../models/comment.model.dart';
import '../../../widgets/custom_markdown_body_widget.dart';
import '../widgets/comment_input_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentItem extends StatefulWidget {
  final Comment comment;
  final String? authorUserId;
  final CommentController? controller;

  static const double _tagFontSize = 11.0;
  static const EdgeInsets _tagPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 2);

  const CommentItem({
    super.key, 
    required this.comment, 
    this.authorUserId,
    this.controller,
  });

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isRepliesExpanded = false;
  bool _isTranslationMenuVisible = false;
  bool _isTranslating = false;
  String? _translatedText;
  final UserService _userService = Get.find();
  final List<Comment> _replies = [];
  bool _isLoadingReplies = false;
  bool _hasMoreReplies = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  String? _errorMessage;

  final TranslationService _translationService = Get.find();
  final ConfigService _configService = Get.find();
  final CommentService _commentService = Get.find();

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchReplies({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _replies.clear();
        _hasMoreReplies = true;
        _errorMessage = null;
      });
    }

    if (!_hasMoreReplies || _isLoadingReplies) return;

    setState(() {
      _isLoadingReplies = true;
    });

    try {
      String type;
      String id;
      if (widget.comment.videoId != null) {
        type = CommentType.video.name;
        id = widget.comment.videoId!;
      } else if (widget.comment.profileId != null) {
        type = CommentType.profile.name;
        id = widget.comment.profileId!;
      } else if (widget.comment.imageId != null) {
        type = CommentType.image.name;
        id = widget.comment.imageId!;
      } else if (widget.comment.postId != null) {
        type = CommentType.post.name;
        id = widget.comment.postId!;
      } else {
        throw Exception('未知的评论类型');
      }

      final result = await _commentService.getComments(
        type: type,
        id: id,
        parentId: widget.comment.id,
        page: _currentPage,
        limit: _pageSize,
      );

      if (result.isSuccess) {
        final pageData = result.data!;
        final fetchedReplies = pageData.results;

        setState(() {
          _replies.addAll(fetchedReplies);
          _currentPage++;
          _hasMoreReplies = fetchedReplies.length >= _pageSize;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
          _hasMoreReplies = false;
        });
      }
    } catch (e) {
      LogUtils.e('获取评论回复失败', error: e, tag: 'CommentItem');
      setState(() {
        _errorMessage = slang.t.errors.errorWhileFetchingReplies;
        _hasMoreReplies = false;
      });
    } finally {
      setState(() {
        _isLoadingReplies = false;
      });
    }
  }

  void _handleViewReplies() {
    setState(() {
      _isRepliesExpanded = !_isRepliesExpanded;
    });

    if (_isRepliesExpanded && _replies.isEmpty && !_isLoadingReplies) {
      _fetchReplies(refresh: true);
    }
  }

  Widget _buildRepliesList(BuildContext context) {
    final t = slang.Translations.of(context);
    if (_isLoadingReplies && _replies.isEmpty) {
      return Column(
        children: List.generate(
          widget.comment.numReplies, 
          (index) => _buildShimmerItem()
        ),
      );
    } else if (_errorMessage != null && _replies.isEmpty) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (!_isLoadingReplies && _replies.isEmpty) {
      return Center(child: Text(t.common.tmpNoReplies));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _replies.length + (_hasMoreReplies ? 1 : 0),
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 48.0,
            endIndent: 16.0,
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            if (index < _replies.length) {
              return CommentItem(
                comment: _replies[index],
                authorUserId: widget.authorUserId,
                controller: widget.controller,
              );
            } else {
              if (_isLoadingReplies) {
                return _buildShimmerItem();
              } else if (_hasMoreReplies) {
                return TextButton(
                  onPressed: () {
                    if (!_isLoadingReplies) {
                      _fetchReplies();
                    }
                  },
                  child: Text(t.common.loadMore),
                );
              } else {
                return Center(child: Text(t.common.noMoreDatas));
              }
            }
          },
        ),
      ],
    );
  }

  /// 构建 Shimmer 占位符
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.comment.parent != null ? 32.0 : 16.0,
          right: 0.0,
          top: 8.0,
          bottom: 8.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像占位符
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
            ),
            const SizedBox(width: 8),
            // 文本占位符
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10.0, color: Colors.white),
                  const SizedBox(height: 6.0),
                  Container(height: 10.0, width: 150.0, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTranslationMenu() {
    if (_isTranslationMenuVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _showTranslationMenuOverlay();
    }
    setState(() {
      _isTranslationMenuVisible = !_isTranslationMenuVisible;
    });
  }

  void _showTranslationMenuOverlay() {
    _overlayEntry?.remove();
    
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 40),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: CommonConstants.translationSorts.map((sort) {
                final isSelected = sort.id == _configService.currentTranslationSort.id;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  title: Text(sort.label),
                  onTap: () {
                    _configService.updateTranslationLanguage(sort);
                    _toggleTranslationMenu();
                    if (_translatedText != null) {
                      _handleTranslation();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showTranslationMenuDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  slang.t.common.selectTranslationLanguage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(Get.context!).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: CommonConstants.translationSorts.map((sort) {
                      final isSelected = sort.id == _configService.currentTranslationSort.id;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        title: Text(sort.label),
                        trailing: isSelected ? const Icon(Icons.check, size: 18) : null,
                        onTap: () {
                          _configService.updateTranslationLanguage(sort);
                          AppService.tryPop();
                          if (_translatedText != null) {
                            _handleTranslation();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildTranslationButton(BuildContext context) {
    final t = slang.Translations.of(context);
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 左侧翻译按钮
          InkWell(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            onTap: _isTranslating ? null : () => _handleTranslation(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isTranslating)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.translate,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    t.common.translate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 分割线
          Container(
            height: 24,
            width: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
          ),
          // 右侧下拉按钮
          InkWell(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            onTap: _showTranslationMenuDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_drop_down,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTranslation() async {
    if (_isTranslating) return;

    setState(() => _isTranslating = true);

    ApiResult<String> result =
        await _translationService.translate(widget.comment.body);
    if (result.isSuccess) {
      setState(() {
        _translatedText = result.data;
        _isTranslating = false;
      });
    } else {
      setState(() {
        _translatedText = slang.t.common.translateFailedPleaseTryAgainLater;
        _isTranslating = false;
      });
    }
  }

  // 构建翻译后的内容区域
  Widget _buildTranslatedContent(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, size: 14),
              const SizedBox(width: 4),
              Text(
                t.common.translationResult,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Powered by Google',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_translatedText == t.common.translateFailedPleaseTryAgainLater)
            Text(
              _translatedText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            )
          else
            CustomMarkdownBody(
              data: _translatedText!,
            ),
        ],
      ),
    );
  }

  // 添加这个方法来构建标签
  Widget _buildCommentTag(String text, Color color, IconData icon) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        Color tagColor;
        switch (text) {
          case String t when t == slang.t.common.me:
            tagColor = colorScheme.primary;
            break;
          case String t when t == slang.t.common.premium:
            tagColor = colorScheme.tertiary;
            break;
          case String t when t == slang.t.common.author:
            tagColor = colorScheme.secondary;
            break;
          case String t when t == slang.t.common.admin:
            tagColor = colorScheme.error;
            break;
          default:
            tagColor = colorScheme.primary;
        }

        return Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tagColor.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 10,
                color: tagColor.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: tagColor.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建时间显示区域
  Widget _buildTimeInfo(Comment comment, BuildContext context) {
    final t = slang.Translations.of(context);
    if (comment.createdAt == null) return const SizedBox.shrink();

    final hasEdit = comment.updatedAt != null &&
        comment.createdAt != null &&
        comment.updatedAt!.isAfter(comment.createdAt!);

    final timeTextStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.75),
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 创建时间
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.75),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CommonUtils.formatFriendlyTimestamp(comment.createdAt),
                    style: timeTextStyle,
                  ),
                ],
              ),
              // 编辑时间
              if (hasEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_calendar,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.common.editedAt(num: CommonUtils.formatFriendlyTimestamp(comment.updatedAt)),
                        style: timeTextStyle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // 回复数量指示器
        if (widget.comment.numReplies > 0)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _handleViewReplies,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge.count(
                      count: widget.comment.numReplies,
                      child: Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isRepliesExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmDialog() {
    if (widget.controller == null) {
      showToastWidget(MDToastWidget(message: slang.t.errors.canNotFindCommentController, type: MDToastType.error));
      return;
    }

    Get.dialog(
      CommentRemoveDialog(
        onDelete: () async {
          await widget.controller!.deleteComment(widget.comment.id);
          AppService.tryPop();
        },
      ),
    );
  }

  void _showEditDialog() {
    if (widget.controller == null) {
      showToastWidget(MDToastWidget(message: slang.t.errors.canNotFindCommentController, type: MDToastType.error));
      return;
    }

    Get.dialog(
      CommentInputDialog(
        initialText: widget.comment.body,
        title: slang.t.common.editComment,
        submitText: slang.t.common.save,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showToastWidget(MDToastWidget(message: slang.t.errors.commentCanNotBeEmpty, type: MDToastType.error));
            return;
          }

          // 如果是主评论
          if (widget.comment.parent == null) {
            await widget.controller!.editComment(widget.comment.id, text);
          } else {
            // 如果是回复评论
            final result = await _commentService.editComment(widget.comment.id, text);
            if (result.isSuccess) {
              setState(() {
                // 更新本地评论内容
                final index = _replies.indexWhere((c) => c.id == widget.comment.id);
                if (index != -1) {
                  _replies[index] = widget.comment.copyWith(
                    body: text,
                    updatedAt: DateTime.now(),
                  );
                }
              });
              showToastWidget(MDToastWidget(message: slang.t.common.commentUpdated, type: MDToastType.success));
              AppService.tryPop();
            } else {
              showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
            }
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  void _showReplyDialog() {
    if (widget.controller == null) {
      showToastWidget(MDToastWidget(message: slang.t.errors.canNotFindCommentController, type: MDToastType.error));
      return;
    }

    Get.dialog(
      CommentInputDialog(
        title: slang.t.common.replyComment,
        submitText: slang.t.common.reply,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showToastWidget(MDToastWidget(message: slang.t.errors.commentCanNotBeEmpty, type: MDToastType.error));
            return;
          }
          final result = await widget.controller!.postComment(
            text,
            parentId: widget.comment.id,
          );
          
          // 如果发布成功且回复列表已展开，将新回复添加到列表开头
          if (result.isSuccess && result.data != null && _isRepliesExpanded) {
            setState(() {
              _replies.insert(0, result.data!);
            });
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  // 新增操作菜单构建方法
  Widget _buildActionMenu(BuildContext context) {
    final t = slang.Translations.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16),
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        if (widget.comment.parent == null)
          PopupMenuItem(
            value: 'reply',
            child: Row(
              children: [
                const Icon(Icons.reply, size: 16),
                const SizedBox(width: 8),
                Text(t.common.reply, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        if (_userService.currentUser.value?.id == widget.comment.user?.id) ...[
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16),
                const SizedBox(width: 8),
                Text(t.common.edit, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 16),
                const SizedBox(width: 8),
                Text(t.common.delete, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ],
      onSelected: (value) {
        switch (value) {
          case 'reply':
            _showReplyDialog();
            break;
          case 'edit':
            _showEditDialog();
            break;
          case 'delete':
            _showDeleteConfirmDialog();
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final t = slang.Translations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: comment.parent != null ? 32.0 : 16.0,
        right: 0.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息行
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(comment.user?.username ?? ''),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 头像
                  _buildUserAvatar(comment),
                  const SizedBox(width: 8),
                  // 用户名、标签等信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户名行
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 会员用户名
                            Flexible(
                              child: comment.user?.premium == true
                                ? ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.purple.shade300,
                                        Colors.blue.shade300,
                                        Colors.pink.shade300,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      comment.user?.name ?? slang.t.common.unknownUser,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Text(
                                    comment.user?.name ?? slang.t.common.unknownUser,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ),
                          ],
                        ),
                        // 标签行
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (comment.user?.id == _userService.currentUser.value?.id)
                                _buildCommentTag(t.common.me, Colors.blue, Icons.person),
                              if (comment.user?.premium == true)
                                _buildCommentTag(t.common.premium, Colors.purple, Icons.star),
                              if (comment.user?.id == widget.authorUserId)
                                _buildCommentTag(t.common.author, Colors.green, Icons.verified_user),
                              if (comment.user?.role.contains('admin') == true)
                                _buildCommentTag(t.common.admin, Colors.red, Icons.admin_panel_settings),
                            ],
                          ),
                        ),
                        // @用户名
                        Text(
                          '@${comment.user?.username ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 评论内容
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 评论内容 - 添加点击回复功能
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.comment.parent == null ? _showReplyDialog : null,
                    child: CustomMarkdownBody(data: comment.body),
                  ),
                ),
                if (_translatedText != null) ...[
                  const SizedBox(height: 8),
                  _buildTranslatedContent(context),
                ],
                const SizedBox(height: 8),
                // 回复、翻译和操作按钮行
                Row(
                  children: [
                    // 翻译按钮
                    _buildTranslationButton(context),
                    const Spacer(),
                    // 回复按钮 - 只在非回复评论中显示
                    if (comment.parent == null)
                      IconButton(
                        onPressed: _showReplyDialog,
                        icon: const Icon(Icons.reply, size: 20),
                        visualDensity: VisualDensity.compact,
                        tooltip: t.common.reply,
                        style: IconButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    _buildActionMenu(context),
                  ],
                ),
                const SizedBox(height: 4),
                // 时间和查看回复按钮行
                _buildTimeInfo(comment, context),
              ],
            ),
          ),
          // 回复列表
          if (_isRepliesExpanded) _buildRepliesList(context),
        ],
      ),
    );
  }

  // 构建用户头像
  Widget _buildUserAvatar(Comment comment) {
    return AvatarWidget(
      avatarUrl: comment.user?.avatar?.avatarUrl, 
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      headers: const {'referer': CommonConstants.iwaraBaseUrl},
      radius: 20,
      isPremium: comment.user?.premium ?? false,
      isAdmin: comment.user?.isAdmin ?? false,
    );
  }

}
