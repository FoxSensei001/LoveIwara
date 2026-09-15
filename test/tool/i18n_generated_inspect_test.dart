// 运行时探针：打印「生成代码里到底是什么」。用来回答「YAML 里的转义写法，
// 到运行时还剩什么」——这决定了正则示例、换行这类内容在界面上的真实表现。
//
// 默认跳过；要跑就设 I18N_INSPECT=1：
//   I18N_INSPECT=1 flutter test test/tool/i18n_generated_inspect_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/i18n/strings.g.dart';

void main() {
  if (Platform.environment['I18N_INSPECT'] != '1') {
    test('运行时转义探针（未设 I18N_INSPECT=1，跳过）', () {}, skip: '按需运行');
    return;
  }

  test('生成代码里的转义实况', () async {
    await LocaleSettings.instance.loadAllLocales();
    const newline = '\n';
    const backslash = '\\';
    for (final locale in AppLocale.values) {
      final t = locale.translations;
      final list = t.markdown.listSyntax;
      final re = t.settings.blockSettings.regexEx4Pattern;
      final re2 = t.settings.blockSettings.regexEx2Pattern;
      final re5 = t.settings.blockSettings.regexEx5Pattern;
      final re5d = t.settings.blockSettings.regexEx5Desc;
      // ignore: avoid_print
      print('${locale.languageTag}: listSyntax 真换行=${newline.allMatches(list).length} '
          '反斜杠=${backslash.allMatches(list).length}');
      // ignore: avoid_print
      print('${locale.languageTag}: regexEx2Pattern="$re2" regexEx4Pattern="$re" '
          'regexEx5Pattern="$re5" regexEx5Desc="$re5d"');
    }
  });
}
