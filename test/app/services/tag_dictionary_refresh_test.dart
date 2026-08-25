// 词库更新判定的闸门。
//
// 背景：此前两个本地化服务各自实现了「条目数变了才重建」的启发式
// （tag_localization_service.dart / oreno3d_localization_service.dart），
// 纯译名修正条数不变 → 当次不生效，用户要等下一次冷启动。
// 这几条钉死新的判据，也钉死向后兼容的退化路径。
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/tag_dictionary_refresh.dart';

int _countTags(Map<String, dynamic> m) =>
    (m['tags'] as Map?)?.length ?? 0;

String _doc({
  required int version,
  String? rev,
  required Map<String, String> names,
}) {
  final doc = <String, dynamic>{
    'version': version,
    'count': names.length,
    'tags': {
      for (final e in names.entries)
        e.key: {
          'y': 'general',
          's': 0,
          'n': {'zh-CN': e.value},
        }
    },
  };
  if (rev != null) doc['rev'] = rev;
  return jsonEncode(doc);
}

void main() {
  group('peekSnapshot', () {
    test('读出 version / rev / 条目数', () {
      final s = peekSnapshot(
        _doc(version: 2, rev: 'abcdef0123456789', names: {'a': '甲', 'b': '乙'}),
        _countTags,
      );
      expect(s, isNotNull);
      expect(s!.version, 2);
      expect(s.rev, 'abcdef0123456789');
      expect(s.count, 2);
    });

    test('旧产物没有 rev，也要能读出来而不是整个失败', () {
      final s = peekSnapshot(_doc(version: 1, names: {'a': '甲'}), _countTags);
      expect(s, isNotNull);
      expect(s!.version, 1);
      expect(s.rev, isNull);
    });

    test('坏数据返回 null，不会被写进缓存', () {
      expect(peekSnapshot('not json', _countTags), isNull);
      expect(peekSnapshot(_doc(version: 2, rev: 'x', names: {}), _countTags),
          isNull,
          reason: '空词库不该顶掉已有数据');
    });
  });

  group('shouldRebuild', () {
    const loaded =
        DictionarySnapshot(version: 2, rev: 'aaaaaaaaaaaaaaaa', count: 100);

    test('★ 条目数不变、只改了译名，也必须重建', () {
      // 这一条正是旧启发式判不出来的情况。
      const incoming =
          DictionarySnapshot(version: 2, rev: 'bbbbbbbbbbbbbbbb', count: 100);
      expect(shouldRebuild(loaded, incoming), isTrue,
          reason: '内容变了但条数没变 → 旧实现会漏掉，修正要等冷启动');
    });

    test('指纹相同则不重建，避免每次启动白白重建一遍', () {
      const incoming =
          DictionarySnapshot(version: 2, rev: 'aaaaaaaaaaaaaaaa', count: 100);
      expect(shouldRebuild(loaded, incoming), isFalse);
    });

    test('还没加载过任何数据时一律重建', () {
      expect(shouldRebuild(null, loaded), isTrue);
    });

    test('远端还是旧产物（无 rev）时退回条目数判据', () {
      const oldStyle = DictionarySnapshot(version: 1, rev: null, count: 100);
      expect(shouldRebuild(loaded, oldStyle), isFalse, reason: '条数相同');
      expect(
        shouldRebuild(
            loaded, const DictionarySnapshot(version: 1, rev: null, count: 101)),
        isTrue,
      );
    });

    test('本地缓存是旧产物、远端已升级时同样退回条目数判据', () {
      const staleLocal = DictionarySnapshot(version: 1, rev: null, count: 100);
      const fresh =
          DictionarySnapshot(version: 2, rev: 'cccccccccccccccc', count: 100);
      expect(shouldRebuild(staleLocal, fresh), isFalse,
          reason: '无法比对指纹时不敢断定有变化，留给下次冷启动读缓存');
    });
  });
}
