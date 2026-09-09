import 'dart:convert';

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

  static const int _maxPathSegmentLength = 150;

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
      filename = filename.replaceAll(
        '%title',
        _sanitize(video.title ?? 'video'),
      );
      filename = filename.replaceAll(
        '%author',
        _sanitize(video.user?.name ?? 'unknown'),
      );
      filename = filename.replaceAll(
        '%username',
        _sanitize(video.user?.username ?? 'unknown'),
      );
      filename = filename.replaceAll('%quality', _sanitize(quality));
      filename = filename.replaceAll('%id', _sanitize(video.id));

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
      filename = sanitizePathSegment(filename, fallback: 'video.mp4');
      if (!filename.toLowerCase().endsWith('.mp4')) {
        filename += '.mp4';
      }

      LogUtils.d('生成视频文件名: $filename', 'FilenameTemplateService');
      return filename;
    } catch (e) {
      LogUtils.e('生成视频文件名失败', tag: 'FilenameTemplateService', error: e);
      return sanitizePathSegment(
        '${video.title ?? 'video'}_$quality.mp4',
        fallback: 'video.mp4',
      );
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
      foldername = foldername.replaceAll('%title', _sanitize(gallery.title));
      foldername = foldername.replaceAll(
        '%author',
        _sanitize(gallery.user?.name ?? 'unknown'),
      );
      foldername = foldername.replaceAll(
        '%username',
        _sanitize(gallery.user?.username ?? 'unknown'),
      );
      foldername = foldername.replaceAll('%id', _sanitize(gallery.id));

      // 图库特有的变量
      foldername = foldername.replaceAll(
        '%count',
        gallery.files.length.toString(),
      );

      // 替换日期时间
      foldername = _replaceDateTimeVariables(foldername);

      // 确保文件夹名不为空
      if (foldername.trim().isEmpty) {
        foldername = '${gallery.title}_${gallery.id}';
      }
      foldername = sanitizePathSegment(
        foldername,
        fallback: 'gallery_${gallery.id}',
      );

      LogUtils.d('生成图库文件夹名: $foldername', 'FilenameTemplateService');
      return foldername;
    } catch (e) {
      LogUtils.e('生成图库文件夹名失败', tag: 'FilenameTemplateService', error: e);
      return sanitizePathSegment(
        '${gallery.title}_${gallery.id}',
        fallback: 'gallery',
      );
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
      filename = filename.replaceAll(
        '%title',
        _sanitize(title.isNotEmpty ? title : 'image'),
      );
      filename = filename.replaceAll(
        '%author',
        _sanitize(authorName ?? 'unknown'),
      );
      filename = filename.replaceAll(
        '%username',
        _sanitize(authorUsername ?? 'unknown'),
      );
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
      filename = sanitizePathSegment(
        filename,
        fallback: originalFilename ?? 'image.jpg',
      );

      LogUtils.d('生成图片文件名: $filename', 'FilenameTemplateService');
      return filename;
    } catch (e) {
      LogUtils.e('生成图片文件名失败', tag: 'FilenameTemplateService', error: e);
      return sanitizePathSegment(
        originalFilename ?? 'image.jpg',
        fallback: 'image.jpg',
      );
    }
  }

  /// 替换日期时间变量
  String _replaceDateTimeVariables(String filename) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    final datetime = '${date}_$time';

    filename = filename.replaceAll('%date', date);
    filename = filename.replaceAll('%time', time);
    filename = filename.replaceAll('%datetime', datetime);

    return filename;
  }

  /// 清理文件名中的非法字符
  String _sanitize(String input) {
    return sanitizePathSegment(input, fallback: 'unknown', maxLength: 100);
  }

  /// 将任意模板输出压缩成单个安全路径片段。
  ///
  /// 模板中的字面量也可能包含路径分隔符，因此生成完整文件名后必须再做
  /// 一次整段清理，避免 path.join(base, filename) 被 "../" 逃逸。
  ///
  /// 为便于在 [DownloadService] 等静态上下文中复用同一套清理规则，这里设计为
  /// 纯静态函数，不依赖任何实例状态或 GetX 注册。
  static String sanitizePathSegment(
    String input, {
    String fallback = 'download',
    int maxLength = _maxPathSegmentLength,
  }) {
    String sanitizeOnce(String value) {
      var result = value
          // 先归一空白：换行/制表等异形空白折成普通空格，连续空白压成一个。
          // 必须排在控制字符替换之前，否则 \n \t 会先被当成控制字符变成下划线。
          .replaceAll(RegExp(r'\s+'), ' ')
          // 再处理各平台文件系统真正拒绝的那一批字符 + 剩余控制字符。
          // ⛔ 空格不在其中：Windows / APFS / ext4 / SAF 都允许名字中间有空格，
          // 把它换成下划线会把用户模板 "Iwara - %title [%id] [%quality]" 拧成
          // "Iwara_-_..."（issue #93）。同理不再压缩连续下划线和连续点号，
          // 那会把 "Ep.1 ... The End" 这种标题吃掉一段。
          .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F\x7F]'), '_');
      // 开头的点会变成 Unix 隐藏文件，也是 "." / ".." 逃逸的入口；
      // 结尾的点和空格会被 Windows 静默吃掉，导致「记录的路径」和
      // 「磁盘上的文件名」对不上。两头都清掉，中间一律保留。
      result = result.replaceAll(RegExp(r'^[.\s]+'), '');
      result = result.replaceAll(RegExp(r'[.\s]+$'), '');
      return result;
    }

    var sanitized = sanitizeOnce(input);
    if (sanitized.isEmpty) {
      sanitized = sanitizeOnce(fallback);
    }
    if (sanitized.isEmpty) {
      sanitized = 'download';
    }

    final extension = path.extension(sanitized);
    final baseName = extension.isNotEmpty
        ? path.basenameWithoutExtension(sanitized)
        : sanitized;
    final lower = baseName.toLowerCase();
    const reservedWindowsNames = {
      'con',
      'prn',
      'aux',
      'nul',
      'com1',
      'com2',
      'com3',
      'com4',
      'com5',
      'com6',
      'com7',
      'com8',
      'com9',
      'lpt1',
      'lpt2',
      'lpt3',
      'lpt4',
      'lpt5',
      'lpt6',
      'lpt7',
      'lpt8',
      'lpt9',
    };
    if (reservedWindowsNames.contains(lower)) {
      sanitized = '${baseName}_file$extension';
    }

    return _truncatePathSegment(sanitized, maxLength);
  }

  /// 单个路径片段的字节上限。
  ///
  /// ext4 / APFS / exFAT 限的是 **255 字节**，不是 255 个字符：150 个日文假名
  /// 按 UTF-8 就是 450 字节，落盘直接 ENAMETOOLONG（下载失败，而不是名字变丑）。
  /// 留 55 字节余量给去重后缀 " (12)" 之类。
  static const int _maxPathSegmentBytes = 200;

  /// 按「字符数」和「UTF-8 字节数」两个上限截断，尽量保住扩展名，
  /// 且不把一对代理项（emoji）从中间切开。
  static String _truncatePathSegment(String value, int maxLength) {
    if (value.length <= maxLength &&
        utf8.encode(value).length <= _maxPathSegmentBytes) {
      return value;
    }

    final extension = path.extension(value);
    final keepExtension =
        extension.isNotEmpty &&
        extension.length < maxLength ~/ 2 &&
        utf8.encode(extension).length < _maxPathSegmentBytes ~/ 2;
    final base = keepExtension
        ? value.substring(0, value.length - extension.length)
        : value;
    final charBudget = keepExtension ? maxLength - extension.length : maxLength;
    final byteBudget = keepExtension
        ? _maxPathSegmentBytes - utf8.encode(extension).length
        : _maxPathSegmentBytes;

    var end = base.length < charBudget ? base.length : charBudget;
    while (end > 0) {
      // 不要停在代理项对中间：切一半会产出非法 UTF-16，落盘时同样会失败。
      final unit = base.codeUnitAt(end - 1);
      final isHighSurrogate = unit >= 0xD800 && unit <= 0xDBFF;
      if (isHighSurrogate || utf8.encode(base.substring(0, end)).length > byteBudget) {
        end--;
        continue;
      }
      break;
    }

    // 截断后可能又露出结尾的空格或点（Windows 会静默吃掉），再修一次。
    final truncated = base
        .substring(0, end)
        .replaceAll(RegExp(r'[.\s]+$'), '');
    if (truncated.isEmpty) {
      return keepExtension ? 'download$extension' : 'download';
    }
    return keepExtension ? '$truncated$extension' : truncated;
  }

  /// 获取支持的变量列表
  List<TemplateVariable> getSupportedVariables() {
    return [
      TemplateVariable(
        '%title',
        slang.t.settings.downloadSettings.variableTitle,
      ),
      TemplateVariable(
        '%author',
        slang.t.settings.downloadSettings.variableAuthor,
      ),
      TemplateVariable(
        '%username',
        slang.t.settings.downloadSettings.variableUsername,
      ),
      TemplateVariable(
        '%quality',
        slang.t.settings.downloadSettings.variableQuality,
      ),
      TemplateVariable(
        '%filename',
        slang.t.settings.downloadSettings.variableFilename,
      ),
      TemplateVariable('%id', slang.t.settings.downloadSettings.variableId),
      TemplateVariable(
        '%count',
        slang.t.settings.downloadSettings.variableCount,
      ),
      TemplateVariable('%date', slang.t.settings.downloadSettings.variableDate),
      TemplateVariable('%time', slang.t.settings.downloadSettings.variableTime),
      TemplateVariable(
        '%datetime',
        slang.t.settings.downloadSettings.variableDatetime,
      ),
    ];
  }

  /// 验证模板是否有效
  bool validateTemplate(String template) {
    if (template.trim().isEmpty) return false;

    // 检查是否包含非法字符（除了变量占位符）
    final withoutVariables = template.replaceAll(RegExp(r'%\w+'), '');
    if (withoutVariables.contains(RegExp(r'[<>:"/\\|?*\x00-\x1F]'))) {
      return false;
    }

    // 只拦真正的目录逃逸形状。分隔符上面已经拦掉了，剩下唯一危险的是整条
    // 模板只由点和空白组成（清洗后会退化成 "." / ".."）——中间的省略号
    // （"Ep.1 ... The End"）是合法标题的一部分，不能一并否掉。
    if (template.replaceAll(RegExp(r'[.\s]'), '').isEmpty) {
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
