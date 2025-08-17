enum MediaRating {
  ALL('', '全部的'),
  GENERAL('general', '大众的'),
  ECCHI('ecchi', 'R18'),
  ;

  final String value;
  final String label;

  const MediaRating(this.value, this.label);
}

enum MediaType {
  VIDEO,
  IMAGE;
}

enum SearchSegment {
  video,
  image,
  post,
  user,
  forum,
  oreno3d,
  ;

  String get apiType {
    switch (this) {
      case SearchSegment.video:
        return 'videos';
      case SearchSegment.image:
        return 'images';
      case SearchSegment.post:
        return 'post';
      case SearchSegment.user:
        return 'user';
      case SearchSegment.forum:
        return 'forum';
      case SearchSegment.oreno3d:
        return 'oreno3d';
    }
  }

  static SearchSegment fromValue(String value) {
    return SearchSegment.values.firstWhere((element) => element.name == value,
        orElse: () => SearchSegment.video);
  }
}
