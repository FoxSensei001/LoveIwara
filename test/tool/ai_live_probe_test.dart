// 真端点探针：拿一把真密钥把 [AiService] 的四条路各跑一遍。
//
// ⛔ **默认整只跳过**，没有 `AI_PROBE_KEY` 时不发任何请求——它是工具不是闸门，
// 不该在 `flutter test` 里烧别人的额度、也不该因为网络抖动把整套测试弄红。
//
// ⛔ 密钥只从环境变量来，**任何情况下都不要把它写进这个文件**。
//
// 用法：
//   AI_PROBE_KEY=sk-xxx \
//   AI_PROBE_BASE=https://your-relay/v1 \
//   AI_PROBE_MODEL=grok-4-fast \
//   flutter test test/tool/ai_live_probe_test.dart --reporter expanded
//
// 验的是：自定义端点的 Provider 构造 / 错误措辞装饰 / 流式失败降级两段原因
// 都在 / 结构化输出 / 没有 ConfigService 时记账不崩。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';

class _FixedStore implements AiProfileStore {
  _FixedStore(this.profile);
  final AiProviderProfile profile;
  @override
  List<AiProviderProfile> get profiles => [profile];
  @override
  AiProviderProfile? profileFor(AiTask task) => profile;
}

void main() {
  final key = Platform.environment['AI_PROBE_KEY'] ?? '';
  final base = Platform.environment['AI_PROBE_BASE'] ?? '';
  final model = Platform.environment['AI_PROBE_MODEL'] ?? '';

  test(
    'live probe',
    () async {
      final profile = AiProviderProfile(
        id: 'probe',
        name: 'relay',
        kind: AiProviderKind.openai,
        baseUrl: base,
        model: model,
        apiKey: key,
        structuredOutput: true,
        maxTokens: 256,
      );
      final ai = AiService(store: _FixedStore(profile));

      stdout.writeln('=== 1. listModels ===');
      final models = await ai.listModels(profile);
      if (models.isSuccess) {
        final list = models.data!;
        stdout.writeln('OK ${list.length} 个模型: $list');
      } else {
        stdout.writeln('FAIL -> ${models.message}');
      }

      stdout.writeln('\n=== 2. complete（带本域措辞装饰）===');
      final completed = await ai.complete(
        AiRequest(
          task: AiTask.translate,
          input: 'Hello, world',
          system:
              'Translate the user text into Simplified Chinese. Output only the translation.',
          decorateError: (r) => 'AI 翻译失败: $r（模拟 TranslationService 的装饰）',
          timeout: const Duration(seconds: 45),
        ),
      );
      stdout.writeln(
        completed.isSuccess
            ? 'OK -> ${completed.data}'
            : 'FAIL -> ${completed.message}',
      );

      stdout.writeln('\n=== 3. stream（失败会自动降级为 complete）===');
      final stream = ai.stream(
        AiRequest(
          task: AiTask.translate,
          input: 'Count from one to five in Japanese.',
          system: 'You are concise.',
          decorateError: (r) => 'AI 翻译失败: $r',
          streamErrorLabel: '流式翻译失败',
          timeout: const Duration(seconds: 45),
          timeoutMessage: '翻译请求超时',
        ),
      );
      if (stream == null) {
        stdout.writeln('stream() 返回 null（没有可用档案）');
      } else {
        var chunks = 0;
        String? last;
        try {
          await for (final v in stream) {
            chunks++;
            last = v;
          }
          stdout.writeln('OK $chunks 次推送，末帧: $last');
        } catch (e) {
          stdout.writeln('FAIL 收到 $chunks 次推送后报错 -> $e');
        }
      }

      stdout.writeln('\n=== 4. structured（AI 搜索要用的结构化输出）===');
      final structured = await ai.structured(
        AiRequest(
          task: AiTask.searchQuery,
          input: '找去年之后的初音未来 MMD 视频，按播放量排',
          system:
              'Fill the schema. segment must be one of: videos, images, users.',
          timeout: const Duration(seconds: 45),
        ),
        schema: S.object(
          properties: {
            'segment': S.string(description: 'content type'),
            'query': S.string(description: 'keywords'),
            'sort': S.string(description: 'one of date/relevance/views/likes'),
          },
          required: ['segment', 'query', 'sort'],
        ),
      );
      stdout.writeln(
        structured.isSuccess
            ? 'OK -> ${structured.data}'
            : 'FAIL -> ${structured.message}',
      );

      // structured 失败时，把模型**原样**吐了什么看清楚：是端点压根不认
      // json_schema（回一段带 ``` 围栏的文本），还是真的答非所问。两者的修法
      // 完全不同，光看 FormatException 分不出来。
      if (!structured.isSuccess) {
        stdout.writeln('\n=== 4b. 同一问题走纯文本，看原样返回 ===');
        final raw = await ai.complete(
          AiRequest(
            task: AiTask.searchQuery,
            input: '找去年之后的初音未来 MMD 视频，按播放量排',
            system:
                'Reply with ONLY a JSON object with keys segment, query, sort. '
                'No prose, no markdown fences.',
            timeout: const Duration(seconds: 45),
          ),
        );
        stdout.writeln(
          raw.isSuccess ? '原样返回 >>>${raw.data}<<<' : 'FAIL -> ${raw.message}',
        );
      }

      stdout.writeln('\n=== 5. 用量记账（无 ConfigService 也不该崩）===');
      stdout.writeln('translate: ${ai.usageOf(AiTask.translate).toJson()}');
      stdout.writeln('searchQuery: ${ai.usageOf(AiTask.searchQuery).toJson()}');
    },
    timeout: const Timeout(Duration(minutes: 4)),
    skip: key.isEmpty ? '没有 AI_PROBE_KEY，跳过真端点探针（见文件头用法）' : null,
  );
}
