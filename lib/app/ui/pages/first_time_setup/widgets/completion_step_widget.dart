import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 完成步。
///
/// 目前未注册进向导（见 `SetupStepFactory.buildStepsForPlatform`），
/// 但版式跟着其它步骤一起走，重新启用时不用再对一遍齐。
class CompletionStepWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const CompletionStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  State<CompletionStepWidget> createState() => _CompletionStepWidgetState();
}

class _CompletionStepWidgetState extends State<CompletionStepWidget> {
  late ConfigService configService;

  late bool agreeToRules;

  @override
  void initState() {
    super.initState();
    configService = Get.find<ConfigService>();
    agreeToRules = configService[ConfigKey.RULES_AGREEMENT_KEY];
  }

  Future<void> _updateAgreeToRules(bool value) async {
    setState(() => agreeToRules = value);
    await configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StepPageLayout(
      subtitle: widget.subtitle,
      description: widget.description,
      hero: const _SuccessBadge(),
      content: GlassSettingSection(
        title: slang.t.firstTimeSetup.completion.agreementTitle,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              StepMetrics.cardPadding,
              0,
              StepMetrics.cardPadding,
              StepMetrics.cardPadding,
            ),
            child: Text(
              slang.t.firstTimeSetup.completion.agreementDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          GlassSwitchItem(
            icon: Icons.gavel,
            title: Text(slang.t.firstTimeSetup.completion.checkboxTitle),
            subtitle: Text(slang.t.firstTimeSetup.completion.checkboxSubtitle),
            value: agreeToRules,
            onChanged: _updateAgreeToRules,
          ),
        ],
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double size = stepIsDesktop(context)
        ? 120
        : (stepIsNarrow(context) ? 72 : 96);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, size: size * 0.5, color: cs.onPrimary),
    );
  }
}
