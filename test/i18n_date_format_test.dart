// 日期本地化回归：`CommonUtils.formatDate` 必须按语言给出各自的习惯写法，
// 而不是 12 门语言都显示 ISO `yyyy-MM-dd`。
//
// 判据表与 `lib/utils/common_utils.dart` 的 `_datePatterns` 一一对应：
// 改那边就要同步改这里，不一致会立刻红。
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// locale -> 期望输出（样例日期：2026-09-05，单数字的月/日能同时验出补零行为）
const _expected = <String, String>{
  'en': '2026-09-05',
  'zh-CN': '2026年9月5日',
  'zh-TW': '2026年9月5日',
  'ja': '2026年9月5日',
  'ko': '2026년 9월 5일',
  'ru': '05.09.2026',
  'de': '05.09.2026',
  'es': '05/09/2026',
  'fr': '05/09/2026',
  'vi': '05/09/2026',
  'id': '05/09/2026',
  'th': '05/09/2026',
};

void main() {
  setUpAll(LocaleSettings.instance.loadAllLocales);

  testWidgets('formatDate 对 12 门语言都给出本地化写法', (tester) async {
    final date = DateTime(2026, 9, 5);
    for (final locale in AppLocale.values) {
      await LocaleSettings.setLocale(locale);
      expect(
        CommonUtils.formatDate(date),
        _expected[locale.languageTag],
        reason: '${locale.languageTag} 的日期写法不对',
      );
    }
  });

  testWidgets('月/日补零：西语与俄语等两位数字格式不留空位', (tester) async {
    final date = DateTime(2026, 1, 2);
    await LocaleSettings.setLocale(AppLocale.ru);
    expect(CommonUtils.formatDate(date), '02.01.2026');
    await LocaleSettings.setLocale(AppLocale.ja);
    expect(CommonUtils.formatDate(date), '2026年1月2日', reason: '中日韩不补零');
    await LocaleSettings.setLocale(AppLocale.en);
    expect(CommonUtils.formatDate(date), '2026-01-02', reason: 'en 保持 ISO 原行为');
  });
}
