import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';

void main() {
  InnerPlaylistItemSnapshot buildItem(String id) {
    return InnerPlaylistItemSnapshot(
      id: id,
      title: 'Video $id',
      thumbnailUrl: 'https://example.com/$id.jpg',
      numViews: 1,
      numLikes: 2,
      numComments: 3,
      liked: false,
      isPrivate: false,
      isExternalVideo: false,
      externalVideoDomain: '',
    );
  }

  InnerPlaylistContext buildContext({
    required List<String> ids,
    required String currentVideoId,
  }) {
    return InnerPlaylistContext(
      source: InnerPlaylistSource.popularVideoList,
      items: List<InnerPlaylistItemSnapshot>.unmodifiable(
        ids.map(buildItem).toList(),
      ),
      currentVideoId: currentVideoId,
    );
  }

  List<String> orderedIds(Iterable<InnerPlaylistItemSnapshot> items) {
    return items.map((item) => item.id).toList(growable: false);
  }

  group('InnerPlaylistContext.copyForSelection', () {
    test('returns a reordered copy without mutating the original context', () {
      final original = buildContext(
        ids: const ['video-a', 'video-b', 'video-c', 'video-d'],
        currentVideoId: 'video-a',
      );

      final next = original.copyForSelection('video-c');

      expect(next.currentVideoId, 'video-c');
      expect(
        orderedIds(next.items),
        const ['video-b', 'video-d', 'video-a', 'video-c'],
      );
      expect(
        orderedIds(original.items),
        const ['video-a', 'video-b', 'video-c', 'video-d'],
      );
    });

    test('keeps untouched items at the front across chained selections', () {
      final first = buildContext(
        ids: const ['video-a', 'video-b', 'video-c', 'video-d'],
        currentVideoId: 'video-a',
      );

      final second = first.copyForSelection('video-c');
      final third = second.copyForSelection('video-d');

      expect(
        orderedIds(second.itemsStartingAfterCurrent()),
        const ['video-b', 'video-d', 'video-a'],
      );
      expect(
        orderedIds(third.items),
        const ['video-b', 'video-a', 'video-c', 'video-d'],
      );
      expect(orderedIds(third.itemsStartingAfterCurrent()).first, 'video-b');
    });
  });
}
