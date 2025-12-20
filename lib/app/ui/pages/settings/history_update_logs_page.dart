import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/update_info.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.historyUpdateLogs)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUpdateLogs,
                    child: Text(t.common.retry),
                  ),
                ],
              ),
            )
          : _buildLogsList(),
    );
  }

  Widget _buildLogsList() {
    final t = slang.Translations.of(context);
    if (_updateLogs.isEmpty) {
      return Center(child: Text(t.settings.noUpdateLogs));
    }
    return ListView.builder(
      itemCount: _updateLogs.length,
      itemBuilder: (context, index) {
        final update = _updateLogs[index];
        final configService = Get.find<ConfigService>();
        String locale = configService[ConfigKey.APPLICATION_LOCALE] ?? 'en';
        if (locale == 'system') {
          locale = CommonUtils.getDeviceLocale();
        }
        List<String> changes = update.getLocalizedChanges(locale);
        return ExpansionTile(
          title: Text(
            t.settings.versionLabel.replaceAll('{version}', update.version),
          ),
          subtitle: Text(
            t.settings.releaseDateLabel.replaceAll('{date}', update.date),
          ),
          children: changes.isNotEmpty
              ? changes.map((change) => ListTile(title: Text(change))).toList()
              : [ListTile(title: Text(t.settings.noChanges))],
        );
      },
    );
  }
}
