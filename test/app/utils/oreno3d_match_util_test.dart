import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/oreno3d_match_util.dart';

void main() {
  group('Oreno3dMatchUtil.sanitizeKeyword', () {
    test('removes hyphen/dash that breaks oreno3d search (issue #95)', () {
      final result = Oreno3dMatchUtil.sanitizeKeyword("Furina - I'm ill");
      expect(result.contains('-'), isFalse);
      expect(result, "Furina I'm ill");
    });

    test('strips various dash characters', () {
      expect(Oreno3dMatchUtil.sanitizeKeyword('a–b—c―d‐e'), 'a b c d e');
    });

    test('collapses multiple spaces and trims', () {
      expect(Oreno3dMatchUtil.sanitizeKeyword('  hello   world  '), 'hello world');
    });

    test('leaves clean keyword untouched', () {
      expect(Oreno3dMatchUtil.sanitizeKeyword('Furina'), 'Furina');
    });
  });

  group('Oreno3dMatchUtil.titleSimilarity', () {
    test('empty words do not produce false full match (issue #95 bug)', () {
      // 复刻旧实现的 bug 场景：含双空格的无关标题不应被判为高相似度
      final sim = Oreno3dMatchUtil.titleSimilarity(
        'Genshin Furina dance',
        'Kantai  Umikaze', // 双空格
      );
      expect(sim, lessThan(0.5));
    });

    test('whitespace-only title returns 0', () {
      expect(Oreno3dMatchUtil.titleSimilarity('hello world', ' '), 0.0);
    });

    test('empty title1 returns 0', () {
      expect(Oreno3dMatchUtil.titleSimilarity('', 'anything'), 0.0);
    });

    test('identical titles return 1.0', () {
      expect(Oreno3dMatchUtil.titleSimilarity('a b c', 'a b c'), 1.0);
    });

    test('partial overlap returns proportional score', () {
      // 'a' 匹配, 'z' 不匹配 -> 1/2
      expect(Oreno3dMatchUtil.titleSimilarity('a z', 'a b'), 0.5);
    });

    test('substring match counts (bidirectional contains)', () {
      expect(Oreno3dMatchUtil.titleSimilarity('fur', 'furina'), 1.0);
    });
  });
}
