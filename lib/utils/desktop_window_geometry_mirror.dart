import 'dart:io';
import 'dart:ui' show Rect;

import 'package:i_iwara/common/constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 窗口几何的纯文本镜像：给**原生 runner** 在 Flutter 引擎存在之前读的。
///
/// # 为什么要这么一份
///
/// 几何本来就存在配置库（`ConfigKey.WINDOW_*`）里，但那是 sqlite，而需要它的
/// 时刻在 `FlutterViewController` 构造**之前**——那会儿 Dart 还没跑。让 runner
/// 自己开库、还得认得表结构，为了一个矩形把两边耦合到这个程度不值当。所以额外
/// 写一行纯文本：`x y 宽 高`，逻辑像素，和 `windowManager.setSize/setPosition`
/// 同一套单位。
///
/// # 为什么值得
///
/// 在 Dart 里摆窗口要花掉约 220 毫秒的白屏：那时 Flutter 视图已经建好，改尺寸
/// 会让引擎把渲染表面拆了重建。建窗口的时候就把尺寸给对，这笔钱是零——那时根本
/// 还没有表面。见 `windows/runner/window_geometry.cpp`。
///
/// # 写坏了会怎样
///
/// 不会怎样。runner 读到不合理的值（太小、太大、完全在所有屏幕之外）就当没有，
/// 退回默认尺寸；而 Dart 侧的 `fitStoredWindowRect` 照旧会对着当前屏幕再校一遍，
/// 真有出入就补一次 setSize/setPosition。镜像只是让常见情况少付一次重建。
abstract final class DesktopWindowGeometryMirror {
  static const String _fileName = 'window_geometry.txt';

  /// 本次启动 runner **实际建窗口时用的**矩形（由入口参数
  /// `--startup-window-geometry` 递进来）。非 Windows、或 runner 没给，就是 null。
  static Rect? appliedByRunner;

  /// 从 Dart 入口参数里捡出 runner 的回执。认不出来就当没有。
  static void adoptRunnerGeometry(List<String> args) {
    const prefix = '--startup-window-geometry=';
    for (final arg in args) {
      if (!arg.startsWith(prefix)) continue;
      final parts = arg.substring(prefix.length).split(',');
      if (parts.length != 4) return;
      final values = parts.map(double.tryParse).toList();
      if (values.any((v) => v == null)) return;
      appliedByRunner = Rect.fromLTWH(
        values[0]!,
        values[1]!,
        values[2]!,
        values[3]!,
      );
      return;
    }
  }

  /// 把当前几何写进镜像。失败一律咽掉：这只是一条启动快路，丢了无非是下次
  /// 启动多付一次 setSize。
  static Future<void> write(Rect rect) async {
    try {
      final file = File(await _resolvePath());
      await file.parent.create(recursive: true);
      await file.writeAsString(
        '${rect.left} ${rect.top} ${rect.width} ${rect.height}\n',
      );
    } catch (_) {}
  }

  /// 必须和 `windows/runner/window_geometry.cpp` 解析的位置一致：
  /// 文档目录下的 `<应用名>/window_geometry.txt`。
  static Future<String> _resolvePath() async {
    final documents = await getApplicationDocumentsDirectory();
    return p.join(
      documents.path,
      CommonConstants.applicationName ?? 'i_iwara',
      _fileName,
    );
  }
}
