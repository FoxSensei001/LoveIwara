import 'package:material_ui/material_ui.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/player_icon.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/utils/desktop_save_dialog.dart';
import 'package:file_selector/file_selector.dart' show XTypeGroup;
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart'
    show openDownloadCategoryManagePage;
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

/// [showDownloadPickerSheet] 确认下载后的返回结果：选中的清晰度与分类。
class DownloadPickerResult {
  final VideoSource source;
  final String? categoryId;

  /// 桌面端在弹层里点「更改…」挑过的**本次**落盘路径；null = 按下载位置配置走。
  final String? savePath;

  const DownloadPickerResult({
    required this.source,
    this.categoryId,
    this.savePath,
  });
}

/// 弹窗打开时清晰度网格里预选中的那一档，标签文案要说明这个预选是哪来的。
enum DownloadPickerPreselectSource {
  /// 从主按钮进入——预选“上次下载用的清晰度”。
  lastUsed,

  /// 从「更多」菜单里点了某个具体清晰度进入——预选“刚点的那个”。
  picked,
}

/// 弹出「选择下载」底部弹窗：清晰度图标网格 + 分类胶囊，一次确认即可下载。
///
/// [sources] 需已按清晰度优先级排序（见 [CommonUtils.sortVideoSourcesByQuality]），
/// 弹窗按传入顺序铺网格，不再重新排序。[initialQuality] 在 [sources] 中找不到匹配项时
/// （大小写不敏感）回退为第一个可用源。
///
/// [video] 供「将保存到」路径预览行按当前清晰度联动重算（issue #126）。
///
/// 分类的预选值固定读取“上次选择”（[ConfigKey.LAST_DOWNLOAD_CATEGORY_ID]），与清晰度
/// 的预选来源无关——两个入口对分类的预期是一致的，只有清晰度的预选会因入口而不同。
///
/// 用户取消（下滑关闭/点遮罩）时返回 null；确认下载时返回 [DownloadPickerResult]。
Future<DownloadPickerResult?> showDownloadPickerSheet(
  BuildContext context, {
  required Video video,
  required List<VideoSource> sources,
  String? initialQuality,
  DownloadPickerPreselectSource preselectSource =
      DownloadPickerPreselectSource.lastUsed,
}) {
  if (sources.isEmpty) return Future.value(null);

  return showModalBottomSheet<DownloadPickerResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _DownloadPickerSheet(
      video: video,
      sources: sources,
      initialQuality: initialQuality,
      preselectSource: preselectSource,
    ),
  );
}

class _DownloadPickerSheet extends StatefulWidget {
  final Video video;
  final List<VideoSource> sources;
  final String? initialQuality;
  final DownloadPickerPreselectSource preselectSource;

  const _DownloadPickerSheet({
    required this.video,
    required this.sources,
    required this.initialQuality,
    required this.preselectSource,
  });

  @override
  State<_DownloadPickerSheet> createState() => _DownloadPickerSheetState();
}

class _DownloadPickerSheetState extends State<_DownloadPickerSheet> {
  late VideoSource _selectedSource;
  // 用户手动点过某个清晰度图块后置空——这时它已经不是“预选”了，图块不用再挂标签。
  DownloadPickerPreselectSource? _preselectSource;
  String? _selectedCategoryId;

  /// 「更改…」挑出的本次保存路径（完整文件路径）。只影响这一次，不改配置。
  String? _oneOffSavePath;
  bool _pickingSavePath = false;

  @override
  void initState() {
    super.initState();
    final wantedQuality = widget.initialQuality?.toLowerCase();
    _selectedSource = widget.sources.firstWhere(
      (s) => (s.name?.toLowerCase() ?? '') == wantedQuality,
      orElse: () => widget.sources.first,
    );
    _preselectSource = widget.preselectSource;

    final configService = Get.find<ConfigService>();
    final lastCategory =
        configService[ConfigKey.LAST_DOWNLOAD_CATEGORY_ID] as String?;
    _selectedCategoryId = (lastCategory == null || lastCategory.isEmpty)
        ? null
        : lastCategory;
  }

