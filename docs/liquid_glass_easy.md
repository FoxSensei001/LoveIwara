# liquid_glass_easy 4.1.1 — API 参考（本地存档）

> 抓取自 pub.dev README + 本地 pub-cache 源码（`~/.pub-cache/hosted/pub.flutter-io.cn/liquid_glass_easy-4.1.1/`），
> 2026-08-21。**源码是权威**，README 有若干处已经落后于导出表（见文末「README 与源码不一致处」）。
>
> 之所以落成仓库文件而不是记在脑子里：这个包的公开 API 面很大（lens / style / shape /
> refraction / appearance / touch-flex / blender / view / 一堆 drop-in 组件），而且**导出表里
> 明确写了一半组件是"故意不导出"的**——不查表照着 README 写，会写出一堆 import 不进来的类名。

## 0. 一句话心智模型

一块玻璃 = **geometry（放哪、多大）+ style（长什么样）+ touch（怎么回应手指）**。

`LiquidGlassLens` 是 layout 驱动的：**它没有 position / width / height 参数**，
布局把它放哪它就在哪、约束多大它就多大（要固定尺寸就外面套 `SizedBox`）。

```dart
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

SizedBox(
  width: 220,
  height: 120,
  child: LiquidGlassLens(
    style: const LiquidGlassStyle(
      shape: LiquidGlassShape.continuousRoundedRectangle(cornerRadius: 36),
      refraction: LiquidGlassRefraction(distortion: 0.13, distortionWidth: 34),
      appearance: LiquidGlassAppearance(color: Color(0x16FFFFFF)),
    ),
    child: const Center(child: Text('Liquid Glass')),
  ),
)
```

## 1. 三种渲染模式（自动选，写法完全一样）

| 条件 | 效果 |
| --- | --- |
| **Impeller**（`ui.ImageFilter.isShaderFilterSupported == true`） | 直接折射**实时 backdrop**——你在它后面画了什么就折射什么。不需要 `LiquidGlassView`，不需要背景图，扔在任何 UI 上就能用。 |
| **Skia / Web + 祖先有带 `backgroundWidget` 的 `LiquidGlassView`** | 折射该 view 抓拍下来的背景。 |
| **Skia / Web 且没有 view（或没有背景）** | 降级成"磨砂"：`BackdropFilter` 模糊 + 色调 + 描边，**没有折射**，并 debug 打印一次告警。 |

降级路径的兜底值（见 `liquid_glass_lens.dart` 的 `_FrostedGlassFallback`）：
`blur.sigma <= 0` 时强制 10；`appearance.color` 全透明时用 `0x14FFFFFF`；
`shape.borderColor == null` 时用 `0x40FFFFFF`；`borderWidth <= 0` 时用 1.0。

判定源码（`_buildGlass`）：

```dart
final bool impeller =
    (widget.useImpellerBackdrop ?? scope?.useImpellerBackdrop ?? true) &&
        ui.ImageFilter.isShaderFilterSupported;
```

即：**默认走 Impeller**，`useImpellerBackdrop: false` 才强制关掉。

### 首帧是磨砂的

shader 是**异步加载**的（`LiquidGlassShaders.ensureLoaded()`，在 `initState` 里发起）。
加载完成前，全 App 第一块玻璃会先渲染成磨砂再 `setState` 切过去。要避免这一下切换，
在 App 启动时预热 `LiquidGlassShaders.ensureLoaded()`。

## 2. 公开 API 清单（以 `lib/liquid_glass_easy.dart` 导出表为准）

### 核心

- `LiquidGlassLens` — layout 驱动的玻璃透镜，**app 开发者的主入口**。
- `LiquidGlassBlender` — 包住一棵子树，把其中 2–6 个 `LiquidGlassLens` 融成一块 metaball 玻璃。
- `LiquidGlassView` — Skia/Web 的背景抓拍管线（Impeller 上不需要）。
- `LiquidGlassShaders` — shader 程序缓存，`ensureLoaded()` / `isLoaded`。
- `LiquidGlassStyle` / `LiquidGlassShape` / `LiquidGlassAppearance` / `LiquidGlassRefraction` / `LiquidGlassBlur`
- `LiquidGlassTouch` / `LiquidGlassFlex`（+ `LiquidGlassFlexDeform` / `LiquidGlassFlexAdvanced`）
- `LiquidGlassShadow` — 接触阴影（可以单独包任何 lens）
- `LiquidGlassMotionPill` / `LiquidGlassLensMotion` / `LiquidGlassLensMotionSpec`
- 枚举族：`LiquidGlassCornerStyle`、`LiquidGlassClipQuality`、`LiquidGlassBorderMode`、
  `LiquidGlassLightMode`、`LiquidGlassRefractionMode`、`LiquidGlassRefractionType`
  （`StandardRefraction` / `OpticalRefraction`）、`LiquidGlassRefreshRate`、`LiquidGlassPosition`、`LiquidGlassSpring`
