import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';

/// 这个文件只守**看不见就会出事**的那几条：
///
/// 1. 密钥不许跟着配置序列化（跟进去了备份会把整张供应商列表一起剔掉）；
/// 2. delta 的继承方向不许写反（写反了要么目录永远盖不过用户、要么用户的设置
///    被目录悄悄改掉，两种都没有任何征兆）；
/// 3. 各家的怪癖在调用前就被夹住（夹漏了是一句英文 `UnsupportedError`）；
/// 4. 坏配置不许把整份吞掉，也不许放行无主的条目。
///
/// 其余（UI、网络）不在这里守——那些失败是看得见的。
void main() {
  const demoCatalog = AiCatalogProvider(
    id: 'demo',
    name: '演示供应商',
    kind: AiProviderKind.openai,
    baseUrl: 'https://catalog.example.com/v1',
    structuredOutput: true,
  );

  group('配置序列化', () {
    const provider = AiProvider(
      id: 'p1',
      catalogId: 'demo',
      name: '我的中转',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-SUPER-SECRET',
      headers: {'X-Title': 'LoveIwara'},
    );
    const model = AiModel(providerId: 'p1', modelId: 'gpt-4o-mini');

    test('⛔ toJson 绝不带 apiKey', () {
      final json = provider.toJson();
      expect(json.containsKey('apiKey'), isFalse);
      expect(json.toString(), isNot(contains('SUPER-SECRET')));
    });

    test('⛔ 整份 encode 里也搜不到密钥', () {
      final encoded = AiProviderConfig.encode(
        const AiProviderConfig(providers: [provider], models: [model]),
      );
      expect(encoded, isNot(contains('SUPER-SECRET')));
    });

    test('round-trip：除密钥外原样还原，密钥恒为空串', () {
      final back = AiProviderConfig.decode(
        AiProviderConfig.encode(
          const AiProviderConfig(providers: [provider], models: [model]),
        ),
      );
      final p = back.providers.single;
      expect(p.id, 'p1');
      expect(p.catalogId, 'demo');
      expect(p.name, '我的中转');
      expect(p.baseUrl, 'https://api.example.com/v1');
      expect(p.headers, {'X-Title': 'LoveIwara'});
      expect(p.apiKey, '', reason: '密钥另存安全存储，不该从 JSON 里冒出来');
      expect(back.models.single.modelId, 'gpt-4o-mini');
    });

    test('⛔ 没覆盖的字段不写进 JSON —— 写了就变成「显式设成了 null」', () {
      // 缺席才是「跟目录走」。一旦把 null 写进去，后来的人多半会把它读成
      // 「用户特意清空了这一项」，继承就断在这儿。
      const bare = AiProvider(id: 'p', catalogId: 'demo');
      expect(bare.toJson().keys, ['id', 'catalogId']);
    });

    test('坏 JSON 当成空配置，不抛', () {
      expect(AiProviderConfig.decode('{不是合法 json').providers, isEmpty);
      expect(AiProviderConfig.decode('[]').providers, isEmpty);
      expect(AiProviderConfig.decode(null).providers, isEmpty);
      expect(AiProviderConfig.decode('   ').providers, isEmpty);
    });

    test('⛔ 没有 id 的供应商、以及主人不在的模型，都必须丢掉', () {
      final out = AiProviderConfig.decode(
        '{"providers":[{"name":"没有id"},{"id":"ok"}],'
        '"models":[{"providerId":"ok","modelId":"m"},'
        '{"providerId":"幽灵","modelId":"m"}]}',
      );
      expect(out.providers.map((e) => e.id), ['ok']);
      expect(out.models.map((e) => e.providerId), ['ok']);
    });
  });

  group('⭐ delta 继承', () {
    AiResolvedModel resolve(AiProvider p, [AiModel? m]) => resolveAiModel(
      provider: p,
      model: m ?? const AiModel(providerId: 'p', modelId: ''),
      providerCatalog: demoCatalog,
    );

    test('没覆盖 → 跟目录走', () {
      final r = resolve(const AiProvider(id: 'p', catalogId: 'demo'));
      expect(r.providerName, '演示供应商');
      expect(r.kind, AiProviderKind.openai);
      expect(r.baseUrl, 'https://catalog.example.com/v1');
    });

    test('覆盖了 → 用户赢', () {
      final r = resolve(
        const AiProvider(
          id: 'p',
          catalogId: 'demo',
          name: '我改的名',
          baseUrl: 'https://mine.example.com/v1',
        ),
      );
      expect(r.providerName, '我改的名');
      expect(r.baseUrl, 'https://mine.example.com/v1');
    });

    test('⛔ copyWith 的 clearXxx 要真能把覆盖清回 null（＝重新跟随目录）', () {
      // `x ?? this.x` 表达不出「改回 null」，而 UI 上那枚「重置为默认」走的
      // 就是这条路。缺了它，用户覆盖过一次就再也回不去了。
      const overridden = AiProvider(
        id: 'p',
        catalogId: 'demo',
        baseUrl: 'https://mine.example.com/v1',
      );
      expect(overridden.copyWith(clearBaseUrl: true).baseUrl, isNull);
      expect(
        resolve(overridden.copyWith(clearBaseUrl: true)).baseUrl,
        'https://catalog.example.com/v1',
      );
    });

    test('目录缺席（完全自定义）→ 落到应用默认', () {
      final r = resolveAiModel(
        provider: const AiProvider(id: 'p', kind: AiProviderKind.openai),
        model: const AiModel(providerId: 'p', modelId: 'x'),
      );
      expect(r.kind, AiProviderKind.openai);
      expect(r.baseUrl, '');
      expect(r.temperature, AiDefaults.temperature);
    });
  });

  group('各家的怪癖在调用前就夹住', () {
    AiResolvedModel resolveKind(
      String kind, {
      AiModel? model,
      AiCatalogModel? modelCatalog,
    }) => resolveAiModel(
      provider: AiProvider(id: kind, kind: kind),
      model: model ?? AiModel(providerId: kind, modelId: 'm'),
      modelCatalog: modelCatalog,
    );

    test('⛔ xAI 任何 temperature 都会抛 → 解析出来必须是 null', () {
      expect(resolveKind(AiProviderKind.xai).temperature, isNull);
    });

    test('⛔ openai / mistral / xai 开 thinking 会抛 → reasoning 恒 false', () {
      for (final kind in [
        AiProviderKind.openai,
        AiProviderKind.mistral,
        AiProviderKind.xai,
      ]) {
        final r = resolveKind(
          kind,
          model: AiModel(providerId: kind, modelId: 'm', reasoning: true),
        );
        expect(r.reasoning, isFalse, reason: kind);
      }
    });

    test('anthropic / google / ollama 的 thinking 放行', () {
      for (final kind in [
        AiProviderKind.anthropic,
        AiProviderKind.google,
        AiProviderKind.ollama,
      ]) {
        final r = resolveKind(
          kind,
          model: AiModel(providerId: kind, modelId: 'm', reasoning: true),
        );
        expect(r.reasoning, isTrue, reason: kind);
      }
    });

    test('⭐ 用户没表态时按**模型能力**自动开推理', () {
      // 改造前这是档案上的一个布尔：把 deepseek-chat 换成 deepseek-reasoner
      // 之后开关还留着上一个模型的答案，不报错，只是从此每次都少发一个参数。
      const reasoningModel = AiCatalogModel(
        id: 'r',
        name: 'R',
        capabilities: {AiModelCapability.reasoning},
      );
      expect(
        resolveKind(
          AiProviderKind.anthropic,
          modelCatalog: reasoningModel,
        ).reasoning,
        isTrue,
      );
      expect(resolveKind(AiProviderKind.anthropic).reasoning, isFalse);
    });

    test('推理模型不发 temperature', () {
      final r = resolveKind(
        AiProviderKind.anthropic,
        model: const AiModel(
          providerId: 'a',
          modelId: 'm',
          reasoning: true,
          temperature: 0.7,
        ),
      );
      expect(r.temperature, isNull);
    });

    test('用户明确关掉「下发 temperature」时也不发', () {
      final r = resolveKind(
        AiProviderKind.openai,
        model: const AiModel(
          providerId: 'o',
          modelId: 'm',
          sendTemperature: false,
          temperature: 0.7,
        ),
      );
      expect(r.temperature, isNull);
    });

    test('⛔ 不支持自定义端点的几家：填了也不生效，且不当成配置错误', () {
      final r = resolveAiModel(
        provider: const AiProvider(
          id: 'a',
          kind: AiProviderKind.anthropic,
          baseUrl: 'https://填了也白填.example.com',
        ),
        model: const AiModel(providerId: 'a', modelId: 'm'),
      );
      expect(r.resolvedBaseUri(), isNull);
    });

    test('⛔ 少了 scheme 的地址要报错，不能当相对 URI 放行', () {
      final r = resolveAiModel(
        provider: const AiProvider(
          id: 'o',
          kind: AiProviderKind.openai,
          baseUrl: 'api.openai.com/v1',
        ),
        model: const AiModel(providerId: 'o', modelId: 'm'),
      );
      expect(r.resolvedBaseUri, throwsFormatException);
    });

    test('Ollama 不要密钥就算齐活', () {
      final r = resolveKind(AiProviderKind.ollama);
      expect(r.needsApiKey, isFalse);
      expect(r.isUsable, isTrue);
    });

    test('⛔ 空模型名是合法配置（用服务端默认），不该被判成没配好', () {
      final r = resolveAiModel(
        provider: const AiProvider(id: 'o', apiKey: 'sk-x'),
        model: const AiModel(providerId: 'o', modelId: ''),
      );
      expect(r.modelId, '');
      expect(r.isUsable, isTrue);
    });
  });

  group('maxTokens 的三种含义', () {
    AiResolvedModel resolve({
      String kind = AiProviderKind.openai,
      int? userMaxTokens,
      int? catalogMaxOutput,
    }) => resolveAiModel(
      provider: AiProvider(id: 'p', kind: kind),
      model: AiModel(providerId: 'p', modelId: 'm', maxTokens: userMaxTokens),
      modelCatalog: catalogMaxOutput == null
          ? null
          : AiCatalogModel(
              id: 'm',
              name: 'M',
              maxOutputTokens: catalogMaxOutput,
            ),
    );

    test('用户填了数 → 用它', () {
      expect(resolve(userMaxTokens: 8192).maxTokens, 8192);
    });

    test('⛔ 用户填 0 ＝「根本不发这个参数」，不是「上限是零」', () {
      expect(resolve(userMaxTokens: 0).maxTokens, isNull);
    });

    test('用户没填 → 跟目录', () {
      expect(resolve(catalogMaxOutput: 16384).maxTokens, 16384);
    });

    test('⛔ 都没有时只有 Anthropic 落兜底：它的 max_tokens 是必填的', () {
      expect(resolve().maxTokens, isNull);
      expect(
        resolve(kind: AiProviderKind.anthropic).maxTokens,
        AiDefaults.anthropicFallbackMaxTokens,
      );
    });
  });

  group('结构化输出要端点与模型都点头', () {
    AiResolvedModel resolve({bool? endpoint, Set<AiModelCapability>? caps}) =>
        resolveAiModel(
          provider: AiProvider(id: 'p', structuredOutput: endpoint),
          model: const AiModel(providerId: 'p', modelId: 'm'),
          modelCatalog: caps == null
              ? null
              : AiCatalogModel(id: 'm', name: 'M', capabilities: caps),
        );

    test('⛔ 端点没点头（未知）时不开：白等十几秒再降级', () {
      expect(resolve().structuredOutput, isFalse);
      expect(
        resolve(caps: {AiModelCapability.structuredOutput}).structuredOutput,
        isFalse,
      );
    });

    test('端点认、模型也会 → 开', () {
      expect(
        resolve(
          endpoint: true,
          caps: {AiModelCapability.structuredOutput},
        ).structuredOutput,
        isTrue,
      );
    });

    test('⛔ 端点认、但这个模型不会 → 不开', () {
      expect(resolve(endpoint: true, caps: const {}).structuredOutput, isFalse);
    });

    test('⭐ 目录压根没这个模型时不拿能力表当否决', () {
      // 中转上几百个模型目录多半没有，一律判成「不支持」会让所有人都走降级路。
      expect(resolve(endpoint: true).structuredOutput, isTrue);
    });
  });

  group('用途绑定与用量', () {
    test('绑定表 round-trip，坏数据当空', () {
      final encoded = AiTaskBindings.encode({
        AiTask.translate: 'p1/gpt-4o',
        AiTask.searchQuery: 'p2/claude',
      });
      expect(AiTaskBindings.decode(encoded), {
        AiTask.translate: 'p1/gpt-4o',
        AiTask.searchQuery: 'p2/claude',
      });
      expect(AiTaskBindings.decode('坏数据'), isEmpty);
      // 认不出来的用途名直接跳过，不连累其它条
      expect(AiTaskBindings.decode('{"nope":"p1","translate":"p2/m"}'), {
        AiTask.translate: 'p2/m',
      });
    });

    test('⛔ 用途的 wireName 不跟枚举名走：改名不该让用户的绑定失效', () {
      expect(AiTask.searchQuery.wireName, 'search_query');
      expect(AiTask.fromWireName('search_query'), AiTask.searchQuery);
    });

    test('模型的 key 就是绑定表里存的那个值', () {
      const m = AiModel(providerId: 'p1', modelId: 'gpt-4o');
      expect(m.key, 'p1/gpt-4o');
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
