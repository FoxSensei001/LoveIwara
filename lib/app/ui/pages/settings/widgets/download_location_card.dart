import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/change_download_location_sheet.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_test_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/manual_download_path_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

// ---------------------------------------------------------------------------
// 友好名：页面、更改位置面板、确认弹窗共用同一套叫法
// ---------------------------------------------------------------------------

/// 位置的主标题：「下载 › LoveIwara」「SD 卡 › Movies」「应用专属空间」。
String downloadLocationTitle(DownloadLocation location) {
  final t = slang.t.download.location;
  if (location.kind == DownloadLocationKind.appPrivate) return t.appSpace;
  final segments = [
    for (var i = 0; i < location.segments.length; i++)
      i == 0 && location.startsWithDownloads
          ? t.downloadsFolder
          : location.segments[i],
  ];
  if (location.truncated && segments.isNotEmpty) {
    // 「下载 › … › A › B」或「… › A › B › C」
    if (location.startsWithDownloads) {
      segments.insert(1, '…');
    } else {
      segments.insert(0, '…');
    }
  }
  if (segments.isEmpty) return downloadVolumeName(location) ?? location.path;
  return segments.join(' › ');
}

/// 卷名：「内部存储」「SD 卡（XXXX-XXXX）」「外置盘 · 名字」；不显示卷名返回 null。
String? downloadVolumeName(DownloadLocation location) {
  final t = slang.t.download.location;
  switch (location.volume) {
    case DownloadVolumeKind.internal:
      return t.volumeInternal;
    case DownloadVolumeKind.sdCard:
      return location.volumeLabel == null
          ? t.volumeSdCard
          : '${t.volumeSdCard} (${location.volumeLabel})';
    case DownloadVolumeKind.externalDrive:
      return location.volumeLabel == null
          ? t.volumeExternalDrive
          : '${t.volumeExternalDrive} · ${location.volumeLabel}';
    case DownloadVolumeKind.appSpace:
      return null;
    case DownloadVolumeKind.none:
      return location.volumeLabel;
  }
}

IconData downloadLocationIcon(DownloadLocation location) {
  switch (location.kind) {
    case DownloadLocationKind.appPrivate:
      return Icons.lock_outline;
    case DownloadLocationKind.publicDownloads:
    case DownloadLocationKind.desktopDownloads:
      return Icons.download_for_offline_outlined;
    case DownloadLocationKind.removableVolume:
      return Icons.sd_card_outlined;
    case DownloadLocationKind.sharedStorage:
    case DownloadLocationKind.desktopOther:
    case DownloadLocationKind.other:
      return location.volume == DownloadVolumeKind.externalDrive
          ? Icons.usb_outlined
          : Icons.folder_outlined;
  }
}

// downloadFallbackReasonLabel 搬去了 download_location.dart（enum 旁），
// 与下载服务的完成回执共用同一份措辞。本文件经 download_path_service 的
// export 照常拿得到它。

