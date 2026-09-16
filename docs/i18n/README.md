# 多语言支持状态 (i18n Coverage)

本文件是应用当前翻译情况的索引，回答两个问题：**界面支持哪些语言**、**标签词库支持哪些语言、为什么不是同一份清单**。

## 1. 界面语言（12 门）

基准语言是 **en**（`lib/i18n/en.i18n.yaml`），其余语言在同一份 key 集合上翻译。语言选择器里的实际显示顺序见
[`lib/utils/common_utils.dart`](../../lib/utils/common_utils.dart) 的 `appLocaleDisplayOrder`：

| 语言 | 代码 | 资源文件 |
|---|---|---|
| English | `en` | [`lib/i18n/en.i18n.yaml`](../../lib/i18n/en.i18n.yaml) |
| 日本語 | `ja` | [`lib/i18n/ja.i18n.yaml`](../../lib/i18n/ja.i18n.yaml) |
| 简体中文 | `zh-CN` | [`lib/i18n/zh-CN.i18n.yaml`](../../lib/i18n/zh-CN.i18n.yaml) |
| 繁體中文 | `zh-TW` | [`lib/i18n/zh-TW.i18n.yaml`](../../lib/i18n/zh-TW.i18n.yaml) |
| 한국어 | `ko` | [`lib/i18n/ko.i18n.yaml`](../../lib/i18n/ko.i18n.yaml) |
| ภาษาไทย | `th` | [`lib/i18n/th.i18n.yaml`](../../lib/i18n/th.i18n.yaml) |
| Bahasa Indonesia | `id` | [`lib/i18n/id.i18n.yaml`](../../lib/i18n/id.i18n.yaml) |
| Tiếng Việt | `vi` | [`lib/i18n/vi.i18n.yaml`](../../lib/i18n/vi.i18n.yaml) |
| Español | `es` | [`lib/i18n/es.i18n.yaml`](../../lib/i18n/es.i18n.yaml) |
| Русский | `ru` | [`lib/i18n/ru.i18n.yaml`](../../lib/i18n/ru.i18n.yaml) |
| Français | `fr` | [`lib/i18n/fr.i18n.yaml`](../../lib/i18n/fr.i18n.yaml) |
| Deutsch | `de` | [`lib/i18n/de.i18n.yaml`](../../lib/i18n/de.i18n.yaml) |

这 12 门覆盖应用的全部界面文案，包括 Quest 空间面板（跟随应用内语言设置，不跟系统）以及
`android/questui/` 下的头显原生资源（`values-*`）。

翻译主要由 AI 完成，`en` / `zh-CN` / `zh-TW` / `ja` 这四门原有语言经过人工校对，
其余 8 门（ko / ru / th / es / fr / de / vi / id）目前是机器首轮翻译，尚未逐条人工校对。
发现翻译问题欢迎提 [Issue](https://github.com/FoxSensei001/LoveIwara/issues)。

维护命令：

```bash
dart run tool/i18n_check.dart          # 查看每门语言的缺失/多余/占位符不符/疑似未翻
dart run tool/i18n_sync.dart <locale>  # 给某门语言补齐 en 新增的 key（占位保留原文）
```

## 2. 标签词库语言（4 门，不等同于界面语言）

**[Iwara 标签词库](../../tool/data/iwara_tags/)** 与 **[Oreno3d 词库](../../tool/data/oreno3d_tags/)**
（原作 / 角色 / 标签的中日英译名）目前只维护 **zh-CN / zh-TW / ja / en** 四门语言，
**没有**随界面语言一起扩展到 ko / ru / th / es / fr / de / vi / id。这是有意为之，不是遗漏：

- **AI 翻译成本**：两份词库合计 2600+ 条 ACG / Vtuber / 同人黑话，且持续有新增标签要追加翻译。
  每多支持一门语言，就要为存量词条重新跑一轮翻译，之后每次增量还要再翻一遍——
  这个维护成本会随语言数线性增长，而不是界面翻译那种「翻一次就结束」的一次性成本。
- **语境差异大、错译更难发现**：这类词条严重依赖亚文化圈子约定俗成的译法（角色梗、作品别称、
  同人称呼），不是字面直译。在译者本人不熟悉的语言里，AI 译错的概率更高，而维护者又没有能力
  校对该语言，错译会一直留在词库里没人发现。宁可标签缺译退回英文，也不提供无法校对的翻译。

**实际表现**：界面语言若不在 zh-CN / zh-TW / ja / en 之列，标签**不会**翻译成当前界面语言，
而是回退显示词库里的**英文译名**（如 `mother` -> `Mother`、`blue_archive` -> `Blue Archive`）。
只有当某个标签压根不在这 2600+ 条词库范围内时（词库里连英文译名都没有），才会退到
「美化后的原始 key」（下划线转空格，如 `some_new_tag` -> `some new tag`）——这种情况与界面语言无关，
zh-CN / zh-TW / ja / en 四门语言遇到未收录标签时同样会看到这个原始 key。

想帮某门新语言把词库也覆盖到？欢迎在 [Issue #98](https://github.com/FoxSensei001/LoveIwara/issues/98)
讨论，或参考 [`tool/data/iwara_tags/README.md`](../../tool/data/iwara_tags/README.md) 提交修正/新增。
