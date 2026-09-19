import 'dart:convert';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/author_folder_cache_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path;

/// 文件命名模板服务
/// 支持的变量：
/// %title - 标题
/// %authorcache - 作者首见名（按作者 ID 缓存第一次见到的显示名，改名不漂移）
/// %author - 作者名称（实时跟随改名）
/// %username - 作者用户名
/// %quality - 视频质量
/// %filename - 原始文件名
/// %id - 内容ID
/// %date - 当前日期 (YYYY-MM-DD)
/// %time - 当前时间 (HH-MM-SS)
/// %datetime - 当前日期时间 (YYYY-MM-DD_HH-MM-SS)
///
/// 模板值域（issue #126 子文件夹归档）：允许 `/` 分隔的 1~4 段模板串——
/// 最多 3 层文件夹段 + 1 层文件名段（图库全部为文件夹段）。旧的单段模板
/// 天然合法，运行时逐段渲染、逐段清洗后经 safeJoinUnderBase 拼接。
class FilenameTemplateService extends GetxService {
  static FilenameTemplateService get to => Get.find();

  static const int _maxPathSegmentLength = 150;

  /// 模板最多允许的段数：3 层文件夹段 + 1 层文件名段。
  /// 真约束是 200 字符的相对路径预算（见 07 边界表），层数上限只是编辑器
  /// 的护栏；运行时对超出的段不做截断，照常渲染。
  static const int maxTemplateSegments = 4;

  /// 把模板拆成段：`/` 分隔、逐段 trim、剔除空段。
  static List<String> splitTemplateSegments(String template) =>
      template
          .split('/')
          .map((segment) => segment.trim())
          .where((segment) => segment.isNotEmpty)
          .toList();

