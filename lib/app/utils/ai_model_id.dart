/// 模型 id 的规范化 —— 把「服务端报给我们的名字」折回「目录里的那条」。
///
/// # 为什么非要这一层
///
/// 目录（`AiCatalogService`）只认规范 id（`gemini-2-5-pro`、`claude-opus-4-1`），
/// 而端点 `/models` 报上来的是五花八门的真名：
///
/// | 端点报的 | 目录里的 | 差在哪 |
/// |---|---|---|
/// | `gemini-2.5-pro` | `gemini-2-5-pro` | 版本号用 `.` 分隔 |
/// | `claude-opus-4-1-20250805` | `claude-opus-4-1` | 带发布日期 |
/// | `aihubmix-gpt-4o` | `gpt-4o` | 中转加了自己的前缀 |
/// | `deepseek-v3.2-thinking` | `deepseek-v3-2` | 变体后缀 |
/// | `qwen3-235b-a22b` | `qwen3` | 参数规模 |
/// | `gpt-4o:free` | `gpt-4o` | OpenRouter 的档位后缀 |
///
/// 不折的话，一个中转上几百个模型**一条都查不到能力**，界面上全是「未知」，
/// 而「这个模型会不会推理 / 吃不吃结构化输出」正是我们要拿来替掉那几个手动开关的。
///
/// # 出处
///
/// 规则移植自 Cherry Studio `@cherrystudio/provider-registry`（MIT）的
/// `src/utils/normalize.ts`。**刻意没移植的**：Bedrock 的跨厂商 ARN 那一整套
/// （`us.anthropic.claude-…-v1:0`）——我们把 bedrock 整条丢掉了，移过来是死代码。
///
/// ⚠️ 上游那些「为什么某一条**不在**表里」的注释一并抄了过来（`-medium` /
/// `mm-` / `non-think`）。它们记的是踩过的坑，删掉就会有人好心把那几条加回去。
library;

/// 中转/聚合器给模型加的自家前缀。命中一条就停（不叠着剥）。
const List<String> _aggregatorPrefixes = [
  'aihubmix-', 'aihub-', 'ahm-',
  'alicloud-', 'azure-', 'baidu-', 'cbs-', 'cc-', 'sf-', 's-', 'bai-',
  // ⛔ `mm-` **故意不在这里**：它是 MiniMax 的简写，归 _prefixExpansions 管
  // （`mm-m2-1` → `minimax-m2-1`）。当成聚合器前缀剥掉会先一步把 id 剥成
  // `m2-1`，MiniMax 再也认不回来。
  'web-',
  'deepinfra-', 'groq-', 'nvidia-', 'sophnet-',
  'zai-org-', // 必须排在 zai- 前面
  'zai-', 'lucidquery-', 'lucidnova-', 'lucid-', 'siliconflow-', 'chutes-',
  'huoshan-', 'meta-', 'cohere-', 'coding-', 'dmxapi-', 'perplexity-', 'ai21-',
  'openai-',
  'dmxapi_', 'aistudio_',
];

const List<(String, String)> _prefixExpansions = [('mm-', 'minimax-')];

const List<String> _colonSuffixes = [
  ':free',
  ':nitro',
  ':extended',
  ':beta',
  ':preview',
  ':thinking',
  ':exacto',
  ':latest',
  ':cloud',
];

const List<String> _hyphenSuffixes = [
  '-free', '-search', '-online', '-think', '-reasoning', '-classic',
  '-low', '-high', '-minimal',
  // ⛔ `-medium` **故意不在这里**：它是真的档位名（`mistral-medium`、
  // `devstral-medium`），当成推理强度剥掉会把档位吃掉，剩下个假词根。
  '-nothink', '-no-think', '-ssvip', '-thinking', '-nothinking',
  '-aliyun', '-huoshan', '-tee', '-cc', '-fw', '-di', '-t', '-reverse',
];

const List<String> _parenSuffixes = [
  '(free)',
  '(beta)',
  '(preview)',
  '(thinking)',
];

/// 剥后缀时要保护的复合词头：`…-no-think` 剥掉 `-think` 会剩下 `…-no`，
/// 那不是任何模型的名字。
const List<String> _protectedCompoundPrefixes = [
  'non',
  'no',
  'pre',
  'anti',
  'post',
];

const List<String> _quantizationSuffixes = [
  '-fp8',
  '-fp16',
  '-bf16',
  '-awq',
  '-int4',
  '-int8',
  '-gguf',
  '-gptq',
];

final RegExp _parameterSize = RegExp(
  r'-(\d+(?:\.\d+)?b)(?=-|$)',
  caseSensitive: false,
);

/// 结尾的发布日期戳：`-20250929` / `-2024-08-06` / `-250905` / `-0806` / `-2509`。
///
/// ⛔ 每一段都要求月份 01-12、日期 01-31，所以参数规模与版本号
/// （`glm-4-9b`、`qwen3-235b`）永远不会被误伤。
final RegExp _dateSnapshot = RegExp(
  r'-20\d{2}-(?:0[1-9]|1[0-2])-(?:[0-2]\d|3[01])$'
  r'|-20\d{2}(?:0[1-9]|1[0-2])(?:[0-2]\d|3[01])$'
  r'|-2\d(?:0[1-9]|1[0-2])(?:[0-2]\d|3[01])$'
  r'|-(?:0[1-9]|1[0-2])(?:[0-2]\d|3[01])$'
  r'|-2\d(?:0[1-9]|1[0-2])$',
);

