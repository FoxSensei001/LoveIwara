import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class AppLockSettingsSection extends StatefulWidget {
  const AppLockSettingsSection({super.key});

  @override
  State<AppLockSettingsSection> createState() => _AppLockSettingsSectionState();
}

class _AppLockSettingsSectionState extends State<AppLockSettingsSection> {
  late final AppLockService _service = Get.find<AppLockService>();

  static const _timeouts = <int>[-1, 0, 30, 60, 300, 600, 900, 1800];

  String _timeoutLabel(int seconds) {
    if (seconds < 0) return slang.t.settings.appLockTimeoutDisabled;
    if (seconds == 0) return slang.t.settings.appLockImmediately;
    if (seconds < 60) {
      return slang.t.settings.appLockSeconds(seconds: seconds);
    }
    return slang.t.settings.appLockMinutes(minutes: seconds ~/ 60);
  }

  Future<String?> _askForPin({required String title}) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          maxLength: 8,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: slang.t.settings.appLockEnterPin,
            helperText: slang.t.settings.appLockPinRequirements,
          ),
          onSubmitted: (_) => Navigator.pop(dialogContext, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(slang.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(slang.t.common.confirm),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _enable() async {
    final first = await _askForPin(title: slang.t.settings.appLockSetPin);
    if (first == null || !mounted) return;
    if (!_service.isValidPin(first)) {
      _showMessage(slang.t.settings.appLockPinRequirements);
      return;
    }
    final second = await _askForPin(title: slang.t.settings.appLockConfirmPin);
    if (second == null || !mounted) return;
    if (first != second) {
      _showMessage(slang.t.settings.appLockPinsDoNotMatch);
      return;
    }
    if (!await _service.enableWithPin(first) && mounted) {
      _showMessage(slang.t.settings.appLockSetupFailed);
    }
  }

  Future<void> _disable() async {
    final pin = await _askForPin(title: slang.t.settings.appLockDisable);
    if (pin == null || !mounted) return;
    if (!await _service.disable(pin) && mounted) {
      _showMessage(slang.t.settings.appLockInvalidPin);
    }
  }

  Future<void> _changePin() async {
    final current = await _askForPin(title: slang.t.settings.appLockCurrentPin);
    if (current == null || !mounted) return;
    if (!await _service.verifyPin(current)) {
      if (mounted) _showMessage(slang.t.settings.appLockInvalidPin);
      return;
    }
    final next = await _askForPin(title: slang.t.settings.appLockNewPin);
    if (next == null || !mounted) return;
    if (!_service.isValidPin(next)) {
      _showMessage(slang.t.settings.appLockPinRequirements);
      return;
    }
    final confirm = await _askForPin(title: slang.t.settings.appLockConfirmPin);
    if (confirm == null || !mounted) return;
    if (next != confirm) {
      _showMessage(slang.t.settings.appLockPinsDoNotMatch);
      return;
    }
    if (!await _service.enableWithPin(next) && mounted) {
      _showMessage(slang.t.settings.appLockSetupFailed);
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (!value) {
      await _service.setBiometricsEnabled(false);
      return;
    }
    final authenticated = await _service.authenticateBiometrically(
      reason: slang.t.settings.appLockEnableBiometricsReason,
    );
    if (authenticated) {
      await _service.setBiometricsEnabled(true);
    } else if (mounted) {
      _showMessage(slang.t.settings.appLockBiometricFailed);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              slang.t.settings.appLock,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            final enabled = _service.enabled;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(slang.t.settings.appLockEnabled),
                  subtitle: Text(slang.t.settings.appLockEnabledDesc),
                  value: enabled,
                  onChanged: (_) => enabled ? _disable() : _enable(),
                ),
                if (enabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(slang.t.settings.appLockTimeout),
                    subtitle: Text(slang.t.settings.appLockTimeoutDesc),
                    trailing: DropdownButton<int>(
                      value: _service.timeoutSeconds,
                      items: _timeouts
                          .map(
                            (seconds) => DropdownMenuItem(
                              value: seconds,
                              child: Text(_timeoutLabel(seconds)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _service.setTimeoutSeconds(value);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
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
