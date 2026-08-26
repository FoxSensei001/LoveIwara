import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 右侧侧边抽屉的外壳与路由契约。
///
/// 2026-08-26：筛选设置与已保存筛选/搜索**是同一只抽屉的两份内容**，都走
/// [showGlassSideDrawer]。之前两边一个是 `Scaffold.endDrawer`、一个是自建路由，
/// 圆角、遮罩范围、手势逐条不一致（用户逐条点出来过）。这里锁的就是那些
/// `endDrawer` 自带、换成路由后必须自己补的东西：
///   · 宽屏固定宽、窄屏按屏宽取百分比；
///   · 左边缘圆角（右侧抽屉只有靠内那条边露在外面）；
///   · 按住横拖甩出关闭，**移动端和 PC 都要有**，不到阈值弹回；
///   · Esc 能关（宽屏键盘用户的第一反应）；
///   · 重置钮在「没什么可重置」时是禁用的，不是消失。
void main() {
  /// 抽屉是推在 root Navigator 上的一条路由，读到的是**整个测试窗口**的尺寸，
  /// 不是某个子树里套的 MediaQuery——所以宽窄屏必须改物理窗口来模拟。
  void useSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget host({required Widget child}) {
    return TranslationProvider(child: MaterialApp(home: child));
  }

  group('glassSideDrawerWidth', () {
    testWidgets('宽屏固定 380：再宽也不多占，身后的列表要看得见', (tester) async {
      late double width;
      useSurface(tester, const Size(1600, 900));
      await tester.pumpWidget(
        host(
          child: Builder(
            builder: (context) {
              width = glassSideDrawerWidth(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(width, kGlassSideDrawerWideWidth);
    });

    testWidgets('窄屏取屏宽 88%：左边留一条能瞥见列表 + 点击关闭的余量', (tester) async {
      late double width;
      useSurface(tester, const Size(400, 900));
      await tester.pumpWidget(
        host(
          child: Builder(
            builder: (context) {
              width = glassSideDrawerWidth(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(width, closeTo(400 * 0.88, 0.001));
      expect(width, lessThan(400), reason: '整屏宽就没有「点旁边关掉」这一说了');
    });

    testWidgets('窄屏也封顶 460：横屏手机 / 小平板不该被一只筛选面板铺满', (tester) async {
      late double width;
      useSurface(tester, const Size(599, 400));
      await tester.pumpWidget(
        host(
          child: Builder(
            builder: (context) {
              width = glassSideDrawerWidth(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(width, 460);
    });
  });

  group('GlassFilterDrawerShell', () {
    Future<void> openShell(
      WidgetTester tester, {
      VoidCallback? onReset,
      Size size = const Size(1200, 800),
    }) async {
      useSurface(tester, size);
      late BuildContext hostContext;
      await tester.pumpWidget(
        host(
          child: Builder(
            builder: (context) {
              hostContext = context;
              return const Scaffold(body: SizedBox.expand());
            },
          ),
        ),
      );
      showGlassSideDrawer<void>(
        context: hostContext,
        builder: (_) => GlassFilterDrawerShell(
          title: '筛选',
          subtitle: '改动即时生效',
          onReset: onReset,
          children: const [
            GlassFilterSection(title: '分区', child: Text('内容')),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('标题 / 副标题 / 分区都画出来了', (tester) async {
      await openShell(tester);
      expect(find.text('筛选'), findsOneWidget);
      expect(find.text('改动即时生效'), findsOneWidget);
      expect(find.text('分区'), findsOneWidget);
      expect(find.text('内容'), findsOneWidget);
    });

    testWidgets('抽屉贴右：左边缘落在「屏宽 - 抽屉宽」上', (tester) async {
      await openShell(tester);
      final rect = tester.getRect(find.byType(Drawer));
      expect(rect.width, kGlassSideDrawerWideWidth);
      expect(rect.right, closeTo(1200, 0.5));
    });

    testWidgets('没什么可重置时重置钮禁用（而不是整枚消失）', (tester) async {
      await openShell(tester);
      final reset = tester.widget<GlassIconButton>(
        find.byWidgetPredicate(
          (w) => w is GlassIconButton && w.icon is Icon &&
              (w.icon as Icon).icon == Icons.restart_alt,
        ),
      );
      expect(reset.onPressed, isNull);
    });

    testWidgets('有东西可重置时重置钮可点，点了会回调', (tester) async {
      var reset = 0;
      await openShell(tester, onReset: () => reset++);
      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();
      expect(reset, 1);
    });

    testWidgets('关闭钮关掉抽屉', (tester) async {
      await openShell(tester);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('Esc 关掉抽屉（宽屏键盘用户的第一反应）', (tester) async {
      await openShell(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('左边缘有圆角（右侧抽屉只有靠内那条边露在外面）', (tester) async {
      await openShell(tester);
      final shape =
          tester.widget<Drawer>(find.byType(Drawer)).shape
              as RoundedRectangleBorder;
      final radius = shape.borderRadius.resolve(TextDirection.ltr);
      expect(radius.topLeft.x, kGlassSideDrawerCornerRadius);
      expect(radius.bottomLeft.x, kGlassSideDrawerCornerRadius);
      expect(radius.topRight, Radius.zero, reason: '贴屏那侧不该有圆角');
      expect(radius.bottomRight, Radius.zero);
    });

    for (final (label, size) in <(String, Size)>[
      ('窄屏', Size(400, 800)),
      ('宽屏', Size(1200, 800)),
    ]) {
      testWidgets('$label 右滑甩出：滑过阈值就关', (tester) async {
        await openShell(tester, size: size);
        expect(find.byType(Drawer), findsOneWidget);
        await tester.drag(find.text('筛选'), const Offset(300, 0));
        await tester.pumpAndSettle();
        expect(
          find.byType(Drawer),
          findsNothing,
          reason: '$label 也要能按住横拖把抽屉甩出去',
        );
      });

      testWidgets('$label 右滑没过阈值：弹回去，抽屉还在', (tester) async {
        await openShell(tester, size: size);
        await tester.drag(
          find.text('筛选'),
          const Offset(20, 0),
          // 慢拖，别让甩出速度替判定做主
          touchSlopX: 0,
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(find.byType(Drawer), findsOneWidget);
      });
    }
  });
}
