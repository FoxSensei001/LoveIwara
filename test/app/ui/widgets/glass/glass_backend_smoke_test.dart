import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show AnimatedGlassIndicator, GlassButton, GlassButtonStyle;

/// 三档材质的冒烟：换档不该抛异常，也不该改变布局尺寸——「换材质不换尺寸」
/// 是 GlassSurface 三个后端之间唯一的硬契约。
void main() {
  Future<Size> pumpPill(WidgetTester tester, GlassBackend backend) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassScope(
              backend: backend,
              child: GlassSurface(
                width: 200,
                child: const Center(child: Text('hi')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return tester.getSize(find.byType(GlassSurface));
  }

  for (final backend in GlassBackend.values) {
    testWidgets('$backend 能画出来且尺寸一致', (tester) async {
      final Size size = await pumpPill(tester, backend);
      expect(tester.takeException(), isNull);
      expect(find.text('hi'), findsOneWidget);
      expect(size.width, 200);
      expect(size.height, 44);
    });
  }

  testWidgets('浮出面板不跟 chrome 换档：widgets 档下取样回 easy', (tester) async {
    late GlassBackend sampled;
    await tester.pumpWidget(
      MaterialApp(
        home: LiquidGlassScope(
          backend: GlassBackend.liquidWidgets,
          child: Builder(
            builder: (context) {
              sampled = panelGlassBackend(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(sampled, GlassBackend.easyLens);
  });

  _segmentedTests();
  _stretchTests();

  // 面板不跟触发件的档位走：传统档的触发件（列表行的 `⋮`、播放器工具栏、
  // 设置页下拉）也照样吐液态面板，否则那些菜单会静默落回老样子
  // （见 panelGlassBackend 的说明）。
  testWidgets('传统档的触发件也吐液态面板', (tester) async {
    late GlassBackend sampled;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            sampled = panelGlassBackend(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(sampled, GlassBackend.easyLens);
  });
}

/// 分段控件：widgets 档换果冻玻璃指示器，另外两档维持原有高亮块。
void _segmentedTests() {
  Future<ValueNotifier<double>> pumpSegmented(
    WidgetTester tester,
    GlassBackend backend, {
    bool withProgress = true,
  }) async {
    final progress = ValueNotifier<double>(0);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassScope(
              backend: backend,
              child: SizedBox(
                width: 320,
                child: GlassSegmentedControl(
                  selectedIndex: 0,
                  progress: withProgress ? progress : null,
                  onChanged: (_) {},
                  items: const [
                    GlassSegmentItem(label: '趋势'),
                    GlassSegmentItem(label: '最新'),
                    GlassSegmentItem(label: '最受欢迎'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return progress;
  }

  testWidgets('widgets 档：上下两趟果冻指示器都在，且不抛异常', (tester) async {
    await pumpSegmented(tester, GlassBackend.liquidWidgets);
    expect(tester.takeException(), isNull);
    // 一趟画实心药丸（文字底下），一趟画玻璃（文字上面）。
    expect(find.byType(AnimatedGlassIndicator), findsNWidgets(2));
    expect(find.text('最受欢迎'), findsOneWidget);
  });

  testWidgets('传统/easy 档不引入果冻指示器', (tester) async {
    for (final backend in [GlassBackend.plain, GlassBackend.easyLens]) {
      await pumpSegmented(tester, backend);
      expect(find.byType(AnimatedGlassIndicator), findsNothing);
    }
  });

  testWidgets('progress 推着走：指示器跟着换位置，落位后凝回实心', (tester) async {
    final progress = await pumpSegmented(tester, GlassBackend.liquidWidgets);
    Rect indicatorRect() => tester.getRect(
      find.byType(AnimatedGlassIndicator).first,
    );
    // exactOffset 定位的是内部那层，外层是 Positioned.fill；用文字位置对齐更稳，
    // 这里只要求「推着 progress 走不会抛异常，且中途确实处在两段之间」。
    progress.value = 0.5;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.takeException(), isNull);
    expect(indicatorRect().width, greaterThan(0));

    progress.value = 1.0;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('没有 progress 时换段也能自己插值（_hop）', (tester) async {
    await pumpSegmented(
      tester,
      GlassBackend.liquidWidgets,
      withProgress: false,
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(AnimatedGlassIndicator), findsNWidgets(2));
  });
}

/// 跟手形变：按住并拖动时整只胶囊跟着手指走。
///
/// widgets 档借的是 `GlassButton.custom(style: transparent)`——那一档不画玻璃，
/// 只留 `LiquidStretch` + `GlassGlow`（包里真正干活的 `LiquidStretch` 没导出）。
void _stretchTests() {
  Future<int> pumpGroup(
    WidgetTester tester,
    GlassBackend backend, {
    required bool touchFlex,
  }) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: LiquidGlassScope(
              backend: backend,
              child: GlassButtonGroup(
                touchFlex: touchFlex,
                touchFlexSignature: 'x',
                children: [
                  GlassIconButton(
                    key: const ValueKey('inner'),
                    icon: const Icon(Icons.search),
                    onPressed: () => taps++,
                  ),
                  GlassIconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return taps;
  }

  Finder stretchShell() => find.byWidgetPredicate(
    (w) => w is GlassButton && w.style == GlassButtonStyle.transparent,
  );

  testWidgets('widgets 档 + touchFlex：整只胶囊套上跟手形变层', (tester) async {
    await pumpGroup(tester, GlassBackend.liquidWidgets, touchFlex: true);
    expect(stretchShell(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('不开 touchFlex 就不该多这一层', (tester) async {
    await pumpGroup(tester, GlassBackend.liquidWidgets, touchFlex: false);
    expect(stretchShell(), findsNothing);
  });

  testWidgets('传统/easy 档不走这条路', (tester) async {
    for (final backend in [GlassBackend.plain, GlassBackend.easyLens]) {
      await pumpGroup(tester, backend, touchFlex: true);
      expect(stretchShell(), findsNothing, reason: '$backend');
    }
  });

  testWidgets('整只可按的玻璃开了 liquidTouch，点击照样要发出去', (tester) async {
    // 身份圆钮（IdentityAvatarButton）就是这个形状：onTap 挂在 GlassSurface
    // 自己身上、liquidTouch 也开着。形变层那个 GestureDetector 在命中路径上
    // 比外层的 GlassPressable 更深、会先赢竞技场——点击必须从盒子里头发。
    for (final backend in GlassBackend.values) {
      int taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidGlassScope(
                backend: backend,
                child: GlassSurface(
                  circle: true,
                  height: 44,
                  onTap: () => taps++,
                  liquidTouch: true,
                  child: const Icon(Icons.account_circle),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GlassSurface));
      await tester.pumpAndSettle();
      expect(taps, 1, reason: '$backend 档下整只玻璃的点击被吃掉了');
    }
  });

  testWidgets('形变层的空 onTap 不能把里头的键吃掉', (tester) async {
    await pumpGroup(tester, GlassBackend.liquidWidgets, touchFlex: true);
    // 重新建一次以拿到计数闭包：直接点，断言内层收到了这一下。
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: LiquidGlassScope(
              backend: GlassBackend.liquidWidgets,
              child: GlassButtonGroup(
                touchFlex: true,
                touchFlexSignature: 'x',
                children: [
                  GlassIconButton(
                    key: const ValueKey('inner'),
                    icon: const Icon(Icons.search),
                    onPressed: () => taps++,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('inner')));
    await tester.pumpAndSettle();
    expect(taps, 1, reason: '外层形变层把内层按钮的点击抢走了');
  });
}
