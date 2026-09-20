import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/path_template_editor_page.dart';

void main() {
  group('PathTemplateEditorPage.foldSegmentsToLimit（载入超限存量值）', () {
    test('不超限原样返回', () {
      expect(
        PathTemplateEditorPage.foldSegmentsToLimit([
          '%authorcache',
          '%title_%quality',
        ], 4),
        ['%authorcache', '%title_%quality'],
      );
      expect(
        PathTemplateEditorPage.foldSegmentsToLimit(['a', 'b', 'c', 'd'], 4),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('超限时用 `_` 并进末段：一个字不丢，段内不留 `/`', () {
      expect(
        PathTemplateEditorPage.foldSegmentsToLimit([
          'a',
          'b',
          'c',
          'd',
          'e',
        ], 4),
        ['a', 'b', 'c', 'd_e'],
      );
      expect(
        PathTemplateEditorPage.foldSegmentsToLimit([
          'a',
          'b',
          'c',
          'd',
          'e',
          'f',
        ], 4),
        ['a', 'b', 'c', 'd_e_f'],
      );
      // 图库 Tab 行数上限 2。
      expect(
        PathTemplateEditorPage.foldSegmentsToLimit(['x', 'y', 'z'], 2),
        ['x', 'y_z'],
      );
    });

    test('空段不参与并入，也不留下孤立的 `_`', () {
      expect(
        PathTemplateEditorPage.foldSegmentsToLimit(['a', 'b', '  ', 'c'], 2),
        ['a', 'b_c'],
      );
    });

    group('核心不变量：折叠结果的段数恒等于行数上限', () {
      // 「一行 = 一段、段内永不含 `/`」是编辑器所有正确性的地基：
      // 行数 == 落盘层数，于是预览（按行画）与保存（按行 join）说的是同一件
      // 事。折叠若把 `/` 留在行内，图库这种上限 2 的 Tab 就会出现
      // 「预览一层、落盘两层」且保存校验放行的裂缝。
      for (final (segments, maxRows) in [
        (['a', 'b', 'c', 'd', 'e'], 4),
        (['x', 'y', 'z'], 2),
        (['a', 'b', 'c', 'd', 'e', 'f'], 2),
      ]) {
        test('$segments 折到 $maxRows 行', () {
          final rows = PathTemplateEditorPage.foldSegmentsToLimit(
            segments,
            maxRows,
          );
          expect(rows.length, maxRows);
          expect(rows.any((row) => row.contains('/')), isFalse);
          // join 回模板串再拆，段数不反弹 —— 保存写出去的就是看到的层数。
          expect(
            FilenameTemplateService.splitTemplateSegments(rows.join('/')).length,
            maxRows,
          );
          expect(maxRows, lessThanOrEqualTo(
            FilenameTemplateService.maxTemplateSegments,
          ));
        });
      }
    });
  });

  group('PathTemplateEditorPage.splitInput（一行里出现 `/` 时怎么拆）', () {
    test('⛔ 行尾一个 `/` 必须生出新的空行——重构前这一下按键会被静默吃掉', () {
      // 「在行尾敲 /」是人打路径最自然的动作，桌面端按回车走的也是这条路径
      // （回车 = 在光标处插一个 `/`）。旧实现先把空段全剔光，于是 "abc/"
      // 还是一行，两个功能一起哑掉。
      final out = PathTemplateEditorPage.splitInput(
        'abc/',
        caret: 4,
        room: 4,
      );
      expect(out.parts, ['abc', '']);
      expect(out.caretRow, 1, reason: '光标应落在新开的那一层上');
      expect(out.caretOffset, 0);
      expect(out.capped, isFalse);
    });

    test('在行中间敲 `/`：拆两段，光标跟到新行开头而不是被甩到末尾', () {
      // "ab|cd" 处敲斜杠 → 文本 "ab/cd"，光标在斜杠之后（offset 3）。
      final out = PathTemplateEditorPage.splitInput(
        'ab/cd',
        caret: 3,
        room: 4,
      );
      expect(out.parts, ['ab', 'cd']);
      expect(out.caretRow, 1);
      expect(out.caretOffset, 0);
    });

    test('开头与中间的空段剔除，尾部的保留', () {
      expect(
        PathTemplateEditorPage.splitInput('/a//b', caret: -1, room: 4).parts,
        ['a', 'b'],
      );
      expect(
        PathTemplateEditorPage.splitInput('a//', caret: -1, room: 4).parts,
        ['a', ''],
      );
      // 整行只有一个分隔符：留一个空段，让红描边说「这里还没写完」。
      expect(
        PathTemplateEditorPage.splitInput('/', caret: -1, room: 4).parts,
        [''],
      );
    });

    test('层数到顶：多出来的用 `_` 并进末段并示警，段内绝不留 `/`', () {
      final out = PathTemplateEditorPage.splitInput(
        'a/b/c',
        caret: -1,
        room: 1,
      );
      expect(out.parts, ['a_b_c']);
      expect(out.capped, isTrue);
      expect(out.parts.any((part) => part.contains('/')), isFalse);

      // 到顶时行尾的 `/` 不再生出新行，但要示警而不是静默无反应。
      final atCap = PathTemplateEditorPage.splitInput(
        'abc/',
        caret: 4,
        room: 1,
      );
      expect(atCap.parts, ['abc']);
      expect(atCap.capped, isTrue);
    });

    test('逐段 trim，光标偏移扣掉被 trim 掉的前导空白', () {
      final out = PathTemplateEditorPage.splitInput(
        'a/  bc',
        caret: 6, // 落在 "bc" 之后
        room: 4,
      );
      expect(out.parts, ['a', 'bc']);
      expect(out.caretRow, 1);
      expect(out.caretOffset, 2);
    });

    test('产出的段永远可以安全 join 回模板串', () {
      for (final input in ['a/b', 'a//b/', '/x/y/z', 'a/', '/']) {
        final out = PathTemplateEditorPage.splitInput(
          input,
          caret: -1,
          room: 4,
        );
        expect(out.parts, isNotEmpty);
        expect(out.parts.any((part) => part.contains('/')), isFalse);
        expect(out.caretRow, inInclusiveRange(0, out.parts.length - 1));
        expect(
          out.caretOffset,
          inInclusiveRange(0, out.parts[out.caretRow].length),
        );
      }
    });
  });
}
