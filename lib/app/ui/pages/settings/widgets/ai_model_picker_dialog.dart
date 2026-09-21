import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 从端点报上来的模型里挑要启用的那几条。
///
/// ⭐ **勾了就是勾了，没有「确定」**：每次勾选立刻经 [onChanged] 落下去。
/// 这张表是个开关清单不是一张表单——摆一枚确定钮等于多问一遍「你真的选了吗」，
/// 而且用户点了 X 关掉之后会以为刚才白选了。关闭就只是关闭。
///
/// ⛔ 不用 `showGlassMenu`：中转的 `/models` 动辄回来三五百条，玻璃菜单是给
/// 十条以内的动作用的，几百条塞进去既滚不动也搜不了。选择器弹窗（带搜索框、
/// 多选）才是这件事该有的形状——全站约定也是这么收口的
/// （`test/glass_style_guard_test.dart` 的「选择器弹窗一律走 GlassPickerDialog」）。
Future<void> showAiModelPicker(
  BuildContext context, {
  required List<String> available,
  required Set<String> selected,
  required ValueChanged<Set<String>> onChanged,
}) {
  return showAppDialog<void>(
    _AiModelPickerDialog(
      available: available,
      selected: selected,
      onChanged: onChanged,
    ),
  );
}

class _AiModelPickerDialog extends StatefulWidget {
  const _AiModelPickerDialog({
    required this.available,
    required this.selected,
    required this.onChanged,
  });

  final List<String> available;
  final Set<String> selected;

  /// 每次勾选／取消勾选都会收到**当前完整的**选中集合。
  ///
  /// ⭐ 给全集而不是给增量：调用方据此整体写一次，中途丢一条消息也能被下一次
  /// 纠正回来（见 `AiProviderDetailPage._applyModelSet`）。
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_AiModelPickerDialog> createState() => _AiModelPickerDialogState();
}

class _AiModelPickerDialogState extends State<_AiModelPickerDialog> {
  late final TextEditingController _searchController;
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = {...widget.selected};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.available;
    return widget.available.where((m) {
      if (m.toLowerCase().contains(query)) return true;
      // 目录里的**展示名**也要能搜：用户记得的多半是「Claude Sonnet 4」，
      // 而端点报上来的是 `claude-sonnet-4-5-20250929`。
      final name = AiCatalogService.modelOf(m)?.name;
      return name != null && name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final items = _filtered;

    return GlassPickerDialog(
      title: t.ai.fetchModels,
      rows: [
        GlassPickerRow.field(
          child: GlassPickerField(
            controller: _searchController,
            hintText: t.ai.searchModel,
            icon: Icons.search,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
      bodyBuilder: (context, headerExtent, footerExtent) => ListView.builder(
        padding: EdgeInsets.fromLTRB(
          GlassPickerDialog.hPadding,
          headerExtent,
          GlassPickerDialog.hPadding,
          16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final modelId = items[index];
          final catalog = AiCatalogService.modelOf(modelId);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _selected.contains(modelId),
            title: Text(
              catalog?.name ?? modelId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              modelId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: cs.onSurfaceVariant,
              ),
            ),
            onChanged: (checked) {
              setState(() {
                if (checked ?? false) {
                  _selected.add(modelId);
                } else {
                  _selected.remove(modelId);
                }
              });
              // 立刻落下去。⛔ 传一份**拷贝**：`_selected` 会被下一次勾选就地
              // 改掉，调用方拿着同一个引用去比对新旧就永远看不出差别。
              widget.onChanged({..._selected});
            },
          );
        },
      ),
    );
  }
}
