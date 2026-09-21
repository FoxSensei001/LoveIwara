import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/http_client_factory.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/utils/signature_ai_prompt.dart';
import 'package:i_iwara/app/utils/signature_template.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 求值一条小尾巴时能用上的当前上下文。
///
/// 只带「用户正看着的是什么」——发评论的那张弹窗知道这些，模板里的 `{title}`
/// `{author}` `{tags}` 就是从这儿来的。取不到就留 null，对应的变量会整段消失。
///
/// ⭐ 各处能给的**深浅不一**，这是刻意的：视频页给得出标题、作者、标签和当前
/// 播放进度，论坛给得出版块名与楼主，作者页只给得出那个人，发帖弹窗只给得出
/// 用户正在写的标题。写了填不出的变量不报错、也不留花括号，那一段自己消失
/// （见 [SignatureTemplate.render]）——所以一条模板可以到处通用。
class SignatureContext {
  const SignatureContext({
    this.title,
    this.author,
    this.tags,
    this.section,
    this.replyTo,
    this.floor,
    this.duration,
    this.playPosition,
  });

  /// 正在看的那件东西的标题：视频 / 图库 / 投稿标题、论坛主题、正在写的帖子标题。
  final String? title;

  /// 它的作者：投稿人、论坛楼主、作者页上的那个人。
  final String? author;

  /// 标签（视频 / 图库）。超过 [maxTags] 条时只取前几条——一条小尾巴挂不住
  /// 四十个标签，而截断出来的省略号比少几个标签难看得多。
  final List<String>? tags;

  /// 内容所在的分区。目前只有论坛版块填得出。
  final String? section;

  /// 正在回复谁。回复某条评论 / 引用某一楼时才有。
  final String? replyTo;

  /// 正在回复第几楼。只有论坛数得出楼层。
  final int? floor;

  /// 视频总时长。和 [playPosition] 凑成「看到 12:34 / 45:00」。
  final Duration? duration;

  /// 当前播放进度。
  ///
  /// ⛔ 存的是一个**取值函数**而不是一份快照：小尾巴在按下发送那一刻才求值，
  /// 而用户完全可能对着播放中的视频写上两分钟。`{playtime}` 该是发送时的进度，
  /// 不是打开输入框那一刻的。
  final Duration? Function()? playPosition;

  static const SignatureContext empty = SignatureContext();

  /// `{tags}` 最多写出几条。
  static const int maxTags = 5;

  /// 在页面上下文之上补一个「正在回复谁 / 第几楼」。
  ///
  /// 回复某一楼 / 某条评论时用：那条回复的上下文＝所在页面的上下文 + 回复对象，
  /// 没有理由让每个回复入口自己重新拼一份页面信息。
  SignatureContext withReplyTo(String? who, {int? floor}) {
    final trimmed = who?.trim();
    if ((trimmed == null || trimmed.isEmpty) && floor == null) return this;
    return SignatureContext(
      title: title,
      author: author,
      tags: tags,
      section: section,
      replyTo: (trimmed == null || trimmed.isEmpty) ? replyTo : trimmed,
      floor: floor ?? this.floor,
      duration: duration,
      playPosition: playPosition,
    );
  }

  /// 摊成「给 AI 看的事实表」：键是英文（说给模型听），值是原样的内容。
  ///
  /// ⭐ AI 一言拿到这张表就能**照着用户正看着的东西**现写一句，而不是写一句
  /// 放之四海而皆准的格言——这是它与接口一言唯一的结构性优势。空上下文返回空表，
  /// 提示词里那一整块随之不在场（设置页里「试一下」走的就是这条）。
  Map<String, String> toPromptFacts() {
    final out = <String, String>{};
    void put(String key, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) out[key] = v;
    }

    put('Title', title);
    put('Author', author);
    put('Tags', tags?.take(maxTags).join(', '));
    put('Section', section);
    put('Replying to', replyTo);
    put('Floor', floor?.toString());
    put('Video length', duration == null ? null : _hhmmss(duration!));
    final position = playPosition?.call();
    put(
      'Watched up to',
      position == null || position <= Duration.zero ? null : _hhmmss(position),
    );
    return out;
  }

  static String _hhmmss(Duration d) => CommonUtils.formatDuration(d);
}

