import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import '../../../../../common/enums/media_enums.dart';
import '../../../../models/tag.model.dart';
import '../../../widgets/empty_widget.dart';
import 'add_search_tag_dialog.dart';
import 'remove_search_tag_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 热门视频的搜索配置
class PopularMediaSearchConfig extends StatefulWidget {
  final List<Tag> searchTags; // 此时用作搜索的标签
  final String searchYear;
  final String searchRating;
  final Function(List<Tag> tags, String year, String rating) onConfirm;

  const PopularMediaSearchConfig({
    super.key,
    required this.searchTags,
    required this.searchYear,
    required this.searchRating,
    required this.onConfirm,
  });

  @override
  _PopularMediaSearchConfigState createState() =>
      _PopularMediaSearchConfigState();
}

class _PopularMediaSearchConfigState extends State<PopularMediaSearchConfig> {
  late List<Tag> tags; // 选中的标签
  late String year; // 选中的年份
  late String month; // 选中的月份
  late String rating;
  late MediaRating _selectedRating;
  late UserPreferenceService _userPreferenceService;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _monthScrollController = ScrollController();

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
        (MediaRating rating) => rating.value == widget.searchRating);
    LogUtils.d(
        'tags: $tags, year: $year, month: $month, rating: $rating', 'PopularVideoSearchConfig');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final t = slang.Translations.of(context);

    if (screenWidth > 600) {
      // 屏幕宽度大于600，使用Dialog形式展示
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 设置圆角
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
            minWidth: 400,
          ),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.settings.searchConfig, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),
                      _buildPageContent(context),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        // 组合年份和月份为最终的日期字符串
                        String finalDate = '';
                        if (year.isNotEmpty) {
                          finalDate = year;
                          if (month.isNotEmpty) {
                            finalDate = '$year-$month';
                          }
                        }
                        widget.onConfirm(tags, finalDate, _selectedRating.value);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )),
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
              onPressed: () {
                // 组合年份和月份为最终的日期字符串
                String finalDate = '';
                if (year.isNotEmpty) {
                  finalDate = year;
                  if (month.isNotEmpty) {
                    finalDate = '$year-$month';
                  }
                }
                widget.onConfirm(tags, finalDate, _selectedRating.value);
                Navigator.of(context).pop();
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

  // 构建页面内容
  Widget _buildPageContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentRatingSection(context),
          _buildYearSelectionSection(context),
          _buildMonthSelectionSection(context),
          _buildTagSelectionSection(context),
        ],
      ),
    );
  }

  // 构建内容评级部分
  Widget _buildContentRatingSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${t.search.contentRating}: ', style: const TextStyle(fontSize: 16)).paddingBottom(8),
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
        Text('${t.common.year}: ', style: const TextStyle(fontSize: 16)).paddingBottom(8),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch, // 触摸设备
              PointerDeviceKind.mouse, // 鼠标设备
            },
            scrollbars: true,
          ),
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _scrollController.jumpTo(
                  _scrollController.position.pixels +
                      pointerSignal.scrollDelta.dy,
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
        Text('${t.common.month}: ', style: const TextStyle(fontSize: 16)).paddingBottom(8),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch, // 触摸设备
              PointerDeviceKind.mouse, // 鼠标设备
            },
            scrollbars: true,
          ),
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _monthScrollController.jumpTo(
                  _monthScrollController.position.pixels +
                      pointerSignal.scrollDelta.dy,
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
                        onSelected: year.isEmpty ? null : (bool selected) {
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
                        onSelected: year.isEmpty ? null : (bool selected) {
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        return RemoveSearchTagDialog(
                          onRemoveIds: (List<String> removedTags) {
                            for (var id in removedTags) {
                              _userPreferenceService
                                  .removeVideoSearchTagById(id);
                            }
                            setState(() {
                              tags.removeWhere(
                                  (tag) => removedTags.contains(tag.id));
                            });
                          },
                          videoSearchTagHistory:
                              _userPreferenceService.videoSearchTagHistory,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        return const AddSearchTagDialog();
                      },
                    );
                  },
                ),
              ],
            )
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
                label: Text(tag.id),
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
        })
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
