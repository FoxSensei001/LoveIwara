import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/http_client_factory.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/utils/signature_template.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 求值一条小尾巴时能用上的当前上下文。
///
/// 只带「用户正看着的是什么」——发评论的页面知道这些，模板里的 `{title}`
/// `{author}` 就是从这儿来的。取不到就留 null，对应的变量会整段消失。
class SignatureContext {
  const SignatureContext({this.title, this.author});

  final String? title;
  final String? author;

  static const SignatureContext empty = SignatureContext();
}

/// 一个可以写进小尾巴的变量，以及 UI 要用来介绍它的那点信息。
class SignatureVariableSpec {
  const SignatureVariableSpec({required this.name, this.defaultArg});

  final String name;

  /// 插入到编辑器时默认带上的参数（`{date:yyyy-MM-dd}` 里的那段）。
  final String? defaultArg;

  String get sample => defaultArg == null ? '{$name}' : '{$name:$defaultArg}';
}

/// 把小尾巴模板求值成真正发出去的那句话。
///
/// ⛔ 再说一遍这件事的边界：评论发到 Iwara 之后就是死文本。这里做的全部事情
/// 是「在按下发送的那一秒把 `{date}` 换成今天、把 `{hitokoto}` 换成刚取回来
/// 的一句话」。没有任何办法让已经发出去的评论自己变。
///
/// 网络变量按用户的选择**每条评论都新取**，但求值链路上挂着三道兜底，因为
/// 「发不出评论」永远比「小尾巴少一句」严重得多：
///
/// 1. 超时 [_requestTimeout]，挂住的连接不许拖住发送；
/// 2. 失败回退到上一次成功的值（跨重启保留，见 [_loadCache]）；
/// 3. 还是没有就让这个变量整段消失，剩下的照常发出去。
class SignatureService extends GetxService {
  SignatureService({Dio? dio}) {
    _dio =
        dio ??
        (Dio(
            BaseOptions(
              connectTimeout: _requestTimeout,
              receiveTimeout: _requestTimeout,
              sendTimeout: _requestTimeout,
              // 什么都可能被填进自定义源，别让 dio 替我们猜类型后解析失败抛错
              responseType: ResponseType.plain,
              // 4xx/5xx 交给下面统一按「取不到」处理，不走异常
              validateStatus: (_) => true,
            ),
          )
          ..options.persistentConnection = false
          // 走应用统一的 HttpClient 工厂：用户在设置里配的代理挂在那上面，
          // 裸 Dio 会让墙内用户的一言永远取不到，而且全程静默。
          ..httpClientAdapter = IOHttpClientAdapter(
            createHttpClient: HttpClientFactory.instance.createHttpClient,
          ));
  }

  static const Duration _requestTimeout = Duration(seconds: 6);

  /// 没有缓存值时，拿来估算长度的网络变量占位宽度。
  ///
  /// 输入框的字数统计是同步的（每敲一个字都要算一遍），不可能为它去等一次
  /// 网络请求。估不准的代价只是额度差几个字，而真发送时 [render] 会把总长
  /// 夹回上限，不会因此发不出去。
  static const int _networkEstimateWidth = 24;

  late final Dio _dio;
  final Random _random = Random();

  /// 上一次成功取到的值，键是 [SignatureVariable.key]。
  final Map<String, String> _lastGood = {};

  ConfigService get _config => Get.find<ConfigService>();

  Future<SignatureService> init() async {
    _loadCache();
    await _ensureDateSymbols();
    return this;
  }

  /// 已经加载过日期符号的 locale。
  ///
  /// `DateFormat('EEEE', 'zh_CN')` 在符号没加载时会直接抛——而且是抛在发送
  /// 评论的路径上。这里只加载当前这一个语言（不是 `initializeDateFormatting()`
  /// 那样把几百个 locale 全拉进内存），用户中途换语言时补加载。
  final Set<String> _loadedDateLocales = {};

  String get _intlLocale =>
      slang.LocaleSettings.currentLocale.languageTag.replaceAll('-', '_');

  Future<void> _ensureDateSymbols() async {
    final locale = _intlLocale;
    if (_loadedDateLocales.contains(locale)) return;
    try {
      await initializeDateFormatting(locale);
      _loadedDateLocales.add(locale);
    } catch (e) {
      LogUtils.w('日期符号加载失败（$locale），日期变量将用默认格式：$e', 'SignatureService');
    }
  }

  // ---------------------------------------------------------------- 变量目录

