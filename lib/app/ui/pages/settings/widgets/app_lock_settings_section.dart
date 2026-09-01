import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 这张卡里正在等结果的那一项。
enum _BusyOp { none, toggle, changePin }

/// 隐私模式在这张卡里的去留。
///
/// 隐私模式做两件事：`FLAG_SECURE` 禁截图（只有安卓有原生实现）+ 后台遮罩；
/// 而后台遮罩由 `隐私模式 || 应用锁` 统一驱动（见 `my_app.dart`）。两者因此
/// 天然重叠，重叠多少要看平台和应用锁状态。
enum PrivacyModeVisibility {
  /// 非安卓 + 应用锁开着：隐私模式一点额外作用都没有，整条藏掉。
  hidden,

  /// 安卓 + 应用锁关着：禁截图和后台遮罩都归它管。
  screenshotAndOverlay,

  /// 安卓 + 应用锁开着：遮罩已由应用锁承担，只剩禁截图这一项独有。
  screenshotOnly,

  /// 非安卓 + 应用锁关着：拦不住截图，只剩后台遮罩。
  overlayOnly,
}

/// 纯函数版裁决，方便直接单测（`GetPlatform.isAndroid` 读的是宿主平台，
/// 在 `flutter test` 里恒为 false，分支没法靠 widget test 覆盖）。
PrivacyModeVisibility resolvePrivacyModeVisibility({
  required bool isAndroid,
  required bool appLockEnabled,
}) {
  if (isAndroid) {
    return appLockEnabled
        ? PrivacyModeVisibility.screenshotOnly
        : PrivacyModeVisibility.screenshotAndOverlay;
  }
  return appLockEnabled
      ? PrivacyModeVisibility.hidden
      : PrivacyModeVisibility.overlayOnly;
}

class AppLockSettingsSection extends StatefulWidget {
  const AppLockSettingsSection({super.key});

  @override
  State<AppLockSettingsSection> createState() => _AppLockSettingsSectionState();
}

class _AppLockSettingsSectionState extends State<AppLockSettingsSection> {
  late final AppLockService _service = Get.find<AppLockService>();
  late final ConfigService _configService = Get.find<ConfigService>();

  static const _timeouts = <int>[-1, 0, 30, 60, 300, 600, 900, 1800];

  /// 当前正在跑的慢操作（PBKDF2 派生 12 万轮 + 写/删 Keystore）。
  ///
  /// 开锁、关锁各要一次派生，改 PIN 要两次，真机上是肉眼可见的一段等待。
  /// 之前这段时间里 UI 毫无反应，用户会以为没点上而反复拨开关。记成枚举而
  /// 不是一个 bool，是为了让转圈**只出现在用户刚点的那一行**。
  _BusyOp _busy = _BusyOp.none;

