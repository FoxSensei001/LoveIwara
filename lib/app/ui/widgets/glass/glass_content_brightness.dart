import 'package:flutter/material.dart';
// 带前缀：两个玻璃包的公开面与本仓库自己的组件大面积重名（见
// `liquid_glass_material.dart` 顶部那段说明），不加前缀会一片 ambiguous_import。
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 「内容感知字色」：浮在滚动内容之上的玻璃 chrome，按**身后真正画着什么**
/// 决定自己用深字还是浅字，而不是一律跟着主题的明暗走。
///
/// # 解决的是哪个问题
///
/// 玻璃是半透明的，身后是什么色就透出什么色；而我们全站的字色 / 图标色都取自
/// `Theme.of(context).colorScheme`——它只知道**主题**是亮是暗，不知道此刻这块
/// 玻璃底下压着的是一张纯黑封面还是一张白底列表。浅色主题下滚过一张深色大图，
/// header 上的深色图标就糊在里面看不见了。iOS 26 的系统栏正是靠内容感知躲开
/// 这件事。
///
/// # 机制
///
/// `liquid_glass_widgets` 提供了整套采样与投票（[lgw.GlassContentAwareScope]）：
/// 把被采样区降采样截一张图，把控件自己的矩形映射进去切成网格，每格按 **WCAG
/// 对比度**投票「深字还是浅字读得清」，再加粘滞平局 + 双阈值迟滞防抖；采样由
/// 滚动驱动，静止时零开销。
///
/// 本文件只做三件包里没有的事：
///
/// 1. **把三个部件收成本仓库的词汇**（[GlassContentAwareHost] /
///    [GlassSampledContent] / [GlassAdaptiveChrome]），页面不必直接摸包。
/// 2. **在非液态档整只透传**：Material 档下 chrome 是不透明的面，身后什么色
///    都透不过来，采样纯属白烧 GPU。
/// 3. ⭐**把判决落到我们自己的颜色上**。包只会换它自己的 `GlassTheme` 变体和
///    它自建控件的默认字色——而我们所有玻璃的颜色都来自 `ColorScheme`，且大多
///    是调用点**显式**传给包的（`selectedIconColor: cs.primary` 之类，包里是
///    `widget.selectedIconColor ?? dynamicLabelColor`，显式值直接吃掉动态色）。
///    所以 [GlassAdaptiveChrome] 换的是**整个子树的 `ColorScheme`**：判决翻面
///    时把配色整体插值到反档，字色、图标色、玻璃底色（`GlassTokens` 也是按
///    `cs.brightness` 取的）在同一段过渡里一起走，调用点一行都不用改。
///
/// # 用法（三件套缺一不可）
///
/// ```dart
/// GlassContentAwareHost(          // ① 页面级采样器
///   child: Stack(children: [
///     GlassSampledContent(        // ② 被采样的那块：滚动内容 + 蒙层
///       child: listView,
///     ),
///     Positioned(                 // ③ chrome 必须在被采样区**外面**
///       child: GlassAdaptiveChrome(child: header),
///     ),
///   ]),
/// )
/// ```
///
/// chrome 一旦进了 [GlassSampledContent]，采样就会拍到它自己：判决改了底色、
/// 底色又改了下一次采样的读数，来回自激。
///
/// # ⛔ 几条硬限制
///
/// - **一个 host 只能有一个 [GlassSampledContent]**（包里有 assert）。同一棵
///   子树里并存多个被采样区（例如 `TabBarView` 里每个 tab 各有一个 header）
///   必须各自套自己的 host。
/// - **PlatformView 拍不到**：播放器那层玻璃身后是原生 view，`toImage` 读回来
///   是空的。那种地方要么别开，要么走包的 `brightnessOverride` 自己喂判决。
/// - **采样是整块被采样区的 `toImage` 回读**，滚动期间每 [defaultSampleInterval]
///   一次。被采样区越大越贵——所以 host 应该尽量贴着「真正在滚的那块」放。
class GlassContentAwareHost extends StatelessWidget {
  const GlassContentAwareHost({
    super.key,
    required this.child,
    this.sampleInterval = defaultSampleInterval,
  });

