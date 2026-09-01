import 'package:flutter/material.dart';

/// 给「活在路由树**外面**」的整屏图层配一只自己的 Navigator（因而也有 Overlay）。
///
/// # 为什么需要它
///
/// `MaterialApp.router` 的 `builder` 收到的 `child` 就是 GoRouter 的 Navigator。
/// 想让某一层盖住**所有**页面（含根 Navigator 上的弹窗），只能把它放在 builder 里
/// 的 Stack 上、和 `child` 做兄弟：
///
/// ```dart
/// Stack(children: [
///   Scaffold(body: ...widget.child...),   // ← 整棵路由树
///   if (locked) const Positioned.fill(child: AppLockScreen()),  // ← 兄弟层
/// ])
/// ```
///
/// 代价是这一层的子树里**没有 Navigator、也没有真正的 Overlay 祖先**。
///
/// ⚠️ 历史坑（已随 oktoast 一起移除，留档避免重蹈）：当年 toast 宿主是
/// `OKToast`，而它 vendored 了一整套同名的 `Overlay` / `Theatre` /
/// `RenderTheatre`（`oktoast-3.4.0/lib/src/core/toast.dart:7` 把 flutter 的
/// `Overlay` hide 掉再自建）。`debugCheckHasOverlay` 用
/// `findAncestorWidgetOfExactType<Overlay>` 比的是 **package:flutter 那个精确
/// 类型**，同名不同库＝不同 Type 命中不了，而 `describeMissingAncestor` 打印的
/// 只是简单类名——于是断言一边说 "No Overlay widget found."，一边在祖先列表里
/// 赫然列出一层 `Overlay`，看起来自相矛盾。现在宿主换成了 toastification
/// （`app_toast.dart`），它直接用根 Navigator 自己的 Overlay，不再有影子类型；
/// 但**本图层依旧没有 Overlay 祖先**，下面那些后果一条都没少。
///
/// 于是：
///
///   - 里面的 `TextField` 一旦要建选择浮层（选中变化、退格、长按弹粘贴条、
///     放大镜），`SelectionOverlay` 的 `assert(debugCheckHasOverlay(context))`
///     直接炸。更麻烦的是它炸在 `EditableTextState._formatAndSetValue`
///     **中途**，而那段 `beginBatchEdit()` / `endBatchEdit()` 之间没有
///     try/finally：异常穿出去时 `_batchEditDepth` 漏在 1，此后
///     `_updateRemoteEditingValueIfNeeded()` 一路早退，`setEditingState`
///     发不出去。于是 `controller.clear()` 只清掉了 Dart 这一侧，平台输入法
///     还攥着上一串 PIN；用户下一次敲键，输入法把整串旧内容回灌回来——
///     obscure 下的圆点数恒等于 `_value.text.length`，屏幕上就是「刚清空，
///     一敲就冒出一整排圆点」（2026-08-26 真机报障；圆点数等于**上次输入的
///     长度**，不是 maxLength）。重新聚焦 / 键盘重开会让连接重建从而复位，
///     所以它表现为时好时坏，更难查。
///   - 里面调 `showAppDialog` 走的是根 Navigator，弹窗会挂进 `child` 那棵树，
///     也就是**画在本图层下面**——用户看不见也点不到，而返回键此时又被
///     `PopCoordinator` 吃掉，等于把人卡在一条永远关不掉的模态路由上。
///
/// 包一层 [DetachedNavigatorHost] 就都解决了：它自带的 Navigator 提供 Overlay，
/// 本图层内部的弹窗只要传 `useRootNavigator: false` + 本 builder 给的 context，
/// 就会落在这只 Navigator 上，画在图层**之上**。
///
/// # 用法
///
/// ```dart
/// DetachedNavigatorHost(
///   builder: (context) => Material(child: ...),   // ← 这个 context 在内部 Navigator 之下
/// )
/// ```
///
/// [builder] 拿到的 `context` 是**路由内部**的 context，务必用它去开弹窗；
/// 用外层 State 的 `context` 找不到这只 Navigator（它是在 build 里才创建的）。
///
/// # 为什么要 [HeroControllerScope.none]
///
/// `MaterialApp` 往下供了一只 `HeroController`，而同一只 HeroController 不能被
/// 两个 Navigator 共用（框架会抛 "A HeroController can not be shared by multiple
/// Navigators"）。本图层不需要 Hero 动画，直接断掉这条继承即可。
class DetachedNavigatorHost extends StatelessWidget {
  const DetachedNavigatorHost({super.key, required this.builder});

  /// 图层内容。参数 `context` 位于内部 Navigator 之下，开弹窗要用它。
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope.none(
      child: Navigator(
        // 这只 Navigator 不参与应用的路由体系，别让它去更新引擎的路由状态
        // （否则系统「最近任务」里的路由名会被这一层顶掉）。
        reportsRouteUpdateToEngine: false,
        onGenerateRoute: (settings) => PageRouteBuilder<void>(
          settings: settings,
          // 图层自身的出入场由调用方决定，这里不要再叠一层过渡。
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, _) => builder(context),
        ),
      ),
    );
  }
}
