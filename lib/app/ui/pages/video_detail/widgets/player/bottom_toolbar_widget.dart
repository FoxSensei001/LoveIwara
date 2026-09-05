import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/volume_control_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:logger/logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:i_iwara/app/ui/widgets/like_button_widget.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/user_service.dart';

import '../../../../../../utils/common_utils.dart';
import '../../../../../services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import '../../controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';

import 'custom_slider_bar_shape_widget.dart';
import 'toolbar_fade_visibility.dart';
import 'vr/vr_format_menu.dart';
import 'vr/vr_suggestion_tip.dart';
import 'widgets/player_tip_metrics.dart';
import '../../../../../../i18n/strings.g.dart' as slang;

// 提示胶囊那一槽的几何与密度规则住在 player_tip_metrics.dart（续播提示与 VR 建议
// 提示共用）。这里转出去，是因为 bottomToolbarEstimatedHeight 与它们本来就是一本
// 账，调用方（含测试）从工具栏这个入口拿到全套才不会有人各拿一半。
export 'widgets/player_tip_metrics.dart';

/// 底部工具栏的预估高度。放在这里而不是调用方，是为了让它跟着本文件的布局一起改，
/// 两边不会各自漂移 —— 之前 64/108 两个魔数就是这么和真实高度对不上的。
///
/// 只给「需要给播放条让位」的图层用（例如错误浮层的底部预留）。预估值宁可略大，
/// 但调用方必须再按可用高度夹一次：Flex 的 clipBehavior 是 Clip.none，
/// 预留过头会让子组件溢出画到播放条上，按钮反而把点击吃掉（issue #110 的同类问题）。
double bottomToolbarEstimatedHeight({
  required bool isFullScreen,
  required bool isSmallScreen, // MediaQuery.size.width < 600，看的是窗口不是播放器
  required bool showResumeTip, // controller.showResumePositionTip.value
  required bool showVrTip, // controller.showVrSuggestionTip.value
  required bool
  showQuickActions, // isFullScreen && userService.hasLoadedProfile
  required double
  bottomInset, // applyBottomSafeAreaPadding 时的 computeBottomSafeInset
  required TextScaler textScaler,
}) {
  const double vPad = 8.0; // Container 上下各 4
  const double progressBar = 20.0; // _thumbOverlayRadius(10) * 2
  final double controlRow = isFullScreen
      ? (isSmallScreen ? 36.0 : 40.0)
      : (isSmallScreen ? 32.0 : 36.0);

  // 提示胶囊那一槽：续播提示与 VR 建议提示各占一条，**可以同时在**（刚打开一条
  // 看过一半的 VR 视频就是两条一起）。两条都强制单行、共用同一份几何，所以这里
  // 就是「有几条 × 一条多高」。
  //
  // 允许换行的话这本账就要分两套，而它同时被源错误浮层与全屏播放列表抽屉依赖
  // —— 算错的代价是子组件溢出到播放条上、按钮把点击吃掉。
  final double capsule = playerTipCapsuleHeight(
    isFullScreen: isFullScreen,
    textScaler: textScaler,
  );
  final double tipCapsules =
      (showResumeTip ? capsule : 0.0) + (showVrTip ? capsule : 0.0);

  // 全屏顶部互动层：Container(vertical 4 x2) + Row(TextButton.icon / 头像 30 / 28)。
  // TextButton 的 M3 最小高度是 40，但移动端 materialTapTargetSize 仍是 padded，
  // _InputPadding 会把它抬到 kMinInteractiveDimension = 48；桌面端是 compact -> 32。
  final double buttonBox = switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => kMinInteractiveDimension,
    _ => 32.0,
  };
  final double quickActions = showQuickActions
      ? 8.0 + math.max(buttonBox, 30.0)
      : 0.0;

  return quickActions +
      vPad +
      progressBar +
      controlRow +
      tipCapsules +
      bottomInset;
}

class BottomToolbar extends StatelessWidget {
  final MyVideoStateController myVideoStateController;
  final Logger logger = Logger();
  final bool currentScreenIsFullScreen;
  final bool applyBottomSafeAreaPadding;

  /// 池里还有下一条。由详情页算好下发——底栏不认识池，只负责画那枚钮。
  final bool canPlayNextInQueue;

  /// 点「下一个」。
  final Future<void> Function()? onPlayNextInQueue;

