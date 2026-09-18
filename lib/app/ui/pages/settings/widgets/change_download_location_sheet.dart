import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/routes/app_router.dart' show rootNavigatorKey;
import 'package:i_iwara/app/services/download_relocation_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_relocation_flow.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_location_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 「更改下载位置」的整条流程：
///
/// ```
/// 选择（面板 / 菜单 / 系统选择器 / 手输）
///   → 解析（系统选择器给的是云盘 / 别的 App 的位置 → 解析失败，直接说清）
///   → 分类（要不要授权、要哪一档）
///   → 需要授权：先说明，同时给「改用 下载 › LoveIwara」替代 → 系统设置 → 回来重查
///   → probe（建目录、写探针、改名、删除、读剩余空间）
///   → 失败：不写配置，说清为什么
///   → 成功：确认（名字、剩余空间；旧位置还有 N 项时问 搬过去 / 保留 / 以后再说）
///   → 写配置 → 选了搬过去就交给 startDownloadRelocation
/// ```
///
/// 所有改位置的入口（面板选项、系统选择器、手动输入、修复）都汇到
/// [applyDownloadLocation] 这一个口子：检查、确认、写配置只写一份。

const _tag = 'ChangeDownloadLocation';

DownloadPathService get _service => DownloadPathService.to;

enum _ChoiceKind { option, pickFolder, askEveryTime }

class _Choice {
  const _Choice.option(this.path) : kind = _ChoiceKind.option;
  const _Choice.pickFolder() : kind = _ChoiceKind.pickFolder, path = null;
  const _Choice.askEveryTime() : kind = _ChoiceKind.askEveryTime, path = null;

  final _ChoiceKind kind;
  final String? path;
}

/// 打开「更改位置」：窄屏底部玻璃面板，宽屏（≥ [GlassTokens.dialogWideBreakpoint]）
/// 锚在触发钮上的玻璃菜单。[anchorContext] 必须是触发钮自身的 context。
Future<void> startChangeDownloadLocation(BuildContext anchorContext) async {
  final options = await _service.quickLocationOptions();
  final status = _service.pathStatus;
  final sdkInt = GetPlatform.isAndroid
      ? await Get.find<PermissionService>().androidSdkInt()
      : 0;
  if (!anchorContext.mounted) return;

  final wide =
      MediaQuery.sizeOf(anchorContext).width >=
      GlassTokens.dialogWideBreakpoint;
  final choice = wide
      ? await _showChoiceMenu(anchorContext, options, status, sdkInt)
      : await _showChoiceSheet(anchorContext, options, status, sdkInt);
  if (choice == null) return;

  switch (choice.kind) {
    case _ChoiceKind.option:
      await applyDownloadLocation(choice.path!);
    case _ChoiceKind.askEveryTime:
      await _service.setAskEveryTime();
      showAppToast(
        slang.t.download.location.locationChanged,
        type: AppToastType.success,
      );
    case _ChoiceKind.pickFolder:
      final picked = await _pickFolder();
      if (picked != null) await applyDownloadLocation(picked);
  }
}

/// 「更改位置」触发钮。宽屏开的是锚在它身上的玻璃菜单（长按也能开、按住直接
/// 划选），窄屏开底部面板。
class ChangeDownloadLocationButton extends StatelessWidget {
  const ChangeDownloadLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final opensOverlay =
        MediaQuery.sizeOf(context).width >= GlassTokens.dialogWideBreakpoint;
    return GlassDropdownPill(
      label: slang.Translations.of(context).download.location.changeLocation,
      icon: Icons.drive_file_move_outline,
      opensOverlay: opensOverlay,
      showArrow: opensOverlay,
      onTap: (anchorContext) => startChangeDownloadLocation(anchorContext),
    );
  }
}

bool _isCurrent(String optionPath, PathStatusInfo? status) {
  if (status == null || status.askEveryTime) return false;
  final target = status.targetPath;
  return target != null && p.equals(target, optionPath);
}

