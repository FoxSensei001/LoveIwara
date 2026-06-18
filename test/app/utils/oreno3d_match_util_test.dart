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

    test('strips brackets and emoji that taint tokenization', () {
      // 含【】和 🥰 的标题：括号和 emoji 都应被替换为空格，token 不再粘连。
      final input = '六一肏一个爱苪🥰【爱苪 绝区零 妄想天使 Aria ZZZ アリア ゼンゼロ 妄想エンジェル】';
      final result = Oreno3dMatchUtil.sanitizeKeyword(input);
      expect(result.contains('【'), isFalse);
      expect(result.contains('】'), isFalse);
      expect(result.contains('🥰'), isFalse);
      // 连接处不再粘连
      expect(result.contains('爱苪🥰'), isFalse);
      expect(result.contains('爱苪【'), isFalse);
      // 词本身仍保留
      expect(result.contains('妄想エンジェル'), isTrue);
      expect(result.contains('Aria ZZZ'), isTrue);
    });

    test('strips various bracket pairs and decorative symbols', () {
      expect(
        Oreno3dMatchUtil.sanitizeKeyword('a[b](c){d}（e）「f」『g』〈h〉《i》'),
        'a b c d e f g h i',
      );
      expect(
        Oreno3dMatchUtil.sanitizeKeyword('Furina ★dance♥ Genshin'),
        'Furina dance Genshin',
      );
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

  group('Oreno3dMatchUtil.extractKeywordCandidates', () {
    test('real-world ZZZ Aria title puts the most distinctive CJK word first',
        () {
      // 这是触发本次修复的 case：原本把整条标题塞给 oreno3d 会被热门视频
      // 挤掉，目标视频 #337468 进不了前 5 候选；改用本方法后第一个候选
      // 应当是最长的 CJK 词（妄想エンジェル），它在线上能让 #337468 排到 top 1。
      final input =
          '六一肏一个爱苪🥰【爱苪 绝区零 妄想天使 Aria ZZZ アリア ゼンゼロ 妄想エンジェル】';
      final candidates = Oreno3dMatchUtil.extractKeywordCandidates(input);

      // 第一个候选必须是最长的 CJK 词
      expect(candidates.first, '妄想エンジェル');
      // 至少要包含 "Aria ZZZ" 这个 ASCII 词对（实测能命中目标）
      expect(candidates, contains('Aria ZZZ'));
      // 候选数有上限，不会爆炸
      expect(candidates.length, lessThanOrEqualTo(7));
      // 最后一个候选是兜底的全标题净化版（命中率最差，但保留旧行为）
      expect(candidates.last.contains('六一肏一个爱苪'), isTrue);
    });

    test('prioritizes content inside brackets over the prefix', () {
      // 括号外的"个性化前缀"（六一肏一个爱苪）不应进入 CJK 长词候选——
      // 那段没有空格分词、整段是一个超长 token，对 oreno3d 搜索毫无帮助。
      final input =
          '六一肏一个爱苪🥰【爱苪 绝区零 妄想天使 Aria ZZZ アリア ゼンゼロ 妄想エンジェル】';
      final candidates = Oreno3dMatchUtil.extractKeywordCandidates(input);

      // 不应把整条前缀作为单独候选去搜
      expect(candidates, isNot(contains('六一肏一个爱苪')));
      // 但括号里的词都应该在候选里出现（按 CJK 长度排，前 3 名）
      final top3 = candidates.take(3).toList();
      expect(top3, contains('妄想エンジェル'));
      // 妄想天使 / 绝区零 二选一上榜（长度都 >= 3）
      expect(
        top3.any((c) => c == '妄想天使' || c == '绝区零'),
        isTrue,
      );
    });

    test('falls back to whole-title tokens when no brackets present', () {
      final candidates = Oreno3dMatchUtil.extractKeywordCandidates(
        'Furina dance 妄想エンジェル',
      );
      // CJK 长词排第一
      expect(candidates.first, '妄想エンジェル');
      // 完整标题作为最后兜底
      expect(candidates.last, 'Furina dance 妄想エンジェル');
    });

    test('ASCII-only title yields ASCII pair candidates and full fallback', () {
      final candidates =
          Oreno3dMatchUtil.extractKeywordCandidates('Aria ZZZ HMV remix');
      // 应当包含至少一个连续 ASCII 词对
      expect(
        candidates.any(
          (c) => c == 'Aria ZZZ' || c == 'ZZZ HMV' || c == 'HMV remix',
        ),
        isTrue,
      );
      // 兜底必含完整标题
      expect(candidates, contains('Aria ZZZ HMV remix'));
    });

    test('deduplicates candidates and keeps order', () {
      // 单 CJK 词标题：第一候选（CJK 词）和最后兜底（完整标题）会相同，
      // 应自动去重而非出现两次。
      final candidates =
          Oreno3dMatchUtil.extractKeywordCandidates('妄想エンジェル');
      expect(candidates, ['妄想エンジェル']);
    });

    test('empty title returns empty list', () {
      expect(Oreno3dMatchUtil.extractKeywordCandidates(''), isEmpty);
      expect(Oreno3dMatchUtil.extractKeywordCandidates('   '), isEmpty);
    });

    test('skips short single-char CJK tokens', () {
      // 单字 CJK 区分度太低（如 "雅"、"零"），不应进入 CJK 候选；
      // 但完整标题净化版兜底必须保留。
      final candidates = Oreno3dMatchUtil.extractKeywordCandidates('a 雅 b 零 c');
      expect(candidates, isNot(contains('雅')));
      expect(candidates, isNot(contains('零')));
      expect(candidates, contains('a 雅 b 零 c'));
    });
  });
}
