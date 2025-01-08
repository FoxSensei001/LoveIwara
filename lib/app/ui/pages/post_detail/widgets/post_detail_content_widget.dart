import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

import '../../../widgets/custom_markdown_body_widget.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailContent extends StatelessWidget {
  final PostDetailController controller;
  final double paddingTop;

  const PostDetailContent({
    super.key,
    required this.controller,
    required this.paddingTop,
  });

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              controller.postInfo.value?.title ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          if (controller.postInfo.value?.title.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.translate),
              onPressed: () {
                Get.dialog(
                  TranslationDialog(
                    text: controller.postInfo.value!.title,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildAuthorAvatar(),
          const SizedBox(width: 8),
          _buildAuthorNameButton(),
          const Spacer(),
          if (controller.postInfo.value?.user != null)
            FollowButtonWidget(
              user: controller.postInfo.value!.user,
              onUserUpdated: (updatedUser) {
                controller.postInfo.value = controller.postInfo.value?.copyWith(
                  user: updatedUser,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    final user = controller.postInfo.value?.user;
    Widget avatar = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (user != null) {
            NaviService.navigateToAuthorProfilePage(user.username);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AvatarWidget(
          avatarUrl: user?.avatar?.avatarUrl,
          defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
          headers: const {'referer': CommonConstants.iwaraBaseUrl},
          radius: 20,
          isPremium: user?.premium ?? false,
          isAdmin: user?.isAdmin ?? false,
        ),
      ),
    );

    if (user?.premium == true) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade200,
                Colors.blue.shade200,
                Colors.pink.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: avatar,
          ),
        ),
      );
    }

    return avatar;
  }

  Widget _buildAuthorNameButton() {
    final user = controller.postInfo.value?.user;
    if (user?.premium == true) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            NaviService.navigateToAuthorProfilePage(user?.username ?? '');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.purple.shade300,
                    Colors.blue.shade300,
                    Colors.pink.shade300,
                  ],
                ).createShader(bounds),
                child: Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '@${user?.username ?? ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          NaviService.navigateToAuthorProfilePage(user?.username ?? '');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? '',
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '@${user?.username ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context) {
    final t = slang.Translations.of(context);
    final post = controller.postInfo.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${t.common.publishedAt}: ${CommonUtils.formatFriendlyTimestamp(post?.createdAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          if (post?.updatedAt != null && post!.updatedAt != post.createdAt)
            Row(
              children: [
                const Icon(Icons.update, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${t.common.updatedAt}: ${CommonUtils.formatFriendlyTimestamp(post.updatedAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          Row(
            children: [
              const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${t.common.numViews}: ${CommonUtils.formatFriendlyNumber(post?.numViews ?? 0)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationButton(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              onTap: controller.isTranslating.value
                  ? null
                  : () => controller.handleTranslation(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isTranslating.value)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.translate, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      t.common.translate,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(20),
            ),
            onTap: () => controller.showTranslationMenu.toggle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Obx(() => Icon(
                    controller.showTranslationMenu.value
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 26,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationMenu() {
    final ConfigService configService = Get.find();
    return Card(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: CommonConstants.translationSorts.map((sort) {
          final isSelected = sort.id == configService.currentTranslationSort.id;
          return ListTile(
            dense: true,
            selected: isSelected,
            title: Text(sort.label),
            onTap: () {
              configService.updateTranslationLanguage(sort);
              controller.showTranslationMenu.value = false;
              controller.translatedText.value = null;
              controller.handleTranslation();
            },
          );
        }).toList(),
      ),
    );
  }

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
          if (controller.translatedText.value ==
              t.errors.translationFailedPleaseTryAgainLater)
            Text(
              controller.translatedText.value!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            )
          else
            CustomMarkdownBody(data: controller.translatedText.value!),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildTranslationButton(context),
            ],
          ),
          Obx(() {
            if (controller.showTranslationMenu.value) {
              return Align(
                alignment: Alignment.centerRight,
                child: _buildTranslationMenu(),
              );
            }
            return const SizedBox.shrink();
          }),
          CustomMarkdownBody(data: controller.postInfo.value?.body ?? ''),
          Obx(() {
            if (controller.translatedText.value != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildTranslatedContent(context),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: paddingTop),
        _buildHeader(context),
        _buildAuthorInfo(),
        _buildTitle(),
        _buildContent(context),
        _buildTimeInfo(context),
      ],
    );
  }
}
