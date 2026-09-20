import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 「小尾巴翻译成我的语言」里的「我的语言」＝**界面语言**。
///
/// ⛔ 不是设置里那个「翻译语言」：后者对所有人默认都是 `zh-CN`，拿它当目标的话，
/// 一个德语用户把开关打开也只会把中文一言「翻译」成中文——开关看着生效、结果
/// 一个字都没变，是最难自查的一种失效。
void main() {
  group('界面语言 → 翻译目标语言', () {
    test('⛔ 简繁必须分家：zh-TW 不能落到 zh-CN 上', () {
      expect(SignatureService.targetLanguageFor('zh-CN'), 'zh-CN');
      expect(SignatureService.targetLanguageFor('zh-TW'), 'zh-TW');
    });

    test('目录里写作 en-US，界面语言却只是 en——按主语言退一档', () {
      expect(SignatureService.targetLanguageFor('en'), 'en-US');
    });

    test('⛔ 应用支持的 12 种语言都得落到目录里，不许有一个退到兜底的英语', () {
      final codes = CommonConstants.translationSorts
          .map((e) => e.extData)
          .toSet();
      for (final locale in AppLocale.values) {
        final target = SignatureService.targetLanguageFor(locale.languageTag);
        expect(codes, contains(target), reason: locale.languageTag);
        if (locale != AppLocale.en) {
          // 兜底值只该给英语用；别的语言落到它就是没匹配上
          expect(target, isNot('en-US'), reason: locale.languageTag);
        }
      }
    });

    test('完全不认识的语言兜底给英语，而不是空串', () {
      expect(SignatureService.targetLanguageFor('xx-YY'), 'en-US');
    });
  });
}
