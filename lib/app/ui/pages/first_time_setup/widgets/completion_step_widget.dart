import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isNarrow = screenWidth < 400;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 16 : (isDesktop ? 48 : 24)),
      child: isDesktop 
          ? _buildDesktopLayout(context, theme) 
          : _buildMobileLayout(context, theme, isNarrow),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
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
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '用户协议和社区规则',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '在使用本应用前，请您仔细阅读并同意我们的用户协议和社区规则。这些条款有助于维护良好的使用环境。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('我已阅读并同意用户协议和社区规则'),
                      subtitle: Text(
                        '不同意将无法使用本应用',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: agreeToRules,
                      onChanged: _updateAgreeToRules,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '即将解锁的功能',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• 丰富的视频内容\n• 个性化推荐\n• 社区互动\n• 设置自定义',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.rocket_launch,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(60),
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
              child: const Icon(
                Icons.check_circle,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isNarrow ? 20 : 32),
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
            size: isNarrow ? 48 : 80,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isNarrow ? 20 : 24),
        Text(
          widget.subtitle,
          style: (isNarrow ? theme.textTheme.headlineMedium : theme.textTheme.displaySmall)?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isNarrow ? 16 : 20),
        Container(
          padding: EdgeInsets.all(isNarrow ? 16 : 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
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
                    size: isNarrow ? 20 : 24,
                  ),
                  SizedBox(width: isNarrow ? 8 : 12),
                  Text(
                    '用户协议和社区规则',
                    style: (isNarrow ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: isNarrow ? 12 : 16),
              Text(
                '在使用本应用前，请您仔细阅读并同意我们的用户协议和社区规则。这些条款有助于维护良好的使用环境。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: isNarrow ? 12 : 16),
              CheckboxListTile(
                title: Text(
                  '我已阅读并同意用户协议和社区规则',
                  style: isNarrow ? theme.textTheme.bodySmall : null,
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
                dense: isNarrow,
              ),
            ],
          ),
        ),
        SizedBox(height: isNarrow ? 16 : 20),
        Container(
          padding: EdgeInsets.all(isNarrow ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '即将解锁的功能',
                      style: (isNarrow ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: isNarrow ? 6 : 8),
                    Text(
                      '• 丰富的视频内容\n• 个性化推荐\n• 社区互动\n• 设置自定义',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.rocket_launch,
                size: isNarrow ? 32 : 48,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
