import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// GLSL 着色器文件管理服务
/// 用于将 assets 中的 GLSL 文件复制到临时目录供 MPV 使用
class GlslShaderService extends GetxService {
  static const String shaderAssetPath = 'assets/anime4k_shaders';
  static const String shaderBasePath = 'assets/anime4k_shaders/';

  /// 缓存指纹文件名，用于跳过已完成的复制流程
  static const String _cacheStampFileName = '.cache-stamp';

  String? _tempShaderDirectory;
  bool _isInitialized = false;

  /// 获取临时着色器目录路径
  String? get tempShaderDirectory => _tempShaderDirectory;

  /// 服务是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化服务
  Future<GlslShaderService> init() async {
    try {
      LogUtils.i('开始初始化 GLSL 着色器服务', 'GlslShaderService');

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      _tempShaderDirectory = path.join(tempDir.path, 'anime4k_shaders');

      // 创建临时目录
      final shaderDir = Directory(_tempShaderDirectory!);
      if (!await shaderDir.exists()) {
        await shaderDir.create(recursive: true);
        LogUtils.d('创建临时着色器目录: $_tempShaderDirectory', 'GlslShaderService');
      }

      // 复制所有 GLSL 文件
      await _copyAllShaders();

      _isInitialized = true;
      LogUtils.i('GLSL 着色器服务初始化完成', 'GlslShaderService');

      return this;
    } catch (e) {
      LogUtils.e('GLSL 着色器服务初始化失败', tag: 'GlslShaderService', error: e);
      _isInitialized = false;
      return this;
    }
  }

  /// 复制所有 GLSL 文件到临时目录
  Future<void> _copyAllShaders() async {
    try {
      // 获取 assets 目录下的所有 GLSL 文件
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final glslAssets =
          assetManifest.listAssets()
              .where(
                (asset) =>
                    asset.startsWith(shaderAssetPath) && asset.endsWith('.glsl'),
              )
              .toList()
            ..sort();

      // 缓存指纹命中则整轮跳过。
      // 逐个文件比对字节数需要先把 assets 全部读出来（39 个文件约 2.4MB，
      // 且 rootBundle.load 不走 CachingAssetBundle 的缓存，每次都是平台通道往返），
      // 而本服务在 app_startup 中是 await 初始化的，会直接拖慢每一次冷启动 ——
      // 哪怕用户从未开启 Anime4K。指纹带上版本号与文件清单，
      // 应用升级或着色器增删时自动失效；debug 构建不吃缓存，方便本地改 shader。
      final String stamp =
          '${CommonConstants.VERSION}|${glslAssets.length}|${glslAssets.join(',')}';
      final File stampFile = File(
        path.join(_tempShaderDirectory!, _cacheStampFileName),
      );
      if (!kDebugMode &&
          await stampFile.exists() &&
          await stampFile.readAsString() == stamp) {
        LogUtils.d('GLSL 缓存指纹命中，跳过复制', 'GlslShaderService');
        return;
      }

      LogUtils.d('发现 ${glslAssets.length} 个 GLSL 文件需要复制', 'GlslShaderService');

      for (final assetPath in glslAssets) {
        await _copyShaderFile(assetPath);
      }

      // 指纹最后才写，中途失败下次会重新完整复制
      await stampFile.writeAsString(stamp, flush: true);

      LogUtils.d('所有 GLSL 文件复制完成', 'GlslShaderService');
    } catch (e) {
      LogUtils.e('复制 GLSL 文件时出错', tag: 'GlslShaderService', error: e);
      rethrow;
    }
  }

  /// 作废缓存指纹，使下一次 [_copyAllShaders] 重新完整复制
  Future<void> _invalidateCacheStamp() async {
    if (_tempShaderDirectory == null) return;
    try {
      final stampFile = File(
        path.join(_tempShaderDirectory!, _cacheStampFileName),
      );
      if (await stampFile.exists()) {
        await stampFile.delete();
      }
    } catch (e) {
      LogUtils.w('删除 GLSL 缓存指纹失败: $e', 'GlslShaderService');
    }
  }