/// 一个可以写进小尾巴的变量，以及 UI 要用来介绍它的那点信息。
class SignatureVariableSpec {
  const SignatureVariableSpec({required this.name, this.defaultArg});

  final String name;

  /// 插入到编辑器时默认带上的参数（`{date:yyyy-MM-dd}` 里的那段）。
  final String? defaultArg;

  String get sample => defaultArg == null ? '{$name}' : '{$name:$defaultArg}';
}

/// [SignatureService.estimate] 拿什么填那些「要联网才知道」的变量。
///
/// ⛔ 分成三档是因为三个调用点要的**根本不是一回事**，而第三档被当成第二档
/// 用了很久（2026-09-21 用户报障）：发送前的预览里摆着一句上一条评论的一言，
/// 和真会发出去的那句长得一模一样，用户以为看到的就是要发的。
enum SignatureFill {
  /// 算长度用：上次成功的值 → 没有就一段等宽的点。
  ///
  /// 要的是**宽度**，内容无所谓。字数统计每敲一键算一次，不可能等网络。
  length,

  /// 给人看的样例用（设置页、变量选择面板）：上次成功的值 → 没有就原样留
  /// `{hitokoto}`。
  ///
  /// 这里拿上次的值是**对的**：打开一张列表就去挨个请求别人的接口不礼貌，
  /// 而这两处问的是「这个源会给我什么」，不是「我这条会发出什么」。
  sample,

  /// 发送前的预览用：**只认这一次当场生成过的值**，没生成过就写一句
  /// 「发送时生成」。
  ///
  /// ⛔ 这一档绝不许回退到上次缓存。预览回答的是「我按下发送会发出什么」，
  /// 而那个答案在用户点「生成」之前根本不存在——摆一句看起来像真的旧句子，
  /// 比摆一句「还没生成」错得多。
  pending,
}

/// 发送时小尾巴求值的进度。发送键上那圈转圈拿它说明「在等什么」。
///
/// ⭐ 存在的理由：接了 AI 一言之后这一步可能要好几秒（见 `_aiTimeout`），
/// 而一个没有说明的转圈会被读成「应用卡住了」。用户等得起，但要知道在等谁。
class SignatureProgress {
  const SignatureProgress({
    required this.done,
    required this.total,
    required this.pending,
  });

  /// 已经取回来的个数。
  final int done;

  /// 这次要联网取的变量总数。**不含**本地变量和已经钉住的值——那些是同步的，
  /// 算进来会让进度条一开始就莫名其妙地不是 0。
  final int total;

  /// 还在等的那些源的显示名（「AI 一言」/「Hitokoto」/ 用户自己起的名）。
  final List<String> pending;

