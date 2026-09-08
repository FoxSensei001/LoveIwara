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

  /// 每块（或每个融合层）玻璃画几层投影（`GlassTokens.widgetsShadow`）。
  /// 生产值 2：接触影 + 环境影。包里每层影子＝一次 saveLayer + 一趟几何蒙版模糊。
  static int shadows = 2;

  /// 折射 shader 之前那趟独立的高斯模糊 backdrop 层（包默认 sigma 5）。
  /// 生产值 true；关掉后每块玻璃少一次整屏 resolve，但磨砂感只剩 shader 内置那点。
  static bool blur = true;

  /// 独立模糊层的 sigma（包默认 5）。只在 [blur] 为 true 时有意义。
  static double blurSigma = 5;

  /// 浮动底栏是否走液态档（false = 液态档下也用 Material 那份自绘导航栏），
  /// 用来单独量底栏那几层值多少毫秒。生产值 true。
  static bool liquidBar = true;

  /// 回到顶部浮钮是否允许出现，用来量它那一层值多少毫秒。生产值 true。
  static bool fab = true;

  /// chrome 画质：false 时 [chromeGlassQuality] 落到 standard（轻量单 pass shader，
  /// 无融合、无 SDF 影子）。生产值 true。
  static bool premium = true;

  /// 浮动底栏那层玻璃自己的独立模糊 pass（不影响 header）。生产值 true。
  static bool barBlur = true;

  /// **单块**玻璃（不在融合层里的：回顶浮钮、角落坞、弹窗里的键）的独立
  /// 模糊 pass。生产值 true。
  static bool soloBlur = true;

  /// 底栏选中指示器的材质：`full`＝跟栏同一份玻璃（模糊 + 折射各一趟）、
  /// `noblur`＝只折射、`flat`＝零厚度零模糊（包的快速路径，纯色块）。生产值 full。
  static String indicator = 'full';

  /// header 融合层（[GlassBlendGroup]）自己的独立模糊 pass。生产值 true。
  static bool headerBlur = true;

  /// header 内容感知取色（滚动期间每 180ms 一次 `toImage` 回读）。生产值 true。
  static bool contentAware = true;

  /// chrome 玻璃色调的 alpha 覆盖（浅色档），为 null 时用 `GlassTokens.widgetsTint`
  /// 的生产值。用来试「去掉模糊后靠色调补磨砂感」几档的观感。
  static double? tintAlpha;

  /// 底栏「魔法镜头」遮罩：`high`＝双层渲染 + 果冻裁剪，`off`＝只换图标色。
  /// 生产值 high。
  static String mask = 'high';

  static bool apply(String name, String value) {
    if (!benchBuild) return false;
    switch (name) {
      case 'blend':
        blend = value == 'on';
        return true;
      case 'chromeGroup':
        chromeGroup = value == 'on';
        return true;
      case 'shadows':
        final int? n = int.tryParse(value);
        if (n == null || n < 0 || n > 2) return false;
        shadows = n;
        return true;
      case 'blur':
        if (value == 'on' || value == 'off') {
          blur = value == 'on';
          if (blur) blurSigma = 5;
          return true;
        }
        final double? sigma = double.tryParse(value);
        if (sigma == null || sigma < 0) return false;
        blur = sigma > 0;
        blurSigma = sigma;
        return true;
      case 'bar':
        if (value != 'liquid' && value != 'material') return false;
        liquidBar = value == 'liquid';
        return true;
      case 'fab':
        fab = value == 'on';
        return true;
      case 'quality':
        if (value != 'premium' && value != 'standard') return false;
        premium = value == 'premium';
        return true;
      case 'barBlur':
        barBlur = value == 'on';
        return true;
      case 'soloBlur':
        soloBlur = value == 'on';
        return true;
      case 'indicator':
        if (value != 'full' && value != 'noblur' && value != 'flat') {
          return false;
        }
        indicator = value;
        return true;
      case 'headerBlur':
        headerBlur = value == 'on';
        return true;
      case 'contentAware':
        contentAware = value == 'on';
        return true;
      case 'tint':
        if (value == 'off') {
          tintAlpha = null;
          return true;
        }
        final double? a = double.tryParse(value);
        if (a == null || a < 0 || a > 1) return false;
        tintAlpha = a;
        return true;
      case 'mask':
        if (value != 'high' && value != 'off') return false;
        mask = value;
        return true;
    }
    return false;
  }

  static String describe() =>
      'blend=$blend chromeGroup=$chromeGroup shadows=$shadows blur=$blur '
      'sigma=$blurSigma premium=$premium liquidBar=$liquidBar fab=$fab '
      'barBlur=$barBlur soloBlur=$soloBlur indicator=$indicator mask=$mask '
      'headerBlur=$headerBlur contentAware=$contentAware tint=$tintAlpha';
}
