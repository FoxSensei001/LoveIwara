/// 小尾巴的现成写法（「案例」）。
///
/// ⛔ 存在的理由是一句用户原话：「你准备的这些变量其实就算是我也不清楚要怎么
/// 用」。一张变量清单回答的是「有哪些零件」，而人卡住的地方是**「这些零件拼起
/// 来是什么样」**——所以编辑器里给的是几条能直接用的整句，点一下就落进输入框，
/// 再照着改。变量面板仍在，那是给已经知道自己要什么的人。
///
/// ⭐ 每条都挂一个 [SignatureRecipe.sceneId]：案例画廊按它挑一份真实上下文，
/// 把这条**渲染出来**给用户看（见 `signature_scenes.dart`）。光有名字的胶囊
/// 解决不了问题——用户要看的是结果，不是标题（2026-09-21 用户第二次点名：
/// 「光靠文字用户很难理解是什么」）。
///
/// ## ⛔ 模板里的变量写成 `%name%`，不是 `{name}`
///
/// 案例的文字是**要翻译的**（小尾巴是用户语言里的一句话），而 i18n 那一侧有两
/// 道机关都会拿花括号做文章：
///
/// - slang 把文案里的 `{title}` 当成**插值参数**，会给这条文案生成一个
///   `String recipeWatching({required Object title})` 的签名；
/// - `tool/i18n_check.dart` 把 `{xxx}` 当占位符逐语言比对，一处写漏就报红。
///
/// 两边都不是能顺手关掉的东西，所以文案里换一种记号，进输入框前在这里翻回去。
library;

import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/utils/signature_scenes.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 案例的分组。⭐ 分的是**场合**不是变量类型：用户找案例时想的是「我在看视频
/// 的时候该写什么」，不是「哪些是上下文变量」。
enum SignatureRecipeGroup { watching, replying, forum, daily, ai }

/// 一条现成写法。
class SignatureRecipe {
  const SignatureRecipe({
    required this.label,
    required this.template,
    required this.group,
    required this.sceneId,
  });

  /// 给人看的名字（「正在看什么」）。
  final String label;

  /// 真正落进输入框的模板，已经是 `{变量}` 写法。
  final String template;

  final SignatureRecipeGroup group;

  /// 该在哪个场景下看它（见 [SignatureScene.videoId] 一族）。画廊用它决定
  /// 拿哪份上下文来渲染这张卡片，卡片上那枚小标签也是它。
  final String sceneId;
}

/// `%name%` → `{name}`。参数照样带得过去（`%pick:a|b%`）。
final RegExp _markerPattern = RegExp(r'%([A-Za-z_][^%]*)%');

String _toTemplate(String text) =>
    text.replaceAllMapped(_markerPattern, (m) => '{${m.group(1)}}');

String signatureRecipeGroupLabel(
  slang.Translations t,
  SignatureRecipeGroup group,
) => switch (group) {
  SignatureRecipeGroup.watching => t.settings.signatureRecipeGroupWatching,
  SignatureRecipeGroup.replying => t.settings.signatureRecipeGroupReplying,
  SignatureRecipeGroup.forum => t.settings.signatureRecipeGroupForum,
  SignatureRecipeGroup.daily => t.settings.signatureRecipeGroupDaily,
  SignatureRecipeGroup.ai => t.settings.signatureRecipeGroupAi,
};

