# Love Iwara (2i)

<p align="center">
  <img src="assets/icon/launcher_icon_v2.png" width="200" alt="Love Iwara Logo" style="border-radius: 16px;">
</p>

<div align="center">

[English](#english) | [中文](README_ZH.md)

</div>

---

## English

### 🌟 Introduction
Love Iwara (also known as i_iwara or 2i) is a third-party mobile application for Iwara built with Flutter. Our goal is to provide users with an excellent experience, supporting multiple platforms and devices including mobile phones, tablets and computers, compatible with Android, Windows and other operating systems.

### ⚠️ Project Description
As a Flutter beginner, this is my first attempt at developing a cross-platform application. While there may be areas in the project that need improvement and code that could be optimized, the main purpose is to learn and understand Flutter development through hands-on practice.

- **Learning Objectives**
  - Familiarize with Flutter development basics
  - Understand cross-platform application development processes
  - Document insights and experiences during the learning process

- **Project Status**
  - Currently in the learning and exploration phase
  - Code may not be sufficiently standardized and complete
  - Feature implementation primarily focuses on learning purposes

- **Usage Notes**
  - This project is for learning reference only
  - Not recommended for production environment
  - Welcome discussions with other learners

- **Usage Restrictions**
  - Strictly prohibited from promotion on any platform
  - Violations will result in measures including but not limited to maintenance suspension and repository deletion

- **Known Issues**
  - Due to limited experience, the project may have room for performance optimization
  - Some features may not be fully developed
  - Suggestions for improvement are welcome

Thank you for your understanding and support! If you're also a Flutter beginner, I hope we can progress together in our learning journey.

### ✨ Features
#### Current Features
- **🖥️ Supported Platforms**
    - 📱 Android
    - 🪟 Windows
    - 🍎 MacOS (Due to lack of Mac device, testing and built packages unavailable; UI bugs theoretically same as Windows version but not fully tested)
    - 🐧 Linux (Due to lack of Linux device, testing and built packages unavailable)
    - 📱 iOS (Due to lack of iOS device, testing and built packages unavailable)
    - 🌐 Web (Development only)

- **🔍 Search**
    - Search videos/galleries/posts/users

- **📜 History**
    - Browsing history: videos/galleries/posts

- **🔄 Translation**
    - Translate video descriptions/gallery descriptions/posts/comments

- **🎥 Video**
    - Video playback
    - Video tags
    - Video quality selection
    - Playback speed control
    - Fullscreen support

- **🖼️ Gallery**
    - Image browsing
    - Image zoom and pan
    - Gallery view

- **📝 Posts**
    - Browse/comment

- **💬 Comments**
    - Comment browsing
    - Comment reply

- **👤 User System**
    - User authentication
    - Profile management
    - Following system

- **🌍 Multi-language Support**
    - English
    - Simplified Chinese
    - Traditional Chinese
    - Japanese

#### Upcoming Features
- **Download Management**
- **In-app Message Notification**
- **Share**
- **Forum System**
- **Enhanced User Experience**
- **Others**
  
### 📱 Screenshots
| | |
|:-------------------------:|:-------------------------:|
|<img src="docs/imgs/show1.jpg" width="200">|<img src="docs/imgs/show2.jpg" width="200">|
|<img src="docs/imgs/show3.png" width="400">|<img src="docs/imgs/show4.png" width="400">|
|<img src="docs/imgs/shezhi.png" width="300">|<img src="docs/imgs/dingyue.png" width="300">|
|<img src="docs/imgs/lishi.png" width="300">|<img src="docs/imgs/guanzhu.png" width="300">|
|<img src="docs/imgs/sousuo.png" width="300">|<img src="docs/imgs/zuiai.png" width="300">|

### 🛠️ Development Environment Setup

#### Prerequisites
- Flutter SDK (Latest stable version recommended)
- Dart SDK
- Git
- Recommended IDEs:
  - Android Studio / Cursor
  - VS Code / Cursor + Flutter plugin

#### Platform-Specific Requirements

**Windows Development Environment:**
- Windows 10 or higher (64-bit)
- Visual Studio 2022 or newer
- Windows 10 SDK
```bash
# Check Windows development environment
flutter doctor -v
```

**macOS Development Environment:**
- macOS (Latest version recommended)
- Xcode (Latest version)
- CocoaPods
```bash
# Install CocoaPods
sudo gem install cocoapods
```

**Linux Development Environment:**
```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Fedora
sudo dnf install clang cmake ninja-build gtk3-devel
```

**Android Development Environment:**
- Android Studio
- Android SDK
- Android Emulator or physical device

**iOS Development Environment:**
- Xcode
- iOS Simulator or physical device
- Apple Developer Account (required for distribution)

#### Project Setup
```bash
# 1. Clone repository
git clone [repository_url]
cd [project_directory]

# 2. Check Flutter environment
flutter doctor

# 3. Get dependencies
flutter pub get

# 4. Start development
# Run on default device
flutter run

# Run on specific platform
flutter run -d windows  # Windows
flutter run -d macos   # macOS
flutter run -d linux   # Linux
flutter run -d chrome --web-browser-flag "--disable-web-security" # Web & disable security check for CORS
flutter run -d android # Android
flutter run -d ios     # iOS

# 5. Build release version
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

#### Common Development Commands
```bash
# Generate internationalization text
dart run slang

# Clean build cache
flutter clean

# Update Flutter SDK
flutter upgrade

# Analyze code
flutter analyze

# Run tests
flutter test

# List connected devices
flutter devices

# Create new page/component
flutter create component_name
```

#### Important Notes
1. Ensure proper configuration of development environment for each platform
2. iOS development requires macOS system
3. Regularly update Flutter SDK and dependencies
4. Use `.gitignore` to exclude unnecessary files
5. Follow Flutter official best practices guidelines

#### Troubleshooting
```bash
# Resolve dependency conflicts
flutter pub cache repair
flutter clean
flutter pub get

# Emulator issues
flutter emulators
flutter emulators --launch <emulator_id>

# Reset development tools
flutter config --clear-features
```

These settings cover the main aspects of Flutter cross-platform development. Additional configuration or tools may be required depending on specific project needs. It's recommended to regularly check Flutter official documentation for the latest development guidelines and best practices.

### 🌍 Internationalization
Currently, the internationalization texts are generated using GPT. If you'd like to contribute to translations, please refer to the Simplified Chinese template at [lib/i18n/zh-CN.i18n.yaml](lib/i18n/zh-CN.i18n.yaml).

### 💬 Feedback
For suggestions or bug reports, please submit an issue in the repository's issue tracker.

### 🙏 Acknowledgments
This project wouldn't be possible without the inspiration and learning from these amazing projects:

- [iwrqk/iwrqk](https://github.com/iwrqk/iwrqk) - An excellent Flutter implementation of Iwara client
- [wgh136/PicaComic](https://github.com/wgh136/PicaComic) - A well-structured Flutter comic application

Many of the implementations and best practices in this project were learned from these repositories.
