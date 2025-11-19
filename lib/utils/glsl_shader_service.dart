import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// GLSL 着色器文件管理服务
/// 用于将 assets 中的 GLSL 文件复制到临时目录供 MPV 使用
class GlslShaderService extends GetxService {
  static const String shaderAssetPath = 'assets/anime4k_shaders';
  static const String shaderBasePath = 'assets/anime4k_shaders/';

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
      final glslAssets = assetManifest.listAssets()
          .where((asset) => asset.startsWith(shaderAssetPath) && asset.endsWith('.glsl'))
          .toList();

      LogUtils.d('发现 ${glslAssets.length} 个 GLSL 文件需要复制', 'GlslShaderService');

      for (final assetPath in glslAssets) {
        await _copyShaderFile(assetPath);
      }

      LogUtils.d('所有 GLSL 文件复制完成', 'GlslShaderService');
    } catch (e) {
      LogUtils.e('复制 GLSL 文件时出错', tag: 'GlslShaderService', error: e);
      rethrow;
    }
  }

  /// 复制单个 GLSL 文件
  Future<void> _copyShaderFile(String assetPath) async {
    try {
      // 获取文件名
      final fileName = path.basename(assetPath);
      final tempFilePath = path.join(_tempShaderDirectory!, fileName);

      // 检查文件是否已存在且是最新的
      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        // 如果文件已存在，跳过复制
        LogUtils.d('GLSL 文件已存在，跳过: $fileName', 'GlslShaderService');
        return;
      }

      // 读取 assets 文件
      final assetData = await rootBundle.load(assetPath);

      // 写入临时文件
      await tempFile.writeAsBytes(assetData.buffer.asUint8List());

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

