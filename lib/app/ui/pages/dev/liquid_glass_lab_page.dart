/// liquid_glass_easy 4.1.1 —— 业务场景速览（临时调试页面）。
///
/// 看的是「这套依赖搭出来的真实界面长什么样」：列表页悬浮头部与按钮组、底部导航、
/// 播放器控制条、弹窗与浮层。所有玻璃都直接用包导出的 `LiquidGlassLens` 搭，
/// 刻意**不复用**项目自己的 `lib/app/ui/widgets/glass/**`。
///
/// 玻璃背后铺的是仿真业务内容（视频网格 / 图库 / 评论流 / 播放画面），而且是能滚的，
/// 因为折射看的就是背后那层。
///
/// 入口：全局抽屉「更多」分组 →「液态玻璃实验室」。右侧边缘的小把手拉出调参抽屉。
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

// ─────────────────────────────────────────────────────────────
// 玻璃配方：一份参数派生出「胶囊 / 面板 / 圆钮」三种 style，
// 场景只说自己要哪一种，材质统一在这里调。
// ─────────────────────────────────────────────────────────────

class _Recipe {
  const _Recipe({
    this.tintAlpha = 0.10,
    this.distortion = 0.12,
    this.distortionWidth = 26,
    this.blur = 2,
    this.lightIntensity = 1.2,
    this.borderWidth = 1.1,
    this.chromatic = 0.003,
    this.shadow = true,
    this.touchFlex = true,
  });

  final double tintAlpha;
  final double distortion;
  final double distortionWidth;
  final double blur;
  final double lightIntensity;
  final double borderWidth;
  final double chromatic;
  final bool shadow;
  final bool touchFlex;

  _Recipe copyWith({
    double? tintAlpha,
    double? distortion,
    double? distortionWidth,
    double? blur,
    double? lightIntensity,
    double? borderWidth,
    double? chromatic,
    bool? shadow,
    bool? touchFlex,
  }) => _Recipe(
    tintAlpha: tintAlpha ?? this.tintAlpha,
    distortion: distortion ?? this.distortion,
    distortionWidth: distortionWidth ?? this.distortionWidth,
    blur: blur ?? this.blur,
    lightIntensity: lightIntensity ?? this.lightIntensity,
    borderWidth: borderWidth ?? this.borderWidth,
    chromatic: chromatic ?? this.chromatic,
    shadow: shadow ?? this.shadow,
    touchFlex: touchFlex ?? this.touchFlex,
  );

  LiquidGlassStyle glass({
    double radius = 999,
    double? tint,
    double shadowBlur = 10,
    double shadowOpacity = 0.22,
  }) => LiquidGlassStyle(
    shape: LiquidGlassShape.continuousRoundedRectangle(
      cornerRadius: radius,
      borderWidth: borderWidth,
      lightIntensity: lightIntensity,
      lightDirection: 80,
      borderType: const OpticalBorder(
        borderSaturation: 1.4,
        ambientIntensity: 1,
        borderSolidity: 0.35,
      ),
    ),
    appearance: LiquidGlassAppearance(
      color: Colors.white.withValues(alpha: tint ?? tintAlpha),
      blur: LiquidGlassBlur(sigmaX: blur, sigmaY: blur),
      shadow: shadow
          ? LiquidGlassShadow(blur: shadowBlur, opacity: shadowOpacity)
          : null,
    ),
    refraction: LiquidGlassRefraction(
      distortion: distortion,
      distortionWidth: distortionWidth,
      chromaticAberration: chromatic,
    ),
  );

  /// 选中胶囊：叠在按钮组那块玻璃之上的第二块玻璃，做得更「实」一点。
  LiquidGlassStyle indicator({double radius = 999}) => LiquidGlassStyle(
    shape: LiquidGlassShape.continuousRoundedRectangle(
      cornerRadius: radius,
      borderWidth: 1,
      lightIntensity: 1.5,
      lightDirection: 80,
      borderType: const OpticalBorder(borderSolidity: 0.6),
    ),
    appearance: LiquidGlassAppearance(
      color: Colors.white.withValues(alpha: tintAlpha + 0.12),
    ),
    refraction: LiquidGlassRefraction(
      distortion: distortion + 0.05,
      distortionWidth: 18,
      chromaticAberration: chromatic,
    ),
  );

  LiquidGlassTouch? get touch =>
      touchFlex ? const LiquidGlassTouch(flex: LiquidGlassFlex.subtle()) : null;

  LiquidGlassTouch? get keyTouch =>
      touchFlex ? const LiquidGlassTouch(flex: LiquidGlassFlex()) : null;
}

// ─────────────────────────────────────────────────────────────
// 页面骨架
// ─────────────────────────────────────────────────────────────

enum _Scene {
  list('列表页'),
  buttons('按钮组'),
  player('播放器'),
  overlay('弹窗浮层'),
  tune('材质微调');

  const _Scene(this.label);
  final String label;
}

