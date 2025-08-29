import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_edit_sheet_widget.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/setting_tiles.dart';

class BasicSettingsStepWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const BasicSettingsStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  State<BasicSettingsStepWidget> createState() => _BasicSettingsStepWidgetState();
}

class _BasicSettingsStepWidgetState extends State<BasicSettingsStepWidget> {
  late ConfigService configService;
  
  // 本地状态
  late bool enableVibration;
  late bool enableHistory;
  late bool disableForumReplyQuote;
  late bool enableSignature;
  late String signatureContent;

  @override
  void initState() {
    super.initState();
    configService = Get.find<ConfigService>();
    _loadSettings();
  }

  void _loadSettings() {
    enableVibration = configService[ConfigKey.ENABLE_VIBRATION];
    enableHistory = configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS];
    disableForumReplyQuote = configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY];
    enableSignature = configService[ConfigKey.ENABLE_SIGNATURE_KEY];
    signatureContent = configService[ConfigKey.SIGNATURE_CONTENT_KEY];
  }

  Future<void> _updateVibration(bool value) async {
    setState(() {
      enableVibration = value;
    });
    await configService.setSetting(ConfigKey.ENABLE_VIBRATION, value);
  }

  Future<void> _updateHistory(bool value) async {
    setState(() {
      enableHistory = value;
    });
    await configService.setSetting(ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS, value);
  }

  Future<void> _updateDisableForumReplyQuote(bool value) async {
    setState(() {
      disableForumReplyQuote = value;
    });
    await configService.setSetting(ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY, value);
  }

  Future<void> _updateEnableSignature(bool value) async {
    setState(() {
      enableSignature = value;
    });
    await configService.setSetting(ConfigKey.ENABLE_SIGNATURE_KEY, value);
  }

  Future<void> _editSignatureContent() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SignatureEditSheet(
        initialContent: signatureContent,
      ),
    );
    if (result != null) {
      setState(() {
        signatureContent = result;
      });
      await configService.setSetting(ConfigKey.SIGNATURE_CONTENT_KEY, result);
    }
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
          child: _buildLeftContent(context, theme),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: _buildSettingsContainer(context, theme, false),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: isNarrow ? 16 : 24,
      children: [
        _buildSubtitle(context, theme, isNarrow),
        _buildSettingsContainer(context, theme, isNarrow),
        _buildTipContainer(context, theme, isNarrow),
      ],
    );
  }

  Widget _buildLeftContent(BuildContext context, ThemeData theme) {
    return Column(
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
        _buildTipContainer(context, theme, false),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme, bool isNarrow) {
    return Text(
      widget.subtitle,
      style: (isNarrow ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context, ThemeData theme, bool isNarrow) {
    return StepSectionCard(
      isNarrow: isNarrow,
      child: Column(
        children: [
          SwitchSettingTile(
            icon: Icons.vibration,
            title: '震动反馈',
            subtitle: '在部分界面的交互里提供触觉反馈',
            value: enableVibration,
            onChanged: _updateVibration,
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.history,
            title: '自动记录历史',
            subtitle: '记录您观看过的视频和图库等历史记录',
            value: enableHistory,
            onChanged: _updateHistory,
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.forum,
            title: '论坛：禁用回复引用',
            subtitle: '回复时不携带被回复楼层信息',
            value: disableForumReplyQuote,
            onChanged: _updateDisableForumReplyQuote,
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.edit_note,
            title: '小尾巴',
            subtitle: '在回复时添加签名',
            value: enableSignature,
            onChanged: _updateEnableSignature,
            isNarrow: isNarrow,
          ),
          if (enableSignature)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 16 : 20,
                vertical: isNarrow ? 8 : 12,
              ),
              child: InkWell(
                onTap: _editSignatureContent,
                borderRadius: BorderRadius.circular(isNarrow ? 8 : 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.short_text,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: isNarrow ? 18 : 20,
                    ),
                    SizedBox(width: isNarrow ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '签名内容',
                            style: (isNarrow ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: isNarrow ? 1 : 2),
                          Text(
                            signatureContent.isEmpty ? '未设置' : signatureContent,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: isNarrow ? 18 : 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipContainer(BuildContext context, ThemeData theme, bool isNarrow) {
    return StepTipBanner(
      icon: Icons.lightbulb,
      text: '这些设置都可以在应用设置中随时修改',
      isNarrow: isNarrow,
    );
  }
}
