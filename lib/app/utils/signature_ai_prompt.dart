import 'package:i_iwara/app/models/signature_ai_settings.dart';

/// 真正发给模型的两段：系统提示词 + 用户消息。
///
/// 设置页「这次 AI 实际收到的」原样摊的就是这两段——与发送时走同一个
/// `SignatureService.buildAiMessages`，所以用户看到的不是示意，是原文。
class SignatureAiMessages {
  const SignatureAiMessages({required this.system, required this.user});

  final String system;
  final String user;
}

/// AI 一言的提示词。
///
/// ⭐ 两层，见 [SignatureAiSettings] 的类文档：
/// - **系统提示词由代码生成**（[systemPrompt]）：只装格式契约——一行、不带
///   引号、多长、带不带 emoji、什么语言。它要能直接挂进小尾巴，这几条改坏了
///   整条小尾巴就坏了，所以不给用户措辞的入口，只给开关。
/// - **用户消息**（[userMessage]）＝这次看得到的事实 + 用户自己写的要求。
///
/// ⛔ 这里**没有任何用户看不见的规矩**。早先的附加消息里藏着「不许复述、必须能
/// 接在任何评论后面」，与用户写的「吐槽这个标题」正面冲突，而用户不知道它存在。
/// 现在要不要复述、要不要贴着上下文写，全由用户那句话说了算；出厂那句要求里
/// 写着「别复述标题」，是**看得见、删得掉**的。
abstract final class SignatureAiPrompt {
  /// 老版本提示词里代表「界面语言」的占位符。
  ///
  /// 现在语言由格式开关管，这个占位符只为老用户改过的那份提示词保留：它被
  /// 迁成了「写什么」，里头的 `{language}` 照旧换成语言名，不至于原样发给模型。
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

    // 2. 退主语言
    return switch (tag.split('-').first) {
      'zh' => 'Simplified Chinese',
      'en' => 'English',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'de' => 'German',
      'es' => 'Spanish',
      'fr' => 'French',
      'ru' => 'Russian',
      'id' => 'Indonesian',
      'th' => 'Thai',
      'vi' => 'Vietnamese',
      _ => 'English',
    };
  }

  /// 这门语言按「字」数还是按「字符」数给长度。
  static bool _isCjk(String languageName) =>
      languageName.contains('Chinese') ||
      languageName == 'Japanese' ||
      languageName == 'Korean';

  /// 用拉丁字母书写的界面语言。「跟正文」时正文是拉丁字母，就当它和界面
  /// 同一种语言——光凭字母分不出德语和法语，而用户最可能写的就是界面那门。
  static const Set<String> _latinScriptLanguages = {
    'English',
    'German',
    'Spanish',
    'French',
    'Indonesian',
    'Vietnamese',
  };

  /// 看一眼正在写的正文是哪种文字，返回语言名；看不出来返回 null。
  ///
  /// ⭐ 正文本身**不发给 AI**，发的只有这个语言名。
  ///
  /// 只认文字种类，不做语种识别：假名 → 日语（日文里也有汉字，所以假名优先），
  /// 谚文 → 韩语，泰文、西里尔字母各对一门，汉字 → 中文（界面是繁体就繁体），
  /// 拉丁字母 → 界面语言若也是拉丁字母就跟界面，否则英语。
  static String? draftLanguageName(String? draft, String uiLocaleTag) {
    if (draft == null) return null;
    // 链接、表情图片的地址全是拉丁字母，不剥掉的话一条贴了表情的中文评论
    // 会被判成英语。
    final text = draft
        .replaceAll(RegExp(r'!?\[[^\]]*\]\([^)]*\)'), ' ')
        .replaceAll(RegExp(r'https?://\S+'), ' ');

    var kana = 0, hangul = 0, han = 0, thai = 0, cyrillic = 0, latin = 0;
    for (final rune in text.runes) {
      if (rune >= 0x3040 && rune <= 0x30FF) {
        kana++;
      } else if ((rune >= 0xAC00 && rune <= 0xD7AF) ||
          (rune >= 0x1100 && rune <= 0x11FF)) {
        hangul++;
      } else if (rune >= 0x4E00 && rune <= 0x9FFF) {
        han++;
      } else if (rune >= 0x0E00 && rune <= 0x0E7F) {
        thai++;
      } else if (rune >= 0x0400 && rune <= 0x04FF) {
        cyrillic++;
      } else if ((rune >= 0x41 && rune <= 0x5A) ||
          (rune >= 0x61 && rune <= 0x7A) ||
          (rune >= 0xC0 && rune <= 0x24F)) {
        latin++;
      }
    }

    final ui = languageNameOf(uiLocaleTag);
    if (kana > 0) return 'Japanese';
    final counts = {
      'Korean': hangul,
      'Chinese': han,
      'Thai': thai,
      'Russian': cyrillic,
      'Latin': latin,
    };
    final top = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
    if (top.value < 2) return null;
    return switch (top.key) {
      'Chinese' => ui.contains('Chinese') ? ui : 'Simplified Chinese',
      'Latin' => _latinScriptLanguages.contains(ui) ? ui : 'English',
      _ => top.key,
    };
  }

  /// 按格式开关生成的系统提示词。
  static String systemPrompt(SignatureAiSettings settings, String language) {
    final limit = _isCjk(language)
        ? '${settings.length.cjk} characters'
        : '${settings.length.other} characters';
    final emoji = settings.allowEmoji
        ? 'Emoji are fine if they fit naturally.'
        : 'No emoji.';
    return '''You write the signature line that is appended under someone's comment on a video and forum site.

Format — hard requirements:
- Output exactly one line of plain text and nothing else: no quotation marks, no attribution, no explanation, no leading dash, no markdown.
- Write it in $language, whatever language the instruction is written in.
- Keep it under $limit.
- $emoji
- Never mention that you were given context or an instruction.

Everything else — topic, tone, style — follows the user's instruction in the next message. If the instruction conflicts with the format above, keep the format and follow the rest. If it mentions something the context does not have, just leave that part out.''';
  }

  /// 用户消息：这次看得到的事实 + 对方原话（开了才有）+ 用户的要求。
  ///
  /// [instruction] 是**已经代入过变量**的那句（`{title}` 已换成真标题）。
  static String userMessage({
    required Map<String, String> facts,
    required String instruction,
    String? replyText,
  }) {
    final buffer = StringBuffer();
    if (facts.isEmpty) {
      buffer.writeln(
        'Context: none — the user is not looking at anything in particular.',
      );
    } else {
      buffer.writeln('Context — what the user is looking at right now:');
      facts.forEach((key, value) => buffer.writeln('- $key: $value'));
    }
    final reply = replyText?.trim();
    if (reply != null && reply.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('The comment they are replying to:')
        ..writeln('"""')
        ..writeln(reply)
        ..writeln('"""');
    }
    buffer
      ..writeln()
      ..writeln('Instruction:')
      ..write(instruction.trim());
    return buffer.toString();
  }

  /// 对方原话最多给 AI 看多长。一条长评论整段塞进去只会让模型抓不住重点，
  /// 也白白多花 token。
  static const int maxReplyTextLength = 300;
}
