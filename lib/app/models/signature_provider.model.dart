import 'dart:convert';
import 'dart:math';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 一个小尾巴**数据源**：一个会返回一句话的地址，加上「从返回里取哪一段」。
///
/// ⭐ 一言不是特例，它只是一个**预置**的数据源（[SignatureProvider.hitokoto]）。
/// 内置和自定义走同一条求值管线、在设置页同一张列表里、用同样的方式被模板
/// 引用——用户只需要理解「数据源」这一个概念。
class SignatureProvider {
  const SignatureProvider({
    required this.id,
    required this.name,
    required this.url,
    this.path = '',
    this.stripHtml = true,
    this.extract = '',
    this.builtin = false,
    this.presetId = '',
    this.params = const {},
    this.suffixPath = '',
    this.kind = kindHttp,
    this.prompt = '',
  });

  static const String kindHttp = 'http';
  static const String kindAi = 'ai';

  /// 模板里怎么引用它：直接写 `{id}`。
  ///
  /// 限定成小写字母数字下划线（见 [normalizeId]）：它要进模板语法，带空格或
  /// 花括号会把解析搅乱。另外不许与内置变量重名，那一条在设置页校验。
  final String id;

  /// 给人看的名字，出现在设置页列表和变量选择面板里。
  final String name;

  final String url;

  /// 从返回的 JSON 里取值的路径，点号分隔，数组用下标：`data.0.text`。
  ///
  /// 留空表示「整个响应体就是那句话」——很多极简接口直接返回一行纯文本。
  /// 下标位置写 `*` 表示**每次随机取一条**（见 [pluckPath]）。
  final String path;

  /// 这条数据源是从哪个预置项来的（`SignaturePreset.id`），自定义的是空串。
  ///
  /// 存下来是为了让设置页和向导知道「它还有哪些可调项」——同一个一言接口，
  /// 换个口味不该让用户重新走一遍接入流程。
  final String presetId;

  /// 拼到地址上的查询参数。一个键可以有多个值（一言的分类就是 `c=a&c=b`）。
  ///
  /// ⛔ 不做成「键值对编辑器」：那是把 API 文档摊给用户看。这张表只由预置项的
  /// **选项**产出（`SignaturePresetOption`），自定义源想带参数直接写进地址里。
  final Map<String, List<String>> params;

  /// 出处 / 作者字段的取值路径，空串＝不带。
  ///
  /// 一言这类接口几乎都是「正文一个字段、出处另一个字段」，而用户想要的往往是
  /// 拼在一起的那一句。取不到或与正文重复时自动省略，不会留下一个孤零零的破折号。
  final String suffixPath;

  /// 取到值之后去掉 HTML 标签与实体。
  ///
  /// 默认开：一言这类接口里相当一部分直接吐 `<p>……</p>`（实测
  /// `v.api.aa1.cn/api/yiyan` 就是），原样接进小尾巴会把标签一起发出去。
  /// 剥标签的正则只认 `<字母…>` 这种形状，所以正文里的 `<3` 不会被误伤。
  final bool stripHtml;

  /// 可选的提取规则：一条正则，取第一个捕获组（没有捕获组就取整个匹配）。
  ///
  /// 给那些「返回里混着不想要的东西」的接口留的出口——比如固定前缀、
  /// 或者一句话后面跟着出处。留空就是不提取。
  final String extract;

  /// 应用预置的源。不可删、地址与取值路径不可改（改坏了用户会以为是应用的
  /// bug），但和自定义源一样可以测试、可以被模板引用。
  final bool builtin;

  /// 数据源种类：[kindHttp]（默认，请求 HTTP 接口）或 [kindAi]（由 AI 生成）。
  final String kind;

  /// [kindAi] 专用：用户改过的提示词，空串＝用出厂那份
  /// （`SignatureAiPrompt.defaultTemplate`）。
  ///
  /// ⭐ 里面可以写 `{language}`，求值时换成当前界面语言的英文名——和小尾巴
  /// 模板同一套花括号语法，用户不必再学第二种写法。
  ///
  /// ⛔ 存空串而不是把默认那份抄进来：抄进去之后我们再改默认提示词，
  /// 老用户永远停在旧版上，而他根本不知道自己"改过"。
  final String prompt;