String _optionDescription(DownloadLocationOption option, int sdkInt) {
  final t = slang.t.download.location;
  switch (option.role) {
    case DownloadLocationOptionRole.recommended:
      if (GetPlatform.isDesktop) return t.optionDesktopDownloadsDesc;
      return option.location.requiresPermission && sdkInt < 30
          ? t.optionRecommendedLegacyDesc
          : t.optionRecommendedDesc;
    case DownloadLocationOptionRole.appPrivate:
      return t.optionAppPrivateDesc;
    case DownloadLocationOptionRole.removable:
      return t.optionRemovableDesc;
  }
}

Future<_Choice?> _showChoiceMenu(
  BuildContext anchorContext,
  List<DownloadLocationOption> options,
  PathStatusInfo? status,
  int sdkInt,
) {
  final t = slang.t.download.location;
  final askEveryTime = status?.askEveryTime ?? _service.asksEveryTime;
  final entries = <GlassMenuEntry>[
    for (final option in options)
      GlassMenuOption<_Choice>(
        value: _Choice.option(option.path),
        icon: downloadLocationIcon(option.location),
        label: downloadLocationTitle(option.location),
        description: _optionDescription(option, sdkInt),
        selected: _isCurrent(option.path, status),
      ),
    if (_service.supportsDirectoryPicker)
      GlassMenuOption<_Choice>(
        value: const _Choice.pickFolder(),
        icon: Icons.folder_open_outlined,
        label: t.chooseOtherFolder,
      ),
    if (GetPlatform.isDesktop)
      GlassMenuOption<_Choice>(
        value: const _Choice.askEveryTime(),
        icon: Icons.help_outline,
        label: t.askEveryTime,
        description: t.optionAskEveryTimeDesc,
        selected: askEveryTime,
      ),
  ];
  return showGlassMenu<_Choice>(
    anchorContext: anchorContext,
    entries: entries,
    minWidth: 280,
  );
}

Future<_Choice?> _showChoiceSheet(
  BuildContext context,
  List<DownloadLocationOption> options,
  PathStatusInfo? status,
  int sdkInt,
) {
  final t = slang.t.download.location;
  final askEveryTime = status?.askEveryTime ?? _service.asksEveryTime;
  return showGlassBottomSheet<_Choice>(
    context: context,
    builder: (sheetContext) {
      void choose(_Choice choice) => Navigator.of(sheetContext).pop(choice);
      final cs = Theme.of(sheetContext).colorScheme;
      Widget currentMark(bool current) => AnimatedSwitcher(
        duration: GlassTokens.motionDuration,
        child: current
            ? Icon(
                Icons.check_circle,
                key: const ValueKey('current'),
                color: cs.primary,
                size: 20,
              )
            : const SizedBox(key: ValueKey('none'), width: 20, height: 20),
      );
      return GlassBottomSheet(
        title: t.sheetTitle,
        scrollable: true,
        maxHeightFactor: 0.85,
        child: GlassSettingSection(
          children: [
            for (final option in options)
              GlassSettingTile(
                icon: downloadLocationIcon(option.location),
                title: Text(downloadLocationTitle(option.location)),
                subtitle: Text(_optionDescription(option, sdkInt)),
                selected: _isCurrent(option.path, status),
                trailing: currentMark(_isCurrent(option.path, status)),
                onTap: () => choose(_Choice.option(option.path)),
              ),
            if (GetPlatform.isDesktop)
              GlassSettingTile(
                icon: Icons.help_outline,
                title: Text(t.askEveryTime),
                subtitle: Text(t.optionAskEveryTimeDesc),
                selected: askEveryTime,
                trailing: currentMark(askEveryTime),
                onTap: () => choose(const _Choice.askEveryTime()),
              ),
            if (_service.supportsDirectoryPicker)
              GlassSettingTile(
                icon: Icons.folder_open_outlined,
                title: Text(t.chooseOtherFolder),
                subtitle: Text(t.chooseOtherFolderDesc),
                trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                onTap: () => choose(const _Choice.pickFolder()),
              ),
          ],
        ),
      );
    },
  );
}