  /// 应用自带、不用联网就能算出来的变量。变量选择面板照这个顺序列。
  ///
  /// ⛔ 这里**没有**一言：一言是一个数据源（[SignatureProvider.hitokoto]），
  /// 和用户自己接的接口同一个概念、同一条求值管线、同一张设置页列表。
  static const List<SignatureVariableSpec> builtinVariables = [
    SignatureVariableSpec(name: 'date', defaultArg: 'yyyy-MM-dd'),
    SignatureVariableSpec(name: 'time', defaultArg: 'HH:mm'),
    SignatureVariableSpec(name: 'datetime', defaultArg: 'yyyy-MM-dd HH:mm'),
    SignatureVariableSpec(name: 'weekday'),
    SignatureVariableSpec(name: 'app'),
    SignatureVariableSpec(name: 'version'),
    SignatureVariableSpec(name: 'platform'),
    SignatureVariableSpec(name: 'title'),
    SignatureVariableSpec(name: 'author'),
    SignatureVariableSpec(name: 'pick', defaultArg: 'A|B|C'),
  ];

  /// 内置变量名，用来挡住「数据源起了个和内置变量一样的名字」。
  static final Set<String> builtinVariableNames = builtinVariables
      .map((e) => e.name)
      .toSet();

  /// 全部数据源：预置的在前，用户自己接的在后。
  ///
  /// ⭐ 自定义源里**同名的那条会顶掉内置源，并占住它原来的位置**。内置的一言
  /// 因此不再是一块动不得的石头：用户想给它换个口味、带上出处，改完仍旧是
  /// `{hitokoto}`，模板不用动；删掉这条覆盖就恢复默认。
  List<SignatureProvider> get providers {
    final custom = customProviders;
    final overrides = {for (final e in custom) e.id: e};
    final taken = <String>{};

    final out = <SignatureProvider>[];
    for (final builtin in SignatureProvider.builtins) {
      final override = overrides[builtin.id];
      if (override != null) taken.add(builtin.id);
      out.add(override ?? builtin);
    }
    out.addAll(custom.where((e) => !taken.contains(e.id)));
    return out;
  }

  /// 这个 id 是不是内置源的位子（＝删掉只是恢复默认，不是真删）。
  static bool isBuiltinSlot(String id) =>
      SignatureProvider.builtins.any((e) => e.id == id);

  /// 用户自己接的那些。
  List<SignatureProvider> get customProviders => SignatureProvider.decodeList(
    _config[ConfigKey.SIGNATURE_CUSTOM_SOURCES_KEY] as String?,
  );

  Future<void> saveCustomProviders(List<SignatureProvider> providers) async {
    await _config.setSetting(
      ConfigKey.SIGNATURE_CUSTOM_SOURCES_KEY,
      SignatureProvider.encodeList(providers),
    );
  }

  SignatureProvider? providerOf(String id) =>
      providers.firstWhereOrNull((e) => e.id == id);

  // -------------------------------------------------------------------- 渲染

  /// 真发送走这条：所有变量都现取，网络变量按上面那三道兜底处理。
  Future<String> render(
    String template, {
    SignatureContext context = SignatureContext.empty,
    bool keepUnknown = false,
  }) async {
    await _ensureDateSymbols();

    final parsed = SignatureTemplate.parse(template);
    final values = <String, String>{};

    await Future.wait(
      parsed.variables.map((variable) async {
        final value = await _resolveGuarded(variable, context);
        if (value != null) values[variable.key] = value;
      }),
    );

    return parsed.render(values, keepUnknown: keepUnknown);
  }

  /// 同步估算：本地变量照常算，网络变量用上次成功的值。
  ///
  /// 字数统计和「结构开销占掉多少额度」用它。**不要**拿它的结果去发送——
  /// 那样发出去的会是上一条评论的一言。
  ///
  /// [padNetwork] 管的是「还没有缓存值的网络变量」怎么占位：
  ///
  /// - true（算长度时）：拿一段等宽的点撑住，好让额度扣得接近真实；
  /// - false（给人看时）：原样留 `{hitokoto}`，一屏圆点没人看得懂。
  ///
  /// 两边都估不准也不至于出事：真发送时 `_composeForSubmit` 会把超出的部分从
  /// 小尾巴上砍掉，不会因为估少了几个字而发不出去。
  String estimate(
    String template, {
    SignatureContext context = SignatureContext.empty,
    bool padNetwork = true,
  }) {
    final parsed = SignatureTemplate.parse(template);
    final values = <String, String>{};

    for (final variable in parsed.variables) {
      final local = _resolveLocal(variable, context);
      if (local != null) {
        values[variable.key] = local;
        continue;
      }
      final cached = _lastGood[variable.key];
      if (cached != null) {
        values[variable.key] = cached;
      } else if (padNetwork) {
        values[variable.key] = '•' * _networkEstimateWidth;
      }
    }

    return parsed.render(values, keepUnknown: true);
  }

