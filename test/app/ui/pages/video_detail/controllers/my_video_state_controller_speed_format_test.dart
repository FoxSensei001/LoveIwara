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
        MyVideoStateController.formatTransferRateForDisplay(1500),
        '1.5 KB/s',
      );
    });

    test('formats megabytes per second', () {
      expect(
        MyVideoStateController.formatTransferRateForDisplay(2000000),
        '2.0 MB/s',
      );
    });

    test('uses decimal units for network transfer rates', () {
      expect(
        MyVideoStateController.formatTransferRateForDisplay(1000),
        '1.0 KB/s',
      );
    });
  });

  group('MyVideoStateController player loading speed parsing', () {
    test('reads mpv raw-input-rate from demuxer cache state', () {
      expect(
        MyVideoStateController.parseDemuxerCacheStateLoadingSpeed(
          '{"raw-input-rate": 2097152, "fw-bytes": 1048576}',
        ),
        2097152,
      );
    });
  });
}
