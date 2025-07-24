import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_edit_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/app/services/log_service.dart';
import 'package:flutter/foundation.dart';

class AppSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const AppSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final Map<String, String> _languageOptions = {
    'system': 'Follow system',
    'en': 'English',
    'ja': '日本語',
    'zh-CN': '简体中文',
    'zh-TW': '繁体中文',
  };

  final Map<String, String> _languageChangedMessages = {
    'en': 'You need to restart the app for the language change to take effect.',
    'ja': '言語の変更を反映するにはアプリを再起動してください。',
    'zh-CN': '需重启应用以生效',
    'zh-TW': '需重新啟動應用程式以生效',
  };

  void _showLanguageDialog(BuildContext context, ConfigService configService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(slang.t.settings.language),
          content: SizedBox(
            width: double.minPositive,
            child: Obx(() => ListView(
                  shrinkWrap: true,
                  children: _languageOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: configService[ConfigKey.APPLICATION_LOCALE],
                      onChanged: (String? value) {
                        if (value != null) {
                          configService.updateApplicationLocale(value);
                          Navigator.of(context).pop();
                          
                          String message;
                          String localeKey = value;
                          if (localeKey == 'system') {
                            localeKey = CommonUtils.getDeviceLocale();
                          }
                          
                          message = _languageChangedMessages[localeKey] ?? _languageChangedMessages['en']!;

                          showToastWidget(MDToastWidget(
                              message: message,
                              type: MDToastType.info));
                        }
                      },
                    );
                  }).toList(),
                )),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(slang.t.common.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 添加一个key来强制FutureBuilder重建
  final ValueNotifier<int> _logUpdateTrigger = ValueNotifier<int>(0);
  
  // 添加一个方法来强制刷新日志UI
  void _forceRefreshLogUI() {
    _logUpdateTrigger.value = DateTime.now().millisecondsSinceEpoch;
  }
  
  // 添加一个方法来刷新整个页面
  void refreshPage() {
    setState(() {});
  }
  
  @override
  void dispose() {
    _logUpdateTrigger.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Scaffold(
      appBar: widget.isWideScreen
          ? null
          : AppBar(
              title: Text(slang.t.settings.appSettings,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              elevation: 2,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              iconTheme: IconThemeData(color: Get.isDarkMode ? Colors.white : null),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.autoRecordHistory),
                    subtitle: Text(slang.t.settings.autoRecordHistoryDesc),
                    value: configService[ConfigKey.AUTO_RECORD_HISTORY_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.AUTO_RECORD_HISTORY_KEY] = value;
                      CommonConstants.enableHistory = value;
                    },
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
                    slang.t.settings.privacy,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.activeBackgroundPrivacyMode),
                    subtitle: Text(slang.t.settings.activeBackgroundPrivacyModeDesc),
                    value: configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE],
                    onChanged: (value) {
                      configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE] = value;
                    },
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          title: Text(slang.t.settings.enableVibration),
                          subtitle: Text(slang.t.settings.enableVibrationDesc),
                          value: configService[ConfigKey.ENABLE_VIBRATION],
                          onChanged: (value) {
                            configService[ConfigKey.ENABLE_VIBRATION] = value;
                            CommonConstants.enableVibration = value;
                          },
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => ListTile(
                    title: Text(slang.t.settings.language),
                    subtitle: Text(_languageOptions[
                            configService[ConfigKey.APPLICATION_LOCALE]] ??
                        ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showLanguageDialog(context, configService),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.showUnprocessedMarkdownText),
                    subtitle: Text(slang.t.settings.showUnprocessedMarkdownTextDesc),
                    value: configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY] = value;
                    },
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
                    slang.t.settings.forum,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.disableForumReplyQuote),
                    subtitle: Text(slang.t.settings.disableForumReplyQuoteDesc),
                    value: configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY] = value;
                    },
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
          Card(
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    slang.t.settings.signature, // 需要在翻译文件中添加相应的翻译
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.enableSignature),
                    subtitle: Text(slang.t.settings.enableSignatureDesc),
                    value: configService[ConfigKey.ENABLE_SIGNATURE_KEY],
                    onChanged: (value) {
                      configService[ConfigKey.ENABLE_SIGNATURE_KEY] = value;
                    },
                  ),
                ),
                Obx(
                  () => configService[ConfigKey.ENABLE_SIGNATURE_KEY]
                      ? ListTile(
                          title: Text(slang.t.settings.signatureContent),
                          subtitle: Text(
                            configService[ConfigKey.SIGNATURE_CONTENT_KEY],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => SignatureEditDialog(
                                initialContent: configService[ConfigKey.SIGNATURE_CONTENT_KEY],
                              ),
                            );
                            if (result != null) {
                              configService[ConfigKey.SIGNATURE_CONTENT_KEY] = result;
                            }
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: Text(slang.t.settings.exportConfig),
                  subtitle: Text(slang.t.settings.exportConfigDesc),
                  onTap: () async {
                    try {
                      await Get.find<ConfigBackupService>().exportConfig();
                    } catch (e) {
                      showToastWidget(MDToastWidget(message: '${slang.t.settings.exportConfigFailed}: ${LogUtils.maskSensitiveData(e.toString())}', type: MDToastType.error));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: Text(slang.t.settings.importConfig),
                  subtitle: Text(slang.t.settings.importConfigDesc),
                  onTap: () async {
                    try {
                      await Get.find<ConfigBackupService>().importConfig();
                    } catch (e) {
                      showToastWidget(MDToastWidget(message: '${slang.t.settings.importConfigFailed}: ${LogUtils.maskSensitiveData(e.toString())}', type: MDToastType.error));
                    }
                  },
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        slang.t.log.logManagement,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildLogSizeDetailWidget(context, configService),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.log.enableLogPersistence),
                    subtitle: Text(slang.t.log.enableLogPersistenceDesc),
                    value: configService[ConfigKey.ENABLE_LOG_PERSISTENCE],
                    onChanged: (value) {
                      configService[ConfigKey.ENABLE_LOG_PERSISTENCE] = value;
                      CommonConstants.enableLogPersistence = value;
                    },
                  ),
                ),
                Obx(
                  () => ListTile(
                    title: Text(slang.t.log.logDatabaseSizeLimit),
                    subtitle: Text(slang.t.log.logDatabaseSizeLimitDesc(size: _formatSize(configService[ConfigKey.MAX_LOG_DATABASE_SIZE]))),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showLogSizeLimitDialog(context, configService),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: Text(slang.t.log.exportCurrentLogs), 
                  subtitle: Text(slang.t.log.exportCurrentLogsDesc),
                  onTap: () async {
                    try {
                      await _exportLogs(context);
                      showToastWidget(
                        MDToastWidget(
                          message: slang.t.log.logExportSuccess,
                          type: MDToastType.success,
                        ),
                      );
                    } catch (e) {
                      showToastWidget(
                        MDToastWidget(
                          message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
                          type: MDToastType.error,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(slang.t.log.exportHistoryLogs),
                  subtitle: Text(slang.t.log.exportHistoryLogsDesc),
                  onTap: () async {
                    try {
                      await _exportHistoryLogs(context);
                    } catch (e) {
                      showToastWidget(
                        MDToastWidget(
                          message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
                          type: MDToastType.error,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.merge_type),
                  title: Text(slang.t.log.exportMergedLogs),
                  subtitle: Text(slang.t.log.exportMergedLogsDesc),
                  onTap: () async {
                    try {
                      await _exportMergedLogs(context);
                    } catch (e) {
                      showToastWidget(
                        MDToastWidget(
                          message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
                          type: MDToastType.error,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: Text(slang.t.log.showLogStats),
                  subtitle: Text(slang.t.log.showLogStatsDesc),
                  onTap: () async {
                    try {
                      await _showLogStats(context);
                    } catch (e) {
                      showToastWidget(
                        MDToastWidget(
                          message: slang.t.log.logExtractFailed(error: LogUtils.maskSensitiveData(e.toString())),
                          type: MDToastType.error,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(slang.t.log.clearAllLogs),
                  subtitle: Text(slang.t.log.clearAllLogsDesc),
                  onTap: () async {
                    if (!context.mounted) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(slang.t.log.confirmClearAllLogs),
                        content: Text(slang.t.log.confirmClearAllLogsDesc),
                        actions: [
                          TextButton(
                            child: Text(slang.t.common.cancel),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text(slang.t.common.confirm),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      try {
                        if (Get.isRegistered<LogService>()) {
                          // 清理所有日志
                          await Get.find<LogService>().clearLogs();

                          // 清空缓存并强制刷新
                          setState(() {});
                          
                          showToastWidget(
                            MDToastWidget(
                              message: slang.t.log.clearAllLogsSuccess,
                              type: MDToastType.success,
                            ),
                          );
                        }
                      } catch (e) {
                        showToastWidget(
                          MDToastWidget(
                            message: slang.t.log.clearAllLogsFailed(error: LogUtils.maskSensitiveData(e.toString())),
                            type: MDToastType.error,
                          ),
                        );
                      }
                    }
                  },
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
                    slang.t.settings.listViewMode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text(slang.t.settings.useTraditionalPaginationMode),
                    subtitle: Text(slang.t.settings.useTraditionalPaginationModeDesc),
                    value: configService[ConfigKey.DEFAULT_PAGINATION_MODE],
                    onChanged: (value) {
                      configService[ConfigKey.DEFAULT_PAGINATION_MODE] = value;
                      CommonConstants.isPaginated = value;
                    },
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
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// 构建日志大小详情展示组件
Widget _buildLogSizeDetailWidget(BuildContext context, ConfigService configService) {
  if (!Get.isRegistered<LogService>()) {
    return const SizedBox.shrink();
  }
  
  final state = context.findAncestorStateOfType<_AppSettingsPageState>();
  
  return ValueListenableBuilder<int>(
    valueListenable: state?._logUpdateTrigger ?? ValueNotifier<int>(0),
    builder: (context, _, __) {
      return FutureBuilder<Map<String, dynamic>>(
        future: _getLogInfo(forceRefresh: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          
          final data = snapshot.data;
          if (data == null || snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                slang.t.log.unableToGetLogSizeInfo,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          
          final int size = data['size'] as int;
          final int count = data['count'] as int;
          final int maxSize = configService[ConfigKey.MAX_LOG_DATABASE_SIZE];
          
          // 计算使用率，确保不会超过1.0
          final double rawUsageRatio = size / maxSize;
          final double usageRatio = rawUsageRatio > 1.0 ? 1.0 : rawUsageRatio;
          
          // 确定使用率颜色
          Color usageColor;
          if (rawUsageRatio >= 1.0) {
            usageColor = Colors.red.shade700; // 超出限制
          } else if (rawUsageRatio >= 0.9) {
            usageColor = Colors.red; // 接近限制
          } else if (rawUsageRatio >= 0.7) {
            usageColor = Colors.orange; // 中等使用率
          } else {
            usageColor = Colors.green; // 低使用率
          }
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(slang.t.log.currentLogSize, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      _formatSize(size),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rawUsageRatio >= 1.0 ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(slang.t.log.logCount, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$count ${slang.t.log.logCountUnit}"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(slang.t.log.logSizeLimit, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_formatSize(maxSize)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rawUsageRatio >= 1.0
                          ? "${slang.t.log.usageRate} ${(rawUsageRatio * 100).toStringAsFixed(1)}% (${slang.t.log.exceedLimit})"
                          : "${slang.t.log.usageRate} ${(rawUsageRatio * 100).toStringAsFixed(1)}%", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: usageColor),
                    ),
                    Text(
                      rawUsageRatio >= 1.0
                          ? "${slang.t.log.exceedLimit}: ${_formatSize(size - maxSize)}"
                          : "${slang.t.log.remaining}: ${_formatSize(maxSize - size)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: rawUsageRatio >= 1.0 ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: usageRatio,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                if (rawUsageRatio >= 0.9)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            rawUsageRatio >= 1.0
                                ? slang.t.log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit
                                : slang.t.log.currentLogSizeAlmostExceededPleaseCleanOldLogs,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (rawUsageRatio >= 1.0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton(
                      onPressed: () async {
                        // 显示清理进度
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    slang.t.log.cleaningOldLogs,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        // 执行强制清理
                        bool cleaned = false;
                        try {
                          cleaned = await Get.find<LogService>().forceCheckAndCleanupBySize();
                          
                          // 执行VACUUM操作确保数据库文件收缩
                          await Get.find<LogService>().vacuum();
                        } catch (e) {
                          if (kDebugMode) {
                            print("强制清理日志失败: ${LogUtils.maskSensitiveData(e.toString())}");
                          }
                        }
                        
                        // 关闭进度对话框
                        if (context.mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        
                        // 强制刷新UI
                        if (context.mounted) {
                          // 使用刷新方式
                          final state = context.findAncestorStateOfType<_AppSettingsPageState>();
                          if (state != null) {
                            state._forceRefreshLogUI();
                          }
                          
                          showToastWidget(
                            MDToastWidget(
                              message: cleaned
                                  ? slang.t.log.logCleaningCompleted
                                  : slang.t.log.logCleaningProcessMayNotBeCompleted,
                              type: cleaned ? MDToastType.success : MDToastType.warning,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      child: Text(slang.t.log.cleanExceededLogs),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// 获取日志信息（大小和记录数）
Future<Map<String, dynamic>> _getLogInfo({bool forceRefresh = false}) async {
  try {
    if (Get.isRegistered<LogService>()) {
      // 强制刷新日志缓冲区
      await Get.find<LogService>().flushBufferToDatabase();
      
      // 如果需要强制刷新，先执行VACUUM操作
      if (forceRefresh) {
        try {
          await Get.find<LogService>().vacuum();
        } catch (e) {
          if (kDebugMode) {
            print("执行VACUUM操作失败: $e");
          }
        }
      }
      
      final size = await Get.find<LogService>().getLogDatabaseSize();
      final count = await Get.find<LogService>().getLogCount();
      
      // 不再添加初始记录，直接返回真实数据
      return {
        'size': size,
        'count': count,
      };
    }
    return {
      'size': 0,
      'count': 0,
    };
  } catch (e) {
    if (kDebugMode) {
      print("获取日志信息失败: $e");
    }
    return {
      'size': 0,
      'count': 0,
    };
  }
}

/// 导出日志的方法
Future<void> _exportLogs(BuildContext context) async {
  try {
    // 显示加载指示器
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  
    // 检查是否有日志
    final count = await Get.find<LogService>().getLogCount();
    if (count == 0) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载指示器
        showToastWidget(
          MDToastWidget(
            message: slang.t.log.noLogsToExport,
            type: MDToastType.warning,
          ),
        );
      }
      return;
    }
  
    // 生成导出文件名
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final fileName = "iwara_logs_$formattedDate.txt";
    
    if (GetPlatform.isDesktop) {
      // 桌面平台使用file_selector
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载指示器
        
        final FileSaveLocation? result = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'Text files',
              extensions: ['txt'],
            ),
          ],
        );
        
        if (result != null && context.mounted) {
          // 显示导出进度
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(slang.t.log.exportingLogs, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
          
          await LogUtils.exportLogFileEnhanced(
            targetPath: result.path,
          );
          
          if (context.mounted) {
            Navigator.of(context).pop(); // 关闭进度对话框
            
            showToastWidget(
              MDToastWidget(
                message: slang.t.log.logExportSuccess,
                type: MDToastType.success,
              ),
            );
          }
        }
      }
    } else if (GetPlatform.isMobile) {
      // 移动平台使用flutter_file_dialog
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = path.join(tempDir.path, fileName);
      
      // 将日志复制到临时目录
      await LogUtils.exportLogFileEnhanced(
        targetPath: tempFilePath,
      );
      
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载指示器
        
        // 使用系统分享/保存功能
        final params = SaveFileDialogParams(
          sourceFilePath: tempFilePath,
          fileName: fileName,
        );
        await FlutterFileDialog.saveFile(params: params);
        
        showToastWidget(
          MDToastWidget(
            message: slang.t.log.logExportSuccess,
            type: MDToastType.success,
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop(); // 确保关闭加载指示器
      }
    }
  } catch (e) {
    // 确保关闭可能存在的加载对话框
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    if (context.mounted) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
          type: MDToastType.error,
        ),
      );
    }
  }
}

/// 导出历史日志
Future<void> _exportHistoryLogs(BuildContext context) async {
  try {
    // 显示加载指示器
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 获取可用的日志日期列表
    final dates = await LogUtils.getLogDates();
    
    // 关闭加载指示器
    if (context.mounted) {
      Navigator.of(context).pop();
    
      if (dates.isEmpty) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.log.noHistoryLogsToExport,
            type: MDToastType.warning,
          ),
        );
        return;
      }
      
      // 显示日期选择对话框
      final selectedDate = await showDialog<DateTime>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(slang.t.log.selectLogDate),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isToday = date.year == DateTime.now().year &&
                                date.month == DateTime.now().month &&
                                date.day == DateTime.now().day;
                return ListTile(
                  title: Text(
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" +
                    (isToday ? " (${slang.t.log.today})" : "")
                  ),
                  onTap: () => Navigator.of(context).pop(date),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(slang.t.common.cancel),
            ),
          ],
        ),
      );
      
      if (selectedDate == null) {
        return;
      }
      
      if (!context.mounted) return;
      
      // 格式化选定的日期
      final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      final fileName = "iwara_logs_$formattedDate.txt";
      
      if (GetPlatform.isDesktop && context.mounted) {
        // 桌面平台使用file_selector
        final FileSaveLocation? result = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'Text files',
              extensions: ['txt'],
            ),
          ],
        );
        
        if (result != null && context.mounted) {
          await LogUtils.exportLogFileEnhanced(
            targetPath: result.path,
            specificDate: selectedDate,
          );
          
          showToastWidget(
            MDToastWidget(
              message: slang.t.log.logExportSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else if (GetPlatform.isMobile && context.mounted) {
        // 移动平台使用flutter_file_dialog
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = path.join(tempDir.path, fileName);
        
        // 将日志复制到临时目录
        await LogUtils.exportLogFileEnhanced(
          targetPath: tempFilePath,
          specificDate: selectedDate,
        );
        
        if (context.mounted) {
          // 使用系统分享/保存功能
          final params = SaveFileDialogParams(
            sourceFilePath: tempFilePath,
            fileName: fileName,
          );
          await FlutterFileDialog.saveFile(params: params);
        }
      }
    }
  } catch (e) {
    // 关闭可能存在的加载对话框
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    if (context.mounted) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
          type: MDToastType.error,
        ),
      );
    }
  }
}

/// 导出合并日志
Future<void> _exportMergedLogs(BuildContext context) async {
  try {
    // 先检查是否有日志
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 检查是否有日志
    final dates = await LogUtils.getLogDates();
    
    // 关闭加载对话框
    if (context.mounted) {
      Navigator.of(context).pop();
    
      if (dates.isEmpty) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.log.noLogsToExport,
            type: MDToastType.warning,
          ),
        );
        return;
      }
      
      // 展示选项对话框
      final daysRange = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(slang.t.log.selectMergeRange),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slang.t.log.selectMergeRangeHint),
              const SizedBox(height: 16),
              ...[ 7, 14, 30, 60 ].map((days) => 
                ListTile(
                  title: Text(slang.t.log.selectMergeRangeDays(days: days)),
                  onTap: () => Navigator.of(context).pop(days),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(slang.t.common.cancel),
            ),
          ],
        ),
      );
      
      if (daysRange == null) {
        return;
      }
      
      if (!context.mounted) return;
      
      // 生成导出文件名
      final now = DateTime.now();
      final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final fileName = "iwara_merged_logs_${daysRange}days_$formattedDate.txt";
      
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      try {
        if (GetPlatform.isDesktop && context.mounted) {
          // 桌面平台使用file_selector
          Navigator.of(context).pop(); // 关闭加载对话框
          
          final FileSaveLocation? result = await getSaveLocation(
            suggestedName: fileName,
            acceptedTypeGroups: [
              const XTypeGroup(
                label: 'Text files',
                extensions: ['txt'],
              ),
            ],
          );
          
          if (result != null && context.mounted) {
            // 显示导出进度
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(slang.t.log.exportingLogs, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
            
            await LogUtils.exportLogFileEnhanced(
              targetPath: result.path,
              allLogs: true,
              daysRange: daysRange,
            );
            
            if (context.mounted) {
              Navigator.of(context).pop(); // 关闭进度对话框
              
              showToastWidget(
                MDToastWidget(
                  message: slang.t.log.logExportSuccess,
                  type: MDToastType.success,
                ),
              );
            }
          }
        } else if (GetPlatform.isMobile && context.mounted) {
          // 移动平台使用flutter_file_dialog
          final tempDir = await getTemporaryDirectory();
          final tempFilePath = path.join(tempDir.path, fileName);
          
          // 将合并日志保存到临时目录
          await LogUtils.exportLogFileEnhanced(
            targetPath: tempFilePath,
            allLogs: true,
            daysRange: daysRange,
          );
          
          if (context.mounted) {
            Navigator.of(context).pop(); // 关闭加载对话框
            
            // 使用系统分享/保存功能
            final params = SaveFileDialogParams(
              sourceFilePath: tempFilePath,
              fileName: fileName,
            );
            await FlutterFileDialog.saveFile(params: params);
            
            showToastWidget(
              MDToastWidget(
                message: slang.t.log.logExportSuccess,
                type: MDToastType.success,
              ),
            );
          }
        }
      } catch (e) {
        // 确保关闭加载对话框
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        if (context.mounted) {
          showToastWidget(
            MDToastWidget(
              message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
              type: MDToastType.error,
            ),
          );
        }
      }
    }
  } catch (e) {
    // 确保关闭加载对话框
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    if (context.mounted) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.log.logExportFailed(error: LogUtils.maskSensitiveData(e.toString())),
          type: MDToastType.error,
        ),
      );
    }
  }
}

/// 显示日志统计信息
Future<void> _showLogStats(BuildContext context) {
  if (!Get.isRegistered<LogService>() || !context.mounted) {
    return Future.value();
  }

  return showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<Map<String, int>>(
        future: Get.find<LogService>().getLogStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: Text(slang.t.log.logStats),
              content: Text(slang.t.log.logExtractFailed(error: LogUtils.maskSensitiveData(snapshot.error.toString()))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(slang.t.common.close),
                ),
              ],
            );
          }

          final stats = snapshot.data ?? {'today': 0, 'week': 0, 'total': 0};
          
          return AlertDialog(
            title: Text(slang.t.log.logStats),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slang.t.log.todayLogs(count: stats['today'] ?? 0)),
                const SizedBox(height: 8),
                Text(slang.t.log.recent7DaysLogs(count: stats['week'] ?? 0)),
                const SizedBox(height: 8),
                Text(slang.t.log.totalLogs(count: stats['total'] ?? 0)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(slang.t.common.close),
              ),
            ],
          );
        },
      );
    },
  );
}

/// 格式化文件大小
String _formatSize(int bytes) {
  if (bytes < 1024) {
    return "$bytes B";
  } else if (bytes < 1024 * 1024) {
    return "${(bytes / 1024).toStringAsFixed(1)} KB";
  } else if (bytes < 1024 * 1024 * 1024) {
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  } else {
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }
}

/// 显示日志大小限制对话框
Future<void> _showLogSizeLimitDialog(BuildContext context, ConfigService configService) async {
  // 预设的大小选项（字节）
  final sizeOptions = [
    256 * 1024 * 1024,    // 256MB
    512 * 1024 * 1024,    // 512MB
    1024 * 1024 * 1024,   // 1GB
    2 * 1024 * 1024 * 1024, // 2GB
  ];
  
  // 当前选择的大小
  int currentSize = configService[ConfigKey.MAX_LOG_DATABASE_SIZE];
  
  // 获取当前日志实际大小
  Map<String, dynamic> logInfo = await _getLogInfo();
  int currentLogSize = logInfo['size'] as int;
  
  // 获取App设置页面状态
  if (!context.mounted) return;
  final state = context.findAncestorStateOfType<_AppSettingsPageState>();
  final t = slang.Translations.of(context);
  final text = t.log.currentLogSizeWithSize(size: _formatSize(currentLogSize));
  
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(slang.t.log.setLogDatabaseSizeLimit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...sizeOptions.map((size) => RadioListTile<int>(
              title: Text(_formatSize(size)),
              value: size,
              groupValue: currentSize,
              onChanged: (value) async {
                if (value == null) return;
                
                // 关闭选择对话框
                Navigator.of(context).pop();
                
                // 检查是否需要显示警告
                if (currentLogSize > value) {
                  // 日志大小已经超过了新的限制，需要警告用户
                  // 显示确认对话框
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(slang.t.log.warning),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slang.t.log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          Text(slang.t.log.currentLogSizeWithSize(size: _formatSize(currentLogSize))),
                          Text(slang.t.log.newSizeLimit(size: _formatSize(value))),
                          const SizedBox(height: 12),
                          Text(slang.t.log.logCleaningProcessMayNotBeCompleted),
                          const SizedBox(height: 12),
                          Text(slang.t.log.cleanExceededLogs),
                          const SizedBox(height: 12),
                          Text(slang.t.log.confirmToContinue),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(slang.t.common.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(slang.t.common.confirm),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm != true) return;
                  
                  // 用户确认后，更新配置
                  configService[ConfigKey.MAX_LOG_DATABASE_SIZE] = value;
                  CommonConstants.maxLogDatabaseSize = value;
                  
                  // 执行强制清理
                  try {
                    await Get.find<LogService>().forceCheckAndCleanupBySize();
                    await Get.find<LogService>().vacuum();
                  } catch (e) {
                    if (kDebugMode) {
                      print("强制清理日志失败: ${LogUtils.maskSensitiveData(e.toString())}");
                    }
                  }
                  
                  // 强制刷新UI（使用ValueListenableBuilder机制）
                  if (state != null) {
                    state._forceRefreshLogUI();
                  }
                  
                  // 显示结果
                  if (context.mounted) {
                    showToastWidget(
                      MDToastWidget(
                        message: slang.t.log.logSizeLimitSetSuccess(size: _formatSize(value)),
                        type: MDToastType.success,
                      ),
                    );
                  }
                } else {
                  // 当前日志大小未超过新限制，直接更新配置
                  configService[ConfigKey.MAX_LOG_DATABASE_SIZE] = value;
                  CommonConstants.maxLogDatabaseSize = value;
                  
                  // 强制刷新UI（使用ValueListenableBuilder机制）
                  if (state != null) {
                    state._forceRefreshLogUI();
                  }
                  
                  // 通知用户设置已更改
                  showToastWidget(
                    MDToastWidget(
                      message: slang.t.log.logSizeLimitSetSuccess(size: _formatSize(value)),
                      type: MDToastType.success,
                    ),
                  );
                }
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(slang.t.common.cancel),
        ),
      ],
    ),
  );
}
