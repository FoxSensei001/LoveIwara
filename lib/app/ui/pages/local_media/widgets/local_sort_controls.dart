import 'package:flutter/material.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本机文件顶栏第二行右侧的排序控件。
///
/// 形态为两枚收进同一只 [GlassButtonGroup] 的小按钮：
///   - 方向钮：升序 / 降序单触翻转；
///   - 字段钮：点击弹出支持字段的单选菜单。
class LocalSortControls extends StatelessWidget {
  const LocalSortControls({
    super.key,
    required this.order,
    required this.fields,
    required this.onChanged,
  });

  final LocalMediaOrder order;
  final List<LocalMediaSortField> fields;
  final ValueChanged<LocalMediaOrder> onChanged;

  static String _labelForField(LocalMediaSortField field) {
    final b = slang.t.localMedia.browse;
    return switch (field) {
      LocalMediaSortField.name => b.sortFieldName,
      LocalMediaSortField.modified => b.sortFieldModified,
      LocalMediaSortField.duration => b.sortFieldDuration,
      LocalMediaSortField.size => b.sortFieldSize,
      LocalMediaSortField.resolution => b.sortFieldResolution,
      LocalMediaSortField.fileType => b.sortFieldFileType,
      LocalMediaSortField.fps => b.sortFieldFps,
      LocalMediaSortField.favorited => b.sortFieldFavorited,
      _ => field.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: Icon(
            order.ascending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
          ),
          tooltip: order.ascending
              ? slang.t.localMedia.browse.sortAscending
              : slang.t.localMedia.browse.sortDescending,
          onPressed: () {
            onChanged(
              LocalMediaOrder(order.field, ascending: !order.ascending),
            );
          },
        ),
        Builder(
          builder: (anchorContext) => GlassIconButton(
            icon: const Icon(Icons.sort),
            opensOverlay: true,
            tooltip: slang.t.localMedia.browse.sortBy,
            onPressed: () async {
              final picked = await showGlassMenu<LocalMediaSortField>(
                anchorContext: anchorContext,
                entries: [
                  for (final field in fields)
                    GlassMenuOption<LocalMediaSortField>(
                      value: field,
                      label: _labelForField(field),
                      selected: field == order.field,
                    ),
                ],
              );
              if (picked != null && picked != order.field) {
                onChanged(LocalMediaOrder(picked, ascending: order.ascending));
              }
            },
          ),
        ),
      ],
    );
  }
}
