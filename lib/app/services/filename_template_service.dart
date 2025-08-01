import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path;

/// 文件命名模板服务
/// 支持的变量：
/// %title - 标题
/// %author - 作者名称
/// %username - 作者用户名
/// %quality - 视频质量
/// %filename - 原始文件名
/// %id - 内容ID
/// %date - 当前日期 (YYYY-MM-DD)
/// %time - 当前时间 (HH-MM-SS)
/// %datetime - 当前日期时间 (YYYY-MM-DD_HH-MM-SS)
class FilenameTemplateService extends GetxService {
  static FilenameTemplateService get to => Get.find();

  /// 为视频生成文件名
  String generateVideoFilename({
    required String template,
    required Video video,
    required String quality,
    String? originalFilename,
  }) {
    try {
      String filename = template;
      
      // 替换基本信息
      filename = filename.replaceAll('%title', _sanitize(video.title ?? 'video'));
      filename = filename.replaceAll('%author', _sanitize(video.user?.name ?? 'unknown'));
      filename = filename.replaceAll('%username', _sanitize(video.user?.username ?? 'unknown'));
      filename = filename.replaceAll('%quality', _sanitize(quality));
      filename = filename.replaceAll('%id', _sanitize(video.id ?? 'unknown'));
      
      // 处理原始文件名
      if (originalFilename != null) {
        final nameWithoutExt = path.basenameWithoutExtension(originalFilename);
        filename = filename.replaceAll('%filename', _sanitize(nameWithoutExt));
      } else {
        filename = filename.replaceAll('%filename', 'video');
      }
      
      // 替换日期时间
      filename = _replaceDateTimeVariables(filename);
      
      // 确保文件名不为空
      if (filename.trim().isEmpty) {
        filename = '${video.title ?? 'video'}_$quality';
      }
      
      // 添加扩展名
      if (!filename.toLowerCase().endsWith('.mp4')) {
        filename += '.mp4';
      }
      
      LogUtils.d('生成视频文件名: $filename', 'FilenameTemplateService');
      return filename;
    } catch (e) {
      LogUtils.e('生成视频文件名失败', tag: 'FilenameTemplateService', error: e);
      return '${video.title ?? 'video'}_$quality.mp4';
    }
  }

  /// 为图库生成文件夹名
  String generateGalleryFoldername({
    required String template,
    required ImageModel gallery,
  }) {
    try {
      String foldername = template;
      
      // 替换基本信息
      foldername = foldername.replaceAll('%title', _sanitize(gallery.title ?? 'gallery'));
      foldername = foldername.replaceAll('%author', _sanitize(gallery.user?.name ?? 'unknown'));
      foldername = foldername.replaceAll('%username', _sanitize(gallery.user?.username ?? 'unknown'));
      foldername = foldername.replaceAll('%id', _sanitize(gallery.id ?? 'unknown'));
      
      // 图库特有的变量
      foldername = foldername.replaceAll('%count', gallery.files.length.toString());
      
      // 替换日期时间
      foldername = _replaceDateTimeVariables(foldername);
      
      // 确保文件夹名不为空
      if (foldername.trim().isEmpty) {
        foldername = '${gallery.title ?? 'gallery'}_${gallery.id}';
      }
      
      LogUtils.d('生成图库文件夹名: $foldername', 'FilenameTemplateService');
      return foldername;
    } catch (e) {
      LogUtils.e('生成图库文件夹名失败', tag: 'FilenameTemplateService', error: e);
      return '${gallery.title ?? 'gallery'}_${gallery.id}';
    }
  }

