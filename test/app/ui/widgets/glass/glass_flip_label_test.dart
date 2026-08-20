import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';

void main() {
  const labels = ['视频', '图库', '帖子'];

  Future<void> pumpLabel(
    WidgetTester tester,
    ValueNotifier<double> progress,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: GlassFlipLabel(progress: progress, labels: labels),
          ),
        ),
      ),
    );
  }

  /// 翻牌用的 Transform（限定在组件内部，别把 MaterialApp 自带的算进来）。
  final flipTransform = find.descendant(
    of: find.byType(GlassFlipLabel),
    matching: find.byType(Transform),
  );

  /// 牌面在垂直方向被压扁的比例（1 = 正对观察者，0 = 完全侧对）。
  double faceSquash(WidgetTester tester) {
    final transform = tester.widget<Transform>(flipTransform);
    return transform.transform.getRow(1)[1].abs();
  }

  testWidgets('停在某一档时只出该档文案，且不套翻转变换', (tester) async {
    final progress = ValueNotifier<double>(0);
    addTearDown(progress.dispose);
    await pumpLabel(tester, progress);

    expect(find.text('视频'), findsOneWidget);
    expect(find.text('图库'), findsNothing);
    expect(flipTransform, findsNothing);

    progress.value = 2;
    await tester.pump();
    expect(find.text('帖子'), findsOneWidget);
    expect(find.text('视频'), findsNothing);
  });

  testWidgets('滑动前半程翻走旧文案，后半程翻进新文案，同一时刻只有一张牌', (tester) async {
    final progress = ValueNotifier<double>(0);
    addTearDown(progress.dispose);
    await pumpLabel(tester, progress);

    progress.value = 0.25;
    await tester.pump();
    expect(find.text('视频'), findsOneWidget);
    expect(find.text('图库'), findsNothing);
    final squashAtQuarter = faceSquash(tester);

    // 越接近交接点，牌面越接近侧对（压扁得越厉害）
    progress.value = 0.45;
    await tester.pump();
    expect(squashAtQuarter, greaterThan(faceSquash(tester)));

    progress.value = 0.75;
    await tester.pump();
    expect(find.text('图库'), findsOneWidget);
    expect(find.text('视频'), findsNothing);

    progress.value = 1;
    await tester.pump();
    expect(find.text('图库'), findsOneWidget);
    expect(flipTransform, findsNothing);
  });

  testWidgets('回滑时倒放：进度退回去，文案也跟着退回旧档', (tester) async {
    final progress = ValueNotifier<double>(0.75);
    addTearDown(progress.dispose);
    await pumpLabel(tester, progress);
    expect(find.text('图库'), findsOneWidget);

    progress.value = 0.25;
    await tester.pump();
    expect(find.text('视频'), findsOneWidget);
    expect(find.text('图库'), findsNothing);
  });

  testWidgets('越界进度被夹住，不会越出档位范围', (tester) async {
    final progress = ValueNotifier<double>(-0.4);
    addTearDown(progress.dispose);
    await pumpLabel(tester, progress);
    expect(find.text('视频'), findsOneWidget);

    progress.value = 4.2;
    await tester.pump();
    expect(find.text('帖子'), findsOneWidget);
  });

  testWidgets('翻牌途中宽度在相邻两档之间插值', (tester) async {
    final progress = ValueNotifier<double>(0);
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: GlassFlipLabel(
              progress: progress,
              labels: const ['短', '很长很长的一档文案'],
            ),
          ),
        ),
      ),
    );
    final double narrow = tester.getSize(find.byType(GlassFlipLabel)).width;

    progress.value = 1;
    await tester.pump();
    final double wide = tester.getSize(find.byType(GlassFlipLabel)).width;
    expect(wide, greaterThan(narrow));

    progress.value = 0.5;
    await tester.pump();
    final double middle = tester.getSize(find.byType(GlassFlipLabel)).width;
    expect(middle, greaterThan(narrow));
    expect(middle, lessThan(wide));
  });
}
