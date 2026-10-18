import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/iwara_poll.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/poll_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_language_selector.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 嵌在正文里的 Iwara 投票卡片。
///
/// 正文里的投票链接由 `MarkdownFormatter.formatPollEmbeds` 改写成占位，
/// `CustomMarkdownBody` 的图片 builder 认到占位就换成这张卡片；独立的投票页
/// 也只放这一张。状态在 [PollService] 里按 id 共享，这里只订阅。
///
/// 与网页端的两处差别（2026-10-18 用户拍板）：
/// - 网页端点一下选项就直接投出；这里先点选、再按「投票」确认。投出后改不了
///   （服务端改投不更新票数），手机上滚动时又容易误触。
/// - 同网页端：已登录、还没投时不显示票数（接口其实给了），未登录直接看结果。
///
/// 网页端没有翻译；这里标题行右侧放一枚翻译胶囊（与评论同款：翻译钮 + 语言
/// 选择），译文按投票共享（见 [PollState.translation]）。
class PollEmbedCard extends StatefulWidget {
  const PollEmbedCard({super.key, required this.pollId});

  final String pollId;

  @override
  State<PollEmbedCard> createState() => _PollEmbedCardState();
}

class _PollEmbedCardState extends State<PollEmbedCard> {
  static const _sizeDuration = Duration(milliseconds: 240);
  static const _switchDuration = Duration(milliseconds: 200);

  late Rx<PollState> _state;
  int? _selectedOptionId;

  PollService get _service => Get.find<PollService>();

  @override
  void initState() {
    super.initState();
    _state = _service.watch(widget.pollId);
  }

