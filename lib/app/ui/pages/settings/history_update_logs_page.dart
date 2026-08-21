import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/update_info.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 历史更新日志页（从「关于」推入）。
///
/// 玻璃化：GlassSettingsScaffold 骨架 + 每个版本一张 [GlassExpansionCard]
/// （替代裸 Scaffold/AppBar/ExpansionTile）。
class HistoryUpdateLogsPage extends StatefulWidget {
  const HistoryUpdateLogsPage({super.key});

  @override
  State<HistoryUpdateLogsPage> createState() => _HistoryUpdateLogsPageState();
}

class _HistoryUpdateLogsPageState extends State<HistoryUpdateLogsPage> {
  final VersionService _versionService = Get.find();
  bool _isLoading = true;
  List<UpdateInfo> _updateLogs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUpdateLogs();
  }

  Future<void> _loadUpdateLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      List<UpdateInfo> logs = await _versionService.fetchAllUpdateLogs();
      setState(() {
        _updateLogs = logs;
      });
    } catch (e) {
      setState(() {
        _error = slang.t.errors.failedToFetchData;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    return GlassSettingsScaffold(
      title: t.settings.historyUpdateLogs,
      // 由「关于」页推入；即使是宽屏双栏，这里也保留返回钮（它不是左栏可选的分区）。
      slivers: [
        if (_isLoading || _error != null || _updateLogs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildPlaceholder(context, t),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildVersionCard(context, t, _updateLogs[index]),
                childCount: _updateLogs.length,
              ),
            ),
          ),
      ],
    );
  }

  /// 加载中 / 出错 / 空态的整屏占位。
  Widget _buildPlaceholder(BuildContext context, slang.Translations t) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadUpdateLogs,
              child: Text(t.common.retry),
            ),
          ],
        ),
      );
    }
    return Center(child: Text(t.settings.noUpdateLogs));
  }

  Widget _buildVersionCard(
    BuildContext context,
    slang.Translations t,
    UpdateInfo update,
  ) {
    final configService = Get.find<ConfigService>();
    String locale = configService[ConfigKey.APPLICATION_LOCALE] ?? 'en';
    if (locale == 'system') {
      locale = CommonUtils.getDeviceLocale();
    }
    final changes = update.getLocalizedChanges(locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassExpansionCard(
        icon: Icons.history,
        title: Text(
          t.settings.versionLabel.replaceAll('{version}', update.version),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          t.settings.releaseDateLabel.replaceAll('{date}', update.date),
        ),
        children: [
          if (changes.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Text(t.settings.noChanges),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final change in changes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(change)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
