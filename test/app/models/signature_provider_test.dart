import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/signature_preset.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';

/// 数据源向导第二步给用户看的那张候选列表全由 [flattenResponseCandidates] 产出。
/// 它决定了「取值路径」这个概念能不能对用户彻底隐形——摊错了，用户就只能回到
/// 自己拼点号路径的老路上去。
void main() {
  group('把响应摊成候选项', () {
    test('不是 JSON 就只给一条「整段内容」', () {
      final out = flattenResponseCandidates('  今天也要加油  ');
      expect(out.length, 1);
      expect(out.first.path, '');
      expect(out.first.value, '今天也要加油');
    });

    test('顶层是个裸字符串的 JSON 同样算整段', () {
      final out = flattenResponseCandidates('"就这一句"');
      expect(out.length, 1);
      expect(out.first.path, '');
      expect(out.first.value, '就这一句');
    });

    test('一言的真实返回：能摊出 hitokoto 那条', () {
      const body =
          '{"id":689,"uuid":"e74a8578","hitokoto":"要邃晓你的处境，凡人！",'
          '"type":"c","from":"奥妮克希亚","from_who":null,"length":11}';
      final out = flattenResponseCandidates(body);
      final picked = out.firstWhere((e) => e.path == 'hitokoto');
      expect(picked.value, '要邃晓你的处境，凡人！');
      // null 不是候选（选了它小尾巴就永远是空的）
      expect(out.any((e) => e.path == 'from_who'), isFalse);
      // 数字照收：有人的接口把想要的东西放在数字字段里
      expect(out.any((e) => e.path == 'length' && e.value == '11'), isTrue);
    });

    test('数组用下标，嵌套用点号', () {
      const body = '{"data":[{"text":"第一句"},{"text":"第二句"}]}';
      final out = flattenResponseCandidates(body);
      expect(out.map((e) => e.path), ['data.0.text', 'data.1.text']);
      expect(out.first.value, '第一句');
    });

    test('空字符串字段不进候选：选了等于没选', () {
      final out = flattenResponseCandidates('{"a":"","b":"有货"}');
      expect(out.map((e) => e.path), ['b']);
    });

    test('条数封顶，免得一个巨大的返回把这张表撑爆', () {
      final body = '{${List.generate(200, (i) => '"k$i":"v$i"').join(',')}}';
      expect(flattenResponseCandidates(body, maxEntries: 10).length, 10);
    });
  });

  group('取到值之后的加工', () {
    const bare = SignatureProvider(id: 'x', name: '', url: 'https://x.y');

    test('实测的 HTML 片段接口：标签剥干净', () {
      // v.api.aa1.cn/api/yiyan 默认就返回这个形状
      expect(
        bare.applyTransform('<p>你，可以流血流汗，但是，你没有流泪的权利。</p>'),
        '你，可以流血流汗，但是，你没有流泪的权利。',
      );
    });

    test('实体与 <br> 一并处理', () {
      expect(
        bare.applyTransform('第一句<br/>第二句&nbsp;&amp;&#39;结尾&#x3002;'),
        "第一句 第二句 &'结尾。",
      );
    });

    test('⛔ 正文里的 <3 和 a < b 不许被当成标签吃掉', () {
      expect(bare.applyTransform('我 <3 你'), '我 <3 你');
      expect(bare.applyTransform('a < b 且 b > c'), 'a < b 且 b > c');
    });

    test('关掉开关就一个字都不动', () {
      const raw = '<p>原样</p>';
      expect(bare.copyWith(stripHtml: false).applyTransform(raw), raw);
    });

    test('提取规则取第一个捕获组', () {
      final p = bare.copyWith(extract: r'「(.+?)」');
      expect(p.applyTransform('今日一言「知足常乐」——某某'), '知足常乐');
    });

    test('没有捕获组就取整个匹配', () {
      expect(bare.copyWith(extract: r'\d+').applyTransform('编号 42 号'), '42');
    });

    test('⛔ 规则没匹配上就保持原样，不能发出去一片空白', () {
      final p = bare.copyWith(extract: r'「(.+?)」');
      expect(p.applyTransform('<p>没有书名号的一句话</p>'), '没有书名号的一句话');
    });

    test('⛔ 正则本身写错也不许炸：当没写过', () {
      final p = bare.copyWith(extract: r'([');
      expect(p.applyTransform('照常发出去'), '照常发出去');
    });
  });

  group('JSONP', () {
    test('剥掉外层函数调用后照样摊得开', () {
      final out = flattenResponseCandidates('cb({"hitokoto":"喝水"});');
      expect(out.single.path, 'hitokoto');
      expect(out.single.value, '喝水');
    });

    test('不是 JSONP 的原样放过', () {
      expect(unwrapJsonp('就是一句话'), '就是一句话');
      expect(unwrapJsonp('{"a":1}'), '{"a":1}');
    });
  });

  group('引用名规整', () {
    test('空格与符号收成下划线，首尾不留', () {
      expect(
        SignatureProvider.normalizeId('  My Weather API '),
        'my_weather_api',
      );
      expect(SignatureProvider.normalizeId('天气'), '');
      expect(SignatureProvider.normalizeId('a--b'), 'a_b');
    });
  });

  group('从地址猜引用名', () {
    test('去掉没有信息量的段', () {
      expect(
        SignatureProvider.suggestIdFromUrl('https://v1.hitokoto.cn/'),
        'hitokoto',
      );
      expect(
        SignatureProvider.suggestIdFromUrl('https://api.weather.com/now'),
        'weather',
      );
    });

    test('⛔ 中文名字推不出 id 时的兜底：不能把空白丢给用户', () {
      expect(SignatureProvider.normalizeId('天气'), '');
      expect(
        SignatureProvider.suggestIdFromUrl('https://tianqi.example.com/x'),
        'tianqi',
      );
    });
  });

  group('按路径取值', () {
    const body =
        '{"code":200,"data":[{"text":"第一句","who":"甲"},'
        '{"text":"第二句","who":"乙"}],"ok":true}';

    test('点号进对象、下标进数组', () {
      expect(pluckPath(body, 'data.1.text'), '第二句');
      expect(pluckPath(body, 'code'), '200');
      expect(pluckPath(body, 'ok'), 'true');
    });

    test('空路径＝整份响应体（极简接口直接回一行文本）', () {
      expect(pluckPath('  就这一句  ', ''), '就这一句');
    });

    test('取不到就是 null，不许抛', () {
      expect(pluckPath(body, 'data.9.text'), isNull);
      expect(pluckPath(body, 'nope'), isNull);
      expect(pluckPath(body, 'data'), isNull); // 数组本身不是「一句话」
    });

    test('⛔ 说好取字段、人家却回了 HTML：要抛，不能把整份 HTML 发出去', () {
      expect(
        () => pluckPath('<p>一句话</p>', 'data.text'),
        throwsA(isA<FormatException>()),
      );
    });

    test('* 每次随机取一条，且只在数组范围内', () {
      final seen = <String>{};
      for (var i = 0; i < 40; i++) {
        final v = pluckPath(body, 'data.*.text');
        expect(v, isNotNull);
        seen.add(v!);
      }
      expect(seen, containsAll(<String>['第一句', '第二句']));
      expect(seen.length, 2);
    });

    test('randomizePath 只换下标，字段名不动', () {
      expect(randomizePath('data.0.text'), 'data.*.text');
      expect(randomizePath('hitokoto'), 'hitokoto');
    });

    test('JSONP 包着也照样按路径取', () {
      expect(pluckPath('cb({"a":{"b":"值"}});', 'a.b'), '值');
    });
  });

  group('参数拼进地址', () {
    const bare = SignatureProvider(id: 'x', name: '', url: 'https://x.y/api');

    test('一个键多个值＝重复的查询参数（一言的分类就这么收）', () {
      final uri = bare
          .copyWith(
            params: {
              'c': ['a', 'b'],
            },
          )
          .resolvedUri();
      expect(uri.queryParametersAll['c'], ['a', 'b']);
    });

    test('地址自带的查询串保留，同名的由选项顶掉', () {
      final uri = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y/api?type=json&c=z',
        params: const {
          'c': ['a'],
        },
      ).resolvedUri();
      expect(uri.queryParameters['type'], 'json');
      expect(uri.queryParametersAll['c'], ['a']);
    });

    test('空值＝去掉这个参数（「不限」就是什么都不带）', () {
      final uri = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y/api?c=a',
        params: const {'c': []},
      ).resolvedUri();
      expect(uri.queryParameters.containsKey('c'), isFalse);
    });

    test('⛔ 地址不合法要抛，不能静默当成取不到', () {
      expect(
        () => bare.copyWith(url: '随便打的').resolvedUri(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('正文 + 出处', () {
    const body = '{"hitokoto":"要邃晓你的处境，凡人！","from":"奥妮克希亚","from_who":null}';

    test('拼成一句', () {
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'hitokoto',
        suffixPath: 'from',
      );
      expect(p.composeValue(body), '要邃晓你的处境，凡人！ —— 奥妮克希亚');
    });

    test('不开出处就只有正文', () {
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'hitokoto',
      );
      expect(p.composeValue(body), '要邃晓你的处境，凡人！');
    });

    test('⛔ 出处取不到（from_who 常是 null）不许留下悬空的破折号', () {
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'hitokoto',
        suffixPath: 'from_who',
      );
      expect(p.composeValue(body), '要邃晓你的处境，凡人！');
    });

    test('⛔ 正文自带署名就别再接一遍', () {
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'a',
        suffixPath: 'b',
      );
      expect(
        p.composeValue('{"a":"能力越大，责任越大——蜘蛛侠","b":"蜘蛛侠"}'),
        '能力越大，责任越大——蜘蛛侠',
      );
    });

    test('⛔ 但出处只是正文里的一个词时照接不误（判重只看结尾）', () {
      // 一言的 from 是作品名，常常就出现在句子中间——用 contains 判重会把
      // 这一类出处整个吞掉。
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'a',
        suffixPath: 'b',
      );
      expect(
        p.composeValue('{"a":"难舍，难分，难解，缘起，缘浅，缘灭。","b":"难解"}'),
        '难舍，难分，难解，缘起，缘浅，缘灭。 —— 难解',
      );
    });

    test('正文空了就整段没有（宁可小尾巴少一句，也别发个破折号）', () {
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'nope',
        suffixPath: 'from',
      );
      expect(p.composeValue(body), '');
    });

    test('提取规则只管正文，不套到出处上', () {
      const p = SignatureProvider(
        id: 'x',
        name: '',
        url: 'https://x.y',
        path: 'a',
        suffixPath: 'b',
        extract: r'「(.+?)」',
      );
      expect(p.composeValue('{"a":"今日一言「知足常乐」","b":"某某"}'), '知足常乐 —— 某某');
    });
  });

  // 目录里每一条的取值路径都是照着**真实返回**写的。路径写错不会报错，只会让
  // 小尾巴那一段静默消失——所以这里把当时那几份返回原样钉下来。
  group('预置源对得上真实返回', () {
    SignatureProvider providerOf(
      SignaturePreset preset, {
      bool origin = false,
    }) => preset.toProvider(id: preset.id, withSuffix: origin);

    test('一言（国内 / 国际是同一份形状）', () {
      const body =
          '{"id":10754,"uuid":"615c6e0c","hitokoto":"从前车马很慢，书信很远，一生只够爱一个人。",'
          '"type":"d","from":"从前慢","from_who":"木心","length":21}';
      expect(
        providerOf(SignaturePreset.hitokoto).composeValue(body),
        '从前车马很慢，书信很远，一生只够爱一个人。',
      );
      expect(
        providerOf(SignaturePreset.hitokoto, origin: true).composeValue(body),
        '从前车马很慢，书信很远，一生只够爱一个人。 —— 从前慢',
      );
      expect(SignaturePreset.hitokotoIntl.path, SignaturePreset.hitokoto.path);
    });

    test('今日诗词：正文嵌在 data.content，作者还要再往里一层', () {
      const body =
          '{"status":"success","data":{"id":"5b8b","content":"春风又绿江南岸，明月何时照我还？",'
          '"origin":{"title":"泊船瓜洲","dynasty":"宋代","author":"王安石",'
          '"content":["京口瓜洲一水间，钟山只隔数重山。"],"translate":null}},"token":"7hm3"}';
      expect(
        providerOf(SignaturePreset.jinrishici, origin: true).composeValue(body),
        '春风又绿江南岸，明月何时照我还？ —— 王安石',
      );
    });

    test('心游阁：正文里的换行由 sanitizeValue 收拾，这里只管取对字段', () {
      const body =
          '{"code":200,"data":{"id":2421,"tag":"时间简史","name":"佚名",'
          '"content":"你发明了时光机。","created_at":"2018-12-30T12:48:49.000Z"},"error":null}';
      expect(
        providerOf(SignaturePreset.xygeng, origin: true).composeValue(body),
        '你发明了时光机。 —— 佚名',
      );
    });

    test('⛔ aa1 默认返回的是 HTML 片段，不是 JSON', () {
      expect(
        providerOf(SignaturePreset.aa1).composeValue('<p>能力越大，责任越大。</p>'),
        '能力越大，责任越大。',
      );
      // 取值路径必须留空：给它配个字段路径，pluckPath 会当场抛
      expect(SignaturePreset.aa1.path, '');
    });

    test('每条预置源的地址都是能解析的绝对地址', () {
      for (final preset in SignaturePreset.all) {
        final uri = preset.toProvider(id: preset.id).resolvedUri();
        expect(uri.scheme, 'https', reason: preset.name);
        expect(uri.host, isNotEmpty, reason: preset.name);
      }
    });
  });

  group('预置源的选项', () {
    test('默认是每个选项的第一条，且第一条一律「不限」（不带参数）', () {
      expect(SignaturePreset.hitokoto.defaultParams, isEmpty);
      for (final option in SignaturePreset.hitokoto.options) {
        expect(option.choices.first.values, isEmpty, reason: option.key);
      }
    });

    test('选中的那条能从参数表里认回来', () {
      final option = SignaturePreset.hitokoto.options.first;
      final literary = option.choices[2];
      final provider = SignaturePreset.hitokoto.toProvider(
        id: 'hitokoto',
        params: {option.key: literary.values},
      );
      expect(option.choiceFor(provider.params), same(literary));
      // 认不出来的参数（用户手改过配置）退回第一条，不是崩
      expect(
        option.choiceFor({
          'c': ['zzz'],
        }),
        same(option.choices.first),
      );
    });
  });

  group('存盘', () {
    test('⛔ 内置源不写进配置：它由代码提供，存一份就会在改版时变成幽灵', () {
      final encoded = SignatureProvider.encodeList([
        SignatureProvider.hitokoto,
        const SignatureProvider(
          id: 'mine',
          name: '我的',
          url: 'https://x.y',
          stripHtml: false,
          extract: r'「(.+?)」',
        ),
      ]);
      final back = SignatureProvider.decodeList(encoded);
      expect(back.map((e) => e.id), ['mine']);
      // 加工配置要跟着存盘走，不然重进设置页就丢了
      expect(back.single.stripHtml, isFalse);
      expect(back.single.extract, r'「(.+?)」');
    });

    test('参数 / 预置出身 / 出处字段都要往返得回来', () {
      final encoded = SignatureProvider.encodeList([
        SignaturePreset.hitokoto.toProvider(
          id: 'hitokoto',
          params: {
            'c': ['d', 'i'],
            'max_length': ['24'],
          },
          withSuffix: true,
        ),
      ]);
      final back = SignatureProvider.decodeList(encoded).single;
      expect(back.presetId, 'hitokoto');
      expect(back.params['c'], ['d', 'i']);
      expect(back.suffixPath, 'from');
      expect(back.resolvedUri().queryParametersAll['c'], ['d', 'i']);
    });

    test('坏数据当成空列表，不让小尾巴配置把发评论搞崩', () {
      expect(SignatureProvider.decodeList('{不是 json'), isEmpty);
      expect(SignatureProvider.decodeList('[{"id":"x"}]'), isEmpty);
    });
  });
}
