import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/constants.dart' show SortId;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import 'add_search_tag_dialog.dart';
import 'remove_search_tag_dialog.dart';

/// 年 / 月与服务端日期串（`''` / `'YYYY'` / `'YYYY-MM'`）之间的互转。
///
/// 抽出来是因为这条契约有两个反直觉的点，散在回调里很容易被改坏：
///   1. **只有月份是非法的**——服务端的日期过滤只认 `YYYY` 与 `YYYY-MM`
///      两档，年份为空时月份必须一起丢掉；
///   2. 换年份要连带清掉月份，否则会拼出「新年份 + 旧月份」这种用户没选过的组合。
abstract final class MediaFilterDate {
  /// 拆开日期串。年份为空时月份恒为空。
  static (String year, String month) parse(String date) {
    if (date.isEmpty) return ('', '');
    final parts = date.split('-');
    final year = parts.isNotEmpty ? parts[0] : '';
    if (year.isEmpty) return ('', '');
    return (year, parts.length > 1 ? parts[1] : '');
  }

  /// 拼回日期串。没有年份就没有日期。
  static String compose({required String year, required String month}) {
    if (year.isEmpty) return '';
    return month.isEmpty ? year : '$year-$month';
  }
}

/// 打开「筛选」抽屉（热门视频 / 图库 / 订阅共用）。
///
/// 改动**即时生效**：每次勾选都会立刻回调 [onChanged]，抽屉不关，可以边看
/// 身后的列表变化边继续调。没有确认钮，只有 header 上的重置。
Future<void> showMediaFilterDrawer({
  required BuildContext context,
  required List<Tag> tags,
  required String date,
  required String rating,
  required void Function(
    List<Tag> tags,
    String date,
    String rating,
    SortId? sortId,
  )
  onChanged,
  bool showRating = true,
  bool tagsFixed = false,
  List<Sort>? sortOptions,
  SortId? selectedSortId,
}) {
  return showGlassSideDrawer<void>(
    context: context,
    builder: (_) => MediaFilterDrawer(
      initialTags: tags,
      initialDate: date,
      initialRating: rating,
      showRating: showRating,
      tagsFixed: tagsFixed,
      sortOptions: sortOptions,
      selectedSortId: selectedSortId,
      onChanged: onChanged,
    ),
  );
}

/// 「筛选」抽屉的内容：已保存 · 排序 · 评级 · 年 · 月 · 标签。
///
/// 前身是 `PopularMediaSearchConfig`（宽屏居中弹窗 / 窄屏整页）。
///
/// # 单选项一律走 [GlassDropdownField]，不再铺胶囊墙
///
/// 原来年份 18 个、月份 13 个、排序 4 个、评级 3 个全是铺开的选择胶囊——弹窗
/// 有 800px 摊得开，抽屉只有 380~460，铺开就是**几十个元素挤在一屏**，扫都扫
/// 不过来（2026-08-26 用户原话：「那些年份啊、月份啊，它们都出现在这里了」）。
/// 这四项都是**单选**，收起来只占一行、展开才是完整列表，正是 Select 的形状：
/// 现在一律用 [GlassDropdownField]（它弹的就是全站那套玻璃菜单，自带长按打开
/// 与滑动取焦）。
///
/// 只有标签区还是胶囊——它是**多选**，而且那些标签就是筛选本身的内容，不是
/// 一个可以折起来的取值。
class MediaFilterDrawer extends StatefulWidget {
  const MediaFilterDrawer({
    super.key,
    required this.initialTags,
    required this.initialDate,
    required this.initialRating,
    required this.onChanged,
    this.showRating = true,
    this.tagsFixed = false,
    this.sortOptions,
    this.selectedSortId,
  });

  final List<Tag> initialTags;

  /// '' / 'YYYY' / 'YYYY-MM'
  final String initialDate;
  final String initialRating;

  /// 是否显示内容评级区。服务端在带 `user=` 的查询里会忽略 `rating`，
  /// 那些页面传 false；此时回调原样返回传入的 [initialRating]。
  final bool showRating;

  /// 标签是否锁定。标签视频页的标签来自路由参数（「这一页就是看这个标签的」），
  /// 在筛选里改掉它等于换了一个页面——所以那里传 true：标签区退化成只读展示，
  /// 回调也原样返回传进来的这几个标签。
  final bool tagsFixed;

  /// 可选排序项；为 null 时不显示排序区（排序在页面自己的 TabBar 上）。
  final List<Sort>? sortOptions;
  final SortId? selectedSortId;

  final void Function(
    List<Tag> tags,
    String date,
    String rating,
    SortId? sortId,
  )
  onChanged;

