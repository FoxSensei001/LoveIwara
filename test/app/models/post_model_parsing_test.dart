import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';

void main() {
  group('PostModel parsing', () {
    test('handles nullable post fields from API safely', () {
      final post = PostModel.fromJson({
        'id': 'post-1',
        'title': null,
        'body': null,
        'numViews': 12,
        'createdAt': '2023-11-30T13:25:24.000Z',
        'updatedAt': '2023-11-30T13:25:24.000Z',
        'user': {
          'id': 'user-1',
          'name': 'Moanah',
          'username': 'notfrombaltimore',
          'status': 'active',
          'role': 'user',
          'followedBy': false,
          'following': false,
          'friend': false,
          'premium': false,
          'creatorProgram': true,
          'locale': null,
          'seenAt': '2026-02-27T18:20:38.000Z',
          'avatar': null,
          'createdAt': '2023-07-20T10:14:27.000Z',
          'updatedAt': '2026-02-27T12:59:02.000Z',
        },
      });

      expect(post.id, 'post-1');
      expect(post.title, '');
      expect(post.body, '');
      expect(post.user.id, 'user-1');
      expect(post.user.locale, isNull);
      expect(post.user.avatar, isNull);
    });

    test('handles malformed avatar fields without throwing', () {
      final user = User.fromJson({
        'id': 'user-2',
        'avatar': {
          'id': 'avatar-1',
          'type': null,
          'path': null,
          'name': null,
          'mime': null,
          'size': 100,
          'width': null,
          'height': null,
          'createdAt': null,
          'updatedAt': null,
        },
      });

      expect(user.avatar, isNotNull);
      expect(user.avatar!.id, 'avatar-1');
      expect(user.avatar!.type, '');
      expect(user.avatar!.path, '');
      expect(user.avatar!.name, '');
      expect(user.avatar!.mime, '');
    });

    test('falls back to empty user when user payload is missing', () {
      final post = PostModel.fromJson({
        'id': 'post-2',
        'title': 't',
        'body': 'b',
        'numViews': 0,
        'createdAt': '2023-11-30T13:25:24.000Z',
        'updatedAt': '2023-11-30T13:25:24.000Z',
        'user': null,
      });

      expect(post.user.id, '');
      expect(post.user.username, '');
    });
  });
}
