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
        equals(<String>['gallery', 'video', 'subscription', 'forum', 'news']),
      );
    });

    test('displayIndex <-> branchIndex mapping follows key, not position', () {
      final order = <String>[
        'gallery',
        'video',
        'subscription',
        'forum',
        'news',
      ];

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
  });
}
