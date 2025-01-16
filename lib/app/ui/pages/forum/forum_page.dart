import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_shimmer_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final ForumService _forumService = Get.find<ForumService>();
  List<ForumCategoryTreeModel>? _categories;
  bool _isLoading = true;
  String? _error;
  final UserService userService = Get.find<UserService>();
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _forumService.getForumCategoryTree();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _categories = result.data;
          _error = null;
        } else {
          _error = result.message;
          _categories = null;
        }
      });
    }
  }

  void _showPostDialog() {
    UserService userService = Get.find<UserService>();
    if (!userService.isLogin) {
      AppService.switchGlobalDrawer();
      showToastWidget(MDToastWidget(message: slang.t.errors.pleaseLoginFirst, type: MDToastType.warning));
      return;
    }
    Get.dialog(
      ForumPostDialog(
        onSubmit: () {
          // 刷新帖子列表
          _loadCategories();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Obx(() {
                if (userService.isLogin) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AvatarWidget(
                        avatarUrl: userService.userAvatar,
                        radius: 14,
                        defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                        isPremium: userService.currentUser.value?.premium ?? false,
                        isAdmin: userService.currentUser.value?.isAdmin ?? false,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Obx(() {
                          final count = userService.notificationCount.value + userService.messagesCount.value;
                          if (count > 0) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ),
                    ],
                  );
                } else {
                  return const Icon(Icons.account_circle);
                }
              }),
              onPressed: () {
                AppService.switchGlobalDrawer();
              },
            ),
            Text(t.forum.forum),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.dialog(SearchDialog(
                initialSearch: '',
                initialSegment: SearchSegment.forum,
                onSearch: (searchInfo, segment) {
                  NaviService.toSearchPage(
                    searchInfo: searchInfo,
                    segment: segment,
                  );
                },
              ));
            },
            tooltip: t.common.search,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: t.common.refresh,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showPostDialog,
            tooltip: t.forum.createThread,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const ForumShimmerWidget();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: Text(slang.t.common.retry),
            ),
          ],
        ),
      );
    }

    if (_categories == null || _categories!.isEmpty) {
      return MyEmptyWidget(
        onRefresh: _loadCategories,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕宽度决定是否使用双列布局
          final bool isWideScreen = constraints.maxWidth > 900;

          if (isWideScreen) {
            // PC端双列布局
            return _buildWideLayout();
          } else {
            // 移动端单列布局
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _categories!.length,
      itemBuilder: (context, index) {
        return _buildCategorySection(_categories![index]);
      },
    );
  }

  Widget _buildNarrowLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _categories!.length,
      itemBuilder: (context, index) {
        return _buildCategorySection(_categories![index]);
      },
    );
  }

  Widget _buildCategorySection(ForumCategoryTreeModel category) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题栏
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category.name),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // 子分类列表
          if (isWideScreen)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4), // 标题
                1: FlexColumnWidth(1), // 主题数
                2: FlexColumnWidth(1), // 回复数
                3: FlexColumnWidth(3), // 最后回复
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ),
                  children: [
                    _buildTableHeader(context, '板块'),
                    _buildTableHeader(context, '主题'),
                    _buildTableHeader(context, '回复'),
                    _buildTableHeader(context, '最后回复'),
                  ],
                ),
              ],
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.children.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subCategory = category.children[index];
              return _buildSubCategoryTile(subCategory, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSubCategoryTile(ForumCategoryModel subCategory, BuildContext context) {
    final t = slang.Translations.of(context);
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    if (isWideScreen) {
      return InkWell(
        onTap: () {
          // TODO: 导航到分类详情页面
          NaviService.navigateToForumThreadListPage(subCategory.id);
        },
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4), // 标题
            1: FlexColumnWidth(1), // 主题数
            2: FlexColumnWidth(1), // 回复数
            3: FlexColumnWidth(3), // 最后回复
          },
          children: [
            TableRow(
              children: [
                // 标题列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        subCategory.locked ? Icons.lock : _getSubCategoryIcon(subCategory.id),
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subCategory.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (subCategory.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                subCategory.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 主题数列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    CommonUtils.formatFriendlyNumber(subCategory.numThreads),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // 回复数列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    CommonUtils.formatFriendlyNumber(subCategory.numPosts),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // 最后回复列
                if (subCategory.lastThread?.lastPost != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            NaviService.navigateToAuthorProfilePage(subCategory.lastThread!.lastPost!.user.username);
                          },
                          child: AvatarWidget(
                            avatarUrl: subCategory.lastThread!.lastPost?.user.avatar?.avatarUrl,
                            radius: 16,
                            headers: const {'referer': CommonConstants.iwaraBaseUrl},
                            defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                            isPremium: subCategory.lastThread!.lastPost?.user.premium ?? false,
                            isAdmin: subCategory.lastThread!.lastPost?.user.isAdmin ?? false,
                            role: subCategory.lastThread!.lastPost?.user.role,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (subCategory.lastThread!.sticky)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.push_pin,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        NaviService.navigateToForumThreadDetailPage(subCategory.id, subCategory.lastThread!.id);
                                      },
                                      child: Text(
                                        subCategory.lastThread!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        NaviService.navigateToAuthorProfilePage(subCategory.lastThread!.lastPost!.user.username);
                                      },
                                      child: _buildUserName(subCategory.lastThread!.lastPost!.user),
                                    ),
                                  ),
                                  Text(
                                    ' · ${CommonUtils.formatFriendlyTimestamp(subCategory.lastThread!.updatedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.remove_red_eye,
                                    size: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CommonUtils.formatFriendlyNumber(subCategory.lastThread!.numViews),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('暂无回复'),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    // 窄屏布局保持不变
    return InkWell(
      onTap: () {
        NaviService.navigateToForumThreadListPage(subCategory.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类名称和统计信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Icon(
                      subCategory.locked ? Icons.lock : _getSubCategoryIcon(subCategory.id),
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subCategory.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${t.forum.threads}: ${CommonUtils.formatFriendlyNumber(subCategory.numThreads)}  ${t.forum.posts}: ${CommonUtils.formatFriendlyNumber(subCategory.numPosts)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (subCategory.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subCategory.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (subCategory.lastThread != null) ...[
              const SizedBox(height: 8),
              // 最后发帖信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: AvatarWidget(
                        avatarUrl: subCategory.lastThread!.lastPost?.user.avatar?.avatarUrl,
                        radius: 16,
                        headers: const {'referer': CommonConstants.iwaraBaseUrl},
                        defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                        isPremium: subCategory.lastThread!.lastPost?.user.premium ?? false,
                        isAdmin: subCategory.lastThread!.lastPost?.user.isAdmin ?? false,
                        role: subCategory.lastThread!.lastPost?.user.role,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            NaviService.navigateToForumThreadDetailPage(subCategory.id, subCategory.lastThread!.id);
                          },
                          child: Text(
                            subCategory.lastThread!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (subCategory.lastThread!.lastPost != null)
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    NaviService.navigateToAuthorProfilePage(subCategory.lastThread!.lastPost!.user.username);
                                  },
                                  child: _buildUserName(subCategory.lastThread!.lastPost!.user),
                                ),
                              ),
                              Text(
                                ' · ${CommonUtils.formatFriendlyTimestamp(subCategory.lastThread!.updatedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserName(User user) {
    // 根据用户角色设置颜色
    Color? nameColor;
    if (user.role == 'officer' || user.role == 'moderator' || user.role == 'admin') {
      nameColor = Colors.green.shade400;
    } else if (user.role == 'limited') {
      nameColor = Colors.grey.shade400;
    } else {
      nameColor = user.isAdmin ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant;
    }

    // 如果是高级用户,使用渐变效果
    if (user.premium) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.purple.shade300,
            Colors.blue.shade300,
            Colors.pink.shade300,
          ],
        ).createShader(bounds),
        child: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      );
    }

    // 普通用户名显示
    return Text(
      user.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: nameColor,
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final t = slang.Translations.of(context);
    if (categoryName == t.forum.groups.administration) {
      return Icons.admin_panel_settings;
    } else if (categoryName == t.forum.groups.global) {
      return Icons.language;
    } else if (categoryName == t.forum.groups.chinese) {
      return Icons.language;
    } else if (categoryName == t.forum.groups.japanese) {
      return Icons.language;
    } else {
      return Icons.forum;
    }
  }

  IconData _getSubCategoryIcon(String id) {
    switch (id) {
      case 'announcements':
        return Icons.campaign;
      case 'feedback':
        return Icons.feedback;
      case 'support':
      case 'support-zh':
      case 'support-ja':
        return Icons.help;
      case 'general':
      case 'general-zh':
      case 'general-ja':
        return Icons.forum;
      case 'guides':
        return Icons.menu_book;
      case 'questions':
      case 'questions-zh':
      case 'questions-ja':
        return Icons.question_answer;
      case 'requests':
      case 'requests-zh':
      case 'requests-ja':
        return Icons.record_voice_over;
      case 'sharing':
        return Icons.share;
      case 'korean':
        return Icons.translate;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.forum;
    }
  }
}
