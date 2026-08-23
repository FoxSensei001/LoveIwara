import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 全站唯一的「我」身份圆钮：**圆形 = 身份入口**。
///
/// 出现在热门视频 / 热门图库 / 订阅 / 社区四个栏目的 header 左上角，以及宽屏
/// 侧栏（`NavigationRail`）的右下角。点击打开全局抽屉；已登录显示头像（带未读
/// 红点与在线绿点），登录中显示闪烁占位，未登录显示占位图标。
///
/// > 别和**订阅页右侧胶囊里那枚方形头像**混淆——那是「特别关注筛选」。
///
/// # 为什么要收成一个组件
///
/// 四处原本各写各的（三份几乎逐行相同的 `_buildAvatarButton` + 侧栏那份），
/// 结果是「社区那份有登录中闪烁、另外三份没有」这类分叉，以及下面那个角标
/// 被裁的 bug 要修四遍。
///
/// # ⛔ 角标必须按 [GlassTokens.circleBadgeInset] 内缩，不能贴着方框的角
///
/// 两个液态后端都会把 child 按玻璃自身形状裁掉（且都没有关裁切的口子）。
/// 角标习惯上挂在方框的**角**上，而那个位置在内切圆之外——一进液态档就整只
/// 被裁没。传统档不裁，所以这个 bug 只在开了液态的页面上现形：2026-08-23
/// 用户报的「视频 / 图库 / 订阅 / 侧栏的头像绿点显示不全」正是这一条，而当时
/// 社区页还是传统档，所以没被报进来。
///
/// 两枚角标的内缩都由 [GlassTokens.circleBadgeInset] 算：未读红点定位在玻璃
/// 圆自己的方框上；在线绿点是 [AvatarWidget] 内部按**头像**的方框定位的，
/// 比玻璃圆小一圈，所以要把头像尺寸一起传进去。
///
/// # ⛔ 材质要跟着所在页面走，不能自作主张开液态
///
/// 「长按跟手形变」只有液态档才有，所以一度让本组件自带
/// `LiquidGlassScope(kChromeGlassBackend)`，好让四个入口都有形变。
/// **2026-08-23 真机上被否掉**：社区页 header 其余控件还是传统档，而液态圆钮
/// 压在那一片近乎纯白的低对比背景上**几乎什么都显不出来**——传统档的
/// [GlassTokens.fill] 明显更实，两者并排读起来是「左边那枚按钮不见了，只剩
/// 一个光秃秃的人像图标」。（同一个失效模式在果冻指示器上也栽过，
/// 见 `glass_two-package-split` 那条真机记录。）
///
/// 所以默认**跟随祖先 [LiquidGlassScope]**：已经液态化的页面（热门视频 /
/// 图库、订阅）自然拿到折射与形变，传统档页面（社区）保持与邻居一致。
/// 只有宽屏侧栏那枚要显式传 [forceLiquid]——它压在 `NavigationRail` 的实心
/// 面上，本来就不在任何液态子树里，而那份「折射出 rail 的底色」是早就
/// 定下来的观感。
class IdentityAvatarButton extends StatelessWidget {
  const IdentityAvatarButton({
    super.key,
    this.size = GlassTokens.pillHeight,
    this.forceLiquid = false,
  });

  /// 圆钮直径。
  final double size;

  /// 就地供一层 [LiquidGlassScope]，让这枚钮无视所在页面的档位走液态。
  /// **只有宽屏侧栏该传 true**，理由见类注释。
  final bool forceLiquid;

  /// 头像铺满圆钮，只留 1px 玻璃描边——不要一圈内边距。
  double get _avatarSize => size - 2;

  /// 未读红点距玻璃圆外接方框的内缩。
  double get _unreadInset => math.max(
    0,
    GlassTokens.circleBadgeInset(
      diameter: size,
      badgeSize: GlassTokens.identityBadgeSize,
    ),
  );

  /// 在线绿点距**头像**外接方框的内缩（[AvatarWidget] 按头像的框定位它）。
  double get _onlineInset => math.max(
    0,
    GlassTokens.circleBadgeInset(
      diameter: size,
      badgeSize: AvatarWidget.onlineIndicatorSize,
      boxSize: _avatarSize,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final userService = Get.find<UserService>();

    final Widget button = Obx(() {
      final Widget inner;
      if (userService.isLogining.value) {
        inner = KeyedSubtree(
          key: const ValueKey('avatar-shimmer'),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surface,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      } else if (userService.hasLoadedProfile &&
          userService.currentUser.value != null) {
        inner = KeyedSubtree(
          key: ValueKey('avatar-${userService.currentUser.value?.id}'),
          child: IgnorePointer(
            child: AvatarWidget(
              user: userService.currentUser.value,
              size: _avatarSize,
              indicatorInset: _onlineInset,
            ),
          ),
        );
      } else {
        inner = KeyedSubtree(
          key: const ValueKey('avatar-placeholder'),
          child: Icon(
            Icons.account_circle,
            size: 26,
            color: colorScheme.onSurface,
          ),
        );
      }

      final count =
          userService.notificationCount.value + userService.messagesCount.value;

      return GlassSurface(
        circle: true,
        height: size,
        tooltip: t.common.me,
        onTap: AppService.switchGlobalDrawer,
        // 尺寸是钉死的正圆，满足 easy 档 touch 的约束（见 GlassSurface）。
        liquidTouch: true,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 头像 ↔ 占位图标 ↔ 登录中闪烁：形变交接，不硬切。
            GlassShapeSwitcher(child: inner),
            Positioned(
              right: _unreadInset,
              top: _unreadInset,
              child: GlassAnimatedDot(
                visible: count > 0,
                size: GlassTokens.identityBadgeSize,
              ),
            ),
          ],
        ),
      );
    });

    if (!forceLiquid) return button;
    return LiquidGlassScope(backend: kChromeGlassBackend, child: button);
  }
}