  /// 某个数据源**上一次成功取到**的那句话，没取到过就是 null。
  ///
  /// 变量选择面板和设置页拿它当样例值：打开一张列表就去挨个请求别人的接口
  /// 是不礼貌的，显示上次的结果足够说明「这个源会给我什么」。
  String? lastValueOf(String providerId) => _lastGood[providerId];

  /// 这条模板里有没有引用到数据源（＝发送时要等一次网络请求）。
  bool needsNetwork(String template) {
    final ids = providers.map((e) => e.id).toSet();
    return SignatureTemplate.parse(
      template,
    ).variables.any((v) => ids.contains(v.name));
  }

  // ------------------------------------------------------------------ 求值

  Future<String?> _resolveGuarded(
    SignatureVariable variable,
    SignatureContext context,
  ) async {
    final local = _resolveLocal(variable, context);
    if (local != null) return local;

    try {
      final fetched = await _resolveRemote(variable).timeout(_requestTimeout);
      if (fetched != null && fetched.trim().isNotEmpty) {
        _rememberGood(variable.key, fetched.trim());
        return fetched.trim();
      }
    } catch (e) {
      LogUtils.w('小尾巴变量 ${variable.raw} 取值失败：$e', 'SignatureService');
    }

    // 兜底：上一次成功的值。宁可发一句昨天的话，也不要让小尾巴凭空缺一块。
    return _lastGood[variable.key];
  }

  /// 不需要联网就能算出来的那些。返回 null 表示「这个变量不归我管」，
  /// 交给 [_resolveRemote]；返回空串表示「归我管，但现在没有值」。
  String? _resolveLocal(SignatureVariable variable, SignatureContext context) {
    final arg = variable.arg?.trim();
    final now = DateTime.now();

    switch (variable.name) {
      case 'date':
        return _formatDate(arg?.isNotEmpty == true ? arg! : 'yyyy-MM-dd', now);
      case 'time':
        return _formatDate(arg?.isNotEmpty == true ? arg! : 'HH:mm', now);
      case 'datetime':
        return _formatDate(
          arg?.isNotEmpty == true ? arg! : 'yyyy-MM-dd HH:mm',
          now,
        );
      case 'weekday':
        return _formatDate('EEEE', now);
      case 'app':
        return CommonConstants.applicationNickname;
      case 'version':
        return CommonConstants.VERSION;
      case 'platform':
        return _platformName();
      case 'title':
        return context.title?.trim() ?? '';
      case 'author':
        return context.author?.trim() ?? '';
      case 'pick':
        final options = (arg ?? '')
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (options.isEmpty) return '';
        return options[_random.nextInt(options.length)];
      default:
        return null;
    }
  }

  /// 变量名对上某个数据源就去请求它。对不上就是「不认识这个变量」。
  Future<String?> _resolveRemote(SignatureVariable variable) async {
    final provider = providerOf(variable.name);
    if (provider == null) return null;
    return fetchWith(provider);
  }

  /// 按一个数据源的完整配置（地址 + 参数 + 取值路径 + 加工 + 翻译）取出那句话。
  ///
  /// 公开是为了让设置页的「测试」按钮和向导走**完全同一条路**——测试通过而真
  /// 用起来不行，是最难查的一类问题。
  Future<String?> fetchWith(SignatureProvider provider) =>
      resolveValue(provider);

  /// 同上，但可以拿一份**已经取回来的**响应体来算。
  ///
  /// 向导的调节屏用它：换「带上出处」开关只是换一种拼法，不必再打一次接口。
  Future<String?> resolveValue(
    SignatureProvider provider, {
    String? body,
  }) async {
    final raw = body ?? await fetchBody(provider);
    if (raw.isEmpty) return null;
    final shaped = provider.composeValue(raw);
    if (shaped.isEmpty) return null;
    return autoTranslate ? await _translated(shaped) : shaped;
  }

  // ------------------------------------------------------------------ 翻译

