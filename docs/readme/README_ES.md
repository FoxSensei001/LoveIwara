<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara">
    <img src="assets/icon/launcher_icon_v2.png" alt="Love Iwara logo" title="Love Iwara logo" width="96"/>
</a>

# Love Iwara <sup>(2i)</sup>

**Un cliente de terceros para Iwara rápido, elegante y multiplataforma, construido con Flutter.**

Una sola base de código → Android · Meta Quest · Windows · macOS · Linux · iOS

[![Telegram Grupo](https://img.shields.io/badge/Telegram-Grupo-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/+ITH4CV6Z_sc2ZWVl)
[![GitHub stars](https://img.shields.io/github/stars/FoxSensei001/LoveIwara?label=stars&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara)
[![GitHub forks](https://img.shields.io/github/forks/FoxSensei001/LoveIwara?label=forks&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara)
[![Latest release](https://img.shields.io/github/v/release/FoxSensei001/LoveIwara?label=release&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/FoxSensei001/LoveIwara/total?label=downloads&labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/releases)
[![License: MIT](https://img.shields.io/github/license/FoxSensei001/LoveIwara?labelColor=27303D&color=0877d2)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/FoxSensei001/LoveIwara?labelColor=27303D&color=0D1117&logo=github&logoColor=FFFFFF&style=flat)](https://github.com/FoxSensei001/LoveIwara/issues)

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-^3.8-0175C2?style=flat&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)
![Meta Quest](https://img.shields.io/badge/Meta_Quest-Horizon_OS-0467DF?style=flat&logo=meta&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0id2hpdGUiPjxwYXRoIGQ9Ik0wIDBoMTEuMzc3djExLjM3Mkgwek0xMi42MjMgMEgyNHYxMS4zNzJIMTIuNjIzek0wIDEyLjYyM2gxMS4zNzdWMjRIMHpNMTIuNjIzIDEyLjYyM0gyNFYyNEgxMi42MjN6Ii8%2BPC9zdmc%2B)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![iOS](https://img.shields.io/badge/iOS-000000?style=flat&logo=apple&logoColor=white)

[English](README.md) · [日本語](README_JA.md) · [简体中文](README_ZH.md) · [繁體中文](README_ZH_TW.md) · [한국어](README_KO.md) · [ภาษาไทย](README_TH.md) · [Bahasa Indonesia](README_ID.md) · [Tiếng Việt](README_VI.md) · **Español** · [Русский](README_RU.md) · [Français](README_FR.md) · [Deutsch](README_DE.md)

</div>

---

## 🌟 Introducción

**Love Iwara** (también conocido como `i_iwara` o **2i**) es un cliente de terceros para [Iwara](https://www.iwara.tv) construido con Flutter. Su objetivo es ofrecer una experiencia fluida y con sensación nativa en teléfonos, tablets y equipos de escritorio, todo desde una única base de código que cubre **Android, Meta Quest, Windows, macOS, Linux e iOS**.

> [!NOTE]
> Esto empezó como un proyecto de aprendizaje: mi primer intento de crear una app multiplataforma con Flutter. Puede que parte del código no esté perfectamente pulido, pero se mantiene activamente y está repleto de funciones. Si tú también estás aprendiendo Flutter, espero que podamos crecer juntos. ¡Los PR y comentarios siempre son bienvenidos!

> [!IMPORTANT]
> **Restricciones de uso** — Este proyecto es únicamente para aprendizaje y referencia personal, y **no se recomienda su uso en producción**. **Queda estrictamente prohibida la promoción de este proyecto en cualquier plataforma pública.** Las infracciones pueden provocar que se detenga el mantenimiento y se elimine el repositorio.

> [!WARNING]
> **Descargo de responsabilidad** — Los desarrolladores no tienen ninguna afiliación con Iwara ni con sus proveedores de contenido. Esta aplicación no aloja **ningún** contenido propio.

## ✨ Funciones

### 🖥️ Plataformas
| Android | Meta Quest | Windows | macOS | Linux | iOS |
|:---:|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ *APK independiente¹* | ✅ | ✅ | ⚠️ *sin probar²* | ✅ |

<sub>¹ La compilación para Quest es su propio APK arm64 para Horizon OS (Android 14+) que incluye el Meta Spatial SDK — ver [Meta Quest / VR](#-meta-quest--vr). El APK normal de Android no se ve afectado y sigue siendo compatible con Android 7.0+.</sub>
<sub>² Las compilaciones de Linux se generan, pero actualmente no están probadas por falta de dispositivos de prueba.</sub>

### 🎥 Vídeo
- Reproducción fluida gracias a **media_kit** (libmpv)
- Selección de calidad · control de velocidad de reproducción (incluida una velocidad predeterminada/automática) · pantalla completa
- Miniaturas de **vista previa al buscar** al pasar el cursor o arrastrar la barra de progreso
- **Marcas de tiempo pulsables**: salta directamente a un momento concreto desde las marcas de tiempo resaltadas en descripciones y comentarios
- Panel de **"Continuar viendo"** + reproducción automática opcional al entrar en un vídeo
- Indicador de velocidad de carga en tiempo real
- **Visor panorámico en pantallas planas**: un archivo VR180 / 360° normalmente se muestra como dos mitades aplastadas; aquí obtienes una vista con las proporciones correctas que puedes arrastrar para mirar alrededor. Los archivos de Iwara no llevan ningún metadato esférico, así que el formato se adivina de forma heurística; corrígelo manualmente y la corrección se recordará para ese vídeo
- **"Distancia de visión"**: mantén pulsado para alejar o acercar la imagen (zoom de imagen para vídeo plano, campo de visión para panorámico)
- **Abrir en otra app**: envía el vídeo actual a MX Player / VLC, a un reproductor VR como Skybox o Pigasus, o a un reproductor externo personalizado en escritorio; prioriza un archivo local o ya descargado, con "copiar enlace" como alternativa
- Escritorio: **arrastra y suelta** archivos de vídeo locales sobre la ventana para reproducirlos al instante

### 🥽 Meta Quest / VR
*Se distribuye como un APK `quest` independiente, construido sobre el Meta Spatial SDK. La compilación normal de Android no depende de él en absoluto y su `minSdk` se mantiene igual.*

**La app vive en un entorno espacial.** Al iniciarla desde el menú de inicio de Quest, entras directamente en un espacio inmersivo residente. Toda la app —navegación, búsqueda, comentarios, teclado en pantalla— flota ante ti como un panel 2D; nada se recorta. El panel está **ligeramente curvado** (un arco de 30°, aproximadamente un monitor de curvatura "3000R" en su anchura predeterminada de 1,6 m). Lo que es fijo es el arco, no el radio, así que la curva se ve igual sin importar cuánto amplíes o estreches la ventana.

**Tres ventanas, un mismo conjunto de gestos.** El panel de la app, la pantalla y el panel de control tienen cada uno su propio marco: el gatillo de agarre arrastra una ventana por su cuerpo, los bordes la mueven y las esquinas la redimensionan en torno a su centro, y las ventanas siempre se orientan hacia ti. El tamaño y la posición se recuerdan. Nada aparece hasta que el seguimiento de cabeza se estabiliza, para que ninguna ventana aparezca en el lugar equivocado y luego salte.

**El reproductor se convierte en una pantalla en el espacio.** Al abrir un vídeo, la transición ocurre automáticamente (opcional).
- **Forma de la pantalla**: plana, o tres grados de curvatura. La distancia, el ancho y la relación de aspecto son ajustables y se recuerdan *por cada relación de aspecto*, así que al volver a un clip en 4:3 se restaura el diseño que configuraste para 4:3.
- **Formatos de vídeo**: 2D / 3D, side-by-side medio y completo, over-under medio y completo, equirrectangular 180° y 360°; se detectan automáticamente a partir del archivo y pueden corregirse a mano. EAC y fisheye se reconocen, se marcan como no compatibles y se ofrecen a un reproductor externo en su lugar.
- **Reproducción**: velocidad de 0,5×–3,0×, bucle, volumen, una vista previa de desplazamiento que muestra el tiempo objetivo y la diferencia, un indicador de búfer en la propia pantalla, además del reloj y la batería en el panel.
- **"Continuar viendo", dentro del espacio**: los mismos grupos de vídeos por secciones que en la app 2D (lista de orígenes, suscripciones, listas de reproducción, favoritos, descargas, ver más tarde), con portadas. Cambia de vídeo sin salir del espacio; el panel muestra un estado de carga y restaura el vídeo anterior si el siguiente no logra cargarse.
- **Gestión de enlaces que caducan**: los orígenes se renuevan antes de caducar, y un error 404 a mitad de reproducción activa una renovación y retoma desde donde te quedaste.
- **Escenas**: paso a través (passthrough) o vacío.

**Galería espacial.** Una galería se abre como un único escenario grande más una tira de miniaturas, de modo que un conjunto de decenas de imágenes —y los vídeos mezclados entre ellas— se mantiene como un solo objeto en lugar de decenas de capas. Presentación de diapositivas a 3 / 5 / 10 / 20 s, calidad estándar u original, y un arrastre lateral sobre el escenario para pasar de una a otra. Las imágenes en vertical se ajustan a un marco 16:9 para que una ilustración 9:16 no se imponga sobre ti.

**Manos o mandos.**
- *Manos*: el rayo y el pellizco oficiales. Un pellizco en cualquier punto fuera de los paneles activa o desactiva el panel de control.
- *Mandos*: A/X reproduce/pausa, B/Y cierra el panel o vuelve a la app, Menu abre los ajustes. El gatillo de agarre atrapa la pantalla sin necesidad de apuntar a ella. El stick desplaza hacia izquierda/derecha con aceleración (un toque son 5 s; mantenido, aumenta hasta 15 minutos por segundo) y empuja la pantalla más cerca o más lejos hacia arriba/abajo.
- Quitarse el visor pausa la reproducción y volver a ponérselo la reanuda; un recentrado del sistema vuelve a colocar todo delante de ti.

**El primer inicio comienza con una lección.** La guía inicial del visor no es la versión de pantalla táctil heredada ("pellizca para hacer zoom, mantén pulsado para la velocidad"); no hay ninguna imagen táctil en el espacio. En su lugar hay dos cursos, **vídeo espacial** y **galería espacial**: una ilustración de mando se anima fotograma a fotograma junto con sus botones y su stick, la pantalla, los paneles y los rayos se sitúan en su geometría real, y cada movimiento se muestra tanto para mandos como para manos desnudas. Con la opción del sistema "reducir movimiento" activada, se dibuja en su lugar un único fotograma estático informativo. Se puede volver a reproducir en cualquier momento desde los ajustes.

### 🌐 Explorar y descubrir
- **Búsqueda** multicategoría: vídeos · galerías · publicaciones · usuarios · foros
- **Cambio de sitio** entre `iwara.tv` e `iwara.ai` en tiempo real
- Integración del feed de **noticias** (`news.iwara.tv`)
- Integración de la fuente de etiquetas de **Oreno3d** para un etiquetado de vídeo más completo
- Suscripciones, filtrado avanzado y diseños adaptables para escritorio/tablet

### 🖼️ Galería
- Navegación de imágenes con zoom y desplazamiento fluidos
- Visor de galería con ajustes de calidad

### 💬 Comunidad
- **Foro**: crear y editar hilos y respuestas
- **Publicaciones**: explorar y comentar
- **Comentarios**: explorar y responder
- **Mensajes privados**: explorar y responder
- **Notificaciones en la app**: explorar y responder

### 👤 Cuenta y compartir
- Autenticación de usuario, gestión de perfil, sistema de seguimiento
- **Compartir** vídeos / galerías / publicaciones / hilos / usuarios
- Transferencia de enlaces profundos en Android: al abrir un enlace de Iwara en otra app, vuelves directamente a 2i

### 🗂️ Datos locales y utilidades
- **Historial** (local): vídeos · galerías · publicaciones · foros
- **Favoritos locales** con carpetas de favoritos personalizadas
- **Descargas** *(beta)*: vídeos / galerías / archivos individuales, con rutas personalizadas (incluida tarjeta SD/TF externa en Android)
- **Copia de seguridad y restauración**: exportar/importar configuración e historial
- **Traducción** de descripciones, publicaciones, comentarios, foros, conversaciones y más
- **Bloqueo de la app** con PIN / biometría
- Opción "Recordar el último volumen" (PC)

### 🌍 Multilingüe
**UI disponible en 12 idiomas** — English · 简体中文 · 繁體中文 · 日本語 · 한국어 · ภาษาไทย · Bahasa Indonesia · Tiếng Việt · Español · Русский · Français · Deutsch — incluidos los paneles espaciales en Quest, que siguen el idioma de la app en lugar del del sistema. Los nombres de etiquetas de Iwara/Oreno3d están traducidos para un subconjunto menor de estos idiomas — ver [más abajo](#-internacionalización).

> ¿Has encontrado algo más? Hay más joyas ocultas por descubrir, y más en camino. ¿Tienes una idea? Abre un [Issue](https://github.com/FoxSensei001/LoveIwara/issues) o pásate por el [grupo de Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 🗺️ Hoja de ruta

**El soporte para Quest ya está aquí** — ver [Meta Quest / VR](#-meta-quest--vr) más arriba. Se distribuye como su propio APK, generado por su propio trabajo de CI, y la compilación normal de Android no se ve afectada.

Lo que sigue pendiente en el lado del visor:

- La liberación de memoria de GPU para los paneles espaciales aún no es eficaz.
- La escena espacial comparte el hilo principal con Flutter; el coste por fotograma de esto nunca se ha medido.
- El panel de la app está basado en Activity y debería migrarse a un panel basado en View, que la guía oficial considera la opción más ligera.
- Las proyecciones EAC y fisheye se detectan, pero se derivan a un reproductor externo en lugar de renderizarse.

Aparte de eso: las descargas siguen marcadas como beta, y Linux se compila pero no se ha probado por falta de un equipo de pruebas.

¿Tienes alguna petición? Abre un [Issue](https://github.com/FoxSensei001/LoveIwara/issues) o pásate por el [grupo de Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 🧰 Stack tecnológico

| Área | Librería |
|---|---|
| Framework | **Flutter** + Dart |
| Gestión de estado | **GetX** (`get`) |
| Enrutamiento | **go_router** |
| Red | **Dio** (+ interceptores CookieJar / Cloudflare) |
| Vídeo | **media_kit** (libmpv) |
| Persistencia | **sqlite3** · **get_storage** · **flutter_secure_storage** |
| i18n | **slang** |
| Shell de escritorio | **window_manager** (barra de título personalizada, arrastrar y soltar) |

## 📸 Capturas de pantalla

### 🥽 Meta Quest

| La pantalla y su panel de control | Una galería: un escenario más una tira de miniaturas |
|:-------------------------:|:-------------------------:|
|<img src="docs/imgs/video_quest.jpg" width="420">|<img src="docs/imgs/gallery_quest.jpg" width="420">|

### 📱 Teléfono y escritorio

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

## 🚀 Inicio rápido

```bash
# 1. Clonar
git clone https://github.com/FoxSensei001/LoveIwara.git
cd LoveIwara

# 2. Verifica tu toolchain
flutter doctor

# 3. Instala las dependencias
flutter pub get

# 4. Ejecutar (selecciona automáticamente un dispositivo conectado)
flutter run --flavor standard   # Android requiere un flavor — ver la nota más abajo
# …o especifica una plataforma (escritorio/iOS no necesitan flavor):
flutter run -d windows   # macos / linux / ios
```

> [!IMPORTANT]
> **Android se distribuye con dos flavors de producto.** `standard` es la compilación normal para teléfonos/tablets (`minSdk 24`,
> todas las ABI); `quest` es la compilación para Meta Quest / Horizon OS (`minSdk 34`, solo arm64, incluye
> ~50 MB del Meta Spatial SDK). Una vez que existen flavors, AGP ya no tiene una variante "sin flavor", así que
> **todo comando `flutter run` / `flutter build` en Android debe incluir `--flavor`**; un comando sin él falla directamente.

> [!TIP]
> Después de editar cualquier `lib/i18n/*.i18n.yaml`, regenera las cadenas de localización con `dart run slang`.
> Consulta [`pubspec.yaml`](pubspec.yaml) para ver la lista completa de dependencias — algunos paquetes requieren pasos de configuración adicionales.

<details>
<summary><b>🛠️ Configuración completa del entorno de desarrollo</b></summary>

### Requisitos previos
- Flutter SDK (se recomienda la última versión estable) · Dart SDK · Git
- IDE recomendado: Android Studio / VS Code / Cursor + plugin de Flutter

### Requisitos específicos por plataforma

**Windows**
- Windows 10+ (64 bits), Visual Studio 2022+, Windows 10 SDK
```bash
flutter doctor -v
```

**macOS**
- macOS más reciente + Xcode + CocoaPods
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

**Android** — Android Studio + Android SDK + emulador/dispositivo
**iOS** — Xcode + simulador/dispositivo + cuenta de Apple Developer (para publicar)

### Compilar binarios de release
```bash
flutter build apk --release --flavor standard         # APK de Android (teléfonos / tablets)
flutter build appbundle --release --flavor standard   # AAB de Android
flutter build apk --release --flavor quest --target-platform android-arm64   # APK de Meta Quest
flutter build ios --release          # iOS
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux
```

### Comandos útiles
```bash
dart run slang     # regenerar cadenas i18n
flutter analyze    # lint
flutter test       # ejecutar tests
flutter clean      # limpiar la caché de compilación
flutter devices    # listar dispositivos conectados
```

### Solución de problemas
```bash
# Conflictos de dependencias
flutter pub cache repair && flutter clean && flutter pub get
# Emulador
flutter emulators && flutter emulators --launch <emulator_id>
```

</details>

<details>
<summary><b>🔐 Configuración de firma en Android</b></summary>

Para compilar un APK de release firmado:

**1. Genera un keystore** (ejecuta dentro de `android/app`):
```bash
keytool -genkeypair -v -keystore keystore.jks -alias <your_key_alias> -keyalg RSA -keysize 2048 -validity 10000
```
Asegúrate de que `keystore.jks` termine dentro de `android/app`.

**2. Configura la firma** en `android/app/build.gradle`:
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
Y añade los marcadores de posición en `android/gradle.properties`:
```properties
MY_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
MY_KEY_ALIAS=${KEY_ALIAS}
MY_KEY_PASSWORD=${KEY_PASSWORD}
```

**3. GitHub Actions** — añade los Secrets del repositorio: `KEYSTORE_BASE64` (base64 de `keystore.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. Luego, en `.github/workflows/build.yml`:
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

**4. Compilar** — `flutter build apk --release --flavor standard` → el resultado queda en `build/app/outputs/flutter-apk/app-standard-release.apk`. Para la compilación de Quest, `flutter build apk --release --flavor quest --target-platform android-arm64` → `app-arm64-v8a-quest-release.apk`.

</details>

## 🌍 Internacionalización

La interfaz ya está disponible en **12 idiomas**; las traducciones son en su mayoría generadas por máquina, salvo los cuatro originales (English / 简体中文 / 繁體中文 / 日本語), que han sido revisados por humanos. Si quieres ayudar a mejorar una traducción, empieza por la plantilla en chino simplificado: [`lib/i18n/zh-CN.i18n.yaml`](lib/i18n/zh-CN.i18n.yaml), y luego ejecuta `dart run slang`. Consulta **[`docs/i18n/README.md`](docs/i18n/README.md)** (en chino) para ver el estado completo por idioma y los comandos de mantenimiento.

### 🏷️ Localización de etiquetas de Iwara

Las etiquetas originales de Iwara son claves con aspecto de inglés (por ejemplo, `mother`, `blue_archive`). La app incluye un diccionario mantenido por la comunidad que asigna a cada etiqueta una traducción en **chino simplificado / chino tradicional / japonés / inglés**, de modo que las etiquetas se muestran en tu idioma actual en las páginas de detalle, la búsqueda y la página de lista de etiquetas.

Cómo funciona:

- **Diccionario**: se encuentra en [`tool/data/iwara_tags/`](tool/data/iwara_tags/). La app usa el archivo combinado y minificado [`iwara_tags.min.json`](tool/data/iwara_tags/iwara_tags.min.json).
- **Distribución**: se incluye como respaldo sin conexión (`assets/data/iwara_tags.min.json`) y se actualiza en caliente desde la CDN de jsDelivr, de modo que la redacción puede mejorar **sin publicar una nueva versión de la app**.
- **Dentro de la app**: los chips de etiquetas muestran el nombre localizado. En la tarjeta de etiquetas de la página de detalle, la fila de expandir/contraer tiene un botón de icono para alternar entre **clave original ⇄ traducción**; mantener pulsado o hacer clic derecho en una etiqueta (o tocar el título de la etiqueta en la página de lista de etiquetas) abre un diálogo con la traducción y la clave original, botones de copiar y un enlace para enviar comentarios.

Se trata de traducciones hechas con el mayor esfuerzo posible de más de 2600 términos de ACG / Vtuber / NSFW, y pueden contener errores.

> **¿Has detectado una traducción incorrecta o poco natural?** Repórtala en el issue dedicado: **https://github.com/FoxSensei001/LoveIwara/issues/98** (el diálogo de etiquetas dentro de la app también enlaza aquí).

**Contribuir con una corrección** (para mantenedores/colaboradores):

1. Edita el archivo legible [`iwara_tags_localized.json`](tool/data/iwara_tags/iwara_tags_localized.json) (por cada etiqueta, `zh-CN` / `zh-TW` / `ja` / `en`).
2. Regenera el artefacto combinado y el asset incluido: `dart run tool/data/iwara_tags/build_localized_min.dart`.
3. Haz commit tanto del origen como del `iwara_tags.min.json` generado (ver [`tool/data/iwara_tags/README.md`](tool/data/iwara_tags/README.md)).

Los metadatos de terceros de **Oreno3d** (obras originales / personajes / etiquetas) se localizan de la misma manera: el diccionario está en [`tool/data/oreno3d_tags/`](tool/data/oreno3d_tags/), como asset incluido + CDN de jsDelivr, y se muestra en tu idioma actual en la página de detalle del vídeo y en las tarjetas de búsqueda.

> [!NOTE]
> Ambos diccionarios de etiquetas anteriores se mantienen **únicamente para zh-CN / zh-TW / ja / en**; *no* se han ampliado a los otros 8 idiomas de la interfaz (ko / th / id / vi / es / ru / fr / de). Se trata de más de 2600 términos de ACG / Vtuber / jerga dōjin que dependen de expresiones propias de la subcultura en lugar de una traducción literal; ampliar la traducción automática a 12 idiomas sin que nadie pueda revisar el resultado corre el riesgo de dejar etiquetas mal traducidas que nadie detecte. En los idiomas de interfaz fuera de esos cuatro, las etiquetas simplemente se muestran con su clave original de Iwara/Oreno3d en lugar de una traducción. Detalles y motivos: [`docs/i18n/README.md`](docs/i18n/README.md).

## 🙏 Agradecimientos

Este proyecto se inspiró y aprendió muchas buenas prácticas de estos excelentes repositorios:

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
      <sub>Excelente cliente de Iwara implementado en Flutter</sub>
    </td>
    <td align="center" width="50%">
      <a href="https://github.com/wgh136/PicaComic">
        <img src="https://opengraph.githubassets.com/1/wgh136/PicaComic" alt="wgh136/PicaComic" style="width: 100%; max-width: 500px;">
      </a>
      <br />
      <sub><b>wgh136/PicaComic</b></sub>
      <br />
      <sub>Aplicación de cómics en Flutter bien estructurada</sub>
    </td>
  </tr>
</table>

</div>

### Colaboradores

¡Gracias a todos los que han contribuido! 🎉

<div align="center">

<a href="https://github.com/FoxSensei001/LoveIwara/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FoxSensei001/LoveIwara&max=100" alt="Contributors" />
</a>

</div>

<sub>Hecho con [contrib.rocks](https://contrib.rocks)</sub>

## 🤝 Contribuir

¡Los pull requests son bienvenidos! Para cambios importantes, abre primero un issue para discutir qué te gustaría cambiar. Antes de reportar un nuevo issue, revisa los [issues](https://github.com/FoxSensei001/LoveIwara/issues) existentes. ¿Tienes preguntas? Únete a nuestro [grupo de Telegram](https://t.me/+ITH4CV6Z_sc2ZWVl).

## 💬 Comunidad

Únete a nosotros en Telegram: **[Haz clic aquí para unirte al grupo](https://t.me/+ITH4CV6Z_sc2ZWVl)**.

---

<div align="center">
<sub>Hecho con ❤️ y Flutter · Este es un cliente hecho por fans — apoya al Iwara oficial.</sub>
</div>
