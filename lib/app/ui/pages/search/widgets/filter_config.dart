import 'package:flutter/material.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FilterConfig {
  // 通用排序项（非 Oreno3D）
  static List<FilterFieldOption> _buildCommonSortVideoImage() {
    return [
      FilterFieldOption(value: 'date', label: slang.t.searchFilter.sortTypes.latest),
      FilterFieldOption(value: 'relevance', label: slang.t.searchFilter.sortTypes.relevance),
      FilterFieldOption(value: 'views', label: slang.t.searchFilter.sortTypes.views),
      FilterFieldOption(value: 'likes', label: slang.t.searchFilter.sortTypes.likes),
    ];
  }

  static List<FilterFieldOption> _buildCommonSortOthers() {
    return [
      FilterFieldOption(value: 'date', label: slang.t.searchFilter.sortTypes.latest),
      FilterFieldOption(value: 'relevance', label: slang.t.searchFilter.sortTypes.relevance),
    ];
  }

  static List<FilterFieldOption> getSortOptionsForSegment(SearchSegment segment) {
    switch (segment) {
      case SearchSegment.video:
      case SearchSegment.image:
        return _buildCommonSortVideoImage();
      case SearchSegment.post:
      case SearchSegment.user:
      case SearchSegment.playlist:
      case SearchSegment.forum:
      case SearchSegment.forum_posts:
        return _buildCommonSortOthers();
      case SearchSegment.oreno3d:
        return const [];
    }
  }

  static String getDefaultSortForSegment(SearchSegment segment) {
    if (segment == SearchSegment.oreno3d) return 'latest';
    return 'date';
  }
  static const Map<FilterFieldType, List<FilterOperator>> _operators = {
    FilterFieldType.STRING: [
      FilterOperator.CONTAINS,
      FilterOperator.EQUALS,
      FilterOperator.NOT_EQUALS,
    ],
    FilterFieldType.NUMBER: [
      FilterOperator.EQUALS,
      FilterOperator.NOT_EQUALS,
      FilterOperator.GREATER_THAN,
      FilterOperator.GREATER_EQUAL,
      FilterOperator.LESS_THAN,
      FilterOperator.LESS_EQUAL,
      FilterOperator.RANGE,
    ],
    FilterFieldType.DATE: [
      FilterOperator.EQUALS,
      FilterOperator.NOT_EQUALS,
      FilterOperator.GREATER_THAN,
      FilterOperator.GREATER_EQUAL,
      FilterOperator.LESS_THAN,
      FilterOperator.LESS_EQUAL,
      FilterOperator.RANGE,
    ],
    FilterFieldType.BOOLEAN: [
      FilterOperator.EQUALS,
    ],
    FilterFieldType.STRING_ARRAY: [
      FilterOperator.IN,
      FilterOperator.NOT_IN,
    ],
    FilterFieldType.SELECT: [
      FilterOperator.EQUALS,
      FilterOperator.NOT_EQUALS,
    ],
  };

  static List<FilterOperator> getOperatorsForType(FilterFieldType type) {
    return _operators[type] ?? [];
  }

  static final Map<SearchSegment, FilterContentType> _contentTypes = {
    SearchSegment.user: FilterContentType(
      id: 'users',
      name: slang.t.searchFilter.users,
      fields: [
        FilterField(name: 'username', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.username, iconData: Icons.person, iconColor: Colors.teal),
        FilterField(name: 'name', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.nickname, iconData: Icons.badge, iconColor: Colors.cyan),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.registrationDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.description, iconData: Icons.description, iconColor: Colors.indigo),
      ],
    ),
    SearchSegment.video: FilterContentType(
      id: 'videos',
      name: slang.t.searchFilter.videos,
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.title, iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.description, iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'tags', type: FilterFieldType.STRING_ARRAY, displayName: slang.t.searchFilter.tags, iconData: Icons.label, iconColor: Colors.red),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.author, iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.publishDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
        FilterField(name: 'private', type: FilterFieldType.BOOLEAN, displayName: slang.t.searchFilter.private, iconData: Icons.lock, iconColor: Colors.grey),
        FilterField(name: 'duration', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.duration, iconData: Icons.timer, iconColor: Colors.orange),
        FilterField(name: 'likes', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.likes, iconData: Icons.favorite, iconColor: Colors.red),
        FilterField(name: 'views', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.views, iconData: Icons.visibility, iconColor: Colors.blue),
        FilterField(name: 'comments', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.comments, iconData: Icons.comment, iconColor: Colors.green),
        FilterField(
          name: 'rating', 
          type: FilterFieldType.SELECT, 
          displayName: slang.t.searchFilter.rating, 
          iconData: Icons.star, 
          iconColor: Colors.amber,
          options: [
            FilterFieldOption(value: '', label: slang.t.searchFilter.all),
            FilterFieldOption(value: 'ecchi', label: slang.t.searchFilter.adult),
            FilterFieldOption(value: 'general', label: slang.t.searchFilter.general),
          ],
        ),
      ],
    ),
    SearchSegment.image: FilterContentType(
      id: 'images',
      name: slang.t.searchFilter.images,
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.title, iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.author, iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'tags', type: FilterFieldType.STRING_ARRAY, displayName: slang.t.searchFilter.tags, iconData: Icons.label, iconColor: Colors.red),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.publishDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
        FilterField(name: 'views', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.views, iconData: Icons.visibility, iconColor: Colors.blue),
        FilterField(name: 'comments', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.comments, iconData: Icons.comment, iconColor: Colors.green),
        FilterField(name: 'images', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.imageCount, iconData: Icons.image, iconColor: Colors.pink),
        FilterField(name: 'likes', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.likes, iconData: Icons.favorite, iconColor: Colors.red),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.description, iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(
          name: 'rating', 
          type: FilterFieldType.SELECT, 
          displayName: slang.t.searchFilter.rating, 
          iconData: Icons.star, 
          iconColor: Colors.amber,
          options: [
            FilterFieldOption(value: '', label: slang.t.searchFilter.all),
            FilterFieldOption(value: 'ecchi', label: slang.t.searchFilter.adult),
            FilterFieldOption(value: 'general', label: slang.t.searchFilter.general),
          ],
        ),
      ],
    ),
    SearchSegment.post: FilterContentType(
      id: 'posts',
      name: slang.t.searchFilter.posts,
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.title, iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.content, iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.author, iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.publishDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.forum: FilterContentType(
      id: 'forum_threads',
      name: slang.t.searchFilter.forumThreads,
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.title, iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.author, iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.publishDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.forum_posts: FilterContentType(
      id: 'forum_posts',
      name: slang.t.searchFilter.forumPosts,
      fields: [
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.content, iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.author, iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.publishDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.playlist: FilterContentType(
      id: 'playlists',
      name: slang.t.searchFilter.playlists,
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: slang.t.searchFilter.title, iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: slang.t.searchFilter.author, iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'videos', type: FilterFieldType.NUMBER, displayName: slang.t.searchFilter.videoCount, iconData: Icons.video_library, iconColor: Colors.purple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: slang.t.searchFilter.createDate, iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
  };

  static FilterContentType? getContentType(SearchSegment segment) {
    return _contentTypes[segment];
  }

  static String generateFilterString(Filter filter, FilterField field) {
    final fieldName = filter.locale != null ? '${filter.field}_${filter.locale}' : filter.field;
    
    // 避免渲染不完整的过滤器
    if (filter.value == null || 
        filter.value == '' || 
        (filter.value is List && (filter.value as List).isEmpty)) {
      return '';
    }
    
    // 特殊处理范围类型
    if (filter.operator == FilterOperator.RANGE) {
      if (filter.value is! Map) {
        return '';
      }
      
      final from = filter.value['from'];
      final to = filter.value['to'];
      // 范围类型必须两个值都填写
      if (from == null || from == '' || to == null || to == '') {
        return '';
      }
    }

    switch (filter.operator) {
      case FilterOperator.CONTAINS:
        return '{$fieldName: ${filter.value}}';
      
      case FilterOperator.RANGE:
        dynamic from;
        dynamic to;
        
        if (field.type == FilterFieldType.DATE) {
          // 处理日期范围
          try {
            if (filter.value['from'] != null && filter.value['from'].toString().isNotEmpty) {
              from = (DateTime.parse(filter.value['from'].toString()).millisecondsSinceEpoch / 1000).floor();
            }
          } catch (e) {
            from = null;
          }
          
          try {
            if (filter.value['to'] != null && filter.value['to'].toString().isNotEmpty) {
              to = (DateTime.parse(filter.value['to'].toString()).millisecondsSinceEpoch / 1000).floor();
            }
          } catch (e) {
            to = null;
          }
        } else {
          // 处理数值范围
          from = filter.value['from'];
          to = filter.value['to'];
        }
        
        if (from == null && to == null) {
          return '';
        }
        
        return '{$fieldName: [${from ?? ''}..${to ?? ''}]}';
      
      case FilterOperator.IN:
        return '{$fieldName: [${(filter.value as List).join(',')}]}';
      
      case FilterOperator.NOT_IN:
        return '{$fieldName: ![${(filter.value as List).join(',')}]}';
      
      default:
        dynamic value = filter.value;
        if (field.type == FilterFieldType.DATE) {
          try {
            value = (DateTime.parse(value.toString()).millisecondsSinceEpoch / 1000).floor();
          } catch (e) {
            return '';
          }
        }
        if (value == null || value == '') return '';
        return '{$fieldName${filter.operator.value}$value}';
    }
  }

  static String getOperatorLabel(FilterOperator operator) {
    switch (operator) {
      case FilterOperator.CONTAINS:
        return slang.t.searchFilter.contains;
      case FilterOperator.EQUALS:
        return slang.t.searchFilter.equals;
      case FilterOperator.NOT_EQUALS:
        return slang.t.searchFilter.notEquals;
      case FilterOperator.GREATER_THAN:
        return slang.t.searchFilter.greaterThan;
      case FilterOperator.GREATER_EQUAL:
        return slang.t.searchFilter.greaterEqual;
      case FilterOperator.LESS_THAN:
        return slang.t.searchFilter.lessThan;
      case FilterOperator.LESS_EQUAL:
        return slang.t.searchFilter.lessEqual;
      case FilterOperator.RANGE:
        return slang.t.searchFilter.range;
      case FilterOperator.IN:
        return slang.t.searchFilter.kIn;
      case FilterOperator.NOT_IN:
        return slang.t.searchFilter.notIn;
    }
  }
}
