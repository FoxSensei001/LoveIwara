<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="../../assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**Быстрый и красивый кроссплатформенный сторонний клиент для Iwara на Flutter.**

Одна кодовая база → Android · Meta Quest · Windows · macOS · Linux · iOS

[![Telegram Группа](https://img.shields.io/badge/Telegram-Группа-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
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

[English](../../README.md) · [日本語](README_JA.md) · [简体中文](README_ZH.md) · [繁體中文](README_ZH_TW.md) · [한국어](README_KO.md) · [ภาษาไทย](README_TH.md) · [Bahasa Indonesia](README_ID.md) · [Tiếng Việt](README_VI.md) · [Español](README_ES.md) · **Русский** · [Français](README_FR.md) · [Deutsch](README_DE.md)

</div>

---

## 🌟 Введение

**Love Iwara** (также известен как `i_iwara` или **2i**) — сторонний клиент для [Iwara](https://www.iwara.tv), созданный на Flutter. Его цель — обеспечить плавный, максимально нативный по ощущениям опыт на телефонах, планшетах и десктопах — всё из единой кодовой базы, охватывающей **Android, Meta Quest, Windows, macOS, Linux и iOS**.

> [!NOTE]
> Это началось как учебный проект — моя первая попытка сделать кроссплатформенное приложение на Flutter. Часть кода может быть не идеально отполирована, но проект активно поддерживается и богат функциями. Если вы тоже изучаете Flutter, надеюсь, мы сможем расти вместе. PR и обратная связь всегда приветствуются!

> [!IMPORTANT]
> **Ограничения использования** — этот проект предназначен только для обучения и личного ознакомления и **не рекомендуется для продакшена**. **Продвижение этого проекта на любых публичных платформах строго запрещено.** Нарушения могут привести к прекращению поддержки и удалению репозитория.

> [!WARNING]
> **Отказ от ответственности** — разработчик(и) никак не связаны с Iwara или его поставщиками контента. Это приложение **не** размещает никакого собственного контента.

## ✨ Возможности

### 🖥️ Платформы
| Android | Meta Quest | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ *отдельный APK¹* | ✅ | ✅ | ⚠️ *не протестировано²* | ✅ |

<sub>¹ Сборка для Quest — это отдельный arm64 APK для Horizon OS (Android 14+) с Meta Spatial SDK — см. [Meta Quest / VR](#-meta-quest--vr). Обычный Android APK не затронут и по-прежнему поддерживает Android 7.0+.</sub>
<sub>² Сборки для Linux создаются, но пока не протестированы из-за отсутствия тестовых устройств.</sub>

### 🎥 Видео
- Плавное воспроизведение на базе **media_kit** (libmpv)
- Выбор качества · управление скоростью воспроизведения (включая скорость по умолчанию / авто) · полноэкранный режим
- Миниатюры **предпросмотра перемотки** при наведении и перетаскивании на полосе прогресса
- **Кликабельные временные метки** — переход сразу к нужному моменту по выделенным меткам в описаниях и комментариях
- Панель **«Продолжить просмотр»** + опциональный автозапуск при открытии видео
- Индикатор скорости загрузки в реальном времени
- **Панорамный просмотр на плоских экранах** — файл VR180 / 360° иначе отображается как две сплющенные половинки; здесь же вы получаете корректно пропорциональный видовой экран, который можно перетаскивать, чтобы осмотреться. В файлах Iwara вообще нет сферических метаданных, поэтому формат определяется эвристически — исправьте его вручную, и исправление запомнится для этого видео
- **«Дистанция обзора»** — нажмите и удерживайте, чтобы отодвинуть картинку или приблизить её (масштаб изображения для плоского видео, угол обзора для панорамного)
- **Открыть в другом приложении** — передайте текущее видео в MX Player / VLC, в VR-плеер вроде Skybox или Pigasus, либо в собственный внешний плеер на десктопе; предпочтение отдаётся локальному или уже скачанному файлу, а запасной вариант — «копировать ссылку»
- Десктоп: **перетаскивание** локальных видеофайлов в окно для мгновенного воспроизведения

### 🥽 Meta Quest / VR
*Поставляется как отдельный APK `quest`, собранный на базе Meta Spatial SDK. Обычная сборка для Android никак с ним не связана, и её `minSdk` остаётся прежним.*

**Приложение живёт в пространственной среде.** Запуск с главного экрана Quest сразу переносит вас в постоянное иммерсивное пространство. Всё приложение — просмотр, поиск, комментарии, экранная клавиатура — плавает перед вами в виде 2D-панели; ничего не урезано. Панель **слегка изогнута** (дуга 30° — примерно как монитор с кривизной «3000R» при ширине по умолчанию 1.6 м). Фиксирована именно дуга, а не радиус, поэтому кривизна выглядит одинаково, как бы широко или узко вы ни растягивали окно.

**Три окна, единый набор жестов.** У панели приложения, экрана и панели управления есть собственные рамки: захватывающий триггер тащит окно за корпус, края тянут его, а углы изменяют размер вокруг центра, при этом окна всегда развёрнуты к вам. Размеры и положения запоминаются. Ничего не появляется, пока трекинг головы не стабилизируется — окно не вспыхивает в неправильном месте и не «прыгает».

**Плеер становится экраном в пространстве.** Открыв видео, вы автоматически (опционально) переключаетесь в этот режим.
- **Форма экрана** — плоская или одна из трёх степеней изогнутости. Расстояние, ширина и соотношение сторон настраиваются и запоминаются *для каждого соотношения сторон отдельно*, поэтому при возврате к ролику 4:3 восстанавливается именно тот макет, который вы настроили для 4:3.
- **Форматы видео** — 2D / 3D, половинный и полный side-by-side, половинный и полный over-under, эквидистантная проекция 180° и 360°; определяются автоматически по файлу и корректируются вручную. EAC и fisheye распознаются, помечаются как неподдерживаемые и вместо этого предлагаются внешнему плееру.
- **Воспроизведение** — скорость от 0.5× до 3.0×, повтор, громкость, предпросмотр перемотки с целевым временем и разницей, индикатор буферизации прямо на экране, а также часы и заряд батареи на панели.
- **«Продолжить просмотр» прямо в пространстве** — те же разделённые по категориям пулы видео, что и в 2D-приложении (список источников, подписки, плейлисты, избранное, загрузки, «посмотреть позже»), с обложками. Переключайте видео, не покидая пространства; если следующее видео не загрузится, панель покажет состояние загрузки и вернёт предыдущее видео.
- **Обработка истекающих ссылок** — источники обновляются до истечения срока действия, а ошибка 404 посреди воспроизведения запускает обновление и продолжает с того же места.
- **Сцены** — сквозное видение (passthrough) или пустота.

**Пространственная галерея.** Галерея открывается как одна большая сцена плюс лента миниатюр, поэтому набор из десятков изображений — и перемешанных с ними видео — остаётся единым объектом, а не десятками слоёв. Слайд-шоу с интервалом 3 / 5 / 10 / 20 с, стандартное или оригинальное качество, а также боковой свайп по сцене для перелистывания. Портретные изображения вписываются в рамку 16:9, чтобы иллюстрация 9:16 не нависала над вами.

**Руки или контроллеры.**
- *Руки* — официальный луч и щипок. Щипок в любом месте за пределами панелей переключает панель управления.
- *Контроллеры* — A/X — воспроизведение/пауза, B/Y — закрывает панель или возвращает в приложение, Menu — открывает настройки. Захватывающий триггер хватает экран без необходимости прицеливаться. Стик прокручивает влево/вправо с ускорением (одно нажатие — 5 секунд; удержание разгоняется до 15 минут в секунду) и толкает экран ближе или дальше вверх/вниз.
- Снятие гарнитуры ставит воспроизведение на паузу, а надевание обратно — возобновляет его; системное «перецентрирование» заново расставляет всё перед вами.

**Первый запуск начинается с обучения.** Первоначальный гайд для гарнитуры — это не перенесённая версия для сенсорного экрана («щипок для масштаба, удержание для скорости») — в пространстве нет картинки, которую можно потрогать. Вместо этого есть два курса, **пространственное видео** и **пространственная галерея**: иллюстрация контроллера анимируется покадрово вместе с его кнопками и стиком, экран, панели и лучи расположены в реальной геометрии, а каждое движение показывается и для контроллеров, и для рук без них. Если в системе включено «уменьшение движения», вместо анимации показывается один информативный статичный кадр. Можно пересмотреть в любой момент из настроек.

### 🌐 Просмотр и открытие
- Многокатегорийный **поиск**: видео · галереи · посты · пользователи · форумы
- **Переключение сайта** между `iwara.tv` и `iwara.ai` на лету
- Интеграция ленты **новостей** (`news.iwara.tv`)
- Интеграция источника тегов **Oreno3d** для более богатой разметки видео
- Подписки, гибкая фильтрация и адаптивные макеты для десктопа/планшета

### 🖼️ Галерея
- Просмотр изображений с плавным масштабированием и панорамированием
- Просмотрщик галерей с настройками качества

### 💬 Сообщество
- **Форум**: создание и редактирование тем и ответов
- **Посты**: просмотр и комментирование
- **Комментарии**: просмотр и ответы
- **Личные сообщения**: просмотр и ответы
- **Уведомления в приложении**: просмотр и ответы

### 👤 Аккаунт и шэринг
- Авторизация пользователя, управление профилем, система подписок
- **Поделиться** видео / галереями / постами / темами / пользователями
- Передача диплинков на Android: открытие ссылки Iwara в другом приложении возвращает вас обратно в 2i

### 🗂️ Локальные данные и утилиты
- Локальная **история**: видео · галереи · посты · форумы
- **Локальное избранное** с пользовательскими папками избранного
- **Загрузки** *(бета)*: видео / галереи / отдельные файлы, с настраиваемыми путями (включая внешнюю SD/TF-карту на Android)
- **Резервное копирование и восстановление**: экспорт / импорт настроек и истории
- **Перевод** описаний, постов, комментариев, форумов, переписок и многого другого
- **Блокировка приложения** по PIN-коду / биометрии
- Опция «Запоминать последнюю громкость» (ПК)

### 🌍 Многоязычность
**UI на 12 языках** — English · 简体中文 · 繁體中文 · 日本語 · 한국어 · ภาษาไทย · Bahasa Indonesia · Tiếng Việt · Español · Русский · Français · Deutsch — включая пространственные панели на Quest, которые следуют языку приложения, а не системы. Названия тегов Iwara/Oreno3d переведены только для меньшего подмножества этих языков — см. [ниже](#-интернационализация).

> Нашли что-то ещё? Есть и другие скрытые возможности, а также новые в разработке. Есть идея? Откройте [Issue](https://github.com/FoxSensei001/LoveIwara/issues) или загляните в [группу Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 🗺️ Дорожная карта

**Поддержка Quest уже реализована** — см. [Meta Quest / VR](#-meta-quest--vr) выше. Она поставляется как отдельный APK, собираемый отдельной задачей CI, а обычная сборка для Android не затрагивается.

Что пока открыто на стороне гарнитуры:

- Путь освобождения GPU-памяти для пространственных панелей пока не работает эффективно.
- Пространственная сцена делит главный поток с Flutter; стоимость этого в кадрах пока никогда не измерялась.
- Панель приложения основана на Activity и должна быть перенесена на панель на основе View, которую официальные рекомендации называют более лёгким вариантом.
- Проекции EAC и fisheye определяются, но передаются во внешний плеер вместо рендеринга.

Помимо этого: загрузки всё ещё помечены как бета, а Linux собирается, но не протестирован из-за отсутствия тестовой машины.

Есть пожелание? Откройте [Issue](https://github.com/FoxSensei001/LoveIwara/issues) или загляните в [группу Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 🧰 Технологический стек

| Область | Библиотека |
|---|---|
| Фреймворк | **Flutter** + Dart |
| Управление состоянием | **GetX** (`get`) |
| Роутинг | **go_router** |
| Сеть | **Dio** (+ перехватчики CookieJar / Cloudflare) |
| Видео | **media_kit** (libmpv) |
| Хранение данных | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| i18n | **slang** |
| Десктопная оболочка | **window_manager** (кастомный заголовок окна, drag & drop) |

## 📸 Скриншоты

### 🥽 Meta Quest

| Экран и его панель управления | Галерея: одна сцена плюс лента миниатюр |
|:-------------------------:|:-------------------------:|
|<img src="../imgs/vr_video.jpg" width="420">|<img src="../imgs/gallery_quest.jpg" width="420">|

### 📱 Телефон и десктоп

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

## 🚀 Быстрый старт

```bash
# 1. Клонирование
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. Проверка инструментария
flutter doctor

# 3. Установка зависимостей
flutter pub get

# 4. Запуск (автоматический выбор подключённого устройства)
flutter run --flavor standard   # для Android нужен flavor — см. примечание ниже
# …или указать платформу (десктоп/iOS flavor не требуется):
flutter run -d windows   # macos / linux / ios
```

> [!IMPORTANT]
> **Android поставляется в виде двух product flavor.** `standard` — обычная сборка для телефонов/планшетов (`minSdk 24`,
> все ABI); `quest` — сборка для Meta Quest / Horizon OS (`minSdk 34`, только arm64, включает
> ~50 МБ Meta Spatial SDK). Как только появляются flavor, у AGP больше не остаётся варианта «без flavor», поэтому
> **любой Android `flutter run` / `flutter build` обязан передавать `--flavor`** — без него команда сразу завершится ошибкой.

> [!TIP]
> После правки любого `lib/i18n/*.i18n.yaml` пересоздайте строки локализации командой `dart run slang`.
> Полный список зависимостей — в [`pubspec.yaml`](../../pubspec.yaml) — некоторым пакетам нужны дополнительные шаги настройки.

<details>
<summary><b>🛠️ Полная настройка окружения разработки</b></summary>

### Предварительные требования
- Flutter SDK (рекомендуется последняя стабильная версия) · Dart SDK · Git
- Рекомендуемая IDE: Android Studio / VS Code / Cursor + плагин Flutter

### Требования для конкретных платформ

**Windows**
- Windows 10+ (64-бит), Visual Studio 2022+, Windows 10 SDK
```bash
flutter doctor -v
```

**macOS**
- Актуальная macOS + Xcode + CocoaPods
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

**Android** — Android Studio + Android SDK + эмулятор/устройство
**iOS** — Xcode + симулятор/устройство + аккаунт Apple Developer (для публикации)

### Сборка релизных бинарников
```bash
flutter build apk --release --flavor standard         # Android APK (телефоны / планшеты)
flutter build appbundle --release --flavor standard   # Android AAB
flutter build apk --release --flavor quest --target-platform android-arm64   # Meta Quest APK
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### Полезные команды
```bash
dart run slang     # пересоздать строки i18n
flutter analyze    # линтер
flutter test       # запустить тесты
flutter clean      # очистить кэш сборки
flutter devices    # список подключённых устройств
```

### Устранение неполадок
```bash
# Конфликты зависимостей
flutter pub cache repair && flutter clean && flutter pub get
# Эмулятор
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Настройка подписи Android</b></summary>

Чтобы собрать подписанный релизный APK:

**1. Сгенерируйте keystore** (выполните внутри `android/app`):
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
Убедитесь, что `keystore.jks` находится в `android/app`.

**2. Настройте подпись** в `android/app/build.gradle`:
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
И добавьте плейсхолдеры в `android/gradle.properties`:
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** — добавьте в Secrets репозитория: `KEYSTORE_BASE64` (base64 от `keystore.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. Затем в `.github/workflows/build.yml`:
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

**4. Сборка** — `flutter build apk --release --flavor standard` → результат в `build/app/outputs/flutter-apk/app-standard-release.apk`. Для Quest-сборки — `flutter build apk --release --flavor quest --target-platform android-arm64` → `app-arm64-v8a-quest-release.apk`.

</details>

## 🌍 Интернационализация

Сейчас UI доступен на **12 языках**; переводы в основном машинные, за исключением исходных четырёх (English / 简体中文 / 繁體中文 / 日本語), которые прошли проверку человеком. Если хотите помочь улучшить перевод, начните с шаблона на упрощённом китайском: [`lib/i18n/zh-CN.i18n.yaml`](../../lib/i18n/zh-CN.i18n.yaml), затем выполните `dart run slang`. Полный статус по каждому языку и команды для поддержки — в **[`docs/i18n/README.md`](../i18n/README.md)** (на китайском языке).

### 🏷️ Локализация тегов Iwara

Исходные теги Iwara — это ключи в англоязычном стиле (например, `mother`, `blue_archive`). В приложение встроен словарь, поддерживаемый сообществом, который сопоставляет каждый тег с переводом на **упрощённый китайский / традиционный китайский / японский / английский**, поэтому теги отображаются на вашем текущем языке на страницах деталей, в поиске и на странице списка тегов.

Как это работает:

- **Словарь**: находится в [`tool/data/iwara_tags/`](../../tool/data/iwara_tags/). Приложение использует объединённый и минифицированный [`iwara_tags.min.json`](../../tool/data/iwara_tags/iwara_tags.min.json).
- **Доставка**: встроен как офлайн-резерв (`assets/data/iwara_tags.min.json`) и обновляется «на горячую» через jsDelivr CDN — так формулировки можно улучшать **без выпуска новой сборки приложения**.
- **Внутри приложения**: чипы тегов показывают локализованное имя. На карточке тега на странице деталей в строке разворачивания/сворачивания есть кнопка-иконка для переключения **между оригинальным ключом и переводом**; долгое нажатие / клик правой кнопкой мыши по тегу (или тап по заголовку тега на странице списка тегов) открывает диалог с переводом, оригинальным ключом, кнопками копирования и ссылкой для обратной связи.

Это переводы 2600+ терминов из ACG / Vtuber / NSFW-тематики, сделанные с максимальными усилиями, но, возможно, содержащие ошибки.

> **Заметили неверный или неуклюжий перевод?** Сообщите, пожалуйста, в специальном issue: **https://github.com/FoxSensei001/LoveIwara/issues/98** (диалог тегов в приложении тоже ведёт сюда).

**Как внести исправление** (для мейнтейнеров/контрибьюторов):

1. Отредактируйте человекочитаемый файл [`iwara_tags_localized.json`](../../tool/data/iwara_tags/iwara_tags_localized.json) (для каждого тега — `zh-CN` / `zh-TW` / `ja` / `en`).
2. Пересоздайте объединённый артефакт и встроенный ассет: `dart run tool/data/iwara_tags/build_localized_min.dart`.
3. Закоммитьте и исходный файл, и сгенерированный `iwara_tags.min.json` (см. [`tool/data/iwara_tags/README.md`](../../tool/data/iwara_tags/README.md)).

Сторонние метаданные **Oreno3d** (произведения / персонажи / теги) локализуются тем же способом — словарь в [`tool/data/oreno3d_tags/`](../../tool/data/oreno3d_tags/), встроенный ассет + jsDelivr CDN, отображаются на вашем текущем языке на странице деталей видео и в карточках поиска.

> [!NOTE]
> Оба словаря тегов выше поддерживаются **только для zh-CN / zh-TW / ja / en** — они *не* расширены на остальные 8 языков UI (ko / th / id / vi / es / ru / fr / de). Это более 2600 терминов из ACG / Vtuber / доуджин-сленга, которые опираются на специфичные для субкультуры формулировки, а не на буквальный перевод; масштабирование ИИ-перевода на 12 языков без возможности кем-либо проверить результат рискует оставить незамеченными ошибочные теги. В языках UI за пределами этих четырёх теги просто отображаются как исходный ключ Iwara/Oreno3d, а не как перевод. Подробности и обоснование — в [`docs/i18n/README.md`](../i18n/README.md).

## 🙏 Благодарности

Этот проект черпал вдохновение и перенял немало лучших практик из следующих отличных репозиториев:

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
      <sub>Отличный клиент Iwara, реализованный на Flutter</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>Хорошо структурированное приложение-читалка комиксов на Flutter</sub>
    </td>
  </tr>
</table>

</div>

### Контрибьюторы

Спасибо всем, кто внёс свой вклад! 🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara&max=100" alt="Contributors" />
</a>

</div>

<sub>Сделано с помощью [contrib.rocks](https://contrib.rocks)</sub>

## 🤝 Как внести вклад

Pull request'ы приветствуются! Для крупных изменений сначала откройте issue, чтобы обсудить, что вы хотите изменить. Перед тем как создавать новый issue, проверьте существующие [issues](https://github.com/FoxSensei001/LoveIwara/issues). Есть вопросы? Присоединяйтесь к нашей [группе Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 💬 Сообщество

Присоединяйтесь к нам в Telegram: **[Нажмите здесь, чтобы вступить в группу](https://t.me/+ITH4CV6Z_sc2ZWVl)**.

---

<div align="center">
<sub>Сделано с ❤️ и Flutter · Это фанатский клиент — пожалуйста, поддержите официальный Iwara.</sub>
</div>
