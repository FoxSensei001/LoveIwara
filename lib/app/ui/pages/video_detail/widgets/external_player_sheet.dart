import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/app/services/external_player_service.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 打开「用其他应用打开」面板，把 [source] 转交给本机其它播放器。
///
/// 面板本身不判断有没有可用播放器（Android 上会数，但空列表也照样把入口摆出来
/// 并在点下去后给一条明确提示）——「装了播放器但没被系统索引到」比「真没装」
/// 更常见，直接隐藏入口会让用户以为功能没做。
Future<void> showExternalPlayerSheet(ExternalPlayerSource source) async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  await showGlassBottomSheet<void>(
    context: context,
    builder: (_) => _ExternalPlayerSheet(source: source),
  );
}

class _ExternalPlayerSheet extends StatefulWidget {
  const _ExternalPlayerSheet({required this.source});

  final ExternalPlayerSource source;

  @override
  State<_ExternalPlayerSheet> createState() => _ExternalPlayerSheetState();
}

class _ExternalPlayerSheetState extends State<_ExternalPlayerSheet> {
  ExternalPlayerSource get source => widget.source;

  /// 桌面端用户自己配的播放器（PCVR 播放器全靠这条路）。移动端恒为空。
  late final List<DesktopPlayerEntry> _desktopPlayers = GetPlatform.isDesktop
      ? DesktopPlayerStore.load()
      : const [];

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // 桌面端没有「用其它应用打开」的选择器，只有「交给系统默认程序」。
    final bool isDesktop = GetPlatform.isDesktop;
    final bool canHandOff = ExternalPlayerService.supports(source);

    return GlassBottomSheet(
      title: t.externalPlayer.title,
      scrollable: true,
      maxHeightFactor: 0.8,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.externalPlayer.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _SourceBadge(source: source),
              ],
            ),
          ),
          // 桌面端：先列用户配置的播放器（本地文件和在线直链都能交给它们），
          // 「系统默认程序」反而是次选——PCVR 播放器不是系统默认关联程序。
          for (final player in _desktopPlayers)
            ListTile(
              leading: Icon(Icons.smart_display_outlined, color: cs.primary),
              title: Text(
                t.externalPlayer.openWithNamed(name: player.name),
              ),
              subtitle: Text(
                player.executablePath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _handOffToDesktopPlayer(context, t, player),
            ),
          if (canHandOff)
            ListTile(
              leading: Icon(
                isDesktop ? Icons.play_circle_outline : Icons.open_in_new,
                color: cs.primary,
              ),
              title: Text(
                isDesktop
                    ? t.externalPlayer.openWithSystemPlayer
                    : t.externalPlayer.openWithOtherApp,
              ),
              subtitle: Text(
                isDesktop
                    ? t.externalPlayer.openWithSystemPlayerDescription
                    : t.externalPlayer.openWithOtherAppDescription,
              ),
              onTap: () => _handOff(context, t),
            ),
          if (!source.isLocalFile)
            ListTile(
              leading: Icon(Icons.link, color: cs.primary),
              title: Text(t.externalPlayer.copyLink),
              subtitle: Text(t.externalPlayer.copyLinkDescription),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: source.value));
                if (!context.mounted) return;
                Navigator.of(context).pop();
                showGlassToast(t.externalPlayer.linkCopied);
              },
            ),
          if (isDesktop)
            ListTile(
              leading: Icon(Icons.tune, color: cs.onSurfaceVariant),
              title: Text(t.externalPlayer.managePlayersEntry),
              subtitle: Text(
                _desktopPlayers.isEmpty
                    ? t.externalPlayer.noPlayerConfigured
                    : t.externalPlayer.playerCount(
                        count: _desktopPlayers.length,
                      ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                appRouter.push(SettingsSection.player.path);
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!source.isLocalFile)
                  _HintLine(text: t.externalPlayer.onlineLinkExpiryHint),
                if (!isDesktop)
                  _HintLine(text: t.externalPlayer.vrPlayerHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handOffToDesktopPlayer(
    BuildContext context,
    slang.Translations t,
    DesktopPlayerEntry player,
  ) async {
    final navigator = Navigator.of(context);
    final result = await ExternalPlayerService.openWithDesktopPlayer(
      player,
      source,
    );
    if (navigator.mounted) navigator.pop();
    _reportResult(t, result);
  }

  Future<void> _handOff(BuildContext context, slang.Translations t) async {
    final navigator = Navigator.of(context);
    final result = await ExternalPlayerService.open(
      source,
      chooserTitle: t.externalPlayer.title,
    );
    if (navigator.mounted) navigator.pop();
    _reportResult(t, result);
  }

  void _reportResult(
    slang.Translations t,
    ExternalPlayerHandoffResult result,
  ) {
    switch (result.status) {
      case ExternalPlayerHandoffStatus.handedOff:
        showGlassToast(t.externalPlayer.handedOff);
      case ExternalPlayerHandoffStatus.noHandler:
        showGlassToast(
          t.externalPlayer.noHandler,
          type: GlassToastType.warning,
        );
      case ExternalPlayerHandoffStatus.unsupported:
        showGlassToast(
          t.externalPlayer.noHandler,
          type: GlassToastType.warning,
        );
      case ExternalPlayerHandoffStatus.fileMissing:
        showGlassToast(
          t.externalPlayer.localFileMissing,
          type: GlassToastType.error,
        );
      case ExternalPlayerHandoffStatus.executableMissing:
        showGlassToast(
          t.externalPlayer.executableMissing,
          type: GlassToastType.error,
        );
      case ExternalPlayerHandoffStatus.failed:
        final message = result.message;
        showGlassToast(
          message == null || message.isEmpty
              ? t.externalPlayer.handoffFailedUnknown
              : t.externalPlayer.handoffFailed(message: message),
          type: GlassToastType.error,
        );
    }
  }
}

/// 交出去的到底是哪一份：本地文件，还是当前清晰度的在线直链。
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final ExternalPlayerSource source;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final String label;
    if (source.isLocalFile) {
      label = t.externalPlayer.sourceLocal;
    } else if (source.qualityTag != null && source.qualityTag!.isNotEmpty) {
      label = t.externalPlayer.sourceOnlineWithQuality(
        quality: source.qualityTag!,
      );
    } else {
      label = t.externalPlayer.sourceOnline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            source.isLocalFile ? Icons.sd_storage_outlined : Icons.cloud_queue,
            size: 16,
            color: cs.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintLine extends StatelessWidget {
  const _HintLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
