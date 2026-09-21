import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/markdown_preview_dialog.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 基础输入组件，提供通用的输入功能。
///
/// ## ⭐ 两种模式：新写是「三段结构」，编辑是「一整坨原文」
///
/// ### 新写（[initialContent] 为空）——输入框里只有用户自己的字
///
/// 引用头与小尾巴都是**结构**，由 [CommentMarkup] 在提交那一刻拼进去，
/// 全程不进 [controller]。旧版反着来——把 `'Reply #N: @x\n---\n'` 和小尾巴
/// 直接拼成初始文本交给用户编辑——于是：
///
/// - 用户在 `---` 行尾接着打字，把 markdown 语法改坏（那条分隔线本来就没
///   生效过，详见 [CommentMarkup] 的类文档）；
/// - 光标落点没定义（`controller.text` 的 setter 把 selection 置成 -1），
///   用户点哪儿光标就在哪儿，上面那件事几乎必然发生；
/// - 「有 initialContent 就不加小尾巴」的分支让论坛回复永远收不到小尾巴，
///   用户在设置里开了却不生效。
///
/// 这三件事的修法是同一件：写的时候不让用户碰到语法。
///
/// ### 编辑（[initialContent] 非空）——整条原文摊开，什么都能改
///
/// ⭐ **分界线是「预设 vs 内容」**：引用头、一言、日期这些在**生成**那一刻
/// 是预设（模板求值的结果）；一旦发出去，它们就是这条评论里的普通文字，
/// 和正文没有区别。编辑时把它们藏起来（引用缩成一张卡、小尾巴缩成一个开关）
/// 意味着用户改不了自己已经发出去的话——打错的楼层号、想换掉的那句一言，
/// 全都没有入口（2026-09-21 用户两次报障）。
///
/// 所以编辑模式下输入框里就是**服务端上那串字本身**（只过一道
/// [CommentMarkup.softenLineBreaks] 把硬换行的行尾空格抹掉，免得越编越脏），
/// 引用卡片与小尾巴开关一并不在场——它们描述的东西现在都在文本里，再画一份
/// 就会在提交时拼第二遍。提交走 `compose(body: 全文)`，只做扶正与硬化。
///
/// 预览仍然预报**列表里的样子**：那一步把输入框里的全文过一道
/// [CommentMarkup.parse] 拆回三段，与评论卡片走同一套呈现件。
class BaseInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final bool showEmojiPicker;
  final bool showTranslation;
  final bool showMarkdownHelp;
  final bool showPreview;
  final bool showRulesAgreement;
  final Function(String)? onSubmit;
  final bool isLoading;
  final String? errorText;

  /// 既有正文（编辑已发布内容时用）。非空即进**编辑模式**：整条原文摊在
  /// 输入框里，引用头与小尾巴都当普通文字，见本类的类文档。
  final String? initialContent;

  final bool enabled;
  final FocusNode? focusNode;
  final GlobalKey<EnhancedEmojiTextFieldState>? emojiTextFieldKey;
  final String? submitText;

  /// 这条回复冲着哪一楼去。给了就在输入框上方画 [GlassQuoteCard]，
  /// 并在提交时拼成 markdown 引用块。用户可以当场撤销。
  final ReplyQuote? quote;

  /// 本弹窗是否参与小尾巴。编辑小尾巴本身、私信这类场合要关掉——
  /// 不然会出现「编辑签名时界面又给你自动加一条签名」。
  final bool allowSignature;

  /// 小尾巴里 `{title}` `{author}` 要填的那点上下文。不给就是两个空变量，
  /// 模板里写了也只会静静消失——这是刻意的：发私信时填不出「视频标题」。
  final SignatureContext signatureContext;

  const BaseInputWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
    this.maxLength = 1000,
    this.maxLines = 5,
    this.showEmojiPicker = false,
    this.showTranslation = true,
    this.showMarkdownHelp = true,
    this.showPreview = true,
    this.showRulesAgreement = false,
    this.onSubmit,
    this.isLoading = false,
    this.errorText,
    this.initialContent,
    this.enabled = true,
    this.focusNode,
    this.emojiTextFieldKey,
    this.submitText,
    this.quote,
    this.allowSignature = true,
    this.signatureContext = SignatureContext.empty,
  });

  @override
  State<BaseInputWidget> createState() => _BaseInputWidgetState();
}

