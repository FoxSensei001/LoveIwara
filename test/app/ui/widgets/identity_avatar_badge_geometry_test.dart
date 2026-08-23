import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 身份圆钮上的角标必须**整只**落在玻璃圆里。
///
/// 液态档的玻璃会按自身形状裁 child（两个后端都没有关裁切的口子），角标贴在
/// 方框角上时那个位置在内切圆之外 —— 用户报的「头像绿点显示不全」就是这条。
/// 这里把「装得下」写成可执行的断言：角标圆心到玻璃圆心的距离 + 角标半径
/// 不得超过玻璃半径。
void main() {
  const double diameter = GlassTokens.pillHeight; // 44：身份圆钮直径
  const double avatarSize = diameter - 2; // 头像铺满圆钮，只留 1px 描边

  /// 角标按 `right/bottom = inset` 挂在边长 [boxSize] 的方框右下角时，
  /// 它离**玻璃圆心**最远的那一点有多远。方框与玻璃圆同心。
  double farthestReach({
    required double boxSize,
    required double badgeSize,
    required double inset,
  }) {
    final double offsetPerAxis = boxSize / 2 - inset - badgeSize / 2;
    final double centerDistance = math.sqrt(2) * offsetPerAxis;
    return centerDistance + badgeSize / 2;
  }

  group('circleBadgeInset', () {
    test('未读红点：算出的内缩刚好让它内切于玻璃圆', () {
      const double badge = GlassTokens.identityBadgeSize; // 9
      final double inset = GlassTokens.circleBadgeInset(
        diameter: diameter,
        badgeSize: badge,
      );
      expect(inset, greaterThan(0), reason: '贴角就会被裁，必须有正的内缩');
      expect(
        farthestReach(boxSize: diameter, badgeSize: badge, inset: inset),
        closeTo(diameter / 2, 0.001),
        reason: '内切：既不浪费空间，也不越界',
      );
    });

    test('在线绿点：定位在比玻璃圆小一圈的头像框上，也要内切', () {
      const double badge = AvatarWidget.onlineIndicatorSize; // 12
      final double inset = GlassTokens.circleBadgeInset(
        diameter: diameter,
        badgeSize: badge,
        boxSize: avatarSize,
      );
      expect(inset, greaterThan(0));
      expect(
        farthestReach(boxSize: avatarSize, badgeSize: badge, inset: inset),
        closeTo(diameter / 2, 0.001),
      );
    });

    test('原来的贴角写法确实越界（回归锚点）', () {
      expect(
        farthestReach(
          boxSize: avatarSize,
          badgeSize: AvatarWidget.onlineIndicatorSize,
          inset: 0,
        ),
        greaterThan(diameter / 2),
        reason: '这就是绿点被裁掉的根因，不要把内缩改回 0',
      );
    });

    test('本来就装得下时返回非正值（调用方按 0 截断）', () {
      // 一枚很小的角标挂在很小的框上：无需内缩。
      expect(
        GlassTokens.circleBadgeInset(
          diameter: 100,
          badgeSize: 4,
          boxSize: 20,
        ),
        lessThanOrEqualTo(0),
      );
    });
  });

  testWidgets('AvatarWidget.indicatorInset 真的把绿点挪进圆内', (tester) async {
    final user = User.fromJson({
      'id': 'u1',
      'name': 'tester',
      'username': 'tester',
      'seenAt': DateTime.now().toUtc().toIso8601String(),
    });
    final double inset = GlassTokens.circleBadgeInset(
      diameter: diameter,
      badgeSize: AvatarWidget.onlineIndicatorSize,
      boxSize: avatarSize,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: Center(
                child: AvatarWidget(
                  user: user,
                  size: avatarSize,
                  indicatorInset: inset,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder dot = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == Colors.green,
    );
    expect(dot, findsOneWidget, reason: '在线绿点没画出来');

    final Rect dotRect = tester.getRect(dot);
    final Offset glassCenter = tester.getRect(find.byType(SizedBox).first).center;
    // 角标圆心到玻璃圆心的距离 + 角标半径 ≤ 玻璃半径
    final double reach =
        (dotRect.center - glassCenter).distance + dotRect.width / 2;
    expect(
      reach,
      lessThanOrEqualTo(diameter / 2 + 0.001),
      reason: '绿点仍然探出玻璃圆，液态档下会被裁掉一角',
    );
  });
}
