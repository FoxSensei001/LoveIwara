import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/signature_preset.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 变量选择面板。选中一条返回它的模板写法（如 `{date:yyyy-MM-dd}`）。
///
/// 和表情选择器是同一种东西：底栏一枚图标 → 弹一张列表 → 选一个插到光标处。
/// 用户不必先学会花括号语法，也不必在编辑器里对着一排陌生的胶囊猜。
///
/// ⭐ 每条**不写说明文字，直接给样例值**（`{date}` 下面就是今天的日期）。一行
/// 真实的值比一句「插入当前日期」说得清楚，而且不用翻译。
///
/// ⛔ 正文是一张列表，所以顶部 chrome **浮在列表之上**（[GlassFloatingHeaderSheet]，
/// 与评论列表弹层同一套），列表从标题行背后滚过去。原先是「标题行一格、列表
/// 一格」的上下分家写法——那是收口前的老样式。
Future<String?> showSignatureVariablePicker(BuildContext context) {
  return showGlassDraggableBottomSheet<String>(
    context: context,
    builder: (context) => const SignatureVariablePicker(),
  );
}

class SignatureVariablePicker extends StatelessWidget {
  const SignatureVariablePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final service = Get.find<SignatureService>();
    final providers = service.providers;

    return GlassFloatingHeaderSheet(
      title: t.settings.signatureInsertVariable,
      leading: const Icon(Icons.data_object, size: 20),
      bodyBuilder: (context, scrollController, headerExtent, footerExtent) =>
          ListView(
            controller: scrollController,
            // 顶部让位用**实测**的 headerExtent，不写常数：标题行里放了什么
            // （图标 / 动作钮）不该回来改这里。
            padding: EdgeInsets.fromLTRB(8, headerExtent, 8, footerExtent + 16),
            children: [
              _GroupLabel(text: t.settings.signatureVariablesGroup),
              for (final spec in SignatureService.builtinVariables)
                _VariableRow(
                  label: SignatureVariableLabels.of(t, spec.name),
                  token: spec.sample,
                  // 样例值当场算：本地变量算得出真值，算不出就留空。
                  sample: service.estimate(spec.sample, padNetwork: false),
                  onTap: () => Navigator.of(context).pop(spec.sample),
                ),
              _GroupLabel(text: t.settings.signatureSources),
              for (final provider in providers)
                _VariableRow(
                  // 同一个一言可以接两条（一条文学、一条抖机灵），名字一样，
                  // 靠选项摘要区分。
                  label: [
                    SignatureVariableLabels.providerName(t, provider),
                    SignatureVariableLabels.optionSummary(t, provider),
                  ].where((e) => e.isNotEmpty).join(' · '),
                  token: '{${provider.id}}',
                  // 数据源的值要联网才有。这里只把**上一次取到的**拿来当样例，
                  // 打开一张面板就去打一圈别人的接口是不礼貌的。
                  sample: service.lastValueOf(provider.id),
                  fallbackSample: t.settings.signatureNeedsNetwork,
                  onTap: () => Navigator.of(context).pop('{${provider.id}}'),
                ),
            ],
          ),
    );
  }
}

/// 变量名 → 给人看的名字。
///
/// 面板上写的是「日期」而不是 `{date}`，那串花括号只作为副标题出现——用户
/// 先按意思挑，挑完才在输入框里见到语法。
class SignatureVariableLabels {
  const SignatureVariableLabels._();

  /// 数据源显示名。内置源的名字要本地化（用户看到的是「一言」而不是
  /// `Hitokoto`），用户自己接的就用他自己起的名字。
  /// 按 [SignatureProvider.presetId] 认、而不是按 id 认：同一个一言可以接两条
  /// （`hitokoto` 和 `hitokoto_2`），两条都该显示「一言」，不能一条中文一条
  /// 英文品牌名。
  static String providerName(slang.Translations t, SignatureProvider p) =>
      switch (p) {
        _ when p.id == 'hitokoto' || p.presetId == 'hitokoto' =>
          t.settings.signatureSourceHitokoto,
        _ => p.name.isEmpty ? p.id : p.name,
      };

  /// 这条源当前选的那些选项，连成一行（「文学诗词 · 短句」）。没有选项就是空串。
  ///
  /// ⛔ 不把它并进 [providerName] 存盘：选项名要跟着界面语言走，存下来的那份
  /// 会在用户换语言之后变成一句外语。
  static String optionSummary(slang.Translations t, SignatureProvider p) {
    final preset = SignaturePreset.byId(p.presetId);
    if (preset == null) return '';

    final parts = <String>[];
    for (final option in preset.options) {
      final choice = option.choiceFor(p.params);
      // 默认那一条（「不限」）不写出来：它等于什么都没选。
      if (choice.values.isEmpty) continue;
      parts.add(optionLabel(t, choice.labelKey));
    }
    if (p.suffixPath.isNotEmpty) {
      parts.add(t.settings.signatureWizardWithOrigin);
    }
    return parts.join(' · ');
  }

  /// 选项与选项值的文案。key 由 [SignaturePresetOption] 给出，模型层不碰 i18n。
  static String optionLabel(slang.Translations t, String key) => switch (key) {
    'flavor' => t.settings.signatureOptFlavor,
    'flavorAny' => t.settings.signatureOptFlavorAny,
    'flavorOtaku' => t.settings.signatureOptFlavorOtaku,
    'flavorLiterary' => t.settings.signatureOptFlavorLiterary,
    'flavorMeme' => t.settings.signatureOptFlavorMeme,
    'length' => t.settings.signatureOptLength,
    'lengthAny' => t.settings.signatureOptLengthAny,
    'lengthShort' => t.settings.signatureOptLengthShort,
    _ => key,
  };

  static String of(slang.Translations t, String name) => switch (name) {
    'date' => t.settings.varDate,
    'time' => t.settings.varTime,
    'datetime' => t.settings.varDatetime,
    'weekday' => t.settings.varWeekday,
    'app' => t.settings.varApp,
    'version' => t.settings.varVersion,
    'platform' => t.settings.varPlatform,
    'title' => t.settings.varTitle,
    'author' => t.settings.varAuthor,
    'pick' => t.settings.varPick,
    _ => name,
  };
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _VariableRow extends StatelessWidget {
  const _VariableRow({
    required this.label,
    required this.token,
    required this.sample,
    this.fallbackSample,
    required this.onTap,
  });

  final String label;
  final String token;

  /// 当场算出来的样例值，算不出就是空串。
  final String? sample;

  /// 样例值为空时显示的说法（数据源用「需要联网」）。
  final String? fallbackSample;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shown = (sample == null || sample!.trim().isEmpty)
        ? fallbackSample
        : sample!.trim();

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        token,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: cs.primary,
        ),
      ),
      trailing: shown == null
          ? null
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                shown,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
      onTap: onTap,
    );
  }
}
