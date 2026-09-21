import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/xr_immersive_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/app_lock_settings_section.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';

class AppSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const AppSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  // 语言列表就地由 slang 生成：新增语言只要往 lib/i18n 丢一份 yaml，这里零改动。
  //
  // 每项显示的是**那门语言自己的母语名**（`简体中文` / `日本語` / `한국어`…），
  // 「跟随系统」也要用**设备语言**说——两者都不能走 `slang.t`，那只给当前语言。
  // 读之前先 `CommonUtils.ensureAllAppLocalesLoaded()`：slang 是按需加载的，
  // 没加载过的语言会静默退回英文（见该方法）。
  Map<String, String> get _languageOptions => {
    'system': _getFollowSystemText(),
    // 顺序走 CommonUtils.appLocaleDisplayOrder（英/日/简/繁优先，其余按二次元受众规模），
    // 不用 AppLocale.values 的字母序；新增语言会由 orderedAppLocales 兜底补在末尾。
    for (final locale in CommonUtils.orderedAppLocales)
      locale.languageTag: locale.translations.settings.languageNativeName,
  };

  // 根据当前设备语言获取"跟随系统"的文本（设备语言没适配时 parse 会退回 en）
  String _getFollowSystemText() {
    final deviceLocale = slang.AppLocaleUtils.parse(
      CommonUtils.getDeviceLocale(),
    );
    return deviceLocale.translations.settings.followSystemLanguage;
  }

  // 弹出输入框设置「历史记录保留天数」
  Future<void> _showAutoDeleteDaysDialog(
    ConfigService configService,
    int currentDays,
  ) async {
    final controller = TextEditingController(text: currentDays.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return GlassAlertDialog(
          title: slang.t.settings.autoDeleteHistoryDays,
          content: GlassInputSurface(
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: glassFieldDecoration(
                dialogContext,
                label: slang.t.settings.autoDeleteHistoryDays,
              ),
            ),
          ),
          actions: [
            GlassDialogAction(
              label: slang.t.common.cancel,
              emphasized: false,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            GlassDialogAction(
              label: slang.t.common.confirm,
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed < 1) {
                  showAppToast(
                    slang.t.settings.autoDeleteHistoryDaysInvalid,
                    type: AppToastType.error,
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(parsed);
              },
            ),
          ],
        );
      },
    );
    if (result != null) {
      configService[ConfigKey.AUTO_DELETE_HISTORY_DAYS] = result;
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    ConfigService configService,
  ) async {
    // 列表要显示每门语言自己的母语名，先确保所有语言的译文都加载好（幂等）。
    await CommonUtils.ensureAllAppLocalesLoaded();

    // 主体是一张列表 → 标题行与底栏都浮在列表之上，列表从它们背后滚过去
    // （全站约定，见 GlassPickerDialog；原先是 GlassAlertDialog 的
    // 「标题一格 / 列表一格 / 动作一格」三截分家）。让位高度由它实测下发，
    // 这里只负责把 headerExtent / footerExtent 当列表的上下内边距用。
    showAppDialog(
      Builder(
        builder: (context) {
          return GlassPickerDialog(
            title: slang.t.settings.language,
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButtonGroup(
                  children: [
                    GlassTextActionButton(
                      label: slang.t.common.cancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            bodyBuilder: (context, headerExtent, footerExtent) => Obx(
              () => RadioGroup<String>(
                groupValue: configService[ConfigKey.APPLICATION_LOCALE],
                onChanged: (String? value) async {
                  if (value != null) {
                    // 更新配置
                    configService.updateApplicationLocale(value);

                    // 立即切换语言
                    if (value == 'system') {
                      slang.LocaleSettings.useDeviceLocale();
                    } else {
                      // 根据语言代码找到对应的 AppLocale
                      slang.AppLocale? targetLocale;
                      for (final locale in slang.AppLocale.values) {
                        if (locale.languageTag.toLowerCase() ==
                            value.toLowerCase()) {
                          targetLocale = locale;
                          break;
                        }
                      }
                      if (targetLocale != null) {
                        slang.LocaleSettings.setLocale(targetLocale);
                      }
                    }

                    // 强制刷新整个应用界面
                    Get.forceAppUpdate();

                    // Quest：空间面板是原生画的，`forceAppUpdate` 管不到它，
                    // 得把新语言推给原生（见 XrImmersiveService.syncLocale）。
                    if (Get.isRegistered<XrImmersiveService>()) {
                      unawaited(Get.find<XrImmersiveService>().syncLocale());
                    }

                    Navigator.of(context).pop();

                    // 提示语用**刚切到的那门语言**说——用户下一眼看到的就是它。
                    // 选「跟随系统」时，那门语言就是设备语言（没适配时 parse 退回 en）。
                    final targetLocale = slang.AppLocaleUtils.parse(
                      value == 'system' ? CommonUtils.getDeviceLocale() : value,
                    );
                    showAppToast(
                      targetLocale.translations.settings.languageChangedMessage,
                      type: AppToastType.success,
                    );
                  }
                },
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    GlassPickerDialog.hPadding,
                    headerExtent,
                    GlassPickerDialog.hPadding,
                    footerExtent,
                  ),
                  children: _languageOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      value: entry.key,
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 添加一个方法来刷新整个页面
  void refreshPage() {
    setState(() {});
  }

  // 导出配置：先询问是否包含敏感信息（API 密钥 / 代理等），默认不包含
  Future<void> _handleExportConfig() async {
    bool includeSensitive = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return GlassAlertDialog(
              title: slang.t.settings.exportConfig,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slang.t.settings.exportConfigDesc),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: includeSensitive,
                    onChanged: (value) {
                      setDialogState(() {
                        includeSensitive = value ?? false;
                      });
                    },
                    title: Text(slang.t.settings.exportIncludeSensitive),
                    subtitle: Text(slang.t.settings.exportIncludeSensitiveDesc),
                  ),
                ],
              ),
              actions: [
                GlassDialogAction(
                  label: slang.t.common.cancel,
                  emphasized: false,
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                GlassDialogAction(
                  label: slang.t.settings.exportConfig,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true) return;
    try {
      await Get.find<ConfigBackupService>().exportConfig(
        includeSensitive: includeSensitive,
      );
    } catch (e) {
      showAppToast(
        '${slang.t.settings.exportConfigFailed}: ${e.toString()}',
        type: AppToastType.error,
      );
    }
  }

  // 导入配置：导入会覆盖现有设置与历史记录，先弹出二次确认
  Future<void> _handleImportConfig() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return GlassAlertDialog(
          title: slang.t.settings.importConfig,
          content: Text(slang.t.settings.importConfigOverwriteWarning),
          actions: [
            GlassDialogAction(
              label: slang.t.common.cancel,
              emphasized: false,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            GlassDialogAction(
              label: slang.t.settings.importConfig,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      final imported = await Get.find<ConfigBackupService>().importConfig();
      if (imported && mounted) {
        await _showImportRestartDialog();
      }
    } catch (e) {
      showAppToast(
        '${slang.t.settings.importConfigFailed}: ${e.toString()}',
        type: AppToastType.error,
      );
    }
  }

  // 导入成功后提示需重启：导入只写入数据库，配置在应用启动时加载到内存，
  // 因此需用户完全关闭并重新打开应用，所有更改才会生效。
  Future<void> _showImportRestartDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return GlassAlertDialog(
          title: slang.t.settings.importConfigRestartTitle,
          content: Text(slang.t.settings.importConfigRestartContent),
          actions: [
            GlassDialogAction(
              label: slang.t.common.confirm,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return GlassSettingsScaffold(
      title: slang.t.settings.appSettings,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        slang.t.settings.history,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => GlassSwitchItem(
                        title: Text(slang.t.settings.autoRecordHistory),
                        subtitle: Text(slang.t.settings.autoRecordHistoryDesc),
                        value: configService[ConfigKey.AUTO_RECORD_HISTORY_KEY],
                        onChanged: (value) {
                          configService[ConfigKey.AUTO_RECORD_HISTORY_KEY] =
                              value;
                          CommonConstants.enableHistory = value;
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(() {
                      final bool enabled =
                          configService[ConfigKey.AUTO_DELETE_HISTORY_ENABLED];
                      final int days =
                          configService[ConfigKey.AUTO_DELETE_HISTORY_DAYS];
                      return Column(
                        children: [
                          GlassSwitchItem(
                            title: Text(slang.t.settings.autoDeleteHistory),
                            subtitle: Text(
                              slang.t.settings.autoDeleteHistoryDesc,
                            ),
                            value: enabled,
                            onChanged: (value) {
                              configService[ConfigKey
                                      .AUTO_DELETE_HISTORY_ENABLED] =
                                  value;
                            },
                          ),
                          if (enabled)
                            ListTile(
                              leading: const Icon(Icons.auto_delete_outlined),
                              title: Text(
                                slang.t.settings.autoDeleteHistoryDays,
                              ),
                              subtitle: Text(
                                slang.t.settings.autoDeleteHistoryDaysValue(
                                  num: days,
                                ),
                              ),
                              trailing: const Icon(Icons.edit),
                              onTap: () => _showAutoDeleteDaysDialog(
                                configService,
                                days,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              // 隐私模式已并入应用锁那张卡（同属「隐私」，且共用后台遮罩）
              const AppLockSettingsSection(),
              if (VibrateUtils.hasVibrator())
                Card(
                  elevation: 2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.interaction,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => GlassSwitchItem(
                          title: Text(slang.t.settings.enableVibration),
                          subtitle: Text(slang.t.settings.enableVibrationDesc),
                          value: configService[ConfigKey.ENABLE_VIBRATION],
                          onChanged: (value) {
                            configService[ConfigKey.ENABLE_VIBRATION] = value;
                            CommonConstants.enableVibration = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        slang.t.settings.language,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => ListTile(
                        title: Text(slang.t.settings.language),
                        subtitle: Text(
                          _languageOptions[configService[ConfigKey
                                  .APPLICATION_LOCALE]] ??
                              '',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () =>
                            _showLanguageDialog(context, configService),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (GetPlatform.isAndroid)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          slang.t.settings.appLinks,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(slang.t.settings.defaultBrowser),
                        subtitle: Text(slang.t.settings.defaultBrowserDesc),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () async {
                          final packageName = CommonConstants.packageName;
                          try {
                            // 首先尝试使用APP_LINKS_SETTINGS
                            final AndroidIntent intent = AndroidIntent(
                              action: 'android.settings.APP_LINKS_SETTINGS',
                              data: 'package:$packageName',
                            );
                            await intent.launch();
                          } catch (e) {
                            // 如果失败，尝试使用APPLICATION_DETAILS_SETTINGS
                            final AndroidIntent intent = AndroidIntent(
                              action:
                                  'android.settings.APPLICATION_DETAILS_SETTINGS',
                              data: 'package:$packageName',
                            );
                            await intent.launch();
                          }
                        },
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        slang.t.settings.markdown,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => GlassSwitchItem(
                        title: Text(
                          slang.t.settings.showUnprocessedMarkdownText,
                        ),
                        subtitle: Text(
                          slang.t.settings.showUnprocessedMarkdownTextDesc,
                        ),
                        value:
                            configService[ConfigKey
                                .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY],
                        onChanged: (value) {
                          configService[ConfigKey
                                  .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY] =
                              value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                clipBehavior: Clip.hardEdge,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        slang.t.settings.exportConfig,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.file_upload),
                      title: Text(slang.t.settings.exportConfig),
                      subtitle: Text(slang.t.settings.exportConfigDesc),
                      onTap: _handleExportConfig,
                    ),
                    ListTile(
                      leading: const Icon(Icons.file_download),
                      title: Text(slang.t.settings.importConfig),
                      subtitle: Text(slang.t.settings.importConfigDesc),
                      onTap: _handleImportConfig,
                    ),
                  ],
                ),
              ),

              SizedBox(height: computeBottomSafeInset(MediaQuery.of(context))),
            ]),
          ),
        ),
      ],
    );
  }
}
