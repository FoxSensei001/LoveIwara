import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  testWidgets('pending list avatars do not schedule continuous frames', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarWidget(avatarUrl: 'https://example.invalid/avatar.png'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Tests have no network/cache response at this point, leaving the real
    // loading placeholder mounted.
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Shimmer), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
