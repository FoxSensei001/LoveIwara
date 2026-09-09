import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';

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
        expect(service.validateTemplate('%title/%quality'), isFalse);
        expect(service.validateTemplate('%title_%quality'), isTrue);
      },
    );

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
}
