import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/db/migrations/migration_v4.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

/// 收藏夹标签筛选：候选标签聚合 + 多标签 AND 查询。
///
/// 直接跑真 sqlite（内存库），因为要验的就是 SQL 本身：LIKE 片段是否只匹配
/// 完整的 `"id":"<tagId>"`、多标签是否 AND、标签 id 里的 `_`/`%` 是否被转义。
void main() {
  late Database db;
  late FavoriteService service;

  String tagsJson(List<Tag> tags) =>
      jsonEncode(tags.map((tag) => tag.toJson()).toList());

  Tag tag(String id, {String type = 'general', bool sensitive = false}) =>
      Tag(id: id, type: type, sensitive: sensitive);

  void insertItem(
    String id, {
    String folderId = 'default',
    String title = 'title',
    List<Tag>? tags,
    String? rawTags,
    int createdAt = 1000,
  }) {
    db.execute(
      '''
      INSERT INTO favorite_items
        (id, folder_id, item_type, item_id, title, tags, created_at, updated_at)
      VALUES (?, ?, 'video', ?, ?, ?, ?, ?)
      ''',
      [
        id,
        folderId,
        'item_$id',
        title,
        rawTags ?? (tags == null ? null : tagsJson(tags)),
        createdAt,
        createdAt,
      ],
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 迁移与 service 内部都会写日志，未初始化 logger 会抛 LateInitializationError
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    MigrationV4Favorites().up(db);
    db.execute(
      "INSERT INTO favorite_folders (id, title) VALUES ('other', 'Other')",
    );
    service = FavoriteService(database: db);
  });

  tearDown(() => db.close());

  group('getFolderTagStats', () {
    test('按出现次数降序聚合夹内标签', () async {
      insertItem('a', tags: [tag('anime'), tag('dance')]);
      insertItem('b', tags: [tag('anime')]);
      insertItem('c', tags: [tag('anime'), tag('dance'), tag('mmd')]);

      final stats = await service.getFolderTagStats('default');

      expect(stats.map((s) => s.tag.id).toList(), ['anime', 'dance', 'mmd']);
      expect(stats.map((s) => s.count).toList(), [3, 2, 1]);
    });

    test('只统计本收藏夹，并保留标签的评级/敏感标记', () async {
      insertItem('a', tags: [tag('ecchi', type: 'ecchi', sensitive: true)]);
      insertItem('b', folderId: 'other', tags: [tag('anime')]);

      final stats = await service.getFolderTagStats('default');

      expect(stats.length, 1);
      expect(stats.single.tag.id, 'ecchi');
      expect(stats.single.tag.type, 'ecchi');
      expect(stats.single.tag.sensitive, isTrue);
    });

    test('同一条目内重复标签只计一次', () async {
      insertItem('a', tags: [tag('anime'), tag('anime')]);

      final stats = await service.getFolderTagStats('default');

      expect(stats.single.count, 1);
    });

    test('脏数据不拖垮整个候选列表', () async {
      insertItem('a', rawTags: 'not json at all');
      insertItem('b', rawTags: '{"id":"anime"}'); // 不是数组
      insertItem('c', rawTags: '[{"type":"general"}]'); // 缺 id
      insertItem('d', tags: [tag('anime')]);

      final stats = await service.getFolderTagStats('default');

      expect(stats.map((s) => s.tag.id).toList(), ['anime']);
    });
  });

  group('getFolderItems 标签筛选', () {
    test('多标签是 AND：必须同时命中才留下', () async {
      insertItem('a', tags: [tag('anime'), tag('dance')]);
      insertItem('b', tags: [tag('anime')]);
      insertItem('c', tags: [tag('dance')]);

      final both = await service.getFolderItems(
        'default',
        tagIds: ['anime', 'dance'],
      );
      expect(both.map((item) => item.id).toList(), ['a']);

      final single = await service.getFolderItems(
        'default',
        tagIds: ['anime'],
      );
      expect(single.map((item) => item.id).toSet(), {'a', 'b'});
    });

    test('只匹配完整标签 id，不再子串误命中', () async {
      insertItem('a', tags: [tag('animation')]);
      insertItem('b', tags: [tag('anime')]);

      final result = await service.getFolderItems(
        'default',
        tagIds: ['anime'],
      );

      expect(result.map((item) => item.id).toList(), ['b']);
    });

    test('标签值不会跑到 type / sensitive 字段上误命中', () async {
      // 旧实现的 `%"id":"%kw%"%` 会让 kw 落在后续字段里，general 能匹配任何标签
      insertItem('a', tags: [tag('anime', type: 'general')]);

      final result = await service.getFolderItems(
        'default',
        tagIds: ['general'],
      );

      expect(result, isEmpty);
    });

    test('标签 id 里的 LIKE 通配符被转义', () async {
      insertItem('a', tags: [tag('hair_pulling')]);
      insertItem('b', tags: [tag('hairXpulling')]);

      final result = await service.getFolderItems(
        'default',
        tagIds: ['hair_pulling'],
      );

      expect(result.map((item) => item.id).toList(), ['a']);
    });

    test('空标签列表等于不筛选', () async {
      insertItem('a', tags: [tag('anime')]);
      insertItem('b');

      final result = await service.getFolderItems('default', tagIds: const []);

      expect(result.length, 2);
    });

    test('标签与关键字 / 时间范围叠加生效', () async {
      // endDate 会被抬到当天 23:59:59，所以两条数据必须落在不同日期上
      final day1 = DateTime(1970, 1, 1, 12).millisecondsSinceEpoch ~/ 1000;
      final day5 = DateTime(1970, 1, 5, 12).millisecondsSinceEpoch ~/ 1000;

      insertItem('a', title: 'dance video', tags: [tag('anime')], createdAt: day1);
      insertItem('b', title: 'dance video', tags: [tag('anime')], createdAt: day5);
      insertItem('c', title: 'other video', tags: [tag('anime')], createdAt: day1);

      final result = await service.getFolderItems(
        'default',
        tagIds: ['anime'],
        searchText: 'dance',
        endDate: DateTime(1970, 1, 2),
      );

      expect(result.map((item) => item.id).toList(), ['a']);
    });
  });

  test('countFolderItems 与 getFolderItems 共用同一套筛选', () async {
    insertItem('a', tags: [tag('anime'), tag('dance')]);
    insertItem('b', tags: [tag('anime')]);

    final count = await service.countFolderItems(
      'default',
      tagIds: ['anime', 'dance'],
    );
    final items = await service.getFolderItems(
      'default',
      tagIds: ['anime', 'dance'],
    );

    expect(count, items.length);
    expect(count, 1);
  });
}
