import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';

class AboutPage extends StatefulWidget {
  final bool isWideScreen;

  const AboutPage({super.key, this.isWideScreen = false});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final VersionService _versionService = Get.find();
  final ConfigService _configService = Get.find();

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    await _versionService.checkUpdate();
  }

  Future<void> _openReleaseUrl() async {
    final url = Uri.parse(_configService[ConfigService.REMOTE_REPO_RELEASE_URL]);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationVersion: _versionService.currentVersion.value,
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          CommonConstants.launcherIconPath,
          width: 48,
          height: 48,
        ),
      ),
    );
  }

  void _showUpdateChangesDialog(List<String> changes) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '${t.settings.updateContent}: ${_versionService.latestVersion.value}',
                      style: theme.textTheme.titleMedium,
                    ),
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 更新内容
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...changes.map((change) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            change,
                            style: theme.textTheme.bodyMedium,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                CommonConstants.launcherIconPath,
                width: 80,
                height: 80,
              )
            ),
            const SizedBox(height: 16),
            Text(
              'i-iwara',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              '${t.settings.currentVersion} ${_versionService.currentVersion.value}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateSection() {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (_versionService.isChecking.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_versionService.errorMessage.value.isNotEmpty) {
            return Column(
              children: [
                Text(
                  _versionService.errorMessage.value,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _checkUpdate,
                  icon: const Icon(Icons.refresh),
                  label: Text(t.common.retry),
                ),
              ],
            );
          }

          if (_versionService.hasUpdate.value) {
            final updateInfo = _versionService.updateInfo.value;
            String currentLocale = CommonUtils.getDeviceLocale();
            final changes = updateInfo?.getLocalizedChanges(currentLocale) ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.system_update,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    '${t.settings.newVersionAvailable}: ${_versionService.latestVersion.value}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: updateInfo != null ? Text(
                    '${t.settings.releaseDate} ${updateInfo.date}',
                  ) : null,
                ),
                if (changes.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateChangesDialog(changes),
                      icon: const Icon(Icons.list_alt),
                      label: Text(t.settings.viewChangelog),
                    ),
                  ),
                ],
                if (updateInfo?.forceUpdate == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    t.settings.forceUpdateTip,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openReleaseUrl,
                    icon: const Icon(Icons.system_update),
                    label: Text(t.settings.update),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          } else if (_versionService.latestVersion.value.isNotEmpty) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
              title: Text(t.settings.alreadyLatestVersion),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _checkUpdate,
              ),
            );
          }

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.update),
            title: Text(t.settings.checkForUpdates),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkUpdate,
          );
        }),
      ),
    );
  }

  Widget _buildLinksSection() {
    final t = slang.Translations.of(context);
    
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(t.settings.projectHome),
            subtitle: const Text('GitHub'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchUrl(
              Uri.parse(_configService[ConfigService.REMOTE_REPO_URL]),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.new_releases),
            title: Text(t.settings.release),
            subtitle: const Text('Releases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchUrl(
              Uri.parse(_configService[ConfigService.REMOTE_REPO_RELEASE_URL]),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(t.settings.issueReport),
            subtitle: const Text('Issues'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchUrl(
              Uri.parse('${_configService[ConfigService.REMOTE_REPO_URL]}/issues'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(t.settings.openSourceLicense),
            subtitle: const Text('Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLicenses,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    return Scaffold(
      appBar: SettingsAppBar(
        title: t.settings.about,
        isWideScreen: widget.isWideScreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfoSection(),
          const SizedBox(height: 16),
          _buildUpdateSection(),
          const SizedBox(height: 16),
          _buildLinksSection(),
          SizedBox(height: Get.context != null ? 
            MediaQuery.of(Get.context!).padding.bottom : 0),
        ],
      ),
    );
  }
}