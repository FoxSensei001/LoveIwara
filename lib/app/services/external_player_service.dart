import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 转交目标的两种形态：本机文件（已下载 / 纯本地视频）与在线直链。
enum ExternalPlayerSourceKind { localFile, onlineUrl }

/// 「当前正在放的这个东西」交给外部播放器时需要的全部信息。
class ExternalPlayerSource {
  const ExternalPlayerSource({
    required this.kind,
    required this.value,
    this.title,
    this.qualityTag,
  });

  final ExternalPlayerSourceKind kind;

  /// 本地文件的绝对路径（或 `content://` URI）；在线视频的直链。
  final String value;

  final String? title;

  /// 在线视频转交时用的是当前清晰度，展示给用户看清楚交出去的是哪一档。
  final String? qualityTag;

  bool get isLocalFile => kind == ExternalPlayerSourceKind.localFile;
}

enum ExternalPlayerHandoffStatus {
  /// 已经把视频交出去（选择器弹出 / 外部应用已启动）。
  handedOff,

  /// 本机没有能接手的播放器。
  noHandler,

  /// 当前平台不支持这种转交（例如桌面端的在线直链）。
  unsupported,

  /// 转交过程本身失败。
  failed,

  /// 要转交的本地文件已经不在了。
  fileMissing,

  /// 配置的外部播放器可执行文件不存在（装了又卸载、或路径被改）。
  executableMissing,
}

class ExternalPlayerHandoffResult {
  const ExternalPlayerHandoffResult(this.status, {this.message});

  final ExternalPlayerHandoffStatus status;
  final String? message;

  bool get isSuccess => status == ExternalPlayerHandoffStatus.handedOff;
}

/// 把当前视频转交给本机其它播放器。
///
/// 动机来自 VR 头显（Quest / Horizon OS）：应用自己是一块 2D 面板，放不了
/// VR/180/360 片源，而头显上的 Skybox、Pigasus 这类播放器可以。同一套机制在
/// 手机上也能把视频丢给 MX Player / VLC，在桌面端则是「用系统默认播放器打开」。
///
/// 各平台走的通道不一样：
/// - Android：原生 `ACTION_VIEW` + 系统选择器（本地文件过 FileProvider 换
///   `content://` 并逐次授读权限；在线直链带 `video/*` mime，否则命中的是浏览器）。
/// - iOS：系统没有「用其它应用打开」的选择器，等价物是分享面板。
/// - 桌面：本地文件交给系统默认程序；在线直链没有对应机制，只能复制链接。
class ExternalPlayerService {
  static const MethodChannel _channel = MethodChannel(
    'i_iwara/external_player',
  );

  /// 按「离线优先」挑出该交给外部播放器的那一份。
  ///
  /// 优先级：纯本地视频的路径 > 当前清晰度已下载完成的文件 > 在线直链。
  /// 本地文件不受直链时效影响，外部播放器放到一半不会断，所以只要手上有
  /// 本地副本就一定交本地副本。三者都没有时返回 null（调用方提示地址不可用）。
  static ExternalPlayerSource? chooseSource({
    String? localVideoPath,
    String? downloadedPath,
    String? onlineUrl,
    String? title,
    String? qualityTag,
  }) {
    if (localVideoPath != null && localVideoPath.isNotEmpty) {
      return ExternalPlayerSource(
        kind: ExternalPlayerSourceKind.localFile,
        value: localVideoPath,
        title: title,
      );
    }
    if (downloadedPath != null && downloadedPath.isNotEmpty) {
      return ExternalPlayerSource(
        kind: ExternalPlayerSourceKind.localFile,
        value: downloadedPath,
        title: title,
        qualityTag: qualityTag,
      );
    }
    if (onlineUrl != null && onlineUrl.isNotEmpty) {
      return ExternalPlayerSource(
        kind: ExternalPlayerSourceKind.onlineUrl,
        value: onlineUrl,
        title: title,
        qualityTag: qualityTag,
      );
    }
    return null;
  }

