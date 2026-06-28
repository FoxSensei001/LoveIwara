import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/download_category_manage_page.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 下载分类选择器（下载时选择目标分类，紧凑型用于对话框）。
///
/// - 已有分类：下拉（第一项「未分类」value=null，其余每个分类一项）+ 旁边齿轮管理入口。
/// - 没有任何分类：不隐藏，而是显示「管理分类」按钮，让用户在下载弹窗里就能新建/管理。
///   新建后通过 [DownloadService.categoriesChangedNotifier] 自动刷新出下拉。
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
  List<DownloadCategory>? _categories;
  Worker? _categoriesWorker;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // 在管理页新建/删除分类后，自动刷新选择器（无需关掉下载弹窗）。
    _categoriesWorker = ever(
      DownloadService.to.categoriesChangedNotifier,
      (_) => _loadCategories(),
    );
  }

  @override
  void dispose() {
    _categoriesWorker?.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DownloadService.to.getAllCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (e) {
      LogUtils.e('加载下载分类失败', tag: 'DownloadCategoryPicker', error: e);
      if (!mounted) return;
      setState(() => _categories = const []);
    }
  }

  void _openManage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DownloadCategoryManagePage()),
    );
    // 返回后由 categoriesChangedNotifier 触发 _loadCategories 刷新。
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    // 加载中：占位不显示，避免闪烁
    if (categories == null) {
      return const SizedBox.shrink();
    }

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
      builder: (context, setState) => AlertDialog(
        title: Text(t.download.category.label),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.download),
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
