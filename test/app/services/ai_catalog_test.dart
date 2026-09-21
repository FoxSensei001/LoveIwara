import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/utils/ai_model_id.dart';
import 'package:i_iwara/app/utils/ai_token_format.dart';

/// 打包进 App 的那份目录。
///
/// ⛔ 直接读**磁盘上的**资源文件而不是 `rootBundle`：这几条断言的价值在于
/// 「生成脚本刚刚吐出来的那份能不能用」，走 bundle 只能测到上一次构建的快照。
Map<String, dynamic> _loadCatalog() =>
    jsonDecode(File('assets/data/ai_catalog.min.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('normalizeModelId', () {
    // 每一条都是真实见过的形状：左边是端点 /models 报上来的，
    // 右边是目录里那条的规范 id。
    const cases = <String, String>{
      'gemini-2.5-pro': 'gemini-2-5-pro',
      'claude-opus-4-1-20250805': 'claude-opus-4-1',
      'claude-sonnet-4-5-20250929-thinking': 'claude-sonnet-4-5',
      'aihubmix-gpt-4o': 'gpt-4o',
      'gpt-4o:free': 'gpt-4o',
      'deepseek-v3.2-thinking': 'deepseek-v3-2',
      'anthropic/claude-3': 'claude-3',
      'kimi-k2-250905': 'kimi-k2',
      'glm-4-5-fp8': 'glm-4-5',
      'bce-embedding-base_v1': 'bce-embedding-base-v1',
    };

    cases.forEach((input, expected) {
      test('$input -> $expected', () {
        expect(normalizeModelId(input), expected);
      });
    });

    test('参数规模：默认剥掉，keepParameterSize 时保留', () {
      expect(normalizeModelId('qwen3-235b-a22b'), 'qwen3-a22b');
      expect(
        normalizeModelId('gpt-oss:20b', keepParameterSize: true),
        'gpt-oss-20b',
      );
    });

    test('⛔ -medium 是真的档位名，不能当推理强度剥掉', () {
      expect(normalizeModelId('mistral-medium'), 'mistral-medium');
      expect(normalizeModelId('devstral-medium'), 'devstral-medium');
    });

    test('⛔ 被保护的词头不许被 -think 腰斩成假词根', () {
      // `-no-think` 自己也是一条变体后缀，所以整条剥掉、落到 `qwen3` 是对的；
      // 保护规则挡的是**中途**那一步——先命中 `-think` 会剩下 `qwen3-no`，
      // 那不是任何模型的名字。
      expect(normalizeModelId('qwen3-no-think'), 'qwen3');
      // 词头被保护、又没有更长的后缀兜住时，整条原样留着。
      expect(normalizeModelId('x-non-think'), 'x-non-think');
      // 而「最后一个词恰好以 no 结尾」不算词头，照剥。
      expect(normalizeModelId('volcano-free'), 'volcano');
    });

    test('⛔ mm- 是 MiniMax 简写，不是聚合器前缀', () {
      expect(normalizeModelId('mm-m2-1'), 'minimax-m2-1');
    });

    test('幂等：折过一次再折结果不变', () {
      for (final input in [...cases.keys, 'qwen3-235b-a22b', 'gpt-oss:20b']) {
        final once = normalizeModelId(input);
        expect(normalizeModelId(once), once, reason: input);
      }
    });
  });

  group('formatTokenCount', () {
    test('每一级量级各自的写法', () {
      expect(formatTokenCount(0), '0');
      expect(formatTokenCount(845), '845');
      expect(formatTokenCount(12300), '12.3K');
      expect(formatTokenCount(163840), '163.8K');
      expect(formatTokenCount(2400000), '2.4M');
      expect(formatTokenCount(3200000000), '3.2B');
      expect(formatTokenCount(1100000000000), '1.1T');
    });

    test('⛔ 整数不许印出 .0 —— 那会被读成「精确到小数位」', () {
      expect(formatTokenCount(128000), '128K');
      expect(formatTokenCount(1000000), '1M');
      expect(formatTokenCount(1000000000), '1B');
      expect(formatTokenCount(1000000000000), '1T');
    });

    test('⛔ 每一级进位都不许出现 1000K / 1000M 这种没人用的写法', () {
      // 判据是「四舍五入到一位小数之后够不够 1」，所以每一级自动对。
      expect(formatTokenCount(999), '999');
      expect(formatTokenCount(1000), '1K');
      expect(formatTokenCount(999949), '999.9K');
      expect(formatTokenCount(999999), '1M');
      expect(formatTokenCount(999999999), '1B');
      expect(formatTokenCount(999999999999), '1T');
    });

    test('超出 T 之后继续用 T，不回落成裸数字', () {
      expect(formatTokenCount(25000000000000), '25T');
    });
  });

  group('打包目录资源', () {
    late Map<String, dynamic> catalog;
    late Map<String, dynamic> providers;
    late Map<String, dynamic> models;

    setUpAll(() {
      catalog = _loadCatalog();
      providers = (catalog['providers'] as Map).cast<String, dynamic>();
      models = (catalog['models'] as Map).cast<String, dynamic>();
    });

    test('信封字段齐全（TagDictionaryFetcher 的新旧判定靠它们）', () {
      expect(catalog['version'], isA<int>());
      expect(catalog['rev'], isA<String>());
      expect(DateTime.tryParse('${catalog['builtAt']}'), isNotNull);
      expect(catalog['count'], providers.length + models.length);
    });

    test('⛔ 几家关键供应商一条都不能丢', () {
      // 生成脚本漏掉一条 kind 判定就会成批丢供应商，而症状是「向导里找不到
      // Anthropic 了」——第一版就真丢过 anthropic / mistral / xai 三家。
      for (final id in [
        'openai',
        'anthropic',
        'gemini',
        'deepseek',
        'ollama',
      ]) {
        expect(providers.containsKey(id), isTrue, reason: '丢了 $id');
      }
      expect(providers.length, greaterThan(40));
      expect(models.length, greaterThan(300));
    });

    test('⛔ OpenAI 兼容端点的地址必须带版本段', () {
      // dartantic 把 baseUrl 原样当前缀拼 /chat/completions，少一个 /v1 就是 404。
      final versioned = RegExp(r'/v\d+([a-z]+\d*)?(/|$)');
      final offenders = <String>[];
      providers.forEach((id, value) {
        final p = (value as Map).cast<String, dynamic>();
        if (p['k'] != 'openai') return;
        final url = p['u'] as String?;
        if (url == null) return;
        // Perplexity 的聊天端点真的没有 /v1，见 overrides.dart。
        if (id == 'perplexity') return;
        if (!versioned.hasMatch(url)) offenders.add('$id -> $url');
      });
      expect(offenders, isEmpty);
    });

    test('⛔ 不许夹带别人的推广返利链接', () {
      final referral = RegExp(r'/i/|invite|referr|utm_', caseSensitive: false);
      final offenders = <String>[];
      providers.forEach((id, value) {
        final web = ((value as Map)['w'] as Map?)?.cast<String, dynamic>();
        web?.forEach((_, url) {
          if (url is String && referral.hasMatch(url)) {
            offenders.add('$id -> $url');
          }
        });
      });
      expect(offenders, isEmpty);
    });

    test('kind 全在 dartantic 认识的那六个里', () {
      const known = {
        'openai',
        'anthropic',
        'google',
        'ollama',
        'mistral',
        'xai',
      };
      for (final value in providers.values) {
        expect(known, contains((value as Map)['k']));
      }
    });
  });

  group('目录解析', () {
    test('provider 的各档开关与网址解得出来', () {
      final p = AiCatalogProvider.fromJson('demo', {
        'n': '演示',
        'k': 'openai',
        'u': 'https://example.com/v1',
        'so': 0,
        'nk': 1,
        'nt': 1,
        'lo': 1,
        'w': {'k': 'https://example.com/key', 'd': 'https://example.com/docs'},
        's': ['a', 'b'],
      });
      expect(p.name, '演示');
      expect(p.structuredOutput, isFalse);
      expect(p.needsApiKey, isFalse);
      expect(p.sendsTemperature, isFalse);
      expect(p.local, isTrue);
      expect(p.apiKeyUrl, 'https://example.com/key');
      expect(p.homeUrl, isNull);
      expect(p.suggestedModels, ['a', 'b']);
    });

    test('⛔ so 缺省是「未知」，不是「不支持」', () {
      // 未知要走向导那一步去真探一次；当成 false 的话，本来支持结构化输出的
      // 端点会被永远按降级路走。
      final p = AiCatalogProvider.fromJson('demo', {'k': 'openai'});
      expect(p.structuredOutput, isNull);
      expect(p.needsApiKey, isTrue);
      expect(p.sendsTemperature, isTrue);
    });

    test('模型能力短码解得出来，不认识的码安静丢掉', () {
      final m = AiCatalogModel.fromJson('x', {
        'n': 'X',
        'c': ['fc', 'rs', '未来的新码'],
        'w': 128000,
        'o': 16384,
      });
      expect(m.capabilities, {
        AiModelCapability.functionCall,
        AiModelCapability.reasoning,
      });
      expect(m.has(AiModelCapability.structuredOutput), isFalse);
      expect(m.contextWindow, 128000);
      expect(m.maxOutputTokens, 16384);
    });

    test('⛔ maxOutputTokens 缺省是 null（「没记」），不是 0（「上限是零」）', () {
      final m = AiCatalogModel.fromJson('x', const {});
      expect(m.maxOutputTokens, isNull);
      expect(m.contextWindow, isNull);
    });
  });
}
