import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 玻璃菜单的「已激活状态色」（`accentColor`）与「行尾注」（`trailing`）。
///
/// 这两件是同一次机制改动的两半：状态色负责让用户一眼看出"这件事已经做过
/// 了"，尾注负责说清"做到什么程度"（已下载 2 个清晰度 / 在 3 个播放列表里）。
///
/// ⛔ 本文件里最重要的一条是 **量宽必须把尾注算进去**。
///
/// 液态档的面板尺寸是把 `_measureMenuPanelSize` 离线量出来的那一份**钉死**喂给
/// `GlassSurface` 的；传统档则是自然布局。于是漏算一个字段**不会报错，也不会
/// 在传统档露出任何破绽**，只有液态档下玻璃比内容窄一截、文字被约束成省略号。
/// 所以闸门盯的是**两档宽度必须一致**（与 `glass_surface_size_parity_test.dart`
/// 同一条思路：换档不许改布局）。
void main() {
  // 面板钉回传统档：液态面板会一直跑跟手形变，`pumpAndSettle` 等不到静止。
  // 本文件测的是颜色与尺寸，与材质无关。
  setUp(() => debugPanelGlassBackendOverride = GlassBackend.plain);
  tearDown(() => debugPanelGlassBackendOverride = null);

  Future<void> openMenu(
    WidgetTester tester, {
    required List<GlassMenuEntry> entries,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Builder(
              builder: (context) => SizedBox(
                width: 48,
                height: 44,
                child: GestureDetector(
                  key: const ValueKey('trigger'),
                  onTap: () => showGlassMenu<String>(
                    anchorContext: context,
                    entries: entries,
                  ),
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('trigger')));
    await tester.pumpAndSettle();
  }

  /// 点遮罩收起当前这张菜单。菜单是一条路由，不关掉就会挡住触发器，
  /// 同一个 test 里没法开第二张。
  Future<void> closeMenu(WidgetTester tester) async {
    await tester.tapAt(const Offset(700, 560));
    await tester.pumpAndSettle();
  }

  /// 一条行的底色：行本身那只 AnimatedContainer 的 decoration。
  Color? rowBackground(WidgetTester tester, String label) {
    final container = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    return (container.decoration as BoxDecoration?)?.color;
  }

  Color textColor(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;

  /// 一条行的实际宽度。面板本体是私有类量不到，而行才是真正会被截断的东西，
  /// 量它比量面板更贴近要防的缺陷。
  double rowWidth(WidgetTester tester, String label) => tester
      .getSize(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      )
      .width;

  group('accentColor：已激活的行整只换色', () {
    testWidgets('文字转成状态色，且行底垫了一层同色薄底', (tester) async {
      const accent = Color(0xFF00A0FF);
      await openMenu(
        tester,
        entries: const [
          GlassMenuOption<String>(
            value: 'done',
            label: '已下载',
            icon: Icons.download,
            accentColor: accent,
          ),
          GlassMenuOption<String>(
            value: 'plain',
            label: '分享',
            icon: Icons.share,
          ),
        ],
      );

      expect(textColor(tester, '已下载'), accent);
      final activeBg = rowBackground(tester, '已下载');
      expect(activeBg, isNotNull);
      expect(
        activeBg!.a,
        greaterThan(0),
        reason: '只换文字颜色在玻璃面板上太弱，必须有底色',
      );

      // 没有状态色的行保持原样：底透明、文字用默认前景。
      expect(rowBackground(tester, '分享')?.a ?? 0, 0);
      expect(textColor(tester, '分享'), isNot(accent));
    });

    testWidgets('⛔ 禁用与破坏性动作压过状态色——先得让人看出它是删除/点不动', (
      tester,
    ) async {
      const accent = Color(0xFF00A0FF);
      await openMenu(
        tester,
        entries: const [
          GlassMenuOption<String>(
            value: 'del',
            label: '删除',
            destructive: true,
            accentColor: accent,
          ),
          GlassMenuOption<String>(
            value: 'off',
            label: '不可用',
            enabled: false,
            accentColor: accent,
          ),
        ],
      );

      expect(textColor(tester, '删除'), isNot(accent));
      expect(textColor(tester, '不可用'), isNot(accent));
      expect(rowBackground(tester, '删除')?.a ?? 0, 0);
      expect(rowBackground(tester, '不可用')?.a ?? 0, 0);
    });

    testWidgets('accentColor 不带对勾——打勾读起来像"我选中了这一行"，语义是错的', (
      tester,
    ) async {
      await openMenu(
        tester,
        entries: const [
          GlassMenuOption<String>(
            value: 'done',
            label: '已下载',
            accentColor: Color(0xFF00A0FF),
          ),
        ],
      );
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });

  group('trailing：行尾注', () {
    testWidgets('尾注文字渲染出来，并跟着状态色走', (tester) async {
      const accent = Color(0xFF00A0FF);
      await openMenu(
        tester,
        entries: const [
          GlassMenuOption<String>(
            value: 'dl',
            label: '下载',
            accentColor: accent,
            trailing: '2 个清晰度',
          ),
        ],
      );

      expect(find.text('2 个清晰度'), findsOneWidget);
      expect(textColor(tester, '2 个清晰度'), accent);
    });

    testWidgets('⛔ 闸门：两档宽度必须一致——漏算尾注只有液态档会露馅', (tester) async {
      // 刻意留在 _maxPanelWidth(320) 以内：撞到上限两档都会被夹成 320，
      // 反而把漏算掩盖过去。
      const entries = [
        GlassMenuOption<String>(
          value: 'a',
          label: '下载',
          icon: Icons.download,
          trailing: '2 个清晰度',
        ),
      ];

      debugPanelGlassBackendOverride = GlassBackend.plain;
      await openMenu(tester, entries: entries);
      final double plainWidth = rowWidth(tester, '下载');
      await closeMenu(tester);

      debugPanelGlassBackendOverride = GlassBackend.liquidWidgets;
      await openMenu(tester, entries: entries);
      final double liquidWidth = rowWidth(tester, '下载');

      // 不是"完全相等"：量宽刻意比自然宽度多留一点余量（字体 hinting/取整，
      // 见 _measureMenuPanelSize 附近那条常量），所以不变量是**玻璃不许比内容窄**。
      expect(
        liquidWidth,
        greaterThanOrEqualTo(plainWidth),
        reason:
            '液态档的面板尺寸是钉死的量宽结果；量宽漏了尾注 → 玻璃比内容窄 → 文字被省略号吃掉',
      );
      // 也不该宽出一大截——那说明量宽把某样东西重复计了一遍。
      expect(liquidWidth, lessThan(plainWidth + 8));
    });

    testWidgets('尾注与对勾可以同时出现', (tester) async {
      await openMenu(
        tester,
        entries: const [
          GlassMenuOption<String>(
            value: 'a',
            label: '最近添加',
            selected: true,
            trailing: '12 条',
          ),
        ],
      );
      expect(find.text('12 条'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
