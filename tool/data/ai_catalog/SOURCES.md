# AI 供应商目录 — 出处与许可

`ai_catalog.min.json` 是**派生产物**，不要手改。要改就改 `overrides.dart` 再重跑生成脚本。

## 上游

| | |
|---|---|
| 项目 | [CherryHQ/cherry-studio](https://github.com/CherryHQ/cherry-studio) |
| 包 | `packages/provider-registry` |
| 取用的文件 | `data/providers.json`、`data/models.json` |
| 许可 | **MIT**（见下） |
| 本次抓取的 commit | `9e2a8d49234931972ffd170412ab93a1e351de33`（2026-09-21） |
| `providers.json` version | `2707d81b155c6c98` |
| `models.json` version | `11174ce97b90176e` |

## ⚠️ 许可要点

Cherry Studio **仓库整体是 AGPL-3.0**，但我们取用的那个子包在自己的
`packages/provider-registry/package.json` 里声明：

```json
{ "name": "@cherrystudio/provider-registry", "license": "MIT", "author": "Cherry Studio" }
```

本仓库也是 MIT，所以**这两份数据文件可以派生**，保留出处与版权声明即可：

> Copyright (c) Cherry Studio — `@cherrystudio/provider-registry`, MIT License.
> https://github.com/CherryHQ/cherry-studio

⛔ **`src/renderer` 下的界面代码是 AGPL-3.0，不能抄。** 我们的供应商设置界面是按
本项目的玻璃体系自己写的，只借鉴了交互思路（内置目录 + 用户 delta、Provider 1–N Model、
「填 key → 拉模型 → 勾选 → 真试一次」的接入向导）。

⛔ 派生时**剥掉了上游的推广返利链接**（硅基流动那条 `/i/…` 邀请码，见
`overrides.dart` 的 `kApiKeyUrlOverrides`）。别人的返利码不该跟着我们的包发出去。

## 我们自己加的那一层

上游负责「这家在哪儿、这个模型有什么能力」。以下是上游没有、**也不该有**的知识，
全部维护在 `overrides.dart`，重抓不会被覆盖：

- `kDropProviders` — dartantic 驱动不了的家（OAuth / 外部 CLI / AWS SigV4 / Azure 部署名）
- `kKindOverrides` — 上游端点判不出、但 dartantic 有原生 provider 的几家
- `kBaseUrlOverrides` + `_normalizeOpenAiBase` — ⛔ dartantic 把 baseUrl **原样当前缀**，
  少一个 `/v1` 就是 404，而上游登记的多是不带版本段的裸域名（它们的 SDK 自己拼路径）
- `kStructuredOutputSupport` — **端点**认不认 `response_format: json_schema`。
  与上游 models.json 的 `structured-output` 是两件事：那个说的是**模型**支不支持，
  而 2026-09-20 实测挖出来的问题是中转层面静默忽略（HTTP 200、回一整段散文、不报错）
- `kNoTemperature` / `kLocalProviders` / `kNameOverrides` / `kModelAliases` / `kModelCapsPatch`

## 重抓

```bash
# 直接拉上游（走 HTTPS_PROXY / ALL_PROXY）
dart run tool/data/ai_catalog/fetch_ai_catalog.dart

# 或指向一份本地副本
git clone --depth 1 --filter=blob:none --sparse https://github.com/CherryHQ/cherry-studio.git /tmp/cs
cd /tmp/cs && git sparse-checkout set --skip-checks packages/provider-registry
dart run tool/data/ai_catalog/fetch_ai_catalog.dart --from /tmp/cs/packages/provider-registry
```

产物会同时写到本目录与 `assets/data/ai_catalog.min.json`。重抓后**把上表的 commit 与
两个 version 更新掉**，并核对：

- 供应商数量没有意外暴跌（漏掉一条 kind 判定就会成批丢）
- `openai` / `anthropic` / `gemini` / `deepseek` / `ollama` 五条都还在
- 没有新的返利链接混进来：
  `python3 -c "import json,re;d=json.load(open('assets/data/ai_catalog.min.json'));print([(p,v) for p,pv in d['providers'].items() for v in (pv.get('w') or {}).values() if re.search(r'/i/|invite|referr|utm_',v,re.I)])"`

## 热更新

产物同时是 jsDelivr 的源（`lib/common/constants.dart` 的 `aiCatalogCdnUrl`，指向本仓库
`tool/data/ai_catalog/ai_catalog.min.json`）。⭐ 于是「某家换了地址」「出了新模型」
**推到 master 就到位，不用发版**——与标签词库同一套机制
（`TagDictionaryFetcher` / `DictionarySnapshot`）。
