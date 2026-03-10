import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/fullscreen_inner_playlist_drawer.dart';

void main() {
  Future<void> pumpDrawer(
    WidgetTester tester, {
    required Size size,
    required Widget child,
    Key? hostKey,
    double leftPadding = 0,
    double rightPadding = 0,
    double topPadding = 0,
    double bottomSafeInset = 0,
  }) async {
    final mediaQuery = MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: EdgeInsets.only(
          left: leftPadding,
          top: topPadding,
          right: rightPadding,
        ),
        viewPadding: EdgeInsets.only(
          left: leftPadding,
          top: topPadding,
          right: rightPadding,
          bottom: bottomSafeInset,
        ),
        systemGestureInsets: EdgeInsets.only(bottom: bottomSafeInset),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            key: hostKey,
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: mediaQuery)));
    await tester.pumpAndSettle();
  }

  Future<void> pumpInteractiveDrawer(
    WidgetTester tester, {
    required Size size,
    required List<InnerPlaylistItemSnapshot> items,
    required bool initialExpanded,
    required ValueSetter<bool> onExpandedChanged,
    Key? hostKey,
    double leftPadding = 0,
    double rightPadding = 0,
    double topPadding = 0,
    double bottomSafeInset = 0,
  }) async {
    bool expanded = initialExpanded;

    await pumpDrawer(
      tester,
      size: size,
      hostKey: hostKey,
      leftPadding: leftPadding,
      rightPadding: rightPadding,
      topPadding: topPadding,
      bottomSafeInset: bottomSafeInset,
      child: StatefulBuilder(
        builder: (context, setState) {
          return FullscreenInnerPlaylistDrawer(
            items: items,
            isExpanded: expanded,
            showHint: !expanded,
            isBusy: false,
            loadingItemId: null,
            toolbarVisibility: 1.0,
            showResumePositionTip: true,
            onSelectItem: (_) {},
            onExpand: () {
              setState(() {
                expanded = true;
              });
              onExpandedChanged(expanded);
            },
            onCollapse: () {
              setState(() {
                expanded = false;
              });
              onExpandedChanged(expanded);
            },
            onDismiss: () {
              setState(() {
                expanded = false;
              });
              onExpandedChanged(expanded);
            },
          );
        },
      ),
    );
  }

  group('FullscreenInnerPlaylistDrawer', () {
    final items = List<InnerPlaylistItemSnapshot>.generate(
      6,
      (index) => InnerPlaylistItemSnapshot(
        id: 'video-$index',
        title: 'Video $index',
        thumbnailUrl: 'https://example.com/$index.jpg',
        numViews: 100 + index,
        numLikes: 10 + index,
        numComments: index,
        liked: false,
        isPrivate: false,
        isExternalVideo: false,
        externalVideoDomain: '',
      ),
    );

    testWidgets('mouse wheel scroll moves horizontal playlist', (tester) async {
      await pumpDrawer(
        tester,
        size: const Size(420, 260),
        child: FullscreenInnerPlaylistDrawer(
          items: items,
          isExpanded: true,
          showHint: false,
          isBusy: false,
          loadingItemId: null,
          onSelectItem: (_) {},
          onExpand: () {},
          onCollapse: () {},
          onDismiss: () {},
        ),
      );

      final listViewFinder = find.byType(ListView);
      final scrollableFinder = find.byType(Scrollable);
      final listenerFinder = find.ancestor(
        of: listViewFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Listener && widget.onPointerSignal != null,
        ),
      );
      expect(scrollableFinder, findsOneWidget);
      expect(listenerFinder, findsOneWidget);

      final scrollable = tester.state<ScrollableState>(scrollableFinder);
      final listener = tester.widget<Listener>(listenerFinder);
      final listCenter = tester.getCenter(listViewFinder);

      expect(scrollable.position.pixels, 0);

      listener.onPointerSignal?.call(
        PointerScrollEvent(
          position: listCenter,
          scrollDelta: const Offset(0, 120),
        ),
      );
      await tester.pump();

      expect(scrollable.position.pixels, greaterThan(0));
    });

    testWidgets('short screen hint stays between toolbar and bottom controls', (
      tester,
    ) async {
      const size = Size(360, 300);
      const topPadding = 32.0;
      const bottomSafeInset = 20.0;
      final hostKey = UniqueKey();
      final expectedTopReserved = 16.0 + 60.0;
      final expectedBottomLimit =
          size.height - (bottomSafeInset + 16.0 + 40.0 + 68.0 + 34.0);

      await pumpDrawer(
        tester,
        size: size,
        hostKey: hostKey,
        topPadding: topPadding,
        bottomSafeInset: bottomSafeInset,
        child: FullscreenInnerPlaylistDrawer(
          items: items,
          isExpanded: false,
          showHint: true,
          isBusy: false,
          loadingItemId: null,
          toolbarVisibility: 1.0,
          showResumePositionTip: true,
          onSelectItem: (_) {},
          onExpand: () {},
          onCollapse: () {},
          onDismiss: () {},
        ),
      );

      final hintRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_hint_box')),
      );
      final hostRect = tester.getRect(find.byKey(hostKey));
      final localHintTop = hintRect.top - hostRect.top;
      final localHintBottom = hintRect.bottom - hostRect.top;

      expect(localHintTop, closeTo(expectedTopReserved, 0.01));
      expect(localHintBottom, lessThanOrEqualTo(expectedBottomLimit + 0.01));
    });

    testWidgets('short screen drawer shrinks to fit above bottom controls', (
      tester,
    ) async {
      const size = Size(360, 200);
      const bottomSafeInset = 20.0;
      final hostKey = UniqueKey();
      final expectedBottomLimit = size.height - (bottomSafeInset + 16.0);

      await pumpDrawer(
        tester,
        size: size,
        hostKey: hostKey,
        bottomSafeInset: bottomSafeInset,
        child: FullscreenInnerPlaylistDrawer(
          items: items,
          isExpanded: true,
          showHint: false,
          isBusy: false,
          loadingItemId: null,
          toolbarVisibility: 1.0,
          showResumePositionTip: true,
          onSelectItem: (_) {},
          onExpand: () {},
          onCollapse: () {},
          onDismiss: () {},
        ),
      );

      final drawerRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
      );
      final hostRect = tester.getRect(find.byKey(hostKey));
      final localDrawerTop = drawerRect.top - hostRect.top;
      final localDrawerBottom = drawerRect.bottom - hostRect.top;

      expect(localDrawerTop, greaterThanOrEqualTo(-0.01));
      expect(localDrawerBottom, lessThanOrEqualTo(expectedBottomLimit + 0.01));
      expect(drawerRect.height, lessThan(176.0));
    });

    testWidgets('dragging the hint left expands the bottom drawer', (
      tester,
    ) async {
      var expanded = false;

      await pumpInteractiveDrawer(
        tester,
        size: const Size(390, 320),
        items: items,
        initialExpanded: expanded,
        onExpandedChanged: (value) => expanded = value,
        bottomSafeInset: 20,
      );

      await tester.drag(
        find.byKey(const Key('fullscreen_inner_playlist_hint_box')),
        const Offset(-120, 0),
      );
      await tester.pumpAndSettle();

      expect(expanded, isTrue);
      expect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
        findsOneWidget,
      );
    });

    testWidgets('tapping the hint animates drawer opening', (tester) async {
      var expanded = false;
      final hostKey = UniqueKey();

      await pumpInteractiveDrawer(
        tester,
        size: const Size(390, 320),
        hostKey: hostKey,
        items: items,
        initialExpanded: expanded,
        onExpandedChanged: (value) => expanded = value,
        bottomSafeInset: 20,
      );

      await tester.tap(
        find.byKey(const Key('fullscreen_inner_playlist_hint_box')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      final openingRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
      );

      await tester.pumpAndSettle();

      final finalRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
      );

      expect(expanded, isTrue);
      // Drawer is hidden off-screen to the right, then slides in.
      expect(openingRect.left, greaterThan(finalRect.left));
    });

    testWidgets('tapping outside animates drawer closing', (tester) async {
      var expanded = true;
      final hostKey = UniqueKey();

      await pumpInteractiveDrawer(
        tester,
        size: const Size(390, 320),
        hostKey: hostKey,
        items: items,
        initialExpanded: expanded,
        onExpandedChanged: (value) => expanded = value,
        bottomSafeInset: 20,
      );

      final hostRect = tester.getRect(find.byKey(hostKey));
      final initialRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
      );

      await tester.tapAt(Offset(hostRect.left + 12, hostRect.top + 12));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      final closingRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
      );

      await tester.pumpAndSettle();

      expect(expanded, isFalse);
      // Drawer slides out to the right when dismissed.
      expect(closingRect.left, greaterThan(initialRect.left));
      expect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
        findsNothing,
      );
    });

    testWidgets(
      'right swipe closes expanded drawer when list is at left edge',
      (tester) async {
        var expanded = true;

        await pumpInteractiveDrawer(
          tester,
          size: const Size(390, 320),
          items: items,
          initialExpanded: expanded,
          onExpandedChanged: (value) => expanded = value,
          bottomSafeInset: 20,
        );

        await tester.drag(
          find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
          const Offset(140, 0),
        );
        await tester.pumpAndSettle();

        expect(expanded, isFalse);
      },
    );

    testWidgets('downward drag closes expanded drawer quickly', (tester) async {
      var expanded = true;

      await pumpInteractiveDrawer(
        tester,
        size: const Size(390, 320),
        items: items,
        initialExpanded: expanded,
        onExpandedChanged: (value) => expanded = value,
        bottomSafeInset: 20,
      );

      await tester.drag(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
        const Offset(0, 140),
      );
      await tester.pumpAndSettle();

      expect(expanded, isFalse);
    });

    testWidgets(
      'right swipe does not close when horizontal list is not at left edge',
      (tester) async {
        var expanded = true;

        await pumpInteractiveDrawer(
          tester,
          size: const Size(390, 320),
          items: items,
          initialExpanded: expanded,
          onExpandedChanged: (value) => expanded = value,
          bottomSafeInset: 20,
        );

        await tester.drag(find.byType(ListView), const Offset(-180, 0));
        await tester.pumpAndSettle();

        await tester.drag(
          find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
          const Offset(140, 0),
        );
        await tester.pumpAndSettle();

        expect(expanded, isTrue);
      },
    );

    testWidgets(
      'drag that starts away from the left edge never closes the drawer',
      (tester) async {
        var expanded = true;

        await pumpInteractiveDrawer(
          tester,
          size: const Size(390, 320),
          items: items,
          initialExpanded: expanded,
          onExpandedChanged: (value) => expanded = value,
          bottomSafeInset: 20,
        );

        final scrollable = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );
        scrollable.position.jumpTo(120);
        await tester.pump();

        await tester.drag(
          find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
          const Offset(220, 0),
        );
        await tester.pumpAndSettle();

        expect(expanded, isTrue);
      },
    );

    testWidgets('expanded drawer respects asymmetric horizontal safe areas', (
      tester,
    ) async {
      const size = Size(390, 320);
      const leftPadding = 44.0;
      const rightPadding = 8.0;
      final hostKey = UniqueKey();

      await pumpDrawer(
        tester,
        size: size,
        hostKey: hostKey,
        leftPadding: leftPadding,
        rightPadding: rightPadding,
        bottomSafeInset: 20,
        child: FullscreenInnerPlaylistDrawer(
          items: items,
          isExpanded: true,
          showHint: false,
          isBusy: false,
          loadingItemId: null,
          toolbarVisibility: 1.0,
          showResumePositionTip: true,
          onSelectItem: (_) {},
          onExpand: () {},
          onCollapse: () {},
          onDismiss: () {},
        ),
      );

      final drawerRect = tester.getRect(
        find.byKey(const Key('fullscreen_inner_playlist_drawer_box')),
      );
      final hostRect = tester.getRect(find.byKey(hostKey));
      final localDrawerLeft = drawerRect.left - hostRect.left;
      final localDrawerRight = drawerRect.right - hostRect.left;

      expect(localDrawerLeft, greaterThanOrEqualTo(leftPadding + 12 - 0.01));
      expect(
        localDrawerRight,
        lessThanOrEqualTo(size.width - rightPadding - 12 + 0.01),
      );
    });
  });
}
