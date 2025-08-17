import 'package:flutter/material.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';

class FilterConfig {
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
      name: '用户',
      fields: [
        FilterField(name: 'username', type: FilterFieldType.STRING, displayName: '用户名', iconData: Icons.person, iconColor: Colors.teal),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: '简介', iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'name', type: FilterFieldType.STRING, isLocalizable: true, displayName: '昵称', iconData: Icons.badge, iconColor: Colors.cyan),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '注册日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.video: FilterContentType(
      id: 'videos',
      name: '视频',
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: '标题', iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: '描述', iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: '作者', iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(
          name: 'rating', 
          type: FilterFieldType.SELECT, 
          displayName: '评级', 
          iconData: Icons.star, 
          iconColor: Colors.amber,
          options: [
            FilterFieldOption(value: '', label: '全部的'),
            FilterFieldOption(value: 'ecchi', label: '成人的'),
            FilterFieldOption(value: 'general', label: '大众的'),
          ],
        ),
        FilterField(name: 'private', type: FilterFieldType.BOOLEAN, displayName: '私密', iconData: Icons.lock, iconColor: Colors.grey),
        FilterField(name: 'duration', type: FilterFieldType.NUMBER, displayName: '时长(秒)', iconData: Icons.timer, iconColor: Colors.orange),
        FilterField(name: 'likes', type: FilterFieldType.NUMBER, displayName: '点赞数', iconData: Icons.favorite, iconColor: Colors.red),
        FilterField(name: 'views', type: FilterFieldType.NUMBER, displayName: '观看数', iconData: Icons.visibility, iconColor: Colors.blue),
        FilterField(name: 'comments', type: FilterFieldType.NUMBER, displayName: '评论数', iconData: Icons.comment, iconColor: Colors.green),
        FilterField(name: 'tags', type: FilterFieldType.STRING_ARRAY, displayName: '标签', iconData: Icons.label, iconColor: Colors.red),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '发布日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.image: FilterContentType(
      id: 'images',
      name: '图片',
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: '标题', iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: '描述', iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: '作者', iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(
          name: 'rating', 
          type: FilterFieldType.SELECT, 
          displayName: '评级', 
          iconData: Icons.star, 
          iconColor: Colors.amber,
          options: [
            FilterFieldOption(value: '', label: '全部的'),
            FilterFieldOption(value: 'ecchi', label: '成人的'),
            FilterFieldOption(value: 'general', label: '大众的'),
          ],
        ),
        FilterField(name: 'likes', type: FilterFieldType.NUMBER, displayName: '点赞数', iconData: Icons.favorite, iconColor: Colors.red),
        FilterField(name: 'views', type: FilterFieldType.NUMBER, displayName: '观看数', iconData: Icons.visibility, iconColor: Colors.blue),
        FilterField(name: 'comments', type: FilterFieldType.NUMBER, displayName: '评论数', iconData: Icons.comment, iconColor: Colors.green),
        FilterField(name: 'images', type: FilterFieldType.NUMBER, displayName: '图片数量', iconData: Icons.image, iconColor: Colors.pink),
        FilterField(name: 'tags', type: FilterFieldType.STRING_ARRAY, displayName: '标签', iconData: Icons.label, iconColor: Colors.red),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '发布日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.post: FilterContentType(
      id: 'posts',
      name: '帖子',
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: '标题', iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: '内容', iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: '作者', iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '发布日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.forum: FilterContentType(
      id: 'forum_threads',
      name: '论坛主题',
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: '标题', iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: '作者', iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '发布日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.forum_posts: FilterContentType(
      id: 'forum_posts',
      name: '论坛帖子',
      fields: [
        FilterField(name: 'body', type: FilterFieldType.STRING, isLocalizable: true, displayName: '内容', iconData: Icons.description, iconColor: Colors.indigo),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: '作者', iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '发布日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
      ],
    ),
    SearchSegment.playlist: FilterContentType(
      id: 'playlists',
      name: '播放列表',
      fields: [
        FilterField(name: 'title', type: FilterFieldType.STRING, isLocalizable: true, displayName: '标题', iconData: Icons.title, iconColor: Colors.blue),
        FilterField(name: 'author', type: FilterFieldType.STRING, displayName: '作者', iconData: Icons.person_outline, iconColor: Colors.deepPurple),
        FilterField(name: 'videos', type: FilterFieldType.NUMBER, displayName: '视频数量', iconData: Icons.video_library, iconColor: Colors.purple),
        FilterField(name: 'date', type: FilterFieldType.DATE, displayName: '创建日期', iconData: Icons.calendar_today, iconColor: Colors.brown),
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
        (filter.value is List && (filter.value as List).isEmpty) ||
        (filter.operator == FilterOperator.RANGE && 
         (filter.value is! Map || 
          (filter.value['from'] == null || filter.value['from'] == '') &&
          (filter.value['to'] == null || filter.value['to'] == '')))) {
      return '';
    }

    switch (filter.operator) {
      case FilterOperator.CONTAINS:
        return '{${fieldName}: ${filter.value}}';
      
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
        
        return '{${fieldName}: [${from ?? ''}..${to ?? ''}]}';
      
      case FilterOperator.IN:
        return '{${fieldName}: [${(filter.value as List).join(',')}]}';
      
      case FilterOperator.NOT_IN:
        return '{${fieldName}: ![${(filter.value as List).join(',')}]}';
      
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
        return '{${fieldName}${filter.operator.value}${value}}';
    }
  }

  static String getOperatorLabel(FilterOperator operator) {
    switch (operator) {
      case FilterOperator.CONTAINS:
        return '包含';
      case FilterOperator.EQUALS:
        return '等于';
      case FilterOperator.NOT_EQUALS:
        return '不等于';
      case FilterOperator.GREATER_THAN:
        return '>';
      case FilterOperator.GREATER_EQUAL:
        return '>=';
      case FilterOperator.LESS_THAN:
        return '<';
      case FilterOperator.LESS_EQUAL:
        return '<=';
      case FilterOperator.RANGE:
        return '范围';
      case FilterOperator.IN:
        return '包含任意一项';
      case FilterOperator.NOT_IN:
        return '不包含任意一项';
    }
  }
}