  /// 长按「下一个」打开的「接着看」抽屉。为 null 时只有点按那件事。
  final VoidCallback? onOpenQueueDrawer;
  final ConfigService _configService = Get.find();
  final AppService appService = Get.find();
  final UserService _userService = Get.find<UserService>();

  // 缓存一些常用的组件
  final Widget _spacer8 = const SizedBox(width: 8.0);

  BottomToolbar({
    super.key,
    required this.myVideoStateController,
    required this.currentScreenIsFullScreen,
    this.applyBottomSafeAreaPadding = false,
    this.canPlayNextInQueue = false,
    this.onPlayNextInQueue,
    this.onOpenQueueDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final double bottomInset = applyBottomSafeAreaPadding
        ? computeBottomSafeInset(MediaQuery.of(context))
        : 0;
    // 如果是非全屏，图标更小一些
    final double iconSize = currentScreenIsFullScreen
        ? (isSmallScreen ? 18 : 20)
        : (isSmallScreen ? 16 : 18);

    // 用 RepaintBoundary 包裹整个工具条
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentScreenIsFullScreen)
            _buildTopInteractionLayer(context, isSmallScreen),
          // VR 建议在续播之上：前者说的是「你可能正用错的几何在看」——画面本身
          // 就不对，比「从哪儿接着看」更急。
          _buildVrSuggestionTip(),
          _buildResumeTip(),
          _buildBottomToolbar(context, isSmallScreen, iconSize, t, bottomInset),
        ],
      ),
    );
  }

  /// 续播提示。**刻意不套 [ToolbarFadeVisibility]。**
  ///
  /// 它有自己的 8 秒停留，与工具栏的显隐无关：用户点一下画面把工具栏收起来，
  /// 提示不该跟着一起消失——那条「从头播放」还没点呢。放在这里而不是自己起一层
  /// 浮层，是为了让它与工具栏共处同一个 Column：位置由布局算出来，不需要拿
  /// [bottomToolbarEstimatedHeight] 的**估算值**去猜偏移量（估算是给别的图层
  /// 预留空间用的，拿它定位迟早会和真实高度对不上而叠到播放条上）。
  ///
  /// 工具栏隐藏时它下面那层黑色渐变也没了，所以提示自带 72% 不透明的深色胶囊，
  /// 直接压在画面上也读得清。
  Widget _buildResumeTip() {
    return Padding(
      // 与下方工具栏内容左右对齐（那个 Container 的水平内边距也是 12）。
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Obx(
        () => ResumeTipReveal(
          visible: myVideoStateController.showResumePositionTip.value,
          child: ResumePositionTip(
            position: myVideoStateController.resumePosition.value,
            isFullScreen: currentScreenIsFullScreen,
            onRestart: () =>
                unawaited(myVideoStateController.restartFromBeginning()),
            onDismiss: myVideoStateController.hideResumePositionTip,
          ),
        ),
      ),
    );
  }

  /// VR 建议提示。与续播提示同一槽、同一套几何，理由见 [ResumePositionTip] 的
  /// 类文档（住在工具栏的 Column 里而不是自己起一层浮层）。
  ///
  /// 「以 VR 播放」不直接套用建议档，而是打开播放模式菜单：机器只是**猜**这是
  /// VR，猜的是 180 还是 360、左右还是上下更是靠行业缺省填的，一步到位等于替
  /// 用户拍板。菜单里那一档已经预先高亮（见 `showVrFormatMenu`），所以用户看到
  /// 的仍然是「点提示 → 点那一档」两下。
  Widget _buildVrSuggestionTip() {
    return Padding(
      // 与下方工具栏内容左右对齐（那个 Container 的水平内边距也是 12）。
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Obx(() {
        final suggestion = myVideoStateController.vrSuggestion.value;
        return ResumeTipReveal(
          visible:
              myVideoStateController.showVrSuggestionTip.value &&
              suggestion != null,
          child: VrSuggestionTip(
            // 退场动画期间 suggestion 可能已经被清空，胶囊却还要有内容可画
            // （AnimatedSwitcher 保留旧 child，但那只 child 会被重建一次）。
            format: suggestion?.format ?? VrSourceFormat.flatMono,
            isFullScreen: currentScreenIsFullScreen,
            onOpenPicker: (anchorContext) => unawaited(
              showVrFormatMenu(
                anchorContext: anchorContext,
                controller: myVideoStateController,
              ),
            ),
            onDismiss: myVideoStateController.hideVrSuggestionTip,
          ),
        );
      }),
    );
  }

  Widget _buildTopInteractionLayer(BuildContext context, bool isSmallScreen) {
    // 淡入淡出显隐（原为位移滑入滑出 + 非响应式 IgnorePointer），
    // ToolbarFadeVisibility 内部已带随动画每帧更新的指针放行
    return ToolbarFadeVisibility(
      animation: myVideoStateController.animationController,
      child: MouseRegion(
        onEnter: (_) => myVideoStateController.setToolbarHovering(true),
        onExit: (_) => myVideoStateController.setToolbarHovering(false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 在全屏且未登录时隐藏点赞和关注按钮
              if (_userService.hasLoadedProfile) ...[
                _buildLikeButton(),
                _spacer8,
                _buildFollowButton(),
                _spacer8,
              ],
              _buildAuthorInfo(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(
    BuildContext context,
    bool isSmallScreen,
    double iconSize,
    slang.Translations t,
    double bottomInset,
  ) {
    // 淡入淡出显隐（原为位移滑入滑出），隐藏后自动放行指针事件
    return ToolbarFadeVisibility(
      animation: myVideoStateController.animationController,
      child: MouseRegion(
        onEnter: (_) => myVideoStateController.setToolbarHovering(true),
        onExit: (_) => myVideoStateController.setToolbarHovering(false),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0 + bottomInset),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 60),
                blurRadius: 60.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 0.0 : 4.0,
                ),
                child: CustomVideoProgressbar(
                  controller: myVideoStateController,
                ),
              ),
              SizedBox(
                height: currentScreenIsFullScreen
                    ? (isSmallScreen ? 36.0 : 40.0)
                    : (isSmallScreen ? 32.0 : 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLeftControls(context, isSmallScreen, iconSize, t),
                    _buildRightControls(context, isSmallScreen, iconSize, t),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示跳转进度的对话框
  void _showSeekDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    // 获取当前和总时长
    final Duration currentPosition = myVideoStateController.currentPosition;
    final Duration totalDuration = myVideoStateController.totalDuration.value;

    // 将总时长拆分为小时、分钟和秒
    final int totalHours = totalDuration.inHours;
    final int totalMinutes = totalDuration.inMinutes.remainder(60);
    final int totalSeconds = totalDuration.inSeconds.remainder(60);

    // 初始化滑块的值为当前播放位置
    int selectedHours = currentPosition.inHours;
    int selectedMinutes = currentPosition.inMinutes.remainder(60);
    int selectedSeconds = currentPosition.inSeconds.remainder(60);

    showAppDialog(
      Builder(
        builder: (BuildContext context) {
          return GlassAlertDialog(
            title: t.videoDetail.seekTo,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 小时滑块
                    if (totalHours > 0)
                      Row(
                        children: [
                          Text(t.common.hour),
                          Expanded(
                            child: Slider(
                              value: selectedHours.toDouble(),
                              min: 0,
                              max: totalHours.toDouble(),
                              divisions: totalHours > 0 ? totalHours : 1,
                              label: '$selectedHours ${t.common.hour}',
                              onChanged: (double value) {
                                setState(() {
                                  selectedHours = value.round();
                                  // 确保总时长不被超过
                                  if (selectedHours == totalHours &&
                                      (selectedMinutes > totalMinutes ||
                                          (selectedMinutes == totalMinutes &&
                                              selectedSeconds >
                                                  totalSeconds))) {
                                    selectedMinutes = totalMinutes;
                                    selectedSeconds = totalSeconds;
                                  }
                                });
                              },
                            ),
                          ),
                          Text('$selectedHours'),
                        ],
                      ),
                    // 分钟滑块
                    Row(
                      children: [
                        Text(t.common.minute),
                        Expanded(
                          child: Slider(
                            value: selectedMinutes.toDouble(),
                            min: 0,
                            max: (selectedHours < totalHours)
                                ? 59
                                : totalMinutes.toDouble(),
                            divisions: (selectedHours < totalHours)
                                ? 59
                                : (totalMinutes > 0 ? totalMinutes : 1),
                            label: '$selectedMinutes ${t.common.minute}',
                            onChanged: (double value) {
                              setState(() {
                                selectedMinutes = value.round();
                                // 确保总时长不被超过
                                if (selectedHours == totalHours &&
                                    selectedMinutes == totalMinutes &&
                                    selectedSeconds > totalSeconds) {
                                  selectedSeconds = totalSeconds;
                                }
                              });
                            },
                          ),
                        ),
                        Text('$selectedMinutes'),
                      ],
                    ),
                    // 秒钟滑块
                    Row(
                      children: [
                        Text(t.common.seconds),
                        Expanded(
                          child: Slider(
                            value: selectedSeconds.toDouble(),
                            min: 0,
                            max:
                                (selectedHours < totalHours ||
                                    selectedMinutes < totalMinutes)
                                ? 59
                                : totalSeconds.toDouble(),
                            divisions:
                                (selectedHours < totalHours ||
                                    selectedMinutes < totalMinutes)
                                ? 59
                                : (totalSeconds > 0 ? totalSeconds : 1),
                            label: '$selectedSeconds ${t.common.seconds}',
                            onChanged: (double value) {
                              setState(() {
                                selectedSeconds = value.round();
                              });
                            },
                          ),
                        ),
                        Text('$selectedSeconds'),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              GlassDialogAction(
                label: t.common.cancel,
                emphasized: false,
                onPressed: () {
                  // 关闭对话框
                  Navigator.of(context).pop();
                },
              ),
              GlassDialogAction(
                label: t.common.confirm,
                onPressed: () {
                  // 构建新的跳转时间
                  final Duration newPosition = Duration(
                    hours: selectedHours,
                    minutes: selectedMinutes,
                    seconds: selectedSeconds,
                  );

                  // 确保跳转时间不超过总时长
                  final Duration clampedPosition = newPosition > totalDuration
                      ? totalDuration
                      : newPosition;

                  // 执行跳转
                  myVideoStateController.player.seek(clampedPosition);

                  // 关闭对话框
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// 创建一个IconButton
  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
    String? tooltip, // 可选的tooltip参数
    VoidCallback? onLongPress,
  }) {
    // 调整点击区域大小，使其更紧凑
    final double touchSize = currentScreenIsFullScreen ? 36.0 : 28.0;

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          width: touchSize,
          height: touchSize,
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );

    if (tooltip != null && tooltip.isNotEmpty) {
      button = Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: true,
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// 创建一个带切换动画的IconButton
  Widget _buildSwitchIconButton({
    required Widget icon,
    required VoidCallback onPressed,
    String? tooltip, // 添加tooltip参数
  }) {
    // 调整点击区域大小，使其更紧凑
    final double touchSize = currentScreenIsFullScreen ? 36.0 : 28.0;

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            width: touchSize,
            height: touchSize,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: icon,
            ).animate().fadeIn(duration: 300.ms).scale(),
          ),
        ),
      ),
    );
  }

  /// 获取分辨率对应的 SVG 资源路径（与下载清晰度选择共用同一套映射）
  String _getResolutionIconAsset(String? label) =>
      CommonUtils.getQualityIconAsset(label);

  /// 分辨率切换器
  Widget _buildResolutionSwitcher(BuildContext context, double iconSize) {
    final t = slang.Translations.of(context);
    return Obx(() {
      String? currentResolution =
          myVideoStateController.currentResolutionTag.value;
      List<VideoResolution> resolutions =
          myVideoStateController.videoResolutions;

      // 如果没有获取到分辨率，不显示
      if (resolutions.isEmpty) {
        return const SizedBox.shrink();
      }

      // 去重：只保留每个清晰度标签的第一个分辨率
      final Map<String, VideoResolution> uniqueResolutionsMap = {};
      for (final resolution in resolutions) {
        if (!uniqueResolutionsMap.containsKey(resolution.label)) {
          uniqueResolutionsMap[resolution.label] = resolution;
        }
      }
      final uniqueResolutions = uniqueResolutionsMap.values.toList();

      final double touchSize = currentScreenIsFullScreen ? 36.0 : 28.0;

      void applyResolution(String selected) {
        if (selected != currentResolution) {
          // 保存用户手动选择的清晰度到新配置
          _configService.setSetting(ConfigKey.DEFAULT_QUALITY_KEY, selected);
          myVideoStateController.switchResolution(selected);
        }
      }

      // 清晰度面板走全站统一的玻璃菜单（原来是 Material 的 PopupMenuButton，
      // 吐出来的是块不透明卡片，跟全站已换成玻璃的下拉不是一套）。
      return Tooltip(
        message: t.videoDetail.switchResolution,
        child: Builder(
          builder: (anchorContext) => GlassPressable(
            // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到
            // 某一条上松手选中（见 GlassTapArea.opensOverlay）。
            opensOverlay: true,
            onTap: () async {
              final picked = await showGlassMenu<String>(
                anchorContext: anchorContext,
                entries: [
                  for (final resolution in uniqueResolutions)
                    GlassMenuOption<String>(
                      value: resolution.label,
                      label: CommonUtils.getQualityDisplayLabel(
                        t,
                        resolution.label,
                      ),
                      leading: SvgPicture.asset(
                        _getResolutionIconAsset(resolution.label),
                        colorFilter: ColorFilter.mode(
                          // leading 槽位外面套了一层跟着行语义色走的 IconTheme，
                          // SVG 不吃 IconTheme，得自己取一次当前色。
                          IconTheme.of(anchorContext).color ?? Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                      selected: resolution.label == currentResolution,
                    ),
                ],
              );
              if (picked != null) applyResolution(picked);
            },
            builder: (context, pressed) => Container(
              width: touchSize,
              height: touchSize,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                _getResolutionIconAsset(currentResolution),
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        ),
      );
    });
  }

  // 倍速展示格式化：去掉多余的小数 0（1.0 -> 1，1.5 -> 1.5）。
  static String _formatPlaybackSpeed(double speed) {
    final String s = speed.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// 播放速度切换器
  Widget _buildPlaybackSpeedSwitcher(BuildContext context, double iconSize) {
    final t = slang.Translations.of(context);
    return Obx(() {
      double currentSpeed = myVideoStateController.playerPlaybackSpeed.value;
      List<double> speeds = [
        0.25,
        0.5,
        0.75,
        1.0,
        1.25,
        1.5,
        1.75,
        2.0,
        2.5,
        3.0,
      ];

      // 只在全屏下显示
      if (!currentScreenIsFullScreen) {
        return const SizedBox.shrink();
      }

      final double touchSize = currentScreenIsFullScreen ? 36.0 : 28.0;

      void applySpeed(double selected) {
        if (selected != currentSpeed) {
          myVideoStateController.setPlaybackSpeed(
            selected,
            persistAsDefault: true,
          );
        }
      }

      final Widget speedButtonChild = Container(
        height: touchSize,
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg/playback_speed.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            const SizedBox(width: 4),
            // 显示当前视频的实时倍速，便于通过快捷键调整后一眼确认。
            Text(
              '${_formatPlaybackSpeed(currentSpeed)}x',
              style: TextStyle(
                color: Colors.white,
                fontSize: currentScreenIsFullScreen ? 13 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

      return Tooltip(
        message: t.videoDetail.switchPlaybackSpeed,
        child: Builder(
          builder: (anchorContext) => GlassPressable(
            // 同上：长按开菜单 + 手指接力（见 GlassTapArea.opensOverlay）。
            opensOverlay: true,
            onTap: () async {
              final picked = await showGlassMenu<double>(
                anchorContext: anchorContext,
                entries: [
                  for (final speed in speeds)
                    GlassMenuOption<double>(
                      value: speed,
                      label: '${_formatPlaybackSpeed(speed)}x',
                      selected: speed == currentSpeed,
                    ),
                ],
              );
              if (picked != null) applySpeed(picked);
            },
            builder: (context, pressed) => speedButtonChild,
          ),
        ),
      );
    });
  }

  Widget _buildLikeButton() {
    return Obx(() {
      final videoInfo = myVideoStateController.videoInfo.value;
      if (videoInfo == null) return const SizedBox.shrink();

      return LikeButtonWidget(
        mediaId: videoInfo.id,
        liked: videoInfo.liked ?? false,
        likeCount: videoInfo.numLikes ?? 0,
        onLike: (id) async {
          final result = await Get.find<VideoService>().likeVideo(id);
          return result.isSuccess;
        },
        onUnlike: (id) async {
          final result = await Get.find<VideoService>().unlikeVideo(id);
          return result.isSuccess;
        },
        onLikeChanged: (liked) {
          myVideoStateController.applyVideoLikeState(
            videoId: videoInfo.id,
            liked: liked,
          );
        },
      );
    });
  }

  Widget _buildFollowButton() {
    return Obx(() {
      final videoInfo = myVideoStateController.videoInfo.value;
      if (videoInfo?.user == null) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 28,
        child: FollowButtonWidget(
          user: videoInfo!.user!,
          onUserUpdated: myVideoStateController.handleAuthorUpdated,
        ),
      );
    });
  }

  Widget _buildAuthorInfo(bool isSmallScreen) {
    return Obx(() {
      final videoInfo = myVideoStateController.videoInfo.value;
      if (videoInfo?.user == null) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          AvatarWidget(user: videoInfo?.user, size: 30),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: videoInfo?.user?.premium == true
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.purple.shade300,
                        Colors.blue.shade300,
                        Colors.pink.shade300,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      videoInfo?.user?.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    videoInfo?.user?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      );
    });
  }

  /// 播放/暂停右边那枚「下一个」。
  ///
  /// # 交互
  ///
  /// **点按播下一条，长按打开「接着看」抽屉**。两件事是同一个心智——"接下来看
  /// 什么"——由一枚钮承担正好；这条栏已经很挤，再加一枚入口钮只会把时间码挤没。
  ///
  /// # 在场
  ///
  /// 池里没有下一条就**整只退场**，不是灰着：一个点了没反应的钮比没有更让人
  /// 困惑（与抽屉里"作者没有播放列表就不出现那枚头像"同一条规矩）。判据由详情页
  /// 下发，池翻页拿到新内容时它会自己回来——所以出入都要有过渡，不能硬切
  /// （尺寸 + 淡入两条一起走，否则时间码会瞬移一格）。
  ///
  /// # 与「池内续播」开关无关
  ///
  /// 那个开关管的是"一条播完要不要自动接上"。手动点是一次明确指令，任何时候
  /// 都作数。
  Widget _buildPlayNextButton(double iconSize, slang.Translations t) {
    final bool canPlayNext = canPlayNextInQueue && onPlayNextInQueue != null;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: canPlayNext
            ? Row(
                key: const ValueKey('queue-next'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 2.0),
                  _buildIconButton(
                    tooltip: onOpenQueueDrawer != null
                        ? t.playbackQueue.playNextHint
                        : t.playbackQueue.playNext,
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: iconSize,
                    ),
                    onPressed: () {
                      VibrateUtils.vibrate();
                      onPlayNextInQueue?.call();
                    },
                    onLongPress: onOpenQueueDrawer == null
                        ? null
                        : () {
                            VibrateUtils.vibrate();
                            onOpenQueueDrawer!();
                          },
                  ),
                ],
              )
            : const SizedBox.shrink(key: ValueKey('queue-next-absent')),
      ),
    );
  }

  Widget _buildLeftControls(
    BuildContext context,
    bool isSmallScreen,
    double iconSize,
    slang.Translations t,
  ) {
    return Row(
      children: [
        Obx(
          () => _buildSwitchIconButton(
            tooltip: myVideoStateController.videoPlaying.value
                ? t.videoDetail.pause
                : t.videoDetail.play,
            icon: Icon(
              myVideoStateController.videoPlaying.value
                  ? Icons.pause
                  : Icons.play_arrow,
              key: ValueKey(
                myVideoStateController.videoPlaying.value ? 'pause' : 'play',
              ),
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () async {
              VibrateUtils.vibrate();
              await myVideoStateController.togglePlayback();
            },
          ),
        ),
        _buildPlayNextButton(iconSize, t),
        if (GetPlatform.isDesktop) ...[
          const SizedBox(width: 2.0),
          VolumeControl(
            configService: _configService,
            myVideoStateController: myVideoStateController,
            iconSize: iconSize,
          ),
        ],
        const SizedBox(width: 8.0),
        TextButton(
          onPressed: () {
            _showSeekDialog(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 2.0 : 4.0,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Obx(
            () => Text(
              '${CommonUtils.formatDuration(myVideoStateController.toShowCurrentPosition.value)} / ${CommonUtils.formatDuration(myVideoStateController.totalDuration.value)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: currentScreenIsFullScreen
                    ? (isSmallScreen ? 11 : 12)
                    : (isSmallScreen ? 10 : 11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightControls(
    BuildContext context,
    bool isSmallScreen,
    double iconSize,
    slang.Translations t,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlaybackSpeedSwitcher(context, iconSize),
        _buildResolutionSwitcher(context, iconSize),
        if (GetPlatform.isDesktop && !currentScreenIsFullScreen)
          _buildIconButton(
            tooltip: myVideoStateController.isDesktopAppFullScreen.value
                ? t.videoDetail.exitAppFullscreen
                : t.videoDetail.enterAppFullscreen,
            icon: Obx(() {
              return SizedBox(
                width: iconSize,
                height: iconSize,
                child: (myVideoStateController.isDesktopAppFullScreen.value)
                    ? SvgPicture.asset(
                        'assets/svg/app_exit_fullscreen.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: iconSize,
                        height: iconSize,
                        semanticsLabel: t.videoDetail.exitAppFullscreen,
                      )
                    : SvgPicture.asset(
                        'assets/svg/app_enter_fullscreen.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: iconSize,
                        height: iconSize,
                        semanticsLabel: t.videoDetail.enterAppFullscreen,
                      ),
              );
            }),
            onPressed: () {
              // 进出都走控制器的收口方法：标志与 hide/showSystemUI 必须成对，
              // 手写两半迟早漏一半（历史上漏出过窗口锁死在视频分区）。
              if (myVideoStateController.isDesktopAppFullScreen.value) {
                myVideoStateController.exitDesktopAppFullscreen();
              } else {
                myVideoStateController.enterDesktopAppFullscreen();
              }
            },
          ),
        if (!myVideoStateController.isDesktopAppFullScreen.value)
          _buildIconButton(
            tooltip: currentScreenIsFullScreen
                ? t.videoDetail.exitSystemFullscreen
                : t.videoDetail.enterSystemFullscreen,
            icon: SvgPicture.asset(
              currentScreenIsFullScreen
                  ? 'assets/svg/fullscreen_exit.svg'
                  : 'assets/svg/fullscreen_enter.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            onPressed: () {
              if (currentScreenIsFullScreen) {
                myVideoStateController.exitFullscreen();
              } else {
                myVideoStateController.enterFullscreen();
                myVideoStateController.setToolbarHovering(false);
              }
            },
          ),
      ],
    );
  }
}

/// 「已从上次位置继续播放」的提示条，带一个反悔入口。
///
/// ## 为什么长这样
///
/// - **住在底部工具栏里**，而不是自己起一层浮层。这块几何有唯一真相
///   [bottomToolbarEstimatedHeight]，源错误浮层与全屏播放列表抽屉都按它预留空间；
///   另起一层等于把那本账作废。代价是工具栏隐藏时它也看不见——所以控制器在提示
///   存活期间会压住 3 秒自动隐藏（见 `_resetAutoHideTimer`）。
/// - **强制单行**。窄屏（竖屏视频、手机、分屏窗口）靠文字 [Flexible] + 省略号收缩，
///   绝不换行：一旦允许换行，高度就有两套，上面那本账立刻不准。
/// - **动作按钮不参与收缩**。文字被省略还能猜出意思，按钮被压没了这条提示就废了。
///
/// 只收纯值、不收 [MyVideoStateController]（与 `PlayerNoticeChip` 同一考虑）：
/// 这样它能在窄到 200px 的约束下被直接 widget 测，不必搭起整套 GetX 服务。
class ResumePositionTip extends StatelessWidget {
  const ResumePositionTip({
    super.key,
    required this.position,
    required this.isFullScreen,
    required this.onRestart,
    required this.onDismiss,
  });

  /// 已经跳转到的历史进度。
  final Duration position;
  final bool isFullScreen;

  /// 「从头播放」。
  final VoidCallback onRestart;

  /// 「知道了」——同时把工具栏的自动隐藏还回去。
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double fontSize = resumeTipFontSize(isFullScreen: isFullScreen);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextStyle labelStyle = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
    );
    final TextStyle actionStyle = labelStyle.copyWith(
      fontWeight: FontWeight.w600,
    );
    final String actionLabel = t.videoDetail.restartFromBeginning;
    final double iconSize = fontSize + 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: kResumeTipGap),
      // 外层 Row 负责靠左；Flexible 让胶囊最宽不超过工具栏宽度，
      // 因而内部的 Flexible 文字拿得到有界约束，可以正常省略。
      child: Row(
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double actionWidth =
                    measurePlayerTipText(actionLabel, actionStyle, scaler) +
                    kResumeTipActionHPad * 2;
                final ResumeTipDensity density = resolveResumeTipDensity(
                  maxWidth: constraints.maxWidth,
                  actionWidth: actionWidth,
                  iconWidth: iconSize,
                  closeWidth: kResumeTipActionHeight,
                );

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kResumeTipHPad,
                    vertical: kResumeTipVPad,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (density == ResumeTipDensity.full) ...[
                        Icon(
                          Icons.history_rounded,
                          size: iconSize,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: kResumeTipGapInner),
                      ],
                      Flexible(
                        child: Text(
                          t.videoDetail.resumedFromHistoryTip(
                            position: CommonUtils.formatDuration(position),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: labelStyle,
                        ),
                      ),
                      const SizedBox(width: kResumeTipGapInner),
                      _ResumeTipAction(
                        label: actionLabel,
                        style: actionStyle,
                        // 极窄档才让按钮文字也省略：宁可按钮难看，也不能溢出——
                        // 溢出的子组件会画到播放条上，把那一片点击整个吃掉。
                        allowShrink: density == ResumeTipDensity.minimal,
                        onTap: onRestart,
                      ),
                      if (density == ResumeTipDensity.full) ...[
                        const SizedBox(width: kResumeTipGapTight),
                        _ResumeTipCloseButton(
                          tooltip: t.videoDetail.dismissResumeTip,
                          size: kResumeTipActionHeight,
                          onTap: onDismiss,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 提示上的主动作（「从头播放」）。
///
/// 高度钉死为 [kResumeTipActionHeight] 而不是交给 Material 的按钮去撑：
/// [bottomToolbarEstimatedHeight] 要按这个数预留，按钮自己算高度就会两边漂移。
class _ResumeTipAction extends StatelessWidget {
  const _ResumeTipAction({
    required this.label,
    required this.style,
    required this.allowShrink,
    required this.onTap,
  });

  final String label;
  final TextStyle style;

  /// 极窄档下允许文字省略，见 [ResumeTipDensity.minimal]。
  final bool allowShrink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return SizedBox(
      height: kResumeTipActionHeight,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kResumeTipActionHPad,
            ),
            // 用 Row 而不是 Center：Flexible 只有直接放在 Flex 里才合法，
            // 放进 Center 会触发 "Incorrect use of ParentDataWidget"。
            // Row 的 crossAxisAlignment 默认就是 center，垂直居中效果一样。
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [allowShrink ? Flexible(child: text) : text],
            ),
          ),
        ),
      ),
    );
  }
}

/// 关闭按钮。提示本身 8 秒后自动消失，这里只是给一个「我看到了，现在就收起」的出口。
class _ResumeTipCloseButton extends StatelessWidget {
  const _ResumeTipCloseButton({
    required this.tooltip,
    required this.size,
    required this.onTap,
  });

  final String tooltip;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: size,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: const Icon(Icons.close, color: Colors.white70, size: 15),
          ),
        ),
      ),
    );
  }
}

/// 续播提示的出入场。
///
/// 「有出有入」是本项目的既定设计：任何元素的出现与消失都要有过渡，
/// `if (!flag) return const SizedBox.shrink()` 这种硬切不被接受。
///
/// 这里三件事一起做，缺一不可：
/// - **尺寸**跟着一起过渡。这条提示占着底部工具栏的一行，只淡入淡出的话，
///   它下面的进度条会在出现/消失的那一帧整体跳一下。
/// - **退场期间保留内容**。[AnimatedSwitcher] 的旧 child 自带最后一次的内容，
///   所以看到的是提示整条缩回去，而不是一个空壳在渐隐。
/// - **尊重系统「关闭动画」开关**。抄 `player_notice_chip.dart` 的做法：
///   开关打开时把时长归零，而不是跳过过渡逻辑。
class ResumeTipReveal extends StatelessWidget {
  const ResumeTipReveal({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  static const Duration kEnter = Duration(milliseconds: 260);
  static const Duration kExit = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : kEnter,
      reverseDuration: reduced ? Duration.zero : kExit,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // 默认的 layoutBuilder 会把新旧 child 叠在 Stack 里居中；这条提示是靠左的，
      // 居中会让它在过渡期间横向漂一下。改成左对齐叠放。
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        // 顶边对齐：从上边缘往下展开，下方的进度条被平稳推开，
        // 而不是从中间撑开。
        alignment: AlignmentDirectional.topStart,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              // 只挪 12% 行高：多了像在弹，少了看不出方向。
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
      ),
      child: visible
          ? child
          // 必须带 key：AnimatedSwitcher 靠 key 判断 child 换没换，
          // 两个都是 SizedBox 时会被当成同一个而不触发过渡。
          : const SizedBox(key: ValueKey('resume-tip-absent'), width: 0),
    );
  }
}
