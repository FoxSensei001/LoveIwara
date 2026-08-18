import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

void main() {
  group('playerScreenFitModeFromConfig', () {
    for (final mode in PlayerScreenFitMode.values) {
      test('parses ${mode.name}', () {
        expect(playerScreenFitModeFromConfig(mode.name), mode);
      });
    }

    test('falls back to fit for an invalid value', () {
      expect(playerScreenFitModeFromConfig('16:9'), PlayerScreenFitMode.fit);
      expect(playerScreenFitModeFromConfig(null), PlayerScreenFitMode.fit);
    });
  });

  group('initialPlayerScreenFitMode', () {
    test('ignores a stored mode when remembering is disabled', () {
      expect(
        initialPlayerScreenFitMode(
          rememberScreenFitMode: false,
          storedMode: PlayerScreenFitMode.cover.name,
        ),
        PlayerScreenFitMode.fit,
      );
    });

    test('uses a valid stored mode when remembering is enabled', () {
      expect(
        initialPlayerScreenFitMode(
          rememberScreenFitMode: true,
          storedMode: PlayerScreenFitMode.ratio16x9.name,
        ),
        PlayerScreenFitMode.ratio16x9,
      );
    });

    test('falls back to fit for an invalid remembered mode', () {
      expect(
        initialPlayerScreenFitMode(
          rememberScreenFitMode: true,
          storedMode: 'invalid',
        ),
        PlayerScreenFitMode.fit,
      );
    });
  });
}