  /// 滚动期间两次采样的最小间隔。滚动停下即停采，静止不花钱。
  static const Duration defaultSampleInterval = Duration(milliseconds: 180);

  final Widget child;
  final Duration sampleInterval;

  @override
  Widget build(BuildContext context) {
    // 非液态档：chrome 是不透明的面，没有「身后透出来的颜色」可言。整只透传，
    // 连 scope 都不建——[GlassAdaptiveChrome] 找不到 host 时也会原样透传，
    // 于是整条链自动归零。
    if (!GlassMaterialScope.isLiquid(context)) return child;
    return lgw.GlassContentAwareScope(
      sampleInterval: sampleInterval,
      child: child,
    );
  }
}

/// 标记「被采样的那块内容」——滚动列表本体，以及压在它上面、chrome 之下的
/// 蒙层。
///
/// # 为什么蒙层也要算进来
///
/// 包自己的示例是只包滚动内容、把 header 的渐变蒙层排除在外。我们不能照抄：
/// `EdgeFadeScrim` 是一层**实打实的 `cs.surface` 面纱**，header 那一行底下的
/// 内容已经被它提亮/压暗过了。只采原始内容会把身后判得比肉眼看到的更深，浅色
/// 主题下滚过深色图时会误翻成浅字，反而更糊。
///
/// 蒙层不构成自激：它的颜色取自**页面**的环境主题，而 [GlassAdaptiveChrome]
/// 只换 chrome 自己那一小块子树的配色，动不到它。
class GlassSampledContent extends StatelessWidget {
  const GlassSampledContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!GlassMaterialScope.isLiquid(context)) return child;
    return lgw.GlassContentAwareContent(child: child);
  }
}

/// 一块跟着身后内容换配色的 chrome。
///
/// 必须待在 [GlassContentAwareHost] 里、且在 [GlassSampledContent] **外面**；
/// 找不到 host 时原样透传（不采样、不改色），所以随手包上是安全的。
///
/// [gridColumns] × [gridRows] 是这块 chrome 自己的投票格子数：整条横栏用默认的
/// 6×1，方形小钮该用 2×2。
class GlassAdaptiveChrome extends StatelessWidget {
  const GlassAdaptiveChrome({
    super.key,
    required this.child,
    this.gridColumns = 6,
    this.gridRows = 1,
    this.debugLabel = 'chrome',
  });

  final Widget child;
  final int gridColumns;
  final int gridRows;

  /// 只出现在判决翻面的那行日志里，用来分辨是哪块 chrome 翻的。
  final String debugLabel;

