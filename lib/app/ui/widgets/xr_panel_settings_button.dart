import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/xr_immersive_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 侧栏那枚「面板与背景」钮：把**空间控制面板**唤到浏览态那一页。
///
/// # 它开出来的东西不在 Flutter 里
///
/// Quest 上整个应用常驻在自建的沉浸空间里，现有的 Flutter UI **整体是悬在空间中的
/// 一块面板**。这块面板离人多远、背后透出多少真实房间，是每个人身高、坐姿、房间
/// 大小各不相同的一件事，所以要能调。
///
/// ⛔ 但调节界面不能画在这块面板自己身上：**一块面板没法把自己推远**——手指点下去
/// 的那一刻，被推走的正是承载这些按钮的那块布。所以点它唤出的是与空间视频同一块的
/// **原生空间面板**（`questui` 的 `BrowsePanelPage`：面板远近 + 背景不透明度），
/// 这里只剩「唤出」一个动作，没有任何弹层。
///
/// # ⛔ 不做「只在 Quest 上编译」这种分叉
///
/// 露不露由 [XrImmersiveService.available] 决定（沉浸场景活着才为真），调用点问的是
/// **能力**不是设备型号。普通安卓 / 桌面上那条通道根本没注册，
/// [XrImmersiveService.togglePanelControls] 会吃掉 `MissingPluginException` 回 false。
///
/// # 形状：只有图标，没有底
///
/// 它站在侧栏底部那一摞里（头像钮下面），与相邻的设置 / 退出钮同一副长相 ——
/// 用户 2026-09-09：「只显示 icon，不要显示背景」。所以是朴素的 [IconButton]，
/// 不是 `GlassIconButton(standalone: true)` 那种自带壳的玻璃圆钮。
///
/// ⛔ 与上下邻居之间那道空隙**由本组件自带**（[_gap]），不由调用点加：它在 Quest
/// 之外整只不占位，调用点各加一道的话就会在别的平台上留下一段凭空的留白。
class XrPanelSettingsButton extends StatelessWidget {
  const XrPanelSettingsButton({super.key});

  /// 与上下邻居之间的空隙。
  static const double _gap = 10;

  /// 当前进程里有没有那条沉浸通道。**`available` 要在 `Obx` 里读**，场景的生死会变。
  static XrImmersiveService? get _service =>
      Get.isRegistered<XrImmersiveService>()
      ? Get.find<XrImmersiveService>()
      : null;

  @override
  Widget build(BuildContext context) {
    final service = _service;
    // 进程里根本没有这个服务（桌面 / 测试）：连 Obx 都不建，也就没有出入场可言。
    if (service == null) return const SizedBox.shrink();
    final t = slang.Translations.of(context);
    return Obx(() {
      // 场景是异步问出来的（`refreshAvailability`），所以这一枚是**启动后才冒出来**的。
      // ⛔ 有出有入：不硬切，让侧栏那一摞把它撑开 / 收拢（本项目对硬切 `SizedBox.shrink()`
      // 的一贯要求）。这里不用 AnimatedOpacity —— 身下没有玻璃，也就不必为它建层。
      final bool visible = service.available.value;
      return AnimatedSize(
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
        child: !visible
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: _gap),
                child: IconButton(
                  icon: const Icon(Icons.open_with),
                  tooltip: t.vrFormat.panelSettings,
                  onPressed: () => service.togglePanelControls(),
                ),
              ),
      );
    });
  }
}
