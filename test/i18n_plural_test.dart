// 复数回归：6 个「数量 + 名词」词条要按语言选区形态。
//
// 覆盖两类语言：
//   * de / es / fr / ru：单数与复数**必须不同**（修之前 de 说 “1 Kommentare”、
//     en 说 “1 Comments”，都是错的）；
//   * ja / zh-CN / zh-TW / ko / th / id / vi：名词不随数量变形，形态相同，
//     且**绝不能抛异常**——slang 只内置了 cs/de/en/es/fr/it/ja/pl/ru/sv/uk/vi 的解析器，
//     本仓用到的 zh-CN / zh-TW / ko / th / id 靠
//     `CommonUtils.ensurePluralResolvers()` 注册「永远 other」。
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.instance.loadAllLocales();
    CommonUtils.ensurePluralResolvers();
  });

  Future<void> use(AppLocale locale) => LocaleSettings.setLocale(locale);

  testWidgets('会变形的语言：1 与 5 给出不同且正确的形态', (tester) async {
    await use(AppLocale.en);
    expect(LocaleSettings.currentLocale.translations.favoriteTags.worksCount(n: 1), '1 work');
    expect(LocaleSettings.currentLocale.translations.favoriteTags.worksCount(n: 2), '2 works');

    await use(AppLocale.de);
    final de = LocaleSettings.currentLocale.translations;
    expect(de.common.videoCount(n: 1), '1 Video');
    expect(de.common.videoCount(n: 5), '5 Videos');
    expect(de.common.daysAgo(n: 1), 'vor 1 Tag');
    expect(de.common.daysAgo(n: 3), 'vor 3 Tagen');

    await use(AppLocale.es);
    expect(LocaleSettings.currentLocale.translations.common.totalComments(n: 1),
        '1 comentario');
    expect(LocaleSettings.currentLocale.translations.common.totalComments(n: 2),
        '2 comentarios');

    await use(AppLocale.fr);
    expect(LocaleSettings.currentLocale.translations.common.hoursAgo(n: 1),
        'il y a 1 heure');
    expect(LocaleSettings.currentLocale.translations.common.hoursAgo(n: 3),
        'il y a 3 heures');

    await use(AppLocale.ru);
    final ru = LocaleSettings.currentLocale.translations;
    expect(ru.common.totalComments(n: 1), 'Комментарий: 1');
    expect(ru.common.totalComments(n: 5), 'Комментариев: 5');
  });

  testWidgets('不变形的语言：形态一致、且不抛异常', (tester) async {
    for (final locale in [
      AppLocale.ja,
      AppLocale.zhCn,
      AppLocale.zhTw,
      AppLocale.ko,
      AppLocale.th,
      AppLocale.id,
      AppLocale.vi,
    ]) {
      await use(locale);
      final tr = LocaleSettings.currentLocale.translations;
      final one = tr.common.videoCount(n: 1);
      final many = tr.common.videoCount(n: 5);
      // 数量必须出现在文案里（换形态不能把数字弄丢）
      expect(one.contains('1'), isTrue, reason: '${locale.languageTag} 的 1 丢了');
      expect(many.contains('5'), isTrue, reason: '${locale.languageTag} 的 5 丢了');
      // ⛔ 不能直接比 `one == many`：两边的数量本来就不同。正确的判据是
      // 「把数量换成占位符之后，文案完全一致」——这才是「名词不随数量变形」。
      expect(
        one.replaceFirst('1', '#'),
        many.replaceFirst('5', '#'),
        reason: '${locale.languageTag} 的名词不该随数量变形',
      );
      expect(tr.common.minutesAgo(n: 2).contains('2'), isTrue);
    }
  });
}
