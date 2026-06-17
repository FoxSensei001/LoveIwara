# Oreno3d 元数据抓取工具包（原作 / 角色 / 标签）

本文件夹包含从第三方站点 **oreno3d.com** 抓取「原作 / 角色 / 标签」三类元数据的工具、原始快照，以及对齐 Iwara 标签的 AI 四语言本地化映射与合并产物。
对应 App 内的 Oreno3d 集成（`lib/app/services/oreno3d_client.dart`、`oreno3d_html_parser.dart`、`oreno3d_localization_service.dart`）。

## 目录结构

- [fetch_oreno3d_tags.dart](fetch_oreno3d_tags.dart)：抓取脚本，逆向 oreno3d 列表页 HTML，产出合并 JSON 快照。
- [oreno3d_tags.json](oreno3d_tags.json)：抓取下来的原始快照（809 原作 / 1579 角色 / 166 标签）。
- [oreno3d_tags_localized.json](oreno3d_tags_localized.json)：AI 产出的四语言译名映射（`日文原名 -> {zh-CN, zh-TW, ja, en}`），人类可读版。
- [oreno3d_tags.min.json](oreno3d_tags.min.json)：**App / CDN 实际消费的合并产物**。把原始元数据与译名合并、按 `id` 分三类（origins/characters/tags）索引。
- [build_localized_min.dart](build_localized_min.dart)：合并脚本，生成 `oreno3d_tags.min.json` 并同步一份到打包资源 `assets/data/oreno3d_tags.min.json`。

## App 集成（展示本地化）

合并产物经两条渠道获取，与 Iwara 标签一致：

1. **打包兜底**：`assets/data/oreno3d_tags.min.json`（离线即用）。
2. **CDN 热更新**：`https://cdn.jsdelivr.net/gh/FoxSensei001/LoveIwara@master/tool/data/oreno3d_tags/oreno3d_tags.min.json`（无需发版即可更新译名）。

运行时由 `Oreno3dLocalizationService` 统一处理：内存只物化「当前语言译名」（外加检索/排序所需的少量字段），切换语言时从数据源重建。详情页的「原作 / 角色 / 标签」chip 与搜索结果卡片上的标签都会按当前语言展示译名——其中详情页对象带数字 `id`，按 (类别, id) 精确映射；卡片上的纯字符串标签按「日文原名 -> 译名」兜底匹配；缺失译名时回退日文原名。点击仍使用原始 `id` 跳转，不受影响。

### 搜索选择 + 收藏

由于全量词库（809 原作 / 1579 角色 / 166 标签）已随包内置，搜索里选择 Oreno3d 实体**完全离线**：

- `Oreno3dLocalizationService.search(type, query)` 在本地按「译名 / 日文原名 / id」检索，按作品数排序。
- `Oreno3dTagPickerDialog` 提供类别切换 + 搜索的选择器；选中即按 `extData{searchType,id}` 浏览该实体（`SearchService.fetchOreno3dByQuery`，单实体浏览，非多标签 AND）。
- 用户可收藏原作/角色/标签（`UserPreferenceService.oreno3dFavorites`，持久化于 sqlite），在搜索弹窗的 oreno3d 段作为快捷区出现。
- 「收藏标签管理」页（`/favorite_tags`，全局抽屉进入）以分类 Tab 维护 Iwara 标签（复用 `videoSearchTagHistory`）与 Oreno3d 原作/角色/标签收藏。

> 修改了 `oreno3d_tags_localized.json` 后，请重跑 `dart run tool/data/oreno3d_tags/build_localized_min.dart` 同步 min 文件与打包资源，再提交。

## 数据模型（已逆向确认）

oreno3d 把内容按三类实体组织，App 详情页也是据此解析（`原作：` / `キャラ：` / `タグ：`）：

| 类别 | 中文 | 详情/筛选路由 | 列表来源 |
|------|------|---------------|----------|
| origins | 原作 | `/origins/:id` | `/origins` 单页全量（约 809） |
| characters | 角色 | `/characters/:id` | `/characters` 单页全量（约 1579，含所属原作） |
| tags | 标签 | `/tags/:id` | 经 `/tags` → 遍历各 `/tag-groups/:id`（8 组共约 166） |

关键结构细节：

- **origins / tags / tag-groups**：单页即全量，列表项为 `a.group-list-li-a`。
- **characters**：`/characters?page=N` 的 `page` 参数对主列表**无效**——每页都返回相同的全量集合，按 `id` 去重即可（抓到 1679 项含 100 条排行榜重复 → 去重后 1579）。每个角色还带 `<span class="group-list-li-a-chara-origins">(所属原作)</span>`。
- **tags 的分组**：`/tags` 是「タググループ一覧」，列出 8 个 tag-group（如 動画の特徴 / プレイ内容 / モーション …），需逐个进 `/tag-groups/:id` 收集其下标签。脚本会记录每个标签的 `groupId` / `groupName`。

单条 DOM 通用形态：

