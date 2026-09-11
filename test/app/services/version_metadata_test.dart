import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:yaml/yaml.dart';

/// 版本元数据的一致性闸门。
///
/// # ⛔ 为什么会有这个文件
///
/// 版本号在这个仓库里有三份真相，全靠手改，此前没有任何脚本或 CI 在校验：
///
/// | 位置 | 形态 |
/// |---|---|
/// | `pubspec.yaml` 的 `version:` | `0.5.1+3` |
/// | `lib/common/constants.dart` 的 `VERSION` | `'0.5.1'` |
/// | `update_logs.yaml` 的 `currentVersion` | `"0.5.1"` |
///
/// `VersionService` 拿 `CommonConstants.VERSION` 和远端 `currentVersion` 比大小。
/// 发版时漏改 `constants.dart` 的后果是**静默**的：要么永远提示有更新，要么永远
/// 不提示——两种都不会报错，只会让整套更新检测悄悄失灵。
///
/// 这里不校验「constants 必须等于 update_logs.currentVersion」：开发 0.5.2 期间
/// constants 会先走一步，而 changelog 要到发版那一刻才补上，拿这条当闸门会让整个
/// 开发周期都是红的。校验的是两条**任何时刻都该成立**的关系。
void main() {
  late final String pubspecVersion;
  late final YamlMap updateLogs;

  setUpAll(() {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    pubspecVersion = pubspec['version'].toString();
    updateLogs =
        loadYaml(File('update_logs.yaml').readAsStringSync()) as YamlMap;
  });

  test('⛔ constants.dart 的 VERSION 必须与 pubspec.yaml 一致', () {
    // pubspec 是 `x.y.z+build`，constants 只取 `+` 前面那段。
    final pubspecSemver = pubspecVersion.split('+').first;
    expect(
      CommonConstants.VERSION,
      pubspecSemver,
      reason:
          'lib/common/constants.dart 的 VERSION ($CommonConstants.VERSION) '
          '与 pubspec.yaml 的 version ($pubspecVersion) 对不上。'
          '更新检测拿的是前者，漏改会让它静默失灵。',
    );
  });

  test('⛔ constants.dart 的 BUILD_NUMBER 必须与 pubspec.yaml 的 +N 一致', () {
    final plus = pubspecVersion.indexOf('+');
    final int pubspecBuild = plus < 0
        ? 0
        : int.parse(pubspecVersion.substring(plus + 1));
    expect(
      CommonConstants.BUILD_NUMBER,
      pubspecBuild,
      reason:
          'BUILD_NUMBER 对不上会让「同 semver 的热修重打包」的更新检测算错：'
          '本机以为自己是 +${CommonConstants.BUILD_NUMBER}，实际是 +$pubspecBuild。',
    );
    expect(CommonConstants.FULL_VERSION, pubspecVersion);
  });

  test('update_logs.yaml 的 currentVersion 若带 build 号，必须是合法整数', () {
    // 热修（同 semver 重新打包）要被认出来，就必须把 build 号一起发布，
    // 例如 currentVersion: "0.5.2+5"。写成别的形态会被 AppVersion 兜底成 0，
    // 于是所有装着 +N 的用户都看不到这次热修。
    final raw = updateLogs['currentVersion'].toString();
    final plus = raw.indexOf('+');
    if (plus >= 0) {
      expect(
        int.tryParse(raw.substring(plus + 1)),
        isNotNull,
        reason: 'currentVersion "$raw" 的 `+` 后面不是整数，build 号会被当成 0',
      );
    }
  });

  test('⛔ update_logs.yaml 的 currentVersion 必须以纯数字段开头（别写成 v1.0.0）', () {
    // `v1.0.0` 这种写法会让首段 int 解析失败、兜底成 0，整个版本被解析成
    // 0.0.0——比本机任何版本都旧，于是**全量用户看不到这次大版本更新，且全程
    // 静默**。AppVersion.parse 已经会剥掉前导 v 作为兜底，但那是客户端侧的
    // 补救；发布物本身该是干净的，所以这里也挡一道。
    final raw = updateLogs['currentVersion'].toString().trim();
    expect(
      RegExp(r'^\d').hasMatch(raw),
      isTrue,
      reason: 'currentVersion "$raw" 不是以数字开头',
    );
  });

  test('update_logs.yaml 的 currentVersion 在 updates 列表里必须有对应条目', () {
    // updates 条目里的 version 写的是纯 semver，比对前先剥掉 build 号
    // （VersionService._parseUpdateInfo 也是这么匹配的）。
    final current = updateLogs['currentVersion'].toString().split('+').first;
    final updates = updateLogs['updates'];
    expect(updates, isA<YamlList>(), reason: 'updates 必须是一个列表');

    final versions = (updates as YamlList)
        .map((e) => (e as YamlMap)['version'].toString())
        .toList();
    expect(
      versions,
      contains(current),
      reason:
          '声明了 currentVersion: $current 却没有对应的 updates 条目。'
          '这种状态下客户端会判定"有新版"、但取不到更新日志——'
          'VersionService 会把它当作一次未得出结论的检查，用户看不到弹窗。',
    );
  });

  test('update_logs.yaml 的 updates 条目不得重复版本号', () {
    final versions = (updateLogs['updates'] as YamlList)
        .map((e) => (e as YamlMap)['version'].toString())
        .toList();
    expect(
      versions.toSet().length,
      versions.length,
      reason: '重复的版本号会让 VersionService 取到先出现的那一条，另一条永远读不到',
    );
  });

  test('每条 updates 都有 date 和至少一种语言的 changes', () {
    for (final entry in updateLogs['updates'] as YamlList) {
      final map = entry as YamlMap;
      final version = map['version'].toString();
      expect(map['date'], isNotNull, reason: 'v$version 缺 date（弹窗里会直接显示这个字段）');
      final changes = map['changes'];
      expect(changes, isA<YamlMap>(), reason: 'v$version 的 changes 必须是 map');
      expect(
        (changes as YamlMap).isNotEmpty,
        isTrue,
        reason: 'v$version 的 changes 一种语言都没有，弹窗会是空的',
      );
      // UpdateInfo.getLocalizedChanges 的兜底链最后落到 en / zh-CN / zh-TW / ja，
      // 一条都没有的话所有语言都拿到空列表。
      expect(
        const ['en', 'zh-CN', 'zh-TW', 'ja'].any(changes.containsKey),
        isTrue,
        reason: 'v$version 的 changes 不含任何一种兜底语言（en/zh-CN/zh-TW/ja）',
      );
    }
  });
}
