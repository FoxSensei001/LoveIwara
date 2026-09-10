import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:i_iwara/utils/logger_utils.dart';

/// iOS 文件夹选取返回的数据。
class IosFolderPickResult {
  const IosFolderPickResult({
    required this.path,
    required this.bookmark,
    required this.displayName,
  });

  final String path;
  final String bookmark;
  final String displayName;

  factory IosFolderPickResult.fromMap(Map<Object?, Object?> raw) {
    return IosFolderPickResult(
      path: raw['path'] as String? ?? '',
      bookmark: raw['bookmark'] as String? ?? '',
      displayName: raw['displayName'] as String? ?? '',
    );
  }
}

/// iOS 解析 security-scoped bookmark 返回的数据。
class IosResolvedBookmark {
  const IosResolvedBookmark({
    required this.path,
    required this.stale,
    this.bookmark,
  });

  final String path;
  final bool stale;
  final String? bookmark;

  factory IosResolvedBookmark.fromMap(Map<Object?, Object?> raw) {
    return IosResolvedBookmark(
      path: raw['path'] as String? ?? '',
      stale: raw['stale'] as bool? ?? false,
      bookmark: raw['bookmark'] as String?,
    );
  }
}

/// Flutter facade for iOS folder picker and security-scoped bookmarks.
///
/// 隔离于通用的文件处理 channel。iOS 的沙箱外目录访问必须靠 security-scoped bookmark，
/// 选完目录后由原生层生成持久化 bookmark；每次访问前需要显式开启权限，访问结束后关闭。
class IosFolderPickerService extends GetxService {
  static IosFolderPickerService get to =>
      Get.isRegistered<IosFolderPickerService>()
      ? Get.find<IosFolderPickerService>()
      : Get.put(IosFolderPickerService());

  static const String channelName = 'i_iwara/ios_folder_picker';
  static const Duration _nativeCallTimeout = Duration(seconds: 15);

  final MethodChannel _channel = const MethodChannel(channelName);

  /// 弹出 UIDocumentPickerViewController 选取文件夹。
  ///
  /// 用户选择后返回路径、base64 书签与目录名；用户取消或非 iOS 平台返回 null。
  /// 注意：此处不设原生超时，等待用户在系统选择器中完成交互。
  Future<IosFolderPickResult?> pickFolder() async {
    if (!GetPlatform.isIOS) return null;
    try {
      final raw = await _channel.invokeMethod<Object?>('pickFolder');
      if (raw is! Map) return null;
      final result = IosFolderPickResult.fromMap(raw);
      if (result.path.isEmpty || result.bookmark.isEmpty) return null;
      return result;
    } catch (e, s) {
      logFailure('pickFolder 失败', e, s);
      return null;
    }
  }

  /// 将持久化的 base64 bookmark 解析为当前绝对路径。
  ///
  /// 若书签失效（stale 为 true），原生层会尝试更新并回传新的 bookmark。
  /// 无法解析或非 iOS 平台返回 null。
  Future<IosResolvedBookmark?> resolveBookmark(String bookmark) async {
    if (!GetPlatform.isIOS) return null;
    if (bookmark.isEmpty) return null;
    try {
      final raw = await _channel
          .invokeMethod<Object?>('resolveBookmark', <String, Object?>{
            'bookmark': bookmark,
          })
          .timeout(_nativeCallTimeout);
      if (raw is! Map) return null;
      final result = IosResolvedBookmark.fromMap(raw);
      if (result.path.isEmpty) return null;
      return result;
    } catch (e, s) {
      logFailure('resolveBookmark 失败', e, s);
      return null;
    }
  }

  /// 开启对 security-scoped bookmark 对应目录的访问权。
  ///
  /// 对应原生 startAccessingSecurityScopedResource。非 iOS 平台返回 false。
  Future<bool> startAccess(String bookmark) async {
    if (!GetPlatform.isIOS) return false;
    if (bookmark.isEmpty) return false;
    try {
      final res = await _channel
          .invokeMethod<bool>('startAccess', <String, Object?>{
            'bookmark': bookmark,
          })
          .timeout(_nativeCallTimeout);
      return res == true;
    } catch (e, s) {
      logFailure('startAccess 失败', e, s);
      return false;
    }
  }

  /// 停止对 security-scoped bookmark 对应目录的访问权。
  ///
  /// 对应原生 stopAccessingSecurityScopedResource。非 iOS 平台返回 false。
  Future<bool> stopAccess(String bookmark) async {
    if (!GetPlatform.isIOS) return false;
    if (bookmark.isEmpty) return false;
    try {
      final res = await _channel
          .invokeMethod<bool>('stopAccess', <String, Object?>{
            'bookmark': bookmark,
          })
          .timeout(_nativeCallTimeout);
      return res == true;
    } catch (e, s) {
      logFailure('stopAccess 失败', e, s);
      return false;
    }
  }

  static void logFailure(String message, Object error, StackTrace stackTrace) {
    LogUtils.e(
      message,
      tag: 'IosFolderPicker',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
