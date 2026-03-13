import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
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

  group('MyVideoStateController.resolveCenterOverlayState', () {
    test('returns loadingVideoInfo before remote video info is fetched', () {
      expect(
        MyVideoStateController.resolveCenterOverlayState(
          hasVideoSourceError: false,
          isLocalVideoMode: false,
          hasVideoInfo: false,
          pageLoadingState: VideoDetailPageLoadingState.loadingVideoInfo,
          shouldShowInitialPlaybackCover: false,
          isWaitingForInitialPlaybackStart: false,
          videoPlayerReady: false,
          isWaitingForSeek: false,
          videoBuffering: true,
          videoPlaying: true,
        ),
        VideoCenterOverlayState.loadingVideoInfo,
      );
    });

    test('returns initialPlaybackCover before user starts deferred playback', () {
      expect(
        MyVideoStateController.resolveCenterOverlayState(
          hasVideoSourceError: false,
          isLocalVideoMode: false,
          hasVideoInfo: true,
          pageLoadingState: VideoDetailPageLoadingState.idle,
          shouldShowInitialPlaybackCover: true,
          isWaitingForInitialPlaybackStart: false,
          videoPlayerReady: false,
          isWaitingForSeek: false,
          videoBuffering: false,
          videoPlaying: false,
        ),
        VideoCenterOverlayState.initialPlaybackCover,
      );
    });

    test('returns initialPlaybackLoading while deferred playback is starting', () {
      expect(
        MyVideoStateController.resolveCenterOverlayState(
          hasVideoSourceError: false,
          isLocalVideoMode: false,
          hasVideoInfo: true,
          pageLoadingState: VideoDetailPageLoadingState.loadingVideoSource,
          shouldShowInitialPlaybackCover: true,
          isWaitingForInitialPlaybackStart: true,
          videoPlayerReady: false,
          isWaitingForSeek: false,
          videoBuffering: true,
          videoPlaying: true,
        ),
        VideoCenterOverlayState.initialPlaybackLoading,
      );
    });

    test('returns rebufferingWhilePlaying only while playback is active', () {
      expect(
        MyVideoStateController.resolveCenterOverlayState(
          hasVideoSourceError: false,
          isLocalVideoMode: false,
          hasVideoInfo: true,
          pageLoadingState: VideoDetailPageLoadingState.idle,
          shouldShowInitialPlaybackCover: false,
          isWaitingForInitialPlaybackStart: false,
          videoPlayerReady: true,
          isWaitingForSeek: false,
          videoBuffering: true,
          videoPlaying: true,
        ),
        VideoCenterOverlayState.rebufferingWhilePlaying,
      );
    });

    test('returns playbackControls when buffering finishes after pause intent', () {
      expect(
        MyVideoStateController.resolveCenterOverlayState(
          hasVideoSourceError: false,
          isLocalVideoMode: false,
          hasVideoInfo: true,
          pageLoadingState: VideoDetailPageLoadingState.idle,
          shouldShowInitialPlaybackCover: false,
          isWaitingForInitialPlaybackStart: false,
          videoPlayerReady: true,
          isWaitingForSeek: false,
          videoBuffering: true,
          videoPlaying: false,
        ),
        VideoCenterOverlayState.playbackControls,
      );
    });

    test('returns seeking while waiting for seek completion', () {
      expect(
        MyVideoStateController.resolveCenterOverlayState(
          hasVideoSourceError: false,
          isLocalVideoMode: false,
          hasVideoInfo: true,
          pageLoadingState: VideoDetailPageLoadingState.idle,
          shouldShowInitialPlaybackCover: false,
          isWaitingForInitialPlaybackStart: false,
          videoPlayerReady: true,
          isWaitingForSeek: true,
          videoBuffering: false,
          videoPlaying: true,
        ),
        VideoCenterOverlayState.seeking,
      );
    });
  });

  group('InnerPlaylistContext.copyWithVideoLikeState', () {
    test('patches matching snapshot like fields only', () {
      const context = InnerPlaylistContext(
        source: InnerPlaylistSource.popularVideoList,
        currentVideoId: 'video-1',
        items: [
          InnerPlaylistItemSnapshot(
            id: 'video-1',
            title: 'One',
            thumbnailUrl: 'thumb-1',
            numViews: 10,
            numLikes: 1,
            numComments: 2,
            liked: false,
            isPrivate: false,
            isExternalVideo: false,
            externalVideoDomain: '',
          ),
          InnerPlaylistItemSnapshot(
            id: 'video-2',
            title: 'Two',
            thumbnailUrl: 'thumb-2',
            numViews: 20,
            numLikes: 5,
            numComments: 3,
            liked: true,
            isPrivate: false,
            isExternalVideo: false,
            externalVideoDomain: '',
          ),
        ],
      );

      final patched = context.copyWithVideoLikeState(
        videoId: 'video-1',
        liked: true,
        numLikes: 99,
      );

      expect(patched.items.first.liked, isTrue);
      expect(patched.items.first.numLikes, 99);
      expect(patched.items.last.liked, isTrue);
      expect(patched.items.last.numLikes, 5);
    });

    test('returns original context when target video is absent', () {
      const context = InnerPlaylistContext(
        source: InnerPlaylistSource.popularVideoList,
        currentVideoId: 'video-1',
        items: [
          InnerPlaylistItemSnapshot(
            id: 'video-1',
            title: 'One',
            thumbnailUrl: 'thumb-1',
            numViews: 10,
            numLikes: 1,
            numComments: 2,
            liked: false,
            isPrivate: false,
            isExternalVideo: false,
            externalVideoDomain: '',
          ),
        ],
      );

      final patched = context.copyWithVideoLikeState(
        videoId: 'video-404',
        liked: true,
        numLikes: 8,
      );

      expect(identical(patched, context), isTrue);
    });
  });
}