  /// 取回来的话要不要翻成界面语言。
  ///
  /// 一言这一族数据源目前**只有中文**，所以这个开关对中文之外的用户默认是开的
  /// （第一次启动时按设备语言定，见 `ConfigKey.SIGNATURE_AUTO_TRANSLATE_KEY`）。
  bool get autoTranslate =>
      _config[ConfigKey.SIGNATURE_AUTO_TRANSLATE_KEY] == true;

  /// 翻成哪种语言。
  ///
  /// ⛔ **是界面语言，不是设置里那个「翻译语言」**。后者
  /// （`DEFAULT_LANGUAGE_KEY`）对所有人默认都是 `zh-CN`，拿它当目标的话，一个
  /// 德语用户开了开关也只会把中文一言「翻译」成中文——开关看着生效、结果毫无
  /// 变化，是最难自查的一种。
  String get _targetLanguage =>
      targetLanguageFor(slang.LocaleSettings.currentLocale.languageTag);

  /// 界面语言标签（`zh-CN` / `ja` / `en`）→ 翻译服务认识的语言代码。
  ///
  /// ⛔ 必须**先精确匹配再退主语言**：`zh-CN` 与 `zh-TW` 在目录里是两条，只按
  /// 主语言匹配会让繁体用户拿到简体。反过来 `en` 在目录里写作 `en-US`，只精确
  /// 匹配又会整个落空，所以两段都要。
  @visibleForTesting
  static String targetLanguageFor(String localeTag) {
    final codes = CommonConstants.translationSorts.map((e) => e.extData);
    final tag = localeTag.toLowerCase();

    for (final code in codes) {
      if (code.toLowerCase() == tag) return code;
    }
    final primary = tag.split('-').first;
    for (final code in codes) {
      if (code.split('-').first.toLowerCase() == primary) return code;
    }
    return 'en-US';
  }

  /// 翻一句话。⛔ 失败一律原样返回——小尾巴少翻一句只是可惜，发不出评论才是事故。
  Future<String> _translated(String text) async {
    try {
      final result = await Get.find<TranslationService>()
          .translate(text, targetLanguage: _targetLanguage)
          .timeout(_requestTimeout);
      final translated = result.data?.trim();
      if (result.isSuccess && translated != null && translated.isNotEmpty) {
        return translated;
      }
      LogUtils.w('小尾巴翻译未成功：${result.message}', 'SignatureService');
    } catch (e) {
      LogUtils.w('小尾巴翻译失败：$e', 'SignatureService');
    }
    return text;
  }

  /// 按这个数据源的地址 + 参数请求一次，返回**整份响应体**，不取值不加工。
  ///
  /// 向导拿着它在本地反复试：换出处开关、改提取规则都不必再打一次接口，
  /// 而用户看到的每一个样例都来自真实返回。
  Future<String> fetchBody(SignatureProvider provider) async {
    final uri = provider.resolvedUri();
    final response = await _dio.getUri<String>(uri);
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw HttpException('HTTP $status', uri: uri);
    }
    return response.data?.trim() ?? '';
  }

  /// 只把地址请求回来，**不取值**。
  ///
  /// 数据源向导的自定义分支用它：先拿到真实返回，下一步才让用户从里头挑一段。
  /// 「取值路径」这个概念因此不需要用户凭空想象——他看着真东西点一下就行。
  Future<String> fetchRaw(String url) =>
      fetchBody(SignatureProvider(id: '_probe', name: '', url: url));

  String _formatDate(String pattern, DateTime time) {
    try {
      final locale = _intlLocale;
      return DateFormat(
        pattern,
        _loadedDateLocales.contains(locale) ? locale : null,
      ).format(time);
    } catch (_) {
      // 用户可以在 `{date:...}` 里写任何东西，写坏了就退回默认格式，
      // 不要让一条发不出去的评论来教他 ICU 的格式串语法。
      return DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
  }

  static String _platformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  // ------------------------------------------------------------------ 缓存

  void _rememberGood(String key, String value) {
    _lastGood[key] = value;
    // 存一份跨重启的：冷启动后第一条评论要是正好断网，还能有句话可发。
    try {
      _config[ConfigKey.SIGNATURE_VALUE_CACHE_KEY] = jsonEncode(_lastGood);
    } catch (e) {
      LogUtils.w('小尾巴取值缓存写入失败：$e', 'SignatureService');
    }
  }

  void _loadCache() {
    final raw = _config[ConfigKey.SIGNATURE_VALUE_CACHE_KEY] as String?;
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      decoded.forEach((key, value) {
        if (key is String && value is String) _lastGood[key] = value;
      });
    } catch (_) {
      // 坏缓存直接当没有
    }
  }
}
