import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/oreno3d_video.model.dart';

class Oreno3dHtmlParser {
  /// 解析搜索结果页面HTML，提取视频列表
  static Oreno3dSearchResult parseSearchResult(String htmlContent, String keyword, {int page = 1}) {
    final document = html_parser.parse(htmlContent);
    
    // 提取视频列表
    final videos = _extractVideoList(document);
    
    // 提取分页信息
    final paginationInfo = _extractPaginationInfo(document);
    
    // 提取排序类型
    final sortType = _extractSortType(document);
    
    return Oreno3dSearchResult(
      videos: videos,
      currentPage: page,
      totalPages: paginationInfo['totalPages'] ?? 1,
      keyword: keyword,
      sortType: sortType,
    );
  }

  /// 从文档中提取视频列表
  static List<Oreno3dVideo> _extractVideoList(Document document) {
    final videos = <Oreno3dVideo>[];
    
    // 查找所有视频article元素
    final articleElements = document.querySelectorAll('.g-main-grid > article');
    
    for (final article in articleElements) {
      try {
        final video = _parseVideoArticle(article);
        if (video != null) {
          videos.add(video);
        }
      } catch (e) {
        // 跳过解析失败的项目
        print('解析视频项目失败: $e');
        continue;
      }
    }
    
    return videos;
  }

  /// 解析单个视频article元素
  static Oreno3dVideo? _parseVideoArticle(Element article) {
    final linkElement = article.querySelector('a.box');
    if (linkElement == null) return null;
    
    final url = linkElement.attributes['href'] ?? '';
    if (url.isEmpty) return null;
    
    // 提取视频ID
    final id = _extractVideoIdFromUrl(url);
    
    // 提取标题
    final titleElement = article.querySelector('h2.box-h2');
    final title = titleElement?.text?.trim() ?? '';
    
    // 提取缩略图URL
    final imgElement = article.querySelector('img.main-thumbnail');
    final thumbnailUrl = imgElement?.attributes['src'] ?? '';
    
    // 提取作者
    final authorElement = article.querySelector('.box-text1 .box-text-in');
    final author = authorElement?.text?.trim() ?? '';
    
    // 提取观看数和点赞数
    final labelElements = article.querySelectorAll('.f-label-in');
    int viewCount = 0;
    int favoriteCount = 0;
    
    for (final label in labelElements) {
      final iconElement = label.querySelector('i');
      final textElement = label.querySelector('.figure-text-in');
      
      if (iconElement != null && textElement != null) {
        final iconText = iconElement.text?.trim();
        final countText = textElement.text?.trim() ?? '';
        
        if (iconText == 'remove_red_eye') {
          viewCount = _parseCountString(countText);
        } else if (iconText == 'favorite') {
          favoriteCount = _parseCountString(countText);
        }
      }
    }
    
    // 提取标签
    final tagsElement = article.querySelector('.box-text2 .box-text-in');
    final tags = _extractTags(tagsElement);
    
    return Oreno3dVideo(
      id: id,
      title: title,
      url: url.startsWith('http') ? url : 'https://oreno3d.com$url',
      thumbnailUrl: thumbnailUrl.startsWith('http') ? thumbnailUrl : 'https://oreno3d.com$thumbnailUrl',
      author: author,
      viewCount: viewCount,
      favoriteCount: favoriteCount,
      tags: tags,
    );
  }

