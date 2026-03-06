import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';

void main() {
  group('ImageModelCardMetaLine liked indicator', () {
    testWidgets('shows pink filled heart when image is liked', (tester) async {
      final imageModel = ImageModel(
        id: 'image-1',
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
          home: Material(child: ImageModelCardMetaLine(imageModel: imageModel)),
        ),
      );

      final iconFinder = find.byIcon(Icons.favorite);
      expect(iconFinder, findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, Colors.pink);
    });

    testWidgets('applies explicit like state override', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ImageModelCardMetaLine(
              imageModel: ImageModel(id: 'image-2'),
              isLiked: true,
              likeCount: 2,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
}
