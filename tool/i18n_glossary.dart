// 生成 docs/i18n-glossary.md：术语表（从各语言**实际译文**抽取，不是另写一套）
// + 翻译规范。
//
// 用法：dart run tool/i18n_glossary.dart
//
// 术语表按 key 锚点从 lib/i18n/*.i18n.yaml 里现取，因此永远与仓库里的真实译法
// 一致；如果某门语言在锚点上用了别的词，说明术语没对齐，这里会直接看出来。
import 'dart:io';

import 'package:yaml/yaml.dart';

const _baseLocale = 'en';
const _i18nDir = 'lib/i18n';

/// 术语 -> 锚点 key（锚点取该术语最典型的那条词条）
const _anchors = <String, String>{
  '视频 Video': 'common.video',
  '图库 Gallery': 'common.gallery',
  '播放列表 Playlist': 'common.playlist',
  '标签 Tag': 'common.tag',
  '搜索 Search': 'common.search',
  '设置 Settings': 'common.settings',
  '历史记录 History': 'common.history',
  '下载 Download': 'common.download',
  '筛选 Filter': 'common.filter',
  '排序 Sort': 'common.sort',
  '作者 Author': 'common.author',
  '关注 Follow': 'common.follow',
  '已关注 Followed': 'common.followed',
  '特别关注 Special Follow': 'common.specialFollow',
  '评论 Comment': 'common.commentList',
  '发送评论 Send Comment': 'common.sendComment',
  '回复 Reply': 'common.reply',
  '翻译 Translate': 'common.translate',
  '点赞数 Likes': 'common.likesCount',
  '播放量 Views': 'common.viewsCount',
  '热门 Popular': 'common.popular',
  '会员 Premium': 'common.premium',
  '好友 Friend': 'common.friend',
  '加载中 Loading': 'common.loading',
  '保存 Save': 'common.save',
  '删除 Delete': 'common.delete',
  '取消 Cancel': 'common.cancel',
  '确定 OK': 'common.ok',
};

Map<String, String> _flatten(YamlMap node, [String prefix = '']) {
  final result = <String, String>{};
  for (final entry in node.entries) {
    final key = prefix.isEmpty ? '${entry.key}' : '$prefix.${entry.key}';
    final value = entry.value;
    if (value is YamlMap) {
      result.addAll(_flatten(value, key));
    } else {
      result[key] = '$value';
    }
  }
  return result;
}

const _rules = r'''
## 1. 文体（硬要求）

| 语言 | 文体 |
|---|---|
| ko 韩语 | 합니다体（正式敬语） |
| ru 俄语 | 正式「вы」。比英文长 20~45%，按钮/标签类优先选最短的合法表达，必要时名词化 |
| th 泰语 | 礼貌书面泰语，可省略句末 `ครับ/ค่ะ` 保持中性。**词间不加空格**，只在子句之间断句 |
| es 西语 | 中性西班牙语，用 `usted`，**不要用 `vosotros`**（西班牙本土用法，拉美读者不用） |
| fr 法语 | 正式 `vous`。较英文长，短词条从简 |
| de 德语 | 正式 `Sie`。**复合词很长**，是欧语里最容易撑爆布局的，短标签务必压缩 |
| vi 越南语 | 中性礼貌体，避免带人称代词的亲昵表达 |
| id 印尼语 | 正式书面体（`Anda`） |
| zh-CN / zh-TW / ja | 沿用既有译文与既有用词，不重译 |

UI 文案要短。这些词条大多进手机屏幕上的按钮、标签、导航项，长度即布局风险。

## 2. 占位符（最容易翻车）

`${xxx}` 与 `{xxx}` 两种形态都必须**原样保留**：不翻译、不改名、不增删、不调整大小写。

```yaml
# 对
watchedCleared: ล้างรายการที่ดูแล้ว ${count} รายการ
# 错——占位符被翻译了
watchedCleared: ล้างรายการที่ดูแล้ว ${จำนวน} รายการ
```

`dart run tool/i18n_check.dart` 会逐条比对占位符集合，不符即报「占位符不符」并使退出码为 1。

## 3. 不翻译的东西

- 品牌与技术名：`Iwara`、`Love Iwara`、`Oreno3D`、`MMD`、`Anime4K`、`Quest`、`VR`、`mpv`、`GitHub`、`Discord`、`Telegram`
- 格式与规格：`MP4`、`WEBM`、`4K`、`8K`、`1080p`、`60fps`
- Anime4K 预设名（`mode_a_hq` 一族）与型号名（`R18`、`EAC`、`Flat`、`Fisheye`）
- **作为「内容语言选项」出现的语言名**：`English`、`日本語`、`中文` —— 语言名用母语显示是国际惯例
- 例外：`settings.languageNativeName` / `settings.followSystemLanguage` /
  `settings.languageChangedMessage` 这三条**要翻译成该语言自己的文字**，因为语言选择器
  必须以「非当前应用语言」显示它们
- Markdown 语法（`**粗体**`）与转义换行 `\n`：结构保留，只译里面的文字

## 4. YAML 写法

- 只替换冒号右边的值。key 名、缩进、层级、行序、空行、注释一律不动
- 译文含 `:`、`#`、`"`、`'`，或以 `>` / `|` / `-` 等开头时必须加引号——**不要手写引号**，
  用 `dart run tool/i18n_apply.dart <locale> <tsv>` 写入，脚本按 en 的引号风格自动处理，
  并在写盘后重新解析逐条核对
- UTF-8、无 BOM、不得出现裸 tab

## 5. 没有复数机制

全部词条都是固定字符串，**没有任何 `(plural)` / `(context)` / `(rich)` 修饰符**。
俄语等有复杂复数规则的语言也**不要**自作主张引入复数变体或拆分 key——那会破坏结构。
需要表达数量时就用占位符原样写法。

## 6. 术语与「不需要翻译的相同值」

`n` 类词条（品牌名、预设名、纯占位符、纯数字符号）在台账里记为「无需翻译」，
它们与 en 逐字相同是**正确**的；把它们译成目标语言反而是缺陷。
判定规则与 `tool/i18n_check.dart` / `tool/i18n_ledger.dart` 里的白名单完全一致，
三处共用同一套判据。
''';

