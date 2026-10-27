import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/poll/poll_embed_card.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 投票页（`/poll/:id`）。
///
/// 与网页端一致，页面上只有这一张投票卡片：投票没有评论、也不挂在别的内容下。
/// 外部打开的投票链接、正文里带文字的投票链接都进这一页。
class PollDetailPage extends StatelessWidget {
  const PollDetailPage({super.key, required this.pollId});

  final String pollId;

  /// 用 www 主站写法：网页端只在「链接 host 等于当前页面 host」时才嵌入卡片。
  String get _shareUrl => '${CommonConstants.iwaraBaseUrl}/poll/$pollId';

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _shareUrl));
    showAppToast(slang.t.common.copiedToClipboard, type: AppToastType.success);
  }

  Widget _buildHeader(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.arrow_back),
            tooltip: t.common.back,
            onPressed: () => AppService.tryPop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GlassTitlePill(title: t.poll.title),
            ),
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.link),
            tooltip: t.poll.copyLink,
            onPressed: _copyLink,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        header: _buildHeader(context),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            12,
            headerExtent + 8,
            12,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: PollEmbedCard(pollId: pollId),
            ),
          ),
        ),
      ),
    );
  }
}
