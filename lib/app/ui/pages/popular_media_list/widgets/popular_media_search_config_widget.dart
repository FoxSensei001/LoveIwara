import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import '../../../../../common/constants.dart' show SortId;
import '../../../../../common/enums/media_enums.dart';
import '../../../../models/sort.model.dart';
import '../../../../models/tag.model.dart';
import '../../../widgets/empty_widget.dart';
import 'add_search_tag_dialog.dart';
import 'remove_search_tag_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 热门视频的搜索配置
///
/// 也复用于作者详情页与订阅页：
/// - [showRating] 为 false 时隐藏内容评级（实测服务端在带 `user=` 的查询里会
///   忽略 `rating`，见作者页；此时回调原样返回传入的 [searchRating]）。
/// - [sortOptions] 非空时额外显示排序区（订阅页没有排序 tab，只能放这里）。
class PopularMediaSearchConfig extends StatefulWidget {
  final List<Tag> searchTags; // 此时用作搜索的标签
  final String searchYear;
  final String searchRating;

  /// 是否显示内容评级选择区。
  final bool showRating;

  /// 可选排序项；为 null 时不显示排序区。
  final List<Sort>? sortOptions;

  /// 当前选中的排序 id（[sortOptions] 非空时有效）。
  final SortId? selectedSortId;

  final Function(List<Tag> tags, String year, String rating, SortId? sortId)
  onConfirm;

  const PopularMediaSearchConfig({
    super.key,
    required this.searchTags,
    required this.searchYear,
    required this.searchRating,
    required this.onConfirm,
    this.showRating = true,
    this.sortOptions,
    this.selectedSortId,
  });

  @override
  State<PopularMediaSearchConfig> createState() =>
      _PopularMediaSearchConfigState();
}

class _PopularMediaSearchConfigState extends State<PopularMediaSearchConfig> {
  late List<Tag> tags; // 选中的标签
  late String year; // 选中的年份
  late String month; // 选中的月份
  late String rating;
  late MediaRating _selectedRating;
  SortId? _selectedSortId;
  late UserPreferenceService _userPreferenceService;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _monthScrollController = ScrollController();

  /// 标签 chip 是否展示原始 key（false 时展示当前语言译名）。
  bool _showOriginalTags = false;

  @override
  void initState() {
    super.initState();
    _userPreferenceService = Get.find<UserPreferenceService>();
    tags = List.from(widget.searchTags);
    rating = widget.searchRating;

    // 解析年份和月份
    final dateParts = widget.searchYear.split('-');
    year = dateParts.isNotEmpty ? dateParts[0] : '';
    month = dateParts.length > 1 ? dateParts[1] : '';

    _selectedRating = MediaRating.values.firstWhere(
      (MediaRating rating) => rating.value == widget.searchRating,
      orElse: () => MediaRating.ALL,
    );
    // 排序区不允许「一个都没选中」：调用方没给初值时兜底到时间排序（没有时间
    // 排序的话退到第一项），否则确认时回调只能返回 null，调用方无从判断。
    _selectedSortId = widget.selectedSortId ?? _defaultSortId;
    LogUtils.d(
      'tags: $tags, year: $year, month: $month, rating: $rating',
      'PopularVideoSearchConfig',
    );
  }

  /// 排序区的默认项：优先时间排序，没有则退到第一项；没有排序区时为 null。
  SortId? get _defaultSortId {
    final sortOptions = widget.sortOptions;
    if (sortOptions == null || sortOptions.isEmpty) return null;
    return sortOptions.any((sort) => sort.id == SortId.date)
        ? SortId.date
        : sortOptions.first.id;
  }

  /// 是否有可重置的内容（决定重置按钮是否可点）。
  bool get _hasAnyConfig =>
      tags.isNotEmpty ||
      year.isNotEmpty ||
      month.isNotEmpty ||
      (widget.showRating && _selectedRating != MediaRating.ALL) ||
      (widget.sortOptions != null && _selectedSortId != _defaultSortId);

  /// 重置为「无筛选」。只改弹窗内的选择，仍需点确认才会应用到列表。
  void _resetConfig() {
    setState(() {
      tags = [];
      year = '';
      month = '';
      _selectedRating = MediaRating.ALL;
      _selectedSortId = _defaultSortId;
    });
  }

