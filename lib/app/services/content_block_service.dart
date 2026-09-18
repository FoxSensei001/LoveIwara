import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/block_rule.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 本地内容屏蔽服务。
///
/// 规则纯本地存储于 [ConfigService] 的 [ConfigKey.CONTENT_BLOCK_RULES]（JSON 列表），
/// 因此会被 `ConfigBackupService` 的整体「设置备份」自动包含。
/// 同时提供独立的屏蔽规则 JSON 导入/导出，便于单独分享屏蔽清单。
class ContentBlockService extends GetxService {
  static const String _tag = 'ContentBlockService';

  /// 正则 pattern 最大长度，限制复杂度（ReDoS 缓解之一）。
  static const int maxRegexPatternLength = 200;

  /// 参与正则匹配的标题最大长度，对最坏回溯开销做防御性截断。
  /// 注意：这只能降低、并不能彻底消除灾难性回溯（Dart 的 [RegExp] 无超时机制）；
  /// 真正不可信来源的正则若要彻底防护需放到带超时的 isolate 中执行。
  static const int _maxRegexInputLength = 256;

  ConfigService get _configService => Get.find<ConfigService>();

  /// 当前所有规则（响应式，卡片通过 Obx 订阅自动刷新）。
  final RxList<BlockRule> rules = <BlockRule>[].obs;

