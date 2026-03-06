import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';

void main() {
  group('VideoCardMetaLine liked indicator', () {
    testWidgets('shows pink filled heart when liked', (tester) async {
      final video = Video(
        id: 'video-1',
        liked: true,
        numLikes: 12,
        numViews: 34,
      );
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Material(child: VideoCardMetaLine(video: video)),
        ),
      );

      final iconFinder = find.byIcon(Icons.favorite);
      expect(iconFinder, findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, Colors.pink);
    });

    testWidgets('shows outline heart with default color when not liked', (
      tester,
    ) async {
      final video = Video(
        id: 'video-1',
        liked: false,
        numLikes: 12,
        numViews: 34,
      );
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );
      final defaultColor = theme.colorScheme.onSurfaceVariant;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Material(child: VideoCardMetaLine(video: video)),
        ),
      );

      final iconFinder = find.byIcon(Icons.favorite_border);
      expect(iconFinder, findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, defaultColor);
    });

    testWidgets('applies explicit like state override', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: VideoCardMetaLine(
              video: Video(id: 'video-2'),
              isLiked: true,
              likeCount: 3,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
}
