import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/path_template_editor_page.dart';

void main() {
  group('PathTemplateEditorPage.capDraftSegments（载入超限存量值时并回末行）', () {
    test('不超限原样返回', () {
      expect(
        PathTemplateEditorPage.capDraftSegments(
          ['%authorcache', '%title_%quality'],
          4,
        ),
        ['%authorcache', '%title_%quality'],
      );
      expect(
        PathTemplateEditorPage.capDraftSegments(['a', 'b', 'c', 'd'], 4),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('超限并入末行：一个字不丢，行内保留 /', () {
      expect(
        PathTemplateEditorPage.capDraftSegments(['a', 'b', 'c', 'd', 'e'], 4),
        ['a', 'b', 'c', 'd/e'],
      );
      // 超得越多，剩余全部并进末行。
      expect(
        PathTemplateEditorPage.capDraftSegments(
          ['a', 'b', 'c', 'd', 'e', 'f'],
          4,
        ),
        ['a', 'b', 'c', 'd/e/f'],
      );
      // 图库 Tab 行数上限 2。
      expect(
        PathTemplateEditorPage.capDraftSegments(['x', 'y', 'z'], 2),
        ['x', 'y/z'],
      );
    });

    test('并回末行后 join 再拆段数不衰减——保存会被段数上限准确拦下', () {
      final rows = PathTemplateEditorPage.capDraftSegments(
        ['a', 'b', 'c', 'd', 'e'],
        4,
      );
      final segmentCount = FilenameTemplateService.splitTemplateSegments(
        rows.join('/'),
      ).length;
      expect(segmentCount, 5);
      expect(segmentCount, greaterThan(FilenameTemplateService.maxTemplateSegments));
    });
  });
}
