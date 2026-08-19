import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 「header 悬浮在列表之上」的通用骨架。
///
/// - [body]：铺满整个区域的列表；调用方自己用 `paddingTop = headerExtent`
///   让出首屏位置（视口不能在外面套 Padding，否则内容滚不到 header 背后）。
/// - 顶部渐变蒙层从 0 覆盖到 [headerExtent] + [GlassTokens.headerFadeExtent]，
///   平台段为 [solidExtent]（一般是状态栏高度，没有状态栏传 0）。
/// - [header]：放在 [headerTop] 处的一行玻璃控件（可为 null，只要蒙层 + 留白）。
class GlassHeaderOverlay extends StatelessWidget {
  const GlassHeaderOverlay({
    super.key,
    required this.body,
    required this.headerExtent,
    this.header,
    this.headerTop = 0,
    this.headerHeight,
    this.solidExtent = 0,
    this.extra = const [],
  });

  final Widget body;

  /// 列表需要让出的总高度（从区域顶部到 header 行底部）。
  final double headerExtent;

  final Widget? header;

  /// header 行距区域顶部的距离。
  final double headerTop;

  /// header 行高度；为 null 时用 [GlassTokens.headerRowHeight]。
  final double? headerHeight;

  /// 蒙层平台段高度（状态栏）。
  final double solidExtent;

  /// 叠在最上层的其他元素（如浮钮、批量操作 FAB）。
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // 所有子项都是 Positioned；松约束下也要撑满，别被某个非 Positioned 的占位压成 0 高
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: body),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: EdgeFadeScrim.top(
            height: headerExtent + GlassTokens.headerFadeExtent,
            solidExtent: solidExtent,
          ),
        ),
        if (header != null)
          Positioned(
            top: headerTop,
            left: 0,
            right: 0,
            height: headerHeight ?? GlassTokens.headerRowHeight,
            child: header!,
          ),
        ...extra,
      ],
    );
  }
}
