class Oreno3dVideo {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final String author;
  final int viewCount;
  final int favoriteCount;
  final List<String> tags;

  const Oreno3dVideo({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.author,
    required this.viewCount,
    required this.favoriteCount,
    required this.tags,
  });

  factory Oreno3dVideo.fromJson(Map<String, dynamic> json) {
    return Oreno3dVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      author: json['author'] as String,
      viewCount: json['viewCount'] as int,
      favoriteCount: json['favoriteCount'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'author': author,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'tags': tags,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Oreno3dVideo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Oreno3dVideo{id: $id, title: $title, author: $author, viewCount: $viewCount, favoriteCount: $favoriteCount}';
  }
}

class Oreno3dSearchResult {
  final List<Oreno3dVideo> videos;
  final int currentPage;
  final int totalPages;
  final String keyword;
  final String sortType;

  const Oreno3dSearchResult({
    required this.videos,
    required this.currentPage,
    required this.totalPages,
    required this.keyword,
    required this.sortType,
  });

  factory Oreno3dSearchResult.fromJson(Map<String, dynamic> json) {
    var videoList = json['videos'] as List;
    List<Oreno3dVideo> videos = videoList
        .map((videoJson) => Oreno3dVideo.fromJson(videoJson as Map<String, dynamic>))
        .toList();

    return Oreno3dSearchResult(
      videos: videos,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      keyword: json['keyword'] as String,
      sortType: json['sortType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videos': videos.map((video) => video.toJson()).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'keyword': keyword,
      'sortType': sortType,
    };
  }

  @override
  String toString() {
    return 'Oreno3dSearchResult{videos: ${videos.length}, currentPage: $currentPage, totalPages: $totalPages, keyword: $keyword, sortType: $sortType}';
  }
}