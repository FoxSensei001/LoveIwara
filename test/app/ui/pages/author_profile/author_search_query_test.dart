import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/author_profile/author_search_query.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 作者页搜索拼出的 `/search` 查询串。⛔ 拼错不会报错：字段名错了返回全站、
/// 文本放在花括号后面会被静默丢掉，所以这里把形状钉死。
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  test('文本在前，{author:…} 在后', () {
    expect(
      authorSearchQuery(
        keyword: ' miku ',
        username: 'gfsmmd',
        exactMatch: false,
      ),
      'miku {author:gfsmmd}',
    );
    final parts = splitQueryParts(
      authorSearchQuery(keyword: 'miku', username: 'gfsmmd', exactMatch: false),
    );
    expect(parts.text, 'miku');
    expect(parts.filters, '{author:gfsmmd}');
  });

  test('精确匹配开着时 CJK 词补引号，与搜索页同一条规则', () {
    expect(
      authorSearchQuery(keyword: '初音ミク', username: 'a', exactMatch: true),
      '"初音ミク" {author:a}',
    );
  });

  test('每个标签一对花括号（AND），不是 [a,b]（OR）', () {
    expect(
      authorSearchQuery(
        keyword: 'x',
        username: 'a',
        tagIds: ['hatsune_miku', 'dance'],
        exactMatch: false,
      ),
      'x {author:a} {tags:[hatsune_miku]} {tags:[dance]}',
    );
  });

  test('年 / 年月换成 UTC 秒的半开区间，认不出的日期不筛', () {
    final year = authorSearchQuery(
      keyword: 'x',
      username: 'a',
      date: '2024',
      exactMatch: false,
    );
    expect(year, 'x {author:a} {date>=1704067200} {date<1735689600}');

    final december = authorSearchQuery(
      keyword: 'x',
      username: 'a',
      date: '2024-12',
      exactMatch: false,
    );
    expect(december, 'x {author:a} {date>=1733011200} {date<1735689600}');

    for (final bad in ['2024-13', '24', 'abc']) {
      expect(
        authorSearchQuery(
          keyword: 'x',
          username: 'a',
          date: bad,
          exactMatch: false,
        ),
        'x {author:a}',
        reason: bad,
      );
    }
  });

  test('热门 / 趋势在搜索里没有对应，退成相关度', () {
    expect(authorSearchSort('date'), 'date');
    expect(authorSearchSort('likes'), 'likes');
    expect(authorSearchSort('views'), 'views');
    expect(authorSearchSort('popularity'), isNull);
    expect(authorSearchSort('trending'), isNull);
  });
}
