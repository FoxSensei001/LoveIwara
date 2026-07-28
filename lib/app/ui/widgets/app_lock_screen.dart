import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  late final AppLockService _service;
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  String? _error;
  bool _submitting = false;
  bool _biometricPrompted = false;

  @override
  void initState() {
    super.initState();
    _service = Get.find<AppLockService>();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _service.failedAttempts.value < 5) return;
      final retry = _service.retryAfter;
      setState(() {
        _error = retry > Duration.zero
            ? slang.t.settings.appLockTooManyAttempts(
                seconds: retry.inSeconds + 1,
              )
            : null;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _tryBiometrics() async {
    if (_biometricPrompted ||
        !_service.biometricsEnabled ||
        !_service.biometricAvailable.value) {
      return;
    }
    _biometricPrompted = true;
    final success = await _service.authenticateBiometrically(
      reason: slang.t.settings.appLockAuthenticateReason,
    );
    if (!success && mounted) _focusNode.requestFocus();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final retry = _service.retryAfter;
    if (retry > Duration.zero) {
      setState(() {
        _error = slang.t.settings.appLockTooManyAttempts(
          seconds: retry.inSeconds + 1,
        );
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final success = await _service.unlockWithPin(_pinController.text);
    if (!mounted) return;
    if (!success) {
      _pinController.clear();
      final blocked = _service.retryAfter;
      setState(() {
        _error = blocked > Duration.zero
            ? slang.t.settings.appLockTooManyAttempts(
                seconds: blocked.inSeconds + 1,
              )
            : slang.t.settings.appLockInvalidPin;
      });
      _focusNode.requestFocus();
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Material(
        color: colors.surface,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: colors.primaryContainer,
                      child: Icon(
                        Icons.lock_outline,
                        size: 36,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      slang.t.settings.appLockLockedTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slang.t.settings.appLockLockedDesc,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pinController,
                      focusNode: _focusNode,
                      autofocus: !_service.biometricsEnabled,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLength: 8,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: slang.t.settings.appLockEnterPin,
                        errorText: _error,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.pin_outlined),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: _submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.lock_open),
                        label: Text(slang.t.settings.appLockUnlock),
                      ),
                    ),
                    if (_service.biometricsEnabled &&
                        _service.biometricAvailable.value) ...[
                      const SizedBox(height: 8),
                      Obx(
                        () => TextButton.icon(
                          onPressed: _service.isAuthenticating.value
                              ? null
                              : () async {
                                  final success = await _service
                                      .authenticateBiometrically(
                                        reason: slang
                                            .t
                                            .settings
                                            .appLockAuthenticateReason,
                                      );
                                  if (!success && mounted) {
                                    setState(() {
                                      _error = slang
                                          .t
                                          .settings
                                          .appLockBiometricFailed;
                                    });
                                  }
                                },
                          icon: const Icon(Icons.fingerprint),
                          label: Text(slang.t.settings.appLockUseBiometrics),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
