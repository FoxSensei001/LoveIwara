import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/device_form_factor_utils.dart';

void main() {
  group('DeviceFormFactorUtils.classifyMobileDisplay', () {
    test('uses platform tablet signal first', () {
      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: true,
          fallbackLogicalTablet: false,
        ),
        MobileDeviceType.tablet,
      );

      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: false,
          fallbackLogicalTablet: true,
        ),
        MobileDeviceType.phone,
      );
    });

    test('XR headsets never classify as phone (no orientation lock)', () {
      // Quest 等头显的 2D 面板 smallestWidthDp 常常 < 600，会被平台信号判成手机；
      // 一旦按手机锁竖屏，系统就给面板加信箱边，用户拖宽也不会真的变宽。
      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: false,
          fallbackLogicalTablet: false,
          isXr: true,
        ),
        MobileDeviceType.tablet,
      );

      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: null,
          fallbackLogicalTablet: false,
          isXr: true,
        ),
        MobileDeviceType.tablet,
      );
    });

    test('non-XR devices keep the existing phone classification', () {
      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: false,
          fallbackLogicalTablet: false,
          isXr: false,
        ),
        MobileDeviceType.phone,
      );
    });

    test('uses logical viewport only as last resort', () {
      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: null,
          fallbackLogicalTablet: true,
        ),
        MobileDeviceType.tablet,
      );

      expect(
        DeviceFormFactorUtils.classifyMobileDisplay(
          platformReportsTablet: null,
          fallbackLogicalTablet: false,
        ),
        MobileDeviceType.phone,
      );
    });
  });
}
