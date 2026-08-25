# 把标签词库的判断工作交给 Antigravity

整套流程是**文件对文件**的：agent 只读一个 `.in.json`、只写一个 `.out.json`，
**永远不碰主词库**。合并由 `ingest.dart` 做，而且它会先校验、不过就整批打回。

这样设计的理由很直接：agent 会偷懒、会漏条、会假装干完。
如果让它直接改词库，漏译的条目会伪装成「已处理」，编造的译名会伪装成「已核实」，
而 5000 条里没人查得出来。

## 三步

```bash
# 1. 生成批次（当前 390 条待判断 -> 4 批）
dart run tool/tag_verify/make_batches.dart

# 2. 交给 Antigravity 跑，一次一批（见下面的提示词）

# 3. 收回：先只校验，通过了再落盘
dart run tool/tag_verify/ingest.dart
dart run tool/tag_verify/ingest.dart --apply
```

落盘后必须重新出包并过闸门：

```bash
dart run tool/data/oreno3d_tags/build_localized_min.dart
dart run tool/data/iwara_tags/build_localized_min.dart
flutter test test/tool/
```

## ⛔ 输出必须从模板拷贝，不要自己排 key

`make_batches` 每批同时产出一份 `batch_XXX.tpl.json`：key 已按输入顺序排好、
条数已经对上、`names` 里该填哪几种语言也已列好，**agent 只负责就地填值**。

```bash
cp tool/tag_verify/out/batches/batch_004.tpl.json \
   tool/tag_verify/out/batches/batch_004.out.json   # 然后就地填
```

这一步不是省事，是堵一类实测发生过的错误：agent 会**整块丢掉输入中间的一段**
（如第 60-78 位共 19 条），再从别的批次和**凭空编造的 key** 里补齐条数——
条数对得上、指纹对得上、格式无懈可击，但 key 全错。
提示词里写「不得增删 key」拦不住它，因为它不是不知道规则，是自己重排了一遍 key。
模板把「重排 key」这个动作从流程里删掉，这一类错误就无从发生。

## 给 Antigravity 的提示词

> 读 `tool/tag_verify/out/batches/batch_001.in.json`，
> 把同目录的 `batch_001.tpl.json` 拷贝成 `batch_001.out.json`，
> 然后按 `contract` 的要求**就地填满每一条** entry——只填值，不要动 key、不要重排顺序。
>
> 两类任务：
> - `type: translate` —— 为 `need` 里列出的每个语言给出译名，写进 `names`。
>   `known` 里已有的语言不要改。
> - `type: adjudicate` —— 现有译名 `current` 与 Danbooru 证据不一致，
>   判断是保留还是替换：`decision` 取 `keep` 或 `replace`，
>   `replace` 时在 `names` 里给出要改的语言，并在 `ref` 里给来源 URL。
>
> 硬性要求：
> - 输出的 key 与条数必须和输入完全一致，不得增删、不得改写 key
> - 每条都要有一句话 `reason`
> - **没有把握一律 keep / 保留原文**。宁可留日文原名，也不要给一个错的中文名
> - 罗马音只有一种情况不许用：**顶掉已有的中文名**（`天海琉夏` → `雨海Ruka` 是错的）。
>   本来就没有公认中文名的小众角色（多为个人势 VTuber），写成 `杏户yuge` 是允许的——
>   罗马字是本人在用的写法，我们自己编一个中文音译反而更不可靠
> - `candidates` 来自 Danbooru 的既有别名，是**线索不是答案**——
>   它可能是日文写法（`暁`）、旧译名，甚至是别的角色
> - 同名不同人的词条（同一个日文名、不同 `origin`）必须给出**不同**的译名，不要合并
>
> 遇到刚实装的新角色请联网核实官方中文名，不要凭记忆。

## 校验会拦下什么

`ingest.dart` 已实测能拦住一份典型的偷懒输出：

```
✗ batch_004 打回（9 个问题）
    条数不符：输入 30，输出 4
    漏了 27 条：stomping, strangling, street_fighter, …
    凭空多出 1 条：characters/999999
    spread_pussy 缺 reason
    spread_pussy decision=replace 必须给可访问的 ref URL
```

规则清单：key 集合与条数必须一致 · key 不得重复 · 语言必须是四种之一 ·
译名不得为空 · `translate` 必须补齐 `need` 且不得改动 `known` ·
`adjudicate` 的 `decision` 必须是 keep/replace · `replace` 必须给 names 与可访问的 ref URL ·
每条必须有 reason。**任何一条不过，整批不合并。**

## 合并去向不是随便定的

| 来源 | 去向 | 为什么 |
|---|---|---|
| `translate` 的新译名 | `*_localized.json` | 它们是新产出的译名，属派生层，将来重译可以覆盖 |
| `adjudicate` 的 replace | `overrides.json` | 它们是对既有 AI 译名的**修正**，必须永不被重译覆盖 |

写进 `overrides.json` 的每条会自动带上 `prev`（改前值）、`ref`、`by`（批次号）与
`note`（agent 给的 reason），将来重抓后上游若发生漂移会进 `needs_review.json`。

## 当前批次构成

```
adjudicate  364   现有译名与 Danbooru 不一致，需裁决
translate    26   重抓带回的新词条缺译名
```

按 `workCount` 降序排列，**热门的排在前面**——错在热门词条上影响面更大，
所以即使只跑完第一批也是最有价值的那 120 条。
