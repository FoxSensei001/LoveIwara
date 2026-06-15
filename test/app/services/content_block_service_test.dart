import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/block_rule.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/content_block_service.dart';

BlockRule _rule(
  BlockRuleType type,
  String value, {
  bool enabled = true,
  bool caseSensitive = false,
}) {
  return BlockRule(
    id: value,
    type: type,
    value: value,
    enabled: enabled,
    caseSensitive: caseSensitive,
  );
}

void main() {
  late ContentBlockService service;

  setUp(() {
    // 直接构造，不经过 Get（onInit 不会被调用，无需 ConfigService）。
    service = ContentBlockService();
  });

  group('keyword matching', () {
    test('matches case-insensitively by default', () {
      service.rules.assignAll([_rule(BlockRuleType.keyword, 'Spam')]);
      expect(service.check(title: 'this is SPAM video'), isNotNull);
      expect(service.check(title: 'clean title'), isNull);
    });

    test('respects caseSensitive flag', () {
      service.rules.assignAll([
        _rule(BlockRuleType.keyword, 'Spam', caseSensitive: true),
      ]);
      expect(service.check(title: 'contains Spam'), isNotNull);
      expect(service.check(title: 'contains spam'), isNull);
    });

    test('disabled rule does not match', () {
      service.rules.assignAll([
        _rule(BlockRuleType.keyword, 'spam', enabled: false),
      ]);
      expect(service.check(title: 'spam here'), isNull);
    });
  });

  group('regex matching', () {
    test('matches a valid pattern', () {
      service.rules.assignAll([_rule(BlockRuleType.regex, r'^\[AD\]')]);
      expect(service.check(title: '[AD] buy now'), isNotNull);
      expect(service.check(title: 'normal [AD] in middle'), isNull);
    });

    test('an invalid regex never matches and does not throw', () {
      service.rules.assignAll([_rule(BlockRuleType.regex, r'([unclosed')]);
      expect(service.check(title: 'anything'), isNull);
    });
  });

  group('userId matching', () {
    test('matches the author id exactly', () {
      service.rules.assignAll([_rule(BlockRuleType.userId, 'user-123')]);
      expect(service.check(authorId: 'user-123'), isNotNull);
      expect(service.check(authorId: 'user-999'), isNull);
      expect(service.check(authorId: null), isNull);
    });

    test('isUserBlocked reflects enabled userId rules', () {
      service.rules.assignAll([
        _rule(BlockRuleType.userId, 'a'),
        _rule(BlockRuleType.userId, 'b', enabled: false),
      ]);
      expect(service.isUserBlocked('a'), isTrue);
      expect(service.isUserBlocked('b'), isFalse);
      expect(service.isUserBlocked(''), isFalse);
      expect(service.isUserBlocked(null), isFalse);
    });
  });

  group('isValidRegex', () {
    test('returns true for valid and false for invalid / empty', () {
      expect(service.isValidRegex(r'^\d+$'), isTrue);
      expect(service.isValidRegex(r'([unclosed'), isFalse);
      expect(service.isValidRegex(''), isFalse);
    });

    test('rejects over-long patterns (ReDoS complexity guard)', () {
      final tooLong = 'a' * (ContentBlockService.maxRegexPatternLength + 1);
      expect(service.isValidRegex(tooLong), isFalse);
    });
  });

  test('_genId produces unique ids even when generated in a tight loop', () {
    // 通过批量替换导入路径无法在无 Get 的单测里跑，这里直接用对外行为间接验证：
    // 连续生成的 id 必须互不相同（修复同一微秒时间戳撞值的问题）。
    final ids = <String>{};
    for (var i = 0; i < 1000; i++) {
      ids.add(service.debugGenId());
    }
    expect(ids.length, 1000);
  });

  test('returns null when no rules', () {
    expect(service.check(title: 'whatever', authorId: 'x'), isNull);
  });

  test('blockUser helper would target the user id', () {
    // 仅校验 User 字段读取路径（不触发持久化）。
    final user = User(id: 'u1', name: 'Alice', username: 'alice');
    service.rules.assignAll([
      _rule(BlockRuleType.userId, user.id),
    ]);
    expect(service.isUserBlocked(user.id), isTrue);
  });
}
