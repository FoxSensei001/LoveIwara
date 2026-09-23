import 'dart:convert';

/// AI 一言写多长。每一档给一个中日韩字数与一个其他文字的字符数。
///
/// ⛔ 「长」那一档的上限要落在 `SignatureTemplate.maxVariableLength`（100）以内：
/// 变量值超出它会被静默截成「…」，而截的是 AI 刚写好的那句话的后半截。
enum SignatureAiLength {
  short(cjk: 15, other: 40),
  medium(cjk: 30, other: 70),
  long(cjk: 60, other: 95);

  const SignatureAiLength({required this.cjk, required this.other});

  final int cjk;
  final int other;
}

/// AI 一言用什么语言写。
enum SignatureAiLanguage {
  /// 跟界面语言。
  ui,

  /// 跟用户正在写的那条评论。
  ///
  /// ⭐ 正文**不发给 AI**：本地看一眼它是哪种文字，只把语言名告诉模型
  /// （见 `SignatureAiPrompt.draftLanguageName`）。看不出来（设置页试写时没有
  /// 正文、或者全是表情）就退回界面语言。
  draft,
}

/// AI 一言的全部可调项。
///
/// ⭐ 分两层，分界线与「翻译提示词收回代码」是同一个判断：
/// - **格式**（一行、不带引号、多长、带不带 emoji、什么语言）有硬契约——它要
///   能直接挂进小尾巴里——所以由代码按这里的几个开关**生成**英文系统提示词，
///   用户碰不到措辞，也就删不坏；
/// - **写什么**（[instruction]）是口味，整段归用户，用自己的语言写一两句大白话，
///   里面可以直接写 `{title}` 这类变量。
///
/// ⛔ 早先是一整段可改的英文系统提示词，外加一段**用户看不见**的附加消息
/// （事实表 + 「不许复述、必须能接在任何评论后面」三条规矩）。用户写「吐槽一下
/// 这个标题」会被那三条顶回去，而他不知道那三条存在（2026-09-23 用户点名：
/// 「用户都不知道 AI 能获取到什么信息，可以指挥 AI 干嘛」）。
class SignatureAiSettings {
  const SignatureAiSettings({
    this.instruction = '',
    this.length = SignatureAiLength.medium,
    this.allowEmoji = false,
    this.language = SignatureAiLanguage.ui,
    this.readReplyText = false,
  });

  /// 用户写给 AI 的要求。空串＝用出厂那句（按界面语言现取，见
  /// `SignatureAiPrompt.defaultInstruction`）。
  ///
  /// ⛔ 存空串而不是把默认那句抄进来：抄进去之后换界面语言，他看到的仍是
  /// 另一种语言的「默认」，而且我们改了默认措辞他也永远拿不到。
  final String instruction;

  final SignatureAiLength length;
  final bool allowEmoji;
  final SignatureAiLanguage language;

  /// 回复别人时，把对方那条评论的原话也给 AI 看。
  ///
  /// 默认关：那是**别人**写的字，发给用户自己配的 AI 供应商之前该由他点头。
  final bool readReplyText;

  static const SignatureAiSettings defaults = SignatureAiSettings();

  bool get isDefault =>
      instruction.trim().isEmpty &&
      length == defaults.length &&
      allowEmoji == defaults.allowEmoji &&
      language == defaults.language &&
      readReplyText == defaults.readReplyText;

  SignatureAiSettings copyWith({
    String? instruction,
    SignatureAiLength? length,
    bool? allowEmoji,
    SignatureAiLanguage? language,
    bool? readReplyText,
  }) => SignatureAiSettings(
    instruction: instruction ?? this.instruction,
    length: length ?? this.length,
    allowEmoji: allowEmoji ?? this.allowEmoji,
    language: language ?? this.language,
    readReplyText: readReplyText ?? this.readReplyText,
  );

  Map<String, dynamic> toJson() => {
    if (instruction.trim().isNotEmpty) 'instruction': instruction.trim(),
    'length': length.name,
    'allowEmoji': allowEmoji,
    'language': language.name,
    'readReplyText': readReplyText,
  };

  factory SignatureAiSettings.fromJson(Map<String, dynamic> json) =>
      SignatureAiSettings(
        instruction: (json['instruction'] as String?) ?? '',
        length: SignatureAiLength.values.firstWhere(
          (e) => e.name == json['length'],
          orElse: () => defaults.length,
        ),
        allowEmoji: (json['allowEmoji'] as bool?) ?? defaults.allowEmoji,
        language: SignatureAiLanguage.values.firstWhere(
          (e) => e.name == json['language'],
          orElse: () => defaults.language,
        ),
        readReplyText:
            (json['readReplyText'] as bool?) ?? defaults.readReplyText,
      );

  /// 坏数据当没配过，不让一条写坏的配置把发评论搞崩。
  static SignatureAiSettings? tryDecode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return SignatureAiSettings.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}