  bool get isAi => kind == kindAi;

  /// 显示给用户看的名称。
  ///
  /// 内置的 AI 源文案随当前界面语言切换，其余返回配置里存的 [name]。
  String get displayName =>
      isAi ? slang.t.settings.signatureAiSourceName : name;

  /// 预置的一言。
  ///
  /// 取 `hitokoto` 字段而不是整个响应体：那个接口返回的是一坨带 id / 作者 /
  /// 时间戳的 JSON。
  ///
  /// 挂着 [presetId] 是为了让它**可调**：点「编辑」会落在一言自己的调节屏上
  /// （换口味、带出处），保存后作为同名的自定义源顶掉这一条，模板里的
  /// `{hitokoto}` 不用动。
  static const SignatureProvider hitokoto = SignatureProvider(
    id: 'hitokoto',
    name: 'Hitokoto',
    url: 'https://v1.hitokoto.cn/',
    path: 'hitokoto',
    builtin: true,
    presetId: 'hitokoto',
  );

  /// AI 写的一句话。⛔ 只在 AI 可用时才进 [SignatureService.providers]。
  static const SignatureProvider aiHitokoto = SignatureProvider(
    id: 'ai_hitokoto',
    name: 'AI', // 显示名由 i18n 现算，见 [displayName]
    url: '', // AI 源不请求地址
    kind: kindAi,
    builtin: true,
  );

  /// 所有预置源。设置页把它们排在自定义源前面。
  static const List<SignatureProvider> builtins = [hitokoto];

  static final RegExp _idPattern = RegExp(r'[^a-z0-9_]');

