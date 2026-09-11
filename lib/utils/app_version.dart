/// 应用版本号的解析与比较。
///
/// 独立成模块是为了能脱离 GetX / 网络单测——`VersionService` 里那套判断
/// 「远端是不是比我新」的逻辑，过去只是几行 `int.tryParse(...) ?? 0`，
/// 有两个说不出口的行为：
///
/// 1. **build number 完全看不见。** 旧实现拿远端字符串先 `.split('+')[0]`
///    把 build 号切掉，而本地常量压根没有 build 号。于是 `0.5.1+3 → 0.5.1+4`
///    这种「同 semver、重新打包」的热修，更新检测**永远发现不了**。
/// 2. **预发布后缀被当成相等。** `'0.6.0-beta'.split('.')` 得到
///    `['0','6','0-beta']`，`int.tryParse('0-beta')` 是 null 于是兜底成 0，
///    结果 `0.6.0-beta` 和 `0.6.0` 完全相等。
///
/// ## 与严格 semver 的一处**故意**偏离
///
/// 严格 semver 规定 `+build` 是**元数据、不参与优先级比较**。这里不遵守：
/// pub / Flutter 把 `+N` 当作构建号，同一个 semver 重新打包就靠它区分，
/// 而「能不能认出一次热修重打包」正是这个类要解决的问题。所以
/// [AppVersion.compare] 里 build 号参与比较，且**大的更新**。
///
/// 缺省 build 号视为 0：远端只写 `"0.5.2"` 时，本地 `0.5.2+4` 会被判成
/// 「不比它旧」——所以**热修必须把 build 号一起发布**（`"0.5.2+5"`），
/// 否则装着 `0.5.2+4` 的人看不到它。update_logs.yaml 顶部有同样的提醒。
class AppVersion implements Comparable<AppVersion> {
  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
    this.build = 0,
  });

  final int major;
  final int minor;
  final int patch;

  /// `-` 之后、`+` 之前的那段；没有则为 null。
  /// 按 semver：**带**预发布后缀的版本比同号的正式版**旧**。
  final String? preRelease;

  /// `+` 之后的构建号；没有则为 0。
  final int build;

  /// 解析 `major.minor.patch[-preRelease][+build]`。
  ///
  /// 刻意宽容：段数不足补 0，解不出的数字段当 0，`+` 后不是整数当 0。
  /// 这里的输入有一半来自远端手写的 yaml，宁可退化成一个保守的结果，
  /// 也不要在启动路径上抛异常。
  static AppVersion parse(String raw) {
    var s = raw.trim();

    // 容忍 git tag 风格的前导 v：`v1.0.0`。不剥的话 `int.tryParse('v1')` 兜底
    // 成 0，整个版本被解析为 0.0.0，大版本更新会被判成"不比我新"而彻底失效。
    if (s.length > 1 && (s[0] == 'v' || s[0] == 'V')) {
      final rest = s.substring(1);
      if (rest.isNotEmpty && _isDigit(rest[0])) s = rest;
    }

    int build = 0;
    final plus = s.indexOf('+');
    if (plus >= 0) {
      build = int.tryParse(s.substring(plus + 1).trim()) ?? 0;
      s = s.substring(0, plus);
    }

    String? preRelease;
    final dash = s.indexOf('-');
    if (dash >= 0) {
      final tail = s.substring(dash + 1).trim();
      preRelease = tail.isEmpty ? null : tail;
      s = s.substring(0, dash);
    }

    final parts = s.split('.');
    int at(int i) =>
        i < parts.length ? (int.tryParse(parts[i].trim()) ?? 0) : 0;

    return AppVersion(
      major: at(0),
      minor: at(1),
      patch: at(2),
      preRelease: preRelease,
      build: build,
    );
  }

  /// `latest` 是否严格新于 `current`。两边都按 [parse] 的宽容规则解析。
  static bool isNewer({required String current, required String latest}) =>
      parse(latest).compareTo(parse(current)) > 0;

  @override
  int compareTo(AppVersion other) {
    var c = major.compareTo(other.major);
    if (c != 0) return c;
    c = minor.compareTo(other.minor);
    if (c != 0) return c;
    c = patch.compareTo(other.patch);
    if (c != 0) return c;

    // semver：1.0.0-beta < 1.0.0
    if (preRelease == null && other.preRelease != null) return 1;
    if (preRelease != null && other.preRelease == null) return -1;
    if (preRelease != null && other.preRelease != null) {
      c = _comparePreRelease(preRelease!, other.preRelease!);
      if (c != 0) return c;
    }

    // 见类文档：这一步是对严格 semver 的故意偏离。
    return build.compareTo(other.build);
  }

  /// semver 的预发布段比较：按 `.` 切成标识符逐个比。
  /// 纯数字的按数值比且**低于**含字母的；标识符多的一方在前缀相同时更大。
  static int _comparePreRelease(String a, String b) {
    final as = a.split('.');
    final bs = b.split('.');
    for (var i = 0; i < as.length && i < bs.length; i++) {
      final an = int.tryParse(as[i]);
      final bn = int.tryParse(bs[i]);
      final int c;
      if (an != null && bn != null) {
        c = an.compareTo(bn);
      } else if (an != null) {
        c = -1; // 数字标识符低于字母标识符
      } else if (bn != null) {
        c = 1;
      } else {
        c = as[i].compareTo(bs[i]);
      }
      if (c != 0) return c;
    }
    return as.length.compareTo(bs.length);
  }

  static bool _isDigit(String ch) {
    final c = ch.codeUnitAt(0);
    return c >= 0x30 && c <= 0x39;
  }

  /// 结构相等：逐字段比，与 [hashCode] 用的是同一组字段。
  ///
  /// ⛔ 不要改成 `compareTo(other) == 0`：`1.0.0-beta.1` 与 `1.0.0-beta.01` 在
  /// semver 次序上等价（数字标识符按数值比），但 `preRelease` 原文不同、
  /// hashCode 不同——那样写会违反 Dart 的 `==`/`hashCode` 契约，放进 Set/Map
  /// 时行为诡异。要比"次序上是否等价"请直接用 `compareTo(other) == 0`。
  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch &&
      preRelease == other.preRelease &&
      build == other.build;

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease, build);

  @override
  String toString() {
    final pre = preRelease == null ? '' : '-$preRelease';
    final b = build == 0 ? '' : '+$build';
    return '$major.$minor.$patch$pre$b';
  }
}