  /// 从URL中提取视频ID
  static String _extractVideoIdFromUrl(String url) {
    final regex = RegExp(r'/movies/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// 解析计数字符串（如"138.9k"转换为数字）
  static int _parseCountString(String countStr) {
    if (countStr.isEmpty) return 0;
    
    final cleanStr = countStr.toLowerCase().replaceAll(',', '');
    
    if (cleanStr.endsWith('k')) {
      final numStr = cleanStr.substring(0, cleanStr.length - 1);
      final num = double.tryParse(numStr) ?? 0;
      return (num * 1000).round();
    } else if (cleanStr.endsWith('m')) {
      final numStr = cleanStr.substring(0, cleanStr.length - 1);
      final num = double.tryParse(numStr) ?? 0;
      return (num * 1000000).round();
    } else {
      return int.tryParse(cleanStr) ?? 0;
    }
  }

  /// 提取标签列表
  static List<String> _extractTags(Element? tagsElement) {
    if (tagsElement == null) return [];
    
    final tags = <String>[];
    final textContent = tagsElement.text?.trim() ?? '';
    
    // 检查是否为"なし"（无标签）
    if (textContent == 'なし') {
      return [];
    }
    
    // 使用换行符和空格分割标签
    final tagsList = textContent
        .split(RegExp(r'\s+'))
        .where((tag) => tag.isNotEmpty)
        .toList();
    
    return tagsList;
  }

  /// 提取分页信息
  static Map<String, int> _extractPaginationInfo(Document document) {
    final paginationElement = document.querySelector('.pagination');
    if (paginationElement == null) {
      return {'totalPages': 1};
    }
    
    // 查找所有页码链接
    final pageLinks = paginationElement.querySelectorAll('li.page-item a.page-link');
    int maxPage = 1;
    
    for (final link in pageLinks) {
      final pageText = link.text?.trim() ?? '';
      final pageNum = int.tryParse(pageText);
      if (pageNum != null && pageNum > maxPage) {
        maxPage = pageNum;
      }
    }
    
    // 也检查"››"链接中的最后页码
    final lastPageLink = paginationElement.querySelector('li.page-item:last-child a.page-link');
    if (lastPageLink != null) {
      final href = lastPageLink.attributes['href'] ?? '';
      final pageMatch = RegExp(r'page=(\d+)').firstMatch(href);
      if (pageMatch != null) {
        final lastPage = int.tryParse(pageMatch.group(1) ?? '') ?? 1;
        if (lastPage > maxPage) {
          maxPage = lastPage;
        }
      }
    }
    
    return {'totalPages': maxPage};
  }

  /// 提取当前排序类型
  static String _extractSortType(Document document) {
    final activeSortButton = document.querySelector('.main-sort-button.sort-choice');
    if (activeSortButton == null) return 'hot';
    
    final href = activeSortButton.attributes['href'] ?? '';
    final sortMatch = RegExp(r'sort=(\w+)').firstMatch(href);
    return sortMatch?.group(1) ?? 'hot';
  }

  /// 解析视频详情页面HTML，提取详细信息
  static Oreno3dVideoDetail? parseVideoDetail(String htmlContent, String videoId) {
    final document = html_parser.parse(htmlContent);
    
    // 查找主要视频文章元素
    final articleElement = document.querySelector('.g-main-video-article');
    if (articleElement == null) {
      // 可能是404页面或页面结构改变
      return null;
    }
    
    try {
      // 提取标题
      final titleElement = articleElement.querySelector('h1.video-h1');
      final title = titleElement?.text?.trim() ?? '';
      
      // 提取缩略图URL
      final imgElement = articleElement.querySelector('.video-figure img.video-img');
      final thumbnailUrl = imgElement?.attributes['src'] ?? '';
      final fullThumbnailUrl = thumbnailUrl.startsWith('http') 
          ? thumbnailUrl 
          : 'https://oreno3d.com$thumbnailUrl';
      
      // 提取播放链接
      final playLinkElement = articleElement.querySelector('.video-figure a.pop_separate, a.video-watch-btn2[target="_blank"]');
      final playUrl = playLinkElement?.attributes['href'] ?? '';
      
      // 提取发布日期和时间
      DateTime? publishedAt;
      final dateElements = articleElement.querySelectorAll('.video-views .f-label-in');
      for (final dateElement in dateElements) {
        final iconElement = dateElement.querySelector('i.material-icons');
        if (iconElement?.text?.trim() == 'calendar_month') {
          final dateTexts = dateElement.querySelectorAll('.video-text');
          if (dateTexts.length >= 2) {
            final dateStr = dateTexts[0].text?.trim() ?? '';
            final timeStr = dateTexts[1].text?.trim() ?? '';
            publishedAt = _parseDateTime(dateStr, timeStr);
          }
          break;
        }
      }
      
      // 提取观看数和点赞数
      int viewCount = 0;
      int favoriteCount = 0;
      final viewElements = articleElement.querySelectorAll('.video-views .f-label-in');
      for (final viewElement in viewElements) {
        final iconElement = viewElement.querySelector('i.material-icons');
        final textElement = viewElement.querySelector('.video-text');
        
        if (iconElement != null && textElement != null) {
          final iconText = iconElement.text?.trim();
          final countText = textElement.text?.trim() ?? '';
          
          if (iconText == 'remove_red_eye') {
            viewCount = _parseCountString(countText);
          } else if (iconText == 'favorite') {
            favoriteCount = _parseCountString(countText);
          }
        }
      }
      
      // 提取作者信息
      Oreno3dLinkItem? author;
      final authorSection = articleElement.querySelector('.video-section-tag');
      if (authorSection != null) {
        final authorH2 = authorSection.querySelector('h2.video-h2-information');
        if (authorH2?.text?.trim() == '作成者：') {
          final authorLink = authorSection.querySelector('a.tag-btn');
          if (authorLink != null) {
            final authorUrl = authorLink.attributes['href'] ?? '';
            final authorName = authorLink.querySelector('.video-center')?.text?.trim() ?? '';
            final authorId = _extractAuthorIdFromUrl(authorUrl);
            
            if (authorName.isNotEmpty) {
              author = Oreno3dLinkItem(
                id: authorId,
                name: authorName,
                url: authorUrl.startsWith('http') ? authorUrl : 'https://oreno3d.com$authorUrl',
              );
            }
          }
        }
      }
      
      // 提取原作信息
      Oreno3dLinkItem? origin;
      final sections = articleElement.querySelectorAll('.video-section-tag');
      for (final section in sections) {
        final h2Element = section.querySelector('h2.video-h2-information');
        if (h2Element?.text?.trim() == '原作：') {
          final originLink = section.querySelector('a.tag-btn');
          if (originLink != null) {
            final originUrl = originLink.attributes['href'] ?? '';
            final originName = originLink.querySelector('.video-center')?.text?.trim() ?? '';
            final originId = _extractOriginIdFromUrl(originUrl);
            
            if (originName.isNotEmpty) {
              origin = Oreno3dLinkItem(
                id: originId,
                name: originName,
                url: originUrl.startsWith('http') ? originUrl : 'https://oreno3d.com$originUrl',
              );
            }
          }
          break;
        }
      }
      
      // 提取角色信息
      final characters = <Oreno3dLinkItem>[];
      for (final section in sections) {
        final h2Element = section.querySelector('h2.video-h2-information');
        if (h2Element?.text?.trim() == 'キャラ：') {
          final characterLinks = section.querySelectorAll('a.tag-btn');
          for (final characterLink in characterLinks) {
            final characterUrl = characterLink.attributes['href'] ?? '';
            final characterName = characterLink.querySelector('.video-center')?.text?.trim() ?? '';
            final characterId = _extractCharacterIdFromUrl(characterUrl);
            
            if (characterName.isNotEmpty) {
              characters.add(Oreno3dLinkItem(
                id: characterId,
                name: characterName,
                url: characterUrl.startsWith('http') ? characterUrl : 'https://oreno3d.com$characterUrl',
              ));
            }
          }
          break;
        }
      }
      
      // 提取标签信息
      final tags = <Oreno3dLinkItem>[];
      for (final section in sections) {
        final h2Element = section.querySelector('h2.video-h2-information');
        if (h2Element?.text?.trim() == 'タグ：') {
          final tagLinks = section.querySelectorAll('.video-tag .tag-btn');
          for (final tagLink in tagLinks) {
            final tagUrl = tagLink.attributes['href'] ?? '';
            final tagName = tagLink.querySelector('.tag-text')?.text?.trim() ?? '';
            final tagId = _extractTagIdFromUrl(tagUrl);
            
            if (tagName.isNotEmpty) {
              tags.add(Oreno3dLinkItem(
                id: tagId,
                name: tagName,
                url: tagUrl.startsWith('http') ? tagUrl : 'https://oreno3d.com$tagUrl',
              ));
            }
          }
          break;
        }
      }
      
      // 提取作者评论
      final commentElement = articleElement.querySelector('.video-information-comment');
      final authorComment = commentElement?.text?.trim();
      
      return Oreno3dVideoDetail(
        id: videoId,
        title: title,
        thumbnailUrl: fullThumbnailUrl,
        oreno3dUrl: 'https://oreno3d.com/movies/$videoId',
        playUrl: playUrl,
        publishedAt: publishedAt,
        viewCount: viewCount,
        favoriteCount: favoriteCount,
        author: author,
        origin: origin,
        characters: characters,
        tags: tags,
        authorComment: authorComment,
      );
    } catch (e) {
      print('解析视频详情失败: $e');
      return null;
    }
  }

  /// 解析日期时间字符串
  static DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      // 日期格式: 2020-05-06, 时间格式: 19:00
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      
      if (dateParts.length == 3 && timeParts.length == 2) {
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        return DateTime(year, month, day, hour, minute);
      }
    } catch (e) {
      print('解析日期时间失败: $e');
    }
    return null;
  }

  /// 从作者URL中提取ID
  static String _extractAuthorIdFromUrl(String url) {
    final regex = RegExp(r'/authors/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// 从原作URL中提取ID
  static String _extractOriginIdFromUrl(String url) {
    final regex = RegExp(r'/origins/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// 从角色URL中提取ID
  static String _extractCharacterIdFromUrl(String url) {
    final regex = RegExp(r'/characters/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// 从标签URL中提取ID
  static String _extractTagIdFromUrl(String url) {
    final regex = RegExp(r'/tags/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }
}