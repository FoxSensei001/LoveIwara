/// 表示一个包含名称和URL的链接项
class Oreno3dLinkItem {
  final String? id; // 可选，如果能从URL中解析出ID
  final String name;
  final String url;

  const Oreno3dLinkItem({
    this.id,
    required this.name,
    required this.url,
  });

  factory Oreno3dLinkItem.fromJson(Map<String, dynamic> json) {
    return Oreno3dLinkItem(
      id: json['id'] as String?,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Oreno3dLinkItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          url == other.url;

  @override
  int get hashCode => name.hashCode ^ url.hashCode;

  @override
  String toString() {
    return 'Oreno3dLinkItem{id: $id, name: $name, url: $url}';
  }
}

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

class Oreno3dVideoDetail {
  final String id;
  final String title;
  final String thumbnailUrl; // 主页面缩略图
  final String oreno3dUrl; // oreno3d.com 上的视频详情页URL
  final String playUrl; // 实际的视频播放链接 (e.g., iwara.tv)

  final DateTime? publishedAt; // 发布日期和时间
  final int viewCount;
  final int favoriteCount;

  final Oreno3dLinkItem? author;
  final Oreno3dLinkItem? origin;
  final List<Oreno3dLinkItem> characters;
  final List<Oreno3dLinkItem> tags;
  final String? authorComment;

  const Oreno3dVideoDetail({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.oreno3dUrl,
    required this.playUrl,
    this.publishedAt,
    required this.viewCount,
    required this.favoriteCount,
    this.author,
    this.origin,
    this.characters = const [],
    this.tags = const [],
    this.authorComment,
  });

  // 可以提供一个从 Oreno3dVideo 转换的工厂构造函数，方便传递基础信息
  factory Oreno3dVideoDetail.fromOreno3dVideo(Oreno3dVideo video, {
    required String playUrl,
    DateTime? publishedAt,
    Oreno3dLinkItem? author,
    Oreno3dLinkItem? origin,
    List<Oreno3dLinkItem> characters = const [],
    List<Oreno3dLinkItem> tags = const [],
    String? authorComment,
  }) {
    return Oreno3dVideoDetail(
      id: video.id,
      title: video.title,
      thumbnailUrl: video.thumbnailUrl,
      oreno3dUrl: video.url, // Oreno3dVideo的url就是oreno3d站内的url
      playUrl: playUrl,
      publishedAt: publishedAt,
      viewCount: video.viewCount,
      favoriteCount: video.favoriteCount,
      author: author,
      origin: origin,
      characters: characters,
      tags: tags,
      authorComment: authorComment,
    );
  }

  factory Oreno3dVideoDetail.fromJson(Map<String, dynamic> json) {
    return Oreno3dVideoDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      oreno3dUrl: json['oreno3dUrl'] as String,
      playUrl: json['playUrl'] as String,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      viewCount: json['viewCount'] as int,
      favoriteCount: json['favoriteCount'] as int,
      author: json['author'] != null
          ? Oreno3dLinkItem.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      origin: json['origin'] != null
          ? Oreno3dLinkItem.fromJson(json['origin'] as Map<String, dynamic>)
          : null,
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => Oreno3dLinkItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => Oreno3dLinkItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      authorComment: json['authorComment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'oreno3dUrl': oreno3dUrl,
      'playUrl': playUrl,
      'publishedAt': publishedAt?.toIso8601String(),
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'author': author?.toJson(),
      'origin': origin?.toJson(),
      'characters': characters.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'authorComment': authorComment,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Oreno3dVideoDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// 从 playUrl 中提取 iwara 视频ID
  /// playUrl 格式: https://www.iwara.tv/video/gvYM0sEvhTunDI/blender-sp01 或 https://www.iwara.tv/video/gvYM0sEvhTunDI/
  /// 返回: gvYM0sEvhTunDI
  String? extractIwaraId() {
    if (playUrl.isEmpty) return null;
    
    try {
      final uri = Uri.parse(playUrl);
      if (uri.host.contains('iwara.tv')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2 && pathSegments[0] == 'video') {
          return pathSegments[1];
        }
      }
    } catch (e) {
      // 解析失败，返回null
    }
    
    return null;
  }

  @override
  String toString() {
    return 'Oreno3dVideoDetail{id: $id, title: $title, playUrl: $playUrl, author: ${author?.name}, viewCount: $viewCount}';
  }
}