/// AI 一言的系统提示词。
///
/// ⭐ **用户可以改**（设置 → AI 一言 → 提示词）。出厂那份是
/// [defaultTemplate]，用户改过的存在 `SignatureProvider.prompt` 里。
///
/// ⛔ 这和翻译提示词是两回事，别照着那边的结论办：翻译提示词有**硬契约**
/// （输出要能被解析），用户改坏了整个翻译就哑了，所以 2026-09-21 把它收回了
/// 代码里。一言没有契约——它只要一句话，改坏了最多是"这句话不好笑"，而
/// "写得像谁"恰恰是用户唯一真正想调的东西。
///
/// 目标语言不写死：模板里写 `{language}`，求值时才换成当前界面语言的英文名
/// （[render]）。这样用户改了提示词也不会把多语言支持一起改没。
abstract final class SignatureAiPrompt {
  /// 模板里代表"当前界面语言"的占位符。
  ///
  /// 和小尾巴模板同一套花括号语法，用户不必再学第二种写法。
  static const String languagePlaceholder = '{language}';

  /// 界面语言标签 → 写进提示词的语言名。
  ///
  /// ⛔ 必须先精确匹配再退主语言：zh-TW 不许落到 zh-CN。
  static String languageNameOf(String localeTag) {
    final tag = localeTag.replaceAll('_', '-').trim().toLowerCase();

    // 1. 精确匹配
    if (tag == 'zh-cn' || tag == 'zh-hans') return 'Simplified Chinese';
    if (tag == 'zh-tw' || tag == 'zh-hant' || tag == 'zh-hk') {
      return 'Traditional Chinese';
    }
    if (tag == 'en') return 'English';
    if (tag == 'ja') return 'Japanese';
    if (tag == 'ko') return 'Korean';
    if (tag == 'de') return 'German';
    if (tag == 'es') return 'Spanish';
    if (tag == 'fr') return 'French';
    if (tag == 'ru') return 'Russian';
    if (tag == 'id') return 'Indonesian';
    if (tag == 'th') return 'Thai';
    if (tag == 'vi') return 'Vietnamese';

    // 2. 退主语言
    final primary = tag.split('-').first;
    switch (primary) {
      case 'zh':
        return 'Simplified Chinese';
      case 'en':
        return 'English';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'de':
        return 'German';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'ru':
        return 'Russian';
      case 'id':
        return 'Indonesian';
      case 'th':
        return 'Thai';
      case 'vi':
        return 'Vietnamese';
      default:
        return 'English';
    }
  }

  /// 出厂提示词。用户没改过时用的就是这一份。
  ///
  /// ⛔ 写成英文是刻意的，不是没做国际化：提示词是**说给模型听的**，不是界面
  /// 文案。英文指令在各家模型上的服从度最稳，而产出语言由 `{language}` 那一行
  /// 单独管——所以德语用户读到的仍是德语一言。
  static const String defaultTemplate =
      '''You write a single short aphorism to be used as a signature line under an internet comment.

Rules:
- Write it in $languagePlaceholder. This is mandatory, regardless of the language of this instruction.
- Exactly one sentence. Keep it under 30 characters if the language uses CJK characters, otherwise under 80 characters.
- Make it feel human and a little wry or warm — not a motivational poster, not a fortune cookie cliche.
- Output the sentence and nothing else: no quotation marks, no attribution, no emoji, no explanation, no leading dash.''';

  /// 把模板里的 `{language}` 换成当前界面语言，得到真正发给模型的系统提示词。
  ///
  /// 模板留空（用户把输入框清空了）时退回 [defaultTemplate]——发一句默认的话，
  /// 总比发一句没有系统提示词的胡话好。
  static String render(String template, String localeTag) {
    final text = template.trim().isEmpty ? defaultTemplate : template;
    return text.replaceAll(languagePlaceholder, languageNameOf(localeTag));
  }

  /// 出厂提示词按当前界面语言渲染后的样子。
  static String systemPrompt(String localeTag) =>
      render(defaultTemplate, localeTag);

  static const String userPrompt = 'Write one now.';
}
