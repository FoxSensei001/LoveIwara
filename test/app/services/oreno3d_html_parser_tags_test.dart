// 列表卡片标签解析的闸门。
//
// 背景：原实现按 `\s+` 切分卡片上的标签文本，而 oreno3d 词条名里有 7 个带空格
// （PiNK CAT / Apple Pie / kiss me 愛してる…），`PiNK CAT` 会被切成两个碎片，
// 两个都查不到译名，用户看到的就是「翻译坏了」。
//
// 下面的 HTML 取自真实页面 https://oreno3d.com/tags/33 ——
// 卡片上的标签是纯文本节点、逐行排列，整个 article 里只有一个 <a>，
// 没有 id，所以卡片只能按日文名兜底本地化。
//
// 这里走**真正的 parseSearchResult 入口**，而不是复刻一份切分逻辑——
// 测复制品的话，真代码退化了测试照样绿。
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/oreno3d_html_parser.dart';

const _realPage = '''
<html><body>
<div class="g-main-grid">
<article>
  <a class="box" href="https://oreno3d.com/movies/340810">
    <h2 class="box-h2">テスト動画</h2>
    <img class="main-thumbnail" src="https://oreno3d.com/thumb.jpg">
    <div class="box-text1"><div class="box-text-in">mitsuboshiL</div></div>
    <div class="box-text2">
      <i class="material-icons md-dark md-18-20">local_offer</i>
      <div class="box-text-in">
                                    主観視点
                                    性行為有り
                                    ダンス有り
                                    PiNK CAT
                                    撮影・ハメ撮り
                                    淫乱
                                    巨乳
      </div>
    </div>
  </a>
</article>
</div>
</body></html>
''';

void main() {
  test('★ 名字里带空格的标签不能被切碎', () {
    final result = Oreno3dHtmlParser.parseSearchResult(_realPage, 'PiNK CAT');
    expect(result.videos, hasLength(1));
    final tags = result.videos.single.tags;

    expect(tags, contains('PiNK CAT'),
        reason: '按 \\s+ 切会得到 PiNK 和 CAT 两个碎片，两个都查不到译名');
    expect(tags, isNot(contains('PiNK')));
    expect(tags, isNot(contains('CAT')));
  });

  test('普通标签照常解析，中黑点不受影响，不产生空条目', () {
    final tags =
        Oreno3dHtmlParser.parseSearchResult(_realPage, 'x').videos.single.tags;
    expect(tags, <String>[
      '主観視点',
      '性行為有り',
      'ダンス有り',
      'PiNK CAT',
      '撮影・ハメ撮り',
      '淫乱',
      '巨乳',
    ]);
  });

  test('「なし」表示无标签', () {
    final page = _realPage.replaceAll(
      RegExp(r'<div class="box-text-in">\s*主観視点.*?</div>', dotAll: true),
      '<div class="box-text-in">なし</div>',
    );
    expect(
      Oreno3dHtmlParser.parseSearchResult(page, 'x').videos.single.tags,
      isEmpty,
    );
  });
}
