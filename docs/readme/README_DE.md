<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="../../assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**Ein schneller, schöner, plattformübergreifender Drittanbieter-Client für Iwara, gebaut mit Flutter.**

Eine Codebasis → Android · Meta Quest · Windows · macOS · Linux · iOS

[![Telegram Gruppe](https://img.shields.io/badge/Telegram-Gruppe-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
[![GitHub stars](https://img.shields.io/github/stars/FoxSensei001/LoveIwara?label=stars&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara)
[![GitHub forks](https://img.shields.io/github/forks/FoxSensei001/LoveIwara?label=forks&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara)
[![Latest release](https://img.shields.io/github/v/release/FoxSensei001/LoveIwara?label=release&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/FoxSensei001/LoveIwara/total?label=downloads&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/releases)
[![License: MIT](https://img.shields.io/github/license/FoxSensei001/LoveIwara?labelColor=27303D&color=0877d2)](../../LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/FoxSensei001/LoveIwara?labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/issues)

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-^3.8-0175C2?style=flat&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)
![Meta Quest](https://img.shields.io/badge/Meta_Quest-Horizon_OS-0467DF?style=flat&logo=meta&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0id2hpdGUiPjxwYXRoIGQ9Ik0wIDBoMTEuMzc3djExLjM3Mkgwek0xMi42MjMgMEgyNHYxMS4zNzJIMTIuNjIzek0wIDEyLjYyM2gxMS4zNzdWMjRIMHpNMTIuNjIzIDEyLjYyM0gyNFYyNEgxMi42MjN6Ii8%2BPC9zdmc%2B)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![iOS](https://img.shields.io/badge/iOS-000000?style=flat&logo=apple&logoColor=white)

[English](../../README.md) · [日本語](README_JA.md) · [简体中文](README_ZH.md) · [繁體中文](README_ZH_TW.md) · [한국어](README_KO.md) · [ภาษาไทย](README_TH.md) · [Bahasa Indonesia](README_ID.md) · [Tiếng Việt](README_VI.md) · [Español](README_ES.md) · [Русский](README_RU.md) · [Français](README_FR.md) · **Deutsch**

</div>

---

## 🌟 Einführung

**Love Iwara** (auch bekannt als `i_iwara` oder **2i**) ist ein von Iwara unabhängiger Drittanbieter-Client für [Iwara](https://www.iwara.tv), gebaut mit Flutter. Ziel ist eine flüssige, nativ wirkende Erfahrung auf Smartphones, Tablets und Desktops zu bieten — alles aus einer einzigen Codebasis, die **Android, Meta Quest, Windows, macOS, Linux und iOS** abdeckt.

> [!NOTE]
> Dieses Projekt begann als Lernprojekt — mein erster Versuch, eine plattformübergreifende Flutter-App zu bauen. Manche Codestellen sind vielleicht nicht perfekt ausgefeilt, aber das Projekt wird aktiv gepflegt und steckt voller Funktionen. Wenn du ebenfalls Flutter lernst, hoffe ich, dass wir gemeinsam wachsen können. PRs und Feedback sind jederzeit willkommen!

> [!IMPORTANT]
> **Nutzungseinschränkungen** — Dieses Projekt dient ausschließlich dem Lernen und der persönlichen Nutzung und wird **nicht für den Produktivbetrieb empfohlen**. **Die Bewerbung dieses Projekts auf öffentlichen Plattformen ist strikt untersagt.** Verstöße können dazu führen, dass die Pflege eingestellt und das Repository entfernt wird.

> [!WARNING]
> **Haftungsausschluss** — Die Entwickler stehen in keinerlei Verbindung zu Iwara oder dessen Inhalteanbietern. Diese Anwendung hostet **keinerlei** eigene Inhalte.

## ✨ Funktionen

### 🖥️ Plattformen
| Android | Meta Quest | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ *separate APK¹* | ✅ | ✅ | ⚠️ *ungetestet²* | ✅ |

<sub>¹ Der Quest-Build ist eine eigenständige arm64-APK für Horizon OS (Android 14+) mit dem Meta Spatial SDK — siehe [Meta Quest / VR](#-meta-quest--vr). Die reguläre Android-APK ist davon nicht betroffen und unterstützt weiterhin Android 7.0+.</sub>
<sub>² Linux-Builds werden erstellt, sind aber mangels Testgeräten derzeit ungetestet.</sub>

### 🎥 Video
- Flüssige Wiedergabe dank **media_kit** (libmpv)
- Qualitätsauswahl · Steuerung der Wiedergabegeschwindigkeit (inkl. einer Standard-/Auto-Geschwindigkeit) · Vollbild
- **Sprungvorschau**-Miniaturbilder beim Überfahren oder Ziehen der Fortschrittsleiste
- **Anklickbare Zeitstempel** — springe direkt zu einem Moment über hervorgehobene Zeitstempel in Beschreibungen und Kommentaren
- **„Weiterschauen"**-Leiste + optionale automatische Wiedergabe beim Öffnen eines Videos
- Live-Anzeige der Ladegeschwindigkeit
- **Panoramaansicht auf flachen Bildschirmen** — eine VR180-/360°-Datei wird sonst als zwei gestauchte Hälften angezeigt; hier erhältst du stattdessen eine korrekt proportionierte Ansicht, die du ziehen kannst, um dich umzusehen. Iwaras Dateien enthalten überhaupt keine sphärischen Metadaten, das Format wird also heuristisch erraten — korrigiere es von Hand, und die Korrektur wird für dieses Video gemerkt
- **„Betrachtungsabstand"** — halte gedrückt, um das Bild wegzuschieben oder näher heranzuziehen (Bildzoom bei flachem Video, Sichtfeld bei Panoramavideo)
- **In anderer App öffnen** — gib das aktuelle Video an MX Player / VLC, an einen VR-Player wie Skybox oder Pigasus oder an einen benutzerdefinierten externen Player am Desktop weiter; bevorzugt eine lokale oder bereits heruntergeladene Datei, mit „Link kopieren" als Rückfalloption
- Desktop: lokale Videodateien per **Drag & Drop** auf das Fenster ziehen, um sie sofort abzuspielen

### 🥽 Meta Quest / VR
*Wird als separate `quest`-APK ausgeliefert, gebaut auf dem Meta Spatial SDK. Der reguläre Android-Build ist damit in keiner Weise verknüpft, und dessen `minSdk` bleibt unverändert.*

**Die App lebt in einer räumlichen Umgebung.** Der Start vom Quest-Home führt dich direkt in einen dauerhaft aktiven, immersiven Raum. Die gesamte App — Durchsuchen, Suche, Kommentare, Bildschirmtastatur — schwebt als 2D-Panel vor dir; nichts davon ist beschnitten. Das Panel ist **sanft gekrümmt** (ein 30°-Bogen — bei der Standardbreite von 1,6 m etwa vergleichbar mit einem Monitor mit „3000R"-Krümmung). Fix ist dabei der Bogen, nicht der Radius, daher sieht die Krümmung immer gleich aus, egal wie breit oder schmal du das Fenster ziehst.

**Drei Fenster, ein Gestensatz.** Das App-Panel, der Bildschirm und das Steuerungspanel besitzen jeweils einen eigenen Rahmen: Der Greif-Trigger zieht ein Fenster am Körper, die Kanten ziehen es, die Ecken skalieren es um seinen Mittelpunkt, und die Fenster richten sich stets zu dir aus. Größen und Positionen werden gemerkt. Nichts erscheint, bevor sich das Head-Tracking stabilisiert hat — kein Fenster blitzt an der falschen Stelle auf, um dann zu springen.

**Der Player wird zu einem Bildschirm im Raum.** Öffnest du ein Video, wechselt die App automatisch dorthin (optional).
- **Bildschirmform** — flach oder eine von drei Krümmungsstufen. Abstand, Breite und Seitenverhältnis sind einstellbar und werden *pro Seitenverhältnis* gemerkt, sodass beim Zurückkehren zu einem 4:3-Clip genau das Layout wiederhergestellt wird, das du für 4:3 eingestellt hattest.
- **Videoformate** — 2D / 3D, halbes und volles Side-by-Side, halbes und volles Over-Under, äquirektangulär 180° und 360°; werden automatisch aus der Datei erkannt und lassen sich von Hand korrigieren. EAC und Fisheye werden erkannt, als nicht unterstützt gekennzeichnet und stattdessen an einen externen Player weitergereicht.
- **Wiedergabe** — Geschwindigkeit 0,5×–3,0×, Schleife, Lautstärke, eine Scrub-Vorschau mit Zielzeit und Differenz, eine Pufferanzeige direkt auf dem Bildschirm sowie Uhrzeit und Akkustand auf dem Panel.
- **„Weiterschauen" im Raum selbst** — dieselben in Abschnitte gegliederten Video-Pools wie in der 2D-App (Quellenliste, Abonnements, Playlists, Favoriten, Downloads, Später ansehen), mit Vorschaubildern. Videos wechseln, ohne den Raum zu verlassen; falls das nächste Video nicht lädt, zeigt das Panel einen Ladezustand und setzt das vorherige Video zurück.
- **Ablaufende Links werden behandelt** — Quellen werden vor Ablauf erneuert, und ein 404-Fehler mitten in der Wiedergabe löst eine Erneuerung aus und setzt dort fort, wo du warst.
- **Szenen** — Passthrough oder eine Leere.

**Räumliche Galerie.** Eine Galerie öffnet sich als eine große Bühne plus ein Filmstreifen, sodass ein Satz von Dutzenden Bildern — samt der dazwischen gemischten Videos — ein einziges Objekt bleibt statt Dutzender Ebenen. Diashow mit 3 / 5 / 10 / 20 s, Standard- oder Originalqualität, sowie ein seitliches Ziehen auf der Bühne zum Umblättern. Hochformatbilder werden in einen 16:9-Rahmen eingepasst, damit eine 9:16-Illustration dich nicht überragt.

**Hände oder Controller.**
- *Hände* — der offizielle Strahl und die Zwei-Finger-Geste. Ein Zwei-Finger-Griff irgendwo außerhalb der Panels schaltet das Steuerungspanel um.
- *Controller* — A/X spielt ab/pausiert, B/Y schließt das Panel oder kehrt zur App zurück, Menu öffnet die Einstellungen. Der Greif-Trigger fasst den Bildschirm, ohne dass man darauf zielen muss. Der Stick scrubbt mit Beschleunigung nach links/rechts (ein Antippen entspricht 5 s; gehalten, beschleunigt es auf bis zu 15 Minuten pro Sekunde) und schiebt den Bildschirm nach oben/unten näher heran oder weiter weg.
- Das Absetzen des Headsets pausiert die Wiedergabe, und das erneute Aufsetzen setzt sie fort; ein System-Recenter platziert alles wieder vor dir.

**Der erste Start beginnt mit einer Lektion.** Die Erstanleitung des Headsets ist nicht die vom Touchscreen übernommene Version („zum Zoomen kneifen, für Geschwindigkeit halten") — im Raum gibt es kein berührbares Bild. Stattdessen gibt es zwei Kurse, **räumliches Video** und **räumliche Galerie**: Eine Controller-Illustration animiert Bild für Bild zusammen mit ihren Tasten und dem Stick, Bildschirm, Panels und Strahlen sitzen in ihrer tatsächlichen Geometrie, und jede Bewegung wird sowohl für Controller als auch für bloße Hände gezeigt. Ist die Systemoption „Bewegungen reduzieren" aktiv, wird stattdessen ein einzelnes informatives Standbild gezeichnet. Jederzeit über die Einstellungen erneut abspielbar.

### 🌐 Durchsuchen & Entdecken
- Mehrkategorien-**Suche**: Videos · Galerien · Beiträge · Nutzer · Foren
- **Seitenwechsel** zwischen `iwara.tv` und `iwara.ai` zur Laufzeit
- Integration des **News**-Feeds (`news.iwara.tv`)
- Integration der **Oreno3d**-Tag-Quelle für reichhaltigere Video-Tags
- Abonnements, umfangreiche Filterung und responsive Layouts für Desktop/Tablet

### 🖼️ Galerie
- Bildersuche mit flüssigem Zoom & Verschieben
- Galerie-Viewer mit Qualitätseinstellungen

### 💬 Community
- **Forum**: Threads und Antworten erstellen & bearbeiten
- **Beiträge**: durchsuchen & kommentieren
- **Kommentare**: durchsuchen & antworten
- **Private Nachrichten**: durchsuchen & antworten
- **In-App-Benachrichtigungen**: durchsuchen & antworten

### 👤 Konto & Teilen
- Nutzerauthentifizierung, Profilverwaltung, Follower-System
- Videos / Galerien / Beiträge / Threads / Nutzer **teilen**
- Android-Deep-Link-Übergabe: Wird ein Iwara-Link in einer anderen App geöffnet, springt er zurück in 2i

### 🗂️ Lokale Daten & Werkzeuge
- **Verlauf** (lokal): Videos · Galerien · Beiträge · Foren
- **Lokale Favoriten** mit benutzerdefinierten Favoritenordnern
- **Downloads** *(Beta)*: Videos / Galerien / einzelne Dateien, mit benutzerdefinierten Pfaden (inkl. externer SD-/TF-Karte auf Android)
- **Sichern & Wiederherstellen**: Export/Import von Konfiguration und Verlauf
- **Übersetzung** von Beschreibungen, Beiträgen, Kommentaren, Foren, Unterhaltungen und mehr
- **App-Sperre** per PIN / Biometrie
- Option „Letzte Lautstärke merken" (PC)

### 🌍 Mehrsprachig
**Oberfläche in 12 Sprachen** — English · 简体中文 · 繁體中文 · 日本語 · 한국어 · ภาษาไทย · Bahasa Indonesia · Tiếng Việt · Español · Русский · Français · Deutsch — einschließlich der räumlichen Panels auf Quest, die der App-Sprache und nicht der Systemsprache folgen. Iwara-/Oreno3d-Tag-Namen sind nur für eine kleinere Teilmenge dieser Sprachen übersetzt — siehe [unten](#-internationalisierung).

> Noch etwas anderes entdeckt? Es gibt noch mehr verborgene Perlen zu finden — und weitere sind in Arbeit. Eine Idee? Eröffne ein [Issue](https://github.com/FoxSensei001/LoveIwara/issues) oder schau in der [Telegram-Gruppe](https://t.me/+ITH4CV6Z_sc2ZWVl) vorbei.

## 🗺️ Roadmap

**Die Quest-Unterstützung ist bereits da** — siehe [Meta Quest / VR](#-meta-quest--vr) oben. Sie wird als eigene APK ausgeliefert, die von einem eigenen CI-Job erzeugt wird, und der reguläre Android-Build bleibt unberührt.

Auf der Headset-Seite noch offen:

- Der GPU-Speicher-Freigabepfad für räumliche Panels wirkt noch nicht effektiv.
- Die räumliche Szene teilt sich den Hauptthread mit Flutter; die dadurch entstehenden Frame-Kosten wurden bislang nie gemessen.
- Das App-Panel basiert auf einer Activity und sollte auf ein View-basiertes Panel migriert werden, das laut offizieller Anleitung als die leichtere Variante gilt.
- EAC- und Fisheye-Projektionen werden erkannt, aber an einen externen Player weitergereicht statt gerendert.

Ansonsten: Downloads sind weiterhin als Beta gekennzeichnet, und Linux wird zwar gebaut, ist aber mangels Testrechner ungetestet.

Hast du einen Wunsch? Eröffne ein [Issue](https://github.com/FoxSensei001/LoveIwara/issues) oder schau in der [Telegram-Gruppe](https://t.me/+ITH4CV6Z_sc2ZWVl) vorbei.

## 🧰 Tech-Stack

| Bereich | Bibliothek |
|---|---|
| Framework | **Flutter** + Dart |
| Zustandsverwaltung | **GetX** (`get`) |
| Routing | **go_router** |
| Netzwerk | **Dio** (+ CookieJar-/Cloudflare-Interceptors) |
| Video | **media_kit** (libmpv) |
| Persistenz | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| i18n | **slang** |
| Desktop-Shell | **window_manager** (eigene Titelleiste, Drag & Drop) |

## 📸 Screenshots

### 🥽 Meta Quest

| Der Bildschirm und sein Steuerungspanel | Eine Galerie: eine Bühne plus ein Filmstreifen |
|:-------------------------:|:-------------------------:|
|<img src="../imgs/vr_video.jpg" width="420">|<img src="../imgs/gallery_quest.jpg" width="420">|

### 📱 Smartphone & Desktop

| | |
|:-------------------------:|:-------------------------:|
|<img src="../imgs/home_screen.png" width="300">|<img src="../imgs/forum_page.png" width="300">|
|<img src="../imgs/gallery.png" width="300">|<img src="../imgs/gallery_detail.png" width="300">|
|<img src="../imgs/local_page.png" width="300">|<img src="../imgs/search_page.png" width="300">|
|<img src="../imgs/search_result_page.png" width="300">|<img src="../imgs/settings_page.png" width="300">|
|<img src="../imgs/sub_page.png" width="300">|<img src="../imgs/thread_detail.png" width="300">|
|<img src="../imgs/user_detail_page.png" width="300">|<img src="../imgs/video_detail.png" width="300">|

## 🚀 Schnellstart

```bash
# 1. Klonen
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. Toolchain prüfen
flutter doctor

# 3. Abhängigkeiten installieren
flutter pub get

# 4. Starten (wählt automatisch ein verbundenes Gerät aus)
flutter run --flavor standard   # Android benötigt einen Flavor — siehe Hinweis unten
# …oder eine Plattform gezielt ansprechen (Desktop/iOS brauchen keinen Flavor):
flutter run -d windows   # macos / linux / ios
```

> [!IMPORTANT]
> **Android wird mit zwei Product-Flavors ausgeliefert.** `standard` ist der reguläre Build für Smartphone/Tablet (`minSdk 24`,
> alle ABIs); `quest` ist der Build für Meta Quest / Horizon OS (`minSdk 34`, nur arm64, enthält das
> ~50 MB große Meta Spatial SDK). Sobald Flavors existieren, kennt AGP keine „ohne Flavor"-Variante mehr, daher muss
> **jeder Android-`flutter run`/`flutter build`-Aufruf `--flavor` übergeben** — ein nackter Befehl schlägt sofort fehl.

> [!TIP]
> Nach dem Bearbeiten einer `lib/i18n/*.i18n.yaml`-Datei die Lokalisierungsstrings mit `dart run slang` neu generieren.
> Die vollständige Abhängigkeitsliste steht in [`pubspec.yaml`](../../pubspec.yaml) — einige Pakete benötigen zusätzliche Einrichtungsschritte.

<details>
<summary><b>🛠️ Vollständige Einrichtung der Entwicklungsumgebung</b></summary>

### Voraussetzungen
- Flutter SDK (aktuelle stabile Version empfohlen) · Dart SDK · Git
- Empfohlene IDE: Android Studio / VS Code / Cursor + Flutter-Plugin

### Plattformspezifische Anforderungen

**Windows**
- Windows 10+ (64-Bit), Visual Studio 2022+, Windows 10 SDK
```bash
flutter doctor -v
```

**macOS**
- Aktuelles macOS + Xcode + CocoaPods
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

**Android** — Android Studio + Android SDK + Emulator/Gerät
**iOS** — Xcode + Simulator/Gerät + Apple-Developer-Konto (für die Veröffentlichung)

### Release-Binaries bauen
```bash
flutter build apk --release --flavor standard         # Android-APK (Smartphones / Tablets)
flutter build appbundle --release --flavor standard   # Android-AAB
flutter build apk --release --flavor quest --target-platform android-arm64   # Meta-Quest-APK
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### Nützliche Befehle
```bash
dart run slang     # i18n-Strings neu generieren
flutter analyze    # Linting
flutter test       # Tests ausführen
flutter clean      # Build-Cache leeren
flutter devices    # verbundene Geräte auflisten
```

### Fehlerbehebung
```bash
# Abhängigkeitskonflikte
flutter pub cache repair && flutter clean && flutter pub get
# Emulator
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Android-Signierungskonfiguration</b></summary>

So baust du eine signierte Release-APK:

**1. Keystore erzeugen** (innerhalb von `android/app` ausführen):
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
Stelle sicher, dass `keystore.jks` in `android/app` landet.

**2. Signierung konfigurieren** in `android/app/build.gradle`:
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
Und die Platzhalter in `android/gradle.properties` ergänzen:
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** — Repository-Secrets hinzufügen: `KEYSTORE_BASE64` (Base64 von `keystore.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. Dann in `.github/workflows/build.yml`:
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

**4. Build** — `flutter build apk --release --flavor standard` → Ergebnis in `build/app/outputs/flutter-apk/app-standard-release.apk`. Für den Quest-Build: `flutter build apk --release --flavor quest --target-platform android-arm64` → `app-arm64-v8a-quest-release.apk`.

</details>

## 🌍 Internationalisierung

Die Oberfläche ist inzwischen in **12 Sprachen** verfügbar; die Übersetzungen sind größtenteils maschinell erstellt, mit Ausnahme der ursprünglichen vier (English / 简体中文 / 繁體中文 / 日本語), die von Menschen geprüft wurden. Wenn du helfen möchtest, eine Übersetzung zu verbessern, starte mit der Vorlage in vereinfachtem Chinesisch: [`lib/i18n/zh-CN.i18n.yaml`](../../lib/i18n/zh-CN.i18n.yaml) und führe danach `dart run slang` aus. Den vollständigen Status pro Sprache sowie die Pflege-Befehle findest du in **[`docs/i18n/README.md`](../i18n/README.md)** (auf Chinesisch).

### 🏷️ Lokalisierung der Iwara-Tags

Die rohen Tags von Iwara sind englisch anmutende Schlüssel (z. B. `mother`, `blue_archive`). Die App bringt ein von der Community gepflegtes Wörterbuch mit, das jedes Tag auf **vereinfachtes Chinesisch / traditionelles Chinesisch / Japanisch / Englisch** abbildet, sodass Tags auf Detailseiten, in der Suche und auf der Tag-Listenseite in deiner aktuellen Sprache dargestellt werden.

So funktioniert es:

- **Wörterbuch**: liegt in [`tool/data/iwara_tags/`](../../tool/data/iwara_tags/). Die App nutzt die zusammengeführte, minifizierte Datei [`iwara_tags.min.json`](../../tool/data/iwara_tags/iwara_tags.min.json).
- **Verteilung**: als Offline-Fallback gebündelt (`assets/data/iwara_tags.min.json`) und per Hot-Update über das jsDelivr-CDN aktualisiert — die Formulierungen können sich also **ohne neuen App-Build** verbessern.
- **In der App**: Tag-Chips zeigen den lokalisierten Namen. Auf der Tag-Karte einer Detailseite gibt es in der Ein-/Ausklapp-Zeile eine Icon-Schaltfläche zum Umschalten zwischen **Originalschlüssel ⇄ Übersetzung**; langes Drücken/Rechtsklick auf ein Tag (oder Tippen auf den Tag-Titel auf der Tag-Listenseite) öffnet einen Dialog mit Übersetzung und Originalschlüssel, Kopier-Schaltflächen und einem Feedback-Link.

Es handelt sich um nach bestem Wissen erstellte Übersetzungen von über 2600 ACG-/Vtuber-/NSFW-Begriffen, die Fehler enthalten können.

> **Eine falsche oder unpassende Übersetzung entdeckt?** Bitte melde sie im dafür vorgesehenen Issue: **https://github.com/FoxSensei001/LoveIwara/issues/98** (auch der In-App-Tag-Dialog verlinkt hierher).

**Eine Korrektur beisteuern** (für Maintainer/Contributor):

1. Bearbeite die menschenlesbare Datei [`iwara_tags_localized.json`](../../tool/data/iwara_tags/iwara_tags_localized.json) (pro Tag `zh-CN` / `zh-TW` / `ja` / `en`).
2. Regeneriere das zusammengeführte Artefakt und das gebündelte Asset: `dart run tool/data/iwara_tags/build_localized_min.dart`.
3. Committe sowohl die Quelle als auch die generierte Datei `iwara_tags.min.json` (siehe [`tool/data/iwara_tags/README.md`](../../tool/data/iwara_tags/README.md)).

Die Drittanbieter-Metadaten von **Oreno3d** (Ursprungswerke / Charaktere / Tags) werden auf dieselbe Weise lokalisiert — Wörterbuch in [`tool/data/oreno3d_tags/`](../../tool/data/oreno3d_tags/), gebündeltes Asset + jsDelivr-CDN, angezeigt in deiner aktuellen Sprache auf der Video-Detailseite und in den Suchkarten.

> [!NOTE]
> Beide oben genannten Tag-Wörterbücher werden **nur für zh-CN / zh-TW / ja / en** gepflegt — sie sind *nicht* auf die übrigen 8 UI-Sprachen (ko / th / id / vi / es / ru / fr / de) ausgeweitet. Es handelt sich um über 2600 ACG-/Vtuber-/Dōjin-Slang-Begriffe, die sich stark auf subkultur-spezifische Formulierungen stützen statt auf wörtliche Übersetzung; würde man KI-Übersetzung auf 12 Sprachen ausweiten, ohne dass jemand das Ergebnis prüfen kann, riskiert man stillschweigend falsche Tags, die niemand bemerkt. In UI-Sprachen außerhalb dieser vier werden Tags nicht in diese Sprache übersetzt — sie fallen stattdessen auf den **englischen** Namen aus dem Wörterbuch zurück (z. B. `mother` → `Mother`). Nur ein Tag, das im Wörterbuch komplett fehlt, fällt auf seinen rohen Schlüssel zurück, und das passiert unabhängig von der UI-Sprache. Details und Gründe: [`docs/i18n/README.md`](../i18n/README.md).

## 🙏 Danksagungen

Dieses Projekt hat sich von folgenden hervorragenden Repositories inspirieren lassen und viele bewährte Praktiken von ihnen gelernt:

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
      <sub>Ausgezeichneter, in Flutter implementierter Iwara-Client</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>Gut strukturierte Comic-Anwendung in Flutter</sub>
    </td>
  </tr>
</table>

</div>

### Contributors

Danke an alle, die beigetragen haben! 🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara&max=100" alt="Contributors" />
</a>

</div>

<sub>Erstellt mit [contrib.rocks](https://contrib.rocks)</sub>

## 🤝 Mitwirken

Pull Requests sind willkommen! Eröffne bei größeren Änderungen zunächst ein Issue, um zu besprechen, was du ändern möchtest. Bevor du ein neues Issue meldest, schau in den bestehenden [Issues](https://github.com/FoxSensei001/LoveIwara/issues) nach. Fragen? Tritt unserer [Telegram-Gruppe](https://t.me/+ITH4CV6Z_sc2ZWVl) bei.

## 💬 Community

Triff uns auf Telegram: **[Hier klicken, um der Gruppe beizutreten](https://t.me/+ITH4CV6Z_sc2ZWVl)**.

---

<div align="center">
<sub>Erstellt mit ❤️ und Flutter · Dies ist ein von Fans erstellter Client — bitte unterstütze das offizielle Iwara.</sub>
</div>
