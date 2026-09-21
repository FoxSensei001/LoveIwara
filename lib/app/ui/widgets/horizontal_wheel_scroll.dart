import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 让**鼠标滚轮**能拨动横向列表。
///
/// # 为什么需要它
///
/// Flutter 的 `Scrollable` 按自己的轴去取滚动量：横向那一支读的是
/// `event.scrollDelta.dx`，而滚轮给的是 `dy`（`dx` 恒 0，除非按住 Shift 或
/// 用触控板横划）。于是所有「摆不下就横着滚」的选项行 / 标签行 / 分段胶囊，
/// 鼠标用户**一格都拨不动**，被裁在后面的那几项永远点不到
/// （2026-09-21 用户报障：搜索页那条横向工具栏）。
///
/// # 为什么要走 [PointerSignalResolver]
///
/// 裸 `Listener(onPointerSignal:)` 在事件派发时**直接**被调用，不经过解析器；
/// 而身下那张竖向列表是把自己注册进解析器的。两边互不知情的话，鼠标划过这一
/// 条行时**横向和竖向会同时滚**——看上去就是「一碰就乱跑」。
///
/// 这里的做法：只有当这条横向列表**真的还能往那个方向动**时才去注册（派发顺
/// 序是由内向外，所以我们一定先于外层那张竖向列表登记，解析器认第一个）。
/// 已经拨到头了就**不注册**，滚轮照常冒泡给外面那张竖向列表——于是「先把这
/// 行拨到底、再接着滚页面」是连贯的一串，而不是划过这行整页就卡住。
///
/// # 用法
///
/// 包在横向可滚组件外面，控制器传同一只：
///
/// ```dart
/// HorizontalWheelScroll(
///   controller: _scroll,
///   child: ListView(controller: _scroll, scrollDirection: Axis.horizontal, ...),
/// )
/// ```
///
/// ⛔ 图库看图那几处横向列表**不要**接：它们的滚轮另有含义（翻图 / 缩放），
/// 见 `horizontial_image_list.dart` 与 `my_gallery_photo_view_wrapper.dart`。
class HorizontalWheelScroll extends StatelessWidget {
  const HorizontalWheelScroll({
    super.key,
    required this.controller,
    required this.child,
    this.speed = 1.0,
  });

  /// 必须与 [child] 那只可滚组件是同一个控制器。
  final ScrollController controller;

  final Widget child;

  /// 一格滚轮走多远的倍率。默认 1.0 ＝ 与竖向列表同步长。
  final double speed;

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!controller.hasClients) return;
    // 触控板横划 / Shift+滚轮给的本来就是 dx，那条路 Scrollable 自己处理得了，
    // 我们插手只会把步长加倍。
    if (event.scrollDelta.dx != 0) return;
    final double delta = event.scrollDelta.dy * speed;
    if (delta == 0) return;

    final ScrollPosition position = controller.position;
    final double target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    // 已经到头：不认领，让它冒泡出去滚页面。
    if ((target - position.pixels).abs() < 0.5) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      // 解析是在本帧派发完之后才发生的，中途可能已经被拆掉了。
      if (!controller.hasClients) return;
      controller.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerSignal: _handlePointerSignal, child: child);
  }
}
