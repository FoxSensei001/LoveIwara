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
    return showDialog<String>(
      context: context,
      builder: (_) => _PinEntryDialog(title: title),
    );
  }

  Future<_NewPinValues?> _askForNewPin({required String title}) {
    return showDialog<_NewPinValues>(
      context: context,
      builder: (_) => _NewPinDialog(title: title),
    );
  }

  Future<_ChangePinValues?> _askForPinChange() {
    return showDialog<_ChangePinValues>(
      context: context,
      builder: (_) => const _ChangePinDialog(),
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
    if (!await _service.enableWithPin(values.pin) && mounted) {
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
    if (!await _service.verifyPin(values.currentPin)) {
      if (mounted) _showMessage(slang.t.settings.appLockInvalidPin);
      return;
    }
    if (!await _service.enableWithPin(values.newPin) && mounted) {
      _showMessage(slang.t.settings.appLockSetupFailed);
    }
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
    return AlertDialog(
      title: Text(widget.title),
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
    return AlertDialog(
      title: Text(widget.title),
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
    return AlertDialog(
      title: Text(slang.t.settings.appLockChangePin),
      content: SingleChildScrollView(
        child: Column(
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

List<Widget> _dialogActions(BuildContext context, VoidCallback submit) {
  return [
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(slang.t.common.cancel),
    ),
    FilledButton(onPressed: submit, child: Text(slang.t.common.confirm)),
  ];
}
