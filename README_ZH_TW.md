<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**一款以 Flutter 打造、快速又美觀的 Iwara 第三方跨平台用戶端。**

一套程式碼 → Android · Windows · macOS · Linux · iOS

[![Telegram 群組](https://img.shields.io/badge/Telegram-群組-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
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

[English](README.md) · [简体中文](README_ZH.md) · **繁體中文** · [日本語](README_JA.md)

</div>

---

## 🌟 簡介

**Love Iwara**（又稱 `i_iwara` 或 **2i**）是以 Flutter 開發的 [Iwara](https://www.iwara.tv) 第三方用戶端。目標是在手機、平板與桌面上都提供順暢、接近原生的使用體驗——而且全部來自同一套程式碼，涵蓋 **Android、Windows、macOS、Linux 與 iOS**。

> [!NOTE]
> 本專案最初只是個學習專案——我第一次嘗試開發跨平台 Flutter 應用程式。有些程式碼可能還不夠完善，但它持續在維護，功能也相當豐富。如果你也在學 Flutter，希望我們可以一起成長。歡迎送 PR 與回饋！

> [!IMPORTANT]
> **使用限制** —— 本專案僅供學習與個人參考，**不建議用於正式環境**。**嚴禁在任何公開平台上宣傳推廣本專案。** 若有違反，可能會採取停止維護、刪除儲存庫等措施。

> [!WARNING]
> **免責聲明** —— 本應用程式的開發者與 Iwara 及其內容提供者沒有任何關聯，且本應用程式**不存放任何**內容。

## ✨ 功能特色

### 🖥️ 支援平台
| Android | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ | ✅ | ⚠️ *未測試¹* | ✅ |

<sub>¹ Linux 版本可以建置，但因為缺少測試裝置，目前尚未經過測試。</sub>

### 🎥 影片
- 以 **media_kit**（libmpv）驅動的流暢播放
- 畫質選擇 · 播放速度控制（含預設 / 自動速度）· 全螢幕
- 進度條停留與拖曳時顯示**預覽縮圖**
- **可點擊的時間戳**——點選簡介與評論中被標示的時間戳，直接跳到該片段
- **「繼續觀看」**抽屜選單 + 可選的進入影片後自動播放
- 即時載入速度顯示
- 桌面版：把本機影片檔**拖曳**到視窗即可立即播放

### 🌐 瀏覽與探索
- 多分類**搜尋**：影片 · 圖庫 · 貼文 · 使用者 · 論壇
- 執行期間在 `iwara.tv` 與 `iwara.ai` 之間**切換站台**
- 整合**最新消息**（`news.iwara.tv`）
- 整合 **Oreno3d** 標籤來源，提供更豐富的影片標籤
- 訂閱、多樣的篩選條件，以及適用於桌面／平板的響應式版面

### 🖼️ 圖庫
- 圖片瀏覽，支援流暢的縮放與平移
- 圖庫檢視器支援畫質設定

### 💬 社群
- **論壇**：建立與編輯主題和回覆
- **貼文**：瀏覽與留言
- **評論**：瀏覽與回覆
- **私訊**：瀏覽與回覆
- **站內通知**：瀏覽與回覆

### 👤 帳號與分享
- 使用者驗證、個人資料管理、追蹤系統
- **分享**影片 / 圖庫 / 貼文 / 主題 / 使用者
- Android 深層連結轉接：在其他 App 中開啟 Iwara 連結時會跳回 2i 繼續瀏覽

### 🗂️ 本機資料與實用功能
- **瀏覽紀錄**（本機）：影片 · 圖庫 · 貼文 · 論壇
- **本機收藏**，可自訂收藏資料夾
- **下載** *(Beta)*：影片 / 圖庫 / 單一檔案，可自訂路徑（含 Android 外接 SD/TF 卡）
- **備份與還原**：匯出 / 匯入設定與瀏覽紀錄
- **翻譯**：影片簡介、貼文、評論、論壇、對話等
- **應用程式鎖**：PIN／生物辨識
- 「記住上次音量」選項（PC）

### 🌍 多國語言
English · 简体中文 · 繁體中文 · 日本語

> 還有更多隱藏功能等你挖掘，也有更多功能正在路上。有想法嗎？歡迎開 [Issue](https://github.com/FoxSensei001/LoveIwara/issues) 或加入 [Telegram 群組](https://t.me/+ITH4CV6Z_sc2ZWVl)。

## 🧰 技術架構

| 面向 | 函式庫 |
|---|---|
| 框架 | **Flutter** + Dart |
| 狀態管理 | **GetX** (`get`) |
| 路由 | **go_router** |
| 網路 | **Dio**（+ CookieJar / Cloudflare 攔截器） |
| 影片 | **media_kit**（libmpv） |
| 本機儲存 | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| 多語系 | **slang** |
| 桌面外框 | **window_manager**（自訂標題列、拖放） |

## 📸 畫面截圖

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

## 🚀 快速開始

```bash
# 1. 複製儲存庫
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. 檢查開發工具鏈
flutter doctor

# 3. 安裝相依套件
flutter pub get

# 4. 執行（自動選擇已連接的裝置）
flutter run
# …或指定平台：
flutter run -d windows   # macos / linux / android / ios
```

> [!TIP]
> 修改任何 `lib/i18n/*.i18n.yaml` 之後，請執行 `dart run slang` 重新產生多語系字串。
> 完整的相依套件請見 [`pubspec.yaml`](pubspec.yaml) —— 少數套件需要額外的設定步驟。

<details>
<summary><b>🛠️ 完整開發環境設定</b></summary>

### 事前準備
- Flutter SDK（建議使用最新穩定版）· Dart SDK · Git
- 建議的 IDE：Android Studio / VS Code / Cursor + Flutter 外掛

### 各平台需求

**Windows**
- Windows 10 以上（64 位元）、Visual Studio 2022 以上、Windows 10 SDK
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

**Android** —— Android Studio + Android SDK + 模擬器／實機
**iOS** —— Xcode + 模擬器／實機 + Apple 開發者帳號（上架時需要）

### 建置發行版本
```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android AAB
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### 常用指令
```bash
dart run slang     # 重新產生多語系字串
flutter analyze    # 靜態分析
flutter test       # 執行測試
flutter clean      # 清除建置快取
flutter devices    # 列出已連接的裝置
```

### 疑難排解
```bash
# 相依套件衝突
flutter pub cache repair && flutter clean && flutter pub get
# 模擬器
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Android 簽署設定</b></summary>

若要建置已簽署的發行版 APK：

**1. 產生 keystore**（在 `android/app` 目錄下執行）：
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
請確認 `keystore.jks` 最後放在 `android/app` 目錄中。

**2. 設定簽署資訊**（`android/app/build.gradle`）：
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
並在 `android/gradle.properties` 中加入佔位變數：
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** —— 在儲存庫的 Secrets 中新增：`KEYSTORE_BASE64`（`keystore.jks` 的 base64）、`KEYSTORE_PASSWORD`、`KEY_ALIAS`、`KEY_PASSWORD`。接著在 `.github/workflows/build.yml` 中：
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

**4. 建置** —— 執行 `flutter build apk --release`，產物位於 `build/app/outputs/flutter-apk/app-release.apk`。

</details>

## 🌍 多語系

目前的翻譯大多由機器產生。如果你願意幫忙改進，請從簡體中文範本開始：[`lib/i18n/zh-CN.i18n.yaml`](lib/i18n/zh-CN.i18n.yaml)，接著執行 `dart run slang`。

### 🏷️ Iwara 標籤在地化

Iwara 的原始標籤是英文式的 key（例如 `mother`、`blue_archive`）。App 內建了一份由社群維護的詞庫，把每個標籤對應到 **簡體中文 / 繁體中文 / 日文 / 英文**，因此在詳情頁、搜尋和標籤列表頁都會以你目前的語言顯示標籤。

運作方式：

- **詞庫**：位於 [`tool/data/iwara_tags/`](tool/data/iwara_tags/)，App 實際使用的是合併壓縮後的 [`iwara_tags.min.json`](tool/data/iwara_tags/iwara_tags.min.json)。
- **發布方式**：隨 App 內建一份離線備援（`assets/data/iwara_tags.min.json`），並透過 jsDelivr CDN 熱更新——因此**不必重新發布新版本**也能改善用詞。
- **App 內**：標籤 chip 會顯示譯名；詳情頁標籤卡片的展開／收合那一列有一個圖示按鈕，可在 **原始 key ⇄ 譯文** 之間切換；長按／右鍵點擊標籤（或在標籤列表頁點選標籤標題）會開啟對話框，同時顯示譯文與原始 key、複製按鈕以及回報連結。

這些是針對 2600 多個 ACG / Vtuber / NSFW 詞彙的盡力翻譯，可能會有錯誤。

> **發現翻譯有誤或不通順？** 歡迎在專屬的 issue 回報：**https://github.com/FoxSensei001/LoveIwara/issues/98**（App 內的標籤對話框也會連到這裡）。

**送出修正**（給維護者／貢獻者）：

1. 編輯人類可讀的 [`iwara_tags_localized.json`](tool/data/iwara_tags/iwara_tags_localized.json)（每個標籤的 `zh-CN` / `zh-TW` / `ja` / `en`）。
2. 重新產生合併後的產物與內建資源：`dart run tool/data/iwara_tags/build_localized_min.dart`。
3. 原始檔與產生的 `iwara_tags.min.json` 都要一起提交（詳見 [`tool/data/iwara_tags/README.md`](tool/data/iwara_tags/README.md)）。

第三方 **Oreno3d** 的中繼資料（原作 / 角色 / 標籤）也用同樣的方式在地化——詞庫位於 [`tool/data/oreno3d_tags/`](tool/data/oreno3d_tags/)，內建資源 + jsDelivr CDN，會在影片詳情頁與搜尋卡片上以你目前的語言顯示。

## 🙏 致謝

本專案在開發過程中受到以下優秀專案的啟發，也從中學到許多實作方式與最佳實務：

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
      <sub>優秀的 Flutter 版 Iwara 用戶端</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>結構良好的 Flutter 漫畫應用程式</sub>
    </td>
  </tr>
</table>

</div>

### 專案貢獻者

感謝每一位為本專案付出的人！🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara" alt="專案貢獻者" />
</a>

</div>

<sub>由 [contrib.rocks](https://contrib.rocks) 產生</sub>

## 🤝 參與貢獻

歡迎送出 Pull Request！如果是比較大的更動，請先開一個 issue 討論你想改的內容。回報新問題之前，請先看看既有的 [issues](https://github.com/FoxSensei001/LoveIwara/issues)。有任何疑問嗎？歡迎加入我們的 [Telegram 群組](https://t.me/+ITH4CV6Z_sc2ZWVl)。

## 💬 交流社群

加入我們的 Telegram 社群：**[點此加入群組](https://t.me/+ITH4CV6Z_sc2ZWVl)**。

---

<div align="center">
<sub>以 ❤️ 與 Flutter 打造 · 這是粉絲自製的用戶端，請支持 Iwara 官方。</sub>
</div>
