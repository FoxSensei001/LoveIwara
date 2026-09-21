import 'dart:convert';

import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/secure_fallback_cipher.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 基于 ConfigService 的 AI 供应商配置存储。
///
/// 三枚 ConfigKey，拆法**不许合并**：
///
/// | 键 | 装什么 | 进不进备份黑名单 |
/// |---|---|---|
/// | `AI_PROVIDER_PROFILES` | 供应商 + 模型（**不含密钥**） | ❌ 不进 |
/// | `AI_PROVIDER_KEYS` | 密钥表（`enc1:` 信封） | ✅ 进 |
/// | `AI_TASK_BINDINGS` | 用途 → `providerId/modelId` | ❌ 不进 |
///
/// ⛔ `config_backup_service.dart` 的 `_sensitiveConfigKeys` 是**按键名整格剔除**
/// 的黑名单。密钥要是跟配置存进同一格，换机恢复丢的就是**整张供应商列表**——
/// 用户看到的是「恢复后 AI 全没了」，而不只是要重填密钥。
class ConfigProfileStore implements AiProfileStore {
  ConfigProfileStore(this._config, {SecureFallbackCipher? cipher})
    : _cipher = cipher ?? SecureFallbackCipher();

  final ConfigService _config;
  final SecureFallbackCipher _cipher;

  /// providerId -> 明文密钥。
  final Map<String, String> _keys = {};
  bool _keysLoaded = false;
  Future<void>? _readyFuture;

  /// 上一次解码过的那串 JSON 与结果。
  ///
  /// ⛔ 这不是洁癖：[resolveFor] 被同步的 `AiService.isAvailable` 调用，而那个要
  /// 出现在 `build()` 里（设置页那张列表、搜索页那枚 AI 钮的在场判定）。不缓存
  /// 的话每一帧都要跑两次 `jsonDecode`。缓存键就是原始字符串本身，所以配置一改
  /// 就自然失效，不需要谁来通知。
  String? _configRawCache;
  AiProviderConfig _configCache = const AiProviderConfig();
  String? _bindingsRawCache;
  Map<AiTask, String> _bindingsCache = const {};

  /// 配置的**骨架**（不含密钥）。密钥由需要的地方现贴，因为 `_keys` 会在
  /// ensureReady / saveConfig 之后变，而它不进这层缓存。
  @override
  AiProviderConfig get config {
    final raw = _config[ConfigKey.AI_PROVIDER_PROFILES] as String?;
    if (raw != _configRawCache) {
      _configRawCache = raw;
      _configCache = AiProviderConfig.decode(raw);
    }
    return _configCache;
  }

  /// 用途 → `providerId/modelId`。
  Map<AiTask, String> get bindings {
    final raw = _config[ConfigKey.AI_TASK_BINDINGS] as String?;
    if (raw != _bindingsRawCache) {
      _bindingsRawCache = raw;
      _bindingsCache = AiTaskBindings.decode(raw);
    }
    return _bindingsCache;
  }

  String? keyOf(String providerId) => _keys[providerId];

  /// 把一条 (供应商, 模型) 合并成可以发请求的样子，顺手贴上密钥。
  AiResolvedModel resolve(AiProvider provider, AiModel model) => resolveAiModel(
    provider: provider.copyWith(apiKey: _keys[provider.id] ?? ''),
    model: model,
    providerCatalog: AiCatalogService.providerOf(provider.catalogId),
    modelCatalog: AiCatalogService.modelOf(model.modelId),
  );

  /// 全部已启用模型，按供应商顺序。设置页与用途下拉用它。
  List<AiResolvedModel> get allResolved {
    final out = <AiResolvedModel>[];
    for (final provider in config.providers) {
      for (final model in config.modelsOf(provider.id)) {
        out.add(resolve(provider, model));
      }
    }
    return out;
  }

  @override
  AiResolvedModel? resolveFor(AiTask task) {
    final current = config;
    final bound = bindings[task];

    if (bound != null && bound.isNotEmpty) {
      final model = current.modelByKey(bound);
      final provider = model == null
          ? null
          : current.providerById(model.providerId);
      if (model != null && provider != null && provider.enabled) {
        return resolve(provider, model);
      }
      // 兼容改造前的绑定值：那时候存的是**光秃秃的 providerId**（一家只有一个
      // 模型）。迁移会改写，但备份恢复 / 手改配置都可能把老值带回来。
      final legacy = current.providerById(bound);
      if (legacy != null && legacy.enabled) {
        final first = current.modelsOf(legacy.id);
        if (first.isNotEmpty) return resolve(legacy, first.first);
      }
    }

    // 绑定缺失 / 绑的东西已被删：退回第一条可用的。
    // ⛔ 不要在这里返回 null——用户在设置里明明有一份能用的配置，却被告知
    // 「AI 没配置」，而那条坏掉的绑定他根本看不见。
    for (final provider in current.providers) {
      if (!provider.enabled) continue;
      for (final model in current.modelsOf(provider.id)) {
        final resolved = resolve(provider, model);
        if (resolved.isUsable) return resolved;
      }
    }
    return null;
  }

