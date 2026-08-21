import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';

/// 设置树改真嵌套路由后的**返回矩阵**回归网。
///
/// 这一版是单 commit 落地的，出回归没法 bisect，所以把「点进去 / 退回来」的
/// 每一条路径都钉在这里。历史实现（宽屏内部 Navigator + 窄屏手写 _pageStack +
/// currentPage 索引三套栈手工编排）在这些用例上是全红的。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------------
  // A. 路由语义：用镜像真实形状的最小路由树验证嵌套 Shell 的返回行为。
  //    页面用桩件，这样不必拉起 GetX 服务；路径全部取自 SettingsSection，
  //    改路径命名会直接让用例失败。
  // ------------------------------------------------------------------
  group('嵌套 Shell 的返回语义', () {
    late GlobalKey<NavigatorState> homeShellKey;
    late GlobalKey<NavigatorState> settingsKey;

    GoRouter buildRouter() {
      homeShellKey = GlobalKey<NavigatorState>(debugLabel: 'homeShell');
      settingsKey = GlobalKey<NavigatorState>(debugLabel: 'settingsShell');
      return GoRouter(
        initialLocation: '/',
        routes: [
          ShellRoute(
            navigatorKey: homeShellKey,
            builder: (context, state, child) => Scaffold(body: child),
            routes: [
              GoRoute(path: '/', builder: (_, _) => const Text('HOME')),
              GoRoute(
                path: '/video/:id',
                builder: (_, _) => const Text('VIDEO'),
              ),
              ShellRoute(
                navigatorKey: settingsKey,
                builder: (context, state, child) => Column(
                  children: [
                    const Text('NAV-PANE'),
                    Expanded(child: child),
                  ],
                ),
                routes: [
                  GoRoute(
                    path: kSettingsRootPath,
                    builder: (_, _) => const Text('LIST'),
                  ),
                  for (final section in SettingsSection.values)
                    if (section.isAvailable)
                      GoRoute(
                        path: section.path,
                        builder: (_, _) => Text('SECTION:${section.name}'),
                        routes: [
                          if (section == SettingsSection.translation)
                            GoRoute(
                              path: 'ai',
                              builder: (_, _) => const Text('SUB:ai'),
                            ),
                          if (section == SettingsSection.display)
                            GoRoute(
                              path: 'layout',
                              builder: (_, _) => const Text('SUB:layout'),
                            ),
                        ],
                      ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    Future<GoRouter> pump(WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('深链直达分区：栈里只有那一页，返回直接离开设置', (tester) async {
      final router = await pump(tester);

      // 抽屉「内容屏蔽」这类入口。go_router 的 push 只压一页
      // （ImperativeRouteMatch 取 matchList.last），所以不会先落到设置列表——
      // 历史实现要靠 _isDeepLinkEntry 特判 + 直接 Navigator.pop 才能做到，
      // 而那段特判自己会和 canPopInternally() 互相绕成死循环。
      router.push(SettingsSection.block.path);
      await tester.pumpAndSettle();
      expect(find.text('SECTION:block'), findsOneWidget);
      expect(find.text('NAV-PANE'), findsOneWidget);
      expect(settingsKey.currentState!.canPop(), isFalse);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('当前 location 必须读 router.state，不能读 routeInformationProvider', (
      tester,
    ) async {
      final router = await pump(tester);

      router.push(SettingsSection.block.path);
      await tester.pumpAndSettle();

      // SettingsNavigation.currentLocation 走的就是这条。
      expect(router.state.uri.path, SettingsSection.block.path);

      // 踩过的坑：RouteMatchList.uri 的文档明确「只反映非 ImperativeRouteMatch
      // 的匹配」，而设置树全是 push 进来的，所以它会一直停在进设置之前的地址。
      // 早先的实现用它做「宽屏是否停在 /settings」的判断，导致自动选中被
      // 永久挡掉、右栏恒空白。
      expect(router.routeInformationProvider.value.uri.path, '/');
    });

    testWidgets('窄屏：列表 → 分区 → 返回回到列表 → 再返回离开设置', (tester) async {
      final router = await pump(tester);

      router.push(kSettingsRootPath);
      await tester.pumpAndSettle();
      expect(find.text('LIST'), findsOneWidget);
      expect(settingsKey.currentState!.canPop(), isFalse);

      router.push(SettingsSection.player.path);
      await tester.pumpAndSettle();
      expect(find.text('SECTION:player'), findsOneWidget);
      // 关键：新页进的是**设置自己的** Navigator，而不是宿主 Shell。
      expect(settingsKey.currentState!.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('LIST'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('三级页逐层返回', (tester) async {
      final router = await pump(tester);

      router.push(kSettingsRootPath);
      await tester.pumpAndSettle();
      router.push(SettingsSection.translation.path);
      await tester.pumpAndSettle();
      router.push(SettingsSubRoutes.translationAi);
      await tester.pumpAndSettle();
      expect(find.text('SUB:ai'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('SECTION:translation'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('LIST'), findsOneWidget);
    });

    testWidgets('宽屏：replace 掉列表页后，从分区返回直接离开设置', (tester) async {
      final router = await pump(tester);

      router.push(kSettingsRootPath);
      await tester.pumpAndSettle();
      // SettingsShell 的宽屏自动选中走的就是 replace：栈里不留 /settings 那页，
      // 于是返回不会先落到一个空白右栏。
      router.replace(SettingsSection.network.path);
      await tester.pumpAndSettle();
      expect(find.text('LIST'), findsNothing);
      expect(settingsKey.currentState!.canPop(), isFalse);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('宽屏切分区：先收三级页再 pushReplacement，右栏栈深恒为 1', (tester) async {
      final router = await pump(tester);

      router.push(kSettingsRootPath);
      await tester.pumpAndSettle();
      router.replace(SettingsSection.display.path);
      await tester.pumpAndSettle();

      // 钻进三级页
      router.push(SettingsSubRoutes.displayLayout);
      await tester.pumpAndSettle();
      expect(settingsKey.currentState!.canPop(), isTrue);

      // 此时点左栏另一个分区：SettingsNavigation._collapseToSectionRoot 的动作
      var safety = 8;
      while (safety-- > 0 && settingsKey.currentState!.canPop()) {
        router.pop();
        await tester.pumpAndSettle();
      }
      router.pushReplacement(SettingsSection.theme.path);
      await tester.pumpAndSettle();

      expect(find.text('SECTION:theme'), findsOneWidget);
      expect(find.text('SUB:layout'), findsNothing);
      // 没有留下 display 这一层：右栏永远从分区根开始
      expect(settingsKey.currentState!.canPop(), isFalse);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('go_router 无法一次性移除多层嵌套 Shell —— 别再写「一次弹掉整棵设置树」', (
      tester,
    ) async {
      final router = await pump(tester);

      router.push(kSettingsRootPath);
      await tester.pumpAndSettle();
      router.replace(SettingsSection.translation.path);
      await tester.pumpAndSettle();

      // 深度 1：宿主 Shell 弹掉设置壳这一页 —— 有效。
      homeShellKey.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);

      // 深度 2：同样的调用**被静默吞掉**。
      // 根因在 RouteMatchList.remove(shellMatch)：嵌套 Shell 里还有多层匹配时
      // 它找不到要移除的东西，直接 `return this`，pop 就没了。
      // 设置页左栏的返回钮曾经走这条路，表现就是「进三级页后点了没反应」。
      router.push(kSettingsRootPath);
      await tester.pumpAndSettle();
      router.replace(SettingsSection.translation.path);
      await tester.pumpAndSettle();
      router.push(SettingsSubRoutes.translationAi);
      await tester.pumpAndSettle();

      homeShellKey.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(
        router.state.uri.path,
        SettingsSubRoutes.translationAi,
        reason: 'go_router 若哪天修了这个限制，这条会红——那时才可以简化左栏返回逻辑',
      );

      // 正确做法：逐层退（左栏返回钮现在走 AppService.tryPop 这条链）。
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('SECTION:translation'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('从 Shell 内的详情页进设置，详情页仍在栈里', (tester) async {
      final router = await pump(tester);

      router.push('/video/abc');
      await tester.pumpAndSettle();
      router.push(SettingsSection.diagnostics.path);
      await tester.pumpAndSettle();
      expect(find.text('SECTION:diagnostics'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('VIDEO'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------
  // B. 真实 appRouter 的结构：路径拼对了没、旧路由删干净了没。
  // ------------------------------------------------------------------
  group('appRouter 里的设置路由', () {
    test('每个可用分区都注册了路由，且 location 与 SettingsSection.path 一致', () {
      expect(appRouter.namedLocation('settings'), kSettingsRootPath);
      for (final section in SettingsSection.values.where((s) => s.isAvailable)) {
        expect(
          appRouter.namedLocation(section.routeName),
          section.path,
          reason: '分区 ${section.name} 的路由 location 与枚举里的 path 对不上',
        );
      }
    });

    test('三级页挂在所属分区下面，路径即层级', () {
      expect(
        appRouter.namedLocation('settings_translation_google'),
        SettingsSubRoutes.translationGoogle,
      );
      expect(
        appRouter.namedLocation('settings_translation_ai'),
        SettingsSubRoutes.translationAi,
      );
      expect(
        appRouter.namedLocation('settings_translation_deeplx'),
        SettingsSubRoutes.translationDeeplx,
      );
      expect(
        appRouter.namedLocation('settings_display_layout'),
        SettingsSubRoutes.displayLayout,
      );
      expect(
        appRouter.namedLocation('settings_display_navigation_order'),
        SettingsSubRoutes.displayNavigationOrder,
      );
      expect(
        appRouter.namedLocation('settings_about_changelog'),
        SettingsSubRoutes.aboutChangelog,
      );
      expect(
        appRouter.namedLocation('settings_diagnostics_logs'),
        SettingsSubRoutes.diagnosticsLogs,
      );
    });

    test('布局 / 导航排序不再有顶层路由（已收编进设置树）', () {
      expect(() => appRouter.namedLocation('layout_settings'), throwsA(anything));
      expect(
        () => appRouter.namedLocation('navigation_order_settings'),
        throwsA(anything),
      );
    });

    test('表情库保留顶层路由：它是共享资源页，不属于设置树', () {
      expect(appRouter.namedLocation('emoji_library'), '/emoji_library');
    });
  });

  // ------------------------------------------------------------------
  // C. SettingsSection 自身。
  // ------------------------------------------------------------------
  group('SettingsSection', () {
    test('path 无重复', () {
      final paths = SettingsSection.values.map((s) => s.path).toList();
      expect(paths.toSet().length, paths.length);
    });

    test('fromLocation：分区页与三级页都推回所属分区', () {
      expect(
        SettingsSection.fromLocation(SettingsSection.translation.path),
        SettingsSection.translation,
      );
      expect(
        SettingsSection.fromLocation(SettingsSubRoutes.translationAi),
        SettingsSection.translation,
      );
      expect(
        SettingsSection.fromLocation(SettingsSubRoutes.displayNavigationOrder),
        SettingsSection.display,
      );
      expect(SettingsSection.fromLocation(kSettingsRootPath), isNull);
      expect(SettingsSection.fromLocation('/'), isNull);
      expect(SettingsSection.fromLocation('/settings_page'), isNull);
      // 前缀相同但不是设置树内的路径不能误判
      expect(SettingsSection.fromLocation('/settingsfoo/bar'), isNull);
    });

    test('分组覆盖全部分区且不重不漏', () {
      final grouped = settingsSectionGroups
          .expand((g) => g.sections)
          .toList();
      expect(grouped.toSet(), SettingsSection.values.toSet());
      expect(grouped.length, SettingsSection.values.length);
    });

    test('firstAvailable 落在第一个可用分区上', () {
      final expected = settingsSectionGroups
          .expand((g) => g.sections)
          .firstWhere((s) => s.isAvailable);
      expect(SettingsSection.firstAvailable, expected);
    });
  });
}
