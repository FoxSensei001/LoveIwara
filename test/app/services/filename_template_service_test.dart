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
