import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

void main() {
  group('MyVideoStateController.formatTransferRateForDisplay', () {
    test('formats small values in bytes per second', () {
      expect(
        MyVideoStateController.formatTransferRateForDisplay(512),
        '512 B/s',
      );
    });

    test('formats kilobytes per second', () {
      expect(
        MyVideoStateController.formatTransferRateForDisplay(1536),
        '1.5 KB/s',
      );
    });

    test('formats megabytes per second', () {
      expect(
        MyVideoStateController.formatTransferRateForDisplay(2 * 1024 * 1024),
        '2.0 MB/s',
      );
    });
  });
}
