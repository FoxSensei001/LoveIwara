import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_powered_by_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/app/models/api_result.model.dart';

import '../../../widgets/custom_markdown_body_widget.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailContent extends StatelessWidget {
  final PostDetailController controller;
  final double paddingTop;
  final VoidCallback onShare;

  const PostDetailContent({
    super.key,
    required this.controller,
    required this.paddingTop,
    required this.onShare,
  });

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onShare,
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
          user: user,
          defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
          radius: 20,
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
    final configService = Get.find<ConfigService>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() => IconButton(
          onPressed: controller.isTranslating.value ? null : () => _handleTranslation(),
          icon: controller.isTranslating.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.translate,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
        )),
        TranslationLanguageSelector(
          compact: true,
          selectedLanguage: configService.currentTranslationSort,
          onLanguageSelected: (sort) {
            configService.updateTranslationLanguage(sort);
            if (controller.translatedText.value != null) {
              _handleTranslation();
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleTranslation() async {
    final translationService = Get.find<TranslationService>();
    final post = controller.postInfo.value;
    if (post?.body.isNotEmpty == true) {
      controller.isTranslating.value = true;
      try {
        ApiResult<String> result = await translationService.translate(post?.body ?? '');
        
        if (result.isSuccess) {
          controller.translatedText.value = result.data;
        } else {
          controller.translatedText.value = slang.t.errors.translationFailedPleaseTryAgainLater;
        }
      } finally {
        controller.isTranslating.value = false;
      }
    }
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
              translationPoweredByWidget(context, fontSize: 10)
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.translatedText.value == t.errors.translationFailedPleaseTryAgainLater) {
              return Text(
                controller.translatedText.value!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              );
            }
            return CustomMarkdownBody(data: controller.translatedText.value!);
          }),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slang.t.mediaList.personalIntroduction,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTranslationButton(context),
            ],
          ),
          const SizedBox(height: 8),
          CustomMarkdownBody(data: controller.postInfo.value?.body ?? ''),
          Obx(() {
            if (controller.translatedText.value == null) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const SizedBox(height: 12),
                _buildTranslatedContent(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