  /// 把一段慢操作包起来：期间该行进入等待态，结束后无论成败都复位。
  Future<void> _runBusy(_BusyOp op, Future<void> Function() action) async {
    if (_busy != _BusyOp.none) return;
    setState(() => _busy = op);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = _BusyOp.none);
    }
  }

  String _timeoutLabel(int seconds) {
    if (seconds < 0) return slang.t.settings.appLockTimeoutDisabled;
    if (seconds == 0) return slang.t.settings.appLockImmediately;
    if (seconds < 60) {
      return slang.t.settings.appLockSeconds(seconds: seconds);
    }
    return slang.t.settings.appLockMinutes(minutes: seconds ~/ 60);
  }

  Future<String?> _askForPin({required String title}) async {
    return showAppDialog<String>(
      _PinEntryDialog(title: title),
      dialogContext: context,
    );
  }

  Future<_NewPinValues?> _askForNewPin({required String title}) {
    return showAppDialog<_NewPinValues>(
      _NewPinDialog(title: title),
      dialogContext: context,
    );
  }

  Future<_ChangePinValues?> _askForPinChange() {
    return showAppDialog<_ChangePinValues>(
      const _ChangePinDialog(),
      dialogContext: context,
    );
  }

  Future<void> _enable() async {
    final values = await _askForNewPin(title: slang.t.settings.appLockSetPin);
    if (values == null || !mounted) return;
    if (!_service.isValidPin(values.pin)) {
      _showMessage(slang.t.settings.appLockPinRequirements);
      return;
    }
    if (values.pin != values.confirmation) {
      _showMessage(slang.t.settings.appLockPinsDoNotMatch);
      return;
    }
    await _runBusy(_BusyOp.toggle, () async {
      if (!await _service.enableWithPin(values.pin) && mounted) {
        _showMessage(slang.t.settings.appLockSetupFailed);
      }
    });
  }

  Future<void> _disable() async {
    final pin = await _askForPin(title: slang.t.settings.appLockDisable);
    if (pin == null || !mounted) return;
    await _runBusy(_BusyOp.toggle, () async {
      if (!await _service.disable(pin) && mounted) {
        _showMessage(slang.t.settings.appLockInvalidPin);
      }
    });
  }

  Future<void> _changePin() async {
    final values = await _askForPinChange();
    if (values == null || !mounted) return;
    if (!_service.isValidPin(values.newPin)) {
      _showMessage(slang.t.settings.appLockPinRequirements);
      return;
    }
    if (values.newPin != values.confirmation) {
      _showMessage(slang.t.settings.appLockPinsDoNotMatch);
      return;
    }
    await _runBusy(_BusyOp.changePin, () async {
      if (!await _service.verifyPin(values.currentPin)) {
        if (mounted) _showMessage(slang.t.settings.appLockInvalidPin);
        return;
      }
      if (!await _service.enableWithPin(values.newPin) && mounted) {
        _showMessage(slang.t.settings.appLockSetupFailed);
      }
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (!value) {
      await _service.setBiometricsEnabled(false);
      return;
    }
    final authenticated = await _service.authenticateBiometrically();
    if (authenticated) {
      await _service.setBiometricsEnabled(true);
    } else if (mounted) {
      _showMessage(slang.t.settings.appLockBiometricFailed);
    }
  }

  void _showMessage(String message) {
    showAppToast(message, type: AppToastType.warning);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              slang.t.settings.privacy,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            final visibility = resolvePrivacyModeVisibility(
              isAndroid: GetPlatform.isAndroid,
              appLockEnabled: _service.enabled,
            );
            if (visibility == PrivacyModeVisibility.hidden) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassSwitchItem(
                  icon: Icons.no_photography_outlined,
                  title: Text(slang.t.settings.activeBackgroundPrivacyMode),
                  subtitle: Text(_privacyModeDescriptionOf(visibility)),
                  value:
                      _configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE],
                  onChanged: (value) {
                    _configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE] =
                        value;
                  },
                ),
                const Divider(height: 1),
              ],
            );
          }),
          Obx(() {
            final enabled = _service.enabled;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassSwitchItem(
                  icon: Icons.lock_outline,
                  title: Text(slang.t.settings.appLockEnabled),
                  subtitle: Text(slang.t.settings.appLockEnabledDesc),
                  value: enabled,
                  busy: _busy == _BusyOp.toggle,
                  onChanged: (_) => enabled ? _disable() : _enable(),
                ),
                if (enabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(slang.t.settings.appLockTimeout),
                    subtitle: Text(slang.t.settings.appLockTimeoutDesc),
                    trailing: GlassDropdownField<int>(
                      // ListTile.trailing 拿到的是整条 tile 的宽度，撑满会把标题挤没
                      shrinkWrap: true,
                      value: _service.timeoutSeconds,
                      items: [
                        for (final seconds in _timeouts)
                          GlassDropdownItem(
                            value: seconds,
                            label: _timeoutLabel(seconds),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) _service.setTimeoutSeconds(value);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  if (GetPlatform.isAndroid) ...[
                    GlassSwitchItem(
                      icon: Icons.screen_lock_portrait,
                      title: Text(slang.t.settings.appLockAfterScreenOff),
                      subtitle: Text(
                        slang.t.settings.appLockAfterScreenOffDesc,
                      ),
                      value: _service.lockAfterScreenOff,
                      onChanged: _service.setLockAfterScreenOff,
                    ),
                    const Divider(height: 1),
                  ],
                  GlassSwitchItem(
                    icon: Icons.fingerprint,
                    title: Text(slang.t.settings.appLockUseBiometrics),
                    subtitle: Text(
                      _service.biometricAvailable.value
                          ? slang.t.settings.appLockUseBiometricsDesc
                          : slang.t.settings.appLockBiometricsUnavailable,
                    ),
                    value:
                        _service.biometricsEnabled &&
                        _service.biometricAvailable.value,
                    onChanged: _service.biometricAvailable.value
                        ? _toggleBiometrics
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: Text(slang.t.settings.appLockChangePin),
                    trailing: _busy == _BusyOp.changePin
                        ? const GlassTileSpinner()
                        : null,
                    enabled: _busy == _BusyOp.none,
                    onTap: _changePin,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: Text(slang.t.settings.appLockNow),
                    onTap: _service.lockNow,
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _NewPinValues {
  const _NewPinValues(this.pin, this.confirmation);

  final String pin;
  final String confirmation;
}

class _ChangePinValues {
  const _ChangePinValues(this.currentPin, this.newPin, this.confirmation);

  final String currentPin;
  final String newPin;
  final String confirmation;
}

class _PinEntryDialog extends StatefulWidget {
  const _PinEntryDialog({required this.title});

  final String title;

  @override
  State<_PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<_PinEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return GlassAlertDialog(
      title: widget.title,
      content: _PinTextField(
        controller: _controller,
        label: slang.t.settings.appLockEnterPin,
        autofocus: true,
        onSubmitted: _submit,
      ),
      actions: _dialogActions(context, _submit),
    );
  }
}

class _NewPinDialog extends StatefulWidget {
  const _NewPinDialog({required this.title});

  final String title;

  @override
  State<_NewPinDialog> createState() => _NewPinDialogState();
}

class _NewPinDialogState extends State<_NewPinDialog> {
  final _pinController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(
      context,
    ).pop(_NewPinValues(_pinController.text, _confirmationController.text));
  }

  @override
  Widget build(BuildContext context) {
    return GlassAlertDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinTextField(
            controller: _pinController,
            label: slang.t.settings.appLockNewPin,
            autofocus: true,
          ),
          const SizedBox(height: 8),
          _PinTextField(
            controller: _confirmationController,
            label: slang.t.settings.appLockConfirmPin,
            onSubmitted: _submit,
          ),
        ],
      ),
      actions: _dialogActions(context, _submit),
    );
  }
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog();

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _ChangePinValues(
        _currentController.text,
        _newController.text,
        _confirmationController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassAlertDialog(
      title: slang.t.settings.appLockChangePin,
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinTextField(
            controller: _currentController,
            label: slang.t.settings.appLockCurrentPin,
            autofocus: true,
          ),
          const SizedBox(height: 8),
          _PinTextField(
            controller: _newController,
            label: slang.t.settings.appLockNewPin,
          ),
          const SizedBox(height: 8),
          _PinTextField(
            controller: _confirmationController,
            label: slang.t.settings.appLockConfirmPin,
            onSubmitted: _submit,
          ),
        ],
      ),
      actions: _dialogActions(context, _submit),
    );
  }
}

class _PinTextField extends StatelessWidget {
  const _PinTextField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: true,
      maxLength: 8,
      keyboardType: TextInputType.number,
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        helperText: slang.t.settings.appLockPinRequirements,
      ),
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    );
  }
}

String _privacyModeDescriptionOf(PrivacyModeVisibility visibility) {
  switch (visibility) {
    case PrivacyModeVisibility.screenshotAndOverlay:
      return slang.t.settings.activeBackgroundPrivacyModeDesc;
    case PrivacyModeVisibility.screenshotOnly:
      return slang.t.settings.activeBackgroundPrivacyModeDescScreenshotOnly;
    case PrivacyModeVisibility.overlayOnly:
      return slang.t.settings.activeBackgroundPrivacyModeDescNonAndroid;
    case PrivacyModeVisibility.hidden:
      return '';
  }
}

List<GlassDialogAction> _dialogActions(
  BuildContext context,
  VoidCallback submit,
) {
  return [
    GlassDialogAction(
      label: slang.t.common.cancel,
      emphasized: false,
      onPressed: () => Navigator.of(context).pop(),
    ),
    GlassDialogAction(label: slang.t.common.confirm, onPressed: submit),
  ];
}
