<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="../../assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**Un client tiers rapide, élégant et multiplateforme pour Iwara, construit avec Flutter.**

Une seule base de code → Android · Meta Quest · Windows · macOS · Linux · iOS

[![Telegram Groupe](https://img.shields.io/badge/Telegram-Groupe-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
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

[English](../../README.md) · [日本語](README_JA.md) · [简体中文](README_ZH.md) · [繁體中文](README_ZH_TW.md) · [한국어](README_KO.md) · [ภาษาไทย](README_TH.md) · [Bahasa Indonesia](README_ID.md) · [Tiếng Việt](README_VI.md) · [Español](README_ES.md) · [Русский](README_RU.md) · **Français** · [Deutsch](README_DE.md)

</div>

---

## 🌟 Introduction

**Love Iwara** (aussi appelé `i_iwara` ou **2i**) est un client tiers pour [Iwara](https://www.iwara.tv) construit avec Flutter. Il vise à offrir une expérience fluide et proche du natif sur téléphones, tablettes et ordinateurs de bureau — le tout à partir d'une seule base de code couvrant **Android, Meta Quest, Windows, macOS, Linux et iOS**.

> [!NOTE]
> Ce projet a démarré comme un projet d'apprentissage — ma première tentative de création d'une application Flutter multiplateforme. Certaines parties du code ne sont peut-être pas parfaitement soignées, mais le projet est activement maintenu et riche en fonctionnalités. Si vous apprenez Flutter vous aussi, j'espère que nous pourrons progresser ensemble. Les PR et les retours sont toujours les bienvenus !

> [!IMPORTANT]
> **Restrictions d'utilisation** — Ce projet est destiné uniquement à l'apprentissage et à un usage personnel de référence, et **n'est pas recommandé pour une utilisation en production**. **La promotion de ce projet sur toute plateforme publique est strictement interdite.** Toute violation peut entraîner l'arrêt de la maintenance et la suppression du dépôt.

> [!WARNING]
> **Avertissement** — Le ou les développeurs n'ont aucune affiliation avec Iwara ni avec ses fournisseurs de contenu. Cette application n'héberge **aucun** contenu qui lui soit propre.

## ✨ Fonctionnalités

### 🖥️ Plateformes
| Android | Meta Quest | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ *APK séparé¹* | ✅ | ✅ | ⚠️ *non testé²* | ✅ |

<sub>¹ La version Quest est son propre APK arm64 pour Horizon OS (Android 14+) embarquant le Meta Spatial SDK — voir [Meta Quest / VR](#-meta-quest--vr). L'APK Android classique n'est pas affecté et continue de prendre en charge Android 7.0+.</sub>
<sub>² Les compilations Linux sont produites mais actuellement non testées, faute d'appareils de test.</sub>

### 🎥 Vidéo
- Lecture fluide propulsée par **media_kit** (libmpv)
- Sélection de la qualité · contrôle de la vitesse de lecture (dont une vitesse par défaut/automatique) · plein écran
- Miniatures d'**aperçu de la position** au survol ou au glissement de la barre de progression
- **Horodatages cliquables** — accédez directement à un moment précis via les horodatages surlignés dans les descriptions et les commentaires
- Tiroir **« Continuer à regarder »** + lecture automatique optionnelle à l'ouverture d'une vidéo
- Indicateur de vitesse de chargement en temps réel
- **Visionneuse panoramique sur écran plat** — un fichier VR180 / 360° s'affiche normalement en deux moitiés aplaties ; ici, vous obtenez une vue aux proportions correctes que vous pouvez faire glisser pour regarder autour de vous. Les fichiers d'Iwara ne contiennent aucune métadonnée sphérique, le format est donc deviné de façon heuristique — corrigez-le manuellement et la correction sera mémorisée pour cette vidéo
- **« Distance de vue »** — appuyez et maintenez pour éloigner ou rapprocher l'image (zoom d'image pour une vidéo plate, champ de vision pour une vidéo panoramique)
- **Ouvrir dans une autre application** — transférez la vidéo en cours vers MX Player / VLC, vers un lecteur VR comme Skybox ou Pigasus, ou vers un lecteur externe personnalisé sur ordinateur ; privilégie un fichier local ou déjà téléchargé, avec « copier le lien » en repli
- Bureau : **glisser-déposer** des fichiers vidéo locaux sur la fenêtre pour une lecture instantanée

### 🥽 Meta Quest / VR
*Distribué sous la forme d'un APK `quest` séparé, construit sur le Meta Spatial SDK. La version Android classique n'y est aucunement liée et son `minSdk` reste inchangé.*

**L'application vit dans un environnement spatial.** Lancée depuis l'accueil Quest, elle vous plonge directement dans un espace immersif résident. L'application entière — navigation, recherche, commentaires, clavier virtuel — flotte devant vous comme un panneau 2D ; rien n'est réduit. Le panneau est **légèrement incurvé** (un arc de 30°, soit environ un moniteur de courbure « 3000R » à sa largeur par défaut de 1,6 m). C'est l'arc qui est fixe, pas le rayon, donc la courbe paraît identique quelle que soit la largeur à laquelle vous étirez la fenêtre.

**Trois fenêtres, un seul ensemble de gestes.** Le panneau de l'application, l'écran et le panneau de contrôle possèdent chacun leur propre cadre : la gâchette de préhension déplace une fenêtre par son corps, les bords la déplacent, les coins la redimensionnent autour de son centre, et les fenêtres restent toujours tournées vers vous. Les tailles et positions sont mémorisées. Rien n'apparaît tant que le suivi de la tête ne s'est pas stabilisé — aucune fenêtre ne surgit au mauvais endroit avant de sauter ailleurs.

**Le lecteur devient un écran dans l'espace.** Ouvrez une vidéo et la bascule se fait automatiquement (en option).
- **Forme de l'écran** — plat, ou trois degrés de courbure. La distance, la largeur et le ratio sont réglables et mémorisés *par ratio d'aspect*, si bien que revenir à un clip en 4:3 restaure la mise en page que vous aviez définie pour le 4:3.
- **Formats vidéo** — 2D / 3D, side-by-side demi et complet, over-under demi et complet, équirectangulaire 180° et 360° ; détectés automatiquement à partir du fichier et corrigibles manuellement. EAC et fisheye sont reconnus, signalés comme non pris en charge, et proposés plutôt à un lecteur externe.
- **Lecture** — vitesse 0,5×–3,0×, boucle, volume, un aperçu de défilement affichant l'heure cible et l'écart, un indicateur de mise en mémoire tampon directement sur l'écran, ainsi que l'heure et la batterie sur le panneau.
- **« Continuer à regarder », dans l'espace** — les mêmes groupes de vidéos organisés en sections que dans l'application 2D (liste des sources, abonnements, playlists, favoris, téléchargements, à regarder plus tard), avec des vignettes. Changez de vidéo sans quitter l'espace ; le panneau affiche un état de chargement et rétablit l'ancienne vidéo si la suivante ne se charge pas.
- **Gestion des liens expirés** — les sources sont actualisées avant leur expiration, et une erreur 404 en cours de lecture déclenche une actualisation et reprend là où vous en étiez.
- **Scènes** — passthrough, ou un vide.

**Galerie spatiale.** Une galerie s'ouvre comme une grande scène unique accompagnée d'une bande de pellicule, de sorte qu'un ensemble de dizaines d'images — et les vidéos qui s'y mêlent — reste un objet unique plutôt que des dizaines de calques. Diaporama à 3 / 5 / 10 / 20 s, qualité standard ou originale, et un glissement latéral sur la scène pour passer à la suivante. Les images en portrait sont ajustées dans un cadre 16:9 afin qu'une illustration en 9:16 ne vous domine pas.

**Mains ou manettes.**
- *Mains* — le rayon et le pincement officiels. Un pincement n'importe où hors des panneaux active ou désactive le panneau de contrôle.
- *Manettes* — A/X lecture/pause, B/Y ferme le panneau ou revient à l'application, Menu ouvre les paramètres. La gâchette de préhension saisit l'écran sans avoir à le viser. Le stick fait défiler à gauche/droite avec accélération (une pichenette correspond à 5 s ; maintenu, cela monte jusqu'à 15 minutes par seconde) et pousse l'écran plus près ou plus loin vers le haut/le bas.
- Retirer le casque met la lecture en pause, et le remettre la reprend ; un recentrage système replace tout devant vous.

**Le premier lancement commence par une leçon.** Le guide initial du casque n'est pas celui de l'écran tactile réutilisé (« pincer pour zoomer, maintenir pour la vitesse ») — il n'y a aucune image tactile dans l'espace. À la place, deux parcours sont proposés, **vidéo spatiale** et **galerie spatiale** : une illustration de manette s'anime image par image avec ses boutons et son stick, l'écran, les panneaux et les rayons sont positionnés selon leur géométrie réelle, et chaque mouvement est montré à la fois pour les manettes et pour les mains nues. Lorsque l'option système « réduire les animations » est activée, une unique image fixe informative est affichée à la place. Rejouable à tout moment depuis les paramètres.

### 🌐 Parcourir et découvrir
- **Recherche** multi-catégories : vidéos · galeries · publications · utilisateurs · forums
- **Changement de site** entre `iwara.tv` et `iwara.ai` à la volée
- Intégration du flux d'**actualités** (`news.iwara.tv`)
- Intégration de la source de tags **Oreno3d** pour un étiquetage vidéo plus riche
- Abonnements, filtrage avancé et mises en page adaptatives pour bureau/tablette

### 🖼️ Galerie
- Navigation d'images avec zoom et déplacement fluides
- Visionneuse de galerie avec réglages de qualité

### 💬 Communauté
- **Forum** : création et modification de sujets et de réponses
- **Publications** : consultation et commentaires
- **Commentaires** : consultation et réponses
- **Messages privés** : consultation et réponses
- **Notifications dans l'application** : consultation et réponses

### 👤 Compte et partage
- Authentification utilisateur, gestion du profil, système d'abonnement
- **Partager** des vidéos / galeries / publications / fils de discussion / utilisateurs
- Transmission de liens profonds sur Android : ouvrir un lien Iwara dans une autre application vous ramène directement dans 2i

### 🗂️ Données locales et utilitaires
- **Historique** (local) : vidéos · galeries · publications · forums
- **Favoris locaux** avec dossiers de favoris personnalisés
- **Téléchargements** *(bêta)* : vidéos / galeries / fichiers uniques, avec chemins personnalisés (carte SD/TF externe incluse sur Android)
- **Sauvegarde et restauration** : export/import de la configuration et de l'historique
- **Traduction** des descriptions, publications, commentaires, forums, conversations et plus encore
- **Verrouillage de l'application** par PIN / biométrie
- Option « Se souvenir du dernier volume » (PC)

### 🌍 Multilingue
**Interface disponible en 12 langues** — English · 简体中文 · 繁體中文 · 日本語 · 한국어 · ภาษาไทย · Bahasa Indonesia · Tiếng Việt · Español · Русский · Français · Deutsch — y compris les panneaux spatiaux sur Quest, qui suivent la langue de l'application plutôt que celle du système. Les noms de tags Iwara/Oreno3d ne sont traduits que dans un sous-ensemble plus restreint de ces langues — voir [ci-dessous](#-internationalisation).

> Vous avez trouvé autre chose ? Il reste d'autres trésors cachés à découvrir — et d'autres à venir. Une idée ? Ouvrez une [Issue](https://github.com/FoxSensei001/LoveIwara/issues) ou passez sur le [groupe Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 🗺️ Feuille de route

**Le support Quest est déjà là** — voir [Meta Quest / VR](#-meta-quest--vr) ci-dessus. Il est distribué sous forme d'APK dédié, produit par sa propre tâche CI, et la version Android classique n'est pas concernée.

Ce qui reste ouvert côté casque :

- Le chemin de libération de la mémoire GPU pour les panneaux spatiaux n'est pas encore efficace.
- La scène spatiale partage le thread principal avec Flutter ; le coût par image que cela implique n'a jamais été mesuré.
- Le panneau de l'application repose sur une Activity et devrait migrer vers un panneau basé sur une View, considéré comme plus léger selon les recommandations officielles.
- Les projections EAC et fisheye sont détectées mais transmises à un lecteur externe plutôt que rendues.

Par ailleurs : les téléchargements sont toujours marqués comme bêta, et Linux est compilé mais non testé faute de machine de test.

Une demande ? Ouvrez une [Issue](https://github.com/FoxSensei001/LoveIwara/issues) ou passez sur le [groupe Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 🧰 Stack technique

| Domaine | Bibliothèque |
|---|---|
| Framework | **Flutter** + Dart |
| Gestion d'état | **GetX** (`get`) |
| Routage | **go_router** |
| Réseau | **Dio** (+ intercepteurs CookieJar / Cloudflare) |
| Vidéo | **media_kit** (libmpv) |
| Persistance | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| i18n | **slang** |
| Shell bureau | **window_manager** (barre de titre personnalisée, glisser-déposer) |

## 📸 Captures d'écran

### 🥽 Meta Quest

| L'écran et son panneau de contrôle | Une galerie : une scène plus une bande de pellicule |
|:-------------------------:|:-------------------------:|
|<img src="../imgs/vr_video.jpg" width="420">|<img src="../imgs/gallery_quest.jpg" width="420">|

### 📱 Téléphone et bureau

| | |
|:-------------------------:|:-------------------------:|
|<img src="../imgs/all.png" width="300">|<img src="../imgs/dingyue.png" width="300">|
|<img src="../imgs/filter.png" width="300">|<img src="../imgs/gonggao.png" width="300">|
|<img src="../imgs/huihua.png" width="300">|<img src="../imgs/luntan.png" width="300">|
|<img src="../imgs/luntanxaingqing.png" width="300">|<img src="../imgs/pinglun.png" width="300">|
|<img src="../imgs/record.png" width="300">|<img src="../imgs/shezhi.png" width="300">|
|<img src="../imgs/shipin.png" width="300">|<img src="../imgs/shipin2.png" width="300">|
|<img src="../imgs/shipinliebiao.png" width="300">|<img src="../imgs/sousuo.png" width="300">|
|<img src="../imgs/tongzhi.png" width="300">|<img src="../imgs/tuku.png" width="300">|
|<img src="../imgs/tukuliebiao.png" width="300">|<img src="../imgs/zuozhe.png" width="300">|
|<img src="../imgs/download.png" width="300">|<img src="../imgs/localshoucang.png" width="300">|

## 🚀 Démarrage rapide

```bash
# 1. Cloner
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. Vérifiez votre chaîne d'outils
flutter doctor

# 3. Installez les dépendances
flutter pub get

# 4. Lancer (sélectionne automatiquement un appareil connecté)
flutter run --flavor standard   # Android nécessite un flavor — voir la note ci-dessous
# …ou ciblez une plateforme (bureau/iOS n'ont pas besoin de flavor) :
flutter run -d windows   # macos / linux / ios
```

> [!IMPORTANT]
> **Android est distribué avec deux flavors de produit.** `standard` est la version classique pour téléphones/tablettes (`minSdk 24`,
> toutes les ABI) ; `quest` est la version Meta Quest / Horizon OS (`minSdk 34`, arm64 uniquement, embarque le
> Meta Spatial SDK d'environ 50 Mo). Dès que des flavors existent, l'AGP n'a plus de variante « sans flavor », donc
> **toute commande `flutter run` / `flutter build` sur Android doit passer `--flavor`** — une commande nue échoue directement.

> [!TIP]
> Après avoir modifié un fichier `lib/i18n/*.i18n.yaml`, régénérez les chaînes de localisation avec `dart run slang`.
> Voir [`pubspec.yaml`](../../pubspec.yaml) pour la liste complète des dépendances — quelques paquets nécessitent des étapes de configuration supplémentaires.

<details>
<summary><b>🛠️ Configuration complète de l'environnement de développement</b></summary>

### Prérequis
- Flutter SDK (dernière version stable recommandée) · Dart SDK · Git
- IDE recommandé : Android Studio / VS Code / Cursor + plugin Flutter

### Prérequis spécifiques par plateforme

**Windows**
- Windows 10+ (64 bits), Visual Studio 2022+, Windows 10 SDK
```bash
flutter doctor -v
```

**macOS**
- macOS récent + Xcode + CocoaPods
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

**Android** — Android Studio + Android SDK + émulateur/appareil
**iOS** — Xcode + simulateur/appareil + compte Apple Developer (pour la publication)

### Compiler les binaires de release
```bash
flutter build apk --release --flavor standard         # APK Android (téléphones / tablettes)
flutter build appbundle --release --flavor standard   # AAB Android
flutter build apk --release --flavor quest --target-platform android-arm64   # APK Meta Quest
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### Commandes utiles
```bash
dart run slang     # régénérer les chaînes i18n
flutter analyze    # lint
flutter test       # lancer les tests
flutter clean      # nettoyer le cache de build
flutter devices    # lister les appareils connectés
```

### Dépannage
```bash
# Conflits de dépendances
flutter pub cache repair && flutter clean && flutter pub get
# Émulateur
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Configuration de la signature Android</b></summary>

Pour compiler un APK de release signé :

**1. Générez un keystore** (à exécuter dans `android/app`) :
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
Assurez-vous que `keystore.jks` se retrouve bien dans `android/app`.

**2. Configurez la signature** dans `android/app/build.gradle` :
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
Puis ajoutez les valeurs à `android/gradle.properties` :
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** — ajoutez ces Secrets au dépôt : `KEYSTORE_BASE64` (base64 de `keystore.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. Puis dans `.github/workflows/build.yml` :
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

**4. Compilation** — `flutter build apk --release --flavor standard` → résultat dans `build/app/outputs/flutter-apk/app-standard-release.apk`. Pour la version Quest, `flutter build apk --release --flavor quest --target-platform android-arm64` → `app-arm64-v8a-quest-release.apk`.

</details>

## 🌍 Internationalisation

L'interface est désormais disponible en **12 langues** ; les traductions sont majoritairement générées par machine, à l'exception des quatre langues d'origine (English / 简体中文 / 繁體中文 / 日本語), qui ont été relues par des humains. Si vous souhaitez aider à améliorer une traduction, partez du modèle en chinois simplifié : [`lib/i18n/zh-CN.i18n.yaml`](../../lib/i18n/zh-CN.i18n.yaml), puis lancez `dart run slang`. Consultez **[`docs/i18n/README.md`](../i18n/README.md)** (en chinois) pour le statut complet par langue et les commandes de maintenance.

### 🏷️ Localisation des tags Iwara

Les tags bruts d'Iwara sont des clés à consonance anglaise (par ex. `mother`, `blue_archive`). L'application embarque un dictionnaire maintenu par la communauté qui associe chaque tag à une traduction en **chinois simplifié / chinois traditionnel / japonais / anglais**, afin que les tags s'affichent dans votre langue actuelle sur les pages de détail, la recherche et la page de liste des tags.

Fonctionnement :

- **Dictionnaire** : situé dans [`tool/data/iwara_tags/`](../../tool/data/iwara_tags/). L'application utilise le fichier fusionné et minifié [`iwara_tags.min.json`](../../tool/data/iwara_tags/iwara_tags.min.json).
- **Diffusion** : embarqué comme solution de repli hors ligne (`assets/data/iwara_tags.min.json`) et mis à jour à chaud depuis le CDN jsDelivr — ce qui permet d'améliorer les formulations **sans publier de nouvelle version de l'application**.
- **Dans l'application** : les puces de tags affichent le nom localisé. Sur la carte de tag d'une page de détail, la ligne d'expansion/réduction comporte un bouton icône pour basculer entre **clé d'origine ⇄ traduction** ; un appui long / clic droit sur un tag (ou un appui sur le titre du tag dans la page de liste des tags) ouvre une boîte de dialogue avec la traduction, la clé d'origine, des boutons de copie et un lien de retour d'information.

Ce sont des traductions faites au mieux pour plus de 2600 termes ACG / Vtuber / NSFW, qui peuvent contenir des erreurs.

> **Vous avez repéré une traduction incorrecte ou maladroite ?** Merci de le signaler sur l'issue dédiée : **https://github.com/FoxSensei001/LoveIwara/issues/98** (la boîte de dialogue des tags dans l'application y renvoie également).

**Contribuer une correction** (pour les mainteneurs/contributeurs) :

1. Modifiez le fichier lisible [`iwara_tags_localized.json`](../../tool/data/iwara_tags/iwara_tags_localized.json) (pour chaque tag, `zh-CN` / `zh-TW` / `ja` / `en`).
2. Régénérez l'artefact fusionné et l'asset embarqué : `dart run tool/data/iwara_tags/build_localized_min.dart`.
3. Commitez à la fois la source et le fichier `iwara_tags.min.json` généré (voir [`tool/data/iwara_tags/README.md`](../../tool/data/iwara_tags/README.md)).

Les métadonnées tierces **Oreno3d** (œuvres d'origine / personnages / tags) sont localisées de la même manière — dictionnaire dans [`tool/data/oreno3d_tags/`](../../tool/data/oreno3d_tags/), asset embarqué + CDN jsDelivr, affichées dans votre langue actuelle sur la page de détail vidéo et les cartes de recherche.

> [!NOTE]
> Les deux dictionnaires de tags ci-dessus ne sont maintenus que pour **zh-CN / zh-TW / ja / en** — ils ne sont *pas* étendus aux 8 autres langues de l'interface (ko / th / id / vi / es / ru / fr / de). Il s'agit de plus de 2600 termes ACG / Vtuber / argot dōjin qui reposent sur des tournures propres à la sous-culture plutôt que sur une traduction littérale ; étendre la traduction automatique à 12 langues sans que personne ne puisse en relire le résultat risquerait de laisser passer des tags mal traduits sans que personne ne s'en aperçoive. Dans les langues d'interface hors de ces quatre-là, les tags s'affichent simplement avec leur clé Iwara/Oreno3d d'origine plutôt qu'une traduction. Détails et raisons : [`docs/i18n/README.md`](../i18n/README.md).

## 🙏 Remerciements

Ce projet s'est inspiré et a beaucoup appris des bonnes pratiques de ces excellents dépôts :

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
      <sub>Excellent client Iwara implémenté en Flutter</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>Application de bandes dessinées Flutter bien structurée</sub>
    </td>
  </tr>
</table>

</div>

### Contributeurs

Merci à tous ceux qui ont contribué ! 🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara&max=100" alt="Contributors" />
</a>

</div>

<sub>Réalisé avec [contrib.rocks](https://contrib.rocks)</sub>

## 🤝 Contribuer

Les pull requests sont les bienvenues ! Pour des changements majeurs, ouvrez d'abord une issue afin de discuter de ce que vous souhaitez modifier. Avant de signaler une nouvelle issue, vérifiez les [issues](https://github.com/FoxSensei001/LoveIwara/issues) existantes. Des questions ? Rejoignez notre [groupe Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 💬 Communauté

Rejoignez-nous sur Telegram : **[Cliquez ici pour rejoindre le groupe](https://t.me/+ITH4CV6Z_sc2ZWVl)**.

---

<div align="center">
<sub>Fait avec ❤️ et Flutter · Ceci est un client créé par des fans — merci de soutenir Iwara officiel.</sub>
</div>