class _BaseInputWidgetState extends State<BaseInputWidget> {
  final ConfigService _configService = Get.find<ConfigService>();
  final SignatureService _signatureService = Get.find<SignatureService>();
  late EmojiSize _selectedEmojiSize;
  int _currentLength = 0;

  /// 正在为这次提交求值小尾巴。带网络变量时这会持续几百毫秒到几秒，
  /// 期间发送键要变成 loading，否则用户会当没反应接着连点。
  bool _submitting = false;

  /// 这是在编辑一条**已经存在**的内容，输入框里摊的是它的完整原文。
  ///
  /// ⭐ 见类文档那条分界线：编辑时引用头与小尾巴都是普通文字，不再是结构。
  /// 于是这个模式下**引用卡片、小尾巴开关、模板求值全部退场**——它们描述的
  /// 东西已经在 [controller] 里了，再走一遍就会在提交时拼出第二份。
  bool _rawEditMode = false;

  /// 这次提交正在等哪个数据源。null＝没在等（或者根本不联网）。
  ///
  /// ⭐ 转圈只说「在忙」，不说「为什么慢」。接了 AI 一言之后这一步可能真要
  /// 好几秒（见 `SignatureService` 的 `_aiTimeout`），一个没有说明的转圈会被
  /// 读成「应用卡住了」——用户等得起，但要知道在等谁。
  String? _submitStatus;

  /// 当前这条回复引用的楼层。**不会被置空**——它同时是「你在回哪一楼」这个
  /// 事实的陈述，带不带引用由 [_quoteEnabled] 管。
  ReplyQuote? _quote;

  /// 这条回复要不要带引用头。初值取持久化配置
  /// [ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY]，勾选框一改就写回去。
  late bool _quoteEnabled;

  /// 要不要带小尾巴。初值取 [ConfigKey.ENABLE_SIGNATURE_KEY]，同样写回去。
  ///
  /// ⛔ 这两个都是**持久化偏好**，不是一次性的：「我不喜欢回复带引用 / 带小
  /// 尾巴」是长期主张，让用户每发一条都重新勾一遍是折磨。本地仍留一份状态而
  /// 不是直接读配置，是为了让「编辑一条已带小尾巴的旧回复」能照原样保留
  /// （见 initState）——那种情况下的初值来自内容本身，与配置无关。
  late bool _signatureEnabled;

  /// 这一次编辑里**已经当场生成过**的数据源取值，键是 `SignatureVariable.key`。
  ///
  /// 用户在预览里点「生成 / 换一句」就往这里记一笔。提交时 [render] 优先用它，
  /// 不再打第二次接口——否则预览里看到的那句一言和真发出去的不是同一句，用户
  /// 会以为自己发错了。一次都没点过就是空表，提交时照旧现取。
  final Map<String, String> _pinnedSignatureValues = {};

  @override
  void initState() {
    super.initState();

    // 初始化表情包规格
    if (widget.showEmojiPicker) {
      final savedSizeSuffix = _configService[ConfigKey.DEFAULT_EMOJI_SIZE];
      _selectedEmojiSize =
          EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;
    }

    _quote = widget.quote;
    _quoteEnabled =
        !(_configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY] as bool);
    _signatureEnabled =
        widget.allowSignature && _configService[ConfigKey.ENABLE_SIGNATURE_KEY];