  @override
  void didUpdateWidget(covariant PollEmbedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pollId != widget.pollId) {
      _state = _service.watch(widget.pollId);
      _selectedOptionId = null;
    }
  }

  Future<void> _submitVote() async {
    final optionId = _selectedOptionId;
    if (optionId == null) return;
    final result = await _service.vote(widget.pollId, optionId);
    if (!mounted) return;
    if (!result.isSuccess) {
      showAppToast(
        result.message.isNotEmpty ? result.message : slang.t.poll.voteFailed,
        type: AppToastType.error,
      );
    }
  }

  Future<void> _runTranslation(
    Future<ApiResult<void>> Function() action,
  ) async {
    final result = await action();
    if (!mounted || result.isSuccess) return;
    showAppToast(
      result.message.isNotEmpty ? result.message : slang.t.poll.translateFailed,
      type: AppToastType.error,
    );
  }

  /// 翻译胶囊：翻译钮（翻译中转圈，显示译文时高亮）+ 紧凑语言选择。
  Widget _buildTranslateControls(BuildContext context, PollState state) {
    final cs = Theme.of(context).colorScheme;
    final configService = Get.find<ConfigService>();
    const height = 28.0;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: slang.Translations.of(context).common.translate,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: state.translating
                    ? null
                    : () => _runTranslation(
                        () => _service.toggleTranslation(widget.pollId),
                      ),
                child: Container(
                  height: height,
                  padding: const EdgeInsets.only(left: 10, right: 4),
                  alignment: Alignment.center,
                  child: state.translating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.translate,
                          size: 16,
                          color: state.showTranslation
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                ),
              ),
            ),
            // 语言选择器自己不带尺寸，尺寸由这只槽位说了算
            Obx(
              () => SizedBox(
                width: 34,
                height: height,
                child: TranslationLanguageSelector(
                  compact: true,
                  extrimCompact: true,
                  selectedLanguage: configService.currentTranslationSort,
                  onLanguageSelected: (sort) {
                    configService.updateTranslationLanguage(sort);
                    // 第一次翻译还在转圈时换语言也要重翻，不然显示的是旧语言
                    final current = _state.value;
                    if (current.showTranslation || current.translating) {
                      _runTranslation(() => _service.translate(widget.pollId));
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: AnimatedSize(
        duration: _sizeDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Obx(() {
          final state = _state.value;
          // 不在投票表单里（已投、换了账号、登出）时丢掉上一次的点选，免得表单
          // 再出现时带着旧选择、「投票」钮已经亮着。只改字段、不 setState：
          // 此刻显示的是结果视图，用不到它。
          if (!state.canVote) _selectedOptionId = null;
          return AnimatedSwitcher(
            duration: _switchDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(
              key: ValueKey(_viewKey(state)),
              child: _buildBody(context, state),
            ),
          );
        }),
      ),
    );
  }

  /// 视图切换的身份：同一视图内的数据变化（票数、提交中）不触发淡入淡出。
  String _viewKey(PollState state) {
    switch (state.status) {
      case PollLoadStatus.loading:
        return 'loading';
      case PollLoadStatus.notFound:
        return 'notFound';
      case PollLoadStatus.error:
        return 'error';
      case PollLoadStatus.ready:
        return state.canVote ? 'vote' : 'results';
    }
  }

  Widget _buildBody(BuildContext context, PollState state) {
    switch (state.status) {
      case PollLoadStatus.loading:
        return const _PollSkeleton();
      case PollLoadStatus.notFound:
        return _PollNotice(
          icon: Icons.poll_outlined,
          text: slang.t.poll.notFound,
        );
      case PollLoadStatus.error:
        return _PollNotice(
          icon: Icons.error_outline,
          text: state.errorMessage?.isNotEmpty == true
              ? state.errorMessage!
              : slang.t.poll.loadFailed,
          action: TextButton(
            onPressed: () => _service.load(widget.pollId),
            child: Text(slang.t.common.retry),
          ),
        );
      case PollLoadStatus.ready:
        final poll = state.poll!;
        final translation = state.showTranslation ? state.translation : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _PollHeader(
              poll: poll,
              translatedTitle: translation?.title,
              trailing: _buildTranslateControls(context, state),
            ),
            const SizedBox(height: 10),
            if (state.canVote)
              _buildVoteForm(context, poll, state, translation)
            else
              _PollResults(poll: poll, translation: translation),
            const SizedBox(height: 10),
            _buildFooter(context, poll, state),
          ],
        );
    }
  }

  Widget _buildVoteForm(
    BuildContext context,
    IwaraPoll poll,
    PollState state,
    PollTranslation? translation,
  ) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final submitting = state.votingOptionId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.poll.chooseThenVote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (final option in poll.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _PollOptionTile(
              option: option,
              translated: translation?.options[option.id],
              selected: _selectedOptionId == option.id,
              submitting: state.votingOptionId == option.id,
              enabled: !submitting,
              onTap: () => setState(() => _selectedOptionId = option.id),
            ),
          ),
        // 选中之后才出现「投票」行，出入都带高度与淡入淡出过渡。
        AnimatedSize(
          duration: _sizeDuration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: _switchDuration,
            child: _selectedOptionId == null
                ? const SizedBox(width: double.infinity, key: ValueKey('none'))
                : Padding(
                    key: const ValueKey('submit'),
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.poll.voteIrreversible,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: submitting ? null : _submitVote,
                          child: submitting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : Text(t.poll.vote),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, IwaraPoll poll, PollState state) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
    );
    final user = poll.user;
    final showLogin =
        !state.fetchedWithAuth && !Get.find<UserService>().isAuthenticated;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (user != null)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => NaviService.navigateToAuthorProfilePage(
              user.username,
              initialUser: user,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarWidget(user: user, size: 20),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: metaStyle?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (poll.createdAt != null)
          Text(
            CommonUtils.formatFriendlyTimestamp(
              poll.createdAt,
              includeTime: false,
            ),
            style: metaStyle,
          ),
        Text(t.poll.totalVotes(count: poll.numVotes), style: metaStyle),
        if (showLogin)
          TextButton.icon(
            onPressed: LoginService.showLogin,
            icon: const Icon(Icons.login, size: 16),
            label: Text(t.poll.loginToVote),
          ),
        // 后台重拉失败（例如登录后那次带登录态的重拉）：照旧显示手上的内容，
        // 给一个重试入口，否则已登录的人会卡在结果视图、投不了也没处重试。
        if (state.errorMessage != null)
          TextButton.icon(
            onPressed: () => _service.load(widget.pollId),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(t.common.retry),
          ),
      ],
    );
  }
}