  /// 把已选的年份与月份组合成最终的日期字符串（'' / 'YYYY' / 'YYYY-MM'）。
  String _buildFinalDate() {
    String finalDate = '';
    if (year.isNotEmpty) {
      finalDate = year;
      if (month.isNotEmpty) {
        finalDate = '$year-$month';
      }
    }
    return finalDate;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final t = slang.Translations.of(context);

    if (screenWidth > 600) {
      // 屏幕宽度大于600，使用Dialog形式展示
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 设置圆角
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1200,
            minWidth: 400,
            maxHeight: screenHeight * 0.8, // 限制最大高度为屏幕高度的80%
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settings.searchConfig,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildPageContent(context)),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restart_alt),
                        tooltip: t.searchFilter.clearAll,
                        onPressed: _hasAnyConfig ? _resetConfig : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          widget.onConfirm(
                            tags,
                            _buildFinalDate(),
                            _effectiveRating,
                            _selectedSortId,
                          );
                          AppService.tryPop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // 屏幕宽度小于等于600，使用普通页面展示
      return Scaffold(
        appBar: AppBar(
          title: Text(t.settings.searchConfig),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: t.searchFilter.clearAll,
              onPressed: _hasAnyConfig ? _resetConfig : null,
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                widget.onConfirm(
                  tags,
                  _buildFinalDate(),
                  _effectiveRating,
                  _selectedSortId,
                );
                AppService.tryPop();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildPageContent(context),
        ),
      );
    }
  }

  /// 隐藏评级区时不改动原有取值，避免把调用方传进来的 rating 洗成 ALL。
  String get _effectiveRating =>
      widget.showRating ? _selectedRating.value : widget.searchRating;

  // 构建页面内容
  Widget _buildPageContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.sortOptions != null) _buildSortSection(context),
          if (widget.showRating) _buildContentRatingSection(context),
          _buildYearSelectionSection(context),
          _buildMonthSelectionSection(context),
          _buildTagSelectionSection(context),
        ],
      ),
    );
  }

  // 构建排序部分（仅在调用方传入 sortOptions 时显示）
  Widget _buildSortSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final sorts = widget.sortOptions!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.common.sort}: ',
          style: const TextStyle(fontSize: 16),
        ).paddingBottom(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sorts.map((sort) {
            final bool isSelected = _selectedSortId == sort.id;
            return ChoiceChip(
              label: Text(sort.label),
              // 选中时让对号顶掉图标（两者都给会并排显示，看着像重叠）
              avatar: isSelected ? null : sort.icon,
              selected: isSelected,
              onSelected: (bool selected) {
                if (!selected) return;
                setState(() {
                  _selectedSortId = sort.id;
                });
              },
            );
          }).toList(),
        ).paddingBottom(8),
      ],
    );
  }

  // 构建内容评级部分
  Widget _buildContentRatingSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.search.contentRating}: ',
          style: const TextStyle(fontSize: 16),
        ).paddingBottom(8),
        SegmentedButton<MediaRating>(
          segments: MediaRating.values.map((MediaRating rating) {
            return ButtonSegment<MediaRating>(
              value: rating,
              label: Text(rating.label),
            );
          }).toList(),
          selected: {_selectedRating},
          onSelectionChanged: (Set<MediaRating> selected) {
            LogUtils.d('选择的元素: ${selected.first}', 'PopularVideoSearchConfig');
            setState(() {
              _selectedRating = selected.first;
            });
          },
        ).paddingBottom(8),
      ],
    );
  }

  // 构建年份选择部分
  Widget _buildYearSelectionSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final currentYear = DateTime.now().year;
    const startYear = 2010;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.common.year}: ',
          style: const TextStyle(fontSize: 16),
        ).paddingBottom(8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                // 将垂直滚动转换为水平滚动
                final scrollDelta = pointerSignal.scrollDelta.dy;
                final newPosition =
                    _scrollController.position.pixels - scrollDelta;

                // 确保滚动位置在有效范围内
                final maxScrollExtent =
                    _scrollController.position.maxScrollExtent;
                final clampedPosition = newPosition.clamp(0.0, maxScrollExtent);

                _scrollController.animateTo(
                  clampedPosition,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                );
              }
            },
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: (currentYear - startYear + 2),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t.common.all),
                        selected: year.isEmpty,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              year = '';
                              month = ''; // 清空年份时也清空月份
                            });
                          }
                        },
                      ),
                    );
                  } else {
                    final yearValue = (currentYear - (index - 1)).toString();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(yearValue),
                        selected: year == yearValue,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              year = yearValue;
                              month = ''; // 选择新年份时重置月份
                            });
                          }
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ).paddingBottom(8),
      ],
    );
  }

  // 构建月份选择部分
  Widget _buildMonthSelectionSection(BuildContext context) {
    final t = slang.Translations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.common.month}: ',
          style: const TextStyle(fontSize: 16),
        ).paddingBottom(8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                // 将垂直滚动转换为水平滚动
                final scrollDelta = pointerSignal.scrollDelta.dy;
                final newPosition =
                    _monthScrollController.position.pixels - scrollDelta;

                // 确保滚动位置在有效范围内
                final maxScrollExtent =
                    _monthScrollController.position.maxScrollExtent;
                final clampedPosition = newPosition.clamp(0.0, maxScrollExtent);

                _monthScrollController.animateTo(
                  clampedPosition,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                );
              }
            },
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _monthScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 13, // "全部" + 12个月
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t.common.all),
                        selected: month.isEmpty,
                        onSelected: year.isEmpty
                            ? null
                            : (bool selected) {
                                if (selected) {
                                  setState(() {
                                    month = '';
                                  });
                                }
                              },
                      ),
                    );
                  } else {
                    final monthValue = index.toString();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(monthValue),
                        selected: month == monthValue,
                        onSelected: year.isEmpty
                            ? null
                            : (bool selected) {
                                if (selected) {
                                  setState(() {
                                    month = monthValue;
                                  });
                                }
                              },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ).paddingBottom(8),
      ],
    );
  }

  /// 可选标签里是否存在「译名 ≠ 原始 key」——决定是否显示「原文/译文」切换按钮。
  bool get _hasMeaningfulTagTranslation {
    for (final tag in _userPreferenceService.videoSearchTagHistory.value) {
      if (TagLocalizationService.displayName(tag.id) != tag.id) return true;
    }
    return false;
  }

  // 构建标签选择部分
  Widget _buildTagSelectionSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${t.common.tag}: ', style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                // 标签本地化引导
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: t.common.tagLocalizationGuideTitle,
                  onPressed: () => showTagLocalizationGuideDialog(context),
                ),
                // 切换标签 chip 显示：原始 key / 当前译文
                if (_hasMeaningfulTagTranslation)
                  IconButton(
                    icon: Icon(
                      _showOriginalTags ? Icons.translate : Icons.tag,
                    ),
                    tooltip: _showOriginalTags
                        ? t.common.showTranslatedTag
                        : t.common.showOriginalTag,
                    onPressed: () => setState(
                      () => _showOriginalTags = !_showOriginalTags,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    showAppDialog(
                      RemoveSearchTagDialog(
                        onRemoveIds: (List<String> removedTags) {
                          for (var id in removedTags) {
                            _userPreferenceService.removeVideoSearchTagById(id);
                          }
                          setState(() {
                            tags.removeWhere(
                              (tag) => removedTags.contains(tag.id),
                            );
                          });
                        },
                        videoSearchTagHistory:
                            _userPreferenceService.videoSearchTagHistory,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showAppDialog(const AddSearchTagDialog());
                  },
                ),
              ],
            ),
          ],
        ).paddingBottom(8),
        Obx(() {
          List<Tag> remappedTags =
              _userPreferenceService.videoSearchTagHistory.value;

          if (remappedTags.isEmpty) {
            return const MyEmptyWidget();
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: remappedTags.map((tag) {
              return FilterChip(
                label: Text(
                  _showOriginalTags
                      ? tag.id
                      : TagLocalizationService.displayName(tag.id),
                ),
                selected: tags.any((element) => element.id == tag.id),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      tags.add(tag);
                    } else {
                      tags.removeWhere((element) => element.id == tag.id);
                    }
                  });
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }
}