  /// 复制单个 GLSL 文件
  ///
  /// 临时目录属于系统缓存，可能被清理、被上一次写入中断而留下半截文件；
  /// 而 mpv 只要读到一个内容不完整的 shader 就会解析失败并渲染黑屏。
  /// 因此这里以「字节数一致」作为跳过条件，并先写 .tmp 再 rename，
  /// 保证目录里出现的文件一定是完整的。
  Future<void> _copyShaderFile(String assetPath) async {
    try {
      // 获取文件名
      final fileName = path.basename(assetPath);
      final tempFilePath = path.join(_tempShaderDirectory!, fileName);

      // 读取 assets 文件
      final assetData = await rootBundle.load(assetPath);
      final bytes = assetData.buffer.asUint8List();

      // 已存在且大小一致，视为有效缓存，跳过复制
      final tempFile = File(tempFilePath);
      if (await tempFile.exists() && await tempFile.length() == bytes.length) {
        return;
      }

      // 先写入临时文件再原子重命名，避免中断留下残缺的 shader
      final stagingFile = File('$tempFilePath.tmp');
      await stagingFile.writeAsBytes(bytes, flush: true);
      await stagingFile.rename(tempFilePath);

      LogUtils.d('复制 GLSL 文件: $fileName -> $tempFilePath', 'GlslShaderService');
    } catch (e) {
      LogUtils.e('复制 GLSL 文件失败: $assetPath', tag: 'GlslShaderService', error: e);
      rethrow;
    }
  }

  /// 获取临时文件的完整路径
  String getTempShaderPath(String fileName) {
    if (!_isInitialized || _tempShaderDirectory == null) {
      throw StateError('GlslShaderService 未初始化');
    }
    return path.join(_tempShaderDirectory!, fileName);
  }

  /// 确保服务可用；若首次初始化失败（或缓存目录被系统清理）则重试一次
  Future<bool> ensureInitialized() async {
    if (_isInitialized && _tempShaderDirectory != null) {
      final shaderDir = Directory(_tempShaderDirectory!);
      if (await shaderDir.exists()) {
        return true;
      }
      LogUtils.w('临时着色器目录已丢失，重新初始化', 'GlslShaderService');
      _isInitialized = false;
    }

    await init();
    return _isInitialized;
  }

  /// 解析一组 shader 文件在磁盘上的绝对路径
  ///
  /// 只有当每个文件都真实存在且非空时才返回路径列表，否则返回 null。
  /// mpv 无法读取 Flutter 的 assets 路径，把不可读的路径交给它只会静默渲染失败，
  /// 所以调用方应当在拿到 null 时直接放弃应用 shader。
  ///
  /// 临时目录随时可能被系统清理掉其中一部分文件，此时 [allowRepair] 会作废缓存指纹
  /// 并重新复制一次，避免 Anime4K 在剩余进程生命周期里静默失效。
  Future<List<String>?> resolveShaderPaths(
    List<String> fileNames, {
    bool allowRepair = true,
  }) async {
    if (!await ensureInitialized()) {
      LogUtils.w('GLSL 着色器服务不可用，无法解析 shader 路径', 'GlslShaderService');
      return null;
    }

    final resolved = <String>[];
    for (final fileName in fileNames) {
      final filePath = path.join(_tempShaderDirectory!, fileName);
      final file = File(filePath);
      if (!await file.exists() || await file.length() == 0) {
        LogUtils.w('着色器文件缺失或为空: $fileName', 'GlslShaderService');
        if (!allowRepair) return null;

        try {
          await _invalidateCacheStamp();
          await _copyAllShaders();
        } catch (e) {
          LogUtils.e('重新复制 GLSL 文件失败', tag: 'GlslShaderService', error: e);
          return null;
        }
        return resolveShaderPaths(fileNames, allowRepair: false);
      }
      resolved.add(filePath);
    }
    return resolved;
  }

  /// 清理临时文件
  Future<void> cleanup() async {
    if (_tempShaderDirectory != null) {
      try {
        final shaderDir = Directory(_tempShaderDirectory!);
        if (await shaderDir.exists()) {
          await shaderDir.delete(recursive: true);
          LogUtils.d('清理临时 GLSL 目录: $_tempShaderDirectory', 'GlslShaderService');
        }
      } catch (e) {
        LogUtils.e('清理临时 GLSL 目录失败', tag: 'GlslShaderService', error: e);
      }
    }
  }

  /// 检查临时文件是否存在
  Future<bool> hasShaderFile(String fileName) async {
    if (!_isInitialized || _tempShaderDirectory == null) {
      return false;
    }

    final filePath = path.join(_tempShaderDirectory!, fileName);
    final file = File(filePath);
    return await file.exists();
  }
}

