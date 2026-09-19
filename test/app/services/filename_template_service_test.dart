import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/author_folder_cache_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/db/migrations/migration_v46_author_folder_cache.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('FilenameTemplateService path safety', () {
    late FilenameTemplateService service;

    setUp(() {
      service = FilenameTemplateService();
    });

    test(
      'rejects template literals that can escape the download directory',
      () {
        expect(service.validateTemplate('../%title'), isFalse);
        expect(service.validateTemplate(r'%title\%quality'), isFalse);
        // issue #126：`/` 已放开为段分隔符，整条模板不再整体拒绝。
        expect(service.validateTemplate('%title/%quality'), isTrue);
        expect(service.validateTemplate('%title_%quality'), isTrue);
      },
    );

    test('multi-segment value domain (issue #126)', () {
      // 1~4 段合法；超过 4 段拒绝（3 层文件夹段 + 1 层文件名段）。
      expect(service.validateTemplate('%authorcache/%title_%quality'), isTrue);
      expect(
        service.validateTemplate('%authorcache/%date/%title_%quality'),
        isTrue,
      );
      // 4 段 = 3 层文件夹段 + 1 层文件名段，正好是上限。
      expect(
        service.validateTemplate('%authorcache/%date/%title/%quality'),
        isTrue,
      );
      expect(service.validateTemplate('a/b/c/d'), isTrue);
      expect(service.validateTemplate('a/b/c/d/e'), isFalse);
      // 空段被拆段器剔除，等价于两段。
      expect(service.validateTemplate('%authorcache//%title'), isTrue);
      // 段内出现 `\` 仍然非法。
      expect(service.validateTemplate(r'a/b\c'), isFalse);
      // 段内全点/空白仍然拒绝（.. 逃逸形状）。
      expect(service.validateTemplate('../%title'), isFalse);
      expect(service.validateTemplate('%title/..'), isFalse);
      expect(service.validateTemplate('  . . '), isFalse);
    });

    test('sanitizes final template output to a single path segment', () {
      final sanitized = FilenameTemplateService.sanitizePathSegment(
        '../bad\\name/clip.mp4',
        fallback: 'video.mp4',
      );

      expect(sanitized, isNot(contains('..')));
      expect(sanitized, isNot(contains('/')));
      expect(sanitized, isNot(contains(r'\')));
      expect(sanitized, endsWith('.mp4'));
    });

    test('keeps spaces and inner dots (issue #93)', () {
      // i 站同款模板：空格、连字符、方括号都必须原样留下。
      expect(
        FilenameTemplateService.sanitizePathSegment(
          'Iwara - My Cool Video [abc123] [Source].mp4',
        ),
        'Iwara - My Cool Video [abc123] [Source].mp4',
      );
      // 省略号是标题的一部分，不能被吃掉。
      expect(
        FilenameTemplateService.sanitizePathSegment('Ep.1 ... The End.mp4'),
        'Ep.1 ... The End.mp4',
      );
      // 用户模板里刻意写的双下划线要保留。
      expect(FilenameTemplateService.sanitizePathSegment('a__b.mp4'), 'a__b.mp4');
    });

    test('trims edges that break Windows / hide files on Unix', () {
      // 结尾的点和空格会被 Windows 静默吃掉。
      expect(FilenameTemplateService.sanitizePathSegment('clip .'), 'clip');
      // 开头的点会变成 Unix 隐藏文件。
      expect(FilenameTemplateService.sanitizePathSegment('.hidden.mp4'), 'hidden.mp4');
      // 换行/制表折成普通空格。
      expect(
        FilenameTemplateService.sanitizePathSegment('a\n\tb.mp4'),
        'a b.mp4',
      );
      // 全是点/空白 → 落回兜底。
      expect(
        FilenameTemplateService.sanitizePathSegment('..', fallback: 'video.mp4'),
        'video.mp4',
      );
    });

    test('strips zero-width characters that \\s does not cover', () {
      // i 站标题里 ZWSP/ZWJ 很常见；漏掉它们会留下一个「看不见也打不出来」的文件名。
      expect(
        FilenameTemplateService.sanitizePathSegment(
          '\u200B..',
          fallback: 'video.mp4',
        ),
        'video.mp4',
      );
      expect(
        FilenameTemplateService.sanitizePathSegment('a\u200Bb.mp4'),
        'a b.mp4',
      );
      expect(service.validateTemplate('\u200B \u200C'), isFalse);
    });

    test('truncates on UTF-8 bytes, not characters, and keeps the extension', () {
      // 150 个日文假名 = 450 字节，ext4/APFS 的上限是 255 字节。
      final longJapanese = '${'ミク' * 100}.mp4';
      final result = FilenameTemplateService.sanitizePathSegment(longJapanese);

      expect(result, endsWith('.mp4'));
      expect(utf8.encode(result).length, lessThanOrEqualTo(200));
    });

    test('never splits a surrogate pair when truncating', () {
      final emojiName = '${'🎵' * 200}.mp4';
      final result = FilenameTemplateService.sanitizePathSegment(emojiName);

      // 半个代理项对会产出非法 UTF-16，落盘同样失败。
      expect(() => utf8.encode(result), returnsNormally);
      expect(result.runes.any((r) => r >= 0xD800 && r <= 0xDFFF), isFalse);
    });

    test('accepts templates with ellipsis but still rejects separators', () {
      expect(service.validateTemplate('Iwara - %title [%id] [%quality]'), isTrue);
      expect(service.validateTemplate('%title ... %id'), isTrue);
      expect(service.validateTemplate('../%title'), isFalse);
      expect(service.validateTemplate('  . . '), isFalse);
    });

    test(
      'renames Windows reserved basenames even when an extension is present',
      () {
        expect(
          FilenameTemplateService.sanitizePathSegment('CON.mp4'),
          'CON_file.mp4',
        );
        expect(
          FilenameTemplateService.sanitizePathSegment('nul.jpg'),
          'nul_file.jpg',
        );
      },
    );
  });

  group('FilenameTemplateService multi-segment paths (issue #126)', () {
    late FilenameTemplateService service;

    final video = Video(
      id: 'abc123',
      title: '夏夜花火',
      user: User(id: 'u1', name: '花火師さん', username: 'hanabi_master'),
    );
    final gallery = ImageModel(
      id: 'gal001',
      title: '夏夜花火画集',
      user: User(id: 'u1', name: '花火師さん', username: 'hanabi_master'),
    );

    setUp(() {
      service = FilenameTemplateService();
    });

    test('single-segment template keeps legacy byte-identical output', () {
      // 存量平铺值：多段入口必须等价于旧的 generateVideoFilename。
      expect(
        service.generateVideoPathSegments(
          template: '%title_%quality',
          video: video,
          quality: '1080',
        ),
        [service.generateVideoFilename(template: '%title_%quality', video: video, quality: '1080')],
      );
    });

    test('multi-segment video template splits folder and file segments', () {
      // 无 GetX 缓存服务 → %authorcache 退化为实时显示名（清洗后）。
      final segments = service.generateVideoPathSegments(
        template: '%authorcache/%title_%quality',
        video: video,
        quality: '1080',
      );
      expect(segments, ['花火師さん', '夏夜花火_1080.mp4']);
    });

    test('gallery template is all folder segments', () {
      final segments = service.generateGalleryPathSegments(
        template: '%authorcache/%title_%id',
        gallery: gallery,
      );
      expect(segments, ['花火師さん', '夏夜花火画集_gal001']);
    });

    test('folder segments sanitize per-segment with unknown fallback', () {
      // %id 在视频里是内容 ID（不是作者 ID）。
      final segments = service.generateVideoPathSegments(
        template: '%authorcache/%id/%title',
        video: video,
        quality: '1080',
      );
      expect(segments, ['花火師さん', 'abc123', '夏夜花火.mp4']);

      // 编辑器会拦下全点段（.. 逃逸形状），运行时是最后一道闸：
      // 退化段清洗为空 → 回退 unknown 文件夹，绝不拼出逃逸路径。
      final defensive = service.generateVideoPathSegments(
        template: '../%title',
        video: video,
        quality: '1080',
      );
      expect(defensive, ['unknown', '夏夜花火.mp4']);
    });

    test('%authorcache misses cache and returns unknown without author data', () {
      final noAuthor = Video(id: 'abc123', title: '夏夜花火');
      final segments = service.generateVideoPathSegments(
        template: '%authorcache/%title',
        video: noAuthor,
        quality: '1080',
      );
      expect(segments, ['unknown', '夏夜花火.mp4']);
    });

    test('%datetime is not corrupted by %date (longest-token-first)', () {
      final segments = service.generateVideoPathSegments(
        template: '%date/%datetime_%title',
        video: video,
        quality: '1080',
      );
      final dateSegment = segments.first;
      final fileSegment = segments.last;
      // 形如 2026-09-19 / 2026-09-19_23-30-05_夏夜花火.mp4
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateSegment), isTrue);
      expect(
        RegExp(r'^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_夏夜花火\.mp4$')
            .hasMatch(fileSegment),
        isTrue,
        reason: '实际输出: $fileSegment',
      );
    });
  });

  group('FilenameTemplateService %authorcache cache (issue #126)', () {
    late FilenameTemplateService service;
    late Database db;
    final video = Video(
      id: 'abc123',
      title: '夏夜花火',
      user: User(id: 'u1', name: '花火師さん', username: 'hanabi_master'),
    );

    setUp(() {
      service = FilenameTemplateService();
      db = sqlite3.openInMemory();
      MigrationV46AuthorFolderCache().up(db);
      Get.put(AuthorFolderCacheService(db));
    });

    tearDown(() {
      Get.delete<AuthorFolderCacheService>();
      db.close();
    });

    test('first download records first-seen name, rename does not drift', () {
      expect(
        service.generateVideoPathSegments(
          template: '%authorcache/%title',
          video: video,
          quality: '1080',
        ),
        ['花火師さん', '夏夜花火.mp4'],
      );
      expect(AuthorFolderCacheService.to.folderNameFor('u1'), '花火師さん');

      // 作者改名：缓存命中，文件夹名不变。
      final renamed = Video(
        id: 'abc123',
        title: '夏夜花火',
        user: User(id: 'u1', name: '新昵称', username: 'hanabi_master'),
      );
      expect(
        service.generateVideoPathSegments(
          template: '%authorcache/%title',
          video: renamed,
          quality: '1080',
        ),
        ['花火師さん', '夏夜花火.mp4'],
      );
    });

    test('preview (writeAuthorCache: false) never writes the cache', () {
      expect(
        service.generateVideoPathSegments(
          template: '%authorcache/%title',
          video: video,
          quality: '1080',
          writeAuthorCache: false,
        ),
        ['花火師さん', '夏夜花火.mp4'],
      );
      expect(AuthorFolderCacheService.to.folderNameFor('u1'), isNull);
    });

    test('unknown fallback is never written as first-seen name', () {
      // 作者 ID 在但显示名清洗后为空（全零宽字符）→ unknown 且不入缓存。
      final invisible = Video(
        id: 'u2',
        title: 't',
        user: User(id: 'u2', name: '\u200B\u200C', username: 'ghost'),
      );
      expect(
        service.generateVideoPathSegments(
          template: '%authorcache/%title',
          video: invisible,
          quality: '1080',
        ),
        ['unknown', 't.mp4'],
      );
      expect(AuthorFolderCacheService.to.folderNameFor('u2'), isNull);
    });
  });
}
