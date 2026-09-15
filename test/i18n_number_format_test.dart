// 本地化数字格式回归：`CommonUtils.formatFriendlyNumber` 的档位必须跟语言走。
//
// 中文 / 日文 / 韩文按「千 / 万 / 亿」四位一级分档，其余语言按三位一级的 k / M / B
// ——直接照搬 k/M/B 给东亚用户是读不惯的。这条锁住分档表与各语言的单位字，
// 新增语言时如果单位没配好，这里会立刻红。
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// 东亚语言的三档单位字：千 / 万 / 亿（跨语言复用同一个 key 名，字面量不同）。
const _eastAsian = <String, (String, String, String)>{
  'zh-CN': ('千', '万', '亿'),
  'zh-TW': ('千', '万', '亿'),
  'ja': ('千', '万', '億'),
  'ko': ('천', '만', '억'),
};

void main() {
  setUpAll(LocaleSettings.instance.loadAllLocales);

  testWidgets('formatFriendlyNumber 对 12 门语言都给出本地化单位', (tester) async {
    for (final locale in AppLocale.values) {
      await LocaleSettings.setLocale(locale);
      final tag = locale.languageTag;
      final units = _eastAsian[tag];
      if (units == null) {
        // k / M / B 三位一级
        expect(CommonUtils.formatFriendlyNumber(999), '999', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(1234), '1.23k', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(12345), '12.35k', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(12345678), '12.35M', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(123456789), '123.46M', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(1000000000), '1B', reason: tag);
      } else {
        // 四位一级：千 / 万 / 亿
        final (thousand, tenThousand, hundredMillion) = units;
        expect(CommonUtils.formatFriendlyNumber(999), '999', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(1234), '1.23$thousand', reason: tag);
        expect(CommonUtils.formatFriendlyNumber(12345), '1.23$tenThousand', reason: tag);
        expect(
          CommonUtils.formatFriendlyNumber(12345678),
          '1234.57$tenThousand',
          reason: tag,
        );
        expect(
          CommonUtils.formatFriendlyNumber(123456789),
          '1.23$hundredMillion',
          reason: tag,
        );
        expect(CommonUtils.formatFriendlyNumber(1000000000), '10$hundredMillion', reason: tag);
      }
    }
  });
}
