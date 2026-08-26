import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_edit_sheet_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
  State<BasicSettingsStepWidget> createState() =>
      _BasicSettingsStepWidgetState();
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
    disableForumReplyQuote =
        configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY];
    enableSignature = configService[ConfigKey.ENABLE_SIGNATURE_KEY];
    signatureContent = configService[ConfigKey.SIGNATURE_CONTENT_KEY];
  }

  Future<void> _updateVibration(bool value) async {
    setState(() => enableVibration = value);
    await configService.setSetting(ConfigKey.ENABLE_VIBRATION, value);
  }

  Future<void> _updateHistory(bool value) async {
    setState(() => enableHistory = value);
    await configService.setSetting(
      ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS,
      value,
    );
  }

  Future<void> _updateDisableForumReplyQuote(bool value) async {
    setState(() => disableForumReplyQuote = value);
    await configService.setSetting(
      ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY,
      value,
    );
  }

  Future<void> _updateEnableSignature(bool value) async {
    setState(() => enableSignature = value);
    await configService.setSetting(ConfigKey.ENABLE_SIGNATURE_KEY, value);
  }

  Future<void> _editSignatureContent() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          SignatureEditSheet(initialContent: signatureContent),
    );
    if (result != null) {
      setState(() => signatureContent = result);
      await configService.setSetting(ConfigKey.SIGNATURE_CONTENT_KEY, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepPageLayout(
      subtitle: widget.subtitle,
      description: widget.description,
      content: GlassSettingSection(
        children: [
          GlassSwitchItem(
            icon: Icons.vibration,
            title: Text(slang.t.settings.enableVibration),
            subtitle: Text(slang.t.settings.enableVibrationDesc),
            value: enableVibration,
            onChanged: _updateVibration,
          ),
          GlassSwitchItem(
            icon: Icons.history,
            title: Text(slang.t.settings.autoRecordHistory),
            subtitle: Text(slang.t.settings.autoRecordHistoryDesc),
            value: enableHistory,
            onChanged: _updateHistory,
          ),
          GlassSwitchItem(
            icon: Icons.forum,
            title: Text(slang.t.settings.disableForumReplyQuote),
            subtitle: Text(slang.t.settings.disableForumReplyQuoteDesc),
            value: disableForumReplyQuote,
            onChanged: _updateDisableForumReplyQuote,
          ),
          GlassSwitchItem(
            icon: Icons.edit_note,
            title: Text(slang.t.settings.signature),
            subtitle: Text(slang.t.settings.enableSignatureDesc),
            value: enableSignature,
            onChanged: _updateEnableSignature,
          ),
          // 签名内容跟着开关显隐：它是上一行的下级，用同一套设置行渲染，
          // 缩进、行高、分隔线都与其它行一致。
          if (enableSignature)
            StepActionTile(
              icon: Icons.short_text,
              title: slang.t.settings.signatureContent,
              value: signatureContent.isEmpty
                  ? slang.t.common.noData
                  : signatureContent,
              valueHighlighted: signatureContent.isNotEmpty,
              onTap: _editSignatureContent,
            ),
        ],
      ),
      tip: StepTipBanner.info(
        slang.t.firstTimeSetup.common.settingsChangeableTip,
      ),
    );
  }
}
