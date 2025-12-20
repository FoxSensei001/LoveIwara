import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/services/upload_service.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/app/models/user_notifications.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.fetchUserProfileFailed(
            error: e.toString(),
          ),
          type: MDToastType.error,
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(slang.t.personalProfile.editPersonalProfile),
        centerTitle: false,
      ),
      body: _isLoading
          ? const _PersonalProfileSkeleton()
          : Obx(() {
              final user = _userService.currentUser.value;
              if (user == null) {
                return Center(child: Text(slang.t.auth.notLoggedIn));
              }

              return ListView(
                children: [
                  const SizedBox(height: 24),
                  // 头像区域
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AvatarWidget(user: user, size: 100),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: _isUploadingAvatar
                                    ? const SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: Padding(
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
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          size: 20,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        onPressed: _pickAndUploadAvatar,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
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
                  _buildSectionHeader(
                    context,
                    slang.t.personalProfile.homepageBackground,
                  ),
                  _buildHeaderImageSection(context, user),
                  const Divider(),

                  // 基本信息分组
                  _buildSectionHeader(
                    context,
                    slang.t.personalProfile.basicInfo,
                  ),
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
                      showToastWidget(
                        MDToastWidget(
                          message: slang.t.personalProfile.usernameCopied,
                          type: MDToastType.success,
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // 个人简介分组
                  _buildSectionHeader(
                    context,
                    slang.t.personalProfile.personalIntroduction,
                  ),
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

                  const Divider(),

                  // 隐私设置分组
                  _buildSectionHeader(
                    context,
                    slang.t.personalProfile.privacySettings,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.visibility_off_outlined),
                    title: Text(slang.t.personalProfile.hideSensitiveContent),
                    subtitle: Text(
                      slang.t.personalProfile.hideSensitiveContentDesc,
                    ),
                    value: user.hideSensitive,
                    onChanged: (bool value) =>
                        _handleToggleHideSensitive(value),
                  ),

                  const Divider(),

                  const Divider(),

                  // 通知设置分组
                  _buildSectionHeader(
                    context,
                    slang.t.personalProfile.notificationSettings,
                  ),
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
                    title: Text(
                      slang.t.personalProfile.commentReplyNotification,
                    ),
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

                  const Divider(),

                  // 账号信息分组
                  ...[
                    _buildSectionHeader(
                      context,
                      slang.t.personalProfile.accountInfo,
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(slang.t.personalProfile.registrationTime),
                      subtitle: Text(
                        // 简单格式化
                        "${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              );
            }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleToggleHideSensitive(bool value) async {
    final user = _userService.currentUser.value;
    if (user == null) return;

    final bool originalValue = user.hideSensitive;

    // 1. 乐观更新：立即反映在 UI 上
    _userService.currentUser.value = user.copyWith(hideSensitive: value);

    // 2. 发送请求
    final result = await _userService.updateUserProfile(hideSensitive: value);

    if (!result.isSuccess) {
      // 3. 如果失败，回滚状态
      _userService.currentUser.value = user.copyWith(
        hideSensitive: originalValue,
      );
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.updateSettingsFailed(
            error: result.message,
          ),
          type: MDToastType.error,
        ),
      );
    }
    // 成功则不需要操作，因为 updateUserProfile 内部已经处理了最终数据的同步
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
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.updateNotificationSettingsFailed(
            error: result.message,
          ),
          type: MDToastType.error,
        ),
      );
    }
  }

  void _showEditNicknameDialog(BuildContext context, String currentName) {
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );
    final RxBool isSaving = false.obs;

    Get.dialog(
      AlertDialog(
        title: Text(slang.t.personalProfile.editNickname),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: slang.t.personalProfile.nickname,
                hintText: slang.t.personalProfile.nicknameCannotBeEmpty,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                AppService.tryPop();
              }
            },
            child: Text(slang.t.common.cancel),
          ),
          Obx(
            () => TextButton(
              onPressed: isSaving.value
                  ? null
                  : () async {
                      final newName = controller.text.trim();
                      if (newName.isEmpty) {
                        showToastWidget(
                          MDToastWidget(
                            message:
                                slang.t.personalProfile.nicknameCannotBeEmpty,
                            type: MDToastType.warning,
                          ),
                        );
                        return;
                      }
                      if (newName == currentName) {
                        if (Get.isDialogOpen == true) {
                          AppService.tryPop();
                        }
                        return;
                      }

                      isSaving.value = true;
                      final result = await _userService.updateUserProfile(
                        name: newName,
                      );
                      isSaving.value = false;

                      if (result.isSuccess) {
                        showToastWidget(
                          MDToastWidget(
                            message: slang.t.personalProfile.changeSuccess,
                            type: MDToastType.success,
                          ),
                        );
                        if (Get.isDialogOpen == true) {
                          AppService.tryPop();
                        }
                      } else {
                        showToastWidget(
                          MDToastWidget(
                            message: result.message,
                            type: MDToastType.error,
                          ),
                        );
                      }
                    },
              child: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(slang.t.common.save),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDescriptionDialog(
    BuildContext context,
    String? currentDescription,
  ) {
    // 使用 BaseDialogInput 来提供富文本编辑体验（Markdown、预览、翻译等）
    Get.dialog(
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
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.unsupportedFileFormat,
          type: MDToastType.error,
        ),
      );
      return;
    }

    final fileSize = await file.length();
    if (fileSize > 0.6 * 1024 * 1024) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.fileTooLarge(size: '0.6MB'),
          type: MDToastType.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      final uploadedImage = await uploadService.uploadImageFile(file);
      if (uploadedImage == null) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.personalProfile.uploadFailed,
            type: MDToastType.error,
          ),
        );
        return;
      }

      final result = await _userService.updateUserProfile(
        avatar: uploadedImage,
      );
      if (result.isSuccess) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.personalProfile.avatarUpdatedSuccessfully,
            type: MDToastType.success,
          ),
        );
      } else {
        showToastWidget(
          MDToastWidget(
            message: slang.t.personalProfile.updateAvatarFailed(
              error: result.message,
            ),
            type: MDToastType.error,
          ),
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(message: '操作失败: $e', type: MDToastType.error),
      );
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          color: Theme.of(context).colorScheme.onPrimary,
                          onPressed: _pickAndUploadHeader,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
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
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.unsupportedFileFormat,
          type: MDToastType.error,
        ),
      );
      return;
    }

    final fileSize = await file.length();
    if (fileSize > 1.5 * 1024 * 1024) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.fileTooLarge(size: '1.5MB'),
          type: MDToastType.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploadingHeader = true;
    });

    try {
      final uploadedImage = await uploadService.uploadImageFile(file);
      if (uploadedImage == null) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.personalProfile.uploadFailed,
            type: MDToastType.error,
          ),
        );
        return;
      }

      final result = await _userService.updateUserProfile(
        header: uploadedImage,
      );
      if (result.isSuccess) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.personalProfile.backgroundUpdatedSuccessfully,
            type: MDToastType.success,
          ),
        );
      } else {
        showToastWidget(
          MDToastWidget(
            message: slang.t.personalProfile.updateBackgroundFailed(
              error: result.message,
            ),
            type: MDToastType.error,
          ),
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '${slang.t.common.error}: $e',
          type: MDToastType.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingHeader = false;
        });
      }
    }
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
      showToastWidget(
        MDToastWidget(
          message: slang.t.personalProfile.changeSuccess,
          type: MDToastType.success,
        ),
      );
      if (mounted) {
        AppService.tryPop();
      }
    } else {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
      );
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
  const _PersonalProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
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