  /// 「交给系统默认程序」这条路当前平台走不走得通（用来决定那一行显不显示）。
  ///
  /// 桌面端只对本地文件成立：在线直链没有对应的系统机制，得靠用户自己配的
  /// 播放器（[DesktopPlayerStore]）或复制链接。
  static bool supports(ExternalPlayerSource source) {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) return true;
    if (GetPlatform.isDesktop) return source.isLocalFile;
    return false;
  }

  /// 桌面端：用用户配置的某个外部播放器打开。
  ///
  /// PCVR 播放器（HereSphere / DeoVR / Whirligig 等）不是系统默认关联程序，
  /// 这条路径才是它们唯一能被拉起来的方式；且它同时打通了桌面端的在线直链——
  /// 这些播放器都能从命令行直接接一个 URL。
  static Future<ExternalPlayerHandoffResult> openWithDesktopPlayer(
    DesktopPlayerEntry entry,
    ExternalPlayerSource source,
  ) async {
    final input = source.isLocalFile
        ? stripFileScheme(source.value)
        : source.value;

    if (source.isLocalFile && !await File(input).exists()) {
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.fileMissing,
      );
    }
    if (!await File(entry.executablePath).exists()) {
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.executableMissing,
      );
    }

    final launched = await DesktopPlayerLauncher.launch(entry, input);
    return ExternalPlayerHandoffResult(
      launched
          ? ExternalPlayerHandoffStatus.handedOff
          : ExternalPlayerHandoffStatus.failed,
    );
  }

  /// 本机有几个能接手的播放器。仅 Android 能问出确切数字；
  /// 其余平台返回 `null` 表示「问不出来，但也别据此禁用入口」。
  static Future<int?> countHandlers(ExternalPlayerSource source) async {
    if (!GetPlatform.isAndroid) return null;
    try {
      final count = await _channel.invokeMethod<int>('countHandlers', {
        'filePath': source.isLocalFile ? source.value : null,
        'url': source.isLocalFile ? null : source.value,
      });
      return count;
    } on MissingPluginException catch (e) {
      LogUtils.w('外部播放器通道未注册（旧原生层）: $e', 'ExternalPlayer');
      return null;
    } catch (e, s) {
      LogUtils.e('查询外部播放器数量失败', tag: 'ExternalPlayer', error: e, stackTrace: s);
      return null;
    }
  }

  static Future<ExternalPlayerHandoffResult> open(
    ExternalPlayerSource source, {
    String? chooserTitle,
  }) async {
    if (!supports(source)) {
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.unsupported,
      );
    }

    try {
      if (GetPlatform.isAndroid) {
        return await _openOnAndroid(source, chooserTitle);
      }
      if (GetPlatform.isIOS) {
        return await _openOnIOS(source);
      }
      return await _openOnDesktop(source);
    } catch (e, s) {
      LogUtils.e('转交外部播放器失败', tag: 'ExternalPlayer', error: e, stackTrace: s);
      return ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.failed,
        message: e.toString(),
      );
    }
  }

  static Future<ExternalPlayerHandoffResult> _openOnAndroid(
    ExternalPlayerSource source,
    String? chooserTitle,
  ) async {
    try {
      final handed = await _channel.invokeMethod<bool>('openVideo', {
        'filePath': source.isLocalFile ? source.value : null,
        'url': source.isLocalFile ? null : source.value,
        'chooserTitle': chooserTitle,
      });
      return ExternalPlayerHandoffResult(
        handed == true
            ? ExternalPlayerHandoffStatus.handedOff
            : ExternalPlayerHandoffStatus.noHandler,
      );
    } on MissingPluginException catch (e) {
      LogUtils.w('外部播放器通道未注册（旧原生层）: $e', 'ExternalPlayer');
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.unsupported,
      );
    } on PlatformException catch (e) {
      return ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.failed,
        message: e.message,
      );
    }
  }

  static Future<ExternalPlayerHandoffResult> _openOnIOS(
    ExternalPlayerSource source,
  ) async {
    // iOS 没有「用其它应用打开」的选择器，分享面板是唯一等价物。
    final params = source.isLocalFile
        ? ShareParams(files: [XFile(stripFileScheme(source.value))])
        : ShareParams(text: source.value);
    await SharePlus.instance.share(params);
    return const ExternalPlayerHandoffResult(
      ExternalPlayerHandoffStatus.handedOff,
    );
  }

  static Future<ExternalPlayerHandoffResult> _openOnDesktop(
    ExternalPlayerSource source,
  ) async {
    final path = stripFileScheme(source.value);
    if (!await File(path).exists()) {
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.failed,
      );
    }
    final result = await OpenFile.open(path);
    if (result.type == ResultType.done) {
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.handedOff,
      );
    }
    if (result.type == ResultType.noAppToOpen) {
      return const ExternalPlayerHandoffResult(
        ExternalPlayerHandoffStatus.noHandler,
      );
    }
    return ExternalPlayerHandoffResult(
      ExternalPlayerHandoffStatus.failed,
      message: result.message,
    );
  }

  /// `file://` 前缀只有 media_kit 需要；交给 share_plus / OpenFile 的必须是
  /// 裸路径，且路径里的中文、空格在拼进 URI 时可能已被百分号编码。
  @visibleForTesting
  static String stripFileScheme(String value) {
    if (!value.startsWith('file://')) return value;
    return Uri.decodeFull(value.substring('file://'.length));
  }
}