  /// 把用户随手打的名字收成合法 id。收不出东西就返回空串，由调用方拒绝。
  static String normalizeId(String raw) => raw
      .trim()
      .toLowerCase()
      .replaceAll(_idPattern, '_')
      .replaceAll(RegExp(r'_{2,}'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  /// 从地址猜一个像样的引用名。
  ///
  /// ⛔ 存在的理由：`normalizeId` 只保留 ASCII，于是一个叫「天气」的源推出来是
  /// 空串——中文用户按名字推导必然落空，只会看到一句「引用名只能用小写字母」
  /// 而不知道该填什么。从域名猜一个总比把空白丢给他好。
  ///
  /// 去掉 www / api / vN 这类没有信息量的段：`v1.hitokoto.cn` → `hitokoto`，
  /// `api.weather.com` → `weather`。
  static String suggestIdFromUrl(String url) {
    final host = Uri.tryParse(url.trim())?.host ?? '';
    if (host.isEmpty) return '';
    final noise = RegExp(r'^(www|api|v\d+)$');
    final parts = host
        .split('.')
        .where((p) => p.isNotEmpty && !noise.hasMatch(p))
        .toList();
    if (parts.isEmpty) return normalizeId(host);
    // 最后一段通常是 com / cn 这类后缀，能去就去
    final meaningful = parts.length > 1 ? parts.first : parts.single;
    return normalizeId(meaningful);
  }

  SignatureProvider copyWith({
    String? id,
    String? name,
    String? url,
    String? path,
    bool? stripHtml,
    String? extract,
    String? presetId,
    Map<String, List<String>>? params,
    String? suffixPath,
    String? kind,
    String? prompt,
  }) => SignatureProvider(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    path: path ?? this.path,
    stripHtml: stripHtml ?? this.stripHtml,
    extract: extract ?? this.extract,
    builtin: builtin,
    presetId: presetId ?? this.presetId,
    params: params ?? this.params,
    suffixPath: suffixPath ?? this.suffixPath,
    kind: kind ?? this.kind,
    prompt: prompt ?? this.prompt,
  );

  /// 真正要请求的地址：基础地址 + [params]。
  ///
  /// 地址自己带的查询串保留，同名的键由 [params] 覆盖（选项是后说的算）。
  /// 地址不合法时抛 [FormatException]——这是配置错了，不该静默当成取不到。
  Uri resolvedUri() {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw FormatException('地址不合法：$url');
    }
    if (params.isEmpty) return uri;

    final merged = <String, List<String>>{...uri.queryParametersAll};
    params.forEach((key, values) {
      if (values.isEmpty) {
        merged.remove(key);
      } else {
        merged[key] = values;
      }
    });
    if (merged.isNotEmpty) return uri.replace(queryParameters: merged);

    // ⛔ 这里不能写 `replace(queryParameters: null)`：null 对 replace 是
    // 「这一项不动」，原来的查询串会原样留着——选了「不限」却还带着上一次的
    // 分类，而且一路上没有任何迹象。只能把地址重搭一遍。
    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
  }

  /// 从一整份响应里拼出最终那句话：正文 + （可选的）出处。
  ///
  /// ⭐ 求值、设置页的测试钮、向导里的样例全走这一个方法。三处各写一遍的话，
  /// 「向导里看着好好的、发出去却不是那样」这种问题会查到天亮。
  String composeValue(String body) {
    final main = applyTransform(pluckPath(body, path) ?? '');
    if (main.isEmpty) return '';
    if (suffixPath.trim().isEmpty) return main;

    final suffix = applyTransform(
      pluckPath(body, suffixPath) ?? '',
      applyExtract: false,
    );
    // 取不到出处（`from_who` 经常是 null）就别接，不然会留下一个悬空的破折号。
    //
    // ⛔ 判重只看**结尾**，不能用 `contains`：一言的 `from` 是作品名，常常
    // 是句子里的一个词（「难舍，难分，难解……」出自《难解》），用 contains
    // 会把这类出处整个吞掉。真正要防的是「正文自带署名」那种（一批接口直接
    // 回「……——蜘蛛侠」），而署名总在末尾。
    if (suffix.isEmpty || main.endsWith(suffix)) return main;
    return '$main$valueJoiner$suffix';
  }

  /// 正文与出处之间的连接符。一言的惯例写法，不做成可配置项。
  static const String valueJoiner = ' —— ';

  /// 把取到的原始值加工成真正要写进小尾巴的那句话。
  ///
  /// 顺序是刻意的：先剥标签再提取。用户写提取规则时对着的是**剥干净之后**的
  /// 文本（向导里那一栏实时显示的就是它），两边不一致的话他写出来的正则在真
  /// 发送时会落空。
  ///
  /// [applyExtract] 为 false 时只剥标签：提取规则是给正文写的，拿它去套出处
  /// 字段（作者名）基本都会落空。
  String applyTransform(String raw, {bool applyExtract = true}) {
    var text = raw;
    if (stripHtml) text = stripHtmlFrom(text);

    final pattern = applyExtract ? extract.trim() : '';
    if (pattern.isNotEmpty) {
      try {
        final match = RegExp(pattern).firstMatch(text);
        if (match != null) {
          text =
              (match.groupCount >= 1 ? match.group(1) : match.group(0)) ?? '';
        }
        // 匹配不上就保持原样：提取规则写错时宁可发一句没加工的，也别发空白。
      } on FormatException {
        // 正则本身非法，当没写过
      }
    }
    return text.trim();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'path': path,
    'stripHtml': stripHtml,
    'extract': extract,
    if (presetId.isNotEmpty) 'presetId': presetId,
    if (params.isNotEmpty) 'params': params,
    if (suffixPath.isNotEmpty) 'suffixPath': suffixPath,
    if (kind != kindHttp) 'kind': kind,
    if (prompt.isNotEmpty) 'prompt': prompt,
  };

  factory SignatureProvider.fromJson(Map<String, dynamic> json) =>
      SignatureProvider(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
        path: (json['path'] as String?) ?? '',
        stripHtml: (json['stripHtml'] as bool?) ?? true,
        extract: (json['extract'] as String?) ?? '',
        presetId: (json['presetId'] as String?) ?? '',
        params: _paramsFromJson(json['params']),
        suffixPath: (json['suffixPath'] as String?) ?? '',
        kind: (json['kind'] as String?) == kindAi ? kindAi : kindHttp,
        prompt: (json['prompt'] as String?) ?? '',
      );

  static Map<String, List<String>> _paramsFromJson(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, List<String>>{};
    raw.forEach((key, value) {
      if (key is! String) return;
      if (value is List) {
        final values = value.map((e) => e.toString()).toList();
        if (values.isNotEmpty) out[key] = values;
      } else if (value != null) {
        // 早期写法 / 手改过的配置：单个值也收下，别整条参数丢掉
        out[key] = [value.toString()];
      }
    });
    return out;
  }

  /// 从配置里存的那串 JSON 解出列表。坏数据一律当成空列表——小尾巴配置坏掉
  /// 不该让发评论这件事报错。
  static List<SignatureProvider> decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => SignatureProvider.fromJson(e.cast<String, dynamic>()))
          // ⛔ 「没有地址就是坏数据」对 AI 源不成立——它根本不请求地址。
          // 漏掉这一条的后果是：用户改完提示词、当场生效，下次启动静默变回
          // 默认，而配置文件里那条一直好好地躺着。
          .where((e) => e.id.isNotEmpty && (e.url.isNotEmpty || e.isAi))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static String encodeList(List<SignatureProvider> providers) => jsonEncode(
    providers.where((e) => !e.builtin).map((e) => e.toJson()).toList(),
  );
}