  @override
  State<MediaFilterDrawer> createState() => _MediaFilterDrawerState();
}

class _MediaFilterDrawerState extends State<MediaFilterDrawer> {
  late List<Tag> _tags;
  late String _year;
  late String _month;
  late MediaRating _rating;
  SortId? _sortId;

  late final UserPreferenceService _userPreferenceService =
      Get.find<UserPreferenceService>();

  /// 标签胶囊是否展示原始 key（false 时展示当前语言译名）。
  bool _showOriginalTags = false;

  @override
  void initState() {
    super.initState();
    _tags = List<Tag>.from(widget.initialTags);
    final (year, month) = MediaFilterDate.parse(widget.initialDate);
    _year = year;
    _month = month;

    _rating = MediaRating.values.firstWhere(
      (r) => r.value == widget.initialRating,
      orElse: () => MediaRating.ALL,
    );
    // 排序区不允许「一个都没选中」：调用方没给初值时兜底到时间排序（没有时间
    // 排序的话退到第一项），否则回调只能返回 null，调用方无从判断。
    _sortId = widget.selectedSortId ?? _defaultSortId;
  }

  SortId? get _defaultSortId {
    final sortOptions = widget.sortOptions;
    if (sortOptions == null || sortOptions.isEmpty) return null;
    return sortOptions.any((sort) => sort.id == SortId.date)
        ? SortId.date
        : sortOptions.first.id;
  }

  /// 隐藏评级区时不改动原有取值，避免把调用方传进来的 rating 洗成 ALL。
  String get _effectiveRating =>
      widget.showRating ? _rating.value : widget.initialRating;

  String get _effectiveDate =>
      MediaFilterDate.compose(year: _year, month: _month);

  bool get _hasAnyConfig =>
      (!widget.tagsFixed && _tags.isNotEmpty) ||
      _year.isNotEmpty ||
      _month.isNotEmpty ||
      (widget.showRating && _rating != MediaRating.ALL) ||
      (widget.sortOptions != null && _sortId != _defaultSortId);

  /// 改一次、播一次：抽屉不关，列表在身后立刻跟着变。
  void _emit() {
    widget.onChanged(
      List<Tag>.from(_tags),
      _effectiveDate,
      _effectiveRating,
      _sortId,
    );
  }

  void _mutate(VoidCallback change) {
    setState(change);
    _emit();
  }

