# 人工修正层（overrides）

两份标签词库的译名都是 **AI 批量产出**的，随时可能被整批重跑覆盖。
任何人工采纳的修正如果直接写回 `*_localized.json`，下一次重译就会**静默消失**——
在沙滩上写字。所以人工修正单独存一层，由合并脚本最后盖上去。

```
原始元数据  →  AI 译名（*_localized.json）  →  overrides.json
   谁改：抓取脚本        谁改：AI 批量重译          谁改：人（你 / 采纳的用户提交）
   会被覆盖              会被覆盖                   永不被覆盖
```

## 文件位置

| 词库 | overrides 路径 | 主键 |
|---|---|---|
| iwara | `tool/data/iwara_tags/overrides.json` | tag id，如 `mother` |
| oreno3d | `tool/data/oreno3d_tags/overrides.json` | `type/id`，如 `characters/3872` |

两份分开，因为两边结构不同（一个平铺、一个分三类），硬合只会到处写 if。

## Schema

```jsonc
{
  "schema": 1,
  "entries": {
    "characters/2215": {
      // 只列改过的语言。没列出的继续走 AI 译名，AI 后续改进还进得来。
      "n": { "zh-CN": "小萤", "zh-TW": "小螢" },

      // 元数据覆盖（目前只有 iwara 侧的 type / sensitive 用得上）
      "meta": { "sensitive": 1 },

      // 改动当时 AI 译名的值，用于重译后的冲突检测。
      // 上游变了 → 进 needs_review.json 报出来，但**修正照常生效**。
      "prev": { "zh-CN": "流萤" },

      "src": "manual",              // manual | user | ai
      "by": "dev",                  // 贡献者标识，可留空
      "ref": ["https://danbooru.donmai.us/wiki_pages/..."],  // 依据来源
      "at": "2026-08-25",
      "note": "スプラトゥーン 的 ホタル，与星铁的 ホタル 同名不同人"
    }
  }
}
```

**为什么按语言逐个覆盖**：整条覆盖意味着你只想改一个 zh-CN，却把另外三语言也钉死，
AI 之后再也改进不进来。四语言全管的前提下这一条尤其要紧。

## 合并语义

- `n[lang]` 逐语言胜出；未列出的语言不受影响
- `meta` 整块胜出原始元数据
- `prev[lang]` 存在且与当前 AI 值不一致 → **仍然应用**，同时写进 `needs_review.json`
  （静默丢弃会让用户看到的译名突然退回旧值；静默保留则让你永远不知道底下变了）
- 主键在原始数据里已不存在 → 报成孤儿（`orphanKeys`），不静默丢弃

## rev：内容指纹

产物顶层的 `rev` 是全量内容的 FNV-1a 指纹，**只改译名、条数不变时它也会变**。

存在的理由：App 现有实现用「条目数变了才重建词库」的启发式判断更新
（`tag_localization_service.dart` / `oreno3d_localization_service.dart` 的 `_refreshFromCdn`），
纯译名修正判不出来，要等下次冷启动才生效。`rev` 是给运行时换掉那个启发式用的。

> 产物 `version` 已升到 2。旧版 App 会忽略 `rev` 与 `version`，行为不变（向后兼容）。

## 闸门

`test/tool/tag_overrides_test.dart` 四道，对应四个已经发生过或必然会再发生的问题：

1. 同名词条必须各自独立（迁移前 38 组共享译名，结构上无法分别修正）
2. 人工修正不会被 AI 重译覆盖，且只覆盖列出的语言
3. 上游变化必须被报出来，不能静默；孤儿 override 同理
4. `rev` 必须随内容变化、内容不变时保持稳定

```bash
flutter test test/tool/tag_overrides_test.dart
```
