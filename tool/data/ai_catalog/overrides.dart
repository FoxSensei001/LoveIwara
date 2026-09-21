// AI 供应商目录的**我们自己那一层**。
//
// 上游（Cherry Studio 的 `@cherrystudio/provider-registry`，MIT）负责「这家在哪儿、
// 这个模型有什么能力」；这个文件负责「**用 dartantic 打过去**会怎么样」——那是上游
// 没有、也不该有的知识。
//
// ⛔ 重抓上游时这一层不会被覆盖：`fetch_ai_catalog.dart` 总是先蒸馏上游、再把这里的
// 覆盖盖上去。所以我们实测出来的东西写在**这里**，不要去改产物 JSON。

/// 整条丢掉的供应商。
///
/// 判据只有一条：**dartantic 驱动不了**。列出来让用户点、点完发现跑不起来，
/// 比不列出来糟得多。
const Map<String, String> kDropProviders = {
  // 凭据在外部 CLI / OAuth 里，我们拿不到也不该拿
  'claude-code': '凭据在 Claude Code CLI 的存储里',
  'grok-cli': 'OAuth 登录态',
  'openai-codex': 'OAuth 登录态',
  'copilot': '要先用 GitHub token 换一枚短期 token，dartantic 没有这条路',
  'cherryin': 'Cherry Studio 自家中转，要他们的登录态',

  // 鉴权方式 dartantic 不支持
  'aws-bedrock': 'AWS SigV4 签名',
  'vertexai': 'GCP 服务账号 / ADC',
  'azure-openai': '部署名 + api-version 走的是另一套 URL 拼法',

  // 没有聊天模型，只做 embedding / rerank
  'jina': '只做 rerank / embedding',
  'voyageai': '只做 embedding',
};

/// 上游 provider id → 我们的 kind（`AiProviderKind`）。
///
/// 不在这张表里的按端点类型自动判（见 `fetch_ai_catalog.dart` 的 `_kindOf`）。
/// 这里列的都是**自动判会判错**的：它们同时挂着 openai 兼容端点，会被吃成 `openai`，
/// 而 dartantic 对它们有原生 provider（原生那条路能拿到 thinking / 正确的
/// maxTokens 字段名）。
const Map<String, String> kKindOverrides = {
  'ollama': 'ollama',
  'mistral': 'mistral',
  'grok': 'xai',
  'anthropic': 'anthropic',
  'gemini': 'google',
};

/// 端点地址的**逐条**覆盖。
///
/// 一般不需要：`_normalizeOpenAiBase` 会按「路径里没有 `/v<数字>` 段就补 `/v1`」
/// 自动补。这里只放那条规则会补错的。
const Map<String, String> kBaseUrlOverrides = {
  // ⛔ Perplexity 的聊天端点就是 `https://api.perplexity.ai/chat/completions`，
  // **没有 /v1**。补上去是 404。
  'perplexity': 'https://api.perplexity.ai',
  // 上游只登记了 Responses 端点（没有 baseUrl 里的 /v1）；我们走的是
  // chat/completions 那条，必须带 /v1。
  'openai': 'https://api.openai.com/v1',
};

/// 这家端点**真的**认 `response_format: json_schema` 吗。
///
/// ⭐ 这是本文件存在的头号理由。上游 models.json 的 `structured-output` 说的是
/// **模型**支不支持；而 2026-09-20 实测挖出来的问题是**端点**静默忽略它——带
/// `strict:true` 的 json_schema 发过去，HTTP 200、18 秒、626 个 completion token、
/// 回一整段散文，一个字的 JSON 都没有，不报错不警告。换模型一样 → 是中转层面的。
///
/// 所以这里只给**有证据**的那几家 true。其余一律不写（＝未知），由接入向导那一步
/// 真发一次请求去探，探到了就落到用户的 delta 上。
/// ⛔ 不要凭"它是大厂"就填 true：填错的代价是用户每次 AI 搜索白等十几秒再降级。
const Map<String, bool> kStructuredOutputSupport = {
  // 官方三家：Anthropic / Google 是靠工具调用编排实现的，OpenAI 是原生
  // response_format。这三条有实测。
  'openai': true,
  'anthropic': true,
  'gemini': true,
  // DeepSeek 官方端点实测可用（非中转）。
  'deepseek': true,
};

/// 已知不接受自定义 `temperature` 的家。
///
/// ⛔ xAI 是**发了就抛 UnsupportedError**，不是忽略——夹不住的话选了它的人每一次
/// 调用都是异常。出处：dartantic_ai 3.4.2 `providers/xai_provider.dart:45`。
const Set<String> kNoTemperature = {'grok'};

/// 跑在本机、不该走代理的家。
///
/// Ollama / LM Studio 这类是回环地址，套上用户配的代理反而不通。
const Set<String> kLocalProviders = {
  'ollama',
  'lmstudio',
  'omlx',
  'ovms',
  'gpustack',
};

/// 供应商显示名的覆盖。
///
/// 上游有几条是小写的裸 id（`deepseek` / `doubao` / `nvidia` / `zai`），直接摆给
/// 用户看不像个产品名。只改这几条，其余沿用上游。
const Map<String, String> kNameOverrides = {
  'deepseek': 'DeepSeek',
  'doubao': '豆包 Doubao',
  'nvidia': 'NVIDIA NIM',
  'zai': 'Z.AI',
  'zhipu': '智谱 GLM',
  'silicon': 'SiliconFlow 硅基流动',
  'dashscope': '阿里云百炼 DashScope',
  'modelscope': '魔搭 ModelScope',
  'qiniu': '七牛云',
  'baidu-cloud': '百度千帆',
  'xirang': '天翼云息壤',
  'gemini': 'Google Gemini',
  'grok': 'xAI Grok',
};

/// 「去这里拿 key」链接的覆盖。
///
/// ⛔ 上游有推广返利链接（硅基流动那条 `/i/d1nTBKXU` 是 Cherry Studio 的邀请码，
/// 他们自己还有一条测试盯着它）。**别人的返利码不该跟着我们的包发出去**——
/// 用户点一次就算在他们头上了。一律换成该站的裸注册/控制台地址。
/// 重抓时这张表会盖掉上游值，所以上游换了邀请码也不会漏进来。
const Map<String, String> kApiKeyUrlOverrides = {
  'silicon': 'https://cloud.siliconflow.cn/account/ak',
};

/// 服务端的模型名 → 目录里的规范 id。
///
/// ⭐ 绝大多数差异（`gemini-2.5-pro` → `gemini-2-5-pro`、
/// `claude-opus-4-1-20250805` → `claude-opus-4-1`）由 `normalizeModelId` 自动抹平，
/// **不要**往这里加。这张表只放**规范化抹不平的真别名**——同一个模型，两个名字
/// 长得不像。
const Map<String, String> kModelAliases = {
  // DeepSeek 官方端点把 R1 叫 reasoner、把 V3 叫 chat。
  'deepseek-reasoner': 'deepseek-r1',
};

/// 模型能力的补丁：上游漏了或和我们实测不符的。
///
/// 形如 `'模型id': {'加的能力', ...}`。目前为空——留着是因为迟早会有一条，
/// 而没有这个口子时人会直接去改产物 JSON（重抓就没了）。
const Map<String, Set<String>> kModelCapsPatch = {};
