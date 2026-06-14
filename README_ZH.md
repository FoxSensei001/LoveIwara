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

[English](README.md) · **中文**

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
| Android | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ | ✅ | ⚠️ *未测试¹* | ⚠️ *未测试¹* |

<sub>¹ Linux 与 iOS 可以构建，但由于缺少测试设备，目前暂未经过测试。</sub>

### 🎥 视频
- 基于 **media_kit**（libmpv）的流畅播放
- 清晰度选择 · 播放倍速控制（含默认 / 自动倍速）· 全屏
- 进度条悬停与拖拽时的**预览缩略图**
- **可点击的时间节点**——点击简介与评论中高亮的时间戳，直接跳转到对应位置
- **「接着看」**抽屉 + 可选的进入视频自动播放
- 实时加载速率显示
- 桌面端：将本地视频文件**拖拽**到窗口即可直接播放

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
- 「记住音量」选项（PC）

### 🌍 多语言
English · 简体中文 · 繁體中文 · 日本語

> 还有更多隐藏功能等你发现，也有更多功能在路上。有想法？欢迎提交 [Issue](https://github.com/FoxSensei001/LoveIwara/issues) 或加入 [Telegram 群组](https://t.me/+ITH4CV6Z_sc2ZWVl)。

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
flutter run
# …或指定平台：
flutter run -d windows   # macos / linux / android / ios
```

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
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android AAB
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

**4. 构建** —— `flutter build apk --release`，产物位于 `build/app/outputs/flutter-apk/app-release.apk`。

</details>

## 🌍 国际化

目前的翻译大多由机器生成。如果你愿意协助改进，请从简体中文模板入手：[`lib/i18n/zh-CN.i18n.yaml`](lib/i18n/zh-CN.i18n.yaml)，然后运行 `dart run slang`。

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
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara" alt="项目贡献者" />
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
