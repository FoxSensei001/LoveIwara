import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';

/// 首次设置向导的版式闸门。
///
/// 报障是「引导页里的组件布局、样式都对不齐」，其中最扎眼的是顶部留白，
/// 而它有两种反向的错法，都**编译得过、analyze 干净**：
///
///   - 让得不够：内容被毛玻璃标题栏压住（原来拿 `AppService.titleBarHeight`
///     ——桌面自绘标题栏的 26——当 AppBar 高度算）；
///   - 让得太多：页面开了 `extendBodyBehindAppBar`，Scaffold 已经把
///     「状态栏 + AppBar」折进 body 的 `MediaQuery.padding.top`，谁要是在它
///     之上再加一次 AppBar 高度，首块内容就凭空往下掉一整条标题栏。
///
/// 所以这里卡的是一个**区间**：首块内容既要在标题栏之下，又不能低出一个
/// 块间距以上。另外两条：步骤不许自己手写顶部留白；卡片里的滚动件必须显式
/// 写 padding（`BoxScrollView` 在 padding == null 时会把 MediaQuery 的竖直
/// padding 自动补进来，在这页上就是白白多出 80 的空白）。
void main() {
  group('StepPageLayout 的顶部让位', () {
    /// 取内容第一块相对屏幕顶端的位置。
    Future<double> contentTop(
      WidgetTester tester, {
      required Size size,
      required double statusBar,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = FakeViewPadding(top: statusBar);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(toolbarHeight: kStepAppBarHeight),
            body: StepPageLayout(
              subtitle: '标题',
              description: '描述',
              content: const SizedBox(key: ValueKey('content'), height: 200),
            ),
          ),
        ),
      );

      return tester.getTopLeft(find.text('标题')).dy;
    }

    for (final size in const [
      Size(360, 800), // 窄屏手机
      Size(600, 900), // 大屏手机 / 小平板
      Size(1200, 900), // 桌面双栏
    ]) {
      testWidgets('${size.width.toInt()}px 宽时首块内容不被 AppBar 盖住', (tester) async {
        const statusBar = 24.0;
        final top = await contentTop(
          tester,
          size: size,
          statusBar: statusBar,
        );

        const appBarBottom = statusBar + kStepAppBarHeight;
        expect(
          top,
          inInclusiveRange(appBarBottom, appBarBottom + 32),
          reason:
              '首块内容必须落在标题栏正下方一个块间距处。\n'
              '  · 小于 $appBarBottom：让得不够，内容被 AppBar 压住'
              '（多半是又拿 AppService.titleBarHeight 当 AppBar 高度算了）。\n'
              '  · 大于 ${appBarBottom + 32}：让过头了，'
              'Scaffold 在 extendBodyBehindAppBar 下已经把 AppBar 高度折进'
              ' MediaQuery.padding.top，不要再自己加一遍。',
        );
      });
    }

    testWidgets('每一步的首块内容都停在同一条基线上', (tester) async {
      // 有图标的步骤（欢迎 / 完成）与没图标的步骤，标题以上的结构不同，
      // 但「页面顶端 → 第一块内容」的距离必须一致，翻页时才不会上下跳。
      const size = Size(360, 800);
      const statusBar = 24.0;

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: statusBar);
      addTearDown(tester.view.reset);

      Future<double> firstBlockTop({required bool withHero}) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(toolbarHeight: kStepAppBarHeight),
              body: StepPageLayout(
                subtitle: '标题',
                description: '描述',
                hero: withHero
                    ? const SizedBox(key: ValueKey('hero'), height: 72, width: 72)
                    : null,
                content: const SizedBox(height: 200),
              ),
            ),
          ),
        );
        final finder = withHero
            ? find.byKey(const ValueKey('hero'))
            : find.text('标题');
        return tester.getTopLeft(finder).dy;
      }

      expect(
        await firstBlockTop(withHero: true),
        await firstBlockTop(withHero: false),
      );
    });
  });

  test('卡片里的滚动件必须显式写 padding（零容忍）', () {
    // BoxScrollView（ListView / GridView）在 padding == null 时会把
    // MediaQuery 的竖直 padding 自动补进来。这页开了 extendBodyBehindAppBar，
    // 那个值是「状态栏 + AppBar」≈80——于是卡片里凭空多出一大片空白，
    // 看着像漏排了一整行。
    final offenders = <String>[];
    final boxScrollView = RegExp(
      r'(?<![A-Za-z0-9_])(GridView|ListView)(\.[A-Za-z]+)?\(',
    );
    for (final entity in Directory(
      'lib/app/ui/pages/first_time_setup',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final match in boxScrollView.allMatches(source)) {
        final tail = source.substring(
          match.end,
          (match.end + 400).clamp(0, source.length),
        );
        if (tail.contains('padding:')) continue;
        final line =
            '\n'.allMatches(source.substring(0, match.start)).length + 1;
        offenders.add('${entity.path.replaceAll(r'\', '/')}:$line');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          '这些滚动件没写 padding，会自动继承 MediaQuery 的竖直 padding'
          '（本页 ≈ 状态栏 + AppBar）：\n${offenders.join('\n')}',
    );
  });

  test('步骤不许自己手写顶部留白（零容忍）', () {
    final offenders = <String>[];
    final dir = Directory('lib/app/ui/pages/first_time_setup/widgets');
    for (final entity in dir.listSync()) {
      if (entity is! File || !entity.path.endsWith('_step_widget.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      final rel = entity.path.replaceAll(r'\', '/');

      if (!source.contains('StepPageLayout(')) {
        offenders.add('$rel：没有走 StepPageLayout');
      }
      // 顶部留白的两种手搓写法：直接拿桌面标题栏高度当 AppBar 高（原来的
      // 错法），或者自己去读状态栏 padding 再加一个常数。
      // （弹窗里的 SingleChildScrollView 是正当的，所以不查滚动容器本身。）
      if (source.contains('titleBarHeight')) {
        offenders.add('$rel：拿 titleBarHeight 当 AppBar 高度算留白');
      }
      if (source.contains('padding.top')) {
        offenders.add('$rel：自己算顶部留白');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          '向导的版式（滚动、上下留白、断点、块间距）只由 StepPageLayout 下发。\n'
          '步骤里再手写一份，页与页之间就又会差出一截：\n'
          '${offenders.join('\n')}',
    );
  });
}