final Random _pluckRandom = Random();

/// 按点号路径从一份响应里取值。
///
/// - 空路径＝整个响应体（很多极简接口直接回一行文本）；
/// - 数组用下标：`data.0.text`；
/// - 下标位置写 `*` 就**每次随机取一条**——一批接口一次返回十几条，固定取第 0
///   条会让「随机一句话」变成同一句话。向导发现候选里有平行的下标时会把这个
///   开关摆出来。
///
/// 说好了要取某个字段、结果人家返回的根本不是 JSON 时抛 [FormatException]：
/// 那是配置错了，不能把整份 HTML 当成小尾巴发出去。
String? pluckPath(String body, String path) {
  final trimmedBody = body.trim();
  final trimmedPath = path.trim();
  if (trimmedPath.isEmpty) return trimmedBody;
  if (trimmedBody.isEmpty) return null;

  dynamic node;
  try {
    node = jsonDecode(unwrapJsonp(trimmedBody));
  } catch (_) {
    throw const FormatException('返回的不是 JSON');
  }

  for (final segment in trimmedPath.split('.')) {
    if (segment.isEmpty) continue;
    if (node is List) {
      if (node.isEmpty) return null;
      if (segment == '*') {
        node = node[_pluckRandom.nextInt(node.length)];
        continue;
      }
      final index = int.tryParse(segment);
      if (index == null || index < 0 || index >= node.length) return null;
      node = node[index];
    } else if (node is Map) {
      if (!node.containsKey(segment)) return null;
      node = node[segment];
    } else {
      return null;
    }
  }

  if (node == null) return null;
  if (node is String) return node;
  if (node is num || node is bool) return node.toString();
  return null;
}

/// 把路径里的数组下标换成 `*`（＝每次随机取一条）。`data.0.text` → `data.*.text`。
String randomizePath(String path) =>
    path.split('.').map((e) => int.tryParse(e) == null ? e : '*').join('.');

/// 一个接口返回里、**可能就是那句话**的候选字段。
///
/// 数据源向导把返回的 JSON 摊成这样一张列表让用户点选：他看见的是真实的值，
/// 选完我们才在背后把 [path] 记下来。用户全程不需要知道「取值路径」是什么。
class SignatureValueCandidate {
  const SignatureValueCandidate({required this.path, required this.value});

  /// 点号路径，空串表示「整个响应体」。
  final String path;

  final String value;
}

