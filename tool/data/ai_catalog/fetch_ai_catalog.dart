// AI 供应商目录的生成脚本。
//
// 上游是 Cherry Studio 的 `@cherrystudio/provider-registry`（**MIT**，见同目录
// SOURCES.md）。它维护着 64 家供应商的端点与 900+ 个模型的能力表；我们蒸馏出
// **dartantic 真跑得动**的那一部分，再盖上 `overrides.dart` 里我们自己实测出来的
// 端点知识。
//
// 为什么要这么一份东西：改造前预设是 15 条**写死在 Dart 里的快照**
// （`AiProviderPreset`），`toProfile()` 把 baseUrl / structuredOutput 拷进用户档案，
// 之后我们更新预设，老用户永远拿不到。目录 + 用户 delta 之后，
// 「某家换了地址」「出了新模型」重抓一次就到位，而且走 jsDelivr **不用发版**。
//
// 输入（二选一）：
//   --from <dir>   一份 provider-registry 的本地副本，读 <dir>/data/*.json
//   （不给就从 raw.githubusercontent.com 拉，走 HTTPS_PROXY/ALL_PROXY）
//
// 输出：
//   ai_catalog.json                         展开版，只为看 diff，不打包
//   ai_catalog.min.json                     紧凑版（CDN 源）
//   ../../../assets/data/ai_catalog.min.json  同步一份到打包资源
//
// 产物结构（键名缩写以省体积，解析见 lib/app/services/ai_catalog_service.dart）：
//   {"version":1,"rev":"<内容指纹>","builtAt":"<UTC>","count":653,
//    "providers":{"deepseek":{"n":"DeepSeek","k":"openai","u":"https://api.deepseek.com/v1",
//                             "so":1,"w":{"k":"<拿key的地址>","d":"<文档>","h":"<官网>"},
//                             "s":["deepseek-chat"]}},
//    "models":{"deepseek-chat":{"n":"DeepSeek V3","c":["fc","so"],"w":163840,"o":8192}}}
//
//   provider: n=名字 k=kind u=端点 so=端点认 json_schema(1/0,缺省=未知)
//             nk=不要密钥 nt=不吃 temperature lo=本机地址不走代理
//             w=相关网址 s=拉不到模型列表时的建议值
//   model:    n=名字 c=能力码 w=上下文窗口 o=输出上限
//   能力码:   fc=函数调用 rs=推理 so=结构化输出 vi=看图 fi=读文件
//
// 用法（仓库根目录执行）：
//   dart run tool/data/ai_catalog/fetch_ai_catalog.dart
//   dart run tool/data/ai_catalog/fetch_ai_catalog.dart --from /tmp/cherry-studio-ref/packages/provider-registry
import 'dart:convert';
import 'dart:io';

import '../../tag_overrides/overrides.dart' show buildStamp, contentRev;
import 'overrides.dart';

/// 产物结构版本。改了键名含义才动它。
const int kCatalogVersion = 1;

const String _rawBase =
    'https://raw.githubusercontent.com/CherryHQ/cherry-studio/main/packages/provider-registry/data';

/// 上游能力名 → 我们的能力码。不在表里的（image-generation / embedding / rerank …）
/// 一律丢掉：它们标记的是**非聊天**用途，而这个 App 只做聊天。
const Map<String, String> _capCodes = {
  'function-call': 'fc',
  'reasoning': 'rs',
  'structured-output': 'so',
  'image-recognition': 'vi',
  'file-input': 'fi',
};

/// 带这些能力就不是聊天模型，整条丢掉。
const Set<String> _nonChatCaps = {
  'embedding',
  'rerank',
  'image-generation',
  'video-generation',
  'audio-generation',
};