- 自定义图标/文字槽：`LiquidGlassGlyph` / `LiquidGlassGlyphBuilder` / `LiquidGlassLabel` / `LiquidGlassLabelBuilder`

### Drop-in 组件（导出的）

`LiquidGlassButton`、`LiquidGlassFab`、`LiquidGlassDialog`（+ presenter 助手）、
`LiquidGlassSlider`（+`LiquidGlassSliderLayout`）、`LiquidGlassSwitch`（+`LiquidGlassSwitchLayout`）、
`LiquidGlassScaffold`、`LiquidGlassAppBar`、`LiquidGlassDraggable`、
`LiquidGlassTabBar`（+`LiquidGlassTabBarItem`、`LiquidGlassTabBarAction`、`LiquidGlassPillMode`、
`LiquidGlassTabItemStyle`、`LiquidGlassTabPillStyle`、`LiquidGlassTabMagnifierPillStyle`）。

### ⚠️ 存在但**故意不导出**的（照 README 写会编译不过）

- `LiquidGlass` / `LiquidGlassGeometry` / `LiquidGlassBehavior` — 老的位置驱动引擎，`@internal`，
  只有包自己的组件用。**用 `LiquidGlassLens` 代替。**
- `LiquidGlassSegmented` / `LiquidGlassSegmentedControl` / `LiquidGlassMorphSegmented` /
  `LiquidGlassMorphPill` — "动效还没定稿"，作者暂时藏起来了。
  → **我们自己的分段胶囊（`GlassSegmentedControl`）没法直接换成它的，只能自己拿 lens 拼。**
- `LiquidGlassAppIcon` / `LiquidGlassDock` / `LiquidGlassControlTile`
- `LiquidGlassAnimatedNavBar` 及一众 bottom-nav 底层积木 — 走 `LiquidGlassTabBar` 配置。
- `LiquidGlassShowcase` / `LiquidGlassPlayground` — "UNDER MAINTENANCE"，暂时不导出。

## 3. `LiquidGlassLens` 构造参数

```dart
const LiquidGlassLens({
  Key? key,
  LiquidGlassStyle style = const LiquidGlassStyle(),
  bool visibility = true,          // false = 玻璃不画（无 backdrop 开销）且 child 被移除；**瞬时，无内建动画**
  bool? useImpellerBackdrop,       // null = 继承祖先 view / 默认 true
  LiquidGlassTouch? touch,         // null = 不加手势监听、不加 ticker
  LiquidGlassFlexDeform? deform,   // 外部驱动形变（与 restSize 必须成对给，否则忽略）；优先于 touch
  Size? restSize,
  bool honorBackdropAlpha = false, // 仅 Skia 抓拍路径；Impeller 忽略
  Widget? child,                   // 画在玻璃之上，按 lens 形状裁切
});
```

要点：

- `visibility: false` 是**硬切**。要淡入淡出得自己在外面包。
- `touch` 为 null 时**完全零成本**（不建 `Listener`、不建 ticker）。
- `deform` + `restSize` 是给"宿主自己算形变"的场景（滑块 thumb、导航 pill）；
  给了就跳过手势与 driver，**lens 自己的 box 必须已经是形变后的尺寸**。

## 4. `LiquidGlassStyle` = shape + appearance + refraction

```dart
const LiquidGlassStyle({
  LiquidGlassShape? shape,          // null → 消费方自己挑默认（lens 用 continuousRoundedRectangle()）
  LiquidGlassAppearance appearance = const LiquidGlassAppearance(),
  LiquidGlassRefraction refraction = const LiquidGlassRefraction(),
});

style.copyWith(...)      // 换字段
style.merge(other)       // other 覆盖；other.shape 为 null 时回落到本 style 的 shape
```

### `LiquidGlassShape`（几何 + 描边 + 打光）

