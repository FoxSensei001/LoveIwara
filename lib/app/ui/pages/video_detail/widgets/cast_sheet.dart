import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart' show rootNavigatorKey;
import 'package:i_iwara/app/services/cast/cast_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:material_ui/material_ui.dart';

/// 投屏弹层：搜索 DLNA 与 Google Cast 设备、手动添加、投放与停止。
///
/// 打开即开始一轮搜索（[CastService.searchWindow]），关掉即停止。
class CastSheet extends StatefulWidget {
  const CastSheet({
    super.key,
    required this.videoUrl,
    required this.castService,
    this.videoTitle,
    this.onCastStarted,
  });

  final String videoUrl;
  final String? videoTitle;
  final CastService castService;
  final VoidCallback? onCastStarted;

  @override
  State<CastSheet> createState() => _CastSheetState();
}

class _CastSheetState extends State<CastSheet> {
  CastService get _service => widget.castService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _service.startSearch();
    });
  }

  @override
  void dispose() {
    _service.stopSearch();
    super.dispose();
  }

  Future<void> _cast(CastDevice device) async {
    final started = await _service.castToDevice(
      device,
      widget.videoUrl,
      title: widget.videoTitle,
    );
    if (started) widget.onCastStarted?.call();
  }

  Future<void> _addManually() async {
    final t = slang.t.videoDetail.cast.dlnaCastSheet;
    // 输入框的 controller 归输入框自己管（路由真正卸载时才释放）；这里只拿文字。
    final draft = ValueNotifier<String>('');
    void submit() => rootNavigatorKey.currentState?.pop(draft.value);
    final input = await showGlassAlertDialog<String>(
      title: t.addByIpTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.addByIpDesc),
          const SizedBox(height: 12),
          _ManualHostField(
            hint: t.addByIpHint,
            draft: draft,
            onSubmitted: submit,
          ),
        ],
      ),
      actions: [GlassDialogAction(label: t.addByIpAction, onPressed: submit)],
    );
    if (input == null || input.trim().isEmpty) return;

    final result = await _service.addManualHost(input);
    switch (result) {
      case ManualCastResult.found:
        break;
      case ManualCastResult.invalid:
        showAppToast(t.addByIpInvalid, type: AppToastType.warning);
      case ManualCastResult.notFound:
        showAppToast(
          t.addByIpNotFound(host: input.trim()),
          type: AppToastType.error,
          duration: const Duration(seconds: 5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t.videoDetail.cast.dlnaCastSheet;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GlassBottomSheet(
      title: t.title,
      scrollable: true,
      maxHeightFactor: 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 状态 + 动作
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AnimatedSwitcher(
                    duration: GlassTokens.motionDuration,
                    child: Text(
                      _service.isSearching.value
                          ? t.searchingDevices
                          : t.searchFinished(count: _service.devices.length),
                      key: ValueKey(_service.isSearching.value),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => GlassButtonGroup(
                  children: [
                    GlassTextActionButton(
                      label: t.addByIp,
                      loading: _service.isProbing.value,
                      onPressed: _service.isProbing.value ? null : _addManually,
                    ),
                    GlassTextActionButton(
                      label: t.searchAgain,
                      emphasized: true,
                      loading: _service.isSearching.value,
                      onPressed: _service.isSearching.value
                          ? null
                          : _service.startSearch,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 设备列表 / 空状态
          Obx(() {
            final devices = _service.devices.toList();
            final busy = _service.isCasting.value;
            final connectedId = _service.isConnected.value
                ? _service.connectedDeviceId.value
                : null;
            return AnimatedSize(
              duration: GlassTokens.motionDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: GlassTokens.motionDuration,
                child: devices.isEmpty
                    ? _EmptyState(
                        key: const ValueKey('empty'),
                        searching: _service.isSearching.value,
                      )
                    : GlassSettingSection(
                        key: const ValueKey('list'),
                        children: [
                          for (final device in devices)
                            GlassSettingTile(
                              key: ValueKey(device.id),
                              icon: device is ChromecastDevice
                                  ? Icons.cast
                                  : Icons.tv,
                              title: Text(
                                device.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _subtitle(
                                  device,
                                  dlna: t.protocolDlna,
                                  googleCast: t.protocolGoogleCast,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected: device.id == connectedId,
                              enabled: !busy,
                              trailing: device.id == connectedId
                                  ? Icon(
                                      Icons.check_circle,
                                      color: cs.primary,
                                      size: 20,
                                    )
                                  : Icon(
                                      Icons.chevron_right,
                                      color: cs.onSurfaceVariant,
                                    ),
                              onTap: () => _cast(device),
                            ),
                        ],
                      ),
              ),
            );
          }),

          // 搜完了：排查清单（列表里有别的设备、偏偏没有自己那台时同样用得上）
          Obx(() {
            final show = !_service.isSearching.value;
            return AnimatedSize(
              duration: GlassTokens.motionDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !show
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.troubleshootTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.troubleshoot,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }),

          // 已连接：停止投屏
          Obx(() {
            final connected = _service.isConnected.value;
            return AnimatedSize(
              duration: GlassTokens.motionDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !connected
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.connectedTo(
                                deviceName: _service.connectedDeviceName.value,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassButtonGroup(
                            children: [
                              GlassTextActionButton(
                                label: t.stopCasting,
                                destructive: true,
                                loading: _service.isCasting.value,
                                onPressed: _service.isCasting.value
                                    ? null
                                    : _service.stopCast,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  static String _subtitle(
    CastDevice device, {
    required String dlna,
    required String googleCast,
  }) {
    final protocol = switch (device) {
      ChromecastDevice() => googleCast,
      DlnaCastDevice() => dlna,
    };
    final parts = [
      protocol,
      if (device.model != null) device.model!,
      if (device.manual) device.host,
    ];
    return parts.join(' · ');
  }
}

/// 没有设备时的占位。
class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    final t = slang.t.videoDetail.cast.dlnaCastSheet;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.devices_other, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            searching ? t.searchingDevicesPrompt : t.noDevicesFound,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 手动添加弹窗里的地址输入框。自己持有 controller，随弹窗路由一起卸载时释放
/// （弹窗 Future 在 pop 时就完成了，退场动画期间输入框还挂在树上）。
class _ManualHostField extends StatefulWidget {
  const _ManualHostField({
    required this.hint,
    required this.draft,
    required this.onSubmitted,
  });

  final String hint;
  final ValueNotifier<String> draft;
  final VoidCallback onSubmitted;

  @override
  State<_ManualHostField> createState() => _ManualHostFieldState();
}

class _ManualHostFieldState extends State<_ManualHostField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassInputSurface(
      child: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z.:/_\-]')),
        ],
        textInputAction: TextInputAction.done,
        onChanged: (value) => widget.draft.value = value,
        onSubmitted: (_) => widget.onSubmitted(),
        decoration: glassFieldDecoration(context, hint: widget.hint),
      ),
    );
  }
}
