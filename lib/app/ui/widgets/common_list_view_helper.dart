import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 根据屏幕宽度计算每行显示几列
int calculateColumns(double availableWidth) {
  if (availableWidth > 1200) return 5;
  if (availableWidth > 900) return 4;
  if (availableWidth > 600) return 3;
  if (availableWidth > 300) return 2;
  return 1;
}

/// 通用加载更多指示器组件
Widget buildLoadMoreIndicator(BuildContext context, RxBool hasMore) {
  final t = slang.Translations.of(context);
  return Obx(() => hasMore.value
      ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              t.common.noMoreDatas,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ));
}

/// 通用空视图组件
Widget buildEmptyView({
  required BuildContext context,
  required IconData emptyIcon,
  required String noContentText,
  required VoidCallback onRefresh,
}) {
  final t = slang.Translations.of(context);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(emptyIcon, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      Text(
        noContentText,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: Text(t.common.refresh),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
} 