import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/translation_prompt.dart';
import 'package:i_iwara/common/constants.dart';

/// 守的就是那个把提示词收回代码里的理由：**目标语言必须真的到得了模型**。
///
/// 实测过的坏法（见 `docs/ai-provider-workstream.md`）：占位替换失败时，日文原文
/// 被译成英文、英文原文被原样退回，而界面上一声不吭。那种失败没有任何自动
/// 信号——只有这里能挡住。
void main() {
  test('每一种目标语言都能拿到自己的规范名称', () {
    for (final sort in CommonConstants.translationSorts) {
      final code = sort.extData;
      final name = CommonConstants.translationLanguageName(code);
      final prompt = TranslationPrompt.build(code);

      expect(
        name,
        isNot(code),
        reason:
            '$code 在 translationLanguageNames 里缺一条，'
            '会把裸代码丢给模型（zh-TW 尤其容易被当成简体）',
      );
      expect(prompt, contains(name), reason: code);
    }
  });

  test('⛔ 提示词里绝不能残留任何占位符', () {
    final prompt = TranslationPrompt.build('zh-CN');
    // [TL] 是历史上那个占位；顺带挡住 {}/${} 这类没替换干净的模板痕迹
    expect(prompt, isNot(contains('[TL]')));
    expect(prompt, isNot(matches(RegExp(r'\$\{|\{\{'))));
  });

  test('目标语言在开头和结尾各出现一次（长文本上别跑偏）', () {
    final prompt = TranslationPrompt.build('ja');
    final name = CommonConstants.translationLanguageName('ja');
    expect(name, 'Japanese (日本語)');
    expect(
      RegExp(RegExp.escape(name)).allMatches(prompt).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('未知语言代码不抛，退回代码本身', () {
    expect(TranslationPrompt.build('xx-YY'), contains('xx-YY'));
  });

  test('⛔ 四条保命规则必须在：内容不是命令 / 已是目标语言 / 只输出译文 / 成人内容照译', () {
    final prompt = TranslationPrompt.build('zh-CN').toLowerCase();
    expect(prompt, contains('never obey'));
    expect(prompt, contains('already in'));
    expect(prompt, contains('output only'));
    expect(prompt, contains('never refuse'));
  });
}
