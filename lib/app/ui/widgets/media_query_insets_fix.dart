import 'dart:math' as math;

import 'package:flutter/widgets.dart';

double computeBottomSafeInset(MediaQueryData mq) {
  return math.max(
    mq.padding.bottom,
    math.max(mq.viewPadding.bottom, mq.systemGestureInsets.bottom),
  );
}

/// 底部弹窗（`showModalBottomSheet`）内容区应当自己让出的底部空间。
///
/// 两件事都得弹窗内容自己做：
/// - `showModalBottomSheet` 的 `useSafeArea` 只挡上/左/右（源码里是
///   `SafeArea(bottom: false)`），底部安全区从来不管；
/// - 键盘则相反：根布局 [MyAppLayout] 是一个 `resizeToAvoidBottomInset` 的
///   Scaffold，整棵 Navigator（含所有弹窗路由）已经被整体抬到键盘之上，而且
///   `viewInsets.bottom` 在 Scaffold 之下会被抹成 0。所以键盘可见时不能再叠
///   安全区，否则输入框和键盘之间会多出一条导航条高度的空隙。
///
/// ⛔ 这段内边距必须让在**弹层自己的背景里面**（画背景那个
/// `Material`/`Container` 的 `padding`，或它内部内容/列表的 `padding.bottom`），
/// 不能在弹层外面套一层 `Padding` 把整块弹层往上抬：抬上去之后背景只铺到
/// 导航条上沿，导航条那条带就只剩弹层遮罩，看起来像「弹层先隔了一条安全区
/// 才出现」。收口示例见 `GlassBottomSheet` / `GlassDraggableBottomSheet`。
double computeSheetBottomInset(BuildContext context) {
  final mq = MediaQuery.of(context);
  // 根 Scaffold 抹掉了 viewInsets，所以键盘是否可见要看未经处理的原始值。
  final rawKeyboardInset =
      RawMediaQueryDataScope.maybeOf(context)?.rawData.viewInsets.bottom ?? 0.0;
  if (math.max(mq.viewInsets.bottom, rawKeyboardInset) > 0) {
    // 键盘可见：只让出本层还能看到的键盘高度（外层已整体上抬时它就是 0）。
    return mq.viewInsets.bottom;
  }
  return computeBottomSafeInset(mq);
}

class RawMediaQueryDataScope extends InheritedWidget {
  final MediaQueryData rawData;

  const RawMediaQueryDataScope({
    super.key,
    required this.rawData,
    required super.child,
  });

  static RawMediaQueryDataScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RawMediaQueryDataScope>();
  }

  @override
  bool updateShouldNotify(RawMediaQueryDataScope oldWidget) {
    return rawData != oldWidget.rawData;
  }
}

/// Fixes `MediaQuery.padding.bottom` in edge-to-edge environments where it may be
/// `0`, while `systemGestureInsets.bottom` is non-zero.
///
/// This helps `SafeArea(bottom: true)` and existing `MediaQuery.padding.bottom`
/// call sites behave as expected without rewriting every usage site.
class ApplyFixedMediaQueryInsets extends StatelessWidget {
  final Widget child;

  const ApplyFixedMediaQueryInsets({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final rawMq = MediaQuery.of(context);
    final fixedBottom = computeBottomSafeInset(rawMq);
    final fixedMq = rawMq.copyWith(
      padding: rawMq.padding.copyWith(bottom: fixedBottom),
    );

    return RawMediaQueryDataScope(
      rawData: rawMq,
      child: MediaQuery(data: fixedMq, child: child),
    );
  }
}

/// Restores the raw (unfixed) `MediaQueryData` captured by
/// [ApplyFixedMediaQueryInsets].
///
/// Intended for immersive/fullscreen pages that want to keep the previous
/// behavior (e.g. allow bottom overlays to reach the very bottom).
class RestoreRawMediaQueryInsets extends StatelessWidget {
  final Widget child;

  const RestoreRawMediaQueryInsets({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final rawScope = RawMediaQueryDataScope.maybeOf(context);
    if (rawScope == null) return child;
    return MediaQuery(data: rawScope.rawData, child: child);
  }
}
