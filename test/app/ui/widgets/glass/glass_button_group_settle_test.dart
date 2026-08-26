import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 按钮组胶囊「进出编辑模式」的尺寸回归。
///
/// 2026-08-23 在 OnePlus Pad 上抓到：[LiquidGlassSettledTouch] 原本靠墙上时钟
/// 等 420ms 就量一次并把宽度**永久**锁死，而胶囊的宽度过渡（槽位 300ms +
/// 外壳追 340ms）那时根本没跑完。锁在半路之后里头的 Row 从此溢出、末尾那枚
/// 键被裁掉（debug 下常驻黄黑 OVERFLOWED 条）；退出时反过来锁得太宽，
/// `AnimatedSize(alignment: centerRight)` 把富余留在左边——最左侧凭空多出一个
/// 按钮大小的空位。
void main() {
  group('LiquidGlassSettledTouch 只锁静止后的尺寸', () {
    testWidgets('尺寸还在长的时候绝不上锁，最终锁到的是终值', (tester) async {
      final List<Size?> locked = <Size?>[];
      late StateSetter setOuter;
      double width = 100;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuter = setState;
                return LiquidGlassSettledTouch(
                  signature: 'fixed',
                  builder: (context, lockedSize) {
                    locked.add(lockedSize);
                    return SizedBox(width: width, height: 44);
                  },
                );
              },
            ),
          ),
        ),
      );

      // 模拟「宽度分很多帧慢慢长到 200」——正是按钮组过渡时的形状。
      for (var i = 0; i < 30; i++) {
        setOuter(() => width += 10 / 3);
        await tester.pump(const Duration(milliseconds: 16));
      }
      // 长完之后再多跑几帧，让探测确认静止。
      await tester.pumpAndSettle();

      final Size? finalLocked = locked.last;
      expect(finalLocked, isNotNull, reason: '尺寸稳定之后应该已经上锁');
      expect(
        finalLocked!.width,
        closeTo(width, 0.5),
        reason: '锁到的是过渡途中的宽度而不是终值——这正是那个 bug',
      );
      // 全程不该出现「锁了一个比终值小的宽度」这种不可恢复的状态。
      for (final Size? s in locked) {
        if (s == null) continue;
        expect(
          s.width,
          lessThanOrEqualTo(width + 0.5),
          reason: '中途锁死了一个偏小的宽度：$s（终值 $width）',
        );
      }

      timeDilation = 1.0;
    });

    testWidgets('signature 变化会解锁并重新量', (tester) async {
      final List<Size?> locked = <Size?>[];
      Widget build(String sig, double w) => MaterialApp(
        home: Scaffold(
          body: LiquidGlassSettledTouch(
            signature: sig,
            builder: (context, lockedSize) {
              locked.add(lockedSize);
              return SizedBox(width: w, height: 44);
            },
          ),
        ),
      );

      await tester.pumpWidget(build('a', 100));
      await tester.pumpAndSettle();
      expect(locked.last?.width, closeTo(100, 0.5));

      await tester.pumpWidget(build('b', 180));
      // 解锁那一帧必须先回到 null（自然布局），不能拿旧尺寸继续钉着
      expect(locked.last, isNull);
      await tester.pumpAndSettle();
      expect(locked.last?.width, closeTo(180, 0.5));

      timeDilation = 1.0;
    });
  });

  group('GlassButtonGroup 进出编辑模式', () {
    const Key moreKey = ValueKey('more');

    Future<void> pumpGroup(
      WidgetTester tester,
      GlassBackend backend, {
      required bool extra,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: LiquidGlassScope(
                backend: backend,
                child: GlassButtonGroup(
                  touchFlex: true,
                  touchFlexSignature: '$extra',
                  children: [
                    GlassIconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    GlassIconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                    GlassGroupSlot(
                      visible: extra,
                      child: GlassIconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {},
                      ),
                    ),
                    GlassIconButton(
                      key: moreKey,
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
    }

    /// 末尾那枚「更多」必须完整落在胶囊内——它被裁掉正是用户报的症状。
    void expectMoreInside(WidgetTester tester, String phase) {
      final Rect group = tester.getRect(find.byType(GlassButtonGroup));
      final Rect more = tester.getRect(find.byKey(moreKey));
      expect(
        more.right,
        lessThanOrEqualTo(group.right + 0.5),
        reason: '$phase：「更多」溢出胶囊右缘（胶囊 $group，按钮 $more）',
      );
      expect(more.left, greaterThanOrEqualTo(group.left - 0.5), reason: phase);
    }

    for (final backend in <GlassBackend>[
      GlassBackend.easyLens,
      GlassBackend.liquidWidgets,
    ]) {
      testWidgets('$backend：逐帧都不溢出，且收放回得去', (tester) async {
        await pumpGroup(tester, backend, extra: false);
        await tester.pumpAndSettle();
        final double narrow = tester
            .getSize(find.byType(GlassButtonGroup))
            .width;
        expectMoreInside(tester, '初始');

        await pumpGroup(tester, backend, extra: true);
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.takeException(), isNull, reason: '进编辑模式第 $i 帧');
          expectMoreInside(tester, '进编辑模式第 $i 帧');
        }
        await tester.pumpAndSettle();
        final double wide = tester.getSize(find.byType(GlassButtonGroup)).width;
        expect(
          wide,
          greaterThan(narrow + 30),
          reason: '胶囊没跟着长出一枚键的宽度：$narrow → $wide',
        );

        await pumpGroup(tester, backend, extra: false);
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.takeException(), isNull, reason: '退出编辑模式第 $i 帧');
          expectMoreInside(tester, '退出编辑模式第 $i 帧');
        }
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(GlassButtonGroup)).width,
          closeTo(narrow, 0.5),
          reason: '退出后胶囊没收回去，多出来的宽度会在左侧读成一个空按钮位',
        );
      });
    }
  });
}