/// 系统目录选择器。解析失败（云盘 / 别的 App 提供的位置）当场说清，返回 null。
Future<String?> _pickFolder() async {
  final t = slang.t;
  try {
    return await _service.pickDirectoryPath();
  } on PlatformException catch (e) {
    // ⛔ 不把 e.message 吐给用户：那是原生写死的中文。按错误码取文案。
    LogUtils.e('选择下载路径失败', error: e, tag: _tag);
    switch (e.code) {
      case 'ALREADY_ACTIVE':
        showAppToast(
          t.settings.downloadSettings.pickerAlreadyActive,
          type: AppToastType.warning,
        );
      case 'UNSUPPORTED_VOLUME':
      case 'RESOLVE_FAILED':
        await _showError(t.download.location.errorUnresolvable);
      default:
        showAppToast(
          t.settings.downloadSettings.selectPathFailed,
          type: AppToastType.error,
        );
    }
    return null;
  } catch (e) {
    LogUtils.e('选择下载路径失败', error: e, tag: _tag);
    showAppToast(
      t.settings.downloadSettings.selectPathFailed,
      type: AppToastType.error,
    );
    return null;
  }
}

Future<void> _showError(String message) {
  return showGlassAlertDialog<void>(
    title: slang.t.download.location.sheetTitle,
    content: Text(message),
    actions: [
      GlassDialogAction(
        label: slang.t.common.confirm,
        onPressed: () => _popRoot(),
      ),
    ],
  );
}

/// 弹窗挂在 root navigator 上，按钮里从它 pop（见 [GlassDialogAction.onPressed]）。
void _popRoot<T>([T? value]) => rootNavigatorKey.currentState?.pop(value);

enum _PermissionChoice { alternative, grant }

enum _OutsideChoice { move, keep, later }

/// 把下载目录改到 [dirPath]：分类 → 授权 → probe → 确认 → 写配置 → （可选）搬旧内容。
///
/// 返回位置是否真的改了。任何一步失败 / 取消，配置原样不动。
Future<bool> applyDownloadLocation(String dirPath) async {
  final t = slang.t.download.location;
  final path = p.normalize(dirPath.trim());
  if (path.isEmpty) return false;

  // 1. 分类：要不要授权。
  final need = await _service.storageAccessNeedOf(path);
  final permission = Get.find<PermissionService>();
  if (need != StorageAccessNeed.none &&
      !await permission.hasStorageAccess(need)) {
    final sdkInt = await permission.androidSdkInt();
    final alternative = await _alternativeFor(path, sdkInt);
    final choice = await showGlassAlertDialog<_PermissionChoice>(
      title: t.permissionTitle,
      content: Text(
        need == StorageAccessNeed.allFilesAccess
            ? t.permissionAllFiles
            : t.permissionLegacy,
      ),
      actions: [
        if (alternative != null)
          GlassDialogAction(
            label: sdkInt >= 30 ? t.useDownloadsInstead : t.useAppSpaceInstead,
            emphasized: false,
            onPressed: () => _popRoot(_PermissionChoice.alternative),
          ),
        GlassDialogAction(
          label: t.goToSettings,
          onPressed: () => _popRoot(_PermissionChoice.grant),
        ),
      ],
    );
    switch (choice) {
      case null:
        return false;
      case _PermissionChoice.alternative:
        return applyDownloadLocation(alternative!);
      case _PermissionChoice.grant:
        // 「所有文件访问」走系统设置页，request 要等用户回来才结束；回来后再查一遍
        // 实际状态（部分 ROM 的返回值不可靠）。
        await permission.requestStorageAccess(need);
        await _service.refreshPermissionAndRelated();
        if (!await permission.hasStorageAccess(need)) {
          showAppToast(t.permissionDenied, type: AppToastType.warning);
          return false;
        }
    }
  }

  // 2. probe：只有它会建目录。
  final probe = await _service.probe(path);
  switch (probe.outcome) {
    case DownloadProbeOutcome.ok:
      break;
    case DownloadProbeOutcome.volumeMissing:
      await _showError(t.errorVolumeMissing);
      return false;
    case DownloadProbeOutcome.needsPermission:
      showAppToast(t.permissionDenied, type: AppToastType.warning);
      return false;
    case DownloadProbeOutcome.notWritable:
      LogUtils.w('下载位置不可写: $path (${probe.error})', _tag);
      await _showError(t.errorNotWritable);
      return false;
  }

  // 3. 确认：名字、剩余空间、旧位置还有多少。
  final location = await _service.describeLocation(path);
  final outside = Get.isRegistered<DownloadRelocationService>()
      ? await DownloadRelocationService.to.movableTaskIdsOutside(path)
      : const <String>[];
  final confirmed = await showAppDialog<_OutsideChoice>(
    _ConfirmLocationDialog(
      location: location,
      freeBytes: probe.freeBytes,
      outsideCount: outside.length,
    ),
  );
  if (confirmed == null) {
    await _service.discardProbe(probe);
    return false;
  }

  // 4. 写配置。
  await _service.commitDownloadLocation(path);
  showAppToast(t.locationChanged, type: AppToastType.success);

  // 5. 搬旧内容（整条交互由移动流程自己负责：规划、明细、进度、结果）。
  if (confirmed == _OutsideChoice.move && outside.isNotEmpty) {
    await startDownloadRelocation(outside, destination: path);
  } else if (confirmed == _OutsideChoice.keep) {
    // 「保留在原处」是明确的回答：列表横幅别每次启动都再问一遍。
    // 「以后再说」不记，横幅照常提醒。
    _service.dismissOutsideFor(path);
  }
  return true;
}

