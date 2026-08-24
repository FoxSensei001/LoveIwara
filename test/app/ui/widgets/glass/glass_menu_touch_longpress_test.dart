import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// [showGlassMenu] 上这次补齐的三件事：
///   - 跟手形变默认开（传统档除外，那一档没有形变、开了只会把面板尺寸从
///     「抱内容」改成静态量出来的，白担一份测量误差）；
///   - [GlassMenuOption.leading] 塞进固定槽位后**也能静态量出尺寸**，带头像的
///     菜单（特别关注选人）因此也能开跟手形变；
///   - [GlassMenuOption.onLongPress]：长按关面板并跑动作，同时整只关掉滑动取焦。
void main() {
  /// 弹一张菜单；返回它的结果 future。
  Future<Future<String?>> openMenu(
    WidgetTester tester, {
    required List<GlassMenuEntry> entries,
    GlassBackend backend = GlassBackend.plain,
  }) async {
    late Future<String?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassScope(
            backend: backend,
            child: Align(
              alignment: Alignment.topLeft,
              child: Builder(
                builder: (context) => SizedBox(
                  width: 48,
                  height: 44,
                  child: GestureDetector(
                    key: const ValueKey('trigger'),
                    onTap: () {
                      result = showGlassMenu<String>(
                        anchorContext: context,
                        entries: entries,
                      );
                    },
                    child: const ColoredBox(color: Color(0xFF000000)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('trigger')));
    await tester.pumpAndSettle();
    return result;
  }

  /// 面板那块玻璃（触发件不是 GlassSurface，所以全场只有这一块）。
  GlassSurface panel(WidgetTester tester) =>
      tester.widget<GlassSurface>(find.byType(GlassSurface));

  /// 焦点底板：面板里唯一一块 AnimatedPositioned。
  Finder pill() => find.byType(AnimatedPositioned);

  testWidgets('液态档：跟手形变默认开，尺寸被钉死', (tester) async {
    await openMenu(
      tester,
      backend: GlassBackend.liquidWidgets,
      entries: <GlassMenuEntry>[
        const GlassMenuOption<String>(value: 'a', label: '刷新'),
        const GlassMenuOption<String>(value: 'b', label: '回到顶部'),
      ],
    );
    final GlassSurface p = panel(tester);
    expect(p.liquidTouch, isTrue);
    // touch 要求尺寸已经钉死（见 LiquidGlassBox.touchFlex）。
    expect(p.width, isNotNull);
    expect(p.height, isNotNull);
  });

  // 触发件在传统档里（列表行的 `⋮`、播放器工具栏、设置页下拉——绝大多数下拉
  // 都是这种）也照样吐液态面板。2026-08-24 之前面板跟着触发件的档位走，于是这
  // 些新换的菜单全部静默落回传统档：没折射、没长按蠕动，跟旧的
  // PopupMenuButton 看不出区别（见 panelGlassBackend 的说明）。
  testWidgets('触发件是传统档：面板照样是液态的，跟手形变照样开', (tester) async {
    await openMenu(
      tester,
      entries: <GlassMenuEntry>[
        const GlassMenuOption<String>(value: 'a', label: '刷新'),
        const GlassMenuOption<String>(value: 'b', label: '回到顶部'),
      ],
    );
    final GlassSurface p = panel(tester);
    expect(p.liquidTouch, isTrue);
    // 跟手形变要求精确尺寸，静态量出来喂给 lens（见 _measureMenuPanelSize）。
    expect(p.width, isNotNull);
    expect(p.height, isNotNull);
  });

  testWidgets('钉回传统档时才不开跟手形变（测试专用逃生口）', (tester) async {
    debugPanelGlassBackendOverride = GlassBackend.plain;
    addTearDown(() => debugPanelGlassBackendOverride = null);
    await openMenu(
      tester,
      entries: <GlassMenuEntry>[
        const GlassMenuOption<String>(value: 'a', label: '刷新'),
        const GlassMenuOption<String>(value: 'b', label: '回到顶部'),
      ],
    );
    final GlassSurface p = panel(tester);
    expect(p.liquidTouch, isFalse);
    expect(p.width, isNull);
    expect(p.height, isNull);
  });

  testWidgets('带 leading 的条目也能量出尺寸（特别关注选人那张菜单）', (tester) async {
    await openMenu(
      tester,
      backend: GlassBackend.liquidWidgets,
      entries: <GlassMenuEntry>[
        const GlassMenuOption<String>(
          value: 'all',
          label: '全部',
          leading: CircleAvatar(radius: 11),
        ),
        const GlassMenuOption<String>(
          value: 'u1',
          label: '某位作者',
          leading: CircleAvatar(radius: 11),
        ),
      ],
    );
    // 以前 leading 一出现就返回 null（量不出来）→ 开不了 touch。
    expect(panel(tester).liquidTouch, isTrue);
  });

  group('GlassMenuOption.onLongPress', () {
    testWidgets('长按：关掉面板返回 null，再跑动作', (tester) async {
      var fired = 0;
      final Future<String?> result = await openMenu(
        tester,
        entries: <GlassMenuEntry>[
          const GlassMenuOption<String>(value: 'a', label: 'Option A'),
          GlassMenuOption<String>(
            value: 'b',
            label: 'Option B',
            onLongPress: () => fired++,
          ),
        ],
      );

      await tester.longPress(find.text('Option B'));
      await tester.pumpAndSettle();

      expect(fired, 1);
      // 长按是「离开这张菜单去别处」，不是选中。
      expect(await result, isNull);
      expect(find.text('Option A'), findsNothing);
    });

    testWidgets('长按之外的普通点按照常选中', (tester) async {
      final Future<String?> result = await openMenu(
        tester,
        entries: <GlassMenuEntry>[
          const GlassMenuOption<String>(value: 'a', label: 'Option A'),
          GlassMenuOption<String>(
            value: 'b',
            label: 'Option B',
            onLongPress: () {},
          ),
        ],
      );
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();
      expect(await result, 'a');
    });

    testWidgets('有长按条目时滑动取焦整只让位（两个手势不能抢同一次按住）', (tester) async {
      // 按住不放期间液态面板一直在跑跟手形变，pumpAndSettle 等不到静止。
      debugPanelGlassBackendOverride = GlassBackend.plain;
      addTearDown(() => debugPanelGlassBackendOverride = null);
      await openMenu(
        tester,
        entries: <GlassMenuEntry>[
          const GlassMenuOption<String>(value: 'a', label: 'Option A'),
          GlassMenuOption<String>(
            value: 'b',
            label: 'Option B',
            onLongPress: () {},
          ),
        ],
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option A')),
      );
      await tester.pumpAndSettle();
      expect(pill(), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
