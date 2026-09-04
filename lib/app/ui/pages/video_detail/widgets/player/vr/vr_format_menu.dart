import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/vr/vr_panorama_shader.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 播放模式的选项表与文案，播放器顶栏菜单和设置面板共用一份。
///
/// 顺序即 UI 顺序：平面 → 平面立体 → VR 全景，从最常见排到最少见。
/// **不含鱼眼**——`VrProjection.fisheye` 在模型里保留是为了以后迁数据方便，但目前
/// 没有任何后端画得出它（Spatial SDK 没有鱼眼形状，Flutter 侧的着色器也只做等距），
/// 摆进选单等于给一个选了没用的档。
const List<VrSourceFormat> kVrFormatOptions = <VrSourceFormat>[
  VrSourceFormat.flatMono,
  VrSourceFormat(
    projection: VrProjection.flat,
    stereoLayout: VrStereoLayout.sideBySide,
  ),
  VrSourceFormat(
    projection: VrProjection.flat,
    stereoLayout: VrStereoLayout.topBottom,
  ),
  VrSourceFormat(
    projection: VrProjection.equirect180,
    stereoLayout: VrStereoLayout.sideBySide,
  ),
  VrSourceFormat(
    projection: VrProjection.equirect180,
    stereoLayout: VrStereoLayout.mono,
  ),
  VrSourceFormat(
    projection: VrProjection.equirect360,
    stereoLayout: VrStereoLayout.mono,
  ),
  VrSourceFormat(
    projection: VrProjection.equirect360,
    stereoLayout: VrStereoLayout.topBottom,
  ),
];

/// 菜单里两个「动作」项的哨兵值。选项本身用 [VrSourceFormat.toConfigString]，
/// 与这两个字符串天然不会撞（配置串一定含冒号）。
const String kVrMenuResetView = 'reset-view';
const String kVrMenuResetAuto = 'reset-auto';

String vrFormatLabel(VrSourceFormat format) {
  final t = slang.t.vrFormat;
  return switch ((format.projection, format.stereoLayout)) {
    (VrProjection.flat, VrStereoLayout.sideBySide) => t.flatSideBySide,
    (VrProjection.flat, VrStereoLayout.topBottom) => t.flatTopBottom,
    (VrProjection.equirect180, VrStereoLayout.sideBySide) =>
      t.vr180SideBySide,
    (VrProjection.equirect180, _) => t.vr180Mono,
    (VrProjection.equirect360, VrStereoLayout.topBottom) => t.vr360TopBottom,
    (VrProjection.equirect360, _) => t.vr360Mono,
    _ => t.flat,
  };
}

String vrFormatDescription(VrSourceFormat format) {
  final t = slang.t.vrFormat;
  return switch ((format.projection, format.stereoLayout)) {
    (VrProjection.flat, VrStereoLayout.sideBySide) => t.flatSideBySideDesc,
    (VrProjection.flat, VrStereoLayout.topBottom) => t.flatTopBottomDesc,
    (VrProjection.equirect180, VrStereoLayout.sideBySide) =>
      t.vr180SideBySideDesc,
    (VrProjection.equirect180, _) => t.vr180MonoDesc,
    (VrProjection.equirect360, VrStereoLayout.topBottom) =>
      t.vr360TopBottomDesc,
    (VrProjection.equirect360, _) => t.vr360MonoDesc,
    _ => t.flatDesc,
  };
}

/// 打开播放模式菜单，并把选择结果直接应用到 [controller]。
///
/// 选中即生效、不需要确认，也不弹二次提示——用户改这个就是因为当前这档不对，
/// 让他再确认一次只是在他已经知道答案的问题上拦一道。
Future<void> showVrFormatMenu({
  required BuildContext anchorContext,
  required MyVideoStateController controller,
}) async {
  final t = slang.t.vrFormat;
  final current = controller.vrFormat;
  final bool isManual =
      controller.vrFormatVerdict.value.source == VrVerdictSource.userSpecified;

  GlassMenuEntry option(VrSourceFormat format) => GlassMenuOption<String>(
    value: format.toConfigString(),
    label: vrFormatLabel(format),
    description: vrFormatDescription(format),
    selected: format == current,
  );

  final entries = <GlassMenuEntry>[
    GlassMenuSectionHeader(t.title),
    option(kVrFormatOptions[0]),
    const GlassMenuSeparator(),
    GlassMenuSectionHeader(t.sectionStereo),
    option(kVrFormatOptions[1]),
    option(kVrFormatOptions[2]),
    const GlassMenuSeparator(),
    GlassMenuSectionHeader(t.sectionPanorama),
    // 环视靠片元着色器，只在 Impeller 上可用。跑不了的机器上这几档仍然能选
    // （单眼裁切照样有价值），但必须先把话说清楚，不能让人选完发现没有环视。
    if (!VrPanoramaShader.isSupported)
      GlassMenuSectionHeader(t.shaderUnsupported),
    option(kVrFormatOptions[3]),
    option(kVrFormatOptions[4]),
    option(kVrFormatOptions[5]),
    option(kVrFormatOptions[6]),
    if (controller.isVrPanorama) ...[
      const GlassMenuSeparator(),
      GlassMenuOption<String>(
        value: kVrMenuResetView,
        label: t.resetView,
        description: t.resetViewDesc,
      ),
    ],
    if (isManual) ...[
      const GlassMenuSeparator(),
      GlassMenuOption<String>(
        value: kVrMenuResetAuto,
        label: t.resetToAuto,
        description: t.resetToAutoDesc,
      ),
    ],
  ];

  final picked = await showGlassMenu<String>(
    anchorContext: anchorContext,
    entries: entries,
  );
  if (picked == null) return;
  applyVrMenuSelection(controller, picked);
}

/// 把菜单/设置面板选出来的值应用到控制器。抽出来是因为两个入口都要用同一套语义。
void applyVrMenuSelection(MyVideoStateController controller, String picked) {
  switch (picked) {
    case kVrMenuResetView:
      controller.resetVrView();
    case kVrMenuResetAuto:
      controller.resetVrFormatToInferred();
    default:
      controller.setVrFormat(VrSourceFormat.fromConfigString(picked));
  }
}

/// 播放模式（VR / 立体）触发钮。
///
/// 钮和它吐出来的菜单**必须待在同一个文件里**：`opensOverlay: true` 是调用点对
/// 组件的声明（「我这一按会开浮层，所以长按也该开，而且要能按住不抬手划进面板
/// 选中」），组件自己猜不出来。两者分家就会出现「点得开、长按打不开」的半残
/// 手势，全站的玻璃闸门盯的正是这条。
class VrFormatButton extends StatelessWidget {
  const VrFormatButton({
    super.key,
    required this.controller,
    required this.iconSize,
  });

  final MyVideoStateController controller;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 当前不是普通平面视频时图标转主色：用户得看得出这个视频正被按特殊几何
      // 渲染，否则画面不对劲的时候他不知道该往哪儿找开关。
      final bool active = controller.needsVrPresentation;
      return Tooltip(
        message: slang.t.vrFormat.entryTooltip,
        child: Builder(
          builder: (anchorContext) => GlassPressable(
            opensOverlay: true,
            onTap: () => showVrFormatMenu(
              anchorContext: anchorContext,
              controller: controller,
            ),
            builder: (context, pressed) => SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.threesixty,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
      );
    });
  }
}
