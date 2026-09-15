// 回退链守卫：slang 配了 `fallback_strategy: base_locale`（见 `slang.yaml`），
// 某门语言漏译一条时，运行时取到的是**基准语言 en 的值**，而不是空白、原始
// 键名或异常。
//
// 这里锁两件事（都是回退链生效的**结构前提**，任一被破坏回退就静默失效）：
//   1. `slang.yaml` 里 `fallback_strategy: base_locale` 还在；
//   2. 每门语言生成的 `TranslationsXxx` 都 `extends Translations`（基准类），
//      漏译的 key 因此由基类兜底，而不是编译期报错或运行期空值。
//
// 端到端行为已在本任务里实测过一次（临时删掉 de 的 `settings.language` 后重新
// 生成，`AppLocale.de.translations.settings.language` 返回 "Language" 而不是
// "Sprache"，其余词条不受影响；命令与输出记录在
// `docs/i18n-verification-report.md`）。删文件属于高风险操作，探针没有把它写成
// 自动化用例，避免 CI 去改仓库里的 yaml。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slang.yaml 保持 fallback_strategy: base_locale', () {
    final config = File('slang.yaml').readAsStringSync();
    expect(
      config,
      contains('fallback_strategy: base_locale'),
      reason: '漏译回退到 en 全靠这一行，删了会让漏译变成运行期空值',
    );
  });

  test('每门语言生成的 TranslationsXxx 都继承基准类', () {
    final files = Directory('lib/i18n')
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.startsWith('strings_'))
        .where((f) => f.uri.pathSegments.last.endsWith('.g.dart'))
        .toList();
    expect(files.length, 12, reason: '应有 12 门语言的生成文件');
    for (final file in files) {
      final source = file.readAsStringSync();
      // `strings_en.g.dart` 里定义的是**基准类**本身（`class Translations`），
      // 其余语言定义的是继承它的子类。
      final decl = RegExp(r'^class (Translations\w*)', multiLine: true)
          .firstMatch(source)
          ?.group(1);
      expect(decl, isNotNull, reason: '${file.path} 里找不到译文类声明');
      if (file.path.endsWith('strings_en.g.dart')) {
        expect(decl, 'Translations');
      } else {
        expect(
          source.contains('class $decl extends Translations'),
          isTrue,
          reason: '$decl 没有继承基准类，漏译将无法回退',
        );
      }
    }
  });
}