  @override
  Widget build(BuildContext context) {
    if (!GlassMaterialScope.isLiquid(context)) return child;
    // 外面已经有一块 chrome 在按内容换色了：这一整片（例如 header 那一行里的
    // 每一枚圆钮）归它管。再各自投一次票，同一行里就可能出现「胶囊翻了、钮
    // 没翻」的花脸；而且融合层里本来就只有一份材质。
    if (context
            .dependOnInheritedWidgetOfExactType<_GlassAdaptiveChromeMarker>() !=
        null) {
      return child;
    }
    // 没有 host 就没有判决来源，包会退回「平台亮度」——那和我们的主题亮度是
    // 两回事（用户可以钉死浅色主题却把系统调成深色），照着它换色是纯粹的错。
    if (lgw.GlassContentAwareScope.maybeOf(context) == null) return child;

    final ThemeData theme = Theme.of(context);
    final Brightness ambient = theme.colorScheme.brightness;

    Widget consumer = lgw.GlassContentAwareBrightness(
      gridColumns: gridColumns,
      gridRows: gridRows,
      // 判决翻面很稀疏（要跨过 0.6 的迟滞带才算数），但它是这套机制唯一能在
      // 日志里看见的东西——玻璃底下是什么色截图也拍不出来（开了隐私模式的机器
      // 更是整屏全黑）。真机排查「到底有没有生效」就靠这一行。
      onBrightnessChanged: (b) =>
          LogUtils.d('内容感知判决翻面：${b.name}（$debugLabel）', 'GlassAdaptiveChrome'),
      builder: (context, brightness, darkAmount) => _GlassAdaptiveChromeMarker(
        child: _themed(theme, darkAmount: darkAmount, ambient: ambient),
      ),
    );

    // ⛔ 包用 `MediaQuery.platformBrightness` 给判决**播种**（并在系统亮度变化
    // 时重新锚定）。本 App 的主题明暗由设置里的 themeMode 决定，和系统亮度可以
    // 完全不一致——不改这一条，「浅色主题 + 深色系统」的机器上 chrome 会以翻面
    // 状态起步，等第一次采样回来才跳回去。这里就地把种子换成**主题**的亮度。
    final MediaQueryData? mq = MediaQuery.maybeOf(context);
    if (mq != null && mq.platformBrightness != ambient) {
      consumer = MediaQuery(
        data: mq.copyWith(platformBrightness: ambient),
        child: consumer,
      );
    }
    return consumer;
  }

  /// 把判决落成子树的配色。
  ///
  /// `darkAmount` 是包给的动画位置（0 = 浅、1 = 深），翻面时按 200ms 缓动过去。
  /// 我们要的是「离环境档有多远」：环境是浅色主题时它自己就是距离，环境是深色
  /// 主题时取补。距离为 0（判决与主题一致）时**整只不包 Theme**，静止态零开销。
  Widget _themed(
    ThemeData theme, {
    required double darkAmount,
    required Brightness ambient,
  }) {
    final double t = ambient == Brightness.dark ? 1.0 - darkAmount : darkAmount;
    if (t <= 0.001) return child;

    final ColorScheme cs = theme.colorScheme;
    final ColorScheme flipped = _flippedScheme(cs);
    final ColorScheme effective = ColorScheme.lerp(cs, flipped, t);
    return Theme(
      data: theme.copyWith(
        colorScheme: effective,
        // `GlassTokens` 里有几处是按 `cs.brightness` 取值的（玻璃底色、描边
        // 透明度），`ColorScheme.lerp` 会在中点把它翻过去；`ThemeData.brightness`
        // 也跟着走，免得子树里两套亮度对不上。
        brightness: effective.brightness,
      ),
      child: child,
    );
  }

  /// 与 [cs] 对档的反面配色。
  ///
  /// 不去读全局的 `appLightTheme` / `appDarkTheme`：那两个值在「系统亮度变化」
  /// 那条路径上会被写成同一档（`_ThemeModeObserver` 只更新 light 那个），拿来
  /// 当反面用会静默失效。这里按当前 primary 现生成一份，键上缓存——
  /// `ColorScheme.fromSeed` 不便宜，但一台机器上就那么几个种子。
  static ColorScheme _flippedScheme(ColorScheme cs) {
    final Brightness target = cs.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    final int key = Object.hash(cs.primary.toARGB32(), target.index);
    return _flippedCache.putIfAbsent(
      key,
      () => ColorScheme.fromSeed(seedColor: cs.primary, brightness: target),
    );
  }

  static final Map<int, ColorScheme> _flippedCache = <int, ColorScheme>{};
}

/// 「这片子树已经有人在按内容换色了」。
///
/// 嵌套的 [GlassAdaptiveChrome] 认它就地透传——见 [GlassAdaptiveChrome.build]。
class _GlassAdaptiveChromeMarker extends InheritedWidget {
  const _GlassAdaptiveChromeMarker({required super.child});

  @override
  bool updateShouldNotify(_GlassAdaptiveChromeMarker oldWidget) => false;
}