/// 本机模型的冒号标签：`gpt-oss:20b` / `qwen2.5:7b` / `:q4_K_M`。
final RegExp _colonSizeTag = RegExp(
  r'^(?:\d+(?:[.x]\d+)*b(?:$|[-.])|q\d|iq\d|fp16|bf16|f16)',
  caseSensitive: false,
);

/// `3.5` / `3,5` / `3p5` / `3_5` → `3-5`。
final RegExp _versionSeparator = RegExp(r'(\d)[,._p](?=\d)');

String _stripAggregatorPrefixes(String id) {
  for (final prefix in _aggregatorPrefixes) {
    if (id.startsWith(prefix)) return id.substring(prefix.length);
  }
  return id;
}

String _expandKnownPrefixes(String id) {
  for (final (abbrev, canonical) in _prefixExpansions) {
    if (id.startsWith(abbrev)) return canonical + id.substring(abbrev.length);
  }
  return id;
}

String _stripVariantSuffixes(String id) {
  final colonIdx = id.lastIndexOf(':');
  if (colonIdx > 0 && _colonSuffixes.contains(id.substring(colonIdx))) {
    return id.substring(0, colonIdx);
  }
  for (final suffix in _hyphenSuffixes) {
    if (!id.endsWith(suffix)) continue;
    final remaining = id.substring(0, id.length - suffix.length);
    // 只在被保护的词头**自成一段**时跳过（`…-no-think` 留着），
    // 而不是它恰好是最后一个词的子串（`volcano-free`、`pino-search` 照剥）。
    final protected = _protectedCompoundPrefixes.any(
      (p) => remaining == p || remaining.endsWith('-$p'),
    );
    if (protected) continue;
    return remaining;
  }
  for (final suffix in _parenSuffixes) {
    if (!id.endsWith(suffix)) continue;
    var result = id.substring(0, id.length - suffix.length);
    if (result.endsWith(' ')) result = result.substring(0, result.length - 1);
    return result;
  }
  return id;
}

String _stripQuantization(String id) {
  for (final suffix in _quantizationSuffixes) {
    if (id.endsWith(suffix)) return id.substring(0, id.length - suffix.length);
  }
  return id;
}

String _stripDateSnapshot(String id) =>
    id.replaceAll(RegExp(r'@.*$'), '').replaceAll(_dateSnapshot, '');

/// 把 `gpt-oss:20b` 的冒号标签改写成目录的连字符拼法 `gpt-oss-20b`。
///
/// 只改写**规模/量化**标签；词标签（`:free`）原样留给 [_stripVariantSuffixes]。
String _colonSizeTagToHyphen(String id) {
  final colonIdx = id.lastIndexOf(':');
  if (colonIdx > 0 && _colonSizeTag.hasMatch(id.substring(colonIdx + 1))) {
    return '${id.substring(0, colonIdx)}-${id.substring(colonIdx + 1)}';
  }
  return id;
}

/// 把模型 id 折成目录里的规范形。
///
/// [keepParameterSize] 为真时**保留参数规模**：`gpt-oss-20b` 与 `gpt-oss-120b`
/// 保持可区分。查目录时先用它、再退回不带规模的那把钥匙——反过来会让
/// `:20b` 的拉取撞上同族的另一个规模。
///
/// ⛔ 剥后缀必须**迭代到不动点**：一个结尾日期会挡住它前面的变体后缀
/// （`…-thinking-2507` 要先去掉日期才看得见 `-thinking`），单趟剥出来的结果
/// 依赖顺序、而且不幂等。
String normalizeModelId(String modelId, {bool keepParameterSize = false}) {
  final parts = modelId.split('/');
  var name = parts.last.toLowerCase();
  name = _stripAggregatorPrefixes(name);
  name = _expandKnownPrefixes(name);
  if (keepParameterSize) name = _colonSizeTagToHyphen(name);

  for (;;) {
    var stripped = name;
    // 内层：变体 → 量化 → 日期，也要各自到不动点。
    for (;;) {
      final next = _stripDateSnapshot(
        _stripQuantization(_stripVariantSuffixes(stripped)),
      );
      if (next == stripped) break;
      stripped = next;
    }
    final next = keepParameterSize
        ? stripped
        : stripped.replaceAll(_parameterSize, '');
    if (next == name) break;
    name = next;
  }

  name = name.replaceAllMapped(_versionSeparator, (m) => '${m[1]}-');
  // 下划线是可互换的分隔符（HF 风格的 `bce-embedding-base_v1`）。
  // 目录里每条规范 id 都只用连字符，这里不折的话那些 id 永远查不到。
  return name.replaceAll('_', '-');
}