/// 「卷名 · 剩余空间」，两样都没有返回 null。
String? downloadLocationCaption(DownloadLocation location, int? freeBytes) {
  final parts = [
    ?downloadVolumeName(location),
    if (freeBytes != null)
      slang.t.download.location.freeSpace(
        size: DownloadPathService.formatBytes(freeBytes),
      ),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

// ---------------------------------------------------------------------------
// 状态标签
// ---------------------------------------------------------------------------

enum _LocationTone { ok, warning, error, neutral }

/// 位置状态小标签（可写 / 需要授权 / 已临时回退 / 空间不足）。
/// 颜色随状态走 [GlassAnimatedColors]，文字换档走 [AnimatedSwitcher]。
class _StatusTag extends StatelessWidget {
  const _StatusTag({super.key, required this.label, required this.tone});

  final String label;
  final _LocationTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color fg = switch (tone) {
      _LocationTone.ok => Colors.green.shade600,
      _LocationTone.warning => Colors.orange.shade700,
      _LocationTone.error => cs.error,
      _LocationTone.neutral => cs.onSurfaceVariant,
    };
    return GlassAnimatedColors(
      colors: [fg.withValues(alpha: 0.14), fg],
      builder: (context, c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: c[0],
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedSwitcher(
          duration: GlassTokens.motionDuration,
          child: Text(
            label,
            key: ValueKey(label),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: c[1],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 当前位置卡
// ---------------------------------------------------------------------------

/// 下载设置页「保存位置」分组的主卡：
///
/// ```
/// 图标 + 友好名 + 状态标签（可写 / 需要授权[授权] / 已临时回退[修复] / 空间不足）
/// 卷名 · 剩余空间；完整路径小字（点一下复制）
/// [更改位置] [在文件管理器中打开(桌面)] [⋯ 复制路径 / 手动输入 / 恢复默认 / 运行诊断]
/// ```
///
/// 状态全部来自 [DownloadPathService.pathStatusRx]，本卡不做任何 I/O 判定。
class DownloadLocationCard extends StatefulWidget {
  const DownloadLocationCard({super.key});

  @override
  State<DownloadLocationCard> createState() => _DownloadLocationCardState();
}

class _DownloadLocationCardState extends State<DownloadLocationCard>
    with WidgetsBindingObserver {
  static const _tag = 'DownloadLocationCard';

  DownloadPathService get _service => DownloadPathService.to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_service.refreshPermissionAndRelated());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从系统设置（授权页）、文件管理器回来：权限 / 卷可能变了，重查一次。
    if (state == AppLifecycleState.resumed) {
      unawaited(_service.refreshPermissionAndRelated());
    }
  }

  Future<void> _grant(PathStatusInfo status) async {
    final target = status.targetPath;
    if (target == null) return;
    final granted = await _service.requestAccessFor(target);
    if (!granted) {
      showAppToast(
        slang.t.download.location.permissionDenied,
        type: AppToastType.warning,
      );
    }
  }

  Future<void> _fix(PathStatusInfo status) async {
    final t = slang.t.download.location;
    final target = status.targetPath;
    if (target == null) return;
    final result = await _service.probe(target);
    await _service.refreshPathStatus();
    if (!mounted) return;
    if (result.ok) {
      showAppToast(t.fixed, type: AppToastType.success);
      return;
    }
    if (result.outcome == DownloadProbeOutcome.needsPermission) {
      await _grant(status);
      return;
    }
    showAppToast(t.fixStillFailing, type: AppToastType.warning);
    if (!mounted) return;
    await startChangeDownloadLocation(context);
  }

  void _copyPath(String value) {
    Clipboard.setData(ClipboardData(text: value));
    showAppToast(
      slang.t.download.location.pathCopied,
      type: AppToastType.success,
    );
  }

  Future<void> _openInFileManager(String dir) async {
    try {
      if (!await Directory(dir).exists()) return;
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [dir]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [dir]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [dir]);
      }
    } catch (e) {
      LogUtils.w('打开文件管理器失败: $e', _tag);
    }
  }

  Future<void> _openMoreMenu(
    BuildContext anchorContext,
    PathStatusInfo? status,
  ) async {
    final t = slang.t.download.location;
    final shownPath = status?.targetPath ?? status?.currentPath;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        if (shownPath != null && shownPath.isNotEmpty)
          GlassMenuOption(value: 'copy', icon: Icons.copy, label: t.copyPath),
        GlassMenuOption(
          value: 'manual',
          icon: Icons.edit_outlined,
          label: t.manualInput,
        ),
        GlassMenuOption(
          value: 'default',
          icon: Icons.restore,
          label: t.restoreDefault,
        ),
        GlassMenuOption(
          value: 'diagnose',
          icon: Icons.science_outlined,
          label: t.runDiagnostics,
        ),
      ],
    );
    if (!mounted || picked == null) return;
    switch (picked) {
      case 'copy':
        if (shownPath != null) _copyPath(shownPath);
      case 'manual':
        final typed = await showManualDownloadPathDialog(
          initialPath: status?.targetPath ?? '',
        );
        if (typed != null) await applyDownloadLocation(typed);
      case 'default':
        await _service.restoreDefaultLocation();
        showAppToast(t.restoredDefault, type: AppToastType.success);
      case 'diagnose':
        if (mounted) DownloadTestWidget.showTestDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.location;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Obx(() {
      final status = _service.pathStatusRx.value;
      final loading = _service.isPathStatusLoading;
      final location = status?.location;
      final askEveryTime = status?.askEveryTime ?? _service.asksEveryTime;

      final String title;
      if (askEveryTime) {
        title = t.askEveryTime;
      } else if (location != null) {
        title = downloadLocationTitle(location);
      } else {
        title = t.statusChecking;
      }

      final ({String label, _LocationTone tone})? tag;
      if (status == null) {
        tag = (label: t.statusChecking, tone: _LocationTone.neutral);
      } else if (status.fallbackReason ==
          DownloadFallbackReason.needsPermission) {
        tag = (label: t.statusNeedsPermission, tone: _LocationTone.warning);
      } else if (status.isFallback) {
        tag = (label: t.statusFallback, tone: _LocationTone.error);
      } else if (status.isLowSpace) {
        tag = (label: t.statusLowSpace, tone: _LocationTone.warning);
      } else {
        tag = (label: t.statusWritable, tone: _LocationTone.ok);
      }

      final String? caption;
      if (askEveryTime && location != null) {
        caption = t.askEveryTimeDesc(location: downloadLocationTitle(location));
      } else if (location != null) {
        caption = downloadLocationCaption(location, status?.freeBytes);
      } else {
        caption = null;
      }
      final fullPath = status?.targetPath ?? status?.currentPath ?? '';

      final Widget? inlineAction;
      if (status != null &&
          status.fallbackReason == DownloadFallbackReason.needsPermission) {
        inlineAction = GlassButtonGroup(
          key: const ValueKey('grant'),
          children: [
            GlassTextActionButton(
              label: t.grant,
              emphasized: true,
              onPressed: () => _grant(status),
            ),
          ],
        );
      } else if (status != null && status.isFallback) {
        inlineAction = GlassButtonGroup(
          key: const ValueKey('fix'),
          children: [
            GlassTextActionButton(
              label: t.fix,
              emphasized: true,
              onPressed: () => _fix(status),
            ),
          ],
        );
      } else {
        inlineAction = null;
      }

      return GlassSettingSection(
        title: t.sectionTitle,
        divided: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: GlassAnimatedIcon(
                    icon: Icon(
                      askEveryTime
                          ? Icons.help_outline
                          : location == null
                          ? Icons.folder_outlined
                          : downloadLocationIcon(location),
                      size: 24,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: GlassTokens.motionDuration,
                            child: Text(
                              title,
                              key: ValueKey(title),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: GlassTokens.motionDuration,
                            child: askEveryTime
                                ? const SizedBox.shrink(key: ValueKey('no-tag'))
                                : _StatusTag(
                                    key: const ValueKey('tag'),
                                    label: tag.label,
                                    tone: tag.tone,
                                  ),
                          ),
                          AnimatedSwitcher(
                            duration: GlassTokens.motionDuration,
                            child: loading
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey('idle')),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: GlassTokens.motionDuration,
                        curve: GlassTokens.motionCurve,
                        alignment: Alignment.topLeft,
                        child: caption == null
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  caption,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                      ),
                      AnimatedSize(
                        duration: GlassTokens.motionDuration,
                        curve: GlassTokens.motionCurve,
                        alignment: Alignment.topLeft,
                        child: fullPath.isEmpty || askEveryTime
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: () => _copyPath(fullPath),
                                  child: Text(
                                    fullPath,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 回退说明：出现 / 消失都要过渡，不许硬切。
          AnimatedSize(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            alignment: Alignment.topCenter,
            child: status == null || !status.isFallback
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: cs.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.fallbackDetail(
                                    reason: downloadFallbackReasonLabel(
                                      status.fallbackReason!,
                                    ),
                                  ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onErrorContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  status.fallbackReason !=
                                          DownloadFallbackReason.needsPermission
                                      ? t.fallbackBanner
                                      : status.accessNeed ==
                                            StorageAccessNeed.allFilesAccess
                                      ? t.permissionAllFiles
                                      : t.permissionLegacy,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                const ChangeDownloadLocationButton(),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: GlassTokens.motionDuration,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child:
                      inlineAction ??
                      const SizedBox.shrink(key: ValueKey('no-action')),
                ),
                const Spacer(),
                GlassButtonGroup(
                  children: [
                    if (GetPlatform.isDesktop && !askEveryTime)
                      GlassIconButton(
                        icon: const Icon(Icons.folder_open_outlined),
                        tooltip: t.openInFileManager,
                        onPressed: status == null
                            ? null
                            : () => _openInFileManager(status.currentPath),
                      ),
                    Builder(
                      builder: (anchorContext) => GlassIconButton(
                        icon: const Icon(Icons.more_horiz),
                        tooltip: t.moreActions,
                        opensOverlay: true,
                        onPressed: () => _openMoreMenu(anchorContext, status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
