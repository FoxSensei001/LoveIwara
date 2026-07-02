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
