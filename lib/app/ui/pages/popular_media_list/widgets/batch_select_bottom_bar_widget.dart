import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 批量选择底部操作栏组件
class BatchSelectBottomBarWidget extends StatelessWidget {
  /// 是否处于多选模式
  final bool isMultiSelect;

  /// 已选择的数量
  final int selectedCount;

  /// 退出多选模式回调
  final VoidCallback onExitMultiSelect;

  /// 下载按钮点击回调
  final VoidCallback onDownload;

  const BatchSelectBottomBarWidget({
    super.key,
    required this.isMultiSelect,
    required this.selectedCount,
    required this.onExitMultiSelect,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    if (!isMultiSelect) {
      return const SizedBox.shrink();
    }

    return BottomSheet(
      enableDrag: false,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      onClosing: () {},
      builder: (context) => SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom:
                16.0 +
                MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    t.common.selectedRecords(num: selectedCount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onExitMultiSelect,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.exitEditMode,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: selectedCount == 0 ? null : onDownload,
                      icon: const Icon(Icons.download),
                      label: Text(t.download.download),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
