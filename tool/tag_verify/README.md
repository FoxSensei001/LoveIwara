# ② 确定性核实层：先查得到的就不问 AI

二次元角色 / 作品的译名是**可以查到事实**的，不该交给模型推理——
尤其是刚实装的新角色（ZZZ 的 ヴェリナ、鳴潮 的 穂穂、明日方舟终末地的 ロッシ），
模型的训练数据往往还没有它们，一问就编。

```bash
dart run tool/tag_verify/lookup.dart --missing              # 查所有还没译名的词条
dart run tool/tag_verify/lookup.dart --keys characters/5182,origins/854
dart run tool/tag_verify/lookup.dart --missing --limit 5    # 小批试跑
```

产物 `out/evidence.json`：**只给证据，不改任何词库**。它是 AI 批次任务的输入——
查得到的直接定死不必再问模型，查不到的才需要判断。

## 数据源：Danbooru wiki

免费、无需 key、社区维护的二次元事实标准。用的是
`wiki_pages.json?search[other_names_match]=<日文原名>`。

它的 `other_names` 一次给齐日文原名、**简体中文名、繁体中文名**与英文别名：

```
毒島冴子   -> busujima_saeko    ['毒島冴子', '毒岛冴子']
ヴェリナ   -> velina_airgid     ['ヴェリナ(ゼンゼロ)', 'ヴェリナ', '维琳娜', 'ヴェリナ・エガード']
白銀の城   -> silver_palace     ['白银之城', '白銀之城', 'SilverPalace', '白銀の城', '실버팰리스']
```

而且别名常带作品后缀（`オデット(原神)`、`ロッシ(エンドフィールド)`），
**顺带就能验证「这个角色属于哪部作品」**——也就是我们要的「身份」信号，
不用再让模型自我声明置信度。

## 语言分桶

复用 [tag_audit](../tag_audit/README.md) 的两张简繁「独用字」表把 `other_names` 分类：
含假名→ja、含韩文→丢弃、纯拉丁→en、汉字则按独用字判简/繁；
两张表都不命中说明这个名字简繁写法相同，归入 `zhAny`，两边都能用。

`preferredZh` 是建议值：优先简体桶，剥掉 `玛绮朵(少女前线2)` 这类作品后缀，取最短的一个。
**只是建议，采不采由人决定。**

## 置信度

不是模型的自我感觉，是**可被脚本证伪的断言**：

| 档 | 条件 |
|---|---|
| `high` | 日文原名精确出现在 `other_names` 里，**且**作品后缀与词库里的 origin 对得上 |
| `medium` | 日文原名精确命中，但没有作品信息可核对 |
| `low` | 靠退回变体命中（见下），或原名未精确出现 |
| `none` | 查不到 |

**退回变体**：词库里有些名字自带括注（`ココナ(心夏)`、`レミエール・ダン(ラミル)`），
Danbooru 通常只收一种写法。全名查不到时依次退回「去掉括注的主名」与「括注里的别名」再试。
这样能把命中率从 23/26 提到 25/26，但证据更弱——`ココナ(心夏)` 用「心夏」去查
可能撞上另一个同字角色，所以除非归属也对得上，一律压到 `low` 交人判断。

## 实测（2026-08-25，重抓带回的 26 条新词条）

```
查得到 25/26，其中归属也对得上 6 条
high 10 · medium 13 · low 2 · none 1
另有 7 条查到了页面但 Danbooru 上没有中文名，仍需 AI 补
```

## 已知未接的源

Wikidata（正式作品名的多语言标签）、萌娘百科（中文圈译名权威，尤其 VTuber）。
Danbooru 查不到的那些（`クロスファイア`）与「有页面但无中文名」的那 7 条，
是这两个源该补位的地方。

## 第二个数据源：EhTagTranslation（iwara 侧）

E 站中文社区维护的标签译名库（约 4.5 万条，每次提交自动发 Release），
`character` / `parody` 与 iwara 的角色 / 作品标签高度重合。

```bash
dart run tool/tag_verify/lookup_ehtt.dart            # 用缓存（没有就下载最新 Release）
dart run tool/tag_verify/lookup_ehtt.dart --refresh  # 强制拉最新
```

- iwara 写 `tanga_ibuki`、E 站写 `ibuki tanga`，所以**按拆词后的集合匹配**。
- 每条给出 `zh`（简中，`|` 分隔的写法拆开）、`ja`（介绍里写明的日文原名）、`origins`（所属作品）。
- 产物 `out/evidence_ehtt_iwara.json`，`make_batches` 自动附进任务的 `evidence.ehtt`；
  Danbooru 没异议、但 EhTT 中文名不同的条目会出 `adjudicate`（`candidatesFrom: ehtt`）。
- 两类已知误导方向按命名空间自动挂 `warning`：
  性癖类（male / female / mixed）用的是本子圈说法（`anal → 爆肛`）；
  按拼写撞名（`almond_eye` 在 E 站是赛马娘角色，不是「杏眼」）。
- 协议 CC BY-NC-SA 3.0：**只作核对证据，不把它的文本原样打包进 App。**

实测（2026-11-24，iwara 2942 条）：命中 1404，其中一致 967、不一致 423、
我们中文位还是英文而它有中文 14（`aemeath → 爱弥斯`、`stella_sora → 星塔旅人`）。

### 整表重译

```bash
dart run tool/tag_verify/make_batches.dart --retranslate   # iwara 每条都出四语言 translate（跳过 overrides）
```

每条带 `current`（旧 AI 译名，仅参考）与两份证据；收回仍走 `ingest.dart`，写进 `iwara_tags_localized.json`。