  /// 为单张图片生成文件名
  String generateImageFilename({
    required String template,
    required String title,
    required String? authorName,
    required String? authorUsername,
    required String? id,
    String? originalFilename,
  }) {
    try {
      String filename = template;
      
      // 替换基本信息
      filename = filename.replaceAll('%title', _sanitize(title.isNotEmpty ? title : 'image'));
      filename = filename.replaceAll('%author', _sanitize(authorName ?? 'unknown'));
      filename = filename.replaceAll('%username', _sanitize(authorUsername ?? 'unknown'));
      filename = filename.replaceAll('%id', _sanitize(id ?? 'unknown'));
      
      // 处理原始文件名
      if (originalFilename != null) {
        final nameWithoutExt = path.basenameWithoutExtension(originalFilename);
        final extension = path.extension(originalFilename);
        filename = filename.replaceAll('%filename', _sanitize(nameWithoutExt));
        
        // 如果模板中没有扩展名，添加原始扩展名
        if (!filename.contains('.') && extension.isNotEmpty) {
          filename += extension;
        }
      } else {
        filename = filename.replaceAll('%filename', 'image');
      }
      
      // 替换日期时间
      filename = _replaceDateTimeVariables(filename);
      
      // 确保文件名不为空
      if (filename.trim().isEmpty) {
        filename = title.isNotEmpty ? title : 'image';
      }
      
      LogUtils.d('生成图片文件名: $filename', 'FilenameTemplateService');
      return filename;
    } catch (e) {
      LogUtils.e('生成图片文件名失败', tag: 'FilenameTemplateService', error: e);
      return originalFilename ?? 'image.jpg';
    }
  }

  /// 替换日期时间变量
  String _replaceDateTimeVariables(String filename) {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    final datetime = '${date}_$time';
    
    filename = filename.replaceAll('%date', date);
    filename = filename.replaceAll('%time', time);
    filename = filename.replaceAll('%datetime', datetime);
    
    return filename;
  }

  /// 清理文件名中的非法字符
  String _sanitize(String input) {
    if (input.isEmpty) return 'unknown';
    
    // 移除或替换非法字符
    String sanitized = input
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')  // 替换文件系统非法字符
        .replaceAll(RegExp(r'\s+'), '_')           // 空白字符替换为下划线
        .replaceAll(RegExp(r'_{2,}'), '_')         // 多个连续下划线替换为单个
        .replaceAll(RegExp(r'^_+|_+$'), '');       // 移除开头和结尾的下划线
    
    // 确保不为空
    if (sanitized.isEmpty) {
      sanitized = 'unknown';
    }
    
    // 限制长度（避免文件名过长）
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }
    
    return sanitized;
  }

  /// 获取支持的变量列表
  List<TemplateVariable> getSupportedVariables() {
    return [
      TemplateVariable('%title', slang.t.settings.downloadSettings.variableTitle),
      TemplateVariable('%author', slang.t.settings.downloadSettings.variableAuthor),
      TemplateVariable('%username', slang.t.settings.downloadSettings.variableUsername),
      TemplateVariable('%quality', slang.t.settings.downloadSettings.variableQuality),
      TemplateVariable('%filename', slang.t.settings.downloadSettings.variableFilename),
      TemplateVariable('%id', slang.t.settings.downloadSettings.variableId),
      TemplateVariable('%count', slang.t.settings.downloadSettings.variableCount),
      TemplateVariable('%date', slang.t.settings.downloadSettings.variableDate),
      TemplateVariable('%time', slang.t.settings.downloadSettings.variableTime),
      TemplateVariable('%datetime', slang.t.settings.downloadSettings.variableDatetime),
    ];
  }

  /// 验证模板是否有效
  bool validateTemplate(String template) {
    if (template.trim().isEmpty) return false;
    
    // 检查是否包含非法字符（除了变量占位符）
    final withoutVariables = template.replaceAll(RegExp(r'%\w+'), '');
    if (withoutVariables.contains(RegExp(r'[<>:"|?*]'))) {
      return false;
    }
    
    return true;
  }
}

/// 模板变量类
class TemplateVariable {
  final String variable;
  final String description;
  
  const TemplateVariable(this.variable, this.description);
}
