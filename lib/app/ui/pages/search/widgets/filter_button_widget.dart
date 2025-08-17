import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_builder_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/responsive_dialog_widget.dart';

class FilterButtonWidget extends StatelessWidget {
  final SearchSegment currentSegment;
  final List<Filter> filters;
  final Function(List<Filter>) onFiltersChanged;
  final double height;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;

  const FilterButtonWidget({
    super.key,
    required this.currentSegment,
    required this.filters,
    required this.onFiltersChanged,
    this.height = 44,
    this.margin,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    // 如果是 oreno3d，不显示筛选项按钮
    if (currentSegment == SearchSegment.oreno3d) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(left: 4),
      height: height,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        elevation: elevation ?? 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showFilterDialog(context),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Badge.count(
              count: filters.length,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.filter_list,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    List<Filter> tempFilters = filters.map((f) => f.copyWith()).toList();
    
    ResponsiveDialog.show(
      context: context,
      title: '筛选项设置',
      maxWidth: 800,
      headerActions: [
        ElevatedButton(
          onPressed: () {
            // 保存筛选项并执行搜索
            onFiltersChanged(tempFilters.map((f) => f.copyWith()).toList());
            AppService.tryPop();
          },
          child: Text(t.common.confirm),
        ),
      ],
      content: FilterBuilderWidget(
        initialSegment: currentSegment,
        initialFilters: filters,
        onFiltersChanged: (newFilters) {
          // 缓存筛选项，不直接触发搜索
          tempFilters = newFilters;
        },
        destroyOnClose: true,
      ),
    );
  }
}