/// 把一坨响应摊成候选字段列表。
///
/// 不是 JSON（很多极简接口直接回一行纯文本）就只给一条「整段内容」。
/// 只收**字符串与数字**的叶子：对象和数组本身不可能是「一句话」，把它们列出来
/// 只会让这张表长到没法看。
List<SignatureValueCandidate> flattenResponseCandidates(
  String body, {
  int maxEntries = 60,
  int maxDepth = 6,
}) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return const [];

  // JSONP（`cb({...})`）先剥掉外层的函数调用，里头是正常 JSON。
  final unwrapped = unwrapJsonp(trimmed);

  dynamic decoded;
  try {
    decoded = jsonDecode(unwrapped);
  } catch (_) {
    // 不是 JSON：HTML 片段、纯文本都走这条，整段就是唯一候选。
    return [SignatureValueCandidate(path: '', value: trimmed)];
  }

  // 顶层就是一个裸字符串 / 数字的情况：整段就是答案。
  if (decoded is String || decoded is num || decoded is bool) {
    return [SignatureValueCandidate(path: '', value: decoded.toString())];
  }

  final out = <SignatureValueCandidate>[];

  void walk(dynamic node, String path, int depth) {
    if (out.length >= maxEntries || depth > maxDepth) return;

    if (node is String) {
      if (node.trim().isNotEmpty) {
        out.add(SignatureValueCandidate(path: path, value: node.trim()));
      }
      return;
    }
    if (node is num || node is bool) {
      out.add(SignatureValueCandidate(path: path, value: node.toString()));
      return;
    }
    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key;
        if (key is! String) continue;
        walk(entry.value, path.isEmpty ? key : '$path.$key', depth + 1);
      }
      return;
    }
    if (node is List) {
      for (var i = 0; i < node.length; i++) {
        walk(node[i], path.isEmpty ? '$i' : '$path.$i', depth + 1);
      }
    }
  }

  walk(decoded, '', 0);
  return out;
}

/// HTML 标签：`<p>` `</p>` `<br/>` `<a href="x">` 这类。
///
/// ⛔ 标签名必须**紧跟** `<` 或 `</`，中间一个空格都不许有。写成
/// `<\s*/?\s*[a-zA-Z]…>` 的话，正文里的「`a < b 且 b > c`」会被整段当成一个
/// 标签吃掉，只剩「a c」——单测 `⛔ 正文里的 <3 和 a < b` 抓到过这件事。
/// HTML5 本来也要求 `<` 后立刻是标签名，所以卡紧不会漏掉真标签。
final RegExp _htmlTagPattern = RegExp(r'</?[a-zA-Z][a-zA-Z0-9-]*(\s[^>]*)?/?>');

/// 命名的 HTML 实体。只收最常见的那几个，其余交给下面的数字实体分支。
const Map<String, String> _htmlEntities = {
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&apos;': "'",
  '&#39;': "'",
  '&nbsp;': ' ',
  '&ldquo;': '“',
  '&rdquo;': '”',
  '&mdash;': '—',
  '&hellip;': '…',
};

/// 去掉 HTML 标签与实体，顺手把连续空白压成一个空格。
///
/// 不做完整的 HTML 解析：我们要的只是「一句话」，接口吐回来的也就是一层
/// `<p>` 或几个 `<br>`。为这点事引一个 HTML 解析器不划算。
String stripHtmlFrom(String input) {
  var text = input.replaceAll(_htmlTagPattern, ' ');

  _htmlEntities.forEach((entity, replacement) {
    text = text.replaceAll(entity, replacement);
  });
  text = text.replaceAllMapped(RegExp(r'&#(x?)([0-9a-fA-F]+);'), (m) {
    final code = int.tryParse(
      m.group(2)!,
      radix: m.group(1)!.isEmpty ? 10 : 16,
    );
    if (code == null || code < 0 || code > 0x10FFFF) return m.group(0)!;
    return String.fromCharCode(code);
  });

  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// JSONP 包裹：`callback({...})` / `cb([...]);`。
///
/// 一批老接口只提供这种形式。剥掉外面那层函数调用，里头就是正常 JSON，
/// 候选列表因此照样摊得开。
final RegExp _jsonpPattern = RegExp(
  r'^[\w$.\[\]"'
  r"']+\s*\(\s*([\s\S]*?)\s*\)\s*;?\s*$",
);

/// 把响应里真正的 JSON 部分抠出来；不是 JSONP 就原样返回。
String unwrapJsonp(String body) {
  final trimmed = body.trim();
  if (trimmed.startsWith('{') || trimmed.startsWith('[')) return trimmed;
  final match = _jsonpPattern.firstMatch(trimmed);
  final inner = match?.group(1)?.trim();
  if (inner == null || inner.isEmpty) return trimmed;
  if (!inner.startsWith('{') && !inner.startsWith('[')) return trimmed;
  return inner;
}
