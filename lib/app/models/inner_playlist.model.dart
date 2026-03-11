import 'dart:math';

import 'package:i_iwara/app/models/video.model.dart';

enum InnerPlaylistSource {
  authorProfile,
  favoritesVideoList,
  playlistDetail,
  popularVideoList,
  relatedVideosTab,
  subscriptionVideoList,
}

class InnerPlaylistItemSnapshot {
  final String id;
  final String title;
  final String thumbnailUrl;
  final int numViews;
  final int numLikes;
  final int numComments;
  final bool liked;
  final bool isPrivate;
  final bool isExternalVideo;
  final String externalVideoDomain;
  final DateTime? createdAt;

  const InnerPlaylistItemSnapshot({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.numViews,
    required this.numLikes,
    required this.numComments,
    required this.liked,
    required this.isPrivate,
    required this.isExternalVideo,
    required this.externalVideoDomain,
    this.createdAt,
  });

  factory InnerPlaylistItemSnapshot.fromVideo(Video video) {
    return InnerPlaylistItemSnapshot(
      id: video.id,
      title: video.title?.trim().isNotEmpty == true ? video.title!.trim() : '',
      thumbnailUrl: video.thumbnailUrl,
      numViews: video.numViews ?? 0,
      numLikes: video.numLikes ?? 0,
      numComments: video.numComments ?? 0,
      liked: video.liked == true,
      isPrivate: video.private == true,
      isExternalVideo: video.isExternalVideo,
      externalVideoDomain: video.externalVideoDomain,
      createdAt: video.createdAt,
    );
  }
}

class InnerPlaylistContext {
  static const int maxPlaylistItems = 100;
  final InnerPlaylistSource source;
  final List<InnerPlaylistItemSnapshot> items;
  final String currentVideoId;

  const InnerPlaylistContext({
    required this.source,
    required this.items,
    required this.currentVideoId,
  });

  factory InnerPlaylistContext.fromVideos({
    required InnerPlaylistSource source,
    required Iterable<Video> videos,
    required String currentVideoId,
    int maxItems = maxPlaylistItems,
  }) {
    final seen = <String>{};
    final items = <InnerPlaylistItemSnapshot>[];
    final effectiveMaxItems = maxItems <= 0
        ? maxPlaylistItems
        : min(maxItems, maxPlaylistItems);

    for (final video in videos) {
      final id = video.id.trim();
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      items.add(InnerPlaylistItemSnapshot.fromVideo(video));
    }

    final limitedItems = _limitItems(
      items,
      currentVideoId: currentVideoId,
      maxItems: effectiveMaxItems,
    );

    return InnerPlaylistContext(
      source: source,
      items: List<InnerPlaylistItemSnapshot>.unmodifiable(limitedItems),
      currentVideoId: currentVideoId,
    );
  }

  InnerPlaylistContext copyWith({
    InnerPlaylistSource? source,
    List<InnerPlaylistItemSnapshot>? items,
    String? currentVideoId,
  }) {
    return InnerPlaylistContext(
      source: source ?? this.source,
      items: items ?? this.items,
      currentVideoId: currentVideoId ?? this.currentVideoId,
    );
  }

  /// Returns a new context for continuing playback from [selectedVideoId].
  ///
  /// The current video and the selected video are both treated as already
  /// consumed in the detail-page handoff chain, so they are moved to the tail
  /// in consumption order. This keeps untouched items closer to the front of
  /// the next "up next" drawer without mutating the original context.
  InnerPlaylistContext copyForSelection(String selectedVideoId) {
    final normalizedSelectedId = selectedVideoId.trim();
    if (normalizedSelectedId.isEmpty) {
      return this;
    }

    final consumedIds = <String>{};

    void markConsumed(String id) {
      final normalizedId = id.trim();
      if (normalizedId.isEmpty) {
        return;
      }
      consumedIds.add(normalizedId);
    }

    markConsumed(currentVideoId);
    markConsumed(normalizedSelectedId);

    final reordered = <InnerPlaylistItemSnapshot>[];
    for (final item in items) {
      final id = item.id.trim();
      if (id.isEmpty || consumedIds.contains(id)) {
        continue;
      }
      reordered.add(item);
    }

    for (final consumedId in consumedIds) {
      for (final item in items) {
        if (item.id.trim() == consumedId) {
          reordered.add(item);
          break;
        }
      }
    }

    return InnerPlaylistContext(
      source: source,
      items: List<InnerPlaylistItemSnapshot>.unmodifiable(reordered),
      currentVideoId: normalizedSelectedId,
    );
  }

  List<InnerPlaylistItemSnapshot> itemsStartingAfterCurrent() {
    if (items.isEmpty) {
      return const <InnerPlaylistItemSnapshot>[];
    }

    final seen = <String>{};
    final ordered = <InnerPlaylistItemSnapshot>[];
    final currentIndex = items.indexWhere((item) => item.id == currentVideoId);

    void addItem(InnerPlaylistItemSnapshot item) {
      final id = item.id.trim();
      if (id.isEmpty || id == currentVideoId || !seen.add(id)) {
        return;
      }
      ordered.add(item);
    }

    if (currentIndex >= 0) {
      for (var i = currentIndex + 1; i < items.length; i++) {
        addItem(items[i]);
      }
      for (var i = 0; i < currentIndex; i++) {
        addItem(items[i]);
      }
    } else {
      for (final item in items) {
        addItem(item);
      }
    }

    return List<InnerPlaylistItemSnapshot>.unmodifiable(ordered);
  }

  static List<InnerPlaylistItemSnapshot> _limitItems(
    List<InnerPlaylistItemSnapshot> items, {
    required String currentVideoId,
    required int maxItems,
  }) {
    if (maxItems <= 0 || items.length <= maxItems) {
      return items;
    }

    final candidates = items
        .where((item) => !item.isExternalVideo)
        .toList(growable: true);

    if (candidates.length <= maxItems) {
      return candidates;
    }

    final random = Random();
    final currentIndex = candidates.indexWhere(
      (item) => item.id == currentVideoId,
    );
    InnerPlaylistItemSnapshot? currentItem;

    if (currentIndex >= 0) {
      currentItem = candidates.removeAt(currentIndex);
    }

    candidates.shuffle(random);

    if (currentItem != null) {
      final selected = <InnerPlaylistItemSnapshot>[currentItem];
      selected.addAll(candidates.take(maxItems - 1));
      return selected;
    }

    return candidates.take(maxItems).toList(growable: false);
  }
}
