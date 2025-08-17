import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_builder_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/app_service.dart';

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
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 800,
            minWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8, // 使用屏幕高度的80%作为最大高度
            minHeight: 400, // 设置最小高度
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 对话框标题和操作按钮
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '筛选项设置',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            // 直接关闭对话框，不检查未保存更改
                            AppService.tryPop();
                          },
                          child: Text(t.common.cancel),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // 保存筛选项并执行搜索
                            onFiltersChanged(tempFilters.map((f) => f.copyWith()).toList());
                            AppService.tryPop();
                          },
                          child: Text(t.common.confirm),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 筛选项生成器 - 使用 Flexible 而不是 Expanded 来更好地自适应
              Flexible(
                child: SingleChildScrollView(
                  child: FilterBuilderWidget(
                    initialSegment: currentSegment,
                    initialFilters: filters,
                    onFiltersChanged: (newFilters) {
                      // 缓存筛选项，不直接触发搜索
                      tempFilters = newFilters;
                    },
                    destroyOnClose: true,
                  ),
                ),
              ),
              
              // 底部间距
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
