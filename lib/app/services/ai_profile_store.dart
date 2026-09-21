import 'dart:convert';

import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/secure_fallback_cipher.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 基于 ConfigService 的 AI 供应商多档案存储实现。
///
/// - 档案元数据存 [ConfigKey.AI_PROVIDER_PROFILES]（不含密钥）
/// - 密钥经 [SecureFallbackCipher] 加密存 [ConfigKey.AI_PROVIDER_KEYS]
/// - 用途绑定关系存 [ConfigKey.AI_TASK_BINDINGS]
class ConfigProfileStore implements AiProfileStore {
  ConfigProfileStore(this._config, {SecureFallbackCipher? cipher})
    : _cipher = cipher ?? SecureFallbackCipher();

  final ConfigService _config;
  final SecureFallbackCipher _cipher;

  /// profileId -> 明文密钥映射。
  final Map<String, String> _keys = {};
  bool _keysLoaded = false;
  Future<void>? _readyFuture;

  /// 上一次解码过的那串 JSON 与结果。
  ///
  /// ⛔ 这不是洁癖：[profileFor] 被同步的 `AiService.isAvailable` 调用，而那个
  /// 要出现在 build 里（设置页那张列表、搜索页那枚 AI 钮的在场判定）。不缓存
  /// 的话每一帧都要跑两次 `jsonDecode`。缓存键就是原始字符串本身，所以配置一
  /// 改就自然失效，不需要谁来通知。
  String? _profilesRawCache;
  List<AiProviderProfile> _profilesCache = const [];
  String? _bindingsRawCache;
  Map<AiTask, String> _bindingsCache = const {};

  /// 档案的**骨架**（不含密钥）。密钥由 [profiles] 现贴，因为 `_keys` 会在
  /// ensureReady / saveProfiles 之后变，而它不进这层缓存。
  List<AiProviderProfile> get _decodedProfiles {
    final raw = _config[ConfigKey.AI_PROVIDER_PROFILES] as String?;
    if (raw != _profilesRawCache) {
      _profilesRawCache = raw;
      _profilesCache = AiProviderProfile.decodeList(raw);
    }
    return _profilesCache;
  }

  @override
  List<AiProviderProfile> get profiles => _decodedProfiles
      .map((p) => p.copyWith(apiKey: _keys[p.id] ?? ''))
      .toList();

  @override
  AiProviderProfile? profileFor(AiTask task) {
    final profileId = bindings[task];
    if (profileId != null && profileId.isNotEmpty) {
      for (final p in _decodedProfiles) {
        if (p.id == profileId) {
          return p.copyWith(apiKey: _keys[p.id] ?? '');
        }
      }
    }
    // 绑定缺失 / 绑的档案已被删：退回第一条可用的。
    // ⛔ 不要在这里返回 null——用户在设置里明明有一份能用的档案，却被告知
    // 「AI 没配置」，而那条坏掉的绑定他根本看不见。
    for (final p in _decodedProfiles) {
      final withKey = p.copyWith(apiKey: _keys[p.id] ?? '');
      if (withKey.isUsable) return withKey;
    }
    return null;
  }

  /// 同步读取用途绑定表。
  Map<AiTask, String> get bindings {
    final raw = _config[ConfigKey.AI_TASK_BINDINGS] as String?;
    if (raw != _bindingsRawCache) {
      _bindingsRawCache = raw;
      _bindingsCache = AiTaskBindings.decode(raw);
    }
    return _bindingsCache;
  }

  /// 幂等初始化：先迁移历史配置，再解密填充密钥表。
  Future<void> ensureReady() => _readyFuture ??= _ensureReadyInternal();

  Future<void> _ensureReadyInternal() async {
    if (_keysLoaded) return;
    final migrated = await _migrateLegacyIfNeeded();
    // ⛔ 迁移过就**不要**再 _loadKeys：[saveProfiles] 已经把明文密钥填进
    // `_keys` 了，而 _loadKeys 是 clear + 从库重读。加密不可用时（Web / 密钥
    // 文件坏了）那一条没能写进库，重读会把刚迁移出来的密钥当场清掉——用户
    // 升级一次就得重填一遍 key，且毫无征兆。
    if (!migrated) await _loadKeys();
    _keysLoaded = true;
  }