```html
<a href="/{kind}/{id}" class="group-list-li-a ...">
  <div class="group-list-li-a-flex1">
    <div class="group-list-li-a-number">1位</div>            <!-- 仅角色有排名 -->
    <div class="group-list-li-a-chara ...">名称<span
        class="group-list-li-a-chara-origins">(所属原作)</span></div>
  </div>
  <div class="group-list-li-a-number">12345作品</div>          <!-- 作品数 -->
</a>
```

## 产物结构

```jsonc
{
  "version": 1,
  "source": "https://oreno3d.com",
  "fetchedAt": "2026-06-17T...Z",
  "counts": { "origins": 809, "characters": 1579, "tags": 166, "tagGroups": 8 },
  "origins":    [ { "id": "1", "name": "ボーカロイド", "url": "...", "workCount": 28228 } ],
  "characters": [ { "id": "4", "name": "初音ミク", "url": "...", "workCount": 9140, "origin": "ボーカロイド" } ],
  "tagGroups":  [ { "id": "1", "name": "動画の特徴" } ],
  "tags":       [ { "id": "1", "name": "主観視点", "url": "...", "workCount": 33157, "groupId": "1", "groupName": "動画の特徴" } ]
}
```

`name` 为日文原名（后续本地化的输入）。`workCount` 为作品数，可用作热度排序。

## 运行

```bash
# 仓库根目录执行
dart run tool/data/oreno3d_tags/fetch_oreno3d_tags.dart --proxy 127.0.0.1:7890
```

选项：

- `--output <path>`：输出路径，默认 `tool/data/oreno3d_tags/oreno3d_tags.json`。
- `--proxy <host:port>`：HTTP 代理（见下方 Cloudflare 说明）。
- `--cookie <header>`：可选 Cookie 头（如已在浏览器通过验证，可复用 `cf_clearance`）。
- `--changes <path>`：额外写出「相比旧快照的变更清单」JSON（增量重抓用）。
- `--no-diff`：跳过与旧快照的对比。

## 定期重抓 / 增量更新方案

oreno3d 会不断新增原作/角色/标签，需要时不时重抓最新数据。脚本是**幂等**的——直接重跑覆盖 `oreno3d_tags.json` 即可。为支持"只关注变化、将来只翻译新条目"，每次重抓会**自动与上一份快照对比**并打印增量：

```bash
# 常规重抓（自动对比上一份快照，打印 新增/删除/改名 摘要）
dart run tool/data/oreno3d_tags/fetch_oreno3d_tags.dart --proxy 127.0.0.1:7890

# 同时把变更落盘成机器可读清单（推荐：将来本地化只翻译 added/renamed）
dart run tool/data/oreno3d_tags/fetch_oreno3d_tags.dart --proxy 127.0.0.1:7890 \
  --changes tool/data/oreno3d_tags/oreno3d_tags.changes.json
```

对比逻辑：按 `id` 在每个类别（origins/characters/tags）内比对，输出三类变化：

- **added**：旧快照没有的新 `id`（站点新收录）。
- **removed**：旧快照有、本次没有的 `id`（下架/合并）。
- **renamed**：同一 `id`、`name`（日文原名）发生变化。

控制台摘要示例：

```
增量对比（相比上一次快照）：
  原作 origins: +3 新增  -0 删除  ~1 改名
    新增: 810 新作品名、811 …
    改名: 42 旧名 → 新名
  角色 characters: +12 新增  -1 删除  ~0 改名
  标签 tags: +0 新增  -0 删除  ~0 改名
```

`--changes` 产物结构：

```jsonc
{
  "generatedAt": "2026-...Z",
  "hasPrevious": true,
  "categories": {
    "origins":    { "added": [ {"id":"810","name":"..."} ], "removed": [], "renamed": [ {"id":"42","old":"...","new":"..."} ] },
    "characters": { "added": [...], "removed": [...], "renamed": [...] },
    "tags":       { "added": [...], "removed": [...], "renamed": [...] }
  }
}
```

> 首次抓取（无旧快照）会提示「全部视为新增」，不会报错。
>
> 建议工作流：重抓前**保留旧 `oreno3d_tags.json`（git 已跟踪即可）**，跑带 `--changes` 的命令，再用 `git diff` 复核快照变化、用 changes 清单驱动后续增量本地化。将来做本地化合并脚本时，沿用 iwara 那套「按 id 保留已有译名、只补 added/renamed」的增量策略即可，无需全量重译。

## ⚠️ Cloudflare 说明（为什么必须挂代理）

oreno3d 全站受 Cloudflare 保护。App 内 `Oreno3dClient` 其实是**裸 Dio、无任何 CF 处理**，它能用是因为运行在 CF 已信任的真实设备会话里。

从命令行/无头环境抓取时：

- **数据中心 / 机房 IP**（如阿里云东京 AS45102）会被弹**交互式人机验证**并返回 `403 Just a moment…`，无头浏览器也过不了那个勾选框。
- **日本住宅类节点**实测可直接 `200` 放行。

因此抓取时请挂一个能放行的（最好是日本住宅类）代理。脚本内置重试以应对节点抖动；若仍持续 403，会抛出明确提示，请换节点或改用 `--cookie` 复用浏览器已通过的 clearance。
