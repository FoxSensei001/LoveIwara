import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart'
    show openDownloadCategoryManagePage;
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// [showDownloadPickerSheet] 确认下载后的返回结果：选中的清晰度与分类。
class DownloadPickerResult {
  final VideoSource source;
  final String? categoryId;

  const DownloadPickerResult({required this.source, this.categoryId});
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
/// 分类的预选值固定读取“上次选择”（[ConfigKey.LAST_DOWNLOAD_CATEGORY_ID]），与清晰度
/// 的预选来源无关——两个入口对分类的预期是一致的，只有清晰度的预选会因入口而不同。
///
/// 用户取消（下滑关闭/点遮罩）时返回 null；确认下载时返回 [DownloadPickerResult]。
Future<DownloadPickerResult?> showDownloadPickerSheet(
  BuildContext context, {
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
      sources: sources,
      initialQuality: initialQuality,
      preselectSource: preselectSource,
    ),
  );
}

class _DownloadPickerSheet extends StatefulWidget {
  final List<VideoSource> sources;
  final String? initialQuality;
  final DownloadPickerPreselectSource preselectSource;

  const _DownloadPickerSheet({
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
  List<DownloadCategory>? _categories;
  Worker? _categoriesWorker;

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

    _loadCategories();
    _categoriesWorker = ever(
      DownloadService.to.categoriesChangedNotifier,
      (_) => _loadCategories(),
    );
  }

  @override
  void dispose() {
    _categoriesWorker?.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DownloadService.to.getAllCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (e) {
      LogUtils.e('加载下载分类失败', tag: 'DownloadPickerSheet', error: e);
      if (!mounted) return;
      setState(() => _categories = const []);
    }
  }

  /// 选中的分类已不存在（如刚被删除）时回退为「未分类」，避免 Chip 状态悬空。
  /// 分类列表还没加载完成时先原样透传，不阻塞用户看清晰度网格。
  String? get _validCategoryId {
    final categories = _categories;
    if (categories == null) return _selectedCategoryId;
    final id = _selectedCategoryId;
    if (id == null) return null;
    return categories.any((c) => c.id == id) ? id : null;
  }

  void _selectQuality(VideoSource source) {
    setState(() {
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
        categoryId: _validCategoryId,
      ),
    );
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

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
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
            Center(
              child: Container(
                width: 34,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
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
                          t.download.saveToSectionLabel,
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
          leading: SvgPicture.asset(
            CommonUtils.getQualityIconAsset(source.name),
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(
              isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
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

  Widget _buildCategoryChips(BuildContext context, slang.Translations t) {
    final categories = _categories;
    if (categories == null) {
      // 加载中：占位不显示，避免闪烁（与 DownloadCategoryPicker 一致的处理方式）。
      return const SizedBox(height: 34);
    }
    final validCategoryId = _validCategoryId;
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
