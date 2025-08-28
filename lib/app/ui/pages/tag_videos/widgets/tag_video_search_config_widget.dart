import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 标签视频列表页面的简化搜索配置弹窗
/// 只包含年份、月份和评级选择，不包含标签选择
class TagVideoSearchConfigWidget extends StatefulWidget {
  final List<Tag> fixedTags; // 固定的标签，不可修改
  final String searchYear;
  final String searchRating;
  final Function(List<Tag> tags, String year, String rating) onConfirm;

  const TagVideoSearchConfigWidget({
    super.key,
    required this.fixedTags,
    required this.searchYear,
    required this.searchRating,
    required this.onConfirm,
  });

  @override
  State<TagVideoSearchConfigWidget> createState() =>
      _TagVideoSearchConfigWidgetState();
}

class _TagVideoSearchConfigWidgetState
    extends State<TagVideoSearchConfigWidget> {
  late String year;
  late String month;
  late MediaRating _selectedRating;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _monthScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 解析年份和月份
    final dateParts = widget.searchYear.split('-');
    year = dateParts.isNotEmpty ? dateParts[0] : '';
    month = dateParts.length > 1 ? dateParts[1] : '';

    _selectedRating = MediaRating.values.firstWhere(
      (MediaRating rating) => rating.value == widget.searchRating,
      orElse: () => MediaRating.ALL,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final t = slang.Translations.of(context);

    if (screenWidth > 600) {
      // 屏幕宽度大于600，使用Dialog形式展示
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 800,
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
                  child: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _confirmAndClose,
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
              icon: const Icon(Icons.check),
              onPressed: _confirmAndClose,
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

  void _confirmAndClose() {
    // 组合年份和月份为最终的日期字符串
    String finalDate = '';
    if (year.isNotEmpty) {
      finalDate = year;
      if (month.isNotEmpty) {
        finalDate = '$year-$month';
      }
    }
    widget.onConfirm(widget.fixedTags, finalDate, _selectedRating.value);
    Navigator.of(context).pop();
  }

  Widget _buildPageContent(BuildContext context) {
    final t = slang.Translations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示当前固定的标签
          if (widget.fixedTags.isNotEmpty) ...[
            Text(
              '${t.common.tag}: ',
              style: const TextStyle(fontSize: 16),
            ).paddingBottom(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.fixedTags.map((tag) {
                return Chip(
                  label: Text(tag.id),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                );
              }).toList(),
            ).paddingBottom(16),
          ],
          _buildContentRatingSection(context),
          _buildYearSelectionSection(context),
          _buildMonthSelectionSection(context),
        ],
      ),
    );
  }

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
            setState(() {
              _selectedRating = selected.first;
            });
          },
        ).paddingBottom(16),
      ],
    );
  }

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
                              month = '';
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
                              month = '';
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
        ).paddingBottom(16),
      ],
    );
  }

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
                itemCount: 13,
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
        ).paddingBottom(16),
      ],
    );
  }
}
