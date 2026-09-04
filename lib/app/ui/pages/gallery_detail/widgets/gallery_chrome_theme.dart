import 'package:flutter/material.dart';

/// 大图页上所有浮在画面之上的 chrome，一律按**深色**渲染。
///
/// # 为什么必须有这一层
///
/// 大图页恒定是一块黑底的媒体查看器，chrome 的内容一律是白的（顶栏那几枚钮从来
/// 就是 `Colors.white`）。而 `GlassSurface` 在 `material` / `plain` 两档下是拿
/// **主题**的表面色填底的——浅色主题下会填出一块近白的底：白图标当场消失，剩下
/// 一块「意义不明的灰白色方块」浮在黑画面上。把子树的 colorScheme 换成深色，
/// 四个材质档就都是「深底白字」。
///
/// # ⛔ 别再在各自的 `build` 里手抄一遍
///
/// 这条规矩此前在顶栏 / 控件条 / 正中控件 / 倍速牌里各写了一份
/// `Theme(data: base.copyWith(colorScheme: const ColorScheme.dark()))`，于是
/// 新加的件只要忘了抄，就会原样长出那块灰白底（图片页右下角那两枚小胶囊第一版
/// 正是如此，用户 2026-09-04 当场看出来了）。凡是摆进大图页 `Stack` 的东西，
/// 一律套这一只，不要再判断「我这件需不需要」。
class GalleryDarkChrome extends StatelessWidget {
  const GalleryDarkChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    // 深色主题下也照换：应用自己的深色 scheme 可能是带色相的（表面泛紫等），
    // 而这一层要的是中性深色，两档表现才一致。
    return Theme(
      data: base.copyWith(colorScheme: const ColorScheme.dark()),
      child: child,
    );
  }
}
