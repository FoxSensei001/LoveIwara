import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/tag_name_index.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';

/// 搜索规划的几条硬约束，拿真词库跑（见 planSearchRoutes 上的评测表）。
void main() {
  final tags = (jsonDecode(File('assets/data/iwara_tags.min.json').readAsStringSync())
      as Map<String, dynamic>)['tags'] as Map<String, dynamic>;
  final index = TagNameIndex.fromTags(tags);

  List<String> plan(String q, [String type = 'videos']) => planSearchRoutes(
    q,
    apiType: type,
    resolveTag: index.match,
  ).routes.map((r) => r.query).toList();

  test('中文角色名：标签 + 日英文名 + 标题补路，原话在第一路', () {
    expect(plan('"初音未来" {date>=1}'), [
      '"初音未来" {date>=1}',
      '{tags:[hatsune_miku]} {date>=1}',
      '"初音ミク" {date>=1}',
      '"Hatsune Miku" {date>=1}',
      '{title_zh:"初音未来"} {date>=1}',
      '{title_ja:"初音未来"} {date>=1}',
    ]);
  });

  test('同名多标签合进一个 [a,b]；认不出的词留在文本里、排在筛选前', () {
    final routes = plan('"巨乳" 某某');
    expect(routes[1], startsWith('某某 {tags:[big_boobs,big_breasts,'));
  });

  test('相邻词合起来认；繁体原话不再补简体名那一路', () {
    expect(plan('hatsune miku')[1], '{tags:[hatsune_miku]}');
    expect(plan('"初音未來"').where((q) => q == '"初音未来"'), isEmpty);
  });

  test('排除标签名给每一路加 tags!=；用户手敲的筛选顺序被纠正', () {
    final routes = plan('{rating:general} "初音未来" -原神');
    expect(routes.first, '"初音未来" -原神 {rating:general} {tags!=[ganshin,genshin_impact]}');
    expect(routes.every((q) => q.contains('{tags!=[ganshin,genshin_impact]}')), isTrue);
  });

  test('没有 tags 字段的分段、认不出的词：维持原先的两路标题补路', () {
    expect(plan('"初音未来"', 'users'), [
      '"初音未来"',
      '{name_zh:"初音未来"}',
      '{name_ja:"初音未来"}',
    ]);
    expect(plan('"白金ディスコ"').length, 3);
  });

  test('认出标签时标题补路不依赖引号；带排除词就不补', () {
    expect(plan('藿藿'), contains('{title_zh:"藿藿"}'));
    expect(plan('藿藿 -MMD').where((q) => q.startsWith('{title_')), isEmpty);
    // 认不出标签的裸词照旧不补（没有核对兜底，碎片召回会混进来）。
    expect(plan('白金ディスコ').where((q) => q.startsWith('{title_')), isEmpty);
  });

  test('名字里的危险写法不进引号短语；名字路要核对', () {
    final r = planSearchRoutes('"舰队Collection"', apiType: 'videos', resolveTag: index.match).routes;
    expect(r.map((e) => e.query).any((q) => q.contains(' -艦これ-')), isFalse);
    expect(r.where((e) => e.kind == SearchRouteKind.alias).every((e) => e.needsVerify), isTrue);
  });
}