    // ⭐ 编辑既有内容＝把服务端上那串字**原样**摊开，引用头和小尾巴都在里面。
    //
    // 早先这里走 `CommentMarkup.parse`，把引用收进上方卡片、把小尾巴收进一个
    // 开关（外加一张单独的编辑弹窗）。结果是用户在输入框里看不到自己发过的
    // 那两段字，改不了打错的楼层号，也换不掉那句一言——「编辑」变成了「只能
    // 改中间那段」（2026-09-21 用户两次报障）。
    //
    // 于是编辑模式下**不解析**：引用卡片、小尾巴开关、模板求值一并退场
    // （见 [_rawEditMode]）。只过一道 softenLineBreaks——硬换行那两个行尾
    // 空格是发送时加的，留着会让用户每编辑保存一次就多硬化一层。
    final existing = widget.initialContent;
    if (existing != null && existing.isNotEmpty) {
      _rawEditMode = true;
      _quote = null;
      _quoteEnabled = false;
      _signatureEnabled = false;
      final body = CommentMarkup.softenLineBreaks(existing).trim();
      widget.controller.text = body;
      // `controller.text` 的 setter 会把 selection 置成 -1（无效），落焦时
      // 光标去哪儿全看用户点在哪儿。显式钉到末尾：编辑就该接着上次写。
      widget.controller.selection = TextSelection.collapsed(
        offset: body.length,
      );
    }

