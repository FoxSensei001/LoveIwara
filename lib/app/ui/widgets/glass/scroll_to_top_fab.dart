import 'dart:async';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 全 App 的「有人正在滚动」信号。
///
/// 由 `main.dart` 根部那层 `NotificationListener<ScrollNotification>` 喂值：
/// 任何滚动容器一开始拖 / 惯性滑，就置真；滚动结束（`ScrollEndNotification`）
/// 后再静置 [settleDelay]，才翻回假。
///
/// # 为什么要有它（2026-09-08 真机实测）
///
/// 液态档下每一块**独立成层**的玻璃，每帧都是一次整屏 backdrop 采样 + 一趟
/// 模糊 + 一趟折射 shader。右下角那枚「回到顶部」浮钮正是这样一层，而它恰恰
/// **只在滚动时出现**——也就是恰好在光栅线程最紧的那几百毫秒里多压一层。
/// 论坛列表 120Hz 下：浮钮在场掉帧 23%，不在场 12%（raster p50 8.6 → 6.7ms）。
///
/// 滚动期间用户并不需要这枚钮（手正按在列表上），所以把它的出现时机改成
/// 「滚过一段 **且** 停下来了」：滑动中整只不建（[GlassReveal] 退场后不建
/// child），停下 [settleDelay] 后再浮现。观感上与 iOS 系统列表的浮层一致，
/// 性能上等于滚动期间少一层玻璃。
class ScrollActivityMonitor {
  ScrollActivityMonitor._();

  static final ScrollActivityMonitor instance = ScrollActivityMonitor._();

  /// 滚动结束后再等多久才算「停下来了」。太短会在两下惯性滑动之间闪一下，
  /// 太长会让浮钮显得迟钝；300ms 与系统列表浮层的口径接近。
  static const Duration settleDelay = Duration(milliseconds: 300);

  /// 是否有滚动容器正在滚动（含惯性滑动与静置等待）。
  final ValueNotifier<bool> scrolling = ValueNotifier<bool>(false);

  Timer? _settle;

  /// 挂到根部 `NotificationListener<ScrollNotification>.onNotification`。
  /// 永远返回 false：只旁听，不拦截。
  bool handle(ScrollNotification notification) {
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      _settle?.cancel();
      _settle = null;
      if (!scrolling.value) scrolling.value = true;
    } else if (notification is ScrollEndNotification) {
      _settle?.cancel();
      _settle = Timer(settleDelay, () {
        _settle = null;
        scrolling.value = false;
      });
    }
    return false;
  }
}

/// 右下角「回到顶部」浮钮的**唯一**实现。
///
/// 出场 / 退场走 [GlassReveal]（材质淡入 + 上滑），并在 [ScrollActivityMonitor]
/// 报告「正在滚动」时整只退场——理由见 [ScrollActivityMonitor]。调用点只管两件事：
/// 「滚过阈值了没」（[visible]）和「点了怎么办」（[onPressed]）。
///
/// ⛔ 别在页面里再手写 `GlassReveal + GlassIconButton(vertical_align_top)`：
/// 那样滚动期间的隐藏就漏掉了，性能与观感都会和其他页不一致。
class ScrollToTopFab extends StatelessWidget {
  const ScrollToTopFab({
    super.key,
    required this.visible,
    required this.onPressed,
    this.slideFrom = const Offset(0, 0.4),
  });

  /// 页面自己的判定（通常是「滚过 300px」）。
  final bool visible;

  final VoidCallback onPressed;

  /// 透传给 [GlassReveal.slideFrom]。
  final Offset slideFrom;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: ScrollActivityMonitor.instance.scrolling,
      builder: (context, scrolling, _) => GlassReveal(
        visible: visible && !scrolling,
        slideFrom: slideFrom,
        builder: (context, m) => GlassIconButton(
          materialize: m,
          standalone: true,
          icon: const Icon(Icons.vertical_align_top),
          tooltip: t.common.scrollToTop,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
