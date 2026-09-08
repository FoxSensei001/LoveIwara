<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**一个用 Flutter 打造的、快速且美观的 Iwara 第三方跨平台客户端。**

一套代码 → Android · Windows · macOS · Linux · iOS

[![Telegram 群组](https://img.shields.io/badge/Telegram-群组-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
[![GitHub stars](https://img.shields.io/github/stars/FoxSensei001/LoveIwara?label=stars&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara)
[![GitHub forks](https://img.shields.io/github/forks/FoxSensei001/LoveIwara?label=forks&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara)
[![License: MIT](https://img.shields.io/github/license/FoxSensei001/LoveIwara?labelColor=27303D&color=0877d2)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/FoxSensei001/LoveIwara?labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/issues)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-^3.8-0175C2?style=flat&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![iOS](https://img.shields.io/badge/iOS-000000?style=flat&logo=apple&logoColor=white)

[English](README.md) · **简体中文** · [繁體中文](README_ZH_TW.md) · [日本語](README_JA.md)

</div>

---

## 🌟 简介

**Love Iwara**（又名 `i_iwara` 或 **2i**）是一个使用 Flutter 构建的 [Iwara](https://www.iwara.tv) 第三方客户端。它的目标是在手机、平板与桌面端都提供顺滑、接近原生的体验——而这一切都来自同一套代码，覆盖 **Android、Windows、macOS、Linux 和 iOS**。

> [!NOTE]
> 本项目最初是一个学习项目——我第一次尝试开发跨平台 Flutter 应用。部分代码可能还不够完善，但它一直在积极维护、功能也很丰富。如果你也在学习 Flutter，希望我们能一起进步。欢迎提交 PR 与反馈！

> [!IMPORTANT]
> **使用限制** —— 本项目仅供学习与个人参考，**不建议用于生产环境**。**严禁在任何公开平台进行宣传推广。** 如有违反，将采取包括但不限于停止维护、删除仓库等措施。

> [!WARNING]
> **免责声明** —— 本应用的开发者与 Iwara 及其内容提供商没有任何关联，且本应用**不托管任何**内容。

## ✨ 功能特性

### 🖥️ 支持平台
| Android | Meta Quest | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ *独立安装包¹* | ✅ | ✅ | ⚠️ *未测试²* | ✅ |

<sub>¹ Quest 版是面向 Horizon OS（Android 14+）的独立 arm64 安装包，内含 Meta Spatial SDK ——详见 [Meta Quest / VR](#-meta-quest--vr)。普通安卓包不受影响，仍然支持 Android 7.0+。</sub>
<sub>² Linux 可以构建，但由于缺少测试设备，目前暂未经过测试。</sub>

### 🎥 视频
- 基于 **media_kit**（libmpv）的流畅播放
- 清晰度选择 · 播放倍速控制（含默认 / 自动倍速）· 全屏
- 进度条悬停与拖拽时的**预览缩略图**
- **可点击的时间节点**——点击简介与评论中高亮的时间戳，直接跳转到对应位置
- **「接着看」**抽屉 + 可选的进入视频自动播放
- 实时加载速率显示
- **平面屏上的环视取景**——VR180 / 360° 的片子在别处只会显示成两个挤扁的半幅；在这里是一个比例正常、可以拖动环顾的取景窗。由于 Iwara 的文件完全不带球面元数据，格式只能靠启发式推断，随时可以手动纠正，纠正结果会为这条视频永久记住
- **「远近」**——按住即可把画面推远或拉近（平面片调画面缩放，环视片调视野角）
- **用其他应用打开**——把当前视频交给 MX Player / VLC，交给 Skybox、Pigasus 这类 VR 播放器，桌面端还可自定义外部播放器；优先使用本地或已下载的文件，并提供「复制链接」兜底
- 桌面端：将本地视频文件**拖拽**到窗口即可直接播放

### 🥽 Meta Quest / VR
*作为独立的 `quest` 安装包发布，基于 Meta Spatial SDK 构建。普通安卓包不链接其中任何内容，`minSdk` 也保持不变。*

**整个应用住在一个空间环境里。** 从 Quest 主页点开就直接进入常驻的沉浸空间。应用的全部——浏览、搜索、评论、软键盘——作为一块 2D 面板悬浮在你面前，没有任何功能被裁剪。这块面板是**微曲面**的（30° 弧度，默认 1.6 m 宽时约合「3000R」那一档曲面屏）：定死的是弧度而不是半径，所以窗拉宽拉窄，弯的程度看上去始终一致。

**三块窗，一套手势。** 应用面板、幕布、控制面板各自带一圈窗框：抓握扳机按在窗体上就能拖，四条边拖动、四个角以窗中心为原点缩放，窗始终面朝着你。尺寸与位置都会记住。头部追踪没稳之前一律不露面——不会出现「先在错的位置闪一下再跳过去」。

**播放器会变成空间里的一块幕布。** 打开视频即自动交出（可关）。
- **屏幕形状**——平面，或三档曲率。距离、幕宽与画幅都可调，并**按画面比例分别记忆**：回到一条 4:3 的片子，就恢复你为 4:3 设过的那套摆位。
- **视频格式**——2D / 3D、左右半幅与全幅、上下半幅与全幅、180° 与 360° 环视；从文件自动识别，也可以手动纠正。EAC 与鱼眼会被识别出来、标注为不支持，并转交外部播放器。
- **播放控制**——0.5×–3.0× 倍速、循环、音量、显示目标时间与增量的拖动预览、画在幕布正中的缓冲指示，面板上还有时钟与电量。
- **空间里的「接着看」**——和 2D 应用同一套分区视频池（来源列表、订阅、播放列表、最爱、已下载、稍后再看），带封面。换片不必离开空间；面板会进入加载态，下一条加载失败就把上一条放回去。
- **直链过期会自处理**——地址在到期前主动刷新；播到一半返回 404 也会触发刷新并从原位置续播。
- **场景**——直通，或纯黑虚空。

**空间画廊。** 图库打开后是一块大幕布加一条胶片，几十张图——以及混在其中的视频——始终是一个物体，而不是几十块合成层。幻灯片可选 3 / 5 / 10 / 20 秒，画质分标准与原图，在幕布上横向拖动即可翻页。竖图会被装进 16:9 的盒子里，9:16 的插画不会在你面前竖起一堵墙。

**手势或手柄都行。**
- *手势*——官方那套射线与捏合。在面板以外的任何地方捏一下，就是控制面板的显隐开关。
- *手柄*——A/X 播放暂停，B/Y 收起面板或返回应用，Menu 打开设置。抓握扳机不用瞄准就能抓住幕布。摇杆左右拖动进度并带加速（轻推一下是 5 秒，按住能一路加到每秒 15 分钟），上下把幕布推远或拉近。
- 摘下头显自动暂停、戴回来继续；系统重定位会把所有东西重新摆到你面前。

**第一次进来会先上一课。** 头显上的首次指引不是把触屏那套「双指捏合、长按倍速」照搬过来——空间里根本没有可触摸的画面。取而代之的是**空间视频**与**空间画廊**两组课程：手柄贴图跟着按键与摇杆逐帧动，幕布、面板与射线按真实几何摆位，手柄与裸手各演示一遍。系统开了「减弱动态效果」就只画一帧有信息量的静止图；设置里随时可以重看。

### 🌐 浏览与发现
- 多分类**搜索**：视频 · 图库 · 帖子 · 用户 · 论坛
- 运行时在 `iwara.tv` 与 `iwara.ai` 之间**切换站点**
- **新闻**资讯接入（`news.iwara.tv`）
- 接入 **Oreno3d** 标签源，提供更丰富的视频标签
- 订阅、丰富的筛选，以及面向桌面/平板的响应式布局

### 🖼️ 图库
- 图片浏览，支持顺滑的缩放与平移
- 图库查看器支持画质设置

### 💬 社区
- **论坛**：发布与编辑帖子、回复
- **帖子**：浏览与评论
- **评论**：浏览与回复
- **私信**：浏览与回复
- **站内消息通知**：浏览与回复

### 👤 账号与分享
- 用户认证、个人资料管理、关注系统
- **分享**视频 / 图库 / 帖子 / 论坛 / 用户
- 安卓深链跳转：在其他应用中打开 Iwara 链接会跳转回 2i 继续浏览

### 🗂️ 本地数据与实用工具
- **历史记录**（本地）：视频 · 图库 · 帖子 · 论坛
- **本地收藏**，支持自定义收藏夹
- **下载** *(测试版)*：视频 / 图库 / 单文件，支持自定义路径（含 Android 外置 SD/TF 卡）
- **备份与恢复**：导出 / 导入配置与历史记录
- **翻译**：视频描述、帖子、评论、论坛、会话等
- **应用锁**：PIN / 生物识别
- 「记住音量」选项（PC）

### 🌍 多语言
English · 简体中文 · 繁體中文 · 日本語——包括 Quest 上的空间面板，它跟随应用内的语言设置而不是系统语言

> 还有更多隐藏功能等你发现，也有更多功能在路上。有想法？欢迎提交 [Issue](https://github.com/FoxSensei001/LoveIwara/issues) 或加入 [Telegram 群组](https://t.me/+ITH4CV6Z_sc2ZWVl)。

## 🗺️ 近期计划

**Quest 适配已经落地**——详见上面的 [Meta Quest / VR](#-meta-quest--vr)。它以独立安装包发布，由独立的 CI 任务产出，普通安卓包不受任何影响。

头显这边仍然开着的账：

- 空间面板的显存释放路径目前是失效的。
- 空间场景与 Flutter 共用同一条主线程，这件事的帧开销从未量过。
- 应用面板目前是 Activity 承载的，应当迁移到 View 承载的面板——官方明写后者是两者中更轻的那个。
- EAC 与鱼眼投影能识别出来，但只能转交外部播放器，尚未自己渲染。

其他方面：下载仍标着测试版；Linux 能构建，但缺测试设备、始终未经测试。

有需求？欢迎提交 [Issue](https://github.com/FoxSensei001/LoveIwara/issues) 或加入 [Telegram 群组](https://t.me/+ITH4CV6Z_sc2ZWVl)。

## 🧰 技术栈

| 领域 | 库 |
|---|---|
| 框架 | **Flutter** + Dart |
| 状态管理 | **GetX** (`get`) |
| 路由 | **go_router** |
| 网络 | **Dio**（+ CookieJar / Cloudflare 拦截器） |
| 视频 | **media_kit**（libmpv） |
| 本地存储 | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| 国际化 | **slang** |
| 桌面外壳 | **window_manager**（自定义标题栏、拖拽） |

## 📸 截图展示

### 🥽 Meta Quest

| 幕布与它的控制面板 | 图库：一块幕布 + 一条胶片 |
|:-------------------------:|:-------------------------:|
|<img src="docs/imgs/video_quest.jpg" width="420">|<img src="docs/imgs/gallery_quest.jpg" width="420">|

### 📱 手机与桌面

| | |
|:-------------------------:|:-------------------------:|
|<img src="docs/imgs/all.png" width="300">|<img src="docs/imgs/dingyue.png" width="300">|
|<img src="docs/imgs/filter.png" width="300">|<img src="docs/imgs/gonggao.png" width="300">|
|<img src="docs/imgs/huihua.png" width="300">|<img src="docs/imgs/luntan.png" width="300">|
|<img src="docs/imgs/luntanxaingqing.png" width="300">|<img src="docs/imgs/pinglun.png" width="300">|
|<img src="docs/imgs/record.png" width="300">|<img src="docs/imgs/shezhi.png" width="300">|
|<img src="docs/imgs/shipin.png" width="300">|<img src="docs/imgs/shipin2.png" width="300">|
|<img src="docs/imgs/shipinliebiao.png" width="300">|<img src="docs/imgs/sousuo.png" width="300">|
|<img src="docs/imgs/tongzhi.png" width="300">|<img src="docs/imgs/tuku.png" width="300">|
|<img src="docs/imgs/tukuliebiao.png" width="300">|<img src="docs/imgs/zuozhe.png" width="300">|
|<img src="docs/imgs/download.png" width="300">|<img src="docs/imgs/localshoucang.png" width="300">|

## 🚀 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. 检查工具链
flutter doctor

# 3. 安装依赖
flutter pub get

# 4. 运行（自动选择已连接设备）
flutter run --flavor standard   # Android 必须带 flavor，见下方说明
# …或指定平台（桌面端 / iOS 不需要 flavor）：
flutter run -d windows   # macos / linux / ios
```

> [!IMPORTANT]
> **Android 有两个产物维度（product flavor）。** `standard` 是普通手机 / 平板包（`minSdk 24`、全 ABI）；
> `quest` 是 Meta Quest / Horizon OS 包（`minSdk 34`、仅 arm64，内含约 50 MB 的 Meta Spatial SDK）。
> 一旦定义了 flavor，AGP 就不再存在「不带 flavor」的变体，因此 **Android 的每一条 `flutter run` /
> `flutter build` 都必须带 `--flavor`**，裸命令会直接失败。

> [!TIP]
> 修改任意 `lib/i18n/*.i18n.yaml` 后，运行 `dart run slang` 重新生成国际化文本。
> 完整依赖见 [`pubspec.yaml`](pubspec.yaml) —— 少数依赖需要额外的准备步骤。

<details>
<summary><b>🛠️ 完整开发环境配置</b></summary>

### 前置要求
- Flutter SDK（建议最新稳定版）· Dart SDK · Git
- 推荐 IDE：Android Studio / VS Code / Cursor + Flutter 插件

### 平台特定要求

**Windows**
- Windows 10+（64 位）、Visual Studio 2022+、Windows 10 SDK
```bash
flutter doctor -v
```

**macOS**
- 最新版 macOS + Xcode + CocoaPods
```bash
sudo gem install cocoapods
```

**Linux**
```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
# Fedora
sudo dnf install clang cmake ninja-build gtk3-devel
```

**Android** —— Android Studio + Android SDK + 模拟器/实体设备
**iOS** —— Xcode + 模拟器/实体设备 + Apple 开发者账号（发布需要）

### 构建发布版本
```bash
flutter build apk --release --flavor standard         # Android APK（手机 / 平板）
flutter build appbundle --release --flavor standard   # Android AAB
flutter build apk --release --flavor quest --target-platform android-arm64   # Meta Quest APK
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### 常用命令
```bash
dart run slang     # 重新生成国际化文本
flutter analyze    # 代码分析
flutter test       # 运行测试
flutter clean      # 清理构建缓存
flutter devices    # 查看已连接设备
```

### 常见问题
```bash
# 依赖冲突
flutter pub cache repair && flutter clean && flutter pub get
# 模拟器
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Android 签名配置</b></summary>

构建签名的发布版 APK：

**1. 生成 keystore**（在 `android/app` 目录下执行）：
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
请确保 `keystore.jks` 最终位于 `android/app` 目录。

**2. 配置签名信息**（`android/app/build.gradle`）：
```groovy
signingConfigs {
    release {
        storeFile file("keystore.jks")
        storePassword System.getenv("KEYSTORE_PASSWORD") ?: project.findProperty("MY_KEYSTORE_PASSWORD")
        keyAlias System.getenv("KEY_ALIAS") ?: project.findProperty("MY_KEY_ALIAS")
        keyPassword System.getenv("KEY_PASSWORD") ?: project.findProperty("MY_KEY_PASSWORD")
    }
}
```
并在 `android/gradle.properties` 中添加占位符：
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** —— 在仓库 Secrets 中添加：`KEYSTORE_BASE64`（`keystore.jks` 的 base64）、`KEYSTORE_PASSWORD`、`KEY_ALIAS`、`KEY_PASSWORD`。然后在 `.github/workflows/build.yml` 中：
```yaml
env:
  KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
  KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
  KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}

steps:
  - name: Setup Keystore
    run: |
      echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
    shell: bash
```

**4. 构建** —— `flutter build apk --release --flavor standard`，产物位于 `build/app/outputs/flutter-apk/app-standard-release.apk`；Quest 包用 `flutter build apk --release --flavor quest --target-platform android-arm64`，产物是 `app-arm64-v8a-quest-release.apk`。

</details>

## 🌍 国际化

目前的翻译大多由机器生成。如果你愿意协助改进，请从简体中文模板入手：[`lib/i18n/zh-CN.i18n.yaml`](lib/i18n/zh-CN.i18n.yaml)，然后运行 `dart run slang`。

### 🏷️ Iwara 标签本地化

Iwara 的原始标签是英文式的 key（如 `mother`、`blue_archive`）。App 内置了一份社区维护的词库，把每个标签映射为 **简体中文 / 繁体中文 / 日语 / 英语**，因此在详情页、搜索、标签列表页都会按你当前的语言展示标签。

工作方式：

- **词库**：位于 [`tool/data/iwara_tags/`](tool/data/iwara_tags/)，App 实际消费合并压缩后的 [`iwara_tags.min.json`](tool/data/iwara_tags/iwara_tags.min.json)。
- **分发**：随包内置一份离线兜底（`assets/data/iwara_tags.min.json`），并通过 jsDelivr CDN 热更新——因此**无需重新发版**也能改进译名。
- **应用内**：标签 chip 显示译名；详情页标签卡片的展开/收起那一行有一个图标按钮，可在 **原始 key ⇄ 译文** 间切换；长按 / 右键标签（或在标签列表页点击标签标题）会弹出弹窗，同时给出译文与原始 key、复制按钮以及反馈入口。

这些是对 2600+ 个 ACG / Vtuber / NSFW 词条的尽力翻译，可能存在错误。

> **发现翻译有误或不通顺？** 欢迎到专门的 issue 反馈：**https://github.com/FoxSensei001/LoveIwara/issues/98**（App 内的标签弹窗也会链接到这里）。

**提交修正**（面向维护者 / 贡献者）：

1. 编辑可读版 [`iwara_tags_localized.json`](tool/data/iwara_tags/iwara_tags_localized.json)（每个标签的 `zh-CN` / `zh-TW` / `ja` / `en`）。
2. 重新生成合并产物与打包资源：`dart run tool/data/iwara_tags/build_localized_min.dart`。
3. 同时提交源文件与生成的 `iwara_tags.min.json`（详见 [`tool/data/iwara_tags/README.md`](tool/data/iwara_tags/README.md)）。

第三方 **Oreno3d** 的元数据（原作 / 角色 / 标签）采用同样方式本地化——词库位于 [`tool/data/oreno3d_tags/`](tool/data/oreno3d_tags/)，打包资源 + jsDelivr CDN，在视频详情页与搜索卡片上按当前语言展示。

## 🙏 致谢

本项目在开发过程中受到以下优秀项目的启发，并从中学习了许多实现方式与最佳实践：

<div align="center">

<table>
  <tr>
    <td align="center" width="50%">
      <a href="https://github.com/iwrqk/iwrqk">
        <img src="https://opengraph.githubassets.com/1/iwrqk/iwrqk" alt="iwrqk/iwrqk" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>iwrqk/iwrqk</b></sub>
      <br />
      <sub>优秀的 Flutter 实现的 Iwara 客户端</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>结构良好的 Flutter 漫画应用</sub>
    </td>
  </tr>
</table>

</div>

### 项目贡献者

感谢所有为本项目做出贡献的开发者！🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara&max=100" alt="项目贡献者" />
</a>

</div>

<sub>通过 [contrib.rocks](https://contrib.rocks) 生成</sub>

## 🤝 贡献

欢迎提交 Pull Request！对于重大更改，请先打开一个 issue 来讨论你想要更改的内容。在报告新问题之前，请先查看已有的 [issues](https://github.com/FoxSensei001/LoveIwara/issues)。有任何疑问？欢迎加入我们的 [Telegram 群组](https://t.me/+ITH4CV6Z_sc2ZWVl)。

## 💬 交流群

加入我们的 Telegram 社区：**[点击此处加入交流群](https://t.me/+ITH4CV6Z_sc2ZWVl)**。

---

<div align="center">
<sub>用 ❤️ 与 Flutter 打造 · 这是一个粉丝制作的客户端，请支持 Iwara 官方。</sub>
</div>