/// 需要授权时给的替代位置：Android 11+ 是「下载 › LoveIwara」（免授权），
/// 更早的系统是 App 专属空间。替代品就是它自己时返回 null。
Future<String?> _alternativeFor(String path, int sdkInt) async {
  final options = await _service.quickLocationOptions();
  final role = sdkInt >= 30
      ? DownloadLocationOptionRole.recommended
      : DownloadLocationOptionRole.appPrivate;
  for (final option in options) {
    if (option.role != role) continue;
    if (option.location.requiresPermission) continue;
    if (p.equals(option.path, path)) continue;
    return option.path;
  }
  return null;
}

class _ConfirmLocationDialog extends StatefulWidget {
  const _ConfirmLocationDialog({
    required this.location,
    required this.freeBytes,
    required this.outsideCount,
  });

  final DownloadLocation location;
  final int? freeBytes;
  final int outsideCount;

  @override
  State<_ConfirmLocationDialog> createState() => _ConfirmLocationDialogState();
}

class _ConfirmLocationDialogState extends State<_ConfirmLocationDialog> {
  _OutsideChoice _choice = _OutsideChoice.move;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.location;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final caption = downloadLocationCaption(widget.location, widget.freeBytes);

    return GlassAlertDialog(
      title: t.confirmTitle,
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(downloadLocationIcon(widget.location), color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      downloadLocationTitle(widget.location),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        caption,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      widget.location.path,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.outsideCount > 0) ...[
            const SizedBox(height: 16),
            Text(
              t.confirmOutside(count: widget.outsideCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              t.confirmOutsideDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            GlassSettingSection(
              children: [
                for (final (value, label, icon) in [
                  (
                    _OutsideChoice.move,
                    t.moveThem,
                    Icons.drive_folder_upload_outlined,
                  ),
                  (_OutsideChoice.keep, t.keepThem, Icons.folder_outlined),
                  (_OutsideChoice.later, t.decideLater, Icons.schedule),
                ])
                  GlassChoiceItem<_OutsideChoice>(
                    value: value,
                    groupValue: _choice,
                    icon: icon,
                    title: Text(label),
                    onChanged: (v) => setState(() => _choice = v),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        GlassDialogAction(
          label: t.useThisLocation,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(_choice),
        ),
      ],
    );
  }
}
