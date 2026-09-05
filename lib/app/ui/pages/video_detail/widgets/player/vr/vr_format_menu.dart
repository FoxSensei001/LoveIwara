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
///
/// 机器认为这条视频是 VR 时（[MyVideoStateController.vrSuggestion]），建议的
/// 那一档会**预先高亮**并在行尾打上「建议」：画面从来不会自动换几何（见
/// `_applyInferredVerdict`），所以这张菜单是用户唯一看得到「机器猜的是哪一档」
/// 的地方；不标出来，他就得自己在七个选项里挑，两下点完的流程也就不成立了。
Future<void> showVrFormatMenu({
  required BuildContext anchorContext,
  required MyVideoStateController controller,
}) async {
  final t = slang.t.vrFormat;
  final current = controller.vrFormat;
  final suggested = controller.vrSuggestion.value?.format;
  final bool isManual =
      controller.vrFormatVerdict.value.source == VrVerdictSource.userSpecified;
  // 建议档与当前档撞在一起时不再标「建议」：那一行已经打了勾，再挂一枚标只会
  // 让人以为这是两件事。
  final Color accent = Theme.of(anchorContext).colorScheme.primary;

  GlassMenuEntry option(VrSourceFormat format) {
    final bool isSuggested = suggested == format && format != current;
    return GlassMenuOption<String>(
      value: format.toConfigString(),
      label: vrFormatLabel(format),
      description: vrFormatDescription(format),
      selected: format == current,
      trailing: isSuggested ? t.suggestedBadge : null,
      accentColor: isSuggested ? accent : null,
    );
  }

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

/// 顶栏「换个方式放」聚合钮：一枚钮，两条出路。
///
/// # 为什么这两件事收进同一枚钮
///
/// 它们回答的是同一个问题——「这段视频不该就这么放，怎么办」：要么**换个程序
/// 放**（交给本机的 Skybox / MX Player / 系统播放器），要么**换个几何放**（VR
/// 180/360、左右 3D）。用户在遇到一段拆成两半的画面时，脑子里想的就是这一件事，
/// 分成两枚图标只会让他在两个都不认识的图标之间猜。
///
/// 更硬的理由是宽度：顶栏右侧那排图标是定宽的，左边那排（返回 + 主页）也是，
/// 360dp 竖屏内嵌播放器上已经贴着边（本项目在这条工具栏上出过 OVERFLOWED 条）。
/// 「播放模式」原先因此**只在 ≥600dp 露出**，手机上根本够不着——而手机恰恰是
/// 最需要它的地方（头显上还能甩给外部播放器，手机上没有别的出路）。合成一枚之
/// 后不占新宽度，两条路在所有尺寸上都在。
///
/// 钮和它吐出来的菜单**必须待在同一个文件里**：`opensOverlay: true` 是调用点对
/// 组件的声明（「我这一按会开浮层，所以长按也该开，而且要能按住不抬手划进面板
/// 选中」），组件自己猜不出来。两者分家就会出现「点得开、长按打不开」的半残
/// 手势，全站的玻璃闸门盯的正是这条。
class PlaybackHandoffButton extends StatelessWidget {
  const PlaybackHandoffButton({
    super.key,
    required this.controller,
    required this.iconSize,
  });

  final MyVideoStateController controller;
  final double iconSize;

  /// 外部播放器这条路走不走得通。Web 上没有「本机的别的应用」这回事。
  static bool get _canHandOff => !GetPlatform.isWeb;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 当前不是普通平面视频时换成 360 图标并转主色：用户得看得出这个视频正被
      // 按特殊几何渲染，否则画面不对劲的时候他不知道该往哪儿找开关。
      final bool active = controller.needsVrPresentation;
      // 有建议没被采纳时也点一下：那条画面提示是有时限的，过期之后这枚钮就是
      // 用户唯一的线索。
      final bool hinted = controller.vrSuggestion.value != null;
      return Tooltip(
        message: slang.t.vrFormat.handoffTooltip,
        child: Builder(
          builder: (anchorContext) => GlassPressable(
            opensOverlay: true,
            onTap: () => _open(anchorContext),
            builder: (context, pressed) => SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                active || hinted ? Icons.threesixty : Icons.open_in_new,
                color: active || hinted
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

  Future<void> _open(BuildContext anchorContext) async {
    // 只剩一条路时不摆二级菜单：一张只有一个选项的菜单是纯粹的多余一步。
    if (!_canHandOff) {
      return showVrFormatMenu(
        anchorContext: anchorContext,
        controller: controller,
      );
    }

    final t = slang.t;
    final suggested = controller.vrSuggestion.value?.format;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<String>(
          value: _kHandoffExternal,
          label: t.externalPlayer.title,
          description: t.externalPlayer.description,
          icon: Icons.open_in_new,
        ),
        GlassMenuOption<String>(
          value: _kHandoffVrFormat,
          label: t.vrFormat.title,
          // 有建议时把「机器猜的是哪一档」直接写在入口上——用户不必先点进去才
          // 知道里面有没有东西等着他。
          description: suggested == null
              ? t.vrFormat.desc
              : t.vrFormat.suggestedEntryDesc(format: vrFormatLabel(suggested)),
          icon: Icons.threesixty,
          // 行尾那枚 `›`：这一条点下去还有一层，不是选中即生效。
          trailing: '›',
          accentColor: suggested == null
              ? null
              : Theme.of(anchorContext).colorScheme.primary,
        ),
      ],
    );
    if (picked == null) return;
    if (picked == _kHandoffExternal) {
      await controller.showExternalPlayerDialog();
      return;
    }
    if (!anchorContext.mounted) return;
    await showVrFormatMenu(
      anchorContext: anchorContext,
      controller: controller,
    );
  }
}

const String _kHandoffExternal = 'external-player';
const String _kHandoffVrFormat = 'vr-format';
