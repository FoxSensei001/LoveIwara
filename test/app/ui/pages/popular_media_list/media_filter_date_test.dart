import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_filter_drawer.dart';

/// 筛选抽屉里「年 / 月」两只 Select 与服务端日期串之间的互转契约。
///
/// 2026-08-26 年月从两排选择胶囊（18 + 13 个）换成两只 Select 时抽出来的：
/// 服务端只认 `''` / `'YYYY'` / `'YYYY-MM'` 三种形态，「只有月份没有年份」
/// 是拼不出来的东西，这条不变量原先散在几个 setState 回调里。
void main() {
  group('MediaFilterDate.parse', () {
    test('空串 = 不限日期', () {
      expect(MediaFilterDate.parse(''), ('', ''));
    });

    test('只有年份', () {
      expect(MediaFilterDate.parse('2024'), ('2024', ''));
    });

    test('年 + 月', () {
      expect(MediaFilterDate.parse('2024-7'), ('2024', '7'));
    });

    test('年份为空时月份一起丢掉（拼不出「只有月份」的查询）', () {
      expect(MediaFilterDate.parse('-7'), ('', ''));
    });
  });

  group('MediaFilterDate.compose', () {
    test('没有年份就没有日期，月份单独存在没有意义', () {
      expect(MediaFilterDate.compose(year: '', month: '7'), '');
      expect(MediaFilterDate.compose(year: '', month: ''), '');
    });

    test('只选年份', () {
      expect(MediaFilterDate.compose(year: '2024', month: ''), '2024');
    });

    test('年 + 月', () {
      expect(MediaFilterDate.compose(year: '2024', month: '12'), '2024-12');
    });
  });

  test('parse / compose 往返不丢信息', () {
    for (final date in ['', '2010', '2024-1', '2024-12']) {
      final (year, month) = MediaFilterDate.parse(date);
      expect(
        MediaFilterDate.compose(year: year, month: month),
        date,
        reason: '「$date」拆开再拼回去应该还是它自己',
      );
    }
  });
}
