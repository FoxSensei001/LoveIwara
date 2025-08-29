import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/proxy_config_widget.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';

class NetworkSettingsStepWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const NetworkSettingsStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  State<NetworkSettingsStepWidget> createState() =>
      _NetworkSettingsStepWidgetState();
}

class _NetworkSettingsStepWidgetState extends State<NetworkSettingsStepWidget> {
  final ConfigService configService = Get.find();

  static const String _networkTipText = '需设置成功后重启应用才能生效';

  Widget _buildNetworkTip(ThemeData theme, {required bool isNarrow}) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi,
            color: theme.colorScheme.onSecondaryContainer,
            size: isNarrow ? 16 : 20,
          ),
          SizedBox(width: isNarrow ? 8 : 12),
          Expanded(
            child: Text(
              _networkTipText,
              style:
                  (isNarrow
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProxyConfigContainer(
    ThemeData theme, {
    required EdgeInsetsGeometry padding,
    required double borderRadius,
    required bool wrapWithCard,
  }) {
    return StepSectionCard(
      isNarrow: borderRadius <= 16,
      child: ProxyConfigWidget(
        configService: configService,
        showTitle: false,
        padding: padding,
        compactMode: true,
        wrapWithCard: wrapWithCard,
      ),
    );
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subtitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildNetworkTip(theme, isNarrow: false),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildProxyConfigContainer(
                theme,
                padding: const EdgeInsets.all(24),
                borderRadius: 20,
                wrapWithCard: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    bool isNarrow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: isNarrow ? 16 : 24,
      children: [
        Text(
          widget.subtitle,
          style:
              (isNarrow
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.headlineSmall)
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
        ),
        _buildProxyConfigContainer(
          theme,
          padding: EdgeInsets.all(isNarrow ? 16 : 20),
          borderRadius: isNarrow ? 16 : 20,
          wrapWithCard: true,
        ),
        _buildNetworkTip(theme, isNarrow: isNarrow),
      ],
    );
  }
}
