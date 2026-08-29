import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/app/ui/widgets/media_card_meta.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 卡片右下角压着一枚三点钮，它 40×40 的可点面积原本正好盖住右对齐的发布时间。
/// 这一组用例把「时间躲开了钮」「播放/评论贴在缩略图右上角」钉死，免得以后有人
/// 把统计或时间挪回去又撞上。
void main() {
  const double cardWidth = 260;

  Video buildVideo({int comments = 12}) => Video(
    id: 'video-1',
    title: '一个标题',
    // 用三位数：formatFriendlyNumber 一过千就跟着语言分叉（k / 万），
    // 这里只想验位置与分段，别把用例绑在某个 locale 上。
    numViews: 999,
    numLikes: 20,
    numComments: comments,
    liked: false,
    // 一周以前 → 走「年-月-日 时:分」那一支，不依赖 i18n。
    createdAt: DateTime(2020, 1, 2, 3, 4),
    user: User(id: 'u1', name: '作者名', username: 'author'),
  );

  Future<void> pumpCard(WidgetTester tester, Video video) async {
    await tester.pumpWidget(
      slang.TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: VideoCardListItemWidget(video: video, width: cardWidth),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('发布时间不再被右下角的三点钮盖住', (tester) async {
    await pumpCard(tester, buildVideo());

    final timeRect = tester.getRect(find.text('2020-01-02 03:04'));
    final buttonRect = tester.getRect(find.byType(MediaActionMenuButton));

    expect(
      timeRect.overlaps(buttonRect),
      isFalse,
      reason: '发布时间与三点钮的可点面积重叠了：$timeRect vs $buttonRect',
    );
  });

  testWidgets('作者名给三点钮让出右侧的位置', (tester) async {
    await pumpCard(tester, buildVideo());

    final nameRect = tester.getRect(find.text('作者名'));
    final buttonRect = tester.getRect(find.byType(MediaActionMenuButton));

    expect(nameRect.right, lessThanOrEqualTo(buttonRect.left));
  });

  testWidgets('播放/评论聚成一组贴在缩略图右上角（不是浮起来的胶囊）', (tester) async {
    await pumpCard(tester, buildVideo());

    final overlay = find.byType(MediaCardStatsOverlay);
    expect(overlay, findsOneWidget);

    final overlayRect = tester.getRect(overlay);
    final cardRect = tester.getRect(find.byType(VideoCardListItemWidget));

    expect(overlayRect.top, cardRect.top, reason: '统计组必须贴着缩略图上沿');
    expect(overlayRect.right, cardRect.right, reason: '统计组必须贴着缩略图右缘');

    // 两条统计都在这一组里，且带了各自的图标。
    expect(find.text('999'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(
      find.descendant(of: overlay, matching: find.byIcon(Icons.visibility)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: overlay, matching: find.byIcon(Icons.forum)),
      findsOneWidget,
    );
  });

  testWidgets('没有评论时整段省掉，只剩播放量', (tester) async {
    await pumpCard(tester, buildVideo(comments: 0));

    expect(
      find.descendant(
        of: find.byType(MediaCardStatsOverlay),
        matching: find.byIcon(Icons.forum),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(MediaCardStatsOverlay),
        matching: find.byIcon(Icons.visibility),
      ),
      findsOneWidget,
    );
  });

  testWidgets('窄卡片只留日期，不让省略号把时间截半截', (tester) async {
    await tester.pumpWidget(
      slang.TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 120,
                child: MediaCardMetaRow(
                  isLiked: false,
                  likeCount: 3,
                  createdAt: DateTime(2020, 1, 2, 3, 4),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('2020-01-02'), findsOneWidget);
    expect(find.text('2020-01-02 03:04'), findsNothing);
  });
}
