import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_notification_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_location_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/downloads_outside_folder_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_test_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/path_template_editor_page.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_slider.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path/path.dart' as p;

/// 「保存结构与命名」的归档方式（issue #126）。
///
/// 前三个是可选的 canned 预设；[custom] 不是第四个选项，而是「现值不匹配任何
/// 预设」这一**派生状态**——选不着也写不进，由 [_DownloadSettingsPageState.
/// _currentPreset] 算出来，用来点亮自定义入口卡。
enum _StructurePreset { flat, author, date, custom }

/// 下载设置页。
///
/// ```
/// [保存位置]  当前位置卡（DownloadLocationCard） + 目录外的已下载内容
/// [下载行为]  并发数、通知
/// [保存结构与命名]  预设单选 + 实时预览 + 路径模板编辑器入口（issue #126）
/// [高级]      可折叠：写入诊断
/// ```
///
/// 保存位置整块由 [DownloadLocationCard] 负责（状态、授权、修复、更改、手输、
/// 恢复默认都在那里），本页不再有常驻的路径输入框、「启用自定义路径」开关、
/// 独立的权限卡——改位置只有「更改位置」一个入口，走同一条检查 → 确认 → 写配置
/// 流程（见 change_download_location_sheet.dart）。
class DownloadSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const DownloadSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return GlassSettingsScaffold(
      title: t.settings.downloadSettings.downloadSettings,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // [保存位置]
              const DownloadLocationCard(),
              const SizedBox(height: 16),

              // 当前目录之外的已下载内容 · 移到这里（没有时不占位，自带底部间距）
              const DownloadsOutsideFolderCard(),

              // [下载行为]
              _buildBehaviorSection(context),
              const SizedBox(height: 16),

              // [保存结构与命名]
              _buildStructureSection(context),
              const SizedBox(height: 16),

              // [高级]
              _buildAdvancedSection(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final current =
        ((configService[ConfigKey.MAX_CONCURRENT_DOWNLOADS] as int?) ?? 3)
            .clamp(1, 5);
    return GlassSettingSection(
      title: t.download.location.behaviorSection,
      children: [
        // 最大并发下载数
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.downloading_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.download.maxConcurrentDownloads,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '$current',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 2),
                child: Text(
                  t.download.maxConcurrentDownloadsDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              GlassSlider(
                value: current.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$current',
                onChanged: (value) {
                  setState(() {
                    configService[ConfigKey.MAX_CONCURRENT_DOWNLOADS] = value
                        .round();
                  });
                  // 调高并发后立即让队列补充启动更多等待中的任务
                  if (Get.isRegistered<DownloadService>()) {
                    DownloadService.to.kickQueue();
                  }
                },
              ),
            ],
          ),
        ),
        // 下载完成/失败通知
        Obx(
          () => GlassSwitchItem(
            icon: Icons.notifications_outlined,
            title: Text(
              t.settings.downloadSettings.enableDownloadNotifications,
            ),
            subtitle: Text(
              t
                  .settings
                  .downloadSettings
                  .enableDownloadNotificationsDescription,
            ),
            value:
                configService[ConfigKey.DOWNLOAD_NOTIFICATIONS_ENABLED] ?? true,
            onChanged: (value) async {
              configService[ConfigKey.DOWNLOAD_NOTIFICATIONS_ENABLED] = value;
              // 开启时请求系统通知权限；被拒绝时提示（应用内通知仍可用）。
              if (value && Get.isRegistered<DownloadNotificationService>()) {
                final granted = await DownloadNotificationService.to
                    .requestPermission();
                if (!granted) {
                  showAppToast(
                    t.settings.downloadSettings.notificationPermissionDenied,
                    type: AppToastType.warning,
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassExpansionCard(
      icon: Icons.tune,
      title: Text(t.download.location.advancedSection),
      subtitle: Text(t.download.location.advancedSubtitle),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: DownloadTestWidget(key: ValueKey('download_test')),
        ),
      ],
    );
  }

  /// [保存结构与命名]（issue #126）。
  ///
  /// 自上而下：一次性提示卡（纯告知，选中任意预设即消失）→ 三张预设单选卡
  /// （即点即生效，只影响新下载）→ 自定义入口卡（[_buildCustomEntryCard]，
  /// 不是第四个单选项）→ 实时路径预览。
  ///
  /// 预设只是 canned 模板串：运行时只读一条多段模板，预设不进第二套事实源。
  Widget _buildStructureSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    return GlassSettingSection(
      title: t.settings.downloadSettings.structureSection,
      divided: false,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            t.settings.downloadSettings.structureSectionDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (_showStructureNotice) _buildStructureNoticeCard(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _buildPresetCard(context, _StructurePreset.flat),
              _buildPresetCard(context, _StructurePreset.author),
              _buildPresetCard(context, _StructurePreset.date),
              _buildCustomEntryCard(context),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildStructurePreview(context),
      ],
    );
  }

  /// 「自定义」入口卡。
  ///
  /// ⛔ 它**不是**第四个单选项，别再放回 [_buildPresetCard] 那一列里去。
  ///
  /// 前三张卡是「选中即生效」，自定义是「去另一页把规则写出来」——两种语义
  /// 塞进同一个 radio 组，点下去就只能弹个 toast 说「请到编辑器里改」，是条
  /// 死胡同：用户已经点了，却还得自己找到下面那个 tile 再点一次。原先正是
  /// 这样，于是同一件事有两个入口，一个假一个真。
  ///
  /// 现在合成一张：形态是动作卡（chevron，不是单选圆点），点按直接开编辑器；
  /// 现值不匹配任何预设时它自己高亮并挂「当前生效」徽章——选中态是**派生**
  /// 出来的，不用用户去选。卡面直接列出三类模板的现值，「我改的是图库，
  /// 怎么整节变成自定义了」在卡上就能看明白。
  Widget _buildCustomEntryCard(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final e = t.settings.downloadSettings;
    final active = _currentPreset == _StructurePreset.custom;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active
            ? cs.primary.withValues(alpha: 0.10)
            : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await PathTemplateEditorPage.open(context);
            if (mounted) setState(() {}); // 刷新预设选中态 / 预览 / 卡面模板
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? cs.primary.withValues(alpha: 0.8)
                    : cs.outlineVariant.withValues(alpha: 0.5),
                width: active ? 1.4 : 1,
              ),
            ),
            child: Row(
              // 图标与 chevron 各自的纵向位置不同：图标要和标题齐平（它是
              // 标题的前缀），chevron 该在整卡中间（它指的是整张卡）。
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 单选圆点的位置改放图标：形状不同 = 行为不同，一眼就知道
                // 这一条不是「选我」而是「进去改」。
                SizedBox(
                  width: 18,
                  height: 22,
                  child: Icon(
                    Icons.edit_note,
                    size: 20,
                    color: active ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              e.pathTemplateEditorEntry,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                e.presetCustomActive,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        e.pathTemplateEditorEntryDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 7),
                      // 三类各自一行：这一节管的是三条模板，只亮视频那条会让
                      // 「我明明只改了图库，怎么整节变成了自定义」无从解释。
                      ..._templateSummaryRows(context, t),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 22,
                  child: Icon(
                    Icons.chevron_right,
                    color: active ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 一次性提示卡：纯告知无按钮（v3.1 裁决）——预设选项就在正下方，
  /// 「选择即开启」，选中任意预设后由 [_applyPreset] 写 dismiss flag 永久消失。
  Widget _buildStructureNoticeCard(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.16),
            cs.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: cs.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.settings.downloadSettings.structureNoticeTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.settings.downloadSettings.structureNoticeBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// canned 预设的单选卡。[_StructurePreset.custom] 不走这里——它是派生状态，
  /// 有自己的动作卡（[_buildCustomEntryCard]）。
  Widget _buildPresetCard(BuildContext context, _StructurePreset preset) {
    assert(preset != _StructurePreset.custom);
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final selected = _currentPreset == preset;
    final e = t.settings.downloadSettings;

    final (title, subtitle) = switch (preset) {
      _StructurePreset.flat => (e.presetFlat, e.presetFlatDesc),
      _StructurePreset.author => (e.presetAuthor, e.presetAuthorDesc),
      _StructurePreset.date => (e.presetDate, e.presetDateDesc),
      _StructurePreset.custom => ('', ''),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? cs.primary.withValues(alpha: 0.10)
            : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _applyPreset(preset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? cs.primary.withValues(alpha: 0.8)
                    : cs.outlineVariant.withValues(alpha: 0.5),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              // 卡片现在有三行（标题 / 说明 / 示例），圆点跟着居中会掉到
              // 说明行旁边——它是标题的前缀，得和标题齐平。
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 单选圆点
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? cs.primary : cs.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Container(
                          margin: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (preset == _StructurePreset.author) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                e.presetAuthorBadge,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // 示例路径（mono 小字，随样例数据实时渲染）。
                      //
                      // 摆在正文**下面整行**而不是挤在右侧一栏：右侧那栏
                      // 只有 118dp，窄屏上示例和副标题会各自折成两行、互相
                      // 挤成一团。整行一条、超长省略，也和自定义卡上那三行
                      // 模板是同一种读法。
                      Text(
                        _presetExample(preset),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 预览行：用样例数据渲染清洗后的真实落盘结果（预览即文档）。
  ///
  /// 画的是**视频**那条规则（标题里标明），三类各自的模板在下方入口 tile 里列全。
  /// 桌面「每次询问」模式下单个下载走系统另存为，这套层级只对批量下载与单图
  /// 生效——说明行换成 [askEveryTimeDesc] 把这件事讲清楚，而不是让用户
  /// 对着一个不会出现的目录结构做选择。
  Widget _buildStructurePreview(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final template =
        configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String? ?? '';
    final segments = FilenameTemplateService.renderSamplePathSegments(template);
    final totalLength = segments.join('/').length;
    final overBudget = totalLength > 200;
    final asksEveryTime = Get.isRegistered<DownloadPathService>()
        ? DownloadPathService.to.asksEveryTime
        : false;

    final spans = <InlineSpan>[
      TextSpan(
        text: _previewRootLabel,
        style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
    ];
    for (var i = 0; i < segments.length; i++) {
      final isFile = i == segments.length - 1;
      spans.add(
        TextSpan(
          text: ' › ',
          style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        ),
      );
      spans.add(
        TextSpan(
          text: segments[i],
          style: TextStyle(
            color: isFile ? cs.onSurface : cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t.settings.downloadSettings.structurePreviewLabel} · '
            '${t.settings.downloadSettings.pathTemplateEditor.tabVideo}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: overBudget
                    ? cs.tertiary.withValues(alpha: 0.6)
                    : GlassTokens.stroke(cs),
              ),
            ),
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                children: spans,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            overBudget
                ? '${t.settings.downloadSettings.pathTooLongWarning} ($totalLength/200)'
                : asksEveryTime
                ? t.download.location.askEveryTimeDesc(
                    location: _previewRootLabel,
                  )
                : t.settings.downloadSettings.structurePreviewNote,
            style: theme.textTheme.labelSmall?.copyWith(
              color: overBudget
                  ? cs.tertiary
                  : cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── 预设派生与切换（issue #126） ─────────────────

  /// 预设 → 三类内容各自的模板串（设计稿 PRESETS 映射）。
  /// custom 不是第三套模板：它表示「现值不匹配任何 canned 预设」，不覆写值。
  static String _presetVideo(_StructurePreset preset) => switch (preset) {
    _StructurePreset.flat => '%title_%quality',
    _StructurePreset.author => '%authorcache/%title_%quality',
    _StructurePreset.date => '%date/%title_%quality',
    _StructurePreset.custom => '',
  };

  static String _presetGallery(_StructurePreset preset) => switch (preset) {
    _StructurePreset.flat => '%title_%id',
    _StructurePreset.author => '%authorcache/%title_%id',
    _StructurePreset.date => '%date/%title_%id',
    _StructurePreset.custom => '',
  };

  static String _presetImage(_StructurePreset preset) => switch (preset) {
    // 平铺也保留标题文件夹层（图片仍按标题分文件夹，G 屏文案）。
    _StructurePreset.flat => '%title/%filename',
    _StructurePreset.author => '%authorcache/%title/%filename',
    _StructurePreset.date => '%date/%title/%filename',
    _StructurePreset.custom => '',
  };

  /// 升级前的存量出厂值（提示卡与「平铺」派生都以它为基准）。
  static const String _legacyVideoFlat = '%title_%quality';
  static const String _legacyGalleryFlat = '%title_%id';
  static const String _legacyImageFlat = '%title_%filename';

  _StructurePreset get _currentPreset {
    final video =
        configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String? ?? '';
    final gallery =
        configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String? ?? '';
    final image =
        configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String? ?? '';
    if (video == _presetVideo(_StructurePreset.author) &&
        gallery == _presetGallery(_StructurePreset.author) &&
        image == _presetImage(_StructurePreset.author)) {
      return _StructurePreset.author;
    }
    if (video == _presetVideo(_StructurePreset.date) &&
        gallery == _presetGallery(_StructurePreset.date) &&
        image == _presetImage(_StructurePreset.date)) {
      return _StructurePreset.date;
    }
    // 平铺：新预设值，或存量旧默认（单图旧值是平铺串，行为同样是平铺）。
    if (video == _presetVideo(_StructurePreset.flat) &&
        gallery == _presetGallery(_StructurePreset.flat) &&
        (image == _presetImage(_StructurePreset.flat) ||
            image == _legacyImageFlat)) {
      return _StructurePreset.flat;
    }
    return _StructurePreset.custom;
  }

  /// 一次性提示卡显隐：未 dismiss 且三模板仍等于升级前的平铺出厂值。
  /// 新装用户出厂即按作者归档，永远看不到这张卡；自定义过的用户也不打扰。
  bool get _showStructureNotice {
    final dismissed =
        configService[ConfigKey.DOWNLOAD_STRUCTURE_NOTICE_DISMISSED] as bool? ??
        false;
    if (dismissed) return false;
    return configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] ==
            _legacyVideoFlat &&
        configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] ==
            _legacyGalleryFlat &&
        configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] == _legacyImageFlat;
  }

  /// 只有 canned 预设走这里：[_StructurePreset.custom] 不是可选项，
  /// 它由 [_currentPreset] 派生（见 [_buildCustomEntryCard]），选不着也写不进。
  void _applyPreset(_StructurePreset preset) {
    assert(preset != _StructurePreset.custom);
    configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] = _presetVideo(preset);
    configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] = _presetGallery(preset);
    configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] = _presetImage(preset);
    // 「选择即开启」：任意预设被选中，一次性提示卡永久消失。
    configService[ConfigKey.DOWNLOAD_STRUCTURE_NOTICE_DISMISSED] = true;
    setState(() {});
  }

  /// 预设卡右侧的示例路径（样例数据实时渲染，与预览行同一套规则）。
  String _presetExample(_StructurePreset preset) {
    final template = preset == _StructurePreset.custom
        ? configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String? ?? ''
        : _presetVideo(preset);
    final segments = FilenameTemplateService.renderSamplePathSegments(template);
    if (segments.isEmpty) return '/';
    return '/${segments.join(' › ')}';
  }

  /// 预览行根目录的灰字（如 LoveIwara）。
  ///
  /// ⛔ 读的是**当前生效**的目录，不是出厂默认：开了自定义下载路径的用户，
  /// 出厂默认那个目录根本不会被写入，拿它的名字当预览根等于报了个假位置。
  String get _previewRootLabel {
    if (!Get.isRegistered<DownloadPathService>()) return '…';
    final service = DownloadPathService.to;
    final current = service.pathStatus?.currentPath ?? '';
    final base = current.isNotEmpty ? current : service.defaultDownloadPath;
    if (base.isEmpty) return '…';
    return p.basename(base);
  }

  /// 入口卡上的三条模板现值，一类一行。
  ///
  /// 分成「类名 + 模板」两列而不是拼一条 `视频: xxx` 的长字符串：类名列定宽
  /// 对齐，三条模板的起始处就在同一条竖线上，扫一眼能比出差异；挤在一行里
  /// 只能逐条从头读。类名走正文字体、模板走 monospace——后者是要照抄进编辑器
  /// 的原文，前者不是。
  List<Widget> _templateSummaryRows(
    BuildContext context,
    slang.Translations t,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final e = t.settings.downloadSettings.pathTemplateEditor;
    Widget row(String label, ConfigKey key) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(
            child: Text(
              configService[key] as String? ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.45,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
    return [
      row(e.tabVideo, ConfigKey.VIDEO_FILENAME_TEMPLATE),
      row(e.tabGallery, ConfigKey.GALLERY_FILENAME_TEMPLATE),
      row(e.tabImage, ConfigKey.IMAGE_FILENAME_TEMPLATE),
    ];
  }
}
