import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/player_notice.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/mpv_playback_error_classifier.dart';

/// 展示播放问题台账。
///
/// 这里是 mpv 原始日志文本唯一的呈现位置：提示条只给本地化的结论，
/// 原始文本折叠在 ExpansionTile 里，避免把 `ffurl_write returned 0x...`
/// 这类对用户无意义的内容直接怼到播放器上。
void showPlaybackIssueSheet(PlayerNoticeCenter center) {
  // 打开瞬间快照一份，弹窗生命周期内不再随后续日志抖动
  final issues = center.notableIssues;
  showAppBottomSheet(
    _PlaybackIssueSheet(issues: issues),
    isScrollControlled: true,
    elevation: 0,
  );
}

class _PlaybackIssueSheet extends StatelessWidget {
  final List<PlaybackIssue> issues;

  const _PlaybackIssueSheet({required this.issues});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isNarrowScreen = screenSize.width < 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: isNarrowScreen ? screenSize.height * 0.8 : 600,
        maxWidth: isNarrowScreen ? screenSize.width : 400,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isNarrowScreen ? const Radius.circular(16) : Radius.zero,
          bottomRight: isNarrowScreen ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.all(isNarrowScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: Theme.of(context).primaryColor,
                  size: isNarrowScreen ? 20 : 24,
                ),
                SizedBox(width: isNarrowScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    t.mediaPlayer.notice.issuesSheetTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: isNarrowScreen ? 18 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Flexible(
            child: issues.isEmpty
                ? _buildEmptyState(context, isNarrowScreen)
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.all(isNarrowScreen ? 12 : 16),
                    itemCount: issues.length,
                    itemBuilder: (context, index) =>
                        _buildIssueCard(context, issues[index], isNarrowScreen),
                  ),
          ),

          // 底部按钮
          Container(
            padding: EdgeInsets.only(
              left: isNarrowScreen ? 12 : 16,
              right: isNarrowScreen ? 12 : 16,
              top: isNarrowScreen ? 12 : 16,
              bottom: isNarrowScreen
                  ? 12 + MediaQuery.of(context).padding.bottom
                  : 16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    // 导出日志的完整能力在「诊断与反馈」里，这里只负责把用户送过去
                    onPressed: () {
                      Navigator.of(context).pop();
                      NaviService.navigateToDiagnosticsSettingsPage();
                    },
                    icon: Icon(
                      Icons.bug_report_outlined,
                      size: isNarrowScreen ? 16 : 18,
                    ),
                    label: Text(
                      t.mediaPlayer.notice.exportLogsAction,
                      style: TextStyle(fontSize: isNarrowScreen ? 12 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isNarrowScreen ? 8 : 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isNarrowScreen ? 8 : 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    t.common.close,
                    style: TextStyle(fontSize: isNarrowScreen ? 12 : 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isNarrowScreen) {
    final t = slang.Translations.of(context);

    return Padding(
      padding: EdgeInsets.all(isNarrowScreen ? 24 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: isNarrowScreen ? 48 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isNarrowScreen ? 12 : 16),
          Text(
            t.mediaPlayer.notice.noIssuesRecorded,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isNarrowScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(
    BuildContext context,
    PlaybackIssue issue,
    bool isNarrowScreen,
  ) {
    final t = slang.Translations.of(context);
    final position = issue.positionAtFirst;

    // 副标题：出现次数 +（若已知）首次出现的播放位置
    final subtitleParts = <String>[
      t.mediaPlayer.notice.issueOccurrences(count: issue.occurrences),
      if (position != null)
        t.mediaPlayer.notice.issueAtPosition(
          position: CommonUtils.formatDuration(position),
        ),
    ];

    return Card(
      margin: EdgeInsets.only(bottom: isNarrowScreen ? 6 : 8),
      child: Theme(
        // ExpansionTile 默认会给展开态加分割线，这里去掉以贴近列表卡片风格
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 8 : 16,
            vertical: isNarrowScreen ? 0 : 4,
          ),
          leading: Icon(
            _iconOfTier(issue.tier),
            color: _colorOfTier(context, issue.tier),
            size: isNarrowScreen ? 20 : 24,
          ),
          title: Text(
            _labelOfKind(context, issue.kind),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: isNarrowScreen ? 14 : 16,
            ),
          ),
          subtitle: Text(
            subtitleParts.join(' · '),
            style: TextStyle(fontSize: isNarrowScreen ? 12 : 14),
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            isNarrowScreen ? 8 : 16,
            0,
            isNarrowScreen ? 8 : 16,
            isNarrowScreen ? 8 : 12,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isNarrowScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              // mpv 原始文本仅出现在这里，方便反馈时直接复制
              child: SelectableText(
                issue.sampleText,
                style: TextStyle(
                  fontSize: isNarrowScreen ? 11 : 12,
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconOfTier(PlaybackErrorTier tier) {
    switch (tier) {
      case PlaybackErrorTier.degraded:
        return Icons.warning_amber_rounded;
      case PlaybackErrorTier.transient:
      case PlaybackErrorTier.silent:
        return Icons.info_outline;
    }
  }

  Color _colorOfTier(BuildContext context, PlaybackErrorTier tier) {
    switch (tier) {
      case PlaybackErrorTier.degraded:
        return Colors.orange;
      case PlaybackErrorTier.transient:
      case PlaybackErrorTier.silent:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// 把分类器的内部类型翻译成用户能看懂的结论
  String _labelOfKind(BuildContext context, PlaybackErrorKind kind) {
    final t = slang.Translations.of(context);
    switch (kind) {
      case PlaybackErrorKind.networkReconnect:
      case PlaybackErrorKind.networkUnreachable:
        return t.mediaPlayer.notice.networkUnstable;
      case PlaybackErrorKind.audioUnavailable:
        return t.mediaPlayer.notice.audioTrackUnavailable;
      case PlaybackErrorKind.hardwareDecodeFallback:
        return t.mediaPlayer.notice.hardwareDecodeFellBack;
      case PlaybackErrorKind.videoDecodeProblem:
      case PlaybackErrorKind.decodeGlitch:
        return t.mediaPlayer.notice.videoDecodeProblem;
      case PlaybackErrorKind.duplicateSummary:
        return t.mediaPlayer.notice.repeatedPlaybackProblems;
      case PlaybackErrorKind.openFailed:
      case PlaybackErrorKind.auxFileSkipped:
        return t.mediaPlayer.videoLoadFailed;
      case PlaybackErrorKind.unknown:
        return t.common.unknownError;
    }
  }
}
