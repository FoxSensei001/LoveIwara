import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/app_lock_settings_section.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class _FakeAppLockService extends AppLockService {
  _FakeAppLockService(ConfigService config)
    : super(configService: config, storageService: StorageService());

  final RxBool _enabled = false.obs;

  @override
  bool get enabled => _enabled.value;

  @override
  Future<bool> enableWithPin(String pin) async {
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
    Get.put<AppLockService>(_FakeAppLockService(config));
  });

  tearDown(Get.reset);

  testWidgets('setting a PIN closes one dialog before expanding settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: AppLockSettingsSection()),
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
    expect(find.byType(AlertDialog), findsNothing);
  });
}