  /// 选中的分类已不存在（如刚在管理页被删掉）时回退为「未分类」，避免标签悬空。
  String? _validCategoryIdIn(List<DownloadCategory> categories) {
    final id = _selectedCategoryId;
    if (id == null) return null;
    return categories.any((c) => c.id == id) ? id : null;
  }

  void _selectQuality(VideoSource source) {
    setState(() {
      // 另存的文件名是按挑的那一刻的清晰度起的（xxx_1080.mp4），换了清晰度就
      // 不再对得上——作废，回到按配置算的路径。（先比较、再赋值。）
      if (!identical(source, _selectedSource)) _oneOffSavePath = null;
      _selectedSource = source;
      _preselectSource = null;
    });
  }

  void _selectCategory(String? id) {
    setState(() => _selectedCategoryId = id);
  }

  void _confirm() {
    Navigator.of(context).pop(
      DownloadPickerResult(
        source: _selectedSource,
        categoryId: _validCategoryIdIn(DownloadService.to.categories),
        savePath: _oneOffSavePath,
      ),
    );
  }

  /// 「更改…」：这一次另存到别处，弹系统「另存为」。
  ///
  /// 只在用户主动点的时候才弹——默认路径不碰系统对话框（见
  /// [DownloadPathService.asksEveryTime] 上的说明）。
  Future<void> _pickOneOffSavePath() async {
    if (_pickingSavePath) return;
    setState(() => _pickingSavePath = true);
    try {
      final segments = DownloadPathService.to.previewVideoRelativePath(
        video: widget.video,
        quality: _selectedSource.name ?? '',
      );
      final result = await showDesktopSaveDialog(
        purpose: '下载视频（本次另存）',
        suggestedName: segments.isEmpty ? null : segments.last,
        acceptedTypeGroups: [
          const XTypeGroup(label: 'MP4 Video', extensions: ['mp4']),
        ],
      );
      if (!mounted || result == null) return;
      setState(() => _oneOffSavePath = result.path);
    } catch (_) {
      // showDesktopSaveDialog 已记过错误日志。别让它冒出 onTap 变成未捕获异常：
      // 那会被全局处理器写成 fatal 快照，下次崩溃导出又要误判死因。
      if (mounted) {
        showAppToast(
          slang.t.download.errors.downloadFailed,
          type: AppToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _pickingSavePath = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sectionLabelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: colorScheme.onSurfaceVariant,
    );

    return GlassBottomSheet(
      showCloseButton: false,
      maxHeightFactor: 0.85,
      padding: const EdgeInsets.fromLTRB(
        UIConstants.pagePadding,
        10,
        UIConstants.pagePadding,
        UIConstants.pagePadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.download.selectDownloadTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: UIConstants.sectionSpacing),
          // 清晰度网格固定 2-3 行、分类胶囊行数不定（分类可以建很多个）——
          // 用 Flexible + 滚动把这段"内容可能比屏幕高"的部分兜住，
          // 让下面的确认按钮始终留在可见区域内，不会被顶出屏幕摸不到。
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.download.qualitySectionLabel,
                    style: sectionLabelStyle,
                  ),
                  const SizedBox(height: UIConstants.listSpacing),
                  _buildQualityGrid(context, colorScheme, t),
                  const SizedBox(height: UIConstants.sectionSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.download.categorySectionLabel,
                        style: sectionLabelStyle,
                      ),
                      InkWell(
                        onTap: () => openDownloadCategoryManagePage(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                t.download.category.createShortcut,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.listSpacing),
                  _buildCategoryChips(context, t),
                  const SizedBox(height: UIConstants.sectionSpacing),
                  // 「将保存到」：按当前清晰度联动重算的落盘路径预览（issue #126）。
                  // 所见即所得；桌面「每次询问」模式下没有固定基目录，只能给出系统
                  // 对话框的建议文件名。桌面固定目录模式下带「更改…」，本次另存。
                  _buildSaveToPreview(context, colorScheme, t),
                ],
              ),
            ),
          ),
          const SizedBox(height: UIConstants.sectionSpacing),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.download, size: 18),
              label: Text(t.download.download),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityGrid(
    BuildContext context,
    ColorScheme colorScheme,
    slang.Translations t,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.sources.map((source) {
        // 按对象同一性比较，而不是 name——两个清晰度都没有 name 时
        // （理论上不该发生，但没有约束保证）字符串比较会让它们一起亮起。
        final isSelected = identical(source, _selectedSource);

        String? badgeText;
        if (isSelected && _preselectSource != null) {
          badgeText = _preselectSource == DownloadPickerPreselectSource.lastUsed
              ? t.download.lastUsedBadge
              : t.download.pickedBadge;
        }

        return _PickerChip(
          label: CommonUtils.getQualityDisplayLabel(t, source.name),
          selected: isSelected,
          onTap: () => _selectQuality(source),
          leading: PlayerQualityIcon(
            quality: source.name,
            size: 15,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
          trailing: badgeText == null
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        );
      }).toList(),
    );
  }

  /// 「将保存到」预览行。
  ///
  /// 与真实落盘共用同一条模板渲染 + 清洗规则（preview 不写作者首见名缓存），
  /// 用户看到的和落盘的永远一致；桌面「每次询问」模式下退化为建议文件名；
  /// 点过「更改…」时显示挑出来的那条完整路径。
  Widget _buildSaveToPreview(
    BuildContext context,
    ColorScheme colorScheme,
    slang.Translations t,
  ) {
    final pathService = DownloadPathService.to;
    final segments = pathService.previewVideoRelativePath(
      video: widget.video,
      quality: _selectedSource.name ?? '',
    );
    final askEveryTime = pathService.asksEveryTime;
    // 「更改…」只给桌面的固定目录模式：「每次询问」本来就会弹框，移动端没有
    // 「另存为」可弹。
    final canChange = GetPlatform.isDesktop && !askEveryTime;
    final oneOff = _oneOffSavePath;

    final Widget valueWidget;
    if (oneOff != null) {
      valueWidget = Text(
        oneOff,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      );
    } else if (askEveryTime) {
      valueWidget = Text(
        t.download.saveToPreviewSuggested(
          name: segments.isEmpty ? '' : segments.last,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          color: colorScheme.onSurface,
        ),
      );
    } else {
      final spans = <InlineSpan>[];
      for (var i = 0; i < segments.length; i++) {
        final isFile = i == segments.length - 1;
        if (i > 0) {
          spans.add(
            TextSpan(
              text: ' › ',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          );
        }
        spans.add(
          TextSpan(
            text: segments[i],
            style: TextStyle(
              color: isFile ? colorScheme.onSurface : colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      valueWidget = Text.rich(
        TextSpan(
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
          children: spans,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.download.saveToPreviewLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget,
              ],
            ),
          ),
          if (canChange) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: _pickingSavePath ? null : _pickOneOffSavePath,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  t.download.saveToPreviewChange,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _pickingSavePath
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 分类标签行。
  ///
  /// 直接 Obx 读服务里的分类状态：在这个弹窗上点「管理分类」新建完返回，标签当场
  /// 就在，不需要页面自己订阅广播再去重拉（那条链断掉时是静默的）。
  Widget _buildCategoryChips(BuildContext context, slang.Translations t) {
    return Obx(
      () => _buildCategoryChipsContent(t, DownloadService.to.categories),
    );
  }

  Widget _buildCategoryChipsContent(
    slang.Translations t,
    List<DownloadCategory> categories,
  ) {
    final validCategoryId = _validCategoryIdIn(categories);
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _PickerChip(
          label: t.download.category.uncategorized,
          selected: validCategoryId == null,
          onTap: () => _selectCategory(null),
        ),
        for (final category in categories)
          _PickerChip(
            label: category.title,
            selected: validCategoryId == category.id,
            onTap: () => _selectCategory(category.id),
          ),
      ],
    );
  }
}

/// 弹窗里统一的"标签按钮"：清晰度、分类两行都用它，只是清晰度多了个 [leading]
/// 图标、选中态可能多一个 [trailing] 来源徽章——外观上是同一套标签按钮。
class _PickerChip extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;

  const _PickerChip({
    this.leading,
    required this.label,
    this.trailing,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        // 来源徽章（trailing）会随选中态出现/消失，图块宽度跟着变化——
        // 用 AnimatedSize 把这次宽度跳变过渡成动画，而不是硬切。
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 6), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
