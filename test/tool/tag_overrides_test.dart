// 标签词库数据层的四道闸门。
//
// 这些测试存在的意义不是「验证代码今天能跑」，而是**让退化会失败**：
// 每一条都对应一个已经真实发生过、或结构上必然会再次发生的问题。
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/tag_overrides/overrides.dart';

void main() {
  group('闸门 1｜同名词条必须各自独立', () {
    // 背景：迁移前 2554 个 oreno3d 词条只有 2515 个不同日文名，
    // 38 组同名词条共享同一份译名 —— 斯普拉遁的 ホタル 与星铁的 ホタル
    // 被迫叫同一个中文名，结构上无法分别修正。
    late Set<String> rawKeys;
    late Map<String, dynamic> loc;

    setUp(() {
      final raw = jsonDecode(
        File('tool/data/oreno3d_tags/oreno3d_tags.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      loc = jsonDecode(
        File('tool/data/oreno3d_tags/oreno3d_tags_localized.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      rawKeys = {
        for (final cat in ['origins', 'characters', 'tags'])
          for (final e in (raw[cat] as List)) '$cat/${(e as Map)['id']}',
      };
    });

    test('译名词典按 type/id 主键，且不含原始数据里不存在的条目', () {
      final unknown = loc.keys.where((k) => !rawKeys.contains(k)).toList();
      expect(unknown, isEmpty,
          reason: '译名词典里有 ${unknown.length} 条主键在原始数据中不存在'
              '（上游删了词条？）：${unknown.take(10).join(', ')}');

      // 同名但不同 id 的两条，必须是两个可分别修改的独立条目。
      expect(loc.containsKey('characters/2215'), isTrue); // スプラトゥーン の ホタル
      expect(loc.containsKey('characters/3872'), isTrue); // 崩壊:スターレイル の ホタル
      expect(identical(loc['characters/2215'], loc['characters/3872']), isFalse);
    });

    test('每个词条都有自己的译名条目（新抓到的词条必须补译后才发布）', () {
      // 这条红了通常不是代码坏了，而是重抓带回了新词条：
      // 它们在 App 里会原样显示日文名，正是「词库过期」那类用户可见问题。
      final untranslated = rawKeys.where((k) => !loc.containsKey(k)).toList()
        ..sort();
      expect(untranslated, isEmpty,
          reason: '有 ${untranslated.length} 条词条还没有译名，'
              '发布前需要补译（见 changes_*.json 增量清单）：'
              '${untranslated.take(10).join(', ')}');
    });
  });

  group('闸门 2｜人工修正不会被 AI 重译覆盖', () {
    test('overrides 永远压过 AI 译名，且只覆盖列出的语言', () {
      final aiV1 = {
        'characters/2215': {'zh-CN': '流萤', 'zh-TW': '流螢', 'en': 'Firefly'},
      };
      final ov = parseOverrides(jsonEncode({
        'schema': 1,
        'entries': {
          'characters/2215': {
            'n': {'zh-CN': '小萤'},
            'prev': {'zh-CN': '流萤'},
          }
        }
      }));

      final r1 = mergeOverrides(
          aiNames: aiV1, overrides: ov, knownKeys: {'characters/2215'});
      expect(r1.names['characters/2215']!['zh-CN'], '小萤');
      // 没被 override 列出的语言继续走 AI，AI 后续改进还进得来。
      expect(r1.names['characters/2215']!['en'], 'Firefly');
      expect(r1.appliedCount, 1);

      // 模拟「AI 整批重译」：换一份全新的 AI 译名，人工值必须依然胜出。
      final aiV2 = {
        'characters/2215': {'zh-CN': '萤火虫', 'zh-TW': '螢火蟲', 'en': 'Hotaru'},
      };
      final r2 = mergeOverrides(
          aiNames: aiV2, overrides: ov, knownKeys: {'characters/2215'});
      expect(r2.names['characters/2215']!['zh-CN'], '小萤',
          reason: '人工修正被 AI 重译覆盖了 —— 这正是 overrides 层存在的理由');
      expect(r2.names['characters/2215']!['en'], 'Hotaru');
    });
  });

  group('闸门 3｜上游变化必须被报出来，不能静默', () {
    test('AI 值偏离 override 记录的 prev 时进入待复核，且修正照常生效', () {
      final ov = parseOverrides(jsonEncode({
        'schema': 1,
        'entries': {
          'characters/2215': {
            'n': {'zh-CN': '小萤'},
            'prev': {'zh-CN': '流萤'}, // 当初是基于「流萤」这个错值改的
          }
        }
      }));

      // 上游没变：不该报。
      final same = mergeOverrides(
        aiNames: {
          'characters/2215': {'zh-CN': '流萤'}
        },
        overrides: ov,
        knownKeys: {'characters/2215'},
      );
      expect(same.needsReview, isEmpty);

      // 上游变了：必须报，但仍然应用人工值（静默退回旧值同样不可接受）。
      final drifted = mergeOverrides(
        aiNames: {
          'characters/2215': {'zh-CN': '萤火虫'}
        },
        overrides: ov,
        knownKeys: {'characters/2215'},
      );
      expect(drifted.needsReview, hasLength(1));
      expect(drifted.needsReview.single.key, 'characters/2215');
      expect(drifted.needsReview.single.currentAi, '萤火虫');
      expect(drifted.names['characters/2215']!['zh-CN'], '小萤');
    });

    test('指向已不存在词条的 override 被报成孤儿，而不是悄悄丢掉', () {
      final ov = parseOverrides(jsonEncode({
        'schema': 1,
        'entries': {
          'characters/999999': {
            'n': {'zh-CN': '某个上游已删除的角色'}
          }
        }
      }));
      final r = mergeOverrides(
          aiNames: const {}, overrides: ov, knownKeys: {'characters/1'});
      expect(r.orphanKeys, ['characters/999999']);
      expect(r.names, isEmpty);
    });
  });

  group('闸门 4｜rev 必须随内容变化', () {
    // 背景：现有 App 用「条目数变了才重建词库」的启发式判断是否更新，
    // 只改译名、条数不变时判不出来，修正要等下次冷启动才生效。
    test('只改一个译名、条数不变，rev 也必须变', () {
      final a = {
        'count': 2,
        'tags': {
          'x': {'n': {'zh-CN': '甲'}},
          'y': {'n': {'zh-CN': '乙'}},
        }
      };
      final b = jsonDecode(jsonEncode(a)) as Map<String, dynamic>;
      (((b['tags'] as Map)['y'] as Map)['n'] as Map)['zh-CN'] = '丙';

      expect((a['tags'] as Map).length, (b['tags'] as Map).length,
          reason: '前提：条目数没变');
      expect(contentRev(a), isNot(contentRev(b)),
          reason: '条数不变但内容变了，rev 必须能区分 —— 否则 App 判不出词库更新');
    });

    test('内容不变时 rev 稳定，重跑构建不会产生假更新', () {
      final a = {
        'count': 1,
        'tags': {
          'x': {'n': {'zh-CN': '甲'}}
        }
      };
      final b = jsonDecode(jsonEncode(a));
      expect(contentRev(a), contentRev(b));
    });

    test('打包资源里的两份词库都已带上 version 2 与 rev', () {
      for (final path in [
        'assets/data/iwara_tags.min.json',
        'assets/data/oreno3d_tags.min.json',
      ]) {
        final m = jsonDecode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        expect(m['version'], 2, reason: '$path 的 version 未升级');
        expect(m['rev'], isA<String>(), reason: '$path 缺少内容指纹 rev');
        expect((m['rev'] as String).length, 16);
      }
    });
  });
}
