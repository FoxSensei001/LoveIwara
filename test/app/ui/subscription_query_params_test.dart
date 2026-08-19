import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/controllers/subscription_query_params.dart';

/// 这些期望来自对 api.iwara.tv `/videos`、`/images` 的实测：
/// - `subscribed=true` 下 sort / date / tags / rating 都生效，且筛选结果仍限定在
///   已关注作者集合内；
/// - 带 `user=` 时服务端会忽略 `rating`（混合评级作者传 general / ecchi 返回
///   完全相同的混合结果），所以这个参数不应被发出去。
void main() {
  group('buildSubscriptionQueryParams', () {
    test('未指定用户时走订阅流，且带上全部筛选参数', () {
      final params = buildSubscriptionQueryParams(
        userId: '',
        sortId: 'likes',
        searchTagIds: ['koikatsu', 'futanari'],
        searchDate: '2025-12',
        searchRating: 'ecchi',
      );

      expect(params['subscribed'], isTrue);
      expect(params.containsKey('user'), isFalse);
      expect(params['sort'], 'likes');
      expect(params['tags'], 'koikatsu,futanari');
      expect(params['date'], '2025-12');
      expect(params['rating'], 'ecchi');
    });

    test('指定用户时不发 subscribed，也不发服务端会忽略的 rating', () {
      final params = buildSubscriptionQueryParams(
        userId: 'user-id',
        sortId: 'date',
        searchTagIds: ['koikatsu'],
        searchDate: '2025',
        searchRating: 'general',
      );

      expect(params['user'], 'user-id');
      expect(params.containsKey('subscribed'), isFalse);
      expect(params['sort'], 'date');
      expect(params['tags'], 'koikatsu');
      expect(params['date'], '2025');
      expect(params.containsKey('rating'), isFalse);
    });

    test('空筛选不产生多余的 key（避免空串被当成筛选条件）', () {
      final params = buildSubscriptionQueryParams(userId: '');

      expect(params.keys.toSet(), {'subscribed'});
    });
  });
}
