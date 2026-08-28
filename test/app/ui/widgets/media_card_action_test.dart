import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_slot.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_state.dart';

/// 只挂 mixin 的最小宿主：把 effectiveLiked / effectiveLikeCount 打到屏幕上，
/// 用来直接观察本地覆盖的建立与清除。
class _OverrideHost extends StatefulWidget {
  const _OverrideHost({
    required this.id,
    required this.liked,
    required this.likeCount,
  });

  final String id;
  final bool liked;
  final int likeCount;

  @override
  State<_OverrideHost> createState() => _OverrideHostState();
}

class _OverrideHostState extends State<_OverrideHost>
    with MediaCardActionState<_OverrideHost> {
  @override
  String get actionMediaId => widget.id;
  @override
  bool get baseLiked => widget.liked;
  @override
  int get baseLikeCount => widget.likeCount;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text('$effectiveLiked|$effectiveLikeCount'),
    );
  }
}

_OverrideHostState _host(WidgetTester tester) =>
    tester.state<_OverrideHostState>(find.byType(_OverrideHost));

void main() {
  group('MediaCardActionState 的本地点赞覆盖', () {
    testWidgets('没点过赞时直接用数据源的值', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );

      expect(find.text('false|3'), findsOneWidget);
    });

    testWidgets('点赞之后覆盖生效，上游原样重建也不会被抹掉', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );

      _host(tester).applyLikeToggle(true);
      await tester.pump();
      expect(find.text('true|4'), findsOneWidget);

      // 上游数据没变（列表刷新但这一条还是旧值）——覆盖必须留着，
      // 否则刚点的赞会闪回去。
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );
      expect(find.text('true|4'), findsOneWidget);
    });

    testWidgets('取消点赞按覆盖值往下减', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: true, likeCount: 3),
      );

      _host(tester).applyLikeToggle(false);
      await tester.pump();
      expect(find.text('false|2'), findsOneWidget);
    });

    testWidgets('换了另一条就把覆盖清掉（复用行不能显示上一条的赞数）', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );
      _host(tester).applyLikeToggle(true);
      await tester.pump();

      await tester.pumpWidget(
        const _OverrideHost(id: 'v2', liked: false, likeCount: 9),
      );
      expect(find.text('false|9'), findsOneWidget);
    });

    testWidgets('同一条但上游给了新数据，也让位给新数据', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );
      _host(tester).applyLikeToggle(true);
      await tester.pump();

      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: true, likeCount: 7),
      );
      expect(find.text('true|7'), findsOneWidget);
    });

    testWidgets('从详情页带回来的 extData 会补到卡片上', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );

      _host(tester).applyLikePatchFromExtData({
        NaviService.mediaLikePatchLikedKey: true,
        NaviService.mediaLikePatchCountKey: 12,
      });
      await tester.pump();
      expect(find.text('true|12'), findsOneWidget);
    });

    testWidgets('extData 里没有点赞补丁时什么都不做', (tester) async {
      await tester.pumpWidget(
        const _OverrideHost(id: 'v1', liked: false, likeCount: 3),
      );

      _host(tester).applyLikePatchFromExtData(null);
      _host(tester).applyLikePatchFromExtData(<String, dynamic>{});
      await tester.pump();
      expect(find.text('false|3'), findsOneWidget);
    });
  });

  group('MediaCardActionSlot', () {
    // 槽位内部的第一层：Scaffold / GlassTapArea 里也有同类组件，必须限定在
    // 槽位子树里再取最外层那一只。
    Finder inSlot(Type type) => find
        .descendant(
          of: find.byType(MediaCardActionSlot),
          matching: find.byType(type),
        )
        .first;

    Widget wrap(Widget slot) => MaterialApp(
      home: Scaffold(
        body: Stack(children: [const SizedBox(width: 200, height: 200), slot]),
      ),
    );

    testWidgets('自带 Positioned，可以直接摆进 Stack 的 children', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaCardActionSlot(
            video: Video(id: 'v1', liked: false, numLikes: 1),
            isMultiSelectMode: false,
            likedOverride: false,
            onLikeChanged: (_) {},
            busy: false,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(MediaActionMenuButton), findsOneWidget);
      expect(
        tester.widget<AnimatedOpacity>(inSlot(AnimatedOpacity)).opacity,
        1,
      );
      expect(
        tester.widget<IgnorePointer>(inSlot(IgnorePointer)).ignoring,
        isFalse,
      );
    });

    testWidgets('多选态下淡出并缩小，同时不再接收点击', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaCardActionSlot(
            video: Video(id: 'v1', liked: false, numLikes: 1),
            isMultiSelectMode: true,
            likedOverride: false,
            onLikeChanged: (_) {},
            busy: false,
          ),
        ),
      );

      expect(
        tester.widget<AnimatedOpacity>(inSlot(AnimatedOpacity)).opacity,
        0,
      );
      expect(tester.widget<AnimatedScale>(inSlot(AnimatedScale)).scale, 0.8);
      expect(
        tester.widget<IgnorePointer>(inSlot(IgnorePointer)).ignoring,
        isTrue,
      );
    });

    testWidgets('忙碌态转圈', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaCardActionSlot(
            video: Video(id: 'v1', liked: false, numLikes: 1),
            isMultiSelectMode: false,
            likedOverride: false,
            onLikeChanged: (_) {},
            busy: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('video 与 gallery 必须二选一', () {
      expect(
        () => MediaCardActionSlot(
          isMultiSelectMode: false,
          likedOverride: false,
          onLikeChanged: (_) {},
          busy: false,
        ),
        throwsAssertionError,
      );
    });
  });
}
