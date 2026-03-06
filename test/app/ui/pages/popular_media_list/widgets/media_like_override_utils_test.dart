import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_like_override_utils.dart';

void main() {
  group('shouldResetLikeOverride', () {
    test('returns false when source data is unchanged', () {
      final result = shouldResetLikeOverride(
        oldId: 'video-1',
        newId: 'video-1',
        oldLiked: true,
        newLiked: true,
        oldLikeCount: 9,
        newLikeCount: 9,
      );

      expect(result, isFalse);
    });

    test('returns true when same id but liked changes', () {
      final result = shouldResetLikeOverride(
        oldId: 'video-1',
        newId: 'video-1',
        oldLiked: false,
        newLiked: true,
        oldLikeCount: 9,
        newLikeCount: 9,
      );

      expect(result, isTrue);
    });

    test('returns true when same id but like count changes', () {
      final result = shouldResetLikeOverride(
        oldId: 'video-1',
        newId: 'video-1',
        oldLiked: true,
        newLiked: true,
        oldLikeCount: 9,
        newLikeCount: 10,
      );

      expect(result, isTrue);
    });
  });
}
