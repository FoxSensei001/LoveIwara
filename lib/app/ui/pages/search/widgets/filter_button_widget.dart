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
            child: Stack(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (filters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        filters.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
            minWidth: 400,
            maxHeight: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 对话框标题和操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '筛选项设置',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => AppService.tryPop(),
                          child: Text(t.common.cancel),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => AppService.tryPop(),
                          child: Text(t.common.confirm),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 筛选项生成器
                Expanded(
                  child: SingleChildScrollView(
                    child: FilterBuilderWidget(
                      initialSegment: currentSegment,
                      initialFilters: filters,
                      onFiltersChanged: onFiltersChanged,
                    ),
                  ),
                ),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
