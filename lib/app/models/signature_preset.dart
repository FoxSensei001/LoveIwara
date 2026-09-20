import 'package:i_iwara/app/models/signature_provider.model.dart';

/// 现成的数据源目录：点一下就能用的那几个一言 / 诗词接口。
///
/// ## 为什么要有这张表
///
/// 「接一个数据源」原本的第一步是一个空白的地址输入框——用户得自己去哪儿找一个
/// 一言接口、自己判断它返回什么、自己填进来。绝大多数人想要的其实只是**一句随机
/// 的话**，这件事不该从一个空输入框开始。
///
/// 表里每条都是 2026-09-20 实际请求验证过的，取值路径、出处字段、要不要剥 HTML
/// 都已经填好：用户点一下名字就完成了，剩下的选项都是可选的。
///
/// ⛔ 往表里加东西之前**必须真的请求一次**。写错的路径不会报错，只会让小尾巴
/// 那一段静默消失，而用户完全看不出是哪里的问题。
class SignaturePreset {
  const SignaturePreset({
    required this.id,
    required this.name,
    required this.url,
    this.path = '',
    this.suffixPath = '',
    this.stripHtml = true,
    this.options = const [],
  });

  /// 默认引用名。重名时由向导自动加后缀。
  final String id;

  /// 显示名。这里一律用来源方自己的名字（品牌名不翻译，和地址一样是事实）。
  final String name;

  final String url;

  /// 正文字段的取值路径，空串＝整个响应体。
  final String path;

  /// 出处 / 作者字段。非空时向导会给出「带上出处」开关，默认**不带**——
  /// 小尾巴本来就该短。
  final String suffixPath;

  final bool stripHtml;

  /// 这个接口支持的调节项。见 [SignaturePresetOption]。
  final List<SignaturePresetOption> options;

  /// 每个选项的默认选择（列表里的第一条）合成的参数表。
  Map<String, List<String>> get defaultParams => {
    for (final option in options)
      if (option.choices.first.values.isNotEmpty)
        option.key: option.choices.first.values,
  };

  SignatureProvider toProvider({
    required String id,
    Map<String, List<String>> params = const {},
    bool withSuffix = false,
  }) => SignatureProvider(
    id: id,
    name: name,
    url: url,
    path: path,
    stripHtml: stripHtml,
    presetId: this.id,
    params: params,
    suffixPath: withSuffix ? suffixPath : '',
  );

  static SignaturePreset? byId(String id) {
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  // --------------------------------------------------------------- 目录本体

  /// 一言。国内线路。JSON，正文在 `hitokoto`，出处在 `from`。
  static const SignaturePreset hitokoto = SignaturePreset(
    id: 'hitokoto',
    name: 'Hitokoto',
    url: 'https://v1.hitokoto.cn/',
    path: 'hitokoto',
    suffixPath: 'from',
    options: [_flavorOption, _lengthOption],
  );

  /// 一言的国际线路。同一个语料库，换一条出口——墙外网络上国内线路常常超时。
  static const SignaturePreset hitokotoIntl = SignaturePreset(
    id: 'hitokoto_intl',
    name: 'Hitokoto · International',
    url: 'https://international.v1.hitokoto.cn/',
    path: 'hitokoto',
    suffixPath: 'from',
    options: [_flavorOption, _lengthOption],
  );

  /// 今日诗词。正文嵌在 `data.content`，作者在 `data.origin.author`——
  /// 这种深路径正是「让用户自己填取值路径」最不可行的地方。
  static const SignaturePreset jinrishici = SignaturePreset(
    id: 'shici',
    name: '今日诗词',
    url: 'https://v2.jinrishici.com/one.json',
    path: 'data.content',
    suffixPath: 'data.origin.author',
  );

  /// 心游阁。语录 / 段子，作者在 `data.name`。
  static const SignaturePreset xygeng = SignaturePreset(
    id: 'yulu',
    name: '心游阁',
    url: 'https://api.xygeng.cn/one',
    path: 'data.content',
    suffixPath: 'data.name',
  );

  /// ⭐ 这一条默认返回的是 **HTML 片段**（`<p>……</p>`），不是 JSON。
  /// 留在表里既因为它本身好用，也因为它是「加工」那套机制的活样板。
  static const SignaturePreset aa1 = SignaturePreset(
    id: 'yiyan',
    name: '一言 · aa1',
    url: 'https://v.api.aa1.cn/api/yiyan/index.php',
  );

  static const List<SignaturePreset> all = [
    hitokoto,
    hitokotoIntl,
    jinrishici,
    xygeng,
    aa1,
  ];
}

/// 接口上的一个可调项。
///
/// ⭐ **暴露的是场景，不是参数**。一言官方有 12 个分类字母（a 动画、b 漫画、
/// c 游戏…），把它们原样摆成 12 个格子等于把 API 文档抄给用户看。这里只给
/// 「二次元 / 文学诗词 / 网络流行语」这种一眼能选的说法，每条在背后对应一组
/// 分类值——用户要做的判断从「我要哪几个字母」变成「我想看什么」。
class SignaturePresetOption {
  const SignaturePresetOption({
    required this.key,
    required this.labelKey,
    required this.choices,
  });

  /// 拼到地址上的查询参数名。
  final String key;

  /// 文案 key，由 UI 层翻成当前语言（模型层不碰 i18n）。
  final String labelKey;

  /// 单选。第一条是默认。
  final List<SignaturePresetChoice> choices;

  SignaturePresetChoice choiceFor(Map<String, List<String>> params) {
    final current = params[key] ?? const <String>[];
    for (final choice in choices) {
      if (choice.matches(current)) return choice;
    }
    return choices.first;
  }
}

class SignaturePresetChoice {
  const SignaturePresetChoice({required this.labelKey, this.values = const []});

  final String labelKey;

  /// 这条选择对应的参数值。多个值会拼成重复的查询参数（`c=a&c=b`，
  /// 一言就是这么收分类的）。空列表＝不带这个参数。
  final List<String> values;

  bool matches(List<String> current) {
    if (current.length != values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (current[i] != values[i]) return false;
    }
    return true;
  }
}

/// 一言的分类：a 动画 b 漫画 c 游戏 d 文学 e 原创 f 网络 g 其他 h 影视
/// i 诗词 j 网易云 k 哲学 l 抖机灵。
const SignaturePresetOption _flavorOption = SignaturePresetOption(
  key: 'c',
  labelKey: 'flavor',
  choices: [
    SignaturePresetChoice(labelKey: 'flavorAny'),
    SignaturePresetChoice(labelKey: 'flavorOtaku', values: ['a', 'b', 'c']),
    SignaturePresetChoice(labelKey: 'flavorLiterary', values: ['d', 'i']),
    SignaturePresetChoice(labelKey: 'flavorMeme', values: ['f', 'j', 'l']),
  ],
);

/// 小尾巴本来就该短，而一言里不乏三四十字的长句——截断了更难看。
const SignaturePresetOption _lengthOption = SignaturePresetOption(
  key: 'max_length',
  labelKey: 'length',
  choices: [
    SignaturePresetChoice(labelKey: 'lengthAny'),
    SignaturePresetChoice(labelKey: 'lengthShort', values: ['24']),
  ],
);