Future<void> main(List<String> args) async {
  final fromIndex = args.indexOf('--from');
  final localDir = fromIndex >= 0 && fromIndex + 1 < args.length
      ? args[fromIndex + 1]
      : null;

  final providersRaw = await _load('providers.json', localDir);
  final modelsRaw = await _load('models.json', localDir);

  final providersDoc = jsonDecode(providersRaw) as Map<String, dynamic>;
  final modelsDoc = jsonDecode(modelsRaw) as Map<String, dynamic>;

  final models = _distillModels(
    (modelsDoc['models'] as List).cast<Map<String, dynamic>>(),
  );
  final providers = _distillProviders(
    (providersDoc['providers'] as List).cast<Map<String, dynamic>>(),
    (modelsDoc['models'] as List).cast<Map<String, dynamic>>(),
    models.keys.toSet(),
  );

  // 别名只保留**指得到东西**的那些：指向一条已被丢掉的模型（比如只做图像生成的）
  // 的别名留着只会让查找多绕一圈再落空。
  final aliases = <String, String>{
    for (final e in kModelAliases.entries)
      if (models.containsKey(e.value)) e.key: e.value,
  };

  // ⛔ rev 只按**载荷**算，不含 builtAt/upstream——否则每次重跑都换指纹，
  // App 会以为词库更新了，git 里也多一条无意义的 diff。
  final payload = {
    'providers': providers,
    'models': models,
    if (aliases.isNotEmpty) 'aliases': aliases,
  };
  final rev = contentRev(payload);

  final dir = File(Platform.script.toFilePath()).parent.path;
  final out = <String, dynamic>{
    'version': kCatalogVersion,
    'rev': rev,
    'builtAt': buildStamp('$dir/ai_catalog.min.json', rev),
    'count': providers.length + models.length,
    'upstream': {
      'source': 'CherryHQ/cherry-studio @ packages/provider-registry (MIT)',
      'providers': providersDoc['version'],
      'models': modelsDoc['version'],
    },
    ...payload,
  };

  File('$dir/ai_catalog.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));

  final min = jsonEncode(out);
  File('$dir/ai_catalog.min.json').writeAsStringSync(min);
  File('$dir/../../../assets/data/ai_catalog.min.json').writeAsStringSync(min);

  stdout
    ..writeln('供应商 ${providers.length} 家，模型 ${models.length} 条')
    ..writeln('rev=$rev  ${(min.length / 1024).toStringAsFixed(1)} KB')
    ..writeln('已写入 ai_catalog.min.json 与 assets/data/ai_catalog.min.json');
}

// --------------------------------------------------------------------- 取数

Future<String> _load(String name, String? localDir) async {
  if (localDir != null) {
    final file = File('$localDir/data/$name');
    if (!file.existsSync()) {
      throw StateError('找不到 ${file.path}');
    }
    return file.readAsStringSync();
  }
  // dart:io 的 findProxyFromEnvironment 只认小写的 `https_proxy`；大写那两个
  // 更常见（Clash 之流写的就是大写），这里一并喂进去。
  final proxy =
      Platform.environment['HTTPS_PROXY'] ??
      Platform.environment['https_proxy'] ??
      Platform.environment['ALL_PROXY'] ??
      '';
  final client = HttpClient()
    ..findProxy = (uri) => HttpClient.findProxyFromEnvironment(
      uri,
      environment: {'https_proxy': proxy},
    );
  try {
    final req = await client.getUrl(Uri.parse('$_rawBase/$name'));
    final res = await req.close();
    if (res.statusCode != 200) {
      throw StateError('拉取 $name 失败：HTTP ${res.statusCode}');
    }
    return res.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

// ------------------------------------------------------------------- 模型表

Map<String, dynamic> _distillModels(List<Map<String, dynamic>> raw) {
  final out = <String, dynamic>{};
  for (final m in raw) {
    final id = (m['id'] as String?)?.trim() ?? '';
    if (id.isEmpty) continue;

    final caps = ((m['capabilities'] as List?) ?? const []).cast<String>();
    if (caps.any(_nonChatCaps.contains)) continue;

    final codes = <String>{
      for (final c in caps)
        if (_capCodes[c] != null) _capCodes[c]!,
      ...?kModelCapsPatch[id],
    }.toList()..sort();

    out[id] = <String, dynamic>{
      if ((m['name'] as String?)?.isNotEmpty == true) 'n': m['name'],
      if (codes.isNotEmpty) 'c': codes,
      if (m['contextWindow'] != null) 'w': m['contextWindow'],
      if (m['maxOutputTokens'] != null) 'o': m['maxOutputTokens'],
    };
  }
  return out;
}

// ----------------------------------------------------------------- 供应商表

Map<String, dynamic> _distillProviders(
  List<Map<String, dynamic>> raw,
  List<Map<String, dynamic>> rawModels,
  Set<String> keptModelIds,
) {
  // 供应商 id → 它自家的模型（`ownedBy` 对得上的）。中转不会命中，
  // 而中转的 /models 接口本来就都能用，拉得到。
  final ownedBy = <String, List<String>>{};
  for (final m in rawModels) {
    final owner = (m['ownedBy'] as String?)?.trim().toLowerCase();
    final id = (m['id'] as String?)?.trim() ?? '';
    if (owner == null || owner.isEmpty || !keptModelIds.contains(id)) continue;
    (ownedBy[owner] ??= []).add(id);
  }

  final out = <String, dynamic>{};
  for (final p in raw) {
    final id = (p['id'] as String?)?.trim() ?? '';
    if (id.isEmpty || kDropProviders.containsKey(id)) continue;

    // 凭据不是 API key（OAuth / 外部 CLI）的整条丢掉。
    final auth = ((p['authMethods'] as List?) ?? const ['api-key'])
        .cast<String>();
    final authOptional = p['authOptional'] == true;
    if (!auth.contains('api-key') && !authOptional) continue;

    final endpoints = (p['endpointConfigs'] as Map?)?.cast<String, dynamic>();
    if (endpoints == null || endpoints.isEmpty) continue;

    final kind = kKindOverrides[id] ?? _kindOf(endpoints);
    if (kind == null) continue;

    final baseUrl = _baseUrlFor(id, kind, endpoints);
    // ⛔ 只有「需要地址的 kind」才按空地址丢：anthropic / mistral / xai 的
    // dartantic provider **根本不收 baseUrl**，它们恒为空是正常的，不是缺配置。
    // （第一版漏了这个条件，把 Anthropic 自己给丢了。）
    if (_needsBaseUrl(kind) &&
        baseUrl.isEmpty &&
        !kLocalProviders.contains(id)) {
      continue;
    }

    final site = ((p['metadata'] as Map?)?['website'] as Map?)
        ?.cast<String, dynamic>();
    final apiKeyUrl = kApiKeyUrlOverrides[id] ?? site?['apiKey'];
    final web = <String, dynamic>{
      if (apiKeyUrl != null) 'k': apiKeyUrl,
      if (site?['docs'] != null) 'd': site!['docs'],
      if (site?['official'] != null) 'h': site!['official'],
    };

    final suggested = [...?ownedBy[id]]..sort();

    out[id] = <String, dynamic>{
      'n': kNameOverrides[id] ?? p['name'] ?? id,
      'k': kind,
      if (baseUrl.isNotEmpty) 'u': baseUrl,
      if (kStructuredOutputSupport[id] != null)
        'so': kStructuredOutputSupport[id]! ? 1 : 0,
      if (authOptional) 'nk': 1,
      if (kNoTemperature.contains(id)) 'nt': 1,
      if (kLocalProviders.contains(id)) 'lo': 1,
      if (web.isNotEmpty) 'w': web,
      if (suggested.isNotEmpty) 's': suggested.take(8).toList(),
    };
  }
  return out;
}

/// 按端点类型判 kind。返回 null ＝ dartantic 驱动不了这一家。
///
/// ⛔ 顺序要紧：一堆家同时挂着 anthropic-messages 和 openai 兼容端点，
/// 而我们的 `AnthropicProvider` **不收 baseUrl**（dartantic 的构造函数就没这个
/// 参数），走它等于把请求发去官方 api.anthropic.com。所以 openai 那条优先。
String? _kindOf(Map<String, dynamic> endpoints) {
  if (endpoints.containsKey('openai-chat-completions')) return 'openai';
  if (endpoints.containsKey('openai-responses')) return 'openai';
  if (endpoints.containsKey('anthropic-messages')) return 'anthropic';
  if (endpoints.containsKey('google-generate-content')) return 'google';
  if (endpoints.containsKey('ollama-chat')) return 'ollama';
  return null;
}

String _baseUrlFor(String id, String kind, Map<String, dynamic> endpoints) {
  final override = kBaseUrlOverrides[id];
  if (override != null) return override;

  String pick(String key) =>
      ((endpoints[key] as Map?)?['baseUrl'] as String?)?.trim() ?? '';

  switch (kind) {
    // ⛔ dartantic 的 AnthropicProvider / MistralProvider / XAIProvider 都不收
    // baseUrl，填了也是白填，不如不写进目录让 UI 把那一栏收起来。
    case 'anthropic':
    case 'mistral':
    case 'xai':
      return '';
    case 'google':
      return pick('google-generate-content');
    case 'ollama':
      return pick('ollama-chat');
    default:
      final raw = pick('openai-chat-completions').isNotEmpty
          ? pick('openai-chat-completions')
          : pick('openai-responses');
      return _normalizeOpenAiBase(raw);
  }
}

/// 这个 kind 需不需要端点地址。
///
/// dartantic 3.4.2 里只有 `OpenAIProvider` / `GoogleProvider` / `OllamaProvider`
/// 的构造函数收 `baseUrl`；另外三家压根没这个参数。
bool _needsBaseUrl(String kind) =>
    kind == 'openai' || kind == 'google' || kind == 'ollama';

/// OpenAI 兼容端点的地址规范化。
///
/// ⛔ dartantic 把 baseUrl **原样当前缀**拼上 `/chat/completions`，所以少一个
/// `/v1` 就是 404——而上游登记的地址多数是不带版本段的裸域名（它们的 SDK 自己拼）。
/// 规则：去掉结尾的 `/`；路径里已经有 `/v<数字>` 段就原样留着，否则补 `/v1`。
/// 补错的那几家写在 `kBaseUrlOverrides` 里逐条覆盖。
String _normalizeOpenAiBase(String raw) {
  var url = raw.trim();
  if (url.isEmpty) return '';
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) return url;
  final hasVersion = uri.pathSegments.any(
    (s) => RegExp(r'^v\d+([a-z]+\d*)?$').hasMatch(s),
  );
  return hasVersion ? url : '$url/v1';
}
