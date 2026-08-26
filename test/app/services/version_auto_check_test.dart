import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/version_service.dart';

void main() {
  const int now = 1800000000000;
  const int day = 24 * 60 * 60 * 1000;

  bool check({
    bool autoCheckEnabled = true,
    bool firstTimeSetupCompleted = true,
    int lastCheckMs = 0,
    int nowMs = now,
  }) => VersionService.shouldAutoCheck(
    autoCheckEnabled: autoCheckEnabled,
    firstTimeSetupCompleted: firstTimeSetupCompleted,
    lastCheckMs: lastCheckMs,
    nowMs: nowMs,
  );

  test('关掉自动检查就不查', () {
    expect(check(autoCheckEnabled: false), isFalse);
  });

  test('⛔ 首次引导还没走完不许查——弹窗会盖在引导页上', () {
    expect(check(firstTimeSetupCompleted: false), isFalse);
    // 连"从来没查过"也不能让它破例。
    expect(check(firstTimeSetupCompleted: false, lastCheckMs: 0), isFalse);
  });

  test('从来没查过就查', () {
    expect(check(lastCheckMs: 0), isTrue);
  });

  test('刚查过不到间隔就不查（这就是"每次启动都弹"的修法）', () {
    expect(check(lastCheckMs: now - 1000), isFalse);
    expect(check(lastCheckMs: now - day + 1000), isFalse);
  });

  test('超过间隔就查', () {
    expect(check(lastCheckMs: now - day), isTrue);
    expect(check(lastCheckMs: now - 3 * day), isTrue);
  });

  test('时间戳在未来（用户改过系统时间）不该把自己锁死', () {
    expect(check(lastCheckMs: now + 30 * day), isTrue);
  });

  test('间隔就是 24 小时', () {
    expect(VersionService.autoCheckInterval, const Duration(hours: 24));
  });
}
