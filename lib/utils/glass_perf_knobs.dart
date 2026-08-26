/// 玻璃渲染的**运行时旋钮**，只给 `--dart-define=GLASS_PERF=1` 的基准包用。
///
/// # 为什么只剩「分层」这两个
///
/// 2026-08-24 在 OnePlus Pad（120Hz）上用 `tool/glass_bench.py` 把可疑项逐个
/// 关掉量了一遍，结论很干净：**画质档、跟手形变、渐进蒙层三项都在噪声里**
/// （premium → minimal 一共只省 0.3ms），唯一贵的是「一屏上有几层独立玻璃」
/// ——每层是一次 `BackdropGroup` + 一次 `BackdropFilterLayer`。所以那三个旋钮
/// 连同它们在生产代码里的分支一起撤掉了，只留下能改变层数的两个，将来回归时
/// 还能一键对照。完整读数见 `GlassChromeLayer` 的类注释。
///
/// **默认值一律等于生产行为**；常规包里 [apply] 整只短路（[benchBuild] 是
/// 编译期 false），旋钮永远停在默认值——这些字段是给基准跑归因的，不是运行时
/// 设置。
abstract final class GlassPerfKnobs {
  /// 基准包的编译期开关（`--dart-define=GLASS_PERF=1`）。
  ///
  /// 走 [String.fromEnvironment] 而不是 `bool.fromEnvironment`：后者只认字面量
  /// `"true"`，`GLASS_PERF=1` 会静默变成 false，编出来的包一条日志都没有。
  static const String _flag = String.fromEnvironment('GLASS_PERF');
  static const bool benchBuild = _flag == '1' || _flag == 'true';

  /// header 一行是否收进同一层融合（`GlassBlendGroup`）。生产值 true。
  static bool blend = true;

  /// `GlassChromeLayer` 是否把一簇 chrome 收进同一层。生产值 true；
  /// 关掉就退回「每块玻璃各占一层」的旧行为，用来量这项收口值多少毫秒。
  static bool chromeGroup = true;

  static bool apply(String name, String value) {
    if (!benchBuild) return false;
    switch (name) {
      case 'blend':
        blend = value == 'on';
        return true;
      case 'chromeGroup':
        chromeGroup = value == 'on';
        return true;
    }
    return false;
  }

  static String describe() => 'blend=$blend chromeGroup=$chromeGroup';
}