  /// 为视频生成文件名
  String generateVideoFilename({
    required String template,
    required Video video,
    required String quality,
    String? originalFilename,
    bool writeAuthorCache = true,
  }) {
    try {
      String filename = _replaceDateTimeVariables(template);
      filename = _replaceVideoVariables(
        filename,
        video: video,
        quality: quality,
        originalFilename: originalFilename,
        writeAuthorCache: writeAuthorCache,
      );

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
    bool writeAuthorCache = true,
  }) {
    try {
      String foldername = _replaceDateTimeVariables(template);
      foldername = _replaceGalleryVariables(
        foldername,
        gallery: gallery,
        writeAuthorCache: writeAuthorCache,
      );

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
    String? authorId,
    required String? id,
    String? originalFilename,
    bool writeAuthorCache = true,
  }) {
    try {
      String filename = _replaceDateTimeVariables(template);
      filename = _replaceImageVariables(
        filename,
        title: title,
        authorName: authorName,
        authorUsername: authorUsername,
        authorId: authorId,
        id: id,
        originalFilename: originalFilename,
        writeAuthorCache: writeAuthorCache,
      );

      // 处理原始扩展名：模板里没有点时补上原文件的扩展名
      final extension = originalFilename != null
          ? path.extension(originalFilename)
          : '';
      if (originalFilename != null &&
          !filename.contains('.') &&
          extension.isNotEmpty) {
        filename += extension;
      }

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

  /// 为视频生成多段落盘路径（相对下载根目录）。
  ///
  /// 模板只有一段（存量平铺值）时返回单元素列表，内容与
  /// [generateVideoFilename] 完全一致——存量用户行为逐字节不变。
  /// 多段时前面的段是文件夹段：逐段渲染清洗，清洗后为空的段回退 `unknown`
  /// （语义诚实的「作者未知桶」，见 07 边界表），最后一段仍走
  /// [generateVideoFilename]（保留 .mp4 补全与整段兜底）。
  List<String> generateVideoPathSegments({
    required String template,
    required Video video,
    required String quality,
    String? originalFilename,
    bool writeAuthorCache = true,
  }) {
    final segments = splitTemplateSegments(template);
    if (segments.length <= 1) {
      return [
        generateVideoFilename(
          template: template,
          video: video,
          quality: quality,
          originalFilename: originalFilename,
          writeAuthorCache: writeAuthorCache,
        ),
      ];
    }
    final folderSegments = segments
        .sublist(0, segments.length - 1)
        .map(
          (segment) => sanitizePathSegment(
            _replaceVideoVariables(
              _replaceDateTimeVariables(segment),
              video: video,
              quality: quality,
              originalFilename: originalFilename,
              writeAuthorCache: writeAuthorCache,
            ),
            fallback: 'unknown',
          ),
        )
        .toList();
    final filename = generateVideoFilename(
      template: segments.last,
      video: video,
      quality: quality,
      originalFilename: originalFilename,
      writeAuthorCache: writeAuthorCache,
    );
    return [...folderSegments, filename];
  }

  /// 为图库生成多段落盘路径（相对下载根目录）。
  ///
  /// 图库模板全部为文件夹段（内部图片按「图片ID.扩展名」命名，不走模板）。
  /// 最后一段仍走 [generateGalleryFoldername]，保留它面向存量单段值的兜底。
  List<String> generateGalleryPathSegments({
    required String template,
    required ImageModel gallery,
    bool writeAuthorCache = true,
  }) {
    final segments = splitTemplateSegments(template);
    if (segments.length <= 1) {
      return [
        generateGalleryFoldername(
          template: template,
          gallery: gallery,
          writeAuthorCache: writeAuthorCache,
        ),
      ];
    }
    final folderSegments = segments
        .sublist(0, segments.length - 1)
        .map(
          (segment) => sanitizePathSegment(
            _replaceGalleryVariables(
              _replaceDateTimeVariables(segment),
              gallery: gallery,
              writeAuthorCache: writeAuthorCache,
            ),
            fallback: 'unknown',
          ),
        )
        .toList();
    final lastSegment = generateGalleryFoldername(
      template: segments.last,
      gallery: gallery,
      writeAuthorCache: writeAuthorCache,
    );
    return [...folderSegments, lastSegment];
  }

  /// 为单张图片生成多段落盘路径（相对下载根目录）。
  ///
  /// 新式模板（含 `/`，如 `%authorcache/%title/%filename`）的标题层写在模板
  /// 里；存量平铺值（`%title_%filename`）不经过这里——路径服务会保留历史上
  /// 硬编码的标题子文件夹层，保证行为逐字节不变。
  List<String> generateImagePathSegments({
    required String template,
    required String title,
    required String? authorName,
    required String? authorUsername,
    String? authorId,
    required String? id,
    String? originalFilename,
    bool writeAuthorCache = true,
  }) {
    final segments = splitTemplateSegments(template);
    if (segments.length <= 1) {
      return [
        generateImageFilename(
          template: template,
          title: title,
          authorName: authorName,
          authorUsername: authorUsername,
          authorId: authorId,
          id: id,
          originalFilename: originalFilename,
          writeAuthorCache: writeAuthorCache,
        ),
      ];
    }
    final folderSegments = segments
        .sublist(0, segments.length - 1)
        .map(
          (segment) => sanitizePathSegment(
            _replaceImageVariables(
              _replaceDateTimeVariables(segment),
              title: title,
              authorName: authorName,
              authorUsername: authorUsername,
              authorId: authorId,
              id: id,
              originalFilename: originalFilename,
              writeAuthorCache: writeAuthorCache,
            ),
            fallback: 'unknown',
          ),
        )
        .toList();
    final filename = generateImageFilename(
      template: segments.last,
      title: title,
      authorName: authorName,
      authorUsername: authorUsername,
      authorId: authorId,
      id: id,
      originalFilename: originalFilename,
      writeAuthorCache: writeAuthorCache,
    );
    return [...folderSegments, filename];
  }

  /// 视频内容的变量替换（不含日期时间——那一步必须先做，见
  /// [_replaceDateTimeVariables] 的顺序说明）。
  String _replaceVideoVariables(
    String input, {
    required Video video,
    required String quality,
    String? originalFilename,
    required bool writeAuthorCache,
  }) {
    var result = input;
    result = result.replaceAll('%title', _sanitize(video.title ?? 'video'));
    result = result.replaceAll(
      '%authorcache',
      _resolveAuthorCache(video.user?.id, video.user?.name, writeAuthorCache),
    );
    result = result.replaceAll(
      '%author',
      _sanitize(video.user?.name ?? 'unknown'),
    );
    result = result.replaceAll(
      '%username',
      _sanitize(video.user?.username ?? 'unknown'),
    );
    result = result.replaceAll('%quality', _sanitize(quality));
    result = result.replaceAll('%id', _sanitize(video.id));
    if (originalFilename != null) {
      result = result.replaceAll(
        '%filename',
        _sanitize(path.basenameWithoutExtension(originalFilename)),
      );
    } else {
      result = result.replaceAll('%filename', 'video');
    }
    return result;
  }

  /// 图库内容的变量替换
  String _replaceGalleryVariables(
    String input, {
    required ImageModel gallery,
    required bool writeAuthorCache,
  }) {
    var result = input;
    result = result.replaceAll('%title', _sanitize(gallery.title));
    result = result.replaceAll(
      '%authorcache',
      _resolveAuthorCache(gallery.user?.id, gallery.user?.name, writeAuthorCache),
    );
    result = result.replaceAll(
      '%author',
      _sanitize(gallery.user?.name ?? 'unknown'),
    );
    result = result.replaceAll(
      '%username',
      _sanitize(gallery.user?.username ?? 'unknown'),
    );
    result = result.replaceAll('%id', _sanitize(gallery.id));

    // 图库特有的变量
    result = result.replaceAll('%count', gallery.files.length.toString());
    return result;
  }

  /// 单图内容的变量替换
  String _replaceImageVariables(
    String input, {
    required String title,
    required String? authorName,
    required String? authorUsername,
    required String? authorId,
    required String? id,
    String? originalFilename,
    required bool writeAuthorCache,
  }) {
    var result = input;
    result = result.replaceAll(
      '%title',
      _sanitize(title.isNotEmpty ? title : 'image'),
    );
    result = result.replaceAll(
      '%authorcache',
      _resolveAuthorCache(authorId, authorName, writeAuthorCache),
    );
    result = result.replaceAll('%author', _sanitize(authorName ?? 'unknown'));
    result = result.replaceAll(
      '%username',
      _sanitize(authorUsername ?? 'unknown'),
    );
    result = result.replaceAll('%id', _sanitize(id ?? 'unknown'));
    if (originalFilename != null) {
      result = result.replaceAll(
        '%filename',
        _sanitize(path.basenameWithoutExtension(originalFilename)),
      );
    } else {
      result = result.replaceAll('%filename', 'image');
    }
    return result;
  }

  /// 解析 `%authorcache`：按作者 ID 查首见名缓存。
  ///
  /// - 命中 → 直接用缓存的首见名（作者改名不影响文件夹名）；
  /// - 未命中 → 用当前显示名（清洗后）写缓存并返回；
  /// - 作者 ID 或显示名缺失 → `unknown`，且**不写缓存**——回退值不是「首见」，
  ///   写进去会把 unknown 钉死成永久文件夹名（审计规格①）；
  /// - 显示名清洗后为空（全是非法字符/零宽字符）→ 同上，视为缺失。
  String _resolveAuthorCache(String? authorId, String? authorName, bool writeCache) {
    final displayName = authorName?.trim() ?? '';
    if (authorId == null || authorId.isEmpty || displayName.isEmpty) {
      return 'unknown';
    }
    if (!Get.isRegistered<AuthorFolderCacheService>()) {
      // 服务还没起来（理论上只发生在启动竞态）：退化为实时显示名，不缓存。
      return _sanitize(displayName);
    }
    final cache = AuthorFolderCacheService.to;
    final cached = cache.folderNameFor(authorId);
    if (cached != null) {
      return cached;
    }
    final cleaned = _sanitize(displayName);
    if (cleaned.isEmpty || cleaned == 'unknown') {
      return 'unknown';
    }
    if (writeCache) {
      cache.recordFirstSeen(authorId, cleaned);
    }
    return cleaned;
  }

  /// 替换日期时间变量。
  ///
  /// ⛔ 顺序敏感：`%datetime` 以 `%date` 为前缀，必须**先长后短**地替换，否则
  /// `%datetime` 会被 `%date` 啃成 `2026-09-19time`。同理该函数要在内容变量
  /// **之前**跑：变量值本身可能含 % 字符（清洗表不滤 %），先替换日期时间可以
  /// 保证模板 token 只在模板字面量上匹配，插入的值永远不会被二次替换（丢字）。
  String _replaceDateTimeVariables(String input) {
    final now = DateTime.now();
    return input
        .replaceAll('%datetime', _formatDateTime(now))
        .replaceAll('%date', _formatDate(now))
        .replaceAll('%time', _formatTime(now));
  }

  static String _formatDate(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  static String _formatTime(DateTime now) =>
      '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';

  static String _formatDateTime(DateTime now) =>
      '${_formatDate(now)}_${_formatTime(now)}';

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
          // \s 不含零宽字符，而 i 站标题里 ZWSP/ZWJ 很常见：漏掉它们的话
          // "\u200B.." 会被清成只剩一个零宽字符的文件名——非空，兜底不触发，
          // 用户看不见也打不出来。
          .replaceAll(RegExp(r'[\s\u200B-\u200D\uFEFF]+'), ' ')
          // 再处理各平台文件系统真正拒绝的那一批字符 + 剩余控制字符。
          // ⛔ 空格不在其中：Windows / APFS / ext4 / SAF 都允许名字中间有空格，
          // 把它换成下划线会把用户模板 "Iwara - %title [%id] [%quality]" 拧成
          // "Iwara_-_..."（issue #93）。同理不再压缩连续下划线和连续点号，
          // 那会把 "Ep.1 ... The End" 这种标题吃掉一段。
          .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F\x7F]'), '_');
      // 开头的点会变成 Unix 隐藏文件，也是 "." / ".." 逃逸的入口；
      // 结尾的点和空格会被 Windows 静默吃掉，导致「记录的路径」和
      // 「磁盘上的文件名」对不上。两头都清掉，中间一律保留。
      result = result.replaceAll(RegExp(r'^[.\s\u200B-\u200D\uFEFF]+'), '');
      result = result.replaceAll(RegExp(r'[.\s\u200B-\u200D\uFEFF]+$'), '');
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
        '%authorcache',
        slang.t.settings.downloadSettings.variableAuthorcache,
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

  /// 验证模板是否有效（值域：允许 `/` 分隔的 1~4 段）。
  ///
  /// 逐段校验，规则与单段时代等价（去掉已被分隔符吃掉的 `/`）：
  /// - 至少一段，至多 [maxTemplateSegments] 段；
  /// - 每段剥掉 `%\w+` 占位符后，字面量部分不得含 `<>:"\|?*`、控制字符与 DEL
  ///   （`/` 现在是分隔符，不再在段内出现；`\` 仍然非法）；
  /// - 段只由点/空白/零宽字符组成也拒绝——清洗后退化为 "." / ".." 或空段。
  ///   中间的省略号（"Ep.1 ... The End"）是合法标题的一部分，不受影响。
  ///
  /// 未知 token 不报错：渲染时原样保留（永不丢字）。
  bool validateTemplate(String template) {
    final segments = splitTemplateSegments(template);
    if (segments.isEmpty || segments.length > maxTemplateSegments) {
      return false;
    }
    for (final segment in segments) {
      final withoutVariables = segment.replaceAll(RegExp(r'%\w+'), '');
      if (withoutVariables.contains(RegExp(r'[<>:"\\|?*\x00-\x1F\x7F]'))) {
        return false;
      }
      if (segment.replaceAll(RegExp(r'[.\s\u200B-\u200D\uFEFF]'), '').isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// 预览用的样例变量值（设置页/编辑器「预览即文档」共用一套）。
  ///
  /// 用设计稿的固定示例（花火師さん › 夏夜花火_1080.mp4），日期时间取当前时刻；
  /// 调用方可整体覆盖个别键。
  static Map<String, String> sampleVariables({DateTime? now}) {
    final current = now ?? DateTime.now();
    return {
      'title': '夏夜花火',
      'author': '花火師さん',
      'authorcache': '花火師さん',
      'username': 'hanabi_master',
      'id': 'abc123',
      'quality': '1080',
      'filename': 'IMG_2049',
      'count': '12',
      'date': _formatDate(current),
      'time': _formatTime(current),
      'datetime': _formatDateTime(current),
    };
  }

  /// 用样例数据渲染单个段（不清洗）。
  ///
  /// 供设置页/编辑器预览：变量按 `%[a-z]+` 查样例表替换，表里没有的 token
  /// 原样保留（与运行时「未知 token 原样往返」一致）。
  static String renderSampleSegment(
    String segment,
    Map<String, String> variables,
  ) {
    return segment.replaceAllMapped(RegExp(r'%([a-z]+)'), (match) {
      final key = match.group(1);
      final value = key == null ? null : variables[key];
      return value ?? match.group(0)!;
    });
  }

  /// 用样例数据把整条模板渲染成清洗后的相对段（设置页预览行用）。
  ///
  /// 每段独立清洗（与运行时同一条 sanitizePathSegment 规则），空段剔除；
  /// 用户看到的和落盘的永远一致。
  static List<String> renderSamplePathSegments(
    String template, {
    Map<String, String>? overrides,
  }) {
    final variables = overrides ?? sampleVariables();
    return splitTemplateSegments(template)
        .map(
          (segment) =>
              sanitizePathSegment(renderSampleSegment(segment, variables), fallback: 'unknown'),
        )
        .toList();
  }
}

/// 模板变量类
class TemplateVariable {
  final String variable;
  final String description;

  const TemplateVariable(this.variable, this.description);
}
