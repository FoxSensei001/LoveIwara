import 'package:flutter/material.dart';

/// 只排一行的 Wrap：高度恒为一行，放不下的项整只落到第二行被裁掉，永不换行撑高。
///
/// 网格里的卡片要等高，一行胶囊（统计、标签、状态）就不能因为「这张卡胶囊多 /
/// 这一列窄」而折成两行；也不能因为「这张卡一颗胶囊都没有」而塌成 0 高。
/// 行高由 [placeholder] 撑出——传一颗与真实子项同款、同字号的胶囊（多种胶囊
/// 高度不同就用 Row 把它们并排放进来，取最高的那颗），它本身不可见。
class SingleRunWrap extends StatelessWidget {
  const SingleRunWrap({
    super.key,
    required this.placeholder,
    required this.children,
    this.spacing = 4,
  });

  /// 撑行高用的隐形样本（不绘制、不响应点击）。
  final Widget placeholder;

  final List<Widget> children;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Visibility.maintain(visible: false, child: placeholder),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Wrap(
            spacing: spacing,
            // 只有一行时竖直居中；溢出成两行时 Wrap 自己把剩余空间夹到 0，从顶排
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            clipBehavior: Clip.hardEdge,
            children: children,
          ),
        ),
      ],
    );
  }
}
