import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/app_version.dart';

void main() {
  bool newer(String current, String latest) =>
      AppVersion.isNewer(current: current, latest: latest);

  group('AppVersion.parse', () {
    test('完整形态', () {
      final v = AppVersion.parse('1.2.3-beta.4+56');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.preRelease, 'beta.4');
      expect(v.build, 56);
    });

    test('段数不足补 0，缺 build 视为 0', () {
      final v = AppVersion.parse('2');
      expect([v.major, v.minor, v.patch], [2, 0, 0]);
      expect(v.build, 0);
      expect(v.preRelease, isNull);
    });

    test('解不出的内容退化成 0 而不是抛异常（远端 yaml 是手写的）', () {
      final v = AppVersion.parse('  x.y.z+nope  ');
      expect([v.major, v.minor, v.patch], [0, 0, 0]);
      expect(v.build, 0);
    });
  });

  group('⛔ 前导 v（git tag 风格）', () {
    test('v1.0.0 不许被解析成 0.0.0', () {
      final v = AppVersion.parse('v1.0.0');
      expect([v.major, v.minor, v.patch], [1, 0, 0]);
      // 不剥 v 的话 int.tryParse('v1') 兜底成 0 → 0.0.0 比谁都旧，
      // **全量用户看不到这次大版本更新，且全程静默**。
      expect(newer('0.5.1+3', 'v1.0.0'), isTrue);
      expect(newer('0.5.1+3', 'V1.0.0'), isTrue);
    });

    test('只剥「v + 数字」，不误伤别的开头', () {
      // 'version-next' 这种不是版本号，不该被剥成 'ersion-next'
      final v = AppVersion.parse('vnext');
      expect([v.major, v.minor, v.patch], [0, 0, 0]);
    });
  });

  group('普通的三段比较', () {
    test('大的更新', () {
      expect(newer('0.5.1', '0.5.2'), isTrue);
      expect(newer('0.5.1', '0.6.0'), isTrue);
      expect(newer('0.5.1', '1.0.0'), isTrue);
    });

    test('相等或更旧都不算有更新', () {
      expect(newer('0.5.1', '0.5.1'), isFalse);
      expect(newer('0.5.2', '0.5.1'), isFalse);
      expect(newer('1.0.0', '0.9.9'), isFalse);
    });

    test('段数不齐也能比', () {
      expect(newer('0.5', '0.5.1'), isTrue);
      expect(newer('0.5.0', '0.5'), isFalse);
    });
  });

  group('⭐ build 号：同 semver 的热修重打包必须能被认出来', () {
    test('build 号大的更新（旧实现在这里永远返回 false）', () {
      expect(newer('0.5.1+3', '0.5.1+4'), isTrue);
    });

    test('build 号小的不算有更新', () {
      expect(newer('0.5.1+4', '0.5.1+3'), isFalse);
      expect(newer('0.5.1+3', '0.5.1+3'), isFalse);
    });

    test('缺省 build 视为 0：远端只写 semver 时，本机带 build 的不会被判成旧', () {
      // 这是现状（update_logs.yaml 写 "0.5.1"，本机是 0.5.1+3）：不该提示更新。
      expect(newer('0.5.1+3', '0.5.1'), isFalse);
      // 反过来：热修必须把 build 号一起发布，否则装着 +3 的人看不到 +4。
      expect(newer('0.5.1', '0.5.1+1'), isTrue);
    });

    test('semver 段优先于 build 号', () {
      expect(newer('0.5.1+99', '0.5.2+1'), isTrue);
      expect(newer('0.5.2+1', '0.5.1+99'), isFalse);
    });
  });

  group('预发布后缀（旧实现把它们当成相等）', () {
    test('带后缀的比同号正式版旧', () {
      expect(newer('0.6.0-beta', '0.6.0'), isTrue);
      expect(newer('0.6.0', '0.6.0-beta'), isFalse);
    });

    test('后缀之间按 semver 规则比', () {
      expect(newer('1.0.0-alpha', '1.0.0-beta'), isTrue);
      expect(newer('1.0.0-alpha.1', '1.0.0-alpha.2'), isTrue);
      expect(newer('1.0.0-alpha.2', '1.0.0-alpha.1'), isFalse);
      // 数字标识符低于字母标识符
      expect(newer('1.0.0-1', '1.0.0-alpha'), isTrue);
      // 前缀相同时标识符多的更大
      expect(newer('1.0.0-alpha', '1.0.0-alpha.1'), isTrue);
    });

    test('正式版比任何预发布都新', () {
      expect(newer('1.0.0-rc.9', '1.0.0'), isTrue);
    });
  });

  group('compareTo 的次序自洽', () {
    test('排序结果符合预期', () {
      final list = [
        '1.0.0',
        '0.9.9',
        '1.0.0-alpha',
        '1.0.0+2',
        '1.0.0-beta',
        '0.9.10',
      ].map(AppVersion.parse).toList()..sort();
      expect(list.map((v) => v.toString()).toList(), [
        '0.9.9',
        '0.9.10',
        '1.0.0-alpha',
        '1.0.0-beta',
        '1.0.0',
        '1.0.0+2',
      ]);
    });
  });
}
