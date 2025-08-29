import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';

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
  
  // 本地状态
  late bool agreeToRules;

  @override
  void initState() {
    super.initState();
    configService = Get.find<ConfigService>();
    _loadSettings();
  }

  void _loadSettings() {
    agreeToRules = configService[ConfigKey.RULES_AGREEMENT_KEY];
  }

  Future<void> _updateAgreeToRules(bool? value) async {
    final boolValue = value ?? false;
    setState(() {
      agreeToRules = boolValue;
    });
    await configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, boolValue);
  }

  @override
  Widget build(BuildContext context) {
    return StepResponsiveScaffold(
      desktopBuilder: (context, theme) => _buildDesktopLayout(context, theme),
      mobileBuilder: (context, theme, isNarrow) => _buildMobileLayout(context, theme, isNarrow),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subtitle,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              _buildAgreementCard(theme, compact: false),
              const SizedBox(height: 32),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildSuccessIcon(theme, padding: 60, iconSize: 120),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: isNarrow ? 16 : 24,
      children: [
        _buildSuccessIcon(
          theme,
          padding: isNarrow ? 20 : 32,
          iconSize: isNarrow ? 48 : 80,
        ),
        Text(
          widget.subtitle,
          style: (isNarrow ? theme.textTheme.headlineMedium : theme.textTheme.displaySmall)?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        _buildAgreementCard(theme, compact: true, isNarrow: isNarrow),
      ],
    );
  }

  // 私有复用组件
  Widget _buildSuccessIcon(ThemeData theme, {required double padding, required double iconSize}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAgreementCard(
    ThemeData theme, {
    required bool compact,
    bool? isNarrow,
  }) {
    final bool narrow = isNarrow ?? false;
    final double padding = compact ? (narrow ? 16 : 20) : 24;
    final double borderRadius = compact ? (narrow ? 16 : 20) : 20;
    final double iconSize = compact ? (narrow ? 20 : 24) : 28;
    final double titleGap = compact ? (narrow ? 8 : 12) : 16;
    final double afterHeaderGap = compact ? (narrow ? 12 : 16) : 16;

    TextStyle? agreementTextStyle = compact
        ? theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          );

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel,
                color: theme.colorScheme.primary,
                size: iconSize,
              ),
              SizedBox(width: titleGap),
              Text(
                '用户协议和社区规则',
                style: (compact
                        ? (narrow ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)
                        : theme.textTheme.titleMedium)
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: afterHeaderGap),
          Text(
            '在使用本应用前，请您仔细阅读并同意我们的用户协议和社区规则。这些条款有助于维护良好的使用环境。',
            style: agreementTextStyle,
          ),
          SizedBox(height: compact ? (narrow ? 12 : 16) : 20),
          CheckboxListTile(
            title: Text(
              '我已阅读并同意用户协议和社区规则',
              style: compact && narrow ? theme.textTheme.bodySmall : null,
            ),
            subtitle: Text(
              '不同意将无法使用本应用',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: agreeToRules,
            onChanged: _updateAgreeToRules,
            contentPadding: EdgeInsets.zero,
            dense: compact && narrow,
          ),
        ],
      ),
    );
  }
}
