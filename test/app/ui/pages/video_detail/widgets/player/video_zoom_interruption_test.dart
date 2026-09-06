import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_zoom_view.dart';

/// Only the state consumed by the real reset-animation widget; no player or service mocks.
class _ZoomState implements MyVideoStateController {
  @override
  final RxDouble videoZoomScale = 2.0.obs;
  @override
  final Rx<Offset> videoZoomOffset = Offset.zero.obs;
  @override
  final RxDouble videoZoomRotation = 0.0.obs;
  @override
  final RxInt videoZoomResetSignal = 0.obs;
  @override
  final RxInt videoZoomInterruptSignal = 0.obs;

  @override
  void applyVideoZoom(double scale, Offset offset, double rotation) {
    videoZoomScale.value = scale;
    videoZoomOffset.value = offset;
    videoZoomRotation.value = rotation;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('new zoom input interrupts reset with pinch disabled', (
    tester,
  ) async {
    final state = _ZoomState();
    await tester.pumpWidget(
      MaterialApp(
        home: VideoZoomGestureLayer(
          controller: state,
          enabled: false,
          child: const SizedBox.expand(),
        ),
      ),
    );
    state.videoZoomResetSignal.value++;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(state.videoZoomScale.value, inExclusiveRange(1.0, 2.0));

    // Immediate media/fullscreen reset emits this interruption.
    state.videoZoomInterruptSignal.value++;
    final next = state.videoZoomScale.value * 1.1;
    state.applyVideoZoom(next, Offset.zero, 0);
    await tester.pump(const Duration(milliseconds: 300));
    expect(state.videoZoomScale.value, next);

    // Interruption cancels the previous reset, not all future reset requests.
    state.videoZoomResetSignal.value++;
    await tester.pumpAndSettle();
    expect(state.videoZoomScale.value, 1.0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