```dart
const LiquidGlassShape({
  LiquidGlassCornerStyle cornerStyle = LiquidGlassCornerStyle.continuousRoundedRectangle,
  double cornerRadius = 50.0,
  LiquidGlassClipQuality clipQuality = LiquidGlassClipQuality.roundedRectangle,
  double borderWidth = 1.0,
  Color? borderColor,               // 非 null 会**顶掉**光影色，变成纯色描边
  double lightIntensity = 1.0,
  Color lightColor = const Color(0xB2FFFFFF),
  double lightDirection = 0.0,      // 度：0=右, 90=上, 180=左, 270=下
  LiquidGlassLightMode lightMode = LiquidGlassLightMode.edge,   // edge | radial
  LiquidGlassBorderType borderType = const OpticalBorder(),
});
```

三个便捷构造（参数同上，只是钉死 `cornerStyle`）：
`LiquidGlassShape.roundedRectangle(...)`（圆弧角，最便宜）、
`LiquidGlassShape.squircle(...)`（L^n 超椭圆，iOS 风）、
`LiquidGlassShape.continuousRoundedRectangle(...)`（Apple 胶囊风，**默认**；半径拉满退化成干净胶囊）。

> ⚠️ **README 写的 `LiquidGlassShape.continuous` / `.rounded` 便捷构造在 4.1.1 源码里不存在**，
> 只有上面三个全名。枚举值也是 `roundedRectangle` / `squircle` / `continuousRoundedRectangle`
> （README 的注释里出现过 `circular` / `continuous`，是过时的）。

`clipQuality`：
- `roundedRectangle`（默认）— 便宜的 `ClipRRect`。shader 画 squircle 角时裁切轮廓仍是圆角，边缘会对不齐。
- `exact` — 与 shader 角型完全一致的 `ClipPath`，多一个 saveLayer，稍贵。

`borderType` 两种（sealed class）：

```dart
OpticalBorder(          // 默认：Apple 风 SDF 边缘光，带背景取色
  borderSaturation: 1.5,
  ambientIntensity: 1.0,
  borderSolidity: 0.0,
  // lightSpread: ...
)
ClassicBorder(          // 风格化的光影扫掠
  borderSoftness: 2.5,
  shadowColor: Color(0x1A000000),
  // oneSideLightIntensity / doubleSideLightIntensity
)
```

### `LiquidGlassAppearance`（材质）

```dart
const LiquidGlassAppearance({
  double saturation = 1.0,                    // 1=不变, 0=灰度
  LiquidGlassBlur blur = const LiquidGlassBlur(),   // 默认 sigmaX/Y = 0（即不糊）
  Color color = Colors.transparent,           // 色调
  bool enableInnerRadiusTransparent = false,  // 内部非畸变区是否透明
  LiquidGlassShadow? shadow,                  // 接触阴影，null=不画
});

const LiquidGlassBlur({double sigmaX = 0, double sigmaY = 0});
```

`shadow` 会被 lens 拿去包住自己（其 `child` 被忽略），圆角默认取 shape 的裁切半径，
且**位于 flex 形变盒之内**——按下时阴影跟着玻璃一起胀、倾、回弹。
`LiquidGlassBlender` 里**不支持**（融合后的 metaball 没有单一轮廓可投影）。

```dart
const LiquidGlassShadow({
  double blur = 3.5, double opacity = 0.2, Color color = Colors.black,
  Offset? offset, double? cornerRadius, Offset scale = const Offset(1, 1),
  double inset = 0, bool visible = true, Widget? child,
});
```

### `LiquidGlassRefraction`（折射）

```dart
const LiquidGlassRefraction({
  double distortion = 0.1,              // 0.0–1.0；仅当 refractionType == null 时生效
  double distortionWidth = 30,          // 逻辑像素；同上
  double magnification = 1,             // 1 = 不放大
  double chromaticAberration = 0.003,   // 色散
  LiquidGlassRefractionMode refractionMode = LiquidGlassRefractionMode.shapeRefraction, // | radialRefraction
  LiquidGlassRefractionType? refractionType,  // 非 null 时上面的 distortion/Width 被忽略
  double diagonalFlip = 0,
});
```

`refractionType` 非 null 时走新算法：`StandardRefraction(distortion, width)` 或
`OpticalRefraction(depth, refraction, width)`（`depth` 复用 `u_distortion` 那根线）。

## 5. 触摸形变 `LiquidGlassTouch` / `LiquidGlassFlex`