  /// 读取 AI_PROVIDER_KEYS 解密并填充内存 _keys。
  Future<void> _loadKeys() async {
    final rawKeys = _config[ConfigKey.AI_PROVIDER_KEYS] as String?;
    final decryptedKeys = <String, String>{};
    if (rawKeys != null && rawKeys.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawKeys);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final profileId = entry.key.toString();
            final rawValue = entry.value?.toString() ?? '';
            if (rawValue.isEmpty) continue;
            if (SecureFallbackCipher.isEnvelope(rawValue)) {
              final clear = await _cipher.decrypt(rawValue);
              if (clear != null) {
                decryptedKeys[profileId] = clear;
              }
              // 解密返回 null 当成「这条没配过」（跳过，不抛）
            } else {
              // 历史遗留 / 手改非信封值：当明文原样采纳（兼容）
              decryptedKeys[profileId] = rawValue;
            }
          }
        }
      } catch (e) {
        LogUtils.w('解析 AI 密钥表失败: $e', 'ConfigProfileStore');
      }
    }
    _keys
      ..clear()
      ..addAll(decryptedKeys);
  }

  /// 写入档案列表及对应密钥。
  ///
  /// ⛔ 密钥表剔除已不存在的 profileId。
  Future<void> saveProfiles(List<AiProviderProfile> profiles) async {
    // 1. 写档案元数据（encodeList 本来就不写密钥）
    await _config.setSetting(
      ConfigKey.AI_PROVIDER_PROFILES,
      AiProviderProfile.encodeList(profiles),
    );

    // 2. 加密写密钥表并更新内存 _keys，剔除已不存在的 profileId
    final newKeysMap = <String, String>{};
    final newMemoryKeys = <String, String>{};

    for (final p in profiles) {
      final key = p.apiKey.trim();
      if (key.isNotEmpty) {
        final enc = await _cipher.encrypt(key);
        if (enc != null) {
          newKeysMap[p.id] = enc;
          newMemoryKeys[p.id] = key;
        } else {
          LogUtils.w('加密档案(${p.id})密钥失败，未写入持久化密钥表', 'ConfigProfileStore');
          newMemoryKeys[p.id] = key;
        }
      }
    }

    await _config.setSetting(
      ConfigKey.AI_PROVIDER_KEYS,
      jsonEncode(newKeysMap),
    );

    _keys
      ..clear()
      ..addAll(newMemoryKeys);
  }

  /// 写入用途绑定表。
  Future<void> saveBindings(Map<AiTask, String> bindings) async {
    await _config.setSetting(
      ConfigKey.AI_TASK_BINDINGS,
      AiTaskBindings.encode(bindings),
    );
  }

  /// 首次从旧版 AI 配置单向迁移。返回「这次真的迁移了」。
  Future<bool> _migrateLegacyIfNeeded() async {
    final profilesRaw = _config[ConfigKey.AI_PROVIDER_PROFILES] as String?;
    if (profilesRaw != null && profilesRaw.trim().isNotEmpty) {
      return false;
    }

    final legacyApiKey =
        (_config[ConfigKey.AI_TRANSLATION_API_KEY] as String?)?.trim() ?? '';
    final legacyBaseUrl =
        (_config[ConfigKey.AI_TRANSLATION_BASE_URL] as String?)?.trim() ?? '';
    final legacyModel =
        (_config[ConfigKey.AI_TRANSLATION_MODEL] as String?)?.trim() ?? '';

    final hasLegacyConfig =
        legacyApiKey.isNotEmpty ||
        legacyBaseUrl.isNotEmpty ||
        legacyModel.isNotEmpty;

    if (!hasLegacyConfig) {
      return false;
    }

    final legacyProfile = LegacyConfigProfileStore.readLegacy(_config);
    await saveProfiles([legacyProfile]);
    // 三个用途全绑到这一条：改造前就是所有用途共用同一份配置，迁移不该
    // 顺手改变任何行为。
    await saveBindings({
      for (final task in AiTask.values) task: legacyProfile.id,
    });
    LogUtils.i('已完成旧版 AI 配置向多档案配置的自动迁移', 'ConfigProfileStore');
    return true;
  }
}
