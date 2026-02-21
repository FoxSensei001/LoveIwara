import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/log_viewer_page.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class DiagnosticsPage extends StatefulWidget {
  final bool isWideScreen;

  const DiagnosticsPage({required this.isWideScreen, super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  static const String _supportEmail = 'miximixihuabulaji@proton.me';
  static const int _droppedWarnThreshold = 100;
  static const int _queueWarnThreshold = (LogConstants.highWaterMark * 8) ~/ 10;
  static const int _flushLatencyWarnMs = 2000;
  bool _isExporting = false;
  bool _isApplyingLogPolicy = false;
  String _deviceInfo = '';
  LogHealthSnapshot? _logHealthSnapshot;
  Timer? _healthRefreshTimer;

  ConfigService? get _configService {
    if (Get.isRegistered<ConfigService>()) {
      return Get.find<ConfigService>();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _refreshLogHealth();
    _healthRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshLogHealth();
    });
  }

  @override
  void dispose() {
    _healthRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final info = StringBuffer();

      if (GetPlatform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        info.writeln('${android.brand} ${android.model}');
        info.writeln(
          'Android ${android.version.release} (SDK ${android.version.sdkInt})',
        );
      } else if (GetPlatform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        info.writeln('${ios.name} (${ios.model})');
        info.writeln('iOS ${ios.systemVersion}');
      } else if (GetPlatform.isWindows) {
        final windows = await deviceInfo.windowsInfo;
        info.writeln(windows.computerName);
        info.writeln(
          'Windows ${windows.displayVersion} (${windows.buildNumber})',
        );
      } else if (GetPlatform.isMacOS) {
        final mac = await deviceInfo.macOsInfo;
        info.writeln(mac.computerName);
        info.writeln('macOS ${mac.osRelease}');
      } else if (GetPlatform.isLinux) {
        final linux = await deviceInfo.linuxInfo;
        info.writeln(linux.name);
        info.writeln('${linux.version}');
      }

      final memMB = (ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(1);
      info.writeln(slang.t.diagnostics.memoryUsage(memMB: memMB));

      if (mounted) {
        setState(() => _deviceInfo = info.toString().trim());
      }
    } catch (_) {
      if (mounted) {
        setState(() => _deviceInfo = slang.t.diagnostics.deviceInfoUnavailable);
      }
    }
  }

  bool _configBool(ConfigKey key, bool fallback) {
    final config = _configService;
    if (config == null) return fallback;
    final raw = config[key];
    if (raw is bool) return raw;
    if (raw is String) return raw.toLowerCase() == 'true';
    return fallback;
  }

  int _configInt(ConfigKey key, int fallback) {
    final config = _configService;
    if (config == null) return fallback;
    final raw = config[key];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? fallback;
    return fallback;
  }

  String _configString(ConfigKey key, String fallback) {
    final config = _configService;
    if (config == null) return fallback;
    final raw = config[key];
    if (raw is String && raw.isNotEmpty) return raw;
    return fallback;
  }

  Future<void> _updateLogSetting(ConfigKey key, dynamic value) async {
    final config = _configService;
    if (config == null) return;

    await config.setSetting(key, value);
    await _applyLogPolicyFromConfig();
    await _refreshLogHealth();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _applyLogPolicyFromConfig() async {
    if (_isApplyingLogPolicy) return;
    if (!Get.isRegistered<LogService>()) return;
    final config = _configService;
    if (config == null) return;

    _isApplyingLogPolicy = true;
    try {
      final service = Get.find<LogService>();
      await service.applyPolicy(
        LogService.policyFromConfig(config, isProduction: kReleaseMode),
      );
    } finally {
      _isApplyingLogPolicy = false;
    }
  }

  Future<void> _refreshLogHealth() async {
    if (!Get.isRegistered<LogService>()) return;
    try {
      final service = Get.find<LogService>();
      final snapshot = await service.getHealthSnapshot();
      if (mounted) {
        setState(() {
          _logHealthSnapshot = snapshot;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    final theme = Theme.of(context);
    final hasConfig = _configService != null;
    final logEnabled = _configBool(ConfigKey.LOGGING_ENABLED, true);
    final persistenceEnabled = _configBool(
      ConfigKey.LOG_PERSISTENCE_ENABLED,
      true,
    );
    final minLevel = _configString(ConfigKey.LOG_MIN_LEVEL, 'INFO');
    final maxFileMb = _configInt(ConfigKey.LOG_MAX_FILE_MB, 5).clamp(1, 50);
    final maxFileBytes = maxFileMb * 1024 * 1024;
    final maxRotated = _configInt(
      ConfigKey.LOG_MAX_ROTATED_FILES,
      3,
    ).clamp(1, 10);
    final maxHangFileMb = _configInt(
      ConfigKey.LOG_HANG_MAX_FILE_MB,
      2,
    ).clamp(1, 20);
    final maxHangRotated = _configInt(
      ConfigKey.LOG_HANG_MAX_ROTATED_FILES,
      2,
    ).clamp(1, 10);

    return Material(
      child: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.diagnosticsAndFeedback,
            isWideScreen: widget.isWideScreen,
            expandedHeight: 56,
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 诊断信息
                _buildCard(
                  theme: theme,
                  children: [
                    _buildSectionHeader(
                      theme,
                      Icons.info_outline,
                      t.diagnostics.infoSectionTitle,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            t.diagnostics.appVersionLabel,
                            CommonConstants.VERSION,
                          ),
                          const SizedBox(height: 4),
                          if (_deviceInfo.isNotEmpty)
                            Text(
                              _deviceInfo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _buildCard(
                  theme: theme,
                  children: [
                    _buildSectionHeader(
                      theme,
                      Icons.tune,
                      t.diagnostics.logPolicySectionTitle,
                    ),
                    if (!hasConfig)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Text(t.diagnostics.configServiceUnavailable),
                      )
                    else ...[
                      _buildSwitchTile(
                        title: t.diagnostics.enableLoggingTitle,
                        subtitle: t.diagnostics.enableLoggingSubtitle,
                        value: logEnabled,
                        onChanged: (v) =>
                            _updateLogSetting(ConfigKey.LOGGING_ENABLED, v),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: t.diagnostics.enableLogPersistenceTitle,
                        subtitle: t.diagnostics.enableLogPersistenceSubtitle,
                        value: persistenceEnabled,
                        onChanged: logEnabled
                            ? (v) => _updateLogSetting(
                                ConfigKey.LOG_PERSISTENCE_ENABLED,
                                v,
                              )
                            : null,
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        title: t.diagnostics.minLogLevelTitle,
                        subtitle: t.diagnostics.minLogLevelSubtitle,
                        value: minLevel,
                        options: const [
                          'DEBUG',
                          'INFO',
                          'WARN',
                          'ERROR',
                          'FATAL',
                        ],
                        onChanged: logEnabled
                            ? (v) =>
                                  _updateLogSetting(ConfigKey.LOG_MIN_LEVEL, v)
                            : null,
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        title: t.diagnostics.maxFileSizeTitle,
                        subtitle: t.diagnostics.maxFileSizeSubtitle,
                        value: '${maxFileMb}MB',
                        options: const ['1MB', '2MB', '5MB', '10MB', '20MB'],
                        onChanged: persistenceEnabled
                            ? (v) => _updateLogSetting(
                                ConfigKey.LOG_MAX_FILE_MB,
                                int.parse(v.replaceAll('MB', '')),
                              )
                            : null,
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        title: t.diagnostics.rotatedFileCountTitle,
                        subtitle: t.diagnostics.rotatedFileCountSubtitle,
                        value: '$maxRotated',
                        options: const [
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                          '8',
                          '9',
                          '10',
                        ],
                        onChanged: persistenceEnabled
                            ? (v) => _updateLogSetting(
                                ConfigKey.LOG_MAX_ROTATED_FILES,
                                int.parse(v),
                              )
                            : null,
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        title: t.diagnostics.hangFileSizeTitle,
                        subtitle: t.diagnostics.hangFileSizeSubtitle,
                        value: '${maxHangFileMb}MB',
                        options: const [
                          '1MB',
                          '2MB',
                          '3MB',
                          '5MB',
                          '10MB',
                          '20MB',
                        ],
                        onChanged: persistenceEnabled
                            ? (v) => _updateLogSetting(
                                ConfigKey.LOG_HANG_MAX_FILE_MB,
                                int.parse(v.replaceAll('MB', '')),
                              )
                            : null,
                      ),
                      _buildDivider(),
                      _buildDropdownTile(
                        title: t.diagnostics.hangRotatedFileCountTitle,
                        subtitle: t.diagnostics.hangRotatedFileCountSubtitle,
                        value: '$maxHangRotated',
                        options: const [
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                          '8',
                          '9',
                          '10',
                        ],
                        onChanged: persistenceEnabled
                            ? (v) => _updateLogSetting(
                                ConfigKey.LOG_HANG_MAX_ROTATED_FILES,
                                int.parse(v),
                              )
                            : null,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                _buildCard(
                  theme: theme,
                  children: [
                    _buildSectionHeader(
                      theme,
                      Icons.monitor_heart,
                      t.diagnostics.healthSectionTitle,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _buildHealthSummary(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildHealthAlerts(theme, maxFileBytes: maxFileBytes),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _refreshLogHealth,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: Text(t.diagnostics.refreshMetrics),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 操作
                _buildCard(
                  theme: theme,
                  children: [
                    _buildSectionHeader(
                      theme,
                      Icons.build_outlined,
                      t.diagnostics.toolsSectionTitle,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          t.diagnostics.privacyNotice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                    _buildActionTile(
                      icon: Icons.upload_file,
                      title: t.diagnostics.exportLogsTitle,
                      subtitle: t.diagnostics.exportLogsSubtitle,
                      trailing: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onTap: _isExporting ? null : _exportLogs,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.visibility,
                      title: t.diagnostics.viewLogsTitle,
                      subtitle: t.diagnostics.viewLogsSubtitle,
                      onTap: _openLogViewer,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.mail_outline,
                      title: t.diagnostics.copySupportEmailTitle,
                      subtitle: _supportEmail,
                      trailing: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: _copySupportEmail,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.bug_report,
                      title: t.diagnostics.reportIssueTitle,
                      subtitle: t.diagnostics.reportIssueSubtitle,
                      onTap: _reportBug,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _buildHealthSummary() {
    final h = _logHealthSnapshot;
    if (h == null) {
      return slang.t.diagnostics.healthSummaryUnavailable;
    }
    return [
      'enabled=${h.enabled} persistence=${h.persistenceEnabled}',
      'queue=${h.queueDepth} ring=${h.ringDepth} dropped=${h.droppedCount}',
      'flush=${h.flushCount} fail=${h.flushFailureCount} latency=${h.lastFlushLatencyMs ?? '-'}ms',
      'file=${_formatBytes(h.currentLogFileBytes)} degraded=${h.sinkDegraded}',
      'exportFail=${h.exportFailCount} lastExport=${_formatTime(h.lastExportAt)}',
      'lastFlush=${_formatTime(h.lastFlushAt)}',
    ].join('\n');
  }

  Widget _buildHealthAlerts(ThemeData theme, {required int maxFileBytes}) {
    final h = _logHealthSnapshot;
    if (h == null) {
      return Text(
        slang.t.diagnostics.healthMetricsUnavailable,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final alerts = _collectHealthAlerts(h, maxFileBytes: maxFileBytes);
    if (alerts.isEmpty) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            slang.t.diagnostics.healthNoRiskIndicators,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts.map((a) => _buildHealthAlertRow(theme, a)).toList(),
    );
  }

  List<_HealthAlert> _collectHealthAlerts(
    LogHealthSnapshot h, {
    required int maxFileBytes,
  }) {
    final alerts = <_HealthAlert>[];

    if (h.flushFailureCount > 0) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.flushFailureTitle,
          detail: 'flushFailureCount=${h.flushFailureCount}',
          critical: true,
        ),
      );
    }

    if (h.sinkDegraded) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.sinkDegradedTitle,
          detail: slang.t.diagnostics.healthAlert.sinkDegradedDetail,
          critical: true,
        ),
      );
    }

    if (h.queueDepth >= _queueWarnThreshold) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.queueBacklogTitle,
          detail: slang.t.diagnostics.healthAlert.queueBacklogDetail(
            queueDepth: h.queueDepth,
            threshold: _queueWarnThreshold,
          ),
          critical: true,
        ),
      );
    }

    if (h.lastFlushLatencyMs != null &&
        h.lastFlushLatencyMs! >= _flushLatencyWarnMs) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.highFlushLatencyTitle,
          detail: 'lastFlushLatency=${h.lastFlushLatencyMs}ms',
          critical: false,
        ),
      );
    }

    if (h.droppedCount >= _droppedWarnThreshold) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.droppedTooManyTitle,
          detail: slang.t.diagnostics.healthAlert.droppedTooManyDetail(
            droppedCount: h.droppedCount,
            threshold: _droppedWarnThreshold,
          ),
          critical: false,
        ),
      );
    }

    if (h.processorRateLimitedCount > 0) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.rateLimitedTitle,
          detail: 'processorRateLimited=${h.processorRateLimitedCount}',
          critical: false,
        ),
      );
    }

    if (h.exportFailCount > 0) {
      alerts.add(
        _HealthAlert(
          title: slang.t.diagnostics.healthAlert.exportFailedTitle,
          detail: 'exportFailCount=${h.exportFailCount}',
          critical: false,
        ),
      );
    }

    if (h.persistenceEnabled && maxFileBytes > 0) {
      final usagePercent = (h.currentLogFileBytes * 100) ~/ maxFileBytes;
      if (usagePercent >= 90) {
        alerts.add(
          _HealthAlert(
            title: slang.t.diagnostics.healthAlert.fileNearLimitTitle,
            detail: slang.t.diagnostics.healthAlert.fileNearLimitDetail(
              usagePercent: usagePercent,
            ),
            critical: false,
          ),
        );
      }
    }

    return alerts;
  }

  Widget _buildHealthAlertRow(ThemeData theme, _HealthAlert alert) {
    final bgColor = alert.critical
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.65)
        : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.65);
    final fgColor = alert.critical
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onTertiaryContainer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            alert.critical ? Icons.error_outline : Icons.warning_amber_rounded,
            size: 16,
            color: fgColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${alert.title} · ${alert.detail}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '-';
    final local = time.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  Widget _buildCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      contentPadding: const EdgeInsets.only(left: 12, right: 8),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: DropdownButton<String>(
        value: options.contains(value) ? value : options.first,
        onChanged: onChanged == null
            ? null
            : (next) {
                if (next != null) {
                  onChanged(next);
                }
              },
        items: options
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
      ),
    );
  }

  Future<void> _exportLogs() async {
    setState(() => _isExporting = true);

    try {
      if (!Get.isRegistered<LogService>()) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.diagnostics.toast.logServiceNotInitialized,
            type: MDToastType.error,
          ),
        );
        return;
      }

      final logService = Get.find<LogService>();
      final file = await logService.exportLogs();

      if (!mounted) return;

      if (GetPlatform.isDesktop) {
        final result = await getSaveLocation(
          suggestedName: 'loveiwara_logs.zip',
          acceptedTypeGroups: [
            const XTypeGroup(label: 'ZIP', extensions: ['zip']),
          ],
        );
        if (result != null) {
          await File(file.path).copy(result.path);
          showToastWidget(
            MDToastWidget(
              message: slang.t.diagnostics.toast.exportSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: slang.t.diagnostics.shareSubject,
          ),
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.diagnostics.toast.exportFailed(error: e.toString()),
          type: MDToastType.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _openLogViewer() {
    final page = LogViewerPage(isWideScreen: widget.isWideScreen);
    if (widget.isWideScreen) {
      SettingsPage.navigateToNestedPage(page);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }
  }

  Future<void> _reportBug() async {
    final uri = Uri.parse(
      'https://github.com/FoxSensei001/LoveIwara/issues/new',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (mounted) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.diagnostics.toast.supportEmailCopied,
          type: MDToastType.success,
        ),
      );
    }
  }
}

class _HealthAlert {
  final String title;
  final String detail;
  final bool critical;

  const _HealthAlert({
    required this.title,
    required this.detail,
    required this.critical,
  });
}