  /// 还在等的第一个源。只有一个源时它就是全部答案。
  String? get current => pending.isEmpty ? null : pending.first;
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
/// 1. 超时（[_httpTimeout] / [_aiTimeout]，按源的种类分），挂住的连接不许拖住发送；
/// 2. 失败回退到上一次成功的值（跨重启保留，见 [_loadCache]）；
/// 3. 还是没有就让这个变量整段消失，剩下的照常发出去。
class SignatureService extends GetxService {
  SignatureService({Dio? dio}) {
    _dio =
        dio ??
        (Dio(
            BaseOptions(
              connectTimeout: _httpTimeout,
              receiveTimeout: _httpTimeout,
              sendTimeout: _httpTimeout,
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

  /// 普通接口源（一言这一族）的超时。
  ///
  /// 原先是 6s，对「打一个接口」来说也偏紧：墙内用户的请求要先过一次代理，
  /// 冷启动时光是代理连接 + TLS 握手就能吃掉好几秒，而这 6s 是**整个请求**的
  /// 预算，不是握手的预算。放宽到 15s——反正取不到也只是回退上次的值，
  /// 真正要防的是「连接挂死拖住发送」，那种情况 15s 和 6s 一样都会被截断。
  static const Duration _httpTimeout = Duration(seconds: 15);

  /// AI 源的超时。
  ///
  /// ⛔ **不能和接口源共用一个数**：AI 源要跑一次模型推理，和打一个接口不是
  /// 一个量级。[AiService.defaultRequestTimeout] 自己给的预算是 90s，外面套一
  /// 个 6s 等于把它压到 1/15——AI 一言因此几乎必然超时，日志里只留下一行
  /// `TimeoutException after 0:00:06`，看着像接口坏了，其实是我们自己掐的
  /// （2026-09-21 用户报障）。
  ///
  /// 取 45s 而不是跟着 AiService 的 90s：发送那一刻评论在等着这句话，不该跟
  /// 模型的最坏情况走。慢过 45s 的模型就让它回退上次的值。
  static const Duration _aiTimeout = Duration(seconds: 45);

  /// 套在 [_aiTimeout] 外面的余量。
  ///
  /// AI 那条路的超时由 [AiRequest.timeout] 在 `AiService` 内部先触发，那里能
  /// 给出带供应商信息的真实错误；外面这层只是防「future 整个挂住」的兜底，
  /// 所以要比内层晚一点到，否则永远是外层先赢、错误信息永远是干巴巴的
  /// `TimeoutException`。
  static const Duration _timeoutSlack = Duration(seconds: 5);

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

  /// 应用自带、不用联网、也不问上下文就能算出来的变量。
  ///
  /// ⛔ 这里**没有**一言：一言是一个数据源（[SignatureProvider.hitokoto]），
  /// 和用户自己接的接口同一个概念、同一条求值管线、同一张设置页列表。
  ///
  /// ⛔ 这里也**没有**应用名和版本号。小尾巴是用户说自己的话，不是应用给自己
  /// 打的广告；「发自 XXX v1.2.3」这种变量只会让人把它当成推广后缀。
  static const List<SignatureVariableSpec> builtinVariables = [
    SignatureVariableSpec(name: 'date', defaultArg: 'yyyy-MM-dd'),
    SignatureVariableSpec(name: 'time', defaultArg: 'HH:mm'),
    SignatureVariableSpec(name: 'datetime', defaultArg: 'yyyy-MM-dd HH:mm'),
    SignatureVariableSpec(name: 'weekday'),
    SignatureVariableSpec(name: 'platform'),
    SignatureVariableSpec(name: 'pick', defaultArg: 'A|B|C'),
  ];

  /// 由**发这条内容时所在的页面**填的变量，见 [SignatureContext]。
  ///
  /// 和上面那组分开列，是因为它们的「有没有值」这件事本身就不一样：日期到哪儿
  /// 都算得出来，而 `{playtime}` 只有视频页给得出。变量面板因此分两组，并在
  /// 组标题下写明这一点——否则用户会以为自己插的变量坏了。
  static const List<SignatureVariableSpec> contextVariables = [
    SignatureVariableSpec(name: 'title'),
    SignatureVariableSpec(name: 'author'),
    SignatureVariableSpec(name: 'tags'),
    SignatureVariableSpec(name: 'section'),
    SignatureVariableSpec(name: 'reply_to'),
    SignatureVariableSpec(name: 'floor'),
    SignatureVariableSpec(name: 'playtime'),
    SignatureVariableSpec(name: 'duration'),
  ];

  /// 内置变量名，用来挡住「数据源起了个和内置变量一样的名字」。
  static final Set<String> builtinVariableNames = {
    for (final e in builtinVariables) e.name,
    for (final e in contextVariables) e.name,
  };

  /// 全部数据源：预置的在前，用户自己接的在后。
  ///
  /// ⭐ 自定义源里**同名的那条会顶掉内置源，并占住它原来的位置**。内置的一言
  /// 因此不再是一块动不得的石头：用户想给它换个口味、带上出处，改完仍旧是
  /// `{hitokoto}`，模板不用动；删掉这条覆盖就恢复默认。
  ///
  /// ⭐ AI 可用时，[SignatureProvider.aiHitokoto] 也作为预置源之一（排在 hitokoto 之后）。
  List<SignatureProvider> get providers {
    final custom = customProviders;
    final overrides = {for (final e in custom) e.id: e};
    final taken = <String>{};

    final effectiveBuiltins = [
      ...SignatureProvider.builtins,
      if (aiAvailable) SignatureProvider.aiHitokoto,
    ];

    final out = <SignatureProvider>[];
    for (final builtin in effectiveBuiltins) {
      final override = overrides[builtin.id];
      if (override != null) taken.add(builtin.id);
      out.add(override ?? builtin);
    }
    // ⛔ AI 源只能从上面那张内置表进来。少了这道过滤，用户改过提示词之后
    // 再把 AI 供应商删掉，那条覆盖会作为一条普通自定义源掉进列表——一个
    // 点开是空白、测试必失败、还删不掉（它占着内置的位子）的幽灵。
    out.addAll(custom.where((e) => !taken.contains(e.id) && !e.isAi));
    return out;
  }

  /// AI 这条路现在能不能用（配了供应商，且它允许跑小尾巴任务）。
  bool get aiAvailable =>
      Get.isRegistered<AiService>() &&
      Get.find<AiService>().isAvailable(AiTask.signature);

  /// AI 一言那条源的**当前**样子：用户改过提示词就是改过的那份。
  ///
  /// ⛔ 返回的是配置，不问可用性——设置页要在 AI 还没配好时也能编辑提示词，
  /// 否则用户得先去配供应商才能看见这个功能存在。
  SignatureProvider get aiProvider =>
      customProviders.firstWhereOrNull(
        (e) => e.id == SignatureProvider.aiHitokoto.id,
      ) ??
      SignatureProvider.aiHitokoto;

  /// 改写 AI 一言的提示词。传空串＝恢复出厂（把那条覆盖整条删掉）。
  Future<void> saveAiPrompt(String prompt) async {
    final next = customProviders
        .where((e) => e.id != SignatureProvider.aiHitokoto.id)
        .toList();
    final trimmed = prompt.trim();
    if (trimmed.isNotEmpty && trimmed != SignatureAiPrompt.defaultTemplate) {
      // ⛔ 不能写 `aiHitokoto.copyWith(...)`：copyWith 会把 `builtin: true`
      // 一起带过来，而 encodeList 明确不存内置源——那样保存会全程静默失败，
      // 界面上还显示改好了。必须自己搭一条 builtin=false 的。
      next.add(
        SignatureProvider(
          id: SignatureProvider.aiHitokoto.id,
          name: SignatureProvider.aiHitokoto.name,
          url: '',
          kind: SignatureProvider.kindAi,
          prompt: trimmed,
        ),
      );
    }
    await saveCustomProviders(next);
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
  ///
  /// [pinned] 是**这一次编辑里已经当场生成过**的值（用户在预览里点了「生成」
  /// 或「换一句」）。键与 [SignatureVariable.key] 一致，命中的变量直接用它、
  /// 不再打一次接口——否则预览里看到的那句和真发出去的那句不是同一句，
  /// 用户会以为自己发错了。本地变量（日期、时间）不受它影响：那些每次现算
  /// 才是对的，`{time}` 应当是按下发送的时刻而不是点开预览的时刻。
  ///
  /// [onProgress] 让发送键上那圈转圈说得出「在等什么」。⭐ 只在真要联网时才
  /// 回调：全是本地变量（或全被钉住了）的那条模板求值是同步的，报一次
  /// `total: 0` 的进度只会让界面闪一下。
  Future<String> render(
    String template, {
    SignatureContext context = SignatureContext.empty,
    bool keepUnknown = false,
    Map<String, String>? pinned,
    void Function(SignatureProgress)? onProgress,
  }) async {
    await _ensureDateSymbols();

    final parsed = SignatureTemplate.parse(template);
    final values = <String, String>{};

    // ⛔ 先把「同步就能填」的全填掉，剩下的才是进度的分母。本地变量和钉住的
    // 值混进来的话，进度一开始就不是 0/N，读起来像是漏了几步。
    final remote = <SignatureVariable>[];
    for (final variable in parsed.variables) {
      // 本地变量优先现算；钉住的值只对网络变量生效。
      final local = _resolveLocal(variable, context);
      if (local != null) {
        values[variable.key] = local;
        continue;
      }
      final pin = pinned?[variable.key];
      if (pin != null && pin.isNotEmpty) {
        values[variable.key] = pin;
        continue;
      }
      remote.add(variable);
    }

    final report = remote.isEmpty ? null : onProgress;
    final pending = report == null ? <String>[] : remote.map(_labelOf).toList();

    // 先报一次 0/N：不然在第一个返回**之前**（恰恰是最慢的那段）界面上什么
    // 都没有，而那正是用户最想知道「在等谁」的时候。
    report?.call(
      SignatureProgress(
        done: 0,
        total: remote.length,
        pending: List.of(pending),
      ),
    );

    var done = 0;
    await Future.wait(
      remote.map((variable) async {
        final value = await _resolveGuarded(variable, context);
        if (value != null) values[variable.key] = value;
        done++;
        pending.remove(_labelOf(variable));
        report?.call(
          SignatureProgress(
            done: done,
            total: remote.length,
            pending: List.of(pending),
          ),
        );
      }),
    );

    return parsed.render(values, keepUnknown: keepUnknown);
  }

  /// 一个变量在进度里怎么称呼：优先用数据源的显示名，认不出就用变量名自己。
  String _labelOf(SignatureVariable variable) =>
      providerOf(variable.name)?.displayName ?? variable.name;

  /// 把模板里**所有数据源变量**现取一遍，返回 key → 取到的值。
  ///
  /// 预览里那枚「生成 / 换一句」按的就是它。与 [render] 共用 [_resolveGuarded]，
  /// 所以超时、失败回退上次值这三道兜底完全一样——预览里能取到的，发送时
  /// 一定也能取到。
  ///
  /// 只跑网络变量：本地变量没有「生成」这回事，把它们一起算进来只会让
  /// `{date}` 被钉在点预览的那一刻。
  Future<Map<String, String>> resolveProviderValues(
    String template, {
    SignatureContext context = SignatureContext.empty,
  }) async {
    final parsed = SignatureTemplate.parse(template);
    final out = <String, String>{};

    await Future.wait(
      parsed.variables.where((v) => _resolveLocal(v, context) == null).map((
        variable,
      ) async {
        final value = await _resolveGuarded(variable, context);
        if (value != null && value.isNotEmpty) out[variable.key] = value;
      }),
    );

    return out;
  }

  /// 同步估算：本地变量照常算，网络变量按 [fill] 说的办。
  ///
  /// **不要**拿它的结果去发送——真发送走 [render]。
  ///
  /// 两边都估不准也不至于出事：真发送时 `_composeForSubmit` 会把超出的部分从
  /// 小尾巴上砍掉，不会因为估少了几个字而发不出去。
  /// [pinned] 见 [render]：这一次编辑里当场生成过的值，优先于一切兜底。
  ///
  /// [contextComplete] 说的是「[context] 已经是最终答案了」。⛔ 它存在是因为
  /// 样例档默认把填不出的上下文变量原样留成 `{title}`（见下面那段注释），而
  /// **示范场景**恰恰要演的是「填不出就整段消失」——尤其是「没有上下文」那一
  /// 档，留着花括号就等于什么都没演。见 `signature_scenes.dart`。
  String estimate(
    String template, {
    SignatureContext context = SignatureContext.empty,
    SignatureFill fill = SignatureFill.length,
    Map<String, String>? pinned,
    bool contextComplete = false,
  }) {
    final parsed = SignatureTemplate.parse(template);
    final values = <String, String>{};

    for (final variable in parsed.variables) {
      final local = _resolveLocal(variable, context);
      if (local != null) {
        // ⛔ 上下文变量在设置页里**本来就算不出值**——那儿没有「正在看的作品」。
        // 照常让它消失的话，预览里出现的是「我在看《》」，像是自己把模板写坏了。
        // 所以样例这一档保留原样的 `{title}`（[render] 的 keepUnknown 会放回
        // 去）。发送前的预览（pending）不走这条：那一档回答的是「按下发送会发
        // 出什么」，而答案确实是它整段消失。示范场景（[contextComplete]）同理：
        // 那儿的上下文就是最终答案，演的正是消失这件事。
        if (local.isEmpty && fill == SignatureFill.sample && !contextComplete) {
          continue;
        }
        values[variable.key] = local;
        continue;
      }
      final pin = pinned?[variable.key];
      if (pin != null && pin.isNotEmpty) {
        values[variable.key] = pin;
        continue;
      }

      // ⛔ 只有这一档不许碰 `_lastGood`：发送前的预览里，一句**上一条评论的**
      // 一言和真会发出去的那句长得一模一样，用户没有任何办法分辨。
      if (fill == SignatureFill.pending) {
        values[variable.key] = slang.t.settings.signaturePendingValue;
        continue;
      }

      final cached = _lastGood[variable.key];
      if (cached != null) {
        values[variable.key] = cached;
      } else if (fill == SignatureFill.length) {
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

    // ⛔ 超时按**源的种类**取，不是一个全局常数：AI 源要跑模型推理，
    // 拿接口源的预算去掐它等于让它永远超时。见 [_aiTimeout]。
    final budget = providerOf(variable.name)?.isAi == true
        ? _aiTimeout + _timeoutSlack
        : _httpTimeout;

    try {
      final fetched = await _resolveRemote(variable, context).timeout(budget);
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
      case 'platform':
        return _platformName();
      case 'title':
        return context.title?.trim() ?? '';
      case 'author':
        return context.author?.trim() ?? '';
      case 'tags':
        final tags = context.tags
            ?.map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(SignatureContext.maxTags);
        return tags == null ? '' : tags.join(' ');
      case 'section':
        return context.section?.trim() ?? '';
      case 'reply_to':
        return context.replyTo?.trim() ?? '';
      case 'floor':
        return context.floor?.toString() ?? '';
      case 'duration':
        final total = context.duration;
        if (total == null || total <= Duration.zero) return '';
        return CommonUtils.formatDuration(total);
      case 'playtime':
        // 写成 `12:34`：评论区的时间节点识别认的就是这个写法，用户的小尾巴
        // 因此顺手变成一个能点的跳转点（见 `CommonUtils.parseTimestamp`）。
        final position = context.playPosition?.call();
        if (position == null || position <= Duration.zero) return '';
        return CommonUtils.formatDuration(position);
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
  Future<String?> _resolveRemote(
    SignatureVariable variable,
    SignatureContext context,
  ) async {
    final provider = providerOf(variable.name);
    if (provider == null) return null;
    return fetchWith(provider, context: context);
  }

  /// 按一个数据源的完整配置（地址 + 参数 + 取值路径 + 加工 + 翻译）取出那句话。
  ///
  /// 公开是为了让设置页的「测试」按钮和向导走**完全同一条路**——测试通过而真
  /// 用起来不行，是最难查的一类问题。
  ///
  /// [context] 只对 AI 源有意义（见 [_fetchAiValue]）：接口源那边是别人的地址，
  /// 我们不会把「用户在看什么」发给它。设置页与向导不传，那边本来就没有上下文。
  Future<String?> fetchWith(
    SignatureProvider provider, {
    SignatureContext context = SignatureContext.empty,
  }) => resolveValue(provider, context: context);

  /// 同上，但可以拿一份**已经取回来的**响应体来算。
  ///
  /// 向导的调节屏用它：换「带上出处」开关只是换一种拼法，不必再打一次接口。
  Future<String?> resolveValue(
    SignatureProvider provider, {
    String? body,
    SignatureContext context = SignatureContext.empty,
  }) async {
    final raw = body ?? await fetchBody(provider, context: context);
    if (raw.isEmpty) return null;
    final shaped = provider.composeValue(raw);
    if (shaped.isEmpty) return null;
    return (autoTranslate && !provider.isAi)
        ? await _translated(shaped)
        : shaped;
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
    // ⛔ 翻译这条路**也可能是 AI**（设置里的「AI 翻译」开关），所以预算同样
    // 要分种类。只按「源不是 AI 源」就套接口预算的话，开了 AI 翻译的用户会
    // 卡在同一个坑里：一言取回来了，翻译那一步静默超时、原样返回中文。
    // DeepLX 优先级高于 AI，与 TranslationService.translate 的分支保持一致。
    final aiTranslate =
        _config[ConfigKey.USE_DEEPLX_TRANSLATION] != true &&
        _config[ConfigKey.USE_AI_TRANSLATION] == true;

    try {
      final result = await Get.find<TranslationService>()
          .translate(text, targetLanguage: _targetLanguage)
          .timeout(aiTranslate ? _aiTimeout + _timeoutSlack : _httpTimeout);
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
  Future<String> fetchBody(
    SignatureProvider provider, {
    SignatureContext context = SignatureContext.empty,
  }) async {
    if (provider.isAi) return _fetchAiValue(provider, context);
    final uri = provider.resolvedUri();
    final response = await _dio.getUri<String>(uri);
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw HttpException('HTTP $status', uri: uri);
    }
    return response.data?.trim() ?? '';
  }

  /// 请求 AI 生成一句小尾巴短句。
  ///
  /// 提示词取这条源自己的 [SignatureProvider.prompt]（用户在设置里改过的），
  /// 空串就是出厂那份。见 [SignatureAiPrompt]。
  ///
  /// ⭐ [context] 会作为一张事实表进用户消息：AI 一言因此能**照着用户正看着
  /// 的东西**现写一句，而不是写一句放之四海皆准的格言——这正是它与接口一言的
  /// 分野。⛔ 上下文只进 AI 源，接口源那边是别人的地址，不往外发。
  ///
  /// ⛔ 失败或空结果必须返回空串，不抛出异常，由上层自然落到三道兜底。
  Future<String> _fetchAiValue(
    SignatureProvider provider,
    SignatureContext context,
  ) async {
    if (!Get.isRegistered<AiService>()) return '';
    final aiService = Get.find<AiService>();
    if (!aiService.isAvailable(AiTask.signature)) return '';

    try {
      final localeTag = slang.LocaleSettings.currentLocale.languageTag;
      final req = AiRequest(
        task: AiTask.signature,
        input: SignatureAiPrompt.userPromptFor(context.toPromptFacts()),
        system: SignatureAiPrompt.render(provider.prompt, localeTag),
        // ⛔ 显式给预算，别用 AiService 的 90s 默认值：发送那一刻评论在等这句
        // 话。内层先到（外面留了 [_timeoutSlack]），错误信息才说得出是哪一步。
        timeout: _aiTimeout,
      );
      final result = await aiService.complete(req);
      if (!result.isSuccess) return '';
      final raw = result.data?.trim() ?? '';
      if (raw.isEmpty) return '';
      return _stripAiWrapping(raw);
    } catch (e) {
      LogUtils.w('获取 AI 一言失败：$e', 'SignatureService');
      return '';
    }
  }

  /// 剥掉模型常见的多余包装：首尾成对引号、行首破折号、首尾空白。
  static String _stripAiWrapping(String text) {
    var s = text.trim();
    bool changed = true;
    while (changed) {
      changed = false;

      if (s.startsWith('- ') || s.startsWith('— ') || s.startsWith('– ')) {
        s = s.substring(2).trim();
        changed = true;
        continue;
      }

      if (s.length >= 2) {
        const quotePairs = [
          ('"', '"'),
          ("'", "'"),
          ('「', '」'),
          ('『', '』'),
          ('“', '”'),
          ('‘', '’'),
        ];
        for (final (open, close) in quotePairs) {
          if (s.startsWith(open) && s.endsWith(close)) {
            s = s.substring(open.length, s.length - close.length).trim();
            changed = true;
            break;
          }
        }
      }
    }
    return s;
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
