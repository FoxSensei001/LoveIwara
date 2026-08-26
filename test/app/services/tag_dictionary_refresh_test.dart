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
  String? builtAt,
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
  if (builtAt != null) doc['builtAt'] = builtAt;
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
      expect(s.builtAt, isNull, reason: '没写 builtAt 的产物要读成 null 而不是报错');
    });

    test('读出 builtAt 并归一到 UTC', () {
      final s = peekSnapshot(
        _doc(
          version: 2,
          rev: 'aaaaaaaaaaaaaaaa',
          builtAt: '2026-08-25T12:00:00.000Z',
          names: {'a': '甲'},
        ),
        _countTags,
      );
      expect(s!.builtAt, DateTime.utc(2026, 8, 25, 12));
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

    test('★ CDN 那份明显更旧时不许降级', () {
      // jsDelivr 的 @master 可以滞后好几天，而用户装的包可能比它新；
      // 只看指纹「不一样」就重建，会把新词库换成旧词库。
      final loaded = DictionarySnapshot(
        version: 2,
        rev: 'aaaaaaaaaaaaaaaa',
        count: 100,
        builtAt: DateTime.utc(2026, 8, 25),
      );
      final older = DictionarySnapshot(
        version: 2,
        rev: 'bbbbbbbbbbbbbbbb',
        count: 100,
        builtAt: DateTime.utc(2026, 6, 1),
      );
      expect(shouldRebuild(loaded, older), isFalse);
      final newer = DictionarySnapshot(
        version: 2,
        rev: 'cccccccccccccccc',
        count: 100,
        builtAt: DateTime.utc(2026, 9, 1),
      );
      expect(shouldRebuild(loaded, newer), isTrue);
    });

    test('★ 远端有 rev 但没有 builtAt 时也算更旧，不许降级', () {
      // 2026-08-26 真机现场：包里是 5155 条角色（builtAt 08-26），
      // jsDelivr @master 还停在 1600 条的上一版产物——它有 rev、没有 builtAt。
      // 「两边都有 builtAt 才挡降级」漏掉了这一格：指纹不同 → 重建 →
      // 启动几秒后新词库被换回旧的（丹花イブキ 又变回日文）。
      final loaded = DictionarySnapshot(
        version: 2,
        rev: 'aaaaaaaaaaaaaaaa',
        count: 6144,
        builtAt: DateTime.utc(2026, 8, 26),
      );
      const olderWithoutStamp = DictionarySnapshot(
        version: 2,
        rev: 'bbbbbbbbbbbbbbbb',
        count: 2580,
      );
      expect(shouldRebuild(loaded, olderWithoutStamp), isFalse);
    });
  });

  group('isStaleIncoming', () {
    test('本地没有 builtAt 时不做判断，交给指纹/条目数', () {
      const loaded = DictionarySnapshot(version: 2, rev: 'a', count: 100);
      const incoming = DictionarySnapshot(version: 2, rev: 'b', count: 100);
      expect(isStaleIncoming(loaded, incoming), isFalse);
      expect(isStaleIncoming(null, incoming), isFalse);
    });

    test('本地有 builtAt、远端没有 → 远端确定更旧', () {
      final loaded = DictionarySnapshot(
        version: 2,
        rev: 'a',
        count: 100,
        builtAt: DateTime.utc(2026, 8, 26),
      );
      const incoming = DictionarySnapshot(version: 2, rev: 'b', count: 100);
      expect(isStaleIncoming(loaded, incoming), isTrue);
    });

    test('两边都有 builtAt 时按时间先后', () {
      final loaded = DictionarySnapshot(
        version: 2,
        rev: 'a',
        count: 100,
        builtAt: DateTime.utc(2026, 8, 26),
      );
      DictionarySnapshot at(DateTime t) =>
          DictionarySnapshot(version: 2, rev: 'b', count: 100, builtAt: t);
      expect(isStaleIncoming(loaded, at(DateTime.utc(2026, 8, 25))), isTrue);
      expect(isStaleIncoming(loaded, at(DateTime.utc(2026, 8, 27))), isFalse);
      expect(isStaleIncoming(loaded, at(DateTime.utc(2026, 8, 26))), isFalse,
          reason: '同一份产物不算更旧');
    });
  });

  group('assetBeatsCache', () {
    DictionarySnapshot snap(DateTime? builtAt, {int count = 100}) =>
        DictionarySnapshot(
          version: 2,
          rev: 'aaaaaaaaaaaaaaaa',
          count: count,
          builtAt: builtAt,
        );

    test('★ 打包资源比缓存新时必须赢', () {
      // 这一条正是老实现（缓存无条件优先）判错的情况：
      // 发版带了更新的词库，用户本地还留着上一版缓存 → 一直用旧的，
      // 连不上 jsDelivr 的用户永远等不到新译名。
      expect(
        assetBeatsCache(
          snap(DateTime.utc(2026, 6, 1)),
          snap(DateTime.utc(2026, 8, 25)),
        ),
        isTrue,
      );
    });

    test('缓存更新时仍然用缓存——CDN 免发版更新的路子不能被堵死', () {
      expect(
        assetBeatsCache(
          snap(DateTime.utc(2026, 8, 25)),
          snap(DateTime.utc(2026, 6, 1)),
        ),
        isFalse,
      );
    });

    test('缓存没有 builtAt、打包有 → 打包赢', () {
      // 没有 builtAt 的缓存必定早于这个字段本身，先后关系是确定的。
      expect(assetBeatsCache(snap(null), snap(DateTime.utc(2026, 8, 25))),
          isTrue);
    });

    test('两边都没有 builtAt 时保持老行为：缓存优先', () {
      expect(assetBeatsCache(snap(null), snap(null)), isFalse);
    });

    test('缓存解析不出来（损坏）时用打包资源', () {
      expect(assetBeatsCache(null, snap(DateTime.utc(2026, 8, 25))), isTrue);
    });

    test('打包资源解析不出来时不要丢掉可用的缓存', () {
      expect(assetBeatsCache(snap(DateTime.utc(2026, 8, 25)), null), isFalse);
    });
  });
}
