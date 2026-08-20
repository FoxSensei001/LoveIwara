import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

void main() {
  Future<void> pumpMorph(WidgetTester tester, {required bool wide}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: GlassCapsuleMorph(
              child: wide
                  ? const SizedBox(
                      key: ValueKey('wide'),
                      width: 220,
                      height: GlassTokens.pillHeight,
                      child: Center(child: Text('Video Gallery Posts')),
                    )
                  : const SizedBox(
                      key: ValueKey('narrow'),
                      width: 90,
                      height: GlassTokens.pillHeight,
                      child: Center(child: Text('Posts')),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// 胶囊内每个内容各自的不透明度（AnimatedSwitcher 给每个 child 套的
  /// FadeTransition）。
  List<double> contentOpacities(WidgetTester tester) {
    return tester
        .widgetList<FadeTransition>(
          find.descendant(
            of: find.byType(GlassCapsuleMorph),
            matching: find.byType(FadeTransition),
          ),
        )
        .map((f) => f.opacity.value)
        .toList();
  }

  testWidgets('新旧内容是交接不是叠化：任何一帧都不会两边同时可读', (tester) async {
    await pumpMorph(tester, wide: false);
    await tester.pumpAndSettle();

    await pumpMorph(tester, wide: true);

    // 逐帧走完整段交接，检查「第二亮」的那层始终接近透明
    var frames = 0;
    double worstSecondBrightest = 0;
    while (frames < 40) {
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
      final opacities = contentOpacities(tester)..sort();
      if (opacities.length >= 2) {
        final second = opacities[opacities.length - 2];
        if (second > worstSecondBrightest) worstSecondBrightest = second;
      }
      if (opacities.isNotEmpty && opacities.last >= 1.0 &&
          opacities.length == 1) {
        break;
      }
    }

    expect(
      worstSecondBrightest,
      lessThan(0.02),
      reason: '同一帧里两层内容都可见 = 叠化糊字，交接时序被破坏了',
    );
  });

  testWidgets('交接结束后只剩新内容，宽度收敛到新内容的宽度', (tester) async {
    await pumpMorph(tester, wide: false);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('narrow')), findsOneWidget);

    await pumpMorph(tester, wide: true);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('narrow')), findsNothing);
    expect(find.byKey(const ValueKey('wide')), findsOneWidget);
    // 玻璃壳左右无 padding，宽度 = 内容宽度 + 两侧 0.6 描边
    expect(
      tester.getSize(find.byType(GlassCapsuleMorph)).width,
      moreOrLessEquals(221.2, epsilon: 0.5),
    );
  });
}
