import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 首启引导里顶替「播放器设置」的那一步（仅头显）。
///
/// # ⛔ 这一步**不设任何开关**，是说明页
///
/// 它原本带过两枚开关，两枚都被拿掉了：
/// - 「点开图库图片自动进入空间画廊」——用户 2026-09-15 不要它出现在首启里
///   （开关本身仍在设置 →「图库」的空间画廊卡片上）；
/// - 「记录并恢复播放进度」——与下一步「基础设置」里的「自动记录历史」是**同一个**
///   配置项（`RECORD_AND_RESTORE_VIDEO_PROGRESS`），连着两步问同一件事。
///
/// 留下它是因为头显用户需要知道一件事：视频不画在这块悬浮面板里，而幕布的远近、
/// 大小、曲率、背景都在**空间控制面板**里调 —— 那个面板不在 Flutter 里，第一次
/// 进来没人说就找不着。
class SpatialPlaybackStepWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const SpatialPlaybackStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return StepPageLayout(
      subtitle: subtitle,
      description: description,
      content: GlassSettingSection(
        children: [
          // 只读条目：不给 onTap。空间控制面板得在沉浸场景里唤，首启这会儿把用户
          // 支到另一块面板上去只会让他丢掉引导的线头。
          GlassSettingTile(
            icon: Icons.view_in_ar,
            title: Text(t.vrFormat.spatialSectionTitle),
            subtitle: Text(t.vrFormat.spatialSectionDesc),
          ),
          GlassSettingTile(
            icon: Icons.open_with,
            title: Text(t.vrFormat.spatialPanelEntry),
            subtitle: Text(t.vrFormat.spatialPanelEntryDesc),
          ),
        ],
      ),
      tip: StepTipBanner.info(t.firstTimeSetup.common.settingsChangeableTip),
    );
  }
}
