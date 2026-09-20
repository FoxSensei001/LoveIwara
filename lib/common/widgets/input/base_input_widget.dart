import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
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
/// ## 输入框里只有用户自己的字
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
/// 这三件事的修法是同一件：不让用户碰到语法。
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

  /// 既有正文（编辑已发布内容时用）。会先过 [CommentMarkup.parse] 拆掉
  /// 引用头与小尾巴，输入框里只留作者自己写的那部分；提交时再原样接回去。
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
  });

  @override
  State<BaseInputWidget> createState() => _BaseInputWidgetState();
}

class _BaseInputWidgetState extends State<BaseInputWidget> {
  final ConfigService _configService = Get.find<ConfigService>();
  late EmojiSize _selectedEmojiSize;
  int _currentLength = 0;

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

    // 既有正文：拆掉结构，输入框里只留作者自己写的那部分。编辑一条带引用的
    // 旧回复时，引用会回到上方的卡片里，而不是继续躺在输入框里等着被改坏。
    final existing = widget.initialContent;
    if (existing != null && existing.isNotEmpty) {
      final parsed = CommentMarkup.parse(
        existing,
        knownSignature: _configService[ConfigKey.SIGNATURE_CONTENT_KEY],
      );
      // 编辑既有内容：原样保留它本来有什么，不受配置影响——用户点的是
      // 「编辑」，不是「按我现在的偏好重写一遍」。
      if (parsed.quote != null) {
        _quote ??= parsed.quote;
        _quoteEnabled = true;
      }
      if (parsed.footer != null) _signatureEnabled = widget.allowSignature;
      final body = CommentMarkup.softenLineBreaks(parsed.body);
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
    return CommentMarkup.compose(
      body: body,
      quote: _quoteEnabled ? _quote : null,
      signature: _signatureEnabled
          ? _configService[ConfigKey.SIGNATURE_CONTENT_KEY]
          : null,
    );
  }

  /// 本弹窗要不要露出小尾巴开关：参与小尾巴、且用户确实配过内容。
  /// 没配过的人不该看见一个自己从来没用过的开关。
  bool get _showSignatureToggle {
    if (!widget.allowSignature) return false;
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

  /// 预览给的是**发出去的样子**，不是输入框里的样子——引用块和小尾巴都在内。
  void _showPreview() {
    MarkdownPreviewHelper.showPreview(context, _composed());
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

  void _handleSubmit() {
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

    widget.onSubmit?.call(_composed());
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
            onToggle: widget.enabled && !widget.isLoading
                ? _toggleQuote
                : null,
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
                  onChanged: (value) {
                    setState(() {
                      _currentLength = value.length;
                    });
                  },
                  enabled: widget.enabled && !widget.isLoading,
                  focusNode: widget.focusNode,
                  onEmojiInserted: (imageUrl) {
                    setState(() {
                      _currentLength = widget.controller.text.length;
                    });
                  },
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
                  onChanged: (value) {
                    setState(() {
                      _currentLength = value.length;
                    });
                  },
                ),
        ),

        const SizedBox(height: 12),

        // 单行底栏：动作 · 状态 · 字数 · 发送。
        // 收口前这里是上下两行（工具行 + 动作行），各自只装一两件东西、
        // 左右都是大片空白；合成一行之后省下的高度全部还给写作区——那才是
        // 这类界面唯一值得优化的量。
        Obx(() {
          final bool? rulesAgreed = widget.showRulesAgreement
              ? _configService[ConfigKey.RULES_AGREEMENT_KEY] as bool
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
            isLoading: widget.isLoading,
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