enum _Content {
  videoGrid('视频网格'),
  gallery('图库'),
  comments('评论流'),
  player('播放画面'),
  rainbow('彩虹条');

  const _Content(this.label);
  final String label;
}

class LiquidGlassLabPage extends StatefulWidget {
  const LiquidGlassLabPage({super.key});

  @override
  State<LiquidGlassLabPage> createState() => _LiquidGlassLabPageState();
}

class _LiquidGlassLabPageState extends State<LiquidGlassLabPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _Scene _scene = _Scene.list;
  _Content _content = _Content.videoGrid;
  _Recipe _recipe = const _Recipe();

  @override
  void initState() {
    super.initState();
    // shader 异步加载，不预热的话第一块玻璃会先渲染成磨砂再切过去。
    LiquidGlassShaders.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _scene == _Scene.player ? _Content.player : _content;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      endDrawer: _ControlDrawer(
        scene: _scene,
        content: _content,
        recipe: _recipe,
        onScene: (s) => setState(() => _scene = s),
        onContent: (c) => setState(() => _content = c),
        onRecipe: (r) => setState(() => _recipe = r),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 玻璃背后的仿真业务内容（可滚）
          _FakeContent(kind: content),
          // 场景本体
          switch (_scene) {
            _Scene.list => _ListSceneOverlay(recipe: _recipe),
            _Scene.buttons => _ButtonsScene(recipe: _recipe),
            _Scene.player => _PlayerScene(recipe: _recipe),
            _Scene.overlay => _OverlayScene(recipe: _recipe),
            _Scene.tune => _TuneScene(
              recipe: _recipe,
              onRecipe: (r) => setState(() => _recipe = r),
            ),
          },
          // 右边缘小把手：拉出调参抽屉
          Align(
            alignment: const Alignment(1, 0.25),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              child: Container(
                width: 22,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ),
          ),
          // 返回
          Positioned(
            left: 4,
            bottom: 4,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 玻璃后面的仿真业务内容
// ─────────────────────────────────────────────────────────────

class _FakeContent extends StatelessWidget {
  const _FakeContent({required this.kind});

  final _Content kind;

  static const _palette = [
    Color(0xFF2E4B8F),
    Color(0xFF8F2E5A),
    Color(0xFF1F7A63),
    Color(0xFF8A5A1F),
    Color(0xFF5B2E8F),
    Color(0xFF2E7F8F),
    Color(0xFF8F3B2E),
    Color(0xFF3F8F2E),
  ];

  static Color _c(int i) => _palette[i % _palette.length];

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // Android 的拉伸回弹会把滚动内容隔离进独立合成层，BackdropFilter 就看不到
      // 真 backdrop —— 滚到两端时玻璃会渲染成纯黑。
      behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
      child: switch (kind) {
        _Content.videoGrid => _videoGrid(context),
        _Content.gallery => _gallery(context),
        _Content.comments => _comments(context),
        _Content.player => const _PlayerFrame(),
        _Content.rainbow => _rainbow(),
      },
    );
  }

  Widget _videoGrid(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = math.max(2, width ~/ 260);
    return ColoredBox(
      color: const Color(0xFF0D0F14),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 130, 12, 140),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 14,
        ),
        itemCount: 40,
        itemBuilder: (context, i) => _VideoCard(index: i, color: _c(i)),
      ),
    );
  }

  Widget _gallery(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF08090C),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        itemCount: 12,
        itemBuilder: (context, i) => Container(
          height: 280,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_c(i), _c(i + 3), _c(i + 5)],
            ),
          ),
          child: Center(
            child: Text(
              '图片 ${i + 1}',
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _comments(BuildContext context) {
    const body =
        '这条评论是用来当折射素材的：小字号、高频细节，最能看出色散和放大有没有把文字糊掉。'
        '把玻璃拖到这段字上面，看边缘那一圈的弯曲。';
    return ColoredBox(
      color: const Color(0xFF101319),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 130, 16, 140),
        itemCount: 30,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: _c(i), shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户 ${1000 + i * 37}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      body,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rainbow() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF0055),
            Color(0xFFFF8A00),
            Color(0xFFFFE500),
            Color(0xFF00D68F),
            Color(0xFF00A3FF),
            Color(0xFF7B2CFF),
            Color(0xFFFF0055),
          ],
          stops: [0, 0.17, 0.33, 0.5, 0.66, 0.83, 1],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, Color.lerp(color, Colors.black, 0.55)!],
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white.withValues(alpha: 0.25),
                    size: 40,
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${8 + index % 12}:${(index * 7) % 60}'.padRight(5, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '示例视频标题 ${index + 1} · 这里是会被玻璃折射的一行标题',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '作者 ${index % 9 + 1}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const Spacer(),
            const Icon(Icons.favorite, color: Colors.white38, size: 11),
            const SizedBox(width: 3),
            Text(
              '${index * 13 % 900}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerFrame extends StatelessWidget {
  const _PlayerFrame();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.2, -0.3),
              radius: 1.1,
              colors: [Color(0xFF3B5BA5), Color(0xFF0A0C12)],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.25, 0.1),
          child: Container(
            width: 260,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(140),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFC7A8), Color(0xFFB65A7A)],
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment(0, 0.62),
          child: Text(
            '这里是字幕行，用来看控制条盖上去之后还读不读得清',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 通用积木：一只胶囊壳 + 壳里的图标键
// ─────────────────────────────────────────────────────────────

/// 键组的宽度要写死：带 touch flex 的 lens 用 `constraints.biggest` 当 rest size ——
/// 松约束下会撑满，无界约束下（比如直接放进 Row）形变会被静默关掉。
const double _kKeySize = 36;
double _groupWidth(int keys, {double padding = 8}) =>
    _kKeySize * keys + padding;

/// 一整只胶囊玻璃（**一块 lens**）。header 上一排键合成一只壳，比每键一块 lens
/// 省一大截 backdrop 采样。
class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.recipe,
    required this.child,
    this.height = 44,
    this.radius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.width,
    this.touch = true,
  });

  final _Recipe recipe;
  final Widget child;
  final double height;
  final double radius;
  final double? width;
  final EdgeInsets padding;
  final bool touch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: LiquidGlassLens(
        style: recipe.glass(radius: radius),
        touch: touch ? recipe.touch : null,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// 壳内的一个键：只有涟漪和图标，玻璃是外面那只壳的。
class _BarKey extends StatelessWidget {
  const _BarKey({
    required this.icon,
    this.onTap,
    this.size = 36,
    this.badge = 0,
    this.label,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final int badge;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.9);
    Widget content = Icon(icon, size: size * 0.52, color: color);
    if (label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size * 0.5, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
    if (badge > 0) {
      content = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          content,
          Positioned(
            right: -2,
            top: -1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B4E),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return InkWell(
      onTap: onTap ?? () {},
      customBorder: const StadiumBorder(),
      child: SizedBox(
        height: size,
        width: label == null ? size : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 12),
          child: Center(child: content),
        ),
      ),
    );
  }
}

/// 独立的一枚圆钮（自己一块 lens，可以自己形变）。
class _GlassKey extends StatelessWidget {
  const _GlassKey({
    required this.recipe,
    required this.icon,
    this.onTap,
    this.size = 44,
  });

  final _Recipe recipe;
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: LiquidGlassLens(
        style: recipe.glass(radius: size / 2),
        touch: recipe.keyTouch,
        child: Material(
          type: MaterialType.transparency,
          child: _BarKey(icon: icon, onTap: onTap, size: size),
        ),
      ),
    );
  }
}

