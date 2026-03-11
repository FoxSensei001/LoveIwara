import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

void main() {
  group('MyVideoStateController.shouldRevealToolbarsOnMouseHover', () {
    test('returns false when hover reveal feature is disabled', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: false,
          isToolbarsLocked: false,
          isSuppressed: false,
        ),
        isFalse,
      );
    });

    test('returns false when toolbars are locked', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: true,
          isToolbarsLocked: true,
          isSuppressed: false,
        ),
        isFalse,
      );
    });

    test('returns false when reveal is suppressed by overlay state', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: true,
          isToolbarsLocked: false,
          isSuppressed: true,
        ),
        isFalse,
      );
    });

    test('returns true only when feature is enabled and unsuppressed', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: true,
          isToolbarsLocked: false,
          isSuppressed: false,
        ),
        isTrue,
      );
    });
  });

  group('MyVideoStateController.shouldBootstrapDeferredPlaybackOnUserPlay', () {
    test('returns true for remote Iwara video before player is ready', () {
      expect(
        MyVideoStateController.shouldBootstrapDeferredPlaybackOnUserPlay(
          isLocalVideoMode: false,
          isExternalVideo: false,
          videoPlayerReady: false,
        ),
        isTrue,
      );
    });

    test('returns false for local video before player is ready', () {
      expect(
        MyVideoStateController.shouldBootstrapDeferredPlaybackOnUserPlay(
          isLocalVideoMode: true,
          isExternalVideo: false,
          videoPlayerReady: false,
        ),
        isFalse,
      );
    });

    test('returns false for external video before player is ready', () {
      expect(
        MyVideoStateController.shouldBootstrapDeferredPlaybackOnUserPlay(
          isLocalVideoMode: false,
          isExternalVideo: true,
          videoPlayerReady: false,
        ),
        isFalse,
      );
    });

    test('returns false once the player is already ready', () {
      expect(
        MyVideoStateController.shouldBootstrapDeferredPlaybackOnUserPlay(
          isLocalVideoMode: false,
          isExternalVideo: false,
          videoPlayerReady: true,
        ),
        isFalse,
      );
    });
  });

  group('MyVideoStateController.shouldOpenPlayerAfterVideoSourceFetch', () {
    test(
      'returns false when neither current nor pending fetch requested open',
      () {
        expect(
          MyVideoStateController.shouldOpenPlayerAfterVideoSourceFetch(
            requestedByCurrentCall: false,
            requestedByPendingCall: false,
          ),
          isFalse,
        );
      },
    );

    test('returns true when current fetch requested open', () {
      expect(
        MyVideoStateController.shouldOpenPlayerAfterVideoSourceFetch(
          requestedByCurrentCall: true,
          requestedByPendingCall: false,
        ),
        isTrue,
      );
    });

    test('returns true when a deduped pending request requested open', () {
      expect(
        MyVideoStateController.shouldOpenPlayerAfterVideoSourceFetch(
          requestedByCurrentCall: false,
          requestedByPendingCall: true,
        ),
        isTrue,
      );
    });
  });

  group('MyVideoStateController.resolveOpenPlayerAfterVideoSourceFetch', () {
    test('consumes pending request when open is requested later', () {
      final decision =
          MyVideoStateController.resolveOpenPlayerAfterVideoSourceFetch(
            requestedByCurrentCall: false,
            requestedByPendingCall: true,
          );

      expect(decision.shouldOpenPlayer, isTrue);
      expect(decision.nextPendingRequest, isFalse);
    });

    test('keeps pending request false when nothing asked to open', () {
      final decision =
          MyVideoStateController.resolveOpenPlayerAfterVideoSourceFetch(
            requestedByCurrentCall: false,
            requestedByPendingCall: false,
          );

      expect(decision.shouldOpenPlayer, isFalse);
      expect(decision.nextPendingRequest, isFalse);
    });

    test('consumes current request immediately after success', () {
      final decision =
          MyVideoStateController.resolveOpenPlayerAfterVideoSourceFetch(
            requestedByCurrentCall: true,
            requestedByPendingCall: false,
          );

      expect(decision.shouldOpenPlayer, isTrue);
      expect(decision.nextPendingRequest, isFalse);
    });
  });
}
