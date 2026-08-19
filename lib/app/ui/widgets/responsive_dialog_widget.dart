import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ResponsiveDialogWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final double? maxWidth;
  final double? minWidth;
  final double? maxHeightRatio;
  final VoidCallback? onClose;
  final List<Widget>? actions;
  final List<Widget>? headerActions;

  const ResponsiveDialogWidget({
    super.key,
    required this.title,
    required this.content,
    this.maxWidth = 600,
    this.minWidth = 400,
    this.maxHeightRatio = 0.8,
    this.onClose,
    this.actions,
    this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth > 600) {
      return _buildWideScreenDialog(context, screenHeight);
    } else {
      return _buildNarrowScreenDialog(context);
    }
  }

  Widget _buildWideScreenDialog(BuildContext context, double screenHeight) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 600,
          minWidth: minWidth ?? 400,
          maxHeight: screenHeight * (maxHeightRatio ?? 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(context),
              if (actions != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
              const SizedBox(height: 16),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  // 窄屏：整页展示，但头部不再用 AppBar，改为「标题 + 玻璃关闭圆钮」的
  // 新样式头行，与全局玻璃风格一致
  Widget _buildNarrowScreenDialog(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        // 底部让内容自己处理（与原 AppBar 版行为一致）
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (headerActions != null) ...[
                    ...headerActions!,
                    const SizedBox(width: 8),
                  ],
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    onPressed: onClose ?? () => AppService.tryPop(),
                  ),
                ],
              ),
            ),
            if (actions != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
            ],
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (headerActions != null) ...[
          ...headerActions!,
          const SizedBox(width: 8),
        ],
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose ?? () => AppService.tryPop(),
        ),
      ],
    );
  }
}

// 便捷方法，用于显示响应式对话框
class ResponsiveDialog {
  static void show({
    required BuildContext context,
    required String title,
    required Widget content,
    double? maxWidth,
    double? minWidth,
    double? maxHeightRatio,
    VoidCallback? onClose,
    List<Widget>? actions,
    List<Widget>? headerActions,
  }) {
    showAppDialog(
      ResponsiveDialogWidget(
        title: title,
        content: content,
        maxWidth: maxWidth,
        minWidth: minWidth,
        maxHeightRatio: maxHeightRatio,
        onClose: onClose,
        actions: actions,
        headerActions: headerActions,
      ),
    );
  }
}