/// 分段控件：壳是一块玻璃，选中胶囊是叠在它上面的第二块玻璃，会滑过去。
class _GlassSegmented extends StatelessWidget {
  const _GlassSegmented({
    required this.recipe,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final _Recipe recipe;
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const pad = 4.0;
    const itemWidth = 84.0;
    const height = 40.0;
    final width = itemWidth * items.length + pad * 2;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: LiquidGlassLens(
              style: recipe.glass(radius: height / 2),
              touch: recipe.touch,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            left: pad + itemWidth * index,
            top: pad,
            width: itemWidth,
            height: height - pad * 2,
            child: LiquidGlassLens(
              style: recipe.indicator(radius: (height - pad * 2) / 2),
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  const SizedBox(width: pad),
                  for (var i = 0; i < items.length; i++)
                    SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        onTap: () => onChanged(i),
                        customBorder: const StadiumBorder(),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: TextStyle(
                              color: i == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            child: Text(items[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text, {this.note});

  final String text;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                note!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 场景 1：列表页 —— 悬浮头部 + 分段 + 底部导航 + 浮钮
// ─────────────────────────────────────────────────────────────

class _ListSceneOverlay extends StatefulWidget {
  const _ListSceneOverlay({required this.recipe});

  final _Recipe recipe;

  @override
  State<_ListSceneOverlay> createState() => _ListSceneOverlayState();
}

class _ListSceneOverlayState extends State<_ListSceneOverlay> {
  int _tab = 0;
  int _nav = 0;
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        // ── 顶部：标题胶囊 + 右侧按钮组，第二行分段控件
        Positioned(
          top: top + 8,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 返回 + 标题，一只壳
                  Flexible(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: _searching
                          ? _GlassBar(
                              recipe: r,
                              height: 44,
                              width: 320,
                              padding: const EdgeInsets.only(left: 4, right: 8),
                              child: Row(
                                children: [
                                  _BarKey(
                                    icon: Icons.arrow_back,
                                    onTap: () =>
                                        setState(() => _searching = false),
                                  ),
                                  const Expanded(
                                    child: TextField(
                                      autofocus: false,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText: '搜索视频、作者、标签',
                                        hintStyle: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _GlassBar(
                              recipe: r,
                              height: 44,
                              width: 168,
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _BarKey(icon: Icons.arrow_back),
                                  const SizedBox(width: 2),
                                  const Flexible(
                                    child: Text(
                                      '热门视频',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const Spacer(),
                  // 右侧按钮组：一只壳装 3 个键
                  _GlassBar(
                    recipe: r,
                    height: 44,
                    width: _groupWidth(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BarKey(
                          icon: Icons.search,
                          onTap: () => setState(() => _searching = !_searching),
                        ),
                        _BarKey(icon: Icons.tune, badge: 2),
                        _BarKey(icon: Icons.more_horiz),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _GlassSegmented(
                recipe: r,
                items: const ['视频', '图片', '帖子', '播放列表'],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ],
          ),
        ),

        // ── 右下：回顶 + 主操作
        Positioned(
          right: 16,
          bottom: bottom + 108,
          child: Column(
            children: [
              _GlassKey(recipe: r, icon: Icons.vertical_align_top, size: 44),
              const SizedBox(height: 12),
              SizedBox(
                width: 56,
                height: 56,
                child: LiquidGlassLens(
                  style: r.glass(radius: 28, tint: r.tintAlpha + 0.06),
                  touch: r.keyTouch,
                  child: _BarKey(icon: Icons.add, size: 56),
                ),
              ),
            ],
          ),
        ),

        // ── 底部：浮动导航栏（壳 + 会滑的选中胶囊）
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom + 16,
          child: Center(
            child: _FloatingNavBar(
              recipe: r,
              index: _nav,
              onChanged: (i) => setState(() => _nav = i),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.recipe,
    required this.index,
    required this.onChanged,
  });

  final _Recipe recipe;
  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, '首页'),
    (Icons.local_fire_department_outlined, Icons.local_fire_department, '热门'),
    (Icons.subscriptions_outlined, Icons.subscriptions, '订阅'),
    (Icons.forum_outlined, Icons.forum, '社区'),
  ];

  @override
  Widget build(BuildContext context) {
    const itemWidth = 76.0;
    const height = 62.0;
    const pad = 6.0;
    final width = itemWidth * _items.length + pad * 2;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: LiquidGlassLens(
              style: recipe.glass(radius: height / 2, shadowBlur: 16),
              touch: recipe.touch,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            left: pad + itemWidth * index,
            top: pad,
            width: itemWidth,
            height: height - pad * 2,
            child: LiquidGlassLens(
              style: recipe.indicator(radius: (height - pad * 2) / 2),
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  const SizedBox(width: pad),
                  for (var i = 0; i < _items.length; i++)
                    SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        onTap: () => onChanged(i),
                        customBorder: const StadiumBorder(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 260),
                              scale: i == index ? 1.08 : 1,
                              child: Icon(
                                i == index ? _items[i].$2 : _items[i].$1,
                                color: i == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _items[i].$3,
                              style: TextStyle(
                                color: i == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                                fontSize: 10.5,
                                fontWeight: i == index
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 场景 2：按钮组花样
// ─────────────────────────────────────────────────────────────

class _ButtonsScene extends StatefulWidget {
  const _ButtonsScene({required this.recipe});

  final _Recipe recipe;

  @override
  State<_ButtonsScene> createState() => _ButtonsSceneState();
}

class _ButtonsSceneState extends State<_ButtonsScene> {
  int _seg = 0;
  int _toolbar = 1;
  bool _expanded = false;
  bool _liked = false;
  bool _selectionMode = false;
  double _blendGap = 8;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + 12,
          16,
          MediaQuery.paddingOf(context).bottom + 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Caption(
              '① 一只壳装 N 个键（推荐）',
              note: '整组只有一块 lens = 一次 backdrop 采样。header 右上角那排就该这么做。',
            ),
            Row(
              children: [
                _GlassBar(
                  recipe: r,
                  width: _groupWidth(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _BarKey(icon: Icons.search),
                      _BarKey(icon: Icons.tune),
                      _BarKey(icon: Icons.more_horiz),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _GlassBar(
                  recipe: r,
                  width: _groupWidth(3, padding: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _BarKey(icon: Icons.notifications_outlined, badge: 12),
                      _BarKey(icon: Icons.mail_outline, badge: 3),
                      _BarKey(icon: Icons.people_outline, badge: 128),
                    ],
                  ),
                ),
              ],
            ),

            const _Caption(
              '② 每键一块玻璃（各自会形变）',
              note: '按住任意一枚：只有它自己被压。代价是每枚一次采样，排太多会掉帧。',
            ),
            Row(
              children: [
                _GlassKey(recipe: r, icon: Icons.thumb_up_alt_outlined),
                const SizedBox(width: 10),
                _GlassKey(recipe: r, icon: Icons.star_outline),
                const SizedBox(width: 10),
                _GlassKey(recipe: r, icon: Icons.playlist_add),
                const SizedBox(width: 10),
                _GlassKey(recipe: r, icon: Icons.download_outlined),
                const SizedBox(width: 10),
                _GlassKey(recipe: r, icon: Icons.share_outlined),
              ],
            ),

            const _Caption(
              '③ 融合：靠近就流成一条（LiquidGlassBlender）',
              note: '拖间距滑杆看金属球融合。间距大 = 分离的独立键，间距小 = 一条连体工具条。',
            ),
            SizedBox(
              height: 60,
              child: LiquidGlassBlender(
                style: r.glass(radius: 999),
                smoothness: 42,
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      SizedBox.square(
                        dimension: 48,
                        child: LiquidGlassLens(style: r.glass(radius: 24)),
                      ),
                      if (i != 3) SizedBox(width: _blendGap),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: Slider(
                value: _blendGap,
                min: 0,
                max: 90,
                onChanged: (v) => setState(() => _blendGap = v),
              ),
            ),

            const _Caption(
              '④ 分段控件：选中胶囊是第二块玻璃，会滑过去',
              note: '壳一块 + 指示器一块，共两次采样。',
            ),
            _GlassSegmented(
              recipe: r,
              items: const ['最新', '最热', '关注', '收藏'],
              index: _seg,
              onChanged: (i) => setState(() => _seg = i),
            ),

            const _Caption('⑤ 分栏工具条：左中右三段，一只壳'),
            _GlassBar(
              recipe: r,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  const _BarKey(icon: Icons.chevron_left),
                  const Spacer(),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => setState(() => _toolbar = i),
                        customBorder: const StadiumBorder(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _toolbar == i
                                ? Colors.white.withValues(alpha: 0.22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            const ['网格', '列表', '大图'][i],
                            style: TextStyle(
                              color: _toolbar == i
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 13,
                              fontWeight: _toolbar == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  const _BarKey(icon: Icons.chevron_right),
                ],
              ),
            ),

            const _Caption(
              '⑥ 展开式菜单：点「更多」，胶囊自己长出来',
              note: 'AnimatedSize 撑壳，键淡入。整组仍然只有一块 lens。',
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: _GlassBar(
                recipe: r,
                width: _groupWidth(_expanded ? 5 : 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BarKey(
                      icon: _expanded ? Icons.close : Icons.more_horiz,
                      onTap: () => setState(() => _expanded = !_expanded),
                    ),
                    if (_expanded) ...const [
                      _BarKey(icon: Icons.translate),
                      _BarKey(icon: Icons.report_outlined),
                      _BarKey(icon: Icons.block_flipped),
                      _BarKey(icon: Icons.link),
                    ],
                  ],
                ),
              ),
            ),

            const _Caption(
              '⑦ 主次按钮对 / 文字键',
              note: '确认键靠更高的色调 alpha 拉出主次，不靠实心填充。',
            ),
            Row(
              children: [
                _GlassBar(
                  recipe: r,
                  height: 44,
                  width: 104,
                  padding: EdgeInsets.zero,
                  child: const _BarKey(icon: Icons.close, label: '取消'),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 44,
                  width: 104,
                  child: LiquidGlassLens(
                    style: r.glass(radius: 22, tint: r.tintAlpha + 0.14),
                    touch: r.keyTouch,
                    child: const _BarKey(icon: Icons.check, label: '确认'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 44,
                  width: 168,
                  child: LiquidGlassLens(
                    style: r.glass(radius: 22),
                    touch: r.keyTouch,
                    child: _BarKey(
                      icon: _liked ? Icons.favorite : Icons.favorite_border,
                      label: _liked ? '已喜欢 1.2k' : '喜欢 1.2k',
                      onTap: () => setState(() => _liked = !_liked),
                    ),
                  ),
                ),
              ],
            ),

            const _Caption('⑧ 批量选择条：整条从底部升起', note: '一只长壳 + 左右两组键，中间放计数。'),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () =>
                      setState(() => _selectionMode = !_selectionMode),
                  child: Text(_selectionMode ? '退出选择' : '进入选择态'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSlide(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              offset: _selectionMode ? Offset.zero : const Offset(0, 0.4),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 240),
                opacity: _selectionMode ? 1 : 0.25,
                child: _GlassBar(
                  recipe: r,
                  height: 56,
                  radius: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const _BarKey(icon: Icons.close),
                      const SizedBox(width: 6),
                      const Text(
                        '已选 3 项',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const _BarKey(icon: Icons.download_outlined),
                      const _BarKey(icon: Icons.playlist_add),
                      const _BarKey(icon: Icons.delete_outline),
                    ],
                  ),
                ),
              ),
            ),

            const _Caption('⑨ 形变对照：同一组键，三种手感', note: '按住不放，往边上拖。'),
            Row(
              children: [
                Column(
                  children: [
                    _GlassBar(
                      recipe: r.copyWith(touchFlex: false),
                      width: _groupWidth(2),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BarKey(icon: Icons.sync),
                          _BarKey(icon: Icons.tune),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'touch: null（零开销）',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    SizedBox(
                      height: 44,
                      width: _groupWidth(2),
                      child: LiquidGlassLens(
                        style: r.glass(radius: 22),
                        touch: const LiquidGlassTouch(
                          flex: LiquidGlassFlex.subtle(),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BarKey(icon: Icons.sync),
                            _BarKey(icon: Icons.tune),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '.subtle()（大面推荐）',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    SizedBox(
                      height: 44,
                      width: _groupWidth(2),
                      child: LiquidGlassLens(
                        style: r.glass(radius: 22),
                        touch: const LiquidGlassTouch(
                          flex: LiquidGlassFlex(
                            stretch: 40,
                            squeeze: 0.5,
                            lean: 0.8,
                            holdScale: 0.06,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BarKey(icon: Icons.sync),
                            _BarKey(icon: Icons.tune),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '夸张（果冻感）',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 场景 3：播放器
// ─────────────────────────────────────────────────────────────

class _PlayerScene extends StatefulWidget {
  const _PlayerScene({required this.recipe});

  final _Recipe recipe;

  @override
  State<_PlayerScene> createState() => _PlayerSceneState();
}

class _PlayerSceneState extends State<_PlayerScene> {
  double _progress = 0.38;
  double _volume = 0.7;
  bool _playing = true;
  int _quality = 1;
  bool _locked = false;

  String _time(double t) {
    final total = 8 * 60 + 42;
    final s = (total * t).round();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:'
        '${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        // 顶部条
        Positioned(
          top: top + 10,
          left: 14,
          right: 14,
          child: Row(
            children: [
              _GlassBar(
                recipe: r,
                width: 280,
                padding: const EdgeInsets.only(left: 4, right: 14),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BarKey(icon: Icons.arrow_back),
                    SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '示例视频标题 · 4K 60fps',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _GlassBar(
                recipe: r,
                width: _groupWidth(3),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BarKey(icon: Icons.cast),
                    _BarKey(icon: Icons.picture_in_picture_alt_outlined),
                    _BarKey(icon: Icons.more_vert),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 中间：三键播放组
        Center(
          child: _GlassBar(
            recipe: r,
            height: 72,
            radius: 36,
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BarKey(icon: Icons.replay_10, size: 56),
                _BarKey(
                  icon: _playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 64,
                  onTap: () => setState(() => _playing = !_playing),
                ),
                const _BarKey(icon: Icons.forward_30, size: 56),
              ],
            ),
          ),
        ),

        // 右侧竖排：画质 / 倍速 / 锁
        Positioned(
          right: 14,
          top: 0,
          bottom: 0,
          child: Center(
            child: _GlassBar(
              recipe: r,
              height: 168,
              width: 48,
              radius: 24,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BarKey(
                    icon: _locked ? Icons.lock : Icons.lock_open,
                    onTap: () => setState(() => _locked = !_locked),
                  ),
                  const _BarKey(icon: Icons.speed),
                  const _BarKey(icon: Icons.hd_outlined),
                  const _BarKey(icon: Icons.subtitles_outlined),
                ],
              ),
            ),
          ),
        ),

        // 左侧：音量竖滑杆（自己拼的玻璃滑轨）
        Positioned(
          left: 14,
          top: 0,
          bottom: 0,
          child: Center(
            child: _GlassBar(
              recipe: r,
              height: 200,
              width: 48,
              radius: 24,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const Icon(Icons.volume_up, color: Colors.white, size: 18),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),
                        child: Slider(
                          value: _volume,
                          onChanged: (v) => setState(() => _volume = v),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 底部控制条：一整条壳，进度 + 时间 + 画质分段 + 全屏
        Positioned(
          left: 14,
          right: 14,
          bottom: bottom + 14,
          child: _GlassBar(
            recipe: r,
            height: 96,
            radius: 28,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.28),
                    thumbColor: Colors.white,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                  ),
                  child: Slider(
                    value: _progress,
                    onChanged: (v) => setState(() => _progress = v),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_time(_progress)} / 08:42',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFeatures: [ui.FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 12),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => setState(() => _quality = i),
                          customBorder: const StadiumBorder(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _quality == i
                                  ? Colors.white.withValues(alpha: 0.24)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: _quality == i ? 0.5 : 0.18,
                                ),
                              ),
                            ),
                            child: Text(
                              const ['540p', '1080p', 'Source'][i],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    const _BarKey(icon: Icons.skip_next, size: 32),
                    const _BarKey(icon: Icons.fullscreen, size: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 场景 4：弹窗 / 菜单 / 浮层
// ─────────────────────────────────────────────────────────────

class _OverlayScene extends StatefulWidget {
  const _OverlayScene({required this.recipe});

  final _Recipe recipe;

  @override
  State<_OverlayScene> createState() => _OverlaySceneState();
}

class _OverlaySceneState extends State<_OverlayScene> {
  bool _menuOpen = false;
  bool _sheetOpen = false;
  bool _toast = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        // 常驻对话框（不用路由，直接摆着看材质）
        Center(
          child: SizedBox(
            width: 360,
            child: LiquidGlassLens(
              style: r.glass(radius: 28, shadowBlur: 28, shadowOpacity: 0.35),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '删除这条下载？',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _GlassKey(recipe: r, icon: Icons.close, size: 34),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '文件会从本地移除，已下载的进度不会保留。这段正文放长一点，'
                      '好看清弹窗底下的内容被折射成什么样。',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _GlassBar(
                          recipe: r,
                          height: 40,
                          width: 100,
                          padding: EdgeInsets.zero,
                          child: const _BarKey(icon: Icons.close, label: '取消'),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          width: 104,
                          child: LiquidGlassLens(
                            style: r.glass(
                              radius: 20,
                              tint: r.tintAlpha + 0.14,
                            ),
                            touch: r.keyTouch,
                            child: const _BarKey(
                              icon: Icons.delete_outline,
                              label: '删除',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 右上角下拉菜单
        Positioned(
          top: top + 12,
          right: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _GlassKey(
                recipe: r,
                icon: _menuOpen ? Icons.close : Icons.more_horiz,
                onTap: () => setState(() => _menuOpen = !_menuOpen),
              ),
              const SizedBox(height: 10),
              AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                alignment: Alignment.topRight,
                scale: _menuOpen ? 1 : 0.85,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _menuOpen ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_menuOpen,
                    child: SizedBox(
                      width: 200,
                      child: LiquidGlassLens(
                        style: r.glass(radius: 20, shadowBlur: 20),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final item in const [
                                (Icons.sort, '排序方式'),
                                (Icons.translate, '翻译标题'),
                                (Icons.playlist_add, '加入播放列表'),
                                (Icons.block_flipped, '屏蔽此作者'),
                              ])
                                InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.$1,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          item.$2,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // toast
        Positioned(
          top: top + 16,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: _toast ? Offset.zero : const Offset(0, -1.6),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _toast ? 1 : 0,
                child: _GlassBar(
                  recipe: r,
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  touch: false,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF7CFFA8),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '已加入下载队列',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 底部 sheet
        AnimatedPositioned(
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
          left: 10,
          right: 10,
          bottom: _sheetOpen ? bottom + 10 : -300,
          child: SizedBox(
            height: 280,
            child: LiquidGlassLens(
              style: r.glass(radius: 28, shadowBlur: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '分享到',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 18,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final icon in const [
                        Icons.link,
                        Icons.qr_code_2,
                        Icons.image_outlined,
                        Icons.forum_outlined,
                        Icons.mail_outline,
                        Icons.download_outlined,
                      ])
                        _GlassKey(recipe: r, icon: icon, size: 52),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _GlassBar(
                      recipe: r,
                      height: 46,
                      padding: EdgeInsets.zero,
                      child: _BarKey(
                        icon: Icons.close,
                        label: '关闭',
                        onTap: () => setState(() => _sheetOpen = false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 触发器
        Positioned(
          left: 14,
          bottom: bottom + 14,
          child: Row(
            children: [
              FilledButton.tonal(
                onPressed: () => setState(() => _sheetOpen = !_sheetOpen),
                child: const Text('底部 sheet'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: () => setState(() => _toast = !_toast),
                child: const Text('toast'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: () => showLiquidGlassDialog<void>(
                  context: context,
                  builder: (ctx) => LiquidGlassAlertDialog(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    title: const Text('包自带的 LiquidGlassAlertDialog'),
                    content: const Text('对照组：这只是包里的默认实现，含遮罩和进出场动画。'),
                    actions: [
                      LiquidGlassButton(
                        label: '知道了',
                        height: 40,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                child: const Text('包自带弹窗'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 场景 5：材质微调（一组样例键 + 全套旋钮）
// ─────────────────────────────────────────────────────────────

class _TuneScene extends StatelessWidget {
  const _TuneScene({required this.recipe, required this.onRecipe});

  final _Recipe recipe;
  final ValueChanged<_Recipe> onRecipe;

  @override
  Widget build(BuildContext context) {
    final r = recipe;
    return Column(
      children: [
        SizedBox(height: MediaQuery.paddingOf(context).top + 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: [
            _GlassBar(
              recipe: r,
              width: _groupWidth(3),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BarKey(icon: Icons.search),
                  _BarKey(icon: Icons.tune),
                  _BarKey(icon: Icons.more_horiz),
                ],
              ),
            ),
            _GlassKey(recipe: r, icon: Icons.favorite_border),
            SizedBox(
              width: 200,
              height: 110,
              child: LiquidGlassLens(
                style: r.glass(radius: 24),
                touch: r.touch,
                child: const Center(
                  child: Text(
                    '卡片 / 面板',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _RecipeKnobs(
            recipe: recipe,
            onRecipe: onRecipe,
            background: Colors.black.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}

class _RecipeKnobs extends StatelessWidget {
  const _RecipeKnobs({
    required this.recipe,
    required this.onRecipe,
    this.background,
  });

  final _Recipe recipe;
  final ValueChanged<_Recipe> onRecipe;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    Widget knob(
      String label,
      double value,
      double min,
      double max,
      _Recipe Function(double) apply, {
      int digits = 2,
    }) {
      return Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: (v) => onRecipe(apply(v)),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value.toStringAsFixed(digits),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      );
    }

    // ListTile 一族要把涟漪画进最近的 Material；夹一层 ColoredBox 会被断言拦下。
    return Material(
      color: background ?? Colors.transparent,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            knob('色调 alpha', recipe.tintAlpha, 0, 0.5, (v) {
              return recipe.copyWith(tintAlpha: v);
            }, digits: 3),
            knob('distortion', recipe.distortion, 0, 0.6, (v) {
              return recipe.copyWith(distortion: v);
            }, digits: 3),
            knob('distortionWidth', recipe.distortionWidth, 4, 90, (v) {
              return recipe.copyWith(distortionWidth: v);
            }, digits: 0),
            knob('blur sigma', recipe.blur, 0, 14, (v) {
              return recipe.copyWith(blur: v);
            }, digits: 1),
            knob('lightIntensity', recipe.lightIntensity, 0, 3, (v) {
              return recipe.copyWith(lightIntensity: v);
            }),
            knob('borderWidth', recipe.borderWidth, 0, 4, (v) {
              return recipe.copyWith(borderWidth: v);
            }),
            knob('色散 chromatic', recipe.chromatic, 0, 0.03, (v) {
              return recipe.copyWith(chromatic: v);
            }, digits: 4),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                '接触阴影',
                style: TextStyle(color: Colors.white, fontSize: 12.5),
              ),
              value: recipe.shadow,
              onChanged: (v) => onRecipe(recipe.copyWith(shadow: v)),
            ),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                '按下形变 touch flex',
                style: TextStyle(color: Colors.white, fontSize: 12.5),
              ),
              value: recipe.touchFlex,
              onChanged: (v) => onRecipe(recipe.copyWith(touchFlex: v)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => onRecipe(const _Recipe()),
                  child: const Text('默认'),
                ),
                OutlinedButton(
                  onPressed: () => onRecipe(
                    const _Recipe(
                      tintAlpha: 0.03,
                      distortion: 0.2,
                      distortionWidth: 34,
                      blur: 0,
                      chromatic: 0.006,
                    ),
                  ),
                  child: const Text('清透（几乎无色）'),
                ),
                OutlinedButton(
                  onPressed: () => onRecipe(
                    const _Recipe(
                      tintAlpha: 0.22,
                      distortion: 0.08,
                      distortionWidth: 20,
                      blur: 9,
                    ),
                  ),
                  child: const Text('厚磨砂'),
                ),
                OutlinedButton(
                  onPressed: () => onRecipe(
                    const _Recipe(
                      tintAlpha: 0.06,
                      distortion: 0.42,
                      distortionWidth: 60,
                      blur: 1,
                      chromatic: 0.012,
                      lightIntensity: 1.8,
                      borderWidth: 1.6,
                    ),
                  ),
                  child: const Text('夸张折射'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 右侧控制抽屉
// ─────────────────────────────────────────────────────────────

class _ControlDrawer extends StatelessWidget {
  const _ControlDrawer({
    required this.scene,
    required this.content,
    required this.recipe,
    required this.onScene,
    required this.onContent,
    required this.onRecipe,
  });

  final _Scene scene;
  final _Content content;
  final _Recipe recipe;
  final ValueChanged<_Scene> onScene;
  final ValueChanged<_Content> onContent;
  final ValueChanged<_Recipe> onRecipe;

  @override
  Widget build(BuildContext context) {
    final impeller = ui.ImageFilter.isShaderFilterSupported;
    return Drawer(
      backgroundColor: const Color(0xF01A1C22),
      width: 420,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'liquid_glass_easy 4.1.1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: impeller ? Colors.greenAccent : Colors.orange,
                      ),
                    ),
                    child: Text(
                      impeller ? 'Impeller 真折射' : 'Skia 降级磨砂',
                      style: TextStyle(
                        color: impeller ? Colors.greenAccent : Colors.orange,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(
                '场景',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in _Scene.values)
                    ChoiceChip(
                      label: Text(s.label),
                      selected: scene == s,
                      onSelected: (_) => onScene(s),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                '玻璃背后的内容',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in _Content.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: content == c,
                      onSelected: (_) => onContent(c),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                '材质（所有场景共用这一份）',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: _RecipeKnobs(recipe: recipe, onRecipe: onRecipe),
            ),
          ],
        ),
      ),
    );
  }
}
