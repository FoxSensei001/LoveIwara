import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/update_info.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';

class VersionService extends GetxService {
  final int checkInterval = 24 * 60 * 60 * 1000;
  final ConfigService _configService = Get.find();
  final Dio _dio = Dio();

  final currentVersion = ''.obs;
  final latestVersion = ''.obs;
  final hasUpdate = false.obs;
  final isChecking = false.obs;
  final errorMessage = ''.obs;
  final updateInfo = Rxn<UpdateInfo>();

  final isForceUpdate = false.obs;
  final needMinVersionUpdate = false.obs;

  Future<VersionService> init() async {
    // 从 pubspec.yaml 读取当前版本
    currentVersion.value = CommonConstants.VERSION;
    return this;
  }

  /// 自动检查更新
  void doAutoCheckUpdate() async {
    if (_configService[ConfigService.AUTO_CHECK_UPDATE]) {
      final lastCheckTime =
          _configService[ConfigService.LAST_CHECK_UPDATE_TIME];
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCheckTime > checkInterval) {
        checkUpdate(showDialog: true);
      }
    }
  }

  /// 检查更新
  Future<void> checkUpdate({bool showDialog = false}) async {
    try {
      isChecking.value = true;
      errorMessage.value = '';

      final response = await _dio.get(
        _configService[ConfigService.REMOTE_REPO_UPDATE_LOGS_YAML_URL],
      );

      if (response.statusCode == 200) {
        final yaml = loadYaml(response.data);
        final remoteVersion = yaml['currentVersion']?.toString().split('+')[0];

        LogUtils.d('远程版本: $remoteVersion', 'VersionService');

        if (remoteVersion != null) {
          latestVersion.value = remoteVersion;
          hasUpdate.value = _compareVersions(
            currentVersion.value,
            latestVersion.value,
          );

          await _fetchUpdateInfo(remoteVersion);

          if (hasUpdate.value) {
            if (updateInfo.value != null) {
              isForceUpdate.value = updateInfo.value!.forceUpdate;
              if (showDialog) {
                CommonConstants.isForceUpdate = isForceUpdate.value;
              }
              needMinVersionUpdate.value = _compareVersions(
                currentVersion.value,
                updateInfo.value!.minVersion,
              );
            }

            if (showDialog &&
                latestVersion.value !=
                    _configService[ConfigService.IGNORED_VERSION]) {
              _showUpdateDialog();
            }
          }
        }
      }

      _configService[ConfigService.LAST_CHECK_UPDATE_TIME] =
          DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      LogUtils.e('检查更新失败', error: e, tag: 'VersionService');
      errorMessage.value = t.settings.checkForUpdatesFailed;
      hasUpdate.value = false;
    } finally {
      isChecking.value = false;
    }
  }

  /// 获取更新日志
  Future<void> _fetchUpdateInfo(String version) async {
    try {
      final response = await _dio.get(
        _configService[ConfigService.REMOTE_REPO_UPDATE_LOGS_YAML_URL],
      );

      if (response.statusCode == 200) {
        final yaml = loadYaml(response.data);
        final updates = yaml['updates'] as YamlList;

        for (var update in updates) {
          if (update['version'] == version) {
            updateInfo.value = UpdateInfo.fromYaml(update);
            break;
          }
        }
      }
    } catch (e) {
      LogUtils.e('获取更新日志失败', error: e, tag: 'VersionService');
    }
  }

  /// 显示更新对话框
  void _showUpdateDialog() {
    final update = updateInfo.value;
    if (update == null) {
      LogUtils.e('更新信息为空', tag: 'VersionService');
      return;
    }

    String currentLocale = CommonUtils.getDeviceLocale();
    final changes = update.getLocalizedChanges(currentLocale);

    Get.dialog(
      PopScope(
        canPop: !isForceUpdate.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            AppService.tryPop();
          }
        },
        child: AlertDialog(
          title: Text('${t.settings.newVersionAvailable}: ${latestVersion.value}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.settings.latestVersion}: ${latestVersion.value}'),
              const SizedBox(height: 8),
              Text('${t.settings.releaseDate}: ${update.date}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(t.settings.updateContent),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.translate),
                    onPressed: () {
                      Get.dialog(
                        TranslationDialog(
                          text: changes.join('\n\n'),
                        ),
                        barrierDismissible: true,
                      );
                    },
                  ),
                ],
              ),
              ...changes.map((change) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(change),
              )),
              if (needMinVersionUpdate.value)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    t.settings.minVersionUpdateRequired,
                    style: TextStyle(color: Get.theme.colorScheme.error),
                  ),
                ),
            ],
          ),
          actions: [
            if (!isForceUpdate.value) ...[
              TextButton(
                onPressed: () {
                  _configService[ConfigService.IGNORED_VERSION] =
                      latestVersion.value;
                  AppService.tryPop();
                },
                child: Text(t.settings.ignoreThisVersion),
              ),
              TextButton(
                onPressed: () => AppService.tryPop(),
                child: Text(t.common.cancel),
              ),
            ],
            ElevatedButton(
              onPressed: () => _openReleaseUrl(),
              child: Text(t.settings.update),
            ),
          ],
        ),
      ),
      barrierDismissible: !isForceUpdate.value,
    );
  }

  bool _compareVersions(String current, String latest) {
    List<int> currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts =
        latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int currentPart = i < currentParts.length ? currentParts[i] : 0;
      int latestPart = i < latestParts.length ? latestParts[i] : 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }

    return false;
  }

  Future<void> _openReleaseUrl() async {
    final url =
        Uri.parse(_configService[ConfigService.REMOTE_REPO_RELEASE_URL]);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      LogUtils.e('无法打开更新链接', tag: 'VersionService');
    }
  }
}
