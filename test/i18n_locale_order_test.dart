// 语言选择器的**显示顺序**回归。
//
// 顺序不是 `AppLocale.values` 的字母序（en, de, es, fr, id, ja, ko, …）——那是按文件名排的，
// 摆给用户看等于随机。约定：英/日/简/繁在最前（用户最多），其余按二次元内容受众规模排。
//
// 这条用例同时锁两件事：
//   1. 顺序与 `CommonUtils.appLocaleDisplayOrder` 一致；
//   2. **每门语言都还在**（顺序表是「重排」不是「过滤」——新增语言忘了登记也只会排最后，
//      不会从选择器里消失）。
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// 期望的完整顺序。
const _expectedOrder = <String>[
  'en',
  'ja',
  'zh-CN',
  'zh-TW',
  'ko',
  'th',
  'id',
  'vi',
  'es',
  'ru',
  'fr',
  'de',
];

void main() {
  test('显示顺序：英/日/简/繁在最前，其余按二次元受众规模', () {
    expect(
      CommonUtils.appLocaleDisplayOrder.map((l) => l.languageTag).toList(),
      _expectedOrder,
    );
  });

  test('显示顺序是「重排」而不是「过滤」：每门语言都在，且不重复', () {
    final ordered = CommonUtils.orderedAppLocales;
    expect(ordered.length, AppLocale.values.length, reason: '有语言被漏掉了');
    expect(ordered.toSet().length, ordered.length, reason: '有语言重复出现');
    expect(ordered.toSet(), AppLocale.values.toSet(), reason: '顺序表里的语言与 AppLocale 不一致');
  });

  test('顺序与当前支持的语言集合吻合（新增语言时来这里补一行）', () {
    // 这一条是给「新增语言」的人看的：先失败，再决定它排在哪。
    expect(CommonUtils.appLocaleDisplayOrder.length, 12);
    expect(
      CommonUtils.appLocaleDisplayOrder.toSet(),
      AppLocale.values.toSet(),
      reason: 'AppLocale 与显示顺序表不同步——请把新语言加进 appLocaleDisplayOrder（随意位置）',
    );
  });
}
