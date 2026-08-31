import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/my_app.dart' show buildThemeData;
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

/// 桌面端推一页带液态玻璃的路由时，转场**不许**在 paint 里把渲染树标脏。
///
/// 2026-08-30 报障（Windows）：
///
/// ```
/// 'package:flutter/src/rendering/object.dart': Failed assertion:
///   'owner == null || !owner!.debugDoingPaint': is not true.
/// #3 _RenderLightweightGlass.onTransformChanged
/// #5 GeometryTransformTrackingLayer.addToScene
/// #36 _RenderSnapshotWidget._paintAndDetachToImage
/// ```
///
/// 因果见 `buildThemeData` 里 `pageTransitionsTheme` 那段：Zoom 转场默认把页面
/// `toImageSync()` 成位图，那次建场景发生在父级 paint 期间，而液态玻璃的渲染
/// 对象在场景里发现变换变了就 `markNeedsPaint()`。修法是桌面端关掉快照。
///
/// ⚠️ **这条断言在单测里复现不出来**（试过：静止页只栅格化一次，而追踪层第一
/// 帧不回调；给页面加上逐帧重绘也没能凑齐条件）。所以下面测的是**接线**——
/// 桌面端那两档确实关了快照、其余平台一个字没动——外加一趟转场冒烟。真正的
/// 验证只能上 Windows 跑。
void main() {
  Widget glassPage() {
    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: 56,
        header: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassSurface(width: 44, circle: true, child: SizedBox()),
              SizedBox(width: 8),
              Expanded(child: GlassSurface(child: SizedBox())),
            ],
          ),
        ),
        // 底板逐帧重绘：静止页只被栅格化一次，而追踪层第一帧不回调
        // （`_lastTransform == null`），那样连碰都碰不到出事的那条路。真实页面
        // 在转场那几百毫秒里本来就在动（列表加载、shimmer、Obx 重建）。
        // ——即便如此单测里也没能把断言逼出来，见文件头那段 ⚠️。
        body: const _RepaintingBody(),
      ),
    );
  }

  Future<void> pushAndAnimate(WidgetTester tester) async {
    await tester.tap(find.text('go'));
    // 转场逐帧走完：快照是在动画途中拍的，一步到位会跳过出事的那几帧。
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
  }

  test('桌面端关快照，其余平台照抄框架默认', () {
    final theme = buildThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
    );
    final builders = theme.pageTransitionsTheme.builders;

    for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
      final builder = builders[platform];
      expect(builder, isA<ZoomPageTransitionsBuilder>(), reason: '$platform');
      expect(
        (builder! as ZoomPageTransitionsBuilder).allowSnapshotting,
        isFalse,
        reason: '$platform 的转场快照必须是关的',
      );
    }

    // 缺项会被兜底成**带快照**的 Zoom，所以这三个平台必须写全、且维持原样。
    expect(
      builders[TargetPlatform.android],
      isA<PredictiveBackPageTransitionsBuilder>(),
    );
    expect(
      builders[TargetPlatform.iOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
    expect(
      builders[TargetPlatform.macOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
  });

  testWidgets('windows：Zoom 转场推入玻璃页面不报 debugDoingPaint', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => glassPage()),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await pushAndAnimate(tester);

    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}

/// 一块每帧都重绘的底板（见 [_RepaintingBody] 在页面里那段注释）。
class _RepaintingBody extends StatefulWidget {
  const _RepaintingBody();

  @override
  State<_RepaintingBody> createState() => _RepaintingBodyState();
}

class _RepaintingBodyState extends State<_RepaintingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ColoredBox(
        color: Color.lerp(
          const Color(0xFFEEEEEE),
          const Color(0xFFBBBBBB),
          _controller.value,
        )!,
        child: const SizedBox.expand(),
      ),
    );
  }
}
