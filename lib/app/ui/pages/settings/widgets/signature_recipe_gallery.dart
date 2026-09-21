import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/widgets/comment_structure_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/utils/signature_recipes.dart';
import 'package:i_iwara/app/utils/signature_scenes.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 案例画廊：把每条现成写法**渲染出来**摆着，点一条就用。
///
/// ⛔ 上一版是六枚只有名字的文字胶囊（「正在看什么」），点下去才知道长什么样
/// ——而点下去看到的还是 `我在看《{title}》`，因为设置页没有上下文。整条链上
/// 用户一次都没见过真实结果（2026-09-21 用户第二次点名：「光靠文字用户很难
/// 理解是什么」）。
///
/// 这里每张卡片都拿**用户自己最近看过的那条**当上下文渲染（见
/// `signature_scenes.dart`），输入与输出上下并排：
///
/// ```
/// 正在看什么                        [在视频页]
/// ── 正在看《月光下的旋转》 · 2026-09-21
/// 正在看《{title}》 · {date}
/// ```
Future<String?> showSignatureRecipeGallery(BuildContext context) {
  return showGlassDraggableBottomSheet<String>(
    context: context,
    builder: (context) => const _SignatureRecipeGallery(),
  );
}

class _SignatureRecipeGallery extends StatefulWidget {
  const _SignatureRecipeGallery();

  @override
  State<_SignatureRecipeGallery> createState() =>
      _SignatureRecipeGalleryState();
}

class _SignatureRecipeGalleryState extends State<_SignatureRecipeGallery> {
  SignatureSceneSet? _scenes;

  @override
  void initState() {
    super.initState();
    loadSignatureScenes(slang.t).then((value) {
      if (mounted) setState(() => _scenes = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final service = Get.find<SignatureService>();
    final recipes = signatureRecipes(t, aiAvailable: service.aiAvailable);
    final scenes = _scenes;

    // 按组摊开，组内保持定义顺序。
    final groups = <SignatureRecipeGroup, List<SignatureRecipe>>{};
    for (final recipe in recipes) {
      groups.putIfAbsent(recipe.group, () => []).add(recipe);
    }

    return GlassFloatingHeaderSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      title: t.settings.signatureRecipesTitle,
      leading: const Icon(Icons.auto_stories_outlined, size: 20),
      bodyBuilder: (context, scrollController, headerExtent, footerExtent) =>
          ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              12,
              headerExtent,
              12,
              footerExtent + 16,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Text(
                  // 卡片上那句是真的还是顶着的，说法不一样——把「这是你最近看的
                  // 那条」说成示范数据会让人以为应用在编，反过来更糟。
                  scenes == null || scenes.fromHistory
                      ? t.settings.signatureSceneFromHistory
                      : t.settings.signatureSceneFromDemo,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(
                    signatureRecipeGroupLabel(t, entry.key),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final recipe in entry.value)
                  SignatureRecipeCard(
                    recipe: recipe,
                    scenes: scenes,
                    onTap: () => Navigator.of(context).pop(recipe.template),
                  ),
              ],
            ],
          ),
    );
  }
}

/// 一张案例卡片：结果在上、模板在下。
///
/// [compact] 是编辑器空状态用的窄版：省掉模板那一行和场景标签。那儿的目的是
/// 「给个起点」，不是教语法——语法在画廊里教。
class SignatureRecipeCard extends StatelessWidget {
  const SignatureRecipeCard({
    super.key,
    required this.recipe,
    required this.scenes,
    required this.onTap,
    this.compact = false,
  });

  final SignatureRecipe recipe;

  /// 还没加载完就是 null，这时按「没有上下文」渲染（变量整段消失），
  /// 而不是留一屏空白或者骨架——一条小尾巴本来就可能长这样。
  final SignatureSceneSet? scenes;

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final service = Get.find<SignatureService>();
    final scene = scenes?.byId(recipe.sceneId);

    final rendered = service.estimate(
      recipe.template,
      context: scene?.context ?? SignatureContext.empty,
      fill: SignatureFill.sample,
      // ⭐ 场景给的就是最终上下文：填不出的那一段该当场消失，而不是留着花括号。
      contextComplete: true,
      pinned: signatureDemoValues(t, service),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!compact && scene != null) ...[
                      const SizedBox(width: 8),
                      _SceneTag(label: scene.label, icon: scene.icon),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                // ⭐ 走 CommentStructurePreview 而不是自己画一行字：评论区里那条
                // 小尾巴是 11px、alpha 0.6、前缀一小截横线的脚注，案例里看到的
                // 必须就是别人看到的那个样子。不给 body——这张卡片要讲的是小尾巴
                // 本身，配一段假正文只会让十张卡片重复十遍同一句话。
                CommentStructurePreview(body: '', signature: rendered),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  Text(
                    recipe.template,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      fontFamily: 'monospace',
                      color: cs.primary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneTag extends StatelessWidget {
  const _SceneTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}