void main() {
  final locales = Directory(_i18nDir)
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n.endsWith('.i18n.yaml'))
      .map((n) => n.substring(0, n.length - '.i18n.yaml'.length))
      .toList()
    ..sort();
  final ordered = [_baseLocale, ...locales.where((l) => l != _baseLocale)];
  final data = {
    for (final l in ordered)
      l: _flatten(loadYaml(File('$_i18nDir/$l.i18n.yaml').readAsStringSync()) as YamlMap)
  };

  final missing = <String>[];
  final md = StringBuffer();
  md.writeln('# 术语表与翻译规范');
  md.writeln();
  md.writeln('本文件由 `dart run tool/i18n_glossary.dart` 生成。术语表按 key 锚点'
      '从 `lib/i18n/*.i18n.yaml` 的**实际译文**抽取，所以它永远等于仓库现状，'
      '不会出现「文档写一个词、代码里用另一个词」。');
  md.writeln();

  md.writeln('## 术语表');
  md.writeln();
  md.writeln('| 术语 | $_baseLocale | ${ordered.where((l) => l != 'en').join(' | ')} |');
  md.writeln('|---|---|${ordered.where((l) => l != _baseLocale).map((_) => '---').join('|')}|');
  for (final entry in _anchors.entries) {
    final key = entry.value;
    final cells = <String>[];
    for (final locale in ordered) {
      final value = data[locale]?[key];
      if (value == null) {
        if (locale == _baseLocale) missing.add('$key（en 侧锚点不存在）');
        cells.add('—');
      } else {
        cells.add(value.replaceAll('|', '\\|'));
      }
    }
    md.writeln('| ${entry.key} | ${cells.first} | ${cells.sublist(1).join(' | ')} |');
  }
  md.writeln();
  md.writeln('锚点 key：${_anchors.values.map((k) => '`$k`').join('、')}。');
  md.writeln();
  md.writeln(_rules);
  md.writeln();
  md.writeln('## 7. 术语变更流程');
  md.writeln();
  md.writeln('1. 在 `lib/i18n/en.i18n.yaml` 不动 key 的前提下，用 '
      '`dart run tool/i18n_apply.dart <locale> <tsv>` 改译文；');
  md.writeln('2. 受影响的其它 key 一起改（同名术语要全站一致）；');
  md.writeln('3. 跑 `dart run tool/i18n_check.dart` 与 `dart run tool/i18n_ledger.dart`，'
      '台账与校验结果会同步更新；');
  md.writeln('4. 跑 `dart run tool/i18n_glossary.dart` 重新生成本表——上表会显示新用词。');
  md.writeln();

  File('docs/i18n-glossary.md').writeAsStringSync(md.toString());
  stdout.writeln('已生成 docs/i18n-glossary.md（${_anchors.length} 条术语 × ${ordered.length} 门语言）');
  if (missing.isNotEmpty) {
    stdout.writeln('⚠️ 锚点问题：${missing.join('，')}');
    exit(1);
  }
}