class _PollHeader extends StatelessWidget {
  const _PollHeader({
    required this.poll,
    required this.trailing,
    this.translatedTitle,
  });

  final IwaraPoll poll;
  final String? translatedTitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.poll_outlined, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                slang.Translations.of(context).poll.title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
        const SizedBox(height: 6),
        _TranslatableText(
          original: poll.title,
          translated: translatedTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PollOptionTile extends StatelessWidget {
  const _PollOptionTile({
    required this.option,
    this.translated,
    required this.selected,
    required this.submitting,
    required this.enabled,
    required this.onTap,
  });

  final IwaraPollOption option;
  final String? translated;
  final bool selected;
  final bool submitting;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(10);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: selected
                ? cs.primary.withValues(alpha: 0.12)
                : cs.surface.withValues(alpha: 0.5),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.7)
                  : cs.outlineVariant.withValues(alpha: 0.7),
              width: selected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: submitting
                    ? Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      )
                    : Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TranslatableText(
                  original: option.title,
                  translated: translated,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled || selected
                        ? cs.onSurface
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollResults extends StatelessWidget {
  const _PollResults({required this.poll, this.translation});

  final IwaraPoll poll;
  final PollTranslation? translation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = slang.Translations.of(context);
    final total = poll.numVotes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in poll.options) ...[
          _PollResultRow(
            option: option,
            translated: translation?.options[option.id],
            fraction: total > 0 ? option.numVotes / total : 0,
            isMine: option.id == poll.vote,
          ),
          const SizedBox(height: 10),
        ],
        if (poll.vote != null)
          Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                t.poll.youVoted,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.primary),
              ),
            ],
          ),
      ],
    );
  }
}

class _PollResultRow extends StatelessWidget {
  const _PollResultRow({
    required this.option,
    this.translated,
    required this.fraction,
    required this.isMine,
  });

  final IwaraPollOption option;
  final String? translated;
  final double fraction;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final percent = (fraction * 100).round();
    final barColor = isMine ? cs.primary : cs.primary.withValues(alpha: 0.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TranslatableText(
                original: option.title,
                translated: translated,
                trailing: isMine
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.check, size: 16, color: cs.primary),
                      )
                    : null,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${option.numVotes} · $percent%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.08),
              ),
              // 结果出现时进度条从 0 长到实际比例；票数变化时从旧值接着长。
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: barColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 加载占位：标题条加三根选项条，高度接近成品，加载完正文不会猛跳。
class _PollSkeleton extends StatelessWidget {
  const _PollSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.07);
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        bar(0.2, 12),
        const SizedBox(height: 10),
        bar(0.7, 18),
        const SizedBox(height: 14),
        bar(1, 40),
        const SizedBox(height: 6),
        bar(1, 40),
        const SizedBox(height: 6),
        bar(1, 40),
      ],
    );
  }
}

/// 一行说明（已删除 / 出错），不占大块位置。
class _PollNotice extends StatelessWidget {
  const _PollNotice({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

/// 有译文时：译文在上（沿用原来的字样），原文缩小变灰在下；译文与原文相同
/// 就只显示一行。原文那一行的出入带高度过渡。
class _TranslatableText extends StatelessWidget {
  const _TranslatableText({
    required this.original,
    this.translated,
    this.style,
    this.trailing,
  });

  final String original;
  final String? translated;
  final TextStyle? style;

  /// 跟在主文字后面的小部件（结果行里自己那项的勾）。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translatedText = translated?.trim();
    final showBoth =
        translatedText != null &&
        translatedText.isNotEmpty &&
        translatedText != original.trim();
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: showBoth ? translatedText : original),
                if (trailing != null)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: trailing!,
                  ),
              ],
            ),
            style: style,
          ),
          if (showBoth)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                original,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
