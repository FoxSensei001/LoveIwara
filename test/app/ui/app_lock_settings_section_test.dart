import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/app_lock_settings_section.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class _FakeAppLockService extends AppLockService {
  _FakeAppLockService(ConfigService config)
    : super(configService: config, storageService: StorageService());

  final RxBool _enabled = false.obs;

  /// 挂上以后 [enableWithPin] 会卡在这里，用来观察等待期间的 UI。
  /// 真机上这段是 PBKDF2 派生 12 万轮 + 写 Keystore。
  Completer<void>? gate;

  @override
  bool get enabled => _enabled.value;

  @override
  Future<bool> enableWithPin(String pin) async {
    await gate?.future;
    _enabled.value = true;
    return true;
  }
}

void main() {
  setUp(() {
    final config = ConfigService();
    for (final key in ConfigKey.values) {
      config.settings[key] = Rx<dynamic>(key.defaultValue);
    }
    // 隐私模式开关并进了这张卡，所以它现在也依赖 ConfigService
    Get.put<ConfigService>(config);
    Get.put<AppLockService>(_FakeAppLockService(config));
  });

  tearDown(Get.reset);

  testWidgets('setting a PIN closes one dialog before expanding settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TranslationProviderShim(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AppLockSettingsSection()),
          ),
        ),
      ),
    );

    await tester.tap(find.text(slang.t.settings.appLockEnabled));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).at(0), '1234');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.text(slang.t.common.confirm));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(slang.t.settings.appLockTimeout), findsOneWidget);
    expect(find.byType(GlassAlertDialog), findsNothing);
  });

  group('隐私模式与应用锁的重叠裁决', () {
    test('安卓 + 应用锁关：禁截图和后台遮罩都归隐私模式管', () {
      expect(
        resolvePrivacyModeVisibility(isAndroid: true, appLockEnabled: false),
        PrivacyModeVisibility.screenshotAndOverlay,
      );
    });

    test('安卓 + 应用锁开：遮罩已由应用锁承担，隐私模式只剩禁截图', () {
      expect(
        resolvePrivacyModeVisibility(isAndroid: true, appLockEnabled: true),
        PrivacyModeVisibility.screenshotOnly,
      );
    });

    test('非安卓 + 应用锁关：拦不住截图，只剩后台遮罩', () {
      expect(
        resolvePrivacyModeVisibility(isAndroid: false, appLockEnabled: false),
        PrivacyModeVisibility.overlayOnly,
      );
    });

    test('非安卓 + 应用锁开：两者完全重叠，隐私模式整条藏掉', () {
      expect(
        resolvePrivacyModeVisibility(isAndroid: false, appLockEnabled: true),
        PrivacyModeVisibility.hidden,
      );
    });
  });

  testWidgets('开应用锁的等待期间：开关变转圈，且不吃重复点击', (tester) async {
    final fake = Get.find<AppLockService>() as _FakeAppLockService;
    final gate = Completer<void>();
    fake.gate = gate;

    await tester.pumpWidget(
      const TranslationProviderShim(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AppLockSettingsSection()),
          ),
        ),
      ),
    );

    await tester.tap(find.text(slang.t.settings.appLockEnabled));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '1234');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.text(slang.t.common.confirm));
    // 转圈是无限动画，settle 会一直等下去，等待期间只能自己推时间轴。
    // 这一秒同时用来放完 PIN 弹窗的退场动画——否则下面会把还没消失的旧弹窗
    // 误当成「又弹了一张」。
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // 再补一帧：`showAppDialog` 的结果是等路由**销毁**才交出来的（见
    // `test/app/ui/widgets/glass/overlay_result_timing_test.dart`），
    // 退场动画结束那一帧才轮到路由出栈，慢操作要下一帧才起跑。
    await tester.pump();

    // 隐私模式那行也有个开关，所以断言必须钉在应用锁这一行上。
    final lockRow = find.ancestor(
      of: find.text(slang.t.settings.appLockEnabled),
      matching: find.byType(GlassSwitchItem),
    );
    expect(
      find.descendant(of: lockRow, matching: find.byType(GlassTileSpinner)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: lockRow, matching: find.byType(GlassToggle)),
      findsNothing,
    );

    // 等待期间再拨一次：既不该重跑一遍慢操作，也不该再弹一次 PIN 框。
    expect(find.byType(GlassAlertDialog), findsNothing);
    await tester.tap(
      find.text(slang.t.settings.appLockEnabled),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GlassAlertDialog), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(GlassTileSpinner), findsNothing);
    expect(find.text(slang.t.settings.appLockTimeout), findsOneWidget);
  });

  testWidgets('非安卓宿主上开了应用锁，隐私模式开关就从卡里消失', (tester) async {
    // GetPlatform.isAndroid 读的是宿主平台，跑 flutter test 时恒为 false，
    // 所以这里天然就是「非安卓」分支。
    await tester.pumpWidget(
      const TranslationProviderShim(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AppLockSettingsSection()),
          ),
        ),
      ),
    );

    final privacyRow = find.text(slang.t.settings.activeBackgroundPrivacyMode);
    expect(privacyRow, findsOneWidget);
    expect(
      find.text(slang.t.settings.activeBackgroundPrivacyModeDescNonAndroid),
      findsOneWidget,
    );

    await Get.find<AppLockService>().enableWithPin('1234');
    await tester.pumpAndSettle();

    expect(privacyRow, findsNothing);
  });

  testWidgets('PIN 弹窗走的是玻璃弹窗，不是裸 AlertDialog', (tester) async {
    await tester.pumpWidget(
      const TranslationProviderShim(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AppLockSettingsSection()),
          ),
        ),
      ),
    );

    await tester.tap(find.text(slang.t.settings.appLockEnabled));
    await tester.pumpAndSettle();

    expect(find.byType(GlassAlertDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

/// slang 的 [slang.TranslationProvider] 别名，省得每处都写全限定名。
class TranslationProviderShim extends StatelessWidget {
  const TranslationProviderShim({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      slang.TranslationProvider(child: child);
}
