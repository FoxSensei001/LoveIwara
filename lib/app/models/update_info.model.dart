class UpdateInfo {
  final String version; // 版本号
  final String date; // 更新日期
  final Map<String, List<String>> changes; // 更新内容
  final bool forceUpdate; // 是否强制更新
  final String minVersion; // 最小版本号

  UpdateInfo({
    required this.version,
    required this.date,
    required this.changes,
    this.forceUpdate = false,
    this.minVersion = '0.0.1',
  });

  factory UpdateInfo.fromYaml(Map yaml) {
    final changesMap = <String, List<String>>{};
    final yamlChanges = yaml['changes'] as Map;
    
    yamlChanges.forEach((key, value) {
      changesMap[key.toString()] = List<String>.from(value);
    });

    return UpdateInfo(
      version: yaml['version'] ?? '',
      date: yaml['date'] ?? '',
      changes: changesMap,
      forceUpdate: yaml['forceUpdate'] ?? false,
      minVersion: yaml['minVersion'] ?? '0.0.1',
    );
  }

  List<String> getLocalizedChanges(String currentLocale) {
    return changes[currentLocale] ?? changes['en'] ?? changes['zh-CN'] ?? changes['zh-TW'] ?? changes['ja'] ?? [];
  }
} 