import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/player_stack_builder.dart';

void main() {
  testWidgets('local player stack does not require an Rx dependency', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlayerStackBuilder(
          observeChanges: false,
          builder: () => const Text('local video surface'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('local video surface'), findsOneWidget);
  });

  testWidgets('online player stack keeps observing reactive state', (
    tester,
  ) async {
    final visible = false.obs;

    await tester.pumpWidget(
      MaterialApp(
        home: PlayerStackBuilder(
          observeChanges: true,
          builder: () => Text(visible.value ? 'visible' : 'hidden'),
        ),
      ),
    );
    expect(find.text('hidden'), findsOneWidget);

    visible.value = true;
    await tester.pump();

    expect(find.text('visible'), findsOneWidget);
  });
}
