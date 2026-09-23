import 'package:i_iwara/app/utils/signature_recipes.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// AI 一言的「玩法」：一句现成的要求 + 一句示例输出。
///
/// ⭐ 回答的是「能让它干嘛」——变量清单回答不了这个问题，小尾巴案例库那边
/// 已经验证过一次（见 `signature_recipes.dart`）。点一张卡片就把 [instruction]
/// 整句换进「你想让它写什么」，用户再照着改。
///
/// [example] 是**写死的示例**，不是现跑的：打开一张面板就替用户花八次 AI 调用
/// 不像话。卡片上明写「示例」，要看真的就点「试一下」。
class SignatureAiRecipe {
  const SignatureAiRecipe({
    required this.id,
    required this.label,
    required this.instruction,
    required this.example,
    this.needsReplyText = false,
  });

  final String id;
  final String label;

  /// 已经把 `%title%` 翻回 `{title}` 的那句要求。
  final String instruction;
  final String example;

  /// 要先打开「让它读对方的原话」才有意义。没开时卡片照样摆着（让人知道能这么
  /// 玩），只是点不动，并说明要开哪个开关。
  final bool needsReplyText;
}

List<SignatureAiRecipe> signatureAiRecipes(slang.Translations t) {
  final s = t.settings;
  SignatureAiRecipe r(
    String id,
    String label,
    String instruction,
    String example, {
    bool needsReplyText = false,
  }) => SignatureAiRecipe(
    id: id,
    label: label,
    instruction: signatureTemplateFromI18n(instruction),
    example: example,
    needsReplyText: needsReplyText,
  );

  return [
    r(
      'feel',
      s.aiRecipeFeelName,
      s.aiRecipeFeelInstruction,
      s.aiRecipeFeelExample,
    ),
    r(
      'roast',
      s.aiRecipeRoastName,
      s.aiRecipeRoastInstruction,
      s.aiRecipeRoastExample,
    ),
    r(
      'praise',
      s.aiRecipePraiseName,
      s.aiRecipePraiseInstruction,
      s.aiRecipePraiseExample,
    ),
    r(
      'haiku',
      s.aiRecipeHaikuName,
      s.aiRecipeHaikuInstruction,
      s.aiRecipeHaikuExample,
    ),
    r(
      'chuuni',
      s.aiRecipeChuuniName,
      s.aiRecipeChuuniInstruction,
      s.aiRecipeChuuniExample,
    ),
    r(
      'acrostic',
      s.aiRecipeAcrosticName,
      s.aiRecipeAcrosticInstruction,
      s.aiRecipeAcrosticExample,
    ),
    r(
      'greet',
      s.aiRecipeGreetName,
      s.aiRecipeGreetInstruction,
      s.aiRecipeGreetExample,
    ),
    r(
      'echo',
      s.aiRecipeEchoName,
      s.aiRecipeEchoInstruction,
      s.aiRecipeEchoExample,
      needsReplyText: true,
    ),
  ];
}
