import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:i_iwara/utils/logger_utils.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// 把上次存下的窗口矩形放回某块屏幕的可见区里。
///
/// 存下来的几何可能已经不适合这一次：上次是全屏 / 最大化时关的（存成了整块
/// 屏幕的尺寸）、外接显示器拔掉了、分辨率改小了。照原样摆回去，窗口就会一半
/// 在屏幕外、标题栏都够不着。这里只做三件事：
///
/// 1. 选重叠面积最大的那块屏幕（一点都不重叠就用主屏）；
/// 2. 比那块屏幕的可见区（扣掉菜单栏 / 程序坞 / 任务栏）还大的，是全屏时存下
///    的，改成可见区的八成居中；
/// 3. 位置夹进可见区；原本完全不在任何屏幕上的，改为在主屏居中。
///
/// 纯函数，方便测；取屏幕信息的异步部分见 [fitStoredWindowRect]。
Rect fitWindowRect(
  Rect stored, {
  required List<Rect> visibleAreas,
  required Rect primary,
  Size minSize = const Size(200, 200),
}) {
  Rect? best;
  var bestOverlap = 0.0;
  for (final area in visibleAreas) {
    final overlap = area.intersect(stored);
    if (overlap.width <= 0 || overlap.height <= 0) continue;
    final value = overlap.width * overlap.height;
    if (value > bestOverlap) {
      bestOverlap = value;
      best = area;
    }
  }
  final screen = best ?? primary;

  // 比可见区还大的窗口不可能是用户拖出来的（系统不让普通窗口盖住菜单栏 /
  // 程序坞），只能是全屏时存下来的整块屏幕。夹成「铺满可见区」也不是用户要的
  // 窗口，改成可见区的八成、居中。
  if (stored.width > screen.width + 1 || stored.height > screen.height + 1) {
    return Rect.fromCenter(
      center: screen.center,
      width: math.max(minSize.width, screen.width * 0.8),
      height: math.max(minSize.height, screen.height * 0.8),
    );
  }

  final width = math.max(minSize.width, math.min(stored.width, screen.width));
  final height = math.max(
    minSize.height,
    math.min(stored.height, screen.height),
  );

  if (best == null) {
    return Rect.fromCenter(center: screen.center, width: width, height: height);
  }
  final left = stored.left
      .clamp(screen.left, math.max(screen.left, screen.right - width))
      .toDouble();
  final top = stored.top
      .clamp(screen.top, math.max(screen.top, screen.bottom - height))
      .toDouble();
  return Rect.fromLTWH(left, top, width, height);
}

/// [fitWindowRect] 的外壳：向系统要各块屏幕的可见区。拿不到就原样返回，
/// 行为与从前一致。
Future<Rect> fitStoredWindowRect(Rect stored) async {
  try {
    Rect visible(Display d) =>
        (d.visiblePosition ?? Offset.zero) & (d.visibleSize ?? d.size);
    final displays = await screenRetriever.getAllDisplays();
    final primary = await screenRetriever.getPrimaryDisplay();
    return fitWindowRect(
      stored,
      visibleAreas: [for (final d in displays) visible(d)],
      primary: visible(primary),
    );
  } catch (e) {
    LogUtils.w('读取屏幕信息失败，按存储值恢复窗口: $e', '桌面初始化');
    return stored;
  }
}
