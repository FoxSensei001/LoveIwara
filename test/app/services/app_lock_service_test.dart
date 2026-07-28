import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';

void main() {
  late ConfigService config;
  late AppLockService service;

  setUp(() {
    config = ConfigService();
    for (final key in ConfigKey.values) {
      config.settings[key] = Rx<dynamic>(key.defaultValue);
    }
    config.settings[ConfigKey.APP_LOCK_ENABLED]!.value = true;
    service = AppLockService(
      configService: config,
      storageService: StorageService(),
    );
  });

  test('PIN accepts only 4 to 8 digits', () {
    expect(service.isValidPin('1234'), isTrue);
    expect(service.isValidPin('12345678'), isTrue);
    expect(service.isValidPin('123'), isFalse);
    expect(service.isValidPin('123456789'), isFalse);
    expect(service.isValidPin('12a4'), isFalse);
  });

  test('immediate timeout locks when the app resumes', () {
    config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;

    service.onBackgrounded();
    service.onResumed();

    expect(service.isLocked.value, isTrue);
  });

  test('nonzero timeout keeps a short background visit unlocked', () {
    config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 30;

    service.onBackgrounded();
    service.onResumed();

    expect(service.isLocked.value, isFalse);
  });

  test('disabled timeout never locks after a background visit', () {
    expect(config[ConfigKey.APP_LOCK_TIMEOUT_SECONDS], -1);

    service.onBackgrounded();
    service.onResumed();

    expect(service.isLocked.value, isFalse);
  });

  test('screen lock locks when the option is enabled', () {
    config.settings[ConfigKey.APP_LOCK_AFTER_SCREEN_OFF]!.value = true;

    service.onSystemScreenLocked();

    expect(service.isLocked.value, isTrue);
  });

  test('screen lock is ignored when the option is disabled', () {
    service.onSystemScreenLocked();

    expect(service.isLocked.value, isFalse);
  });

  test('disabled app lock ignores lifecycle changes', () {
    config.settings[ConfigKey.APP_LOCK_ENABLED]!.value = false;
    config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;

    service.onBackgrounded();
    service.onResumed();

    expect(service.isLocked.value, isFalse);
  });
}