/// 全部案例。
///
/// [aiAvailable] 为 false 时不摆 AI 那条：点了也只会得到一条空小尾巴，
/// 而用户看不出是因为没配供应商。
List<SignatureRecipe> signatureRecipes(
  slang.Translations t, {
  required bool aiAvailable,
}) {
  final s = t.settings;
  return [
    // —— 看视频时。上下文最全的一档，三条分别演标题、进度、作者+标签。
    SignatureRecipe(
      label: s.recipeWatchingName,
      template: _toTemplate(s.recipeWatchingTemplate),
      group: SignatureRecipeGroup.watching,
      sceneId: SignatureScene.videoId,
    ),
    SignatureRecipe(
      label: s.recipeTimestampName,
      template: _toTemplate(s.recipeTimestampTemplate),
      group: SignatureRecipeGroup.watching,
      sceneId: SignatureScene.videoId,
    ),
    SignatureRecipe(
      label: s.recipeAuthorTagsName,
      template: _toTemplate(s.recipeAuthorTagsTemplate),
      group: SignatureRecipeGroup.watching,
      sceneId: SignatureScene.videoId,
    ),

    // —— 回复别人时。
    SignatureRecipe(
      label: s.recipeReplyName,
      template: _toTemplate(s.recipeReplyTemplate),
      group: SignatureRecipeGroup.replying,
      sceneId: SignatureScene.videoId,
    ),
    SignatureRecipe(
      label: s.recipeFloorName,
      template: _toTemplate(s.recipeFloorTemplate),
      group: SignatureRecipeGroup.replying,
      // 楼层只有论坛数得出，所以这条必须在论坛场景下看。
      sceneId: SignatureScene.forumId,
    ),

    // —— 逛论坛时。
    SignatureRecipe(
      label: s.recipeSectionName,
      template: _toTemplate(s.recipeSectionTemplate),
      group: SignatureRecipeGroup.forum,
      sceneId: SignatureScene.forumId,
    ),

    // —— 每天一句。这一组不依赖上下文，所以放在「没有上下文」下面看：
    // 顺带说明了「有些写法到哪儿都成立」。
    SignatureRecipe(
      label: s.recipeHitokotoName,
      template: _toTemplate(s.recipeHitokotoTemplate),
      group: SignatureRecipeGroup.daily,
      sceneId: SignatureScene.noneId,
    ),
    SignatureRecipe(
      label: s.recipeDailyName,
      template: _toTemplate(s.recipeDailyTemplate),
      group: SignatureRecipeGroup.daily,
      sceneId: SignatureScene.noneId,
    ),
    SignatureRecipe(
      label: s.recipeMoodName,
      template: _toTemplate(s.recipeMoodTemplate),
      group: SignatureRecipeGroup.daily,
      sceneId: SignatureScene.noneId,
    ),

    // —— 交给 AI。⭐ 挂在视频场景上是刻意的：AI 一言与接口一言唯一的分野就是
    // 它**知道用户正在看什么**，摆在空场景下看等于把这件事藏起来。
    if (aiAvailable)
      SignatureRecipe(
        label: s.recipeAiName,
        template: _toTemplate(s.recipeAiTemplate),
        group: SignatureRecipeGroup.ai,
        sceneId: SignatureScene.videoId,
      ),
  ];
}

/// 画廊里最常用的那几条（编辑器空着时直接摆出来的）。
List<SignatureRecipe> signatureStarterRecipes(
  slang.Translations t, {
  required bool aiAvailable,
  int count = 3,
}) => signatureRecipes(t, aiAvailable: aiAvailable).take(count).toList();

/// 数据源变量的**示范值**，当 `pinned` 传给 [SignatureService.estimate]。
///
/// ⛔ 没有它的话，一个刚装完的用户在「今日一言」那张卡上看到的是原样的
/// `{hitokoto}`——那正是整件事最需要被演示的地方，却偏偏空着。
///
/// ⭐ 只在**没有真值**时才顶上：这个源真取到过一句，就该显示那一句。
Map<String, String> signatureDemoValues(
  slang.Translations t,
  SignatureService service,
) {
  final out = <String, String>{};
  void fill(String id, String demo) {
    if (service.lastValueOf(id) == null) out[id] = demo;
  }

  fill('hitokoto', t.settings.signatureDemoQuote);
  fill(SignatureProvider.aiHitokoto.id, t.settings.signatureDemoAiQuote);
  return out;
}
