import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/services/upload_service.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/app/models/user_notifications.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  final UserService _userService = Get.find<UserService>();
  bool _isLoading = true;
  bool _isUploadingAvatar = false;
  bool _isUploadingHeader = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _userService.fetchUserProfile();
    } catch (e) {
      showGlassToast(
        slang.t.personalProfile.fetchUserProfileFailed(error: e.toString()),
        type: GlassToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: _buildBody(context, headerExtent),
        // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊（刷新）
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: slang.t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassTitlePill(
                  title: slang.t.personalProfile.editPersonalProfile,
                ),
              ),
              const SizedBox(width: 8),
              GlassButtonGroup(
                children: [
                  GlassIconButton(
                    // 拉取中图标原位换成沙漏（液态玻璃形变词汇表）
                    icon: const Icon(Icons.refresh),
                    loading: _isLoading,
                    tooltip: slang.t.common.refresh,
                    onPressed: _refresh,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    if (mounted) setState(() => _isLoading = true);
    await _fetchData();
  }

  Widget _buildBody(BuildContext context, double headerExtent) {
    if (_isLoading) {
      return _PersonalProfileSkeleton(paddingTop: headerExtent);
    }
    return Obx(() {
      final user = _userService.currentUser.value;
      if (user == null) {
        return Center(child: Text(slang.t.auth.notLoggedIn));
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final bool isWide = screenWidth > 600;
      final double avatarSize = isWide ? 140.0 : 100.0;
      final double buttonContainerSize = isWide ? 44.0 : 36.0;
      final double iconSize = isWide ? 24.0 : 20.0;
      // 圆形头像上的编辑徽标：中心落在圆周 45° 处，让徽标"骑"在边缘上，
      // 而不是像 right:0/bottom:0 那样整块扣进头像照片内部挡脸。
      final double avatarBadgeOffset =
          avatarSize / 2 * (1 - math.sqrt2 / 2) - buttonContainerSize / 2;

      return RefreshIndicator(
        // 指示器从 header 下方弹出
        displacement: headerExtent,
        onRefresh: _fetchData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: headerExtent,
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const SizedBox(height: 24),
            // 头像区域
            Center(
              child: Column(
                children: [
                  Stack(
                    // 徽标偏移量为负，需要允许它溢出 Stack 的隐式(头像大小)边界
                    clipBehavior: Clip.none,
                    children: [
                      AvatarWidget(user: user, size: avatarSize),
                      Positioned(
                        right: avatarBadgeOffset,
                        bottom: avatarBadgeOffset,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: _isUploadingAvatar
                              ? SizedBox(
                                  width: buttonContainerSize,
                                  height: buttonContainerSize,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(Icons.camera_alt, size: iconSize),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  onPressed: _pickAndUploadAvatar,
                                  constraints: BoxConstraints(
                                    minWidth: buttonContainerSize,
                                    minHeight: buttonContainerSize,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slang.t.personalProfile.suggestedResolution(
                      resolution: '300x300',
                      size: '0.6MB',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  Text(
                    slang.t.personalProfile.supportedFormats(
                      formats: '.jpg, .png, .gif, .webp, .webm',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  if (user.premium != true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        slang.t.personalProfile.premiumBenefit(
                          type: slang.t.personalProfile.avatar,
                          formats: '.gif, .webp',
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 背景图片分组
            _buildSectionCard(
              context,
              title: slang.t.personalProfile.homepageBackground,
              children: [_buildHeaderImageSection(context, user)],
            ),

            // 基本信息分组
            _buildSectionCard(
              context,
              title: slang.t.personalProfile.basicInfo,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(slang.t.personalProfile.nickname),
                  subtitle: Text(user.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditNicknameDialog(context, user.name),
                ),
                ListTile(
                  leading: const Icon(Icons.alternate_email),
                  title: Text(slang.t.personalProfile.username),
                  subtitle: Text(user.username),
                  // 用户名通常不可修改，或者有单独的修改流程
                  trailing: const Icon(Icons.copy, size: 18),
                  onTap: () {
                    // 复制用户名
                    Clipboard.setData(ClipboardData(text: user.username));
                    showGlassToast(
                      slang.t.personalProfile.usernameCopied,
                      type: GlassToastType.success,
                    );
                  },
                ),
              ],
            ),

            // 个人简介分组
            _buildSectionCard(
              context,
              title: slang.t.personalProfile.personalIntroduction,
              children: [
                InkWell(
                  onTap: () =>
                      _showEditDescriptionDialog(context, user.description),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user.description != null &&
                            user.description!.isNotEmpty)
                          CustomMarkdownBody(data: user.description!)
                        else
                          Text(
                            slang.t.personalProfile.noPersonalIntroduction,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              slang.t.personalProfile.clickToEdit,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 通知设置分组
            _buildSectionCard(
              context,
              title: slang.t.personalProfile.notificationSettings,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.comment_outlined),
                  title: Text(
                    slang.t.personalProfile.contentCommentNotification,
                  ),
                  subtitle: Text(
                    slang.t.personalProfile.contentCommentNotificationDesc,
                  ),
                  value: user.notifications?.comment ?? false,
                  onChanged: (bool value) =>
                      _handleToggleNotification('comment', value),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.reply_outlined),
                  title: Text(slang.t.personalProfile.commentReplyNotification),
                  subtitle: Text(
                    slang.t.personalProfile.commentReplyNotificationDesc,
                  ),
                  value: user.notifications?.reply ?? false,
                  onChanged: (bool value) =>
                      _handleToggleNotification('reply', value),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alternate_email_outlined),
                  title: Text(slang.t.personalProfile.mentionNotification),
                  subtitle: Text(
                    slang.t.personalProfile.mentionNotificationDesc,
                  ),
                  value: user.notifications?.mention ?? false,
                  onChanged: (bool value) =>
                      _handleToggleNotification('mention', value),
                ),
              ],
            ),

            // 账号信息分组
            _buildSectionCard(
              context,
              title: slang.t.personalProfile.accountInfo,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(slang.t.personalProfile.registrationTime),
                  subtitle: Text(
                    // 简单格式化
                    "${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  /// 分组卡片：圆角描边卡 + 顶部小标题（与设置页的分组卡同款）。
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleNotification(String key, bool value) async {
    final user = _userService.currentUser.value;
    if (user == null) return;

    final originalNotifications = user.notifications ?? UserNotifications();
    final updatedNotifications = originalNotifications.copyWith(
      comment: key == 'comment' ? value : originalNotifications.comment,
      reply: key == 'reply' ? value : originalNotifications.reply,
      mention: key == 'mention' ? value : originalNotifications.mention,
    );

    // 1. 乐观更新
    _userService.currentUser.value = user.copyWith(
      notifications: updatedNotifications,
    );

    // 2. 发送请求
    final result = await _userService.updateUserProfile(
      notifications: updatedNotifications,
    );

    if (!result.isSuccess) {
      // 3. 失败回滚
      _userService.currentUser.value = user.copyWith(
        notifications: originalNotifications,
      );
      showGlassToast(
        slang.t.personalProfile.updateNotificationSettingsFailed(
          error: result.message,
        ),
        type: GlassToastType.error,
      );
    }
  }

  void _showEditNicknameDialog(BuildContext context, String currentName) {
    showAppDialog(
      _EditNicknameDialog(currentName: currentName, userService: _userService),
    );
  }

  void _showEditDescriptionDialog(
    BuildContext context,
    String? currentDescription,
  ) {
    // 使用 BaseDialogInput 来提供富文本编辑体验（Markdown、预览、翻译等）
    showAppDialog(
      _EditDescriptionDialog(
        initialText: currentDescription,
        userService: _userService,
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final uploadService = await UploadService.getInstance();
    final files = await uploadService.pickImageFiles();
    if (files.isEmpty) return;

    final file = files.first;
    final ext = path.extension(file.path).toLowerCase();
    final allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.webm',
    ];

    if (!allowedExtensions.contains(ext)) {
      showGlassToast(
        slang.t.personalProfile.unsupportedFileFormat,
        type: GlassToastType.error,
      );
      return;
    }

    final fileSize = await file.length();
    if (fileSize > 0.6 * 1024 * 1024) {
      showGlassToast(
        slang.t.personalProfile.fileTooLarge(size: '0.6MB'),
        type: GlassToastType.error,
      );
      return;
    }

    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      final uploadedImage = await uploadService.uploadImageFile(file);
      if (uploadedImage == null) {
        showGlassToast(
          slang.t.personalProfile.uploadFailed,
          type: GlassToastType.error,
        );
        return;
      }

      final result = await _userService.updateUserProfile(
        avatar: uploadedImage,
      );
      if (result.isSuccess) {
        showGlassToast(
          slang.t.personalProfile.avatarUpdatedSuccessfully,
          type: GlassToastType.success,
        );
      } else {
        showGlassToast(
          slang.t.personalProfile.updateAvatarFailed(error: result.message),
          type: GlassToastType.error,
        );
      }
    } catch (e) {
      showGlassToast('操作失败: $e', type: GlassToastType.error);
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Widget _buildHeaderImageSection(BuildContext context, User user) {
    final headerUrl = user.header?.headerUrl;
    final fallbackUrl = CommonConstants.defaultProfileHeaderUrl;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 600;
    final double buttonContainerSize = isWide ? 44.0 : 36.0;
    final double iconSize = isWide ? 24.0 : 20.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1500 / 430,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: headerUrl ?? fallbackUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl: fallbackUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: _isUploadingHeader
                      ? SizedBox(
                          width: buttonContainerSize,
                          height: buttonContainerSize,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.camera_alt, size: iconSize),
                          color: Theme.of(context).colorScheme.onPrimary,
                          onPressed: _pickAndUploadHeader,
                          constraints: BoxConstraints(
                            minWidth: buttonContainerSize,
                            minHeight: buttonContainerSize,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            slang.t.personalProfile.suggestedResolution(
              resolution: '1500x430',
              size: '1.5MB',
            ),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            slang.t.personalProfile.supportedFormats(
              formats: '.jpg, .png, .gif, .webp, .webm',
            ),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          if (user.premium != true)
            Text(
              slang.t.personalProfile.premiumBenefit(
                type: slang.t.personalProfile.background,
                formats: '.gif, .webp',
              ),
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadHeader() async {
    final uploadService = await UploadService.getInstance();
    final files = await uploadService.pickImageFiles();
    if (files.isEmpty) return;

    final file = files.first;
    final ext = path.extension(file.path).toLowerCase();
    final allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.webm',
    ];

    if (!allowedExtensions.contains(ext)) {
      showGlassToast(
        slang.t.personalProfile.unsupportedFileFormat,
        type: GlassToastType.error,
      );
      return;
    }

    final fileSize = await file.length();
    if (fileSize > 1.5 * 1024 * 1024) {
      showGlassToast(
        slang.t.personalProfile.fileTooLarge(size: '1.5MB'),
        type: GlassToastType.error,
      );
      return;
    }

    setState(() {
      _isUploadingHeader = true;
    });

    try {
      final uploadedImage = await uploadService.uploadImageFile(file);
      if (uploadedImage == null) {
        showGlassToast(
          slang.t.personalProfile.uploadFailed,
          type: GlassToastType.error,
        );
        return;
      }

      final result = await _userService.updateUserProfile(
        header: uploadedImage,
      );
      if (result.isSuccess) {
        showGlassToast(
          slang.t.personalProfile.backgroundUpdatedSuccessfully,
          type: GlassToastType.success,
        );
      } else {
        showGlassToast(
          slang.t.personalProfile.updateBackgroundFailed(error: result.message),
          type: GlassToastType.error,
        );
      }
    } catch (e) {
      showGlassToast('${slang.t.common.error}: $e', type: GlassToastType.error);
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingHeader = false;
        });
      }
    }
  }
}

/// 昵称编辑弹窗。
///
/// 必须是 StatefulWidget：controller 由弹窗自己的 dispose 回收——放在
/// showDialog 的 whenComplete 里会在退场动画还没播完时就被销毁。
class _EditNicknameDialog extends StatefulWidget {
  const _EditNicknameDialog({
    required this.currentName,
    required this.userService,
  });

  final String currentName;
  final UserService userService;

  @override
  State<_EditNicknameDialog> createState() => _EditNicknameDialogState();
}

class _EditNicknameDialogState extends State<_EditNicknameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentName,
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty) {
      showGlassToast(
        slang.t.personalProfile.nicknameCannotBeEmpty,
        type: GlassToastType.warning,
      );
      return;
    }
    if (newName == widget.currentName) {
      AppService.tryPop();
      return;
    }

    setState(() => _isSaving = true);
    final result = await widget.userService.updateUserProfile(name: newName);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.isSuccess) {
      showGlassToast(
        slang.t.personalProfile.changeSuccess,
        type: GlassToastType.success,
      );
      AppService.tryPop();
    } else {
      showGlassToast(result.message, type: GlassToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      // 标题行：标题 + 玻璃关闭圆钮（全局统一约定）
      title: Row(
        children: [
          Expanded(child: Text(slang.t.personalProfile.editNickname)),
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.close),
            tooltip: slang.t.common.close,
            onPressed: _isSaving ? null : () => AppService.tryPop(),
          ),
        ],
      ),
      content: Container(
        decoration: BoxDecoration(
          color: GlassTokens.fill(colorScheme),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: GlassTokens.stroke(colorScheme),
            width: GlassTokens.strokeWidth,
          ),
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          enabled: !_isSaving,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: slang.t.personalProfile.nicknameCannotBeEmpty,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.person_outline,
              color: colorScheme.onSurfaceVariant,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => AppService.tryPop(),
          child: Text(slang.t.common.cancel),
        ),
        TextButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(slang.t.common.save),
        ),
      ],
    );
  }
}

class _EditDescriptionDialog extends StatefulWidget {
  final String? initialText;
  final UserService userService;

  const _EditDescriptionDialog({
    required this.initialText,
    required this.userService,
  });

  @override
  State<_EditDescriptionDialog> createState() => _EditDescriptionDialogState();
}

class _EditDescriptionDialogState extends State<_EditDescriptionDialog> {
  bool _isLoading = false;

  void _handleSubmit(String text) async {
    if (text == widget.initialText) {
      if (mounted) {
        AppService.tryPop();
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await widget.userService.updateUserProfile(body: text);

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      showGlassToast(
        slang.t.personalProfile.changeSuccess,
        type: GlassToastType.success,
      );
      if (mounted) {
        AppService.tryPop();
      }
    } else {
      showGlassToast(result.message, type: GlassToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialogInput(
      title: slang.t.personalProfile.editPersonalIntroduction,
      hintText: slang.t.personalProfile.enterPersonalIntroduction,
      maxLength: 5000,
      maxLines: 10,
      showEmojiPicker: true,
      showTranslation: true,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: false,
      initialContent: widget.initialText,
      isLoading: _isLoading,
      onSubmit: _handleSubmit,
      submitText: slang.t.common.save,
    );
  }
}

class _PersonalProfileSkeleton extends StatelessWidget {
  const _PersonalProfileSkeleton({required this.paddingTop});

  /// 让出玻璃 header 的高度（与正式内容同一口径）。
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: EdgeInsets.only(top: paddingTop),
        children: [
          const SizedBox(height: 24),
          // Avatar area
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Homepage background section
          _buildSectionHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: AspectRatio(
              aspectRatio: 1500 / 430,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const Divider(),

          // Basic info section
          _buildSectionHeader(),
          _buildListTileSkeleton(),
          _buildListTileSkeleton(),
          const Divider(),

          // Personal introduction section
          _buildSectionHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Divider(),

          // Privacy settings section
          _buildSectionHeader(),
          _buildListTileSkeleton(),
          const Divider(),

          // Notification settings section
          _buildSectionHeader(),
          _buildListTileSkeleton(),
          _buildListTileSkeleton(),
          _buildListTileSkeleton(),
          const Divider(),

          // Account info section
          _buildSectionHeader(),
          _buildListTileSkeleton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        width: 100,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildListTileSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
