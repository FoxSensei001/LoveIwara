import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 通用空状态：一个灰色图标 +（可选）提示文案 +（可选）刷新入口。
///
/// [message] 默认为 null，即**只画图标**。这里原来的默认值是硬编码的英文
/// `'Empty'`，各页在自己的中文提示之上凭空多出一行英文（如分类管理页的
/// 「还没有分类，新建一个来整理你的下载。」上面顶着个 Empty）。需要文案的
/// 调用方自己传，想要通用文案可以传 `t.common.noData`。
class MyEmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final VoidCallback? onRefresh;
  final double? spacing;

  const MyEmptyWidget({
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined, // 默认使用inbox图标
    this.iconSize = 60,
    this.iconColor = Colors.grey,
    this.onRefresh,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double gap = spacing ?? 16;
    final bool hasIcon = icon != null;
    final bool hasMessage = message != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标部分
          if (hasIcon) Icon(icon, size: iconSize, color: iconColor),

          // 文字提示（不传就不占位，别再兜底一行英文）
          if (hasMessage) ...[
            if (hasIcon) SizedBox(height: gap),
            Text(
              message!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],

          // 刷新按钮
          if (onRefresh != null) ...[
            if (hasIcon || hasMessage) SizedBox(height: gap),
            TextButton(
              onPressed: onRefresh,
              child: Text(t.common.clickToRefresh),
            ),
          ],
        ],
      ),
    );
  }
}
