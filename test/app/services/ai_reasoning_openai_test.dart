import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:i_iwara/app/services/ai_reasoning_openai.dart';
import 'package:i_iwara/app/utils/ai_json_extract.dart';
import 'package:i_iwara/app/utils/ai_think_tags.dart';

/// 一段 SSE：每个 delta 一行 `data:`，最后 `[DONE]`。
http.StreamedResponse _sse(
  List<Map<String, dynamic>> deltas, {
  String? finish,
}) {
  final lines = <String>[
    for (var i = 0; i < deltas.length; i++)
      'data: ${jsonEncode({
        'id': 'c1',
        'object': 'chat.completion.chunk',
        'created': 0,
        'model': 'm',
        'choices': [
          {'index': 0, 'delta': deltas[i], 'finish_reason': i == deltas.length - 1 ? finish : null},
        ],
      })}\n\n',
    'data: [DONE]\n\n',
  ];
  // 故意按字节切碎，验证跨 chunk 的行拼接。
  final bytes = utf8.encode(lines.join());
  final chunks = <List<int>>[
    for (var i = 0; i < bytes.length; i += 7)
      bytes.sublist(i, i + 7 > bytes.length ? bytes.length : i + 7),
  ];
  return http.StreamedResponse(
    Stream.fromIterable(chunks),
    200,
    headers: {'content-type': 'text/event-stream'},
  );
}

void main() {
  test('OpenAI 兼容端点：reasoning_content 接得出来，正文照旧，工具那轮把思考送回去', () async {
    final thinking = StringBuffer();
    final requests = <Map<String, dynamic>>[];

    final mock = MockClient.streaming((request, bodyStream) async {
      final body =
          jsonDecode(await utf8.decodeStream(bodyStream))
              as Map<String, dynamic>;
      requests.add(body);
      if (requests.length == 1) {
        return _sse([
          {'role': 'assistant', 'reasoning_content': '先查一下'},
          {'reasoning_content': '标签。'},
          {
            'tool_calls': [
              {
                'index': 0,
                'id': 'call_1',
                'type': 'function',
                'function': {'name': 'lookup', 'arguments': '{}'},
              },
            ],
          },
        ], finish: 'tool_calls');
      }
      return _sse([
        {'role': 'assistant', 'reasoning_content': '查到了。'},
        {'content': '初音'},
        {'content': 'ミク'},
      ], finish: 'stop');
    });

    final provider = ReasoningOpenAIProvider(
      apiKey: 'k',
      baseUrl: Uri.parse('https://example.invalid/v1'),
      onThinking: thinking.write,
      httpClient: () => mock,
    );
    final agent = Agent.forProvider(
      provider,
      chatModelName: 'm',
      tools: [
        Tool<Map<String, dynamic>>(
          name: 'lookup',
          description: 'd',
          inputSchema: Schema.fromMap({
            'type': 'object',
            'properties': <String, Object?>{},
          }),
          onCall: (_) async => {'ok': true},
        ),
      ],
    );

    final out = StringBuffer();
    await for (final chunk in agent.sendStream('hi')) {
      out.write(chunk.output);
    }

    // dartantic 在工具那轮之后接着出字时自己垫一个换行，与旁听无关。
    expect(out.toString().trim(), '初音ミク');
    expect(thinking.toString(), '先查一下标签。查到了。');
    expect(requests, hasLength(2));
    final assistant = (requests[1]['messages'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((m) => m['role'] == 'assistant');
    expect(assistant['reasoning_content'], '先查一下标签。');
    // 第一次请求没有可送回的思考，请求体原样。
    expect(
      (requests[0]['messages'] as List).any(
        (m) => (m as Map).containsKey('reasoning_content'),
      ),
      isFalse,
    );
  });

  group('ThinkTagSplitter', () {
    test('标签被切在两个 chunk 之间', () {
      final s = ThinkTagSplitter();
      final parts = ['<thi', 'nk>想一', '想</th', 'ink>答案', '<'];
      final visible = StringBuffer();
      final thought = StringBuffer();
      for (final p in parts) {
        final r = s.add(p);
        visible.write(r.visible);
        thought.write(r.thinking);
      }
      final r = s.close();
      visible.write(r.visible);
      thought.write(r.thinking);
      expect(thought.toString(), '想一想');
      expect(visible.toString(), '答案<');
    });

    test('没有标签原样返回', () {
      expect(splitThinkTags('{"a":1}').visible, '{"a":1}');
    });
  });

  test('答案被截断：不把里面某条筛选当成答案', () {
    const raw =
        '先说两句。\n{"segment":"video","query":"x","filters":[{"field":"rating","operator":"EQUALS","value":"ecchi"}';
    expect(extractJsonObject(raw), isNull);
  });

  test('先说话再交 JSON：话里的花括号不当答案', () {
    const raw =
        '用户要 {tags:[x]} 这种。还有一只落单的 { 括号。\n{"query":"\\"原神\\"","filters":[{"field":"tags"}]}';
    expect(extractJsonObject(raw), {
      'query': '"原神"',
      'filters': [
        {'field': 'tags'},
      ],
    });
  });
}
