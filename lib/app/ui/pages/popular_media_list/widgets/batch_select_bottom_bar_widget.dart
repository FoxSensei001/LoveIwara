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
          // 底部安全区交给外层 SafeArea 处理即可。原先这里又手动加了一次
          // MediaQuery.padding.bottom，而这个 context 取自 SafeArea 之上、
          // 拿到的是未被消费的原始值，等于把安全区算了两遍。
          // （之前看不出来，是因为 Shell 的 Scaffold 把 padding.bottom 抹成了 0。）
          padding: const EdgeInsets.all(16.0),
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
