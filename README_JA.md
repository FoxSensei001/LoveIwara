<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**Flutter で作られた、高速で美しいクロスプラットフォームの Iwara サードパーティクライアント。**

ひとつのコードベースで → Android · Windows · macOS · Linux · iOS

[![Telegram グループ](https://img.shields.io/badge/Telegram-グループ-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
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

[English](README.md) · [简体中文](README_ZH.md) · [繁體中文](README_ZH_TW.md) · **日本語**

</div>

---

## 🌟 概要

**Love Iwara**（別名 `i_iwara`、**2i**）は、Flutter で構築された [Iwara](https://www.iwara.tv) のサードパーティクライアントです。スマートフォン・タブレット・デスクトップのいずれでも、ネイティブに近いなめらかな体験を提供することを目指しています。しかもすべては単一のコードベースから作られ、**Android・Windows・macOS・Linux・iOS** に対応しています。

> [!NOTE]
> このプロジェクトは学習目的から始まりました——クロスプラットフォームの Flutter アプリを作る最初の挑戦です。洗練されていないコードもあるかもしれませんが、現在も活発にメンテナンスされており、機能も豊富です。Flutter を学んでいる方とは、ぜひ一緒に成長できればと思います。PR やフィードバックはいつでも歓迎です！

> [!IMPORTANT]
> **利用上の制限** —— 本プロジェクトは学習および個人的な参考のみを目的としており、**本番環境での利用は推奨しません**。**いかなる公開プラットフォームでの宣伝・拡散も固く禁止します。** 違反があった場合、メンテナンスの停止やリポジトリの削除といった措置を取ることがあります。

> [!WARNING]
> **免責事項** —— 開発者は Iwara およびそのコンテンツ提供者と一切関係がありません。本アプリはコンテンツを**一切ホストしていません**。

## ✨ 機能

### 🖥️ 対応プラットフォーム
| Android | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ | ✅ | ⚠️ *未検証¹* | ✅ |

<sub>¹ Linux 版はビルドされていますが、テスト用の端末がないため現時点では未検証です。</sub>

### 🎥 動画
- **media_kit**（libmpv）によるなめらかな再生
- 画質の選択 · 再生速度の変更（デフォルト／自動速度を含む）· 全画面表示
- シークバーのホバー・ドラッグ時に表示される**プレビューサムネイル**
- **クリックできるタイムスタンプ**——説明文やコメント内で強調されたタイムスタンプから、その場面へ直接ジャンプ
- **「続きから見る」**ドロワー ＋ 動画を開いたときの自動再生（任意）
- 読み込み速度のリアルタイム表示
- デスクトップ：ローカルの動画ファイルをウィンドウに**ドラッグ＆ドロップ**するだけですぐ再生

### 🌐 閲覧と発見
- カテゴリ別の**検索**：動画 · ギャラリー · 投稿 · ユーザー · フォーラム
- 実行中に `iwara.tv` と `iwara.ai` の**サイト切り替え**
- **ニュース**（`news.iwara.tv`）との連携
- **Oreno3d** のタグソースと連携し、より充実した動画タグを表示
- 購読、豊富な絞り込み、デスクトップ／タブレット向けのレスポンシブレイアウト

### 🖼️ ギャラリー
- なめらかなズーム・パンに対応した画像閲覧
- 画質設定に対応したギャラリービューア

### 💬 コミュニティ
- **フォーラム**：スレッドと返信の作成・編集
- **投稿**：閲覧とコメント
- **コメント**：閲覧と返信
- **ダイレクトメッセージ**：閲覧と返信
- **アプリ内通知**：閲覧と返信

### 👤 アカウントと共有
- ユーザー認証、プロフィール管理、フォロー機能
- 動画 / ギャラリー / 投稿 / スレッド / ユーザーの**共有**
- Android のディープリンク連携：他のアプリで Iwara のリンクを開くと 2i に戻って続きを閲覧できます

### 🗂️ ローカルデータとユーティリティ
- **履歴**（ローカル）：動画 · ギャラリー · 投稿 · フォーラム
- **ローカルお気に入り**（フォルダを自由に作成可能）
- **ダウンロード** *(ベータ)*：動画 / ギャラリー / 単体ファイル、保存先の指定にも対応（Android の外部 SD/TF カードを含む）
- **バックアップと復元**：設定と履歴のエクスポート／インポート
- **翻訳**：説明文、投稿、コメント、フォーラム、会話など
- **アプリロック**：PIN／生体認証
- 「前回の音量を記憶する」オプション（PC）

### 🌍 多言語対応
English · 简体中文 · 繁體中文 · 日本語

> ほかにも隠れた機能があり、新しい機能も準備中です。アイデアがあれば [Issue](https://github.com/FoxSensei001/LoveIwara/issues) を立てるか、[Telegram グループ](https://t.me/+ITH4CV6Z_sc2ZWVl) までお気軽にどうぞ。

## 🗺️ 今後の予定

**次の重点は Meta Quest への空間化対応です。** すでに [`claude/vr-format-panorama`](https://github.com/FoxSensei001/LoveIwara/tree/claude/vr-format-panorama) ブランチで着手しており、まだ粗削りでどのリリースにも取り込まれていませんが、主要な流れは Quest 3 実機で動作しています：

- **常駐する没入空間。** Quest のホームからアイコンを押すとそのまま入り、既存の Flutter UI が 2D パネルとして上に浮かびます（没入状態でのソフトキーボードにも対応）。閲覧体験は今のままです。
- **空間化するのはプレイヤー。** パネルで動画を開いて「シアターに入る」を押すと、映像がパネルを離れて空間内のスクリーンになり、専用の空間コントロールバーが付きます。「アプリに戻る」でパネルに戻ります。Equirect 180° の左右方式は実機で描画を確認済みです。
- **ハンドトラッキング操作。** コントロールパネルは 1 枚だけ——上段のボタン列といくつかのサブページ（シーン / プレイリスト / 設定など）、±10 秒、再生速度、投影切替、再センタリング、パススルー——アイドル時は自動的に隠れ、ピンチで呼び出します。
- **独立したビルド flavor。** Quest 版は独自の flavor です。標準版に Spatial SDK は含まれず、`minSdk` も変更しません。

同じブランチには、ヘッドセット以外にも効くものがあります：**ソース形式レイヤーと平面パノラマ表示**です。現在スマホ・タブレット・デスクトップで VR180 / 360° のファイルを開くと、押し潰された 2 つの半分が並んで見えますが、これがあれば正しい比率のビューポートになり、ドラッグで見回せます。Iwara のファイルには球面メタデータが一切ないため形式は推測に頼っており、プレイヤー内でいつでも手動修正でき、その修正はその動画に対して記憶されます。

いずれもまだリリースされておらず、形は変わる可能性があります。0.5.1 は土台を用意しただけです：Quest でアプリの幅が上限で固定される問題を修正し、それまでの間は動画を Skybox や Pigasus などの外部 VR プレイヤーに渡せます。

## 🧰 技術スタック

| 分野 | ライブラリ |
|---|---|
| フレームワーク | **Flutter** + Dart |
| 状態管理 | **GetX** (`get`) |
| ルーティング | **go_router** |
| 通信 | **Dio**（+ CookieJar / Cloudflare インターセプター） |
| 動画 | **media_kit**（libmpv） |
| 永続化 | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| 多言語化 | **slang** |
| デスクトップシェル | **window_manager**（カスタムタイトルバー、ドラッグ＆ドロップ） |

## 📸 スクリーンショット

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

## 🚀 クイックスタート

```bash
# 1. クローン
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. ツールチェーンを確認
flutter doctor

# 3. 依存関係をインストール
flutter pub get

# 4. 実行（接続中のデバイスを自動選択）
flutter run
# …またはプラットフォームを指定：
flutter run -d windows   # macos / linux / android / ios
```

> [!TIP]
> `lib/i18n/*.i18n.yaml` を編集したあとは、`dart run slang` で多言語文字列を再生成してください。
> 依存関係の全体像は [`pubspec.yaml`](pubspec.yaml) を参照してください——いくつかのパッケージには追加のセットアップが必要です。

<details>
<summary><b>🛠️ 開発環境の詳細なセットアップ</b></summary>

### 前提条件
- Flutter SDK（最新の stable 推奨）· Dart SDK · Git
- 推奨 IDE：Android Studio / VS Code / Cursor + Flutter プラグイン

### プラットフォーム別の要件

**Windows**
- Windows 10 以降（64bit）、Visual Studio 2022 以降、Windows 10 SDK
```bash
flutter doctor -v
```

**macOS**
- 最新の macOS + Xcode + CocoaPods
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

**Android** —— Android Studio + Android SDK + エミュレータ／実機
**iOS** —— Xcode + シミュレータ／実機 + Apple Developer アカウント（配布時）

### リリースビルド
```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android AAB
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### よく使うコマンド
```bash
dart run slang     # 多言語文字列を再生成
flutter analyze    # 静的解析
flutter test       # テストを実行
flutter clean      # ビルドキャッシュを削除
flutter devices    # 接続中のデバイス一覧
```

### トラブルシューティング
```bash
# 依存関係の競合
flutter pub cache repair && flutter clean && flutter pub get
# エミュレータ
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Android の署名設定</b></summary>

署名済みのリリース APK をビルドする手順：

**1. keystore を生成**（`android/app` 内で実行）：
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
`keystore.jks` が `android/app` に配置されていることを確認してください。

**2. 署名を設定**（`android/app/build.gradle`）：
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
さらに `android/gradle.properties` にプレースホルダーを追加します：
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** —— リポジトリの Secrets に `KEYSTORE_BASE64`（`keystore.jks` の base64）、`KEYSTORE_PASSWORD`、`KEY_ALIAS`、`KEY_PASSWORD` を追加します。そのうえで `.github/workflows/build.yml` に次を記述します：
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

**4. ビルド** —— `flutter build apk --release` を実行すると、`build/app/outputs/flutter-apk/app-release.apk` に出力されます。

</details>

## 🌍 多言語化

現在の翻訳はほとんどが機械翻訳です。改善に協力していただける場合は、簡体字中国語のテンプレート [`lib/i18n/zh-CN.i18n.yaml`](lib/i18n/zh-CN.i18n.yaml) を起点に編集し、`dart run slang` を実行してください。

### 🏷️ Iwara タグのローカライズ

Iwara の生のタグは英語風のキー（例：`mother`、`blue_archive`）です。本アプリにはコミュニティが管理する辞書が同梱されており、各タグを **簡体字中国語 / 繁体字中国語 / 日本語 / 英語** に対応づけます。そのため詳細ページ・検索・タグ一覧ページでは、現在の言語でタグが表示されます。

仕組み：

- **辞書**：[`tool/data/iwara_tags/`](tool/data/iwara_tags/) にあります。アプリが実際に読み込むのは、マージ・圧縮された [`iwara_tags.min.json`](tool/data/iwara_tags/iwara_tags.min.json) です。
- **配信**：オフライン用のフォールバックとしてアプリに同梱（`assets/data/iwara_tags.min.json`）しつつ、jsDelivr CDN からホットアップデートします——つまり**アプリを再リリースしなくても**訳語を改善できます。
- **アプリ内**：タグのチップには訳語が表示されます。詳細ページのタグカードでは、展開／折りたたみの行にあるアイコンボタンで **元のキー ⇄ 訳語** を切り替えられます。タグを長押し／右クリック（またはタグ一覧ページでタグ名をタップ）すると、訳語と元のキー、コピーボタン、フィードバック用リンクをまとめたダイアログが開きます。

これらは 2600 語以上の ACG / Vtuber / NSFW 用語をできる限り翻訳したもので、誤りが含まれている可能性があります。

> **訳語の誤りや不自然な表現を見つけたら？** 専用の issue で報告してください：**https://github.com/FoxSensei001/LoveIwara/issues/98**（アプリ内のタグダイアログからもここへリンクしています）。

**修正を送る場合**（メンテナー／コントリビューター向け）：

1. 人が読める [`iwara_tags_localized.json`](tool/data/iwara_tags/iwara_tags_localized.json) を編集します（タグごとの `zh-CN` / `zh-TW` / `ja` / `en`）。
2. マージ済みの成果物と同梱アセットを再生成します：`dart run tool/data/iwara_tags/build_localized_min.dart`。
3. ソースと生成された `iwara_tags.min.json` の両方をコミットしてください（[`tool/data/iwara_tags/README.md`](tool/data/iwara_tags/README.md) を参照）。

サードパーティの **Oreno3d** のメタデータ（原作 / キャラクター / タグ）も同じ方法でローカライズされています——辞書は [`tool/data/oreno3d_tags/`](tool/data/oreno3d_tags/) にあり、同梱アセット + jsDelivr CDN で配信され、動画詳細ページと検索カードに現在の言語で表示されます。

## 🙏 謝辞

本プロジェクトは、以下の素晴らしいリポジトリから多くの着想とベストプラクティスを学びました：

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
      <sub>Flutter で実装された優れた Iwara クライアント</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>構成の優れた Flutter 製マンガアプリ</sub>
    </td>
  </tr>
</table>

</div>

### コントリビューター

貢献してくださったすべての皆さんに感謝します！🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara&max=100" alt="コントリビューター" />
</a>

</div>

<sub>[contrib.rocks](https://contrib.rocks) で生成</sub>

## 🤝 コントリビュート

Pull Request を歓迎します！大きな変更を加える場合は、まず issue を作成して内容を相談してください。新しい問題を報告する前に、既存の [issues](https://github.com/FoxSensei001/LoveIwara/issues) を確認してください。質問があれば [Telegram グループ](https://t.me/+ITH4CV6Z_sc2ZWVl) までどうぞ。

## 💬 コミュニティ

Telegram で交流しましょう：**[こちらからグループに参加](https://t.me/+ITH4CV6Z_sc2ZWVl)**。

---

<div align="center">
<sub>❤️ と Flutter で作られました · これはファンメイドのクライアントです。公式の Iwara を応援してください。</sub>
</div>