    _currentLength = _composed().length;

    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentLength = _composed().length;
        });
      }
    });
  }

  /// 真正会被发出去的那串字。
  ///
  /// 字数统计、预览、提交三处都读它——服务端的长度上限卡的是最终文本，
  /// 只数输入框里的字会让用户在提交那一刻才发现超了。
  String _composed() => _composeWith(widget.controller.text);

  String _composeWith(String body) {
    // 编辑模式下输入框里就是全文，没有结构要拼；compose 在这里只剩扶正
    // （`---` 补空行）和硬化换行两件事。
    return CommentMarkup.compose(
      body: body,
      quote: _rawEditMode || !_quoteEnabled ? null : _quote,
      signature: !_rawEditMode && _signatureEnabled
          ? _estimatedSignature()
          : null,
    );
  }

  /// 小尾巴的**估算**样子：本地变量照常算，网络变量拿上次成功的值撑宽度。
  ///
  /// 字数统计每敲一个字就要算一遍，不可能为它去等一次网络请求。真正发出去的
  /// 那一份在 [_handleSubmit] 里现求，见 [SignatureService.estimate] 的告诫。
  String _estimatedSignature() => _signatureService.estimate(
    _configService[ConfigKey.SIGNATURE_CONTENT_KEY] as String,
    context: widget.signatureContext,
    pinned: _pinnedSignatureValues,
  );

  /// 用户配置里那条小尾巴模板的原文。
  String get _signatureTemplate =>
      _configService[ConfigKey.SIGNATURE_CONTENT_KEY] as String;

  /// 本弹窗要不要露出小尾巴开关：**只问这只弹窗参不参与小尾巴**。
  ///
  /// ⛔ 早先还要求「用户确实配过内容」，理由是"没配过的人不该看见一个自己从来
  /// 没用过的开关"。可这一条同时是小尾巴**唯一的入口**——没进过设置树的人因此
  /// 永远发现不了它，只会觉得三个点里根本没有这个选项（2026-09-20 用户报障）。
  /// 配没配过现在只改那一条的说法，见 [GlassComposerBar.signatureConfigured]。
  ///
  /// ⛔ 编辑模式下不在场：那条小尾巴已经是输入框里的文字了，再给一个「带不带」
  /// 的开关只会让人以为它能把文本里那段删掉——它不能，两者说的不是一回事。
  bool get _showSignatureToggle => widget.allowSignature && !_rawEditMode;

  /// 用户配过小尾巴的内容没有。没配过时菜单里那一条变成「还没设置」，
  /// 点下去跳设置页而不是开关。
  bool get _signatureConfigured {
    final String content = _configService[ConfigKey.SIGNATURE_CONTENT_KEY];
    return content.trim().isNotEmpty;
  }

  /// 引用头 + 小尾巴 + 块间空行一共要占掉多少字符。
  ///
  /// 服务端卡的是**最终文本**的长度，而用户只能控制输入框里那部分。不把这段
  /// 开销从额度里扣掉的话，输入框会放任用户一路打到 maxLength，直到提交那一刻
  /// 才发现超了——而且超的那部分还不是他自己写的字，他改都不知道从哪儿改。
  ///
  /// 拿一个单字符正文去拼，减掉那一个字符，得到的就是纯结构开销。
  int get _structureOverhead {
    if ((_quote == null || !_quoteEnabled) && !_signatureEnabled) return 0;
    return _composeWith('x').length - 1;
  }

  /// 输入框真正能用的额度。至少留 1，免得开销比上限还大时出现负数
  /// （小上限 + 长签名是可能撞上的，那种情况该让「超长」的错误态去说话）。
  int get _bodyBudget {
    final budget = widget.maxLength - _structureOverhead;
    return budget < 1 ? 1 : budget;
  }

  /// 切换这条回复带不带引用。引用条上那枚勾选框与「更多」菜单里那条走的是
  /// 同一个方法——它们是同一个持久化偏好的两个入口。
  void _toggleQuote() {
    setState(() {
      _quoteEnabled = !_quoteEnabled;
      // 写回持久化配置：这是长期偏好，不是一次性选择
      _configService[ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY] = !_quoteEnabled;
      _currentLength = _composed().length;
    });
  }

  /// 预览给的是**发出去的样子**，不是输入框里的样子——引用条和小尾巴都在内。
  ///
  /// ⛔ 三段是分开传的，不是先 compose 成一串再交给 markdown 渲染。那样画出来
  /// 的引用头是引用块、小尾巴是全宽 `<hr>` 加一行正文大小的字，和评论列表里
  /// 的引用条 / 11px 脚注对不上——预览预报不了结果就没有意义（见
  /// `CommentStructurePreview`）。
  ///
  /// 小尾巴里的数据源变量**默认仍不现取**：点一次预览就打一次别人的接口不
  /// 像话，而且预览取一次、发送再取一次会是两句不同的话。改成给用户一枚
  /// 「生成 / 换一句」自己按——按出来的那句会被钉住（[_pinnedSignatureValues]），
  /// 提交时原样发出去，看到什么就发出什么。
  void _showPreview() {
    // ⭐ 编辑模式：输入框里是全文，这里再拆回三段交给同一套呈现件。预览要
    // 预报的始终是**评论列表里的样子**，不是输入框里的样子——用户在文本里
    // 改坏了引用头、或者把小尾巴那条 `---  ` 记号删了，在这儿一眼看得出来。
    if (_rawEditMode) {
      final parsed = CommentMarkup.parse(
        widget.controller.text,
        knownSignature: _configService[ConfigKey.SIGNATURE_CONTENT_KEY],
      );
      MarkdownPreviewHelper.showPreview(
        context,
        parsed.body,
        quote: parsed.quote,
        signature: parsed.footer,
      );
      return;
    }

    final template = _signatureTemplate;
    final canRegenerate =
        _signatureEnabled && _signatureService.needsNetwork(template);

    MarkdownPreviewHelper.showPreview(
      context,
      widget.controller.text,
      quote: _quoteEnabled ? _quote : null,
      signature: _signatureEnabled
          ? _signatureService.estimate(
              template,
              context: widget.signatureContext,
              // ⛔ pending，不是 sample：预览回答的是「我按下发送会发出
              // 什么」。拿上次那句填，用户看到的就是**上一条评论的**一言，
              // 而且和真要发出去的那句长得一模一样，没办法分辨。
              fill: SignatureFill.pending,
              pinned: _pinnedSignatureValues,
            )
          : null,
      onRegenerateSignature: canRegenerate ? _regenerateSignature : null,
    );
  }

  /// 当场把模板里的数据源变量全取一遍，钉住结果，返回小尾巴的新样子。
  ///
  /// 取不到（超时 / 接口挂了）时 `resolveProviderValues` 给的是空表或上次成功
  /// 的值，这里照样把 estimate 的结果返回去——预览里那行字保持原样，比凭空
  /// 消失好。
  Future<String?> _regenerateSignature() async {
    final template = _signatureTemplate;
    final fresh = await _signatureService.resolveProviderValues(
      template,
      context: widget.signatureContext,
    );
    if (!mounted) return null;
    setState(() {
      _pinnedSignatureValues.addAll(fresh);
      // 一言换长了，字数额度跟着变——不重算的话用户会在提交那一刻才发现超限。
      _currentLength = _composed().length;
    });
    return _signatureService.estimate(
      template,
      context: widget.signatureContext,
      fill: SignatureFill.pending,
      pinned: _pinnedSignatureValues,
    );
  }

  void _showMarkdownHelp() {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  void _showEmojiPickerDialog() {
    // 走 showGlassBottomSheet 而不是裸 showModalBottomSheet：液态档供在那条
    // 路由上，裸开的弹层里所有玻璃件都会静默落回传统档。
    showGlassBottomSheet(
      context: context,
      builder: (context) => EmojiPickerSheet(
        initialSize: _selectedEmojiSize,
        // ⛔ 这里**不 pop**：连选是刻意的（斗图要连发几张）。弹层由用户
        // 自己关，底部会实时显示这次插了几个。
        onEmojiSelected: (imageUrl, size) => _insertEmoji(imageUrl, size),
        onSizeChanged: (size) {
          setState(() {
            _selectedEmojiSize = size;
          });
          // 保存用户选择到配置
          _configService[ConfigKey.DEFAULT_EMOJI_SIZE] = size.altSuffix;
        },
      ),
    );
  }

  void _insertEmoji(String imageUrl, EmojiSize? size) {
    if (widget.emojiTextFieldKey?.currentState != null) {
      // 使用EnhancedEmojiTextField的内部方法插入表情
      widget.emojiTextFieldKey!.currentState!.insertEmoji(
        imageUrl,
        size: size ?? _selectedEmojiSize,
      );
    }

    // 更新字符计数（数的仍是最终文本，与 _composed 保持同一把尺）
    setState(() {
      _currentLength = _composed().length;
    });
  }

  Future<void> _showRulesDialog() async {
    final result = await showGlassDraggableBottomSheet<bool>(
      context: context,
      builder: (context) => GlassDraggableBottomSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            RulesAgreementDialog(scrollController: scrollController),
      ),
    );

    if (result == true) {
      // 只记录「已同意」，不代发内容——同意规则和发出内容是两件事，
      // 用户点完同意后仍需自己按提交键。
      await _configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, true);
    }
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    if (_currentLength > widget.maxLength) return;

    // 判「空」看的是用户自己写的正文：只剩一个引用头或一条小尾巴不算内容。
    if (widget.controller.text.trim().isEmpty) {
      return;
    }

    // 未同意规则时提交键本就是禁用态（见 build 里的 canSubmit），
    // 这里只兜底拦一道，不再顺手弹规则弹窗+代发。
    if (widget.showRulesAgreement &&
        !_configService[ConfigKey.RULES_AGREEMENT_KEY]) {
      return;
    }

    // 小尾巴带网络变量（一言 / 自定义源）时，这一步要等一次请求。超时与失败
    // 兜底都在 SignatureService 里，最坏情况是小尾巴少一段，不会卡住发送。
    setState(() => _submitting = true);
    String composed;
    try {
      composed = await _composeForSubmit();
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitStatus = null;
        });
      }
    }
    if (!mounted) return;

    widget.onSubmit?.call(composed);
    // ⛔ 回调是调用方给的，它完全可能当场把这只 composer 从树上摘掉（把承载它
    // 的那一段换掉、收起内联输入区）。上面那道 mounted 是在 onSubmit **之前**
    // 查的，不作数——少了这一道，下面那次 setState 就是对着已经 dispose 的
    // State 喊话。
    if (!mounted) return;

    // ⛔ 发完就把这一轮的钉子丢掉。composer 在不少地方是**不随发送销毁**的
    // （视频详情页的评论框发完只清空文字，State 还在），钉子留着的话接着写的
    // 第二条会原样带上第一条那句一言——用户看到的是「一言不会变了」。
    // 发送失败时同样清掉：重发一次本来就该算新的一条。
    _pinnedSignatureValues.clear();
    setState(() => _currentLength = _composed().length);
  }

  /// 把小尾巴求值的进度翻成底栏那一行字。
  ///
  /// ⭐ 说的是**那个源的名字**（「正在生成 AI 一言…」），不是一句笼统的
  /// 「处理中」：用户等得起几秒，但要知道在等谁——否则一个没有说明的转圈
  /// 只会被读成「应用卡住了」。只有一个源时不报 1/1，那是噪音。
  void _onSignatureProgress(SignatureProgress progress) {
    if (!mounted) return;
    final current = progress.current;
    final label = current == null
        ? null
        : t.settings.signatureResolving(name: current);
    setState(() {
      // ⛔ 报 done/total，不是 `done+1`/total 的「正在处理第几个」：这些源是
      // **并行**取的，压根没有「当前第几个」这回事。写 done+1 的后果是最后
      // 一个还在转圈时就显示 2/2，看着像已经完成了（2026-09-21 用户截图）。
      _submitStatus = label == null
          ? null
          : progress.total > 1
          ? '$label ${progress.done}/${progress.total}'
          : label;
    });
  }

  /// 真正要发出去的那一串：小尾巴在这里现求值。
  Future<String> _composeForSubmit() async {
    // ⛔ 编辑模式原样发回去，**绝不重新求值**：用户点的是「编辑」，照模板重算
    // 等于把他已经发出去的那句话偷偷换成另一句。compose 在这里只做扶正与硬化。
    if (_rawEditMode) {
      return CommentMarkup.compose(body: widget.controller.text);
    }

    final signature = !_signatureEnabled
        ? null
        : await _signatureService.render(
            _signatureTemplate,
            context: widget.signatureContext,
            // 预览里点过「生成」就用他看见的那一句，别再取一次新的。
            pinned: _pinnedSignatureValues,
            onProgress: _onSignatureProgress,
          );

    String build(String? sig) => CommentMarkup.compose(
      body: widget.controller.text,
      quote: _quoteEnabled ? _quote : null,
      signature: sig,
    );

    final composed = build(signature);
    if (composed.length <= widget.maxLength ||
        signature == null ||
        signature.isEmpty) {
      return composed;
    }

    // 估算（[_estimatedSignature]）和真值对不上时会走到这里：一言比上次那句
    // 长了二十个字，正文又正好写到额度顶，总长就超了。用户写的正文一个字都
    // 不能动，所以砍小尾巴——砍到放不下就整条不要。
    // ⛔ 反过来（截正文、或者原样发出去让服务端拒绝）都等于「写了半天发不出
    // 去」，那比少一句签名严重得多。
    final overflow = composed.length - widget.maxLength;
    final room = signature.length - overflow - 1;
    return build(
      room >= 8 ? '${signature.substring(0, room).trimRight()}…' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? errorText =
        widget.errorText ??
        (_currentLength > widget.maxLength
            ? t.errors.exceedsMaxLength(max: widget.maxLength.toString())
            : null);
    final bool canSubmit =
        widget.controller.text.trim().isNotEmpty &&
        _currentLength <= widget.maxLength;
    final quote = _quote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 引用卡片：这条回复冲着哪一楼去。勾选框控制带不带，**不勾也在场**。
        if (quote != null)
          GlassQuoteCard(
            floor: quote.floor,
            username: quote.username,
            excerpt: quote.excerpt,
            enabled: _quoteEnabled,
            onToggle: widget.enabled && !widget.isLoading ? _toggleQuote : null,
          ),

        // 输入域：玻璃壳包住无边框输入控件
        GlassInputSurface(
          child: widget.showEmojiPicker
              ? EnhancedEmojiTextField(
                  key: widget.emojiTextFieldKey,
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  minLines: widget.maxLines,
                  // 这只控件从来不把 maxLength 传给底层输入框（只用来画计数），
                  // 所以本来就不会硬截断——与下面那支 TextField 的
                  // MaxLengthEnforcement.none 是同一个行为。
                  maxLength: _bodyBudget,
                  // 计数由底栏统一报（只在接近上限时出现），这里不重复画
                  showCounter: false,
                  decoration: glassFieldDecoration(
                    context,
                    hint: widget.hintText,
                    errorText: errorText,
                  ),
                  // ⛔ 这里不再自己记长度：controller 的监听器已经把
                  // `_currentLength` 记成**最终文本**的长度，而 onChanged 给的
                  // `value` 只是输入框里的正文。两处都写的话，后跑的 onChanged
                  // 每次敲键都会把引用头 / 小尾巴那段开销抹掉，超限判定又退回
                  // 「提交那一刻才发现」。
                  enabled: widget.enabled && !widget.isLoading,
                  focusNode: widget.focusNode,
                )
              : TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  minLines: widget.maxLines,
                  maxLength: _bodyBudget,
                  // ⛔ 超限**不拦输入**，只由底栏变色 + 禁用发送来说话。
                  // X / Mastodon / Bluesky 三家一致：硬截断会在用户正打字时
                  // 悄悄吞掉字符，他既不知道被吞了、也不知道从哪儿改起。
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  enabled: widget.enabled && !widget.isLoading,
                  focusNode: widget.focusNode,
                  decoration: glassFieldDecoration(
                    context,
                    hint: widget.hintText,
                    errorText: errorText,
                    // 字数由底栏统一报（且只在接近上限时才出现），
                    // 这里不再重复画一个常驻计数。
                    counterText: '',
                  ),
                  // 长度同样只由 controller 的监听器记（理由见上面那支）。
                ),
        ),

        const SizedBox(height: 12),

        // 单行底栏：动作 · 状态 · 字数 · 发送。
        // 收口前这里是上下两行（工具行 + 动作行），各自只装一两件东西、
        // 左右都是大片空白；合成一行之后省下的高度全部还给写作区——那才是
        // 这类界面唯一值得优化的量。
        Obx(() {
          // ⛔ 这一读必须**无条件**先发生：Obx 靠 build 期间读到的 Rx 建立订阅，
          // 一条都没读到会当场抛「improper use of a GetX」。把它写进三目的分支里，
          // 在 showRulesAgreement: false 的调用点（个人简介弹窗）就会短路成零读取。
          final bool agreedNow =
              _configService[ConfigKey.RULES_AGREEMENT_KEY] as bool;
          final bool? rulesAgreed = widget.showRulesAgreement
              ? agreedNow
              : null;
          final bool blocked = rulesAgreed == false;
          return GlassComposerBar(
            onSubmit: widget.onSubmit == null || !canSubmit || blocked
                ? null
                : _handleSubmit,
            // 只差「同意规则」时按钮仍可点，点下去弹规则全文；置灰又点不动
            // 会让人以为是坏了。
            onBlockedTap: blocked && canSubmit ? _showRulesDialog : null,
            submitText: widget.submitText,
            isLoading: widget.isLoading || _submitting,
            statusText: _submitStatus,
            onEmoji: widget.showEmojiPicker ? _showEmojiPickerDialog : null,
            onPreview: widget.showPreview ? _showPreview : null,
            previewHasContent: widget.controller.text.trim().isNotEmpty,
            onTranslate: widget.showTranslation
                ? () => showAppDialog(
                    TranslationDialog(
                      text: widget.controller.text,
                      defaultLanguageKeyMode: false,
                    ),
                    barrierDismissible: true,
                  )
                : null,
            translateEnabled: widget.controller.text.isNotEmpty,
            onMarkdownHelp: widget.showMarkdownHelp ? _showMarkdownHelp : null,
            rulesAgreed: rulesAgreed,
            onRulesTap: widget.showRulesAgreement ? _showRulesDialog : null,
            // 引用开关：引用条在场时那里更顺手，但菜单是恒定入口，
            // 两处读写同一个持久化配置。
            showQuoteToggle: _quote != null,
            quoteEnabled: _quoteEnabled,
            onQuoteToggle: _toggleQuote,
            showSignatureToggle: _showSignatureToggle,
            signatureEnabled: _signatureEnabled,
            signatureConfigured: _signatureConfigured,
            onSignatureSetup: NaviService.navigateToChatSettingsPage,
            onSignatureToggle: () => setState(() {
              _signatureEnabled = !_signatureEnabled;
              // 同上：写回持久化配置
              _configService[ConfigKey.ENABLE_SIGNATURE_KEY] =
                  _signatureEnabled;
              _currentLength = _composed().length;
            }),
            length: widget.controller.text.length,
            limit: _bodyBudget,
          );
        }),
      ],
    );
  }
}