  /// 编译后的正则缓存，key 为 `${caseSensitive}\x00${pattern}`，避免每帧重复编译。
  final Map<String, RegExp?> _regexCache = {};

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    try {
      final raw = _configService[ConfigKey.CONTENT_BLOCK_RULES];
      final List<dynamic> list = raw is List ? raw : const [];
      rules.assignAll(
        list
            .whereType<Map>()
            .map((e) => BlockRule.fromJson(Map<String, dynamic>.from(e)))
            .where((r) => r.value.isNotEmpty)
            .toList(),
      );
    } catch (e) {
      LogUtils.e('加载屏蔽规则失败', tag: _tag, error: e);
      rules.clear();
    }
    _regexCache.clear();
  }

  Future<void> _persist() async {
    _regexCache.clear();
    final encoded = rules.map((r) => r.toJson()).toList();
    await _configService.setSetting(ConfigKey.CONTENT_BLOCK_RULES, encoded);
  }

  /// 自增序号，避免同一微秒内连续生成（如批量导入）时时间戳撞值导致重复 id。
  int _idSeq = 0;

  String _genId() {
    return 'r_${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';
  }

  @visibleForTesting
  String debugGenId() => _genId();

  // ----------------------------- 匹配 -----------------------------

  /// 检查给定标题 / 作者 ID 是否命中任一启用的规则。命中返回首条 [BlockMatch]，否则 null。
  BlockMatch? check({String? title, String? authorId}) {
    if (rules.isEmpty) return null;
    final normalizedTitle = title?.trim() ?? '';
    for (final rule in rules) {
      if (!rule.enabled) continue;
      switch (rule.type) {
        case BlockRuleType.userId:
          if (authorId != null &&
              authorId.isNotEmpty &&
              authorId == rule.value) {
            return BlockMatch(rule);
          }
          break;
        case BlockRuleType.keyword:
          if (normalizedTitle.isEmpty) break;
          if (_matchKeyword(normalizedTitle, rule)) {
            return BlockMatch(rule);
          }
          break;
        case BlockRuleType.regex:
          if (normalizedTitle.isEmpty) break;
          if (_matchRegex(normalizedTitle, rule)) {
            return BlockMatch(rule);
          }
          break;
      }
    }
    return null;
  }

  bool _matchKeyword(String title, BlockRule rule) {
    if (rule.caseSensitive) {
      return title.contains(rule.value);
    }
    return title.toLowerCase().contains(rule.value.toLowerCase());
  }

  bool _matchRegex(String title, BlockRule rule) {
    final regex = _compile(rule.value, rule.caseSensitive);
    if (regex == null) return false;
    // 截断超长标题，限制最坏回溯开销（防御性，详见 [_maxRegexInputLength]）。
    final sample = title.length > _maxRegexInputLength
        ? title.substring(0, _maxRegexInputLength)
        : title;
    return regex.hasMatch(sample);
  }

  RegExp? _compile(String pattern, bool caseSensitive) {
    final key = '$caseSensitive\x00$pattern';
    if (_regexCache.containsKey(key)) return _regexCache[key];
    RegExp? compiled;
    try {
      compiled = RegExp(pattern, caseSensitive: caseSensitive);
    } catch (_) {
      compiled = null;
    }
    _regexCache[key] = compiled;
    return compiled;
  }

  /// 校验正则是否合法，供设置页输入校验使用。
  /// 过长的 pattern 视为非法，以限制复杂度（ReDoS 缓解之一）。
  bool isValidRegex(String pattern) {
    if (pattern.isEmpty || pattern.length > maxRegexPatternLength) return false;
    try {
      RegExp(pattern);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------- CRUD -----------------------------

  Future<BlockRule> addRule({
    required BlockRuleType type,
    required String value,
    String? label,
    bool caseSensitive = false,
    bool enabled = true,
  }) async {
    final rule = BlockRule(
      id: _genId(),
      type: type,
      value: value.trim(),
      label: label,
      caseSensitive: caseSensitive,
      enabled: enabled,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    rules.add(rule);
    await _persist();
    return rule;
  }

  Future<void> updateRule(BlockRule rule) async {
    final index = rules.indexWhere((r) => r.id == rule.id);
    if (index < 0) return;
    rules[index] = rule;
    await _persist();
  }

  Future<void> removeRule(String id) async {
    rules.removeWhere((r) => r.id == id);
    await _persist();
  }

  Future<void> toggleRule(String id, bool enabled) async {
    final index = rules.indexWhere((r) => r.id == id);
    if (index < 0) return;
    rules[index] = rules[index].copyWith(enabled: enabled);
    await _persist();
  }

  // ----------------------------- 用户屏蔽 -----------------------------

  bool isUserBlocked(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return rules.any(
      (r) => r.type == BlockRuleType.userId && r.enabled && r.value == userId,
    );
  }

  Future<void> blockUser(User user) async {
    if (user.id.isEmpty) return;
    // 已存在则仅确保启用
    final existing = rules.firstWhereOrNull(
      (r) => r.type == BlockRuleType.userId && r.value == user.id,
    );
    if (existing != null) {
      if (!existing.enabled) {
        await toggleRule(existing.id, true);
      }
      return;
    }
    await addRule(
      type: BlockRuleType.userId,
      value: user.id,
      label: user.name.isNotEmpty ? user.name : user.username,
    );
  }

  Future<void> unblockUser(String userId) async {
    rules.removeWhere(
      (r) => r.type == BlockRuleType.userId && r.value == userId,
    );
    await _persist();
  }

  // ----------------------------- 导入 / 导出 -----------------------------

  /// 导出当前所有屏蔽规则为独立 JSON 文件。返回 true 表示成功保存。
  Future<bool> exportRulesToFile() async {
    final Map<String, dynamic> data = {
      'format': 'i_iwara_block_rules',
      'format_version': 1,
      'app_version': CommonConstants.VERSION,
      'rules': rules.map((r) => r.toJson()).toList(),
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final suggestedName =
        '${CommonConstants.applicationName}_block_rules_${CommonUtils.exportFileTimestamp()}.json';

    if (Platform.isAndroid || Platform.isIOS) {
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final params = SaveFileDialogParams(data: bytes, fileName: suggestedName);
      final savedPath = await FlutterFileDialog.saveFile(params: params);
      return savedPath != null;
    } else {
      final location = await fs.getSaveLocation(
        acceptedTypeGroups: [
          const fs.XTypeGroup(label: 'JSON', extensions: ['json']),
        ],
        suggestedName: suggestedName,
      );
      if (location == null) return false;
      await File(location.path).writeAsString(jsonString);
      return true;
    }
  }

  /// 从独立 JSON 文件导入屏蔽规则。
  /// [merge] 为 true 时与现有规则合并（按 value+type 去重），false 时整体替换。
  /// 返回导入（新增）的规则数量；用户取消返回 null。
  Future<int?> importRulesFromFile({bool merge = true}) async {
    String content;
    if (Platform.isAndroid || Platform.isIOS) {
      const params = OpenFileDialogParams();
      final filePath = await FlutterFileDialog.pickFile(params: params);
      if (filePath == null) return null;
      content = await File(filePath).readAsString();
    } else {
      const typeGroup = fs.XTypeGroup(label: 'JSON', extensions: ['json']);
      final fs.XFile? file = await fs.openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return null;
      content = await file.readAsString();
    }

    final decoded = jsonDecode(content);
    if (decoded is! Map || decoded['rules'] is! List) {
      throw const FormatException('invalid block rules file');
    }
    final imported = (decoded['rules'] as List)
        .whereType<Map>()
        .map((e) => BlockRule.fromJson(Map<String, dynamic>.from(e)))
        .where((r) => r.value.isNotEmpty)
        // 丢弃来自外部文件的非法/超长正则，避免引入会卡死列表的灾难性回溯规则。
        .where((r) => r.type != BlockRuleType.regex || isValidRegex(r.value))
        .toList();

    int added = 0;
    if (merge) {
      final existingKeys = rules
          .map((r) => '${r.type.storageValue}\x00${r.value}')
          .toSet();
      for (final r in imported) {
        final key = '${r.type.storageValue}\x00${r.value}';
        if (existingKeys.contains(key)) continue;
        existingKeys.add(key);
        rules.add(r.copyWith(id: _genId()));
        added++;
      }
    } else {
      rules.assignAll(imported.map((r) => r.copyWith(id: _genId())).toList());
      added = imported.length;
    }
    await _persist();
    return added;
  }
}