  void _reset() => _mutate(() {
    if (!widget.tagsFixed) _tags = [];
    _year = '';
    _month = '';
    _rating = MediaRating.ALL;
    _sortId = _defaultSortId;
  });

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassFilterDrawerShell(
      title: t.searchFilter.filterSettings,
      subtitle: t.searchFilter.drawerSubtitle,
      onReset: _hasAnyConfig ? _reset : null,
      children: [
        if (widget.sortOptions != null) _buildSortSection(t),
        if (widget.showRating) _buildRatingSection(t),
        _buildDateSection(t),
        _buildTagSection(t),
      ],
    );
  }

  Widget _buildSortSection(slang.Translations t) {
    final sorts = widget.sortOptions!;
    return GlassFilterSection(
      title: t.common.sort,
      child: SizedBox(
        width: double.infinity,
        child: GlassDropdownField<SortId>(
          value: _sortId,
          items: [
            for (final sort in sorts)
              GlassDropdownItem<SortId>(value: sort.id, label: sort.label),
          ],
          onChanged: (picked) {
            if (picked == null) return;
            _mutate(() => _sortId = picked);
          },
        ),
      ),
    );
  }

  Widget _buildRatingSection(slang.Translations t) {
    return GlassFilterSection(
      title: t.search.contentRating,
      child: SizedBox(
        width: double.infinity,
        child: GlassDropdownField<MediaRating>(
          value: _rating,
          items: [
            for (final rating in MediaRating.values)
              GlassDropdownItem<MediaRating>(
                value: rating,
                label: rating.label,
              ),
          ],
          onChanged: (picked) {
            if (picked == null) return;
            _mutate(() => _rating = picked);
          },
        ),
      ),
    );
  }

  /// 年 + 月：同一件事（时间范围）的两个字段，并排两只 Select 占一行。
  /// 没选年份时月份不可用——服务端的日期过滤是 'YYYY' / 'YYYY-MM' 两档，
  /// 光给月份没有意义。
  Widget _buildDateSection(slang.Translations t) {
    final currentYear = DateTime.now().year;
    const startYear = 2010;
    final bool monthEnabled = _year.isNotEmpty;

    return GlassFilterSection(
      title: t.searchFilter.date,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _LabeledField(
              label: t.common.year,
              child: GlassDropdownField<String>(
                value: _year,
                items: [
                  GlassDropdownItem<String>(value: '', label: t.common.all),
                  for (int y = currentYear; y >= startYear; y--)
                    GlassDropdownItem<String>(value: '$y', label: '$y'),
                ],
                onChanged: (picked) => _mutate(() {
                  _year = picked ?? '';
                  _month = ''; // 换年份（含清空）一律重置月份
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LabeledField(
              label: t.common.month,
              enabled: monthEnabled,
              child: GlassDropdownField<String>(
                value: _month,
                enabled: monthEnabled,
                items: [
                  GlassDropdownItem<String>(value: '', label: t.common.all),
                  for (int m = 1; m <= 12; m++)
                    GlassDropdownItem<String>(value: '$m', label: '$m'),
                ],
                onChanged: (picked) => _mutate(() => _month = picked ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 可选标签里是否存在「译名 ≠ 原始 key」——决定是否显示「原文/译文」切换钮。
  bool get _hasMeaningfulTagTranslation {
    for (final tag in _userPreferenceService.videoSearchTagHistory.value) {
      if (TagLocalizationService.displayName(tag.id) != tag.id) return true;
    }
    return false;
  }

  Widget _buildTagSection(slang.Translations t) {
    if (widget.tagsFixed) return _buildFixedTagSection(t);
    return GlassFilterSection(
      title: t.common.tag,
      actions: [
        _TagAction(
          icon: Icons.help_outline,
          tooltip: t.common.tagLocalizationGuideTitle,
          onPressed: () => showTagLocalizationGuideDialog(context),
        ),
        if (_hasMeaningfulTagTranslation)
          _TagAction(
            icon: _showOriginalTags ? Icons.translate : Icons.tag,
            tooltip: _showOriginalTags
                ? t.common.showTranslatedTag
                : t.common.showOriginalTag,
            onPressed: () =>
                setState(() => _showOriginalTags = !_showOriginalTags),
          ),
        _TagAction(
          icon: Icons.remove,
          tooltip: t.common.delete,
          onPressed: () => showAppDialog(
            RemoveSearchTagDialog(
              onRemoveIds: (removedTags) {
                for (final id in removedTags) {
                  _userPreferenceService.removeVideoSearchTagById(id);
                }
                _mutate(
                  () =>
                      _tags.removeWhere((tag) => removedTags.contains(tag.id)),
                );
              },
              videoSearchTagHistory:
                  _userPreferenceService.videoSearchTagHistory,
            ),
          ),
        ),
        _TagAction(
          icon: Icons.add,
          tooltip: t.searchFilter.add,
          onPressed: () => showAppDialog(const AddSearchTagDialog()),
        ),
      ],
      child: Obx(() {
        final candidates = _userPreferenceService.videoSearchTagHistory.value;
        if (candidates.isEmpty) return const MyEmptyWidget();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: candidates.map((tag) {
            return FilterChip(
              label: Text(
                _showOriginalTags
                    ? tag.id
                    : TagLocalizationService.displayName(tag.id),
              ),
              selected: _tags.any((element) => element.id == tag.id),
              onSelected: (selected) => _mutate(() {
                if (selected) {
                  _tags.add(tag);
                } else {
                  _tags.removeWhere((element) => element.id == tag.id);
                }
              }),
            );
          }).toList(),
        );
      }),
    );
  }

  /// 锁定标签：只读展示，说明「这一页固定在看这些标签」。
  Widget _buildFixedTagSection(slang.Translations t) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassFilterSection(
      title: t.common.tag,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tags
            .map(
              (tag) => Chip(
                label: Text(TagLocalizationService.displayName(tag.id)),
                backgroundColor: colorScheme.primaryContainer,
                side: BorderSide.none,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 一只 Select 上方的小字标签。
///
/// 年 / 月两只并排时，没选之前都显示「全部」——不给标签的话两只长得一模一样，
/// 认不出哪只是年哪只是月。[enabled] 为 false 时标签跟着一起压淡，和下面那只
/// 禁用的 Select 保持同一种「现在还轮不到你」的观感。
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.enabled = true,
  });

  final String label;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: enabled
                ? cs.onSurfaceVariant
                : cs.onSurfaceVariant.withValues(alpha: 0.38),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// 分区小标题右侧的紧凑动作键。抽屉只有 380~460 宽，标签区一行要塞下 4 枚，
/// 用默认 48px 的 `IconButton` 会把标题挤没。
class _TagAction extends StatelessWidget {
  const _TagAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
    );
  }
}