```dart
LiquidGlassLens(
  touch: const LiquidGlassTouch(flex: LiquidGlassFlex(stretch: 22, lean: 0.5)),
  // 或 const LiquidGlassTouch.flexing(LiquidGlassFlex())
)

const LiquidGlassFlex({
  double stretch = 13,       // 顺拖拽方向拉长的像素量
  double squeeze = 0.70,     // 横轴收缩比
  double lean = 0.50,        // 追手指的倾斜
  double grip = 0.70,
  bool compressInward = true,
  double holdScale = 0.030,  // 按住时整体缩放
  double tapScale = 0.020,
  double maxPull = 48,
  Axis? lockAxis,
  LiquidGlassFlexAdvanced advanced = const LiquidGlassFlexAdvanced(),
});

const LiquidGlassFlex.subtle()   // 大面（卡片/面板/工具条）用：stretch 6, holdScale 0.015 …
```

按下时**加深光学**（`refractionBoost`）而不是弹缩放——这是"玻璃受压"而非"橡皮"的关键。
`LiquidGlassBlender` 内除 `refractionBoost` 外都保留（融合面共用一份 style，单块没法单独加深）。

## 6. `LiquidGlassBlender`（金属球融合）

包住子树，把其中 2–6 个后代 `LiquidGlassLens` 融成一块玻璃：靠近时"流"到一起。
被包住的 lens **不再自己画玻璃**，而是把几何交给 blender。
Skia/Web 且没有 `LiquidGlassView` 时 blender 画不了，成员会各自单独渲染、但用**组的** style。

## 7. `LiquidGlassView`（只有 Skia/Web 需要）

```dart
LiquidGlassView(
  backgroundWidget: const MyBackground(),
  child: const MyGlassUI(),
  pixelRatio: 1.0,             // 0.8–1.0 通用；0.5–0.7 省性能
  realTimeCapture: true,       // false + controller.captureOnce() = 快照模式
  useSync: true,
  useImpellerBackdrop: null,
  refreshRate: LiquidGlassRefreshRate.deviceRefreshRate,
)
```

快照模式：

```dart
final viewController = LiquidGlassViewController();
LiquidGlassView(controller: viewController, realTimeCapture: false, ...);
await viewController.captureOnce();   // 背景变了之后手动刷
```

## 8. 性能与坑

1. **滚动容器里放 lens：作者明说 "not recommended"。** lens 的定位是浮在内容之上。
   非放不可（Impeller）时必须关掉 overscroll，否则 Android 的拉伸回弹会把滚动内容
   隔离进独立合成层，`BackdropFilter` 看不到真 backdrop，**两端滚到边会渲染成纯黑**：

   ```dart
   ScrollConfiguration(
     behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
     child: ListView(children: [ /* ...LiquidGlassLens... */ ]),
   )
   ```

2. **Skia 上 blur 是在 shader 里做的**，lens 大 / blur 大时很贵；blur > ~7 在 Skia 上
   跟真 backdrop blur 长得也不像。
3. 每块 lens 一次 backdrop 采样。header 上一排按钮**各自一块 lens** = 一排采样；
   能合成一只胶囊就别拆。
4. `clipQuality: exact` 多一个 saveLayer。
5. `visibility` 切换是硬切，没有动画。

## 9. README 与源码不一致处（4.1.1，以源码为准）

| README 说 | 实际 |
| --- | --- |
| `LiquidGlassShape.squircle(cornerRadius: 44)` 等便捷构造 | ✅ 存在 |
| `LiquidGlassShape.continuous(...)` / `.rounded(...)` | ❌ 不存在，用全名 |
| `LiquidGlassLens(touch: ...)` 示例里的 `LiquidGlassTouch(flex: LiquidGlassFlex())` | ✅ 存在 |
| `LiquidGlassAlertDialog` | 导出的是 `liquid_glass_dialog.dart` 整个文件；类名以源码为准 |
| `LiquidGlassSegmentedControl` 可用 | ❌ 故意不导出 |

## 10. 元信息

- 版本：`liquid_glass_easy: ^4.1.1`，MIT，依赖仅 `flutter` + `meta ^1.9.0`
- 平台：Android / iOS / Linux / macOS / Web / Windows
- 仓库：https://github.com/AhmeedGamil/liquid_glass_easy
- pub.dev：https://pub.dev/packages/liquid_glass_easy
- 本地源码：`~/.pub-cache/hosted/pub.flutter-io.cn/liquid_glass_easy-4.1.1/`
  （注意本机 pub 走的是 `pub.flutter-io.cn` 镜像目录，不是 `pub.dev` 目录）
