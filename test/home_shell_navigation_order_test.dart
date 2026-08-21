import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/routes/home_shell_navigation.dart';

void main() {
  group('HomeShellNavigation', () {
    test('normalizeOrder drops unknowns, de-dupes, appends canonical', () {
      final normalized = HomeShellNavigation.normalizeOrder([
        'gallery',
        'video',
        'gallery',
        'unknown',
      ]);

      expect(
        normalized,
        equals(<String>['gallery', 'video', 'subscription', 'community']),
      );
    });

    test('displayIndex <-> branchIndex mapping follows key, not position', () {
      final order = <String>['gallery', 'video', 'subscription', 'community'];

      expect(
        HomeShellNavigation.branchIndexFromDisplayIndex(0, order),
        equals(1),
      );
      expect(
        HomeShellNavigation.branchIndexFromDisplayIndex(1, order),
        equals(0),
      );
      expect(
        HomeShellNavigation.displayIndexFromBranchIndex(1, order),
        equals(0),
      );
      expect(
        HomeShellNavigation.displayIndexFromBranchIndex(0, order),
        equals(1),
      );
    });

    test('normalizeHidden keeps only hideable keys, de-dupes', () {
      expect(
        HomeShellNavigation.normalizeHidden([
          'community',
          'community',
          'video', // not hideable
          'unknown',
          42,
        ]),
        equals(<String>['community']),
      );
      expect(HomeShellNavigation.normalizeHidden(null), isEmpty);
      expect(HomeShellNavigation.normalizeHidden('community'), isEmpty);
    });

    test('visibleOrder removes hidden keys, preserves order', () {
      final order = <String>['video', 'gallery', 'subscription', 'community'];

      expect(
        HomeShellNavigation.visibleOrder(order, <String>['community']),
        equals(<String>['video', 'gallery', 'subscription']),
      );
      expect(
        HomeShellNavigation.visibleOrder(order, const <String>[]),
        equals(order),
      );
    });

    test('path mapping stays consistent with branch mapping', () {
      for (final key in HomeShellNavigation.canonicalOrder) {
        final index = HomeShellNavigation.branchIndexForKey(key);
        expect(HomeShellNavigation.pathForKey(key), isNotEmpty);
        expect(
          HomeShellNavigation.pathForBranchIndex(index),
          equals(HomeShellNavigation.pathForKey(key)),
        );
      }
    });

    // ---- 论坛 + 新闻 -> 社区 的配置迁移 ----
    //
    // 老用户存量配置里还写着 `forum` / `news`。合并后这两个键都不存在了，
    // 如果只是「丢弃未知键 + 补齐缺失键」，社区栏会被追加到**最后一位**，
    // 自定义过顺序的用户会莫名其妙发现栏目位置变了。
    group('legacy forum/news migration', () {
      test('folds legacy keys in place, keeping the earliest position', () {
        expect(
          HomeShellNavigation.normalizeOrder([
            'forum',
            'video',
            'news',
            'gallery',
          ]),
          equals(<String>['community', 'video', 'gallery', 'subscription']),
        );
      });

      test('a lone legacy key still resolves to community', () {
        expect(
          HomeShellNavigation.normalizeOrder(['news', 'video']),
          equals(<String>['community', 'video', 'gallery', 'subscription']),
        );
        expect(HomeShellNavigation.branchIndexForKey('forum'), equals(3));
        expect(HomeShellNavigation.branchIndexForKey('news'), equals(3));
        expect(HomeShellNavigation.pathForKey('forum'), equals('/community'));
      });

      test('hides community only when BOTH legacy keys were hidden', () {
        // 两个都藏过 -> 合并后整条社区栏保持隐藏
        expect(
          HomeShellNavigation.normalizeHidden(['forum', 'news']),
          equals(<String>['community']),
        );
        // 只藏了新闻 -> 当初论坛还看得见，迁移后社区栏不该消失
        expect(HomeShellNavigation.normalizeHidden(['news']), isEmpty);
        expect(HomeShellNavigation.normalizeHidden(['forum']), isEmpty);
      });

      test('legacyTabLocation folds old paths and keeps their query', () {
        // 从新闻站分享出来的链接带着分类和语言，重定向时一个都不能丢
        expect(
          HomeShellNavigation.legacyTabLocation('news', {
            'category': 'articles',
            'lang': 'ja',
          }),
          equals('/community?tab=news&category=articles&lang=ja'),
        );
        expect(
          HomeShellNavigation.legacyTabLocation('forum', const {}),
          equals('/community?tab=forum'),
        );
        // 地址里显式写了 tab= 的，以地址为准
        expect(
          HomeShellNavigation.legacyTabLocation('news', {'tab': 'forum'}),
          equals('/community?tab=forum'),
        );
      });

      test('legacy + current key in the hidden list does not duplicate', () {
        expect(
          HomeShellNavigation.normalizeHidden([
            'community',
            'forum',
            'news',
          ]),
          equals(<String>['community']),
        );
      });
    });
  });
}
