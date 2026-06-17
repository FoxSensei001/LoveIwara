# Iwara Tags 本地化适配工具包 (Iwara Tags Localization Toolkit)

本文件夹包含了 Iwara 平台的标签抓取工具以及利用 AI 产出的多语言（简体中文、繁体中文、日语、英语）本地化映射文件。

## 目录结构

- [fetch_iwara_tags.dart](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/fetch_iwara_tags.dart)：用于从 Iwara API 自动抓取全部标签并保存为本地 Snapshot 的 Dart 命令行工具。
- [fetch_iwara_tags_web.html](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/fetch_iwara_tags_web.html)：抓取标签的网页端可视化辅助工具。
- [iwara_tags.json](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/iwara_tags.json)：自动抓取下来的原始标签元数据文件（包含 2669 个标签）。
- [iwara_tags_localized.json](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/iwara_tags_localized.json)：由 AI 翻译生成的格式化多语言映射文件（包含 A-Z 字母排序的美化排版）。
- [iwara_tags_localized.min.json](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/iwara_tags_localized.min.json)：去除了所有换行、空格及无用空白的最轻量压缩版映射文件，最大化节省网络与前端加载空间效率。
- [iwara_tags.min.json](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/iwara_tags.min.json)：**App / CDN 实际消费的合并产物**。把原始元数据（`type` / `sensitive`）与四语言译名合并为一份紧凑文件，供客户端做「展示本地化」与「本地搜索」。
- [build_localized_min.dart](file:///Users/chenguanxi/IdeaProjects/LoveIwara/tool/data/iwara_tags/build_localized_min.dart)：合并脚本，由前两个文件生成 `iwara_tags.min.json`，并同步一份到打包资源 `assets/data/iwara_tags.min.json`。

---

## App 集成（展示本地化 + 搜索）

合并产物 `iwara_tags.min.json` 被客户端以两种渠道获取：

1. **打包兜底**：复制到 `assets/data/iwara_tags.min.json`，离线即可用。
2. **CDN 热更新**：经 jsDelivr 指向本仓库快照，无需发版即可更新词库：
   `https://cdn.jsdelivr.net/gh/FoxSensei001/LoveIwara@master/tool/data/iwara_tags/iwara_tags.min.json`

运行时由 `lib/app/services/tag_localization_service.dart`（`TagLocalizationService`）统一处理：

- **内存策略**：内存里**只物化「当前语言译名 + 原始 key + 评级位」**，不保留全部四语言；切换语言时从数据源重建，降低内存占用。
- **展示**：所有渲染 `tag.id` 的位置改为展示「当前语言环境译名」（译名与原始 key 不同的 chip 悬浮可见原始 key）。
- **搜索**：标签搜索支持「当前语言译名 / 原始 key」双向匹配（例如输入「母亲」或 `mother` 都能命中），本地命中结果合并到接口结果前。

### 产物结构（键名缩写以省体积）

```jsonc
{
  "version": 1,
  "count": 2669,
  "tags": {
    "mother": {
      "y": "general",          // type
      "s": 0,                   // sensitive，0/1
      "n": { "zh-CN": "母亲", "zh-TW": "母親", "ja": "母親", "en": "Mother" }
    }
  }
}
```

> 修改了 `iwara_tags_localized.json` 后，请重跑 `dart run tool/data/iwara_tags/build_localized_min.dart` 以同步 `iwara_tags.min.json` 与打包资源，再提交。

---

## 本地化翻译如何利用 AI 产出

Iwara 标签包含了 2669 个错综复杂的二次元名词、小众动漫术语、敏感/成人向专有名词以及 MMD/3D 模型的特定创作者姓名，传统机器翻译（如 Google Translate Web API）在处理它们时会表现得极其糟糕（例如将角色名 `inui_toko` 机翻为“乾东子”，或将 `firefly` 机翻为“萤火虫”）。

为了生成社区级、专业水准的翻译，我们采用了 **AI 并发翻译与多源校对架构**：

1. **分块切割**：将 2669 个标签按字母顺序切割成 7 个独立的文本分块（每个约 380 个标签）。
2. **并发子代理**：并行启动 7 个专门针对 **ACG (动漫游戏) / Vtuber (虚拟主播) / 3D 动作 / NSFW 成人内容** 优化的 AI 翻译子代理进程。
3. **世界知识库映射**：每个子代理根据自身庞大的跨语言知识库，将标签 ID 精准翻译为简中、繁中、日文及英文。
4. **数据归集与排序**：收集全部 7 个子代理写出的临时 JSON 结果，通过 Python 脚本进行去重、完备性校验并按照字母顺序（A-Z）归档合并，最后生成紧凑版。

---

## 为什么需要全面世界知识与实时搜索的模型

在翻译 Iwara 标签时，普通模型会遇到以下瓶颈：

1. **冷门与极新角色**：例如 *Wuthering Waves* (鸣潮) 3.0 的新角色 `mornye` (墨霓)，或者 *Zenless Zone Zero* (绝区零) 2.7 的 `cissia` (希希芙)、`luciana_de_montefio` 等。缺乏实时世界知识的模型会由于数据截止日期而胡乱翻译。
2. **小众 Vtuber 角色**：例如 Hololive DEV_IS 旗下新组 FLOW GLOW 的成员 `kikirara_vivi` (绮々罗々ヴィヴィ)。
3. **特定 MMD/3D 创作者**：标签中有如 `mitsuda_oshiki` 等 MMD 常用模型或动作的创作者名字，如果直接机翻会完全丧失原本的名称意义，而必须保留其原本的命名或做专业惯用转译。
4. **复杂的 NSFW 暗语**：大量的敏感体位、缩写（如 `cbt`、`fgo`、`bb`、`creampie` 等）需要模型能准确区分通用语境和特定成人动漫社群语境。

### 为什么谷歌模型（Gemini）和能力在此处最为合适

在这个任务中，**谷歌（Google）的模型与搜索引擎能力展现出了巨大的天然优势**：

- **强大的实时 Web 搜索**：通过内置的 Web Search 接口，AI 子代理在遇到冷门创作者、极新实装游戏角色或日本小众同人社团时，能够迅速通过网络检索，找到官方或粉丝社群的真实叫法（例如通过检索发现 `cielle` 在 Strinova 语境下应该翻译为“希尔”或“心绘”）。
- **卓越的多语言与跨文化语料**：谷歌模型拥有广泛的中、日英多语言平行语料，使得角色名假名（如 `がうる・ぐら`）、英文（`Gawr Gura`）与中文译名（`噶呜·古拉`）之间建立了极其扎实的对齐关系。
- **精准的上下文敏感度**：能够精准判断一个词究竟是指地理名词、普通英语单词，还是指特定的动漫角色或特定的成人姿势，从而给出最符合中文宅圈和国际社群语境的最佳翻译。

---

## 我们的二次全量纠错审查经历

为了确保翻译的高质量并杜绝 AI 的盲目猜测或粗糙音译，我们对全部 2669 个已生成的本地化翻译进行了全量二次复查，并成功修正了以下典型翻译偏差：

- **防止逐字硬译 / 社区人名对齐**：将 `amatsuka_uto` 从机翻“天鬼宇都”纠正为 **“天使Uto”**；将 `mornye` 纠正为《鸣潮》官方译名 **“莫宁”**（原音译为“莫妮”）；将 `tendo_kei` 由机翻的“天童圭”等纠正为《碧蓝档案》社区惯用的 **“天童kei”**。
- **台湾繁中译名本地化（洗礼）**：将 `overwatch` 修正为 **“鬥陣特攻”**（非“守望先鋒”繁体字）；将 `my_little_pony` 修正为 **“彩虹小馬”**（非“小馬寶莉”）；将 `chainsaw_man` 修正为 **“鏈鋸人”**；将 `fallout` 修正为 **“異塵餘生”**。
- **挖掘特定黑话与同人词意**：将 `x_ray` 从普通直译“透视”修正为 NSFW 专用术语 **“断面图”**；将 `parody` 概念从“恶搞”更正为同人库专用的 **“原作”**。

---

## 🚀 专防 AI 盲目自信/偷懒的 ACG 标签翻译提示词

在下一次翻译或校对长列表的 ACG/Vtuber 标签及小众社群词汇时，可直接将以下 Prompt 复制发送给大语言模型，以最大程度地规避 AI 的“幻觉”、“自负式音译”与“中途截断/偷懒”：

```text
你是一个极其严谨、精通二次元（ACG/Vtuber/同人插画/MMD）及绅士（NSFW）文化语境的高级翻译校对专家。
现在需要你将以下一批标签 ID 进行多语言本地化映射（支持 zh-CN 简中, zh-TW 繁中, ja 日语, en 英语）。

在翻译时，你必须严格遵守以下“反盲目自信、反偷懒、反降级”的三大铁律：

【铁律一：严防盲目自信（禁止拍脑袋音译）】
1. ACG/Vtuber 角色名往往有其固定且唯一的社区通译或官方汉字。你绝对不能“想当然”地进行字面音译！
   * 错误典型：将 `amatsuka_uto` 翻成“天鬼宇都” (X) -> 正确为“天使Uto”或“天使うと” (O)。
   * 错误典型：将 `mornye` 翻成“莫妮” (X) -> 官方正确为《鸣潮》角色的“莫宁” (O)。
   * 错误典型：将 `tendo_kei` 翻成“天童圭” (X) -> 社区正确为《碧蓝档案》的“天童kei” (O)。
2. 对于任何不确定的拼写或生僻的拼音/Romaji 连接词，你必须通过实时搜索（或自我质疑）确认其所属的 IP 和官方角色名，严禁使用粗糙的字面拼音或音译。
3. 警惕带有假汉字或日文叠词符号的角色名。例如 `yuzuriha_maimai`（《佐贺偶像是传奇》的楪舞々），除了姓氏必须翻译为正确的“楪”外，日文叠字符号“々”在中文中也必须正确展开为“舞”（即“楪舞舞”），而非保留日语符号。

【铁律二：严防机翻与语境错位】
1. 深入同人与 NSFW 社区特定语境。很多英文词在日常语境和同人语境下意思完全不同：
   * 错误典型：将 `parody` 翻成“恶搞” (X) -> 在同人/插画库中它特指“原作”或“所属原作 IP” (O)。
   * 错误典型：将 `x_ray` 翻成“透视” (X) -> 在 NSFW 动作/插画中它特指“断面图” (O)。
   * 错误典型：将 `missionary` 翻成“传教士体位” (X) -> 在 ACG/绅士界通译为更自然的“正常位” (O)。
2. 台湾繁体中文 (zh-TW) 必须符合当地的官方译名习惯：
   * 必须使用当地官方译名：如 “鏈鋸人” (O) / “彩虹小馬” (O) / “電馭叛客：邊緣行者” (O) / “惡魔獵人” (O) / “異塵餘生” (O)。

【铁律三：严防偷懒与格式破损】
1. 无论标签列表有多长，你必须“无一遗漏”地完整翻译每一个条目。绝对禁止中途输出“...”（省略号）或者在未完成时截断输出。
2. 保持纯净的输出格式。只输出合法的、平铺的 JSON 对象，不得混入任何 markdown code block 包装，确保解析器能直接解析。

待翻译的标签数据：
[粘贴你的标签数据]
```

