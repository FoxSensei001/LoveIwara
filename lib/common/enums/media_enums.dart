enum MediaRating {
  ALL('', '全部的'),
  GENERAL('general', '大众的'),
  ECCHI('ecchi', 'R18');

  final String value;
  final String label;

  const MediaRating(this.value, this.label);
}

enum MediaType { VIDEO, IMAGE }

enum SearchSegment {
  video,
  image,
  post,
  user,
  forum,
  forum_posts,
  oreno3d,
  playlist;

  String get apiType {
    switch (this) {
      case SearchSegment.video:
        return 'videos';
      case SearchSegment.image:
        return 'images';
      case SearchSegment.post:
        return 'posts';
      case SearchSegment.user:
        return 'users';
      case SearchSegment.forum:
        return 'forum_threads';
      case SearchSegment.forum_posts:
        return 'forum_posts';
      case SearchSegment.playlist:
        return 'playlists';
      case SearchSegment.oreno3d:
        return 'oreno3d';
    }
  }

  static SearchSegment fromValue(String value) {
    return SearchSegment.values.firstWhere(
      (element) => element.name == value,
      orElse: () => SearchSegment.video,
    );
  }
}
