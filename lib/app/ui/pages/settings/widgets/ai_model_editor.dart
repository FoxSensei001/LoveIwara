import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 改一条模型的**覆盖项**。
///
/// ⭐ 这张表里每一栏的默认状态都是「跟随」——空输入框、关着的开关，都不是
/// 「设成了空 / 设成了关」，而是「这一项我没管，按模型能力和目录来」。所以
/// 每栏的提示文案要说清**跟随下来的是什么**，否则用户看到一个空框只会去填满它。
Future<AiModel?> showAiModelEditor(
  BuildContext context, {
  required AiModel model,
  required String providerKind,
}) {
  return showGlassDraggableBottomSheet<AiModel>(
    context: context,
    builder: (context) =>
        _AiModelEditorSheet(model: model, providerKind: providerKind),
  );
}

class _AiModelEditorSheet extends StatefulWidget {
  const _AiModelEditorSheet({required this.model, required this.providerKind});

  final AiModel model;
  final String providerKind;

  @override
  State<_AiModelEditorSheet> createState() => _AiModelEditorSheetState();
}

class _AiModelEditorSheetState extends State<_AiModelEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _maxTokensController;

  /// 用户对「要不要开推理」的表态。null ＝ 跟随模型能力。
  late bool? _reasoning;
  late bool? _sendTemperature;

  AiCatalogModel? get _catalog =>
      AiCatalogService.modelOf(widget.model.modelId);

  @override
  void initState() {
    super.initState();
    final m = widget.model;
    _nameController = TextEditingController(text: m.name ?? '');
    _temperatureController = TextEditingController(
      text: m.temperature?.toString() ?? '',
    );
    // ⛔ 0 显示成**空输入框**：印一个 `0` 出来会被读成「上限是零」，意思正相反。
    // 而 null（跟随）同样是空框——两者在 UI 上不必分开，提交时按「有没有动过」
    // 判：见 _result。
    _maxTokensController = TextEditingController(
      text: (m.maxTokens ?? 0) > 0 ? m.maxTokens.toString() : '',
    );
    _reasoning = m.reasoning;
    _sendTemperature = m.sendTemperature;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  AiModel _result() {
    final name = _nameController.text.trim();
    final temperature = double.tryParse(_temperatureController.text.trim());
    final parsedTokens = int.tryParse(_maxTokensController.text.trim());
    return AiModel(
      providerId: widget.model.providerId,
      modelId: widget.model.modelId,
      name: name.isEmpty ? null : name,
      temperature: temperature,
      sendTemperature: _sendTemperature,
      // 空框 ＝ 跟随（null）；填了正数 ＝ 那个数；填了 0 或负数 ＝ 明确的
      // 「不发这个参数」（0）。
      maxTokens: _maxTokensController.text.trim().isEmpty
          ? null
          : ((parsedTokens ?? 0) > 0 ? parsedTokens : 0),
      reasoning: _reasoning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final catalog = _catalog;
    final canThink = AiProviderKind.supportsThinking(widget.providerKind);
    final canTemp = AiProviderKind.supportsTemperature(widget.providerKind);
    final catalogReasoning = catalog?.has(AiModelCapability.reasoning) ?? false;

    final title = widget.model.modelId.isEmpty
        ? t.ai.serverDefaultModel
        : widget.model.modelId;

    return GlassFloatingHeaderSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      title: title,
      leading: const Icon(Icons.tune, size: 20),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GlassButtonGroup(
            children: [
              GlassTextActionButton(
                label: t.common.confirm,
                emphasized: true,
                onPressed: () => Navigator.of(context).pop(_result()),
              ),
            ],
          ),
        ],
      ),
      bodyBuilder: (context, scrollController, headerExtent, footerExtent) =>
          ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              16,
              headerExtent,
              16,
              footerExtent + 16,
            ),
            children: [
              Text(
                t.ai.modelOverrideHint,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _label(cs, t.ai.providerNameLabel),
              GlassInputSurface(
                child: TextField(
                  controller: _nameController,
                  decoration: glassFieldDecoration(
                    context,
                    hint: catalog?.name ?? widget.model.modelId,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GlassSettingSection(
                children: [
                  if (canThink)
                    GlassSwitchItem(
                      title: Text(t.ai.reasoning),
                      subtitle: Text(
                        _reasoning == null
                            ? t.ai.followCatalog(
                                value: catalogReasoning
                                    ? t.ai.triOn
                                    : t.ai.triOff,
                              )
                            : t.ai.userOverride,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      value: _reasoning ?? catalogReasoning,
                      onChanged: (v) => setState(() => _reasoning = v),
                    ),
                  if (canThink && _reasoning != null)
                    GlassSettingTile(
                      icon: Icons.settings_backup_restore,
                      title: Text(t.ai.resetToDefault),
                      onTap: () => setState(() => _reasoning = null),
                    ),
                  if (canTemp)
                    GlassSwitchItem(
                      title: Text(t.ai.sendTemperature),
                      subtitle: Text(
                        t.ai.sendTemperatureHint,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      value: _sendTemperature ?? true,
                      onChanged: (v) =>
                          setState(() => _sendTemperature = v ? null : false),
                    ),
                ],
              ),
              if (canTemp && (_sendTemperature ?? true)) ...[
                const SizedBox(height: 14),
                _label(cs, t.ai.temperature),
                GlassInputSurface(
                  child: TextField(
                    controller: _temperatureController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: glassFieldDecoration(
                      context,
                      hint: AiDefaults.temperature.toString(),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _label(cs, t.ai.maxTokens),
              GlassInputSurface(
                child: TextField(
                  controller: _maxTokensController,
                  keyboardType: TextInputType.number,
                  decoration: glassFieldDecoration(
                    context,
                    hint: catalog?.maxOutputTokens != null
                        ? t.ai.maxTokensFromCatalog(
                            tokens: catalog!.maxOutputTokens!,
                          )
                        : t.ai.maxTokensAuto,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.ai.maxTokensHint,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
    );
  }

  Widget _label(ColorScheme cs, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
      ),
    ),
  );
}
