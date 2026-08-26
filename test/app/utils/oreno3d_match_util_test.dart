import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/oreno3d_match_util.dart';

void main() {
  group('Oreno3dMatchUtil.queryTokens', () {
    test('drops punctuation / brackets / emoji, keeps words', () {
      // issue #95 的破句字符（连字符）与装饰符号都必须变成分隔符，
      // 否则 oreno3d 站内搜索会被打宽、目标视频被热门榜挤掉。
      final tokens = Oreno3dMatchUtil.queryTokens("Furina - I'm ill🥰【dance】");
      expect(tokens, ['Furina', 'ill', 'dance']);
    });

    test('splits katakana middle dot so each name is its own token', () {
      // 「・」是分隔符而不是词的一部分：プリンツ・オイゲン 必须切成两个 token，
      // 否则拼出来的查询在站内一条都匹配不到。
      final tokens = Oreno3dMatchUtil.queryTokens('【MMD】プリンツ・オイゲンの誘惑Apple Pie');
      expect(tokens, ['MMD', 'プリンツ', 'オイゲンの誘惑Apple', 'Pie']);
    });

    test('keeps single-char CJK but drops single latin char and pure digits',
        () {
      // 中日文单字仍有区分度；单个拉丁字母和纯数字（4K 里的 4、60fps 里的 60）
      // 到处都是，只会把 AND 查询打宽。
      final tokens = Oreno3dMatchUtil.queryTokens('a 雅 b 零 c 4 60 4K');
      expect(tokens, ['雅', '零', '4K']);
    });

    test('folds full-width alphanumerics before tokenizing', () {
      final tokens = Oreno3dMatchUtil.queryTokens('（ＭＭＤ）ｄａｎｃｅ');
      expect(tokens, ['MMD', 'dance']);
    });


    test('deduplicates repeated words (AND 查询里重复毫无作用)', () {
      final tokens = Oreno3dMatchUtil.queryTokens('菲比 泳装 菲比 菲比');
      expect(tokens, ['菲比', '泳装']);
    });

    test('title with no usable token yields empty list', () {
      expect(Oreno3dMatchUtil.queryTokens('👾'), isEmpty);
      expect(Oreno3dMatchUtil.queryTokens('   '), isEmpty);
    });
  });

  group('Oreno3dMatchUtil.buildSearchQueries', () {
    test('first query joins the whole title (AND narrows, one word does not)',
        () {
      // 站内实测是 AND 语义：把标题的词拼成一条查询才够窄；
      // 一个词搜一次只会拿到按热度排的宽结果。
      final queries = Oreno3dMatchUtil.buildSearchQueries(
        "Furina - I'm ill",
        'someone',
      );
      expect(queries.first, "Furina ill");
    });

    test('orders as title -> author -> two most distinctive tokens', () {
      final queries = Oreno3dMatchUtil.buildSearchQueries(
        '六一肏一个爱苪🥰【爱苪 绝区零 妄想天使 Aria ZZZ アリア ゼンゼロ 妄想エンジェル】',
        '10yue',
      );
      expect(queries.length, 3);
      expect(queries[0], startsWith('六一肏一个爱苪'));
      expect(queries[1], '10yue');
      // 第三条是最显著的两个词：长且是 CJK 的优先。
      expect(queries[2], '六一肏一个爱苪 妄想エンジェル');
    });

    test('caps the joined query by salience, keeping the distinctive tail', () {
      // token 超过上限时丢的是「最不显著的」而不是「最后几个」——
      // 标题里最有区分度的词常常正好排在末尾（本例的 妄想エンジェル）。
      final queries = Oreno3dMatchUtil.buildSearchQueries(
        '六一肏一个爱苪🥰【爱苪 绝区零 妄想天使 Aria ZZZ アリア ゼンゼロ 妄想エンジェル】',
        null,
      );
      final firstTokens = queries.first.split(' ');
      expect(firstTokens.length, 8);
      expect(firstTokens, contains('妄想エンジェル'));
      expect(firstTokens, isNot(contains('ZZZ'))); // 最短的拉丁词被丢掉
      // 原有顺序保留，不能被显著度排序打乱。
      expect(firstTokens.first, '六一肏一个爱苪');
      expect(firstTokens.last, '妄想エンジェル');
    });

    test('never emits more than three queries', () {
      final queries = Oreno3dMatchUtil.buildSearchQueries(
        'aa bb cc dd ee ff gg hh ii jj',
        'author',
      );
      expect(queries.length, lessThanOrEqualTo(3));
    });

    test('returns nothing to search when there is neither token nor author', () {
      // 触发「一次都搜不成」的输入：纯 emoji 标题 + 没有作者名。
      // 控制器据此**不**写负缓存——一次都没搜过，不能judge成「oreno3d 上没有」。
      expect(Oreno3dMatchUtil.buildSearchQueries('👾', null), isEmpty);
      expect(Oreno3dMatchUtil.buildSearchQueries('🥰🎉', '   '), isEmpty);
    });

    test('ties in salience keep the original order (sort 稳定性不可依赖)', () {
      // 两个显著度相同的 token（同为 4 字 CJK）必须按标题里的先后排，
      // 不能随 List.sort 的实现摇摆。
      final tokens = Oreno3dMatchUtil.queryTokens('妄想天使 绝区零零 幻想少女 x');
      expect(Oreno3dMatchUtil.distinctiveTokens(tokens, 2), [
        '妄想天使',
        '绝区零零',
      ]);
    });

    test('deduplicates when the title is a single token', () {
      final queries = Oreno3dMatchUtil.buildSearchQueries('妄想エンジェル', null);
      expect(queries, ['妄想エンジェル']);
    });

    test('falls back to the author alone when the title has no usable token',
        () {
      // 「👾」这种纯 emoji 标题切不出任何 token，作者名是唯一线索。
      final queries = Oreno3dMatchUtil.buildSearchQueries('👾', 'そこに田中');
      expect(queries, ['そこに田中']);
    });

    test('skips a blank author instead of emitting an empty query', () {
      final queries = Oreno3dMatchUtil.buildSearchQueries('Fukkireta', '   ');
      expect(queries, ['Fukkireta']);
      expect(queries.any((q) => q.trim().isEmpty), isFalse);
    });
  });

  group('Oreno3dMatchUtil.titleAffinity', () {
    test('identical titles score 1.0 despite case/width/space differences', () {
      expect(
        Oreno3dMatchUtil.titleAffinity(
          'Elysia  Mobius-Chocolate Cream',
          'elysia Mobius - Chocolate Cream',
        ),
        1.0,
      );
      expect(
        Oreno3dMatchUtil.titleAffinity('【ＭＭＤ】дance', '[MMD] дance'),
        1.0,
      );
    });

    test('ranks the real match above hot-list noise for a CJK title', () {
      // 回归护栏：旧实现按空格分词 + 双向 contains，中文标题整条是一个 token，
      // 相似度只会得到 0 或 1，排序等于失效。这里必须给出连续的区分度。
      const iwaraTitle = '风骚丈母娘(上)';
      final real = Oreno3dMatchUtil.titleAffinity(iwaraTitle, '风骚丈母娘（上）');
      final noise = Oreno3dMatchUtil.titleAffinity(iwaraTitle, '黒マスクお姉さんの裏バイト');
      expect(real, 1.0);
      expect(noise, lessThan(Oreno3dMatchUtil.verifyGate));
      expect(real, greaterThan(noise));
    });

    test('partial overlap lands strictly between 0 and 1', () {
      final score = Oreno3dMatchUtil.titleAffinity(
        '蕾米埃尔 Remielle Part 2',
        '蕾米埃尔 Remielle',
      );
      expect(score, greaterThan(0.0));
      expect(score, lessThan(1.0));
    });

    test('empty or symbol-only input scores 0', () {
      expect(Oreno3dMatchUtil.titleAffinity('', 'anything'), 0.0);
      expect(Oreno3dMatchUtil.titleAffinity('🥰', 'anything'), 0.0);
    });
  });

  group('Oreno3dMatchUtil.isSameAuthor', () {
    test('tolerates case, width and stray whitespace', () {
      expect(Oreno3dMatchUtil.isSameAuthor('Redgectx ', 'redgectx'), isTrue);
      expect(Oreno3dMatchUtil.isSameAuthor('ＭＭＤ Guy', 'mmdguy'), isTrue);
    });

    test('different authors and null/blank are not the same', () {
      expect(Oreno3dMatchUtil.isSameAuthor('10yue', 'muta81'), isFalse);
      expect(Oreno3dMatchUtil.isSameAuthor(null, 'muta81'), isFalse);
      expect(Oreno3dMatchUtil.isSameAuthor('  ', '  '), isFalse);
    });
  });

  group('Oreno3dMatchUtil.candidateScore / verifyGate', () {
    test('same author alone clears the gate even with an unlike title', () {
      // 作者名抓自 iwara 且逐字相同，撞名概率远低于标题撞词，
      // 因此「同作者」本身就值得为它拉一次详情页校验。
      final score = Oreno3dMatchUtil.candidateScore(
        iwaraTitle: 'ZZZ: 调教新艾利都的母猪们-蕾米埃尔（下）',
        iwaraAuthor: '全民制作人',
        candidateTitle: '完全无关的另一条作品',
        candidateAuthor: '全民制作人',
      );
      expect(score, greaterThanOrEqualTo(Oreno3dMatchUtil.verifyGate));
    });

    test('hot-list noise stays below the gate so no detail page is fetched',
        () {
      // 站内一个词都命中不了时会返回整站热门榜；这些结果必须一条都进不了校验，
      // 否则每次未命中都要白白拉三个 86KB 的详情页（issue #95 的观感来源）。
      const iwaraTitle = '风骚丈母娘(上)';
      const noise = ['♥がVIPルームでポールダンス', 'な◯じゃもちゃんに負かされる動画です', '黒マスクお姉さんの裏バイト'];
      for (final title in noise) {
        final score = Oreno3dMatchUtil.candidateScore(
          iwaraTitle: iwaraTitle,
          iwaraAuthor: '咕咕嘎嘎',
          candidateTitle: title,
          candidateAuthor: 'kem_kem',
        );
        expect(
          score,
          lessThan(Oreno3dMatchUtil.verifyGate),
          reason: '热门榜噪声 "$title" 不应进入 ID 校验',
        );
      }
    });

    test('an exact title match clears the gate even without the author', () {
      final score = Oreno3dMatchUtil.candidateScore(
        iwaraTitle: 'Fukkireta',
        iwaraAuthor: 'osuimono',
        candidateTitle: 'Fukkireta',
        candidateAuthor: '别的名字',
      );
      expect(score, greaterThanOrEqualTo(Oreno3dMatchUtil.verifyGate));
    });
  });
}