  // -------------------------------------------------------------- 初始化

  /// 幂等初始化：先迁移历史配置，再解密填充密钥表。
  Future<void> ensureReady() => _readyFuture ??= _ensureReadyInternal();

  Future<void> _ensureReadyInternal() async {
    if (_keysLoaded) return;
    final migrated = await _migrateIfNeeded();
    // ⛔ 迁移过就**不要**再 _loadKeys：[saveConfig] 已经把明文密钥填进 `_keys`
    // 了，而 _loadKeys 是 clear + 从库重读。加密不可用时（Web / 密钥文件坏了）
    // 那一条没能写进库，重读会把刚迁移出来的密钥当场清掉——用户升级一次就得
    // 重填一遍 key，且毫无征兆。
    if (!migrated) await _loadKeys();
    _keysLoaded = true;
  }

  Future<void> _loadKeys() async {
    final rawKeys = _config[ConfigKey.AI_PROVIDER_KEYS] as String?;
    final decrypted = <String, String>{};
    if (rawKeys != null && rawKeys.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawKeys);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final providerId = entry.key.toString();
            final rawValue = entry.value?.toString() ?? '';
            if (rawValue.isEmpty) continue;
            if (SecureFallbackCipher.isEnvelope(rawValue)) {
              final clear = await _cipher.decrypt(rawValue);
              // 解密返回 null 当成「这条没配过」（跳过，不抛）
              if (clear != null) decrypted[providerId] = clear;
            } else {
              // 历史遗留 / 手改非信封值：当明文原样采纳（兼容）
              decrypted[providerId] = rawValue;
            }
          }
        }
      } catch (e) {
        LogUtils.w('解析 AI 密钥表失败: $e', 'ConfigProfileStore');
      }
    }
    _keys
      ..clear()
      ..addAll(decrypted);
  }

  // ---------------------------------------------------------------- 写入

  /// 写入配置。
  ///
  /// ⛔ **不碰密钥的值**，只把已经不存在的 providerId 从密钥表里剔掉。
  ///
  /// 密钥的写入归 [setApiKey] 独占。两件事分家不是洁癖：合在一起时，
  /// 「这次调用没带密钥」（对象是从 [config] 读出来的，`apiKey` 本来就是空串，
  /// 因为它不进 JSON）和「用户把密钥删了」长得一模一样。合并写法只能二选一——
  /// 要么保存一次设置就把密钥清空，要么用户永远删不掉那把 key。
  Future<void> saveConfig(AiProviderConfig next) async {
    await _config.setSetting(
      ConfigKey.AI_PROVIDER_PROFILES,
      AiProviderConfig.encode(next),
    );

    final alive = next.providers.map((p) => p.id).toSet();
    var keysChanged = false;
    // 带着密钥进来的（接入向导的新供应商就是这样）顺手落一下，省得调用方
    // 还要记着再调一次 setApiKey。
    for (final provider in next.providers) {
      final key = provider.apiKey.trim();
      if (key.isNotEmpty && _keys[provider.id] != key) {
        _keys[provider.id] = key;
        keysChanged = true;
      }
    }
    if (_keys.keys.any((id) => !alive.contains(id))) {
      _keys.removeWhere((id, _) => !alive.contains(id));
      keysChanged = true;
    }
    // ⛔ 密钥表没变就别落盘：[_flushKeys] 会把**每一把** key 重新 AES 加密一遍。
    // 模型选择弹窗是「勾一下写一次」的，连勾五个就是白加密五轮。
    if (keysChanged) await _flushKeys();
  }

  /// 改一条供应商的密钥。空串 ＝ **删掉它**。
  Future<void> setApiKey(String providerId, String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      _keys.remove(providerId);
    } else {
      _keys[providerId] = key;
    }
    await _flushKeys();
  }

  /// 把内存里的密钥表加密落盘。
  Future<void> _flushKeys() async {
    final stored = <String, String>{};
    for (final entry in _keys.entries) {
      final enc = await _cipher.encrypt(entry.value);
      if (enc != null) {
        stored[entry.key] = enc;
      } else {
        // 加密不可用（Web / 密钥文件坏了）：内存里那份照旧能用到进程结束，
        // 但不落盘——⛔ 绝不退回明文。
        LogUtils.w('加密供应商(${entry.key})密钥失败，未写入持久化密钥表', 'ConfigProfileStore');
      }
    }
    await _config.setSetting(ConfigKey.AI_PROVIDER_KEYS, jsonEncode(stored));
  }

  Future<void> saveBindings(Map<AiTask, String> next) => _config.setSetting(
    ConfigKey.AI_TASK_BINDINGS,
    AiTaskBindings.encode(next),
  );

  // ---------------------------------------------------------------- 迁移

  /// 返回「这次真的迁移了」。
  ///
  /// 两条历史路径：
  /// 1. `AI_PROVIDER_PROFILES` 是个 **JSON 数组** → 上一版的「一档案一模型」；
  /// 2. 它是空的 → 再上一版的 12 枚 `AI_TRANSLATION_*`。
  ///
  /// ⛔ 老的 ConfigKey **一个都不删**：迁移写坏了还能靠它们看出用户原本配的是
  /// 什么，而那几个键占的地方可以忽略不计。
  Future<bool> _migrateIfNeeded() async {
    final raw = (_config[ConfigKey.AI_PROVIDER_PROFILES] as String?)?.trim();

    if (raw != null && raw.isNotEmpty) {
      final decoded = _tryDecode(raw);
      if (decoded is! List) return false; // 已经是新结构
      final migrated = _fromLegacyProfileList(decoded);
      if (migrated == null) return false;
      await saveConfig(migrated.$1);
      await saveBindings(_remapBindings(migrated.$2));
      LogUtils.i(
        '已把 ${migrated.$1.providers.length} 份旧 AI 档案迁成「供应商 + 模型」',
        'ConfigProfileStore',
      );
      return true;
    }

    final legacy = _fromLegacyTranslationKeys();
    if (legacy == null) return false;
    await saveConfig(legacy);
    // 三个用途全绑到这一条：改造前就是所有用途共用同一份配置，迁移不该顺手
    // 改变任何行为。
    final only = legacy.models.first.key;
    await saveBindings({for (final task in AiTask.values) task: only});
    LogUtils.i('已完成旧版 AI 翻译配置的自动迁移', 'ConfigProfileStore');
    return true;
  }

  static Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// 旧绑定值是光秃秃的 providerId，新的是 `providerId/modelId`。
  Map<AiTask, String> _remapBindings(Map<String, String> providerToModelKey) {
    final old = AiTaskBindings.decode(
      _config[ConfigKey.AI_TASK_BINDINGS] as String?,
    );
    final next = <AiTask, String>{};
    old.forEach((task, providerId) {
      final key = providerToModelKey[providerId];
      if (key != null) next[task] = key;
    });
    return next;
  }

  /// 上一版的档案数组 → 新结构 + 「providerId → 那条模型的 key」对照表。
  ///
  /// ⭐ 迁移的关键判断：一个字段**该不该留成 delta**。
  /// 规则是「与目录里那条相同就不留」——相同就让它继承，以后目录更新自动到位；
  /// 不同才是用户真改过的东西，留着继续赢。这正是改造要治的病：改造前一切都是
  /// 快照，分不出「用户特意填的」和「当年预设就长这样」。
  (AiProviderConfig, Map<String, String>)? _fromLegacyProfileList(List raw) {
    final providers = <AiProvider>[];
    final models = <AiModel>[];
    final bindingMap = <String, String>{};

    for (final item in raw.whereType<Map>()) {
      final json = item.cast<String, dynamic>();
      final id = (json['id'] as String?)?.trim() ?? '';
      if (id.isEmpty) continue;

      final catalogId = _catalogIdForPreset(
        (json['presetId'] as String?) ?? '',
      );
      final catalog = AiCatalogService.providerOf(catalogId);

      final kind = AiProviderKind.normalize((json['kind'] as String?) ?? '');
      final name = (json['name'] as String?) ?? '';
      final baseUrl = (json['baseUrl'] as String?) ?? '';
      final structuredOutput = json['structuredOutput'] as bool?;

      providers.add(
        AiProvider(
          id: id,
          catalogId: catalogId,
          name: _deltaOrNull(name.isEmpty ? null : name, catalog?.name),
          kind: _deltaOrNull(kind, catalog?.kind),
          baseUrl: _deltaOrNull(
            baseUrl.isEmpty ? null : baseUrl,
            catalog?.baseUrl.isEmpty ?? true ? null : catalog!.baseUrl,
          ),
          structuredOutput: _deltaOrNull(
            structuredOutput,
            catalog?.structuredOutput,
          ),
          streaming: _deltaOrNull(json['streaming'] as bool?, true),
          headers: AiProvider.fromJson(json).headers,
          apiKey: (json['apiKey'] as String?) ?? '',
        ),
      );

      final model = AiModel(
        providerId: id,
        modelId: ((json['model'] as String?) ?? '').trim(),
        // ⛔ 这三项原样带过来，不做任何「顺手改好」：它们是老用户的真实设置。
        temperature: (json['temperature'] as num?)?.toDouble(),
        sendTemperature: json['sendTemperature'] as bool?,
        maxTokens: (json['maxTokens'] as num?)?.toInt(),
        reasoning: json['reasoning'] as bool?,
      );
      models.add(model);
      bindingMap[id] = model.key;
    }

    if (providers.isEmpty) return null;
    return (AiProviderConfig(providers: providers, models: models), bindingMap);
  }

  /// 与目录相同就不留 delta（＝以后跟着目录走）。
  static T? _deltaOrNull<T>(T? stored, T? catalogValue) {
    if (stored == null) return null;
    return stored == catalogValue ? null : stored;
  }

  /// 上一版的预设 id → 目录 id。认不出来的（`custom` / `legacy` / 空）没有可
  /// 继承的东西，返回空串。
  static String _catalogIdForPreset(String presetId) => switch (presetId) {
    'openai' || 'openai_reasoning' => 'openai',
    'anthropic' || 'anthropic_reasoning' => 'anthropic',
    'gemini' || 'gemini_reasoning' => 'gemini',
    'ollama' => 'ollama',
    'mistral' => 'mistral',
    'xai' => 'grok',
    'deepseek' || 'deepseek_reasoner' => 'deepseek',
    'openrouter' => 'openrouter',
    'siliconflow' => 'silicon',
    'zhipu' => 'zhipu',
    _ => '',
  };

  /// 再上一版：12 枚 `AI_TRANSLATION_*`。
  AiProviderConfig? _fromLegacyTranslationKeys() {
    T? get<T>(ConfigKey key) => _config[key] as T?;

    final apiKey = get<String>(ConfigKey.AI_TRANSLATION_API_KEY)?.trim() ?? '';
    final baseUrl =
        get<String>(ConfigKey.AI_TRANSLATION_BASE_URL)?.trim() ?? '';
    final model = get<String>(ConfigKey.AI_TRANSLATION_MODEL)?.trim() ?? '';
    if (apiKey.isEmpty && baseUrl.isEmpty && model.isEmpty) return null;

    final kind = AiProviderKind.normalize(
      get<String>(ConfigKey.AI_TRANSLATION_PROVIDER) ?? AiProviderKind.openai,
    );

    return AiProviderConfig(
      providers: [
        AiProvider(
          id: legacyProviderId,
          name: AiProviderKind.displayName(kind),
          kind: kind,
          baseUrl: baseUrl.isEmpty ? null : baseUrl,
          // 历史配置里没有这一项。保守给 false ＝「别试 json_schema，直接走
          // 提示词契约」：实测绝大多数中转会**静默忽略** json_schema，先试一次
          // 只是白等十几秒、白烧几百个 token。
          structuredOutput: false,
          streaming: get<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING),
          apiKey: apiKey,
        ),
      ],
      models: [
        AiModel(
          providerId: legacyProviderId,
          modelId: model,
          // ⛔ 这几个 `??` 是在读老用户的**真实配置**，换掉兜底值等于偷偷改了
          // 他原本的设置。别顺手「改好」。
          temperature: get<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.3,
          sendTemperature: get<bool>(ConfigKey.AI_TRANSLATION_SEND_TEMPERATURE),
          maxTokens: get<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 4096,
          reasoning: get<bool>(ConfigKey.AI_TRANSLATION_REASONING_MODEL),
        ),
      ],
    );
  }

  /// 从 12 枚 `AI_TRANSLATION_*` 迁过来的那条供应商的固定 id。
  static const String legacyProviderId = 'legacy';
}
