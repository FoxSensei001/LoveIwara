import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';

/// 这个文件只守三件**看不见就会出事**的事：
///
/// 1. 密钥不许跟着档案序列化（跟进去了备份会把整张供应商列表一起剔掉）；
/// 2. 各家的怪癖在调用前就被夹住（夹漏了是一句英文 `UnsupportedError`）；
/// 3. 坏配置不许把列表整份吞掉，也不许放行无主的条目。
///
/// 其余（UI、网络）不在这里守——那些失败是看得见的。
void main() {
  group('档案序列化', () {
    const profile = AiProviderProfile(
      id: 'p1',
      name: '我的中转',
      kind: AiProviderKind.openai,
      baseUrl: 'https://api.example.com/v1',
      model: 'gpt-4o-mini',
      apiKey: 'sk-SUPER-SECRET',
      headers: {'X-Title': 'LoveIwara'},
    );

    test('⛔ toJson 绝不带 apiKey', () {
      final json = profile.toJson();
      expect(json.containsKey('apiKey'), isFalse);
      expect(json.toString(), isNot(contains('SUPER-SECRET')));
    });

    test('⛔ 整份 encodeList 里也搜不到密钥', () {
      final encoded = AiProviderProfile.encodeList([profile]);
      expect(encoded, isNot(contains('SUPER-SECRET')));
    });

    test('round-trip：除密钥外原样还原，密钥恒为空串', () {
      final back = AiProviderProfile.decodeList(
        AiProviderProfile.encodeList([profile]),
      ).single;
      expect(back.id, 'p1');
      expect(back.name, '我的中转');
      expect(back.baseUrl, 'https://api.example.com/v1');
      expect(back.model, 'gpt-4o-mini');
      expect(back.headers, {'X-Title': 'LoveIwara'});
      expect(back.apiKey, '', reason: '密钥另存安全存储，不该从 JSON 里冒出来');
    });

    test('坏 JSON 当成空列表，不抛', () {
      expect(AiProviderProfile.decodeList('{不是合法 json'), isEmpty);
      expect(AiProviderProfile.decodeList('{"a":1}'), isEmpty);
      expect(AiProviderProfile.decodeList(null), isEmpty);
      expect(AiProviderProfile.decodeList('   '), isEmpty);
    });

    test('⛔ 没有 id 的条目必须丢掉：它会让用途绑定指向一个无主的档案', () {
      final out = AiProviderProfile.decodeList(
        '[{"name":"没有id"},{"id":"ok","name":"有id"}]',
      );
      expect(out.map((e) => e.id), ['ok']);
    });

    test('认不出来的 kind 落回 openai（兼容端点是最宽的一支）', () {
      final out = AiProviderProfile.decodeList(
        '[{"id":"x","kind":"some-future-vendor"}]',
      ).single;
      expect(out.kind, AiProviderKind.openai);
    });
  });

  group('各家的怪癖在调用前就夹住', () {
    test('⛔ xAI 任何 temperature 都会抛 → effectiveTemperature 必须是 null', () {
      const p = AiProviderProfile(
        id: 'x',
        name: 'xAI',
        kind: AiProviderKind.xai,
        sendTemperature: true,
        temperature: 0.7,
      );
      expect(p.effectiveTemperature, isNull);
    });

    test('推理模型不发 temperature', () {
      const p = AiProviderProfile(
        id: 'r',
        name: 'o3',
        reasoning: true,
        sendTemperature: true,
        temperature: 0.7,
      );
      expect(p.effectiveTemperature, isNull);
    });

    test('普通 openai 档案照常发 temperature', () {
      const p = AiProviderProfile(id: 'o', name: 'OpenAI', temperature: 0.42);
      expect(p.effectiveTemperature, 0.42);
    });

    test(
      '⛔ openai / mistral / xai 开 thinking 会抛 → effectiveThinking 恒 false',
      () {
        for (final kind in [
          AiProviderKind.openai,
          AiProviderKind.mistral,
          AiProviderKind.xai,
        ]) {
          final p = AiProviderProfile(
            id: kind,
            name: kind,
            kind: kind,
            reasoning: true,
          );
          expect(p.effectiveThinking, isFalse, reason: kind);
        }
      },
    );

    test('anthropic / google / ollama 的 thinking 放行', () {
      for (final kind in [
        AiProviderKind.anthropic,
        AiProviderKind.google,
        AiProviderKind.ollama,
      ]) {
        final p = AiProviderProfile(
          id: kind,
          name: kind,
          kind: kind,
          reasoning: true,
        );
        expect(p.effectiveThinking, isTrue, reason: kind);
      }
    });

    test('⛔ 不支持自定义端点的几家：填了也不生效，且不当成配置错误', () {
      const p = AiProviderProfile(
        id: 'a',
        name: 'Claude',
        kind: AiProviderKind.anthropic,
        baseUrl: 'https://填了也白填.example.com',
      );
      expect(p.resolvedBaseUri(), isNull);
    });

    test('⛔ 少了 scheme 的地址要报错，不能当相对 URI 放行', () {
      const p = AiProviderProfile(
        id: 'o',
        name: 'OpenAI',
        baseUrl: 'api.openai.com/v1',
      );
      expect(p.resolvedBaseUri, throwsFormatException);
    });

    test('Ollama 不要密钥就算齐活', () {
      const p = AiProviderProfile(
        id: 'l',
        name: 'Ollama',
        kind: AiProviderKind.ollama,
      );
      expect(p.needsApiKey, isFalse);
      expect(p.isUsable, isTrue);
    });

    test('⛔ 空模型名是合法配置（用服务端默认），不该被判成没配好', () {
      const p = AiProviderProfile(id: 'o', name: 'OpenAI', apiKey: 'sk-x');
      expect(p.model, '');
      expect(p.isUsable, isTrue);
    });
  });

  group('预设', () {
    test('「自定义」排在最后——第一屏不该是空白表单', () {
      expect(kAiProviderPresets.last.custom, isTrue);
      expect(
        kAiProviderPresets.where((e) => e.custom).length,
        1,
        reason: '只该有一条自定义',
      );
    });

    test('预设 id 唯一', () {
      final ids = kAiProviderPresets.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('推理预设摊出来的档案默认不发 temperature', () {
      final preset = aiPresetById('deepseek_reasoner')!;
      final profile = preset.toProfile(id: 'p');
      expect(profile.reasoning, isTrue);
      expect(profile.sendTemperature, isFalse);
      expect(profile.presetId, 'deepseek_reasoner');
    });
  });

  group('用途绑定与用量', () {
    test('绑定表 round-trip，坏数据当空', () {
      final encoded = AiTaskBindings.encode({
        AiTask.translate: 'p1',
        AiTask.searchQuery: 'p2',
      });
      expect(AiTaskBindings.decode(encoded), {
        AiTask.translate: 'p1',
        AiTask.searchQuery: 'p2',
      });
      expect(AiTaskBindings.decode('坏数据'), isEmpty);
      // 认不出来的用途名直接跳过，不连累其它条
      expect(AiTaskBindings.decode('{"nope":"p1","translate":"p2"}'), {
        AiTask.translate: 'p2',
      });
    });

    test('⛔ 用途的 wireName 不跟枚举名走：改名不该让用户的绑定失效', () {
      expect(AiTask.searchQuery.wireName, 'search_query');
      expect(AiTask.fromWireName('search_query'), AiTask.searchQuery);
    });

    test('用量累加与 round-trip', () {
      final stats = {
        AiTask.translate: const AiUsageStat().plus(
          calls: 1,
          promptTokens: 10,
          responseTokens: 20,
        ),
      };
      final back = AiUsageStat.decodeMap(AiUsageStat.encodeMap(stats));
      expect(back[AiTask.translate]!.calls, 1);
      expect(back[AiTask.translate]!.totalTokens, 30);
    });
  });
}
