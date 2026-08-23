import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_category_manage_page.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 跳转到「管理分类」页面。下载分类选择器、下载清晰度弹窗、"更多"菜单里的
/// 快捷入口都跳到同一个页面，统一在这里维护导航方式，避免各处各写一份。
void openDownloadCategoryManagePage(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const DownloadCategoryManagePage()));
}

/// 下载分类选择器（下载时选择目标分类，紧凑型用于对话框）。
///
/// - 已有分类：下拉（第一项「未分类」value=null，其余每个分类一项）+ 旁边齿轮管理入口。
/// - 没有任何分类：不隐藏，而是显示「管理分类」按钮，让用户在下载弹窗里就能新建/管理。
///   新建后通过 [DownloadService.categories] 这个可观察状态自动刷新出下拉。
class DownloadCategoryPicker extends StatefulWidget {
  /// 当前选中的分类 ID；null 表示未分类。
  final String? value;

  /// 选择变化回调；null 表示未分类。
  final ValueChanged<String?> onChanged;

  const DownloadCategoryPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DownloadCategoryPicker> createState() => _DownloadCategoryPickerState();
}

class _DownloadCategoryPickerState extends State<DownloadCategoryPicker> {
  void _openManage() {
    openDownloadCategoryManagePage(context);
    // 返回后无需做任何事：下面是 Obx 读服务里的分类状态，新建的分类当场就在。
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildPicker(context, DownloadService.to.categories));
  }

  Widget _buildPicker(BuildContext context, List<DownloadCategory> categories) {
    final isEmpty = categories.isEmpty;

    // 选中的 ID 已不存在时回退为未分类，避免 Dropdown 断言失败。
    final validValue =
        widget.value != null && categories.any((c) => c.id == widget.value)
        ? widget.value
        : null;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            // 以「分类集合 + 当前值」为 key：分类增删时重建并按 validValue 重新播种，
            // 防止内部仍持有已删除的旧值导致 Dropdown 断言。
            key: ValueKey(
              '${categories.map((c) => c.id).join(',')}|$validValue',
            ),
            initialValue: validValue,
            isDense: true,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: t.download.category.label,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(t.download.category.uncategorized),
              ),
              ...categories.map(
                (c) => DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text(c.title, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: widget.onChanged,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(isEmpty ? Icons.add : Icons.settings_outlined),
          tooltip: t.download.category.manageTitle,
          visualDensity: VisualDensity.compact,
          onPressed: _openManage,
        ),
      ],
    );
  }
}

/// 弹出「选择下载分类」对话框（用于无清晰度选择的下载，如整本图库）。
///
/// 始终弹出（即使没有分类，选择器也会显示「未分类」占位 + 新建入口）。
/// - 用户确认 → 持久化所选分类为下次默认，返回 (confirmed: true, categoryId)。
/// - 用户取消 → 返回 (confirmed: false, categoryId: null)。
Future<({bool confirmed, String? categoryId})> showDownloadCategoryDialog(
  BuildContext context,
) async {
  final configService = Get.find<ConfigService>();
  final last = configService[ConfigKey.LAST_DOWNLOAD_CATEGORY_ID] as String?;
  String? selected = (last == null || last.isEmpty) ? null : last;

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => GlassAlertDialog(
        title: t.download.category.label,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DownloadCategoryPicker(
                value: selected,
                onChanged: (value) => setState(() => selected = value),
              ),
            ],
          ),
        ),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          GlassDialogAction(
            label: t.common.download,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ),
  );

  if (ok != true) return (confirmed: false, categoryId: null);
  configService.setSetting(ConfigKey.LAST_DOWNLOAD_CATEGORY_ID, selected ?? '');
  return (
    confirmed: true,
    categoryId: (selected?.isEmpty ?? true) ? null : selected,
  );
}
