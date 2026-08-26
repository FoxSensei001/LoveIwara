import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 应用锁的锁屏。
///
/// ⚠️ 它是 `MaterialApp.router` builder 里 Navigator **旁边**的一层
/// Stack sibling，不是一条路由——视觉上它盖住一切（含根 Navigator 上的
/// 弹窗），但自带的 [PopScope] 拦不住系统返回键。返回键由
/// `PopCoordinator` 在锁定期间统一消费，见那边的 `_isAppLocked`。
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
  String? _notice;
  bool _submitting = false;
  bool _retrying = false;
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
    final success = await _service.authenticateBiometrically();
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

  /// 凭据读失败后的重试：Keystore 抽风多半是瞬时的。
  Future<void> _retryCredential() async {
    if (_retrying) return;
    setState(() {
      _retrying = true;
      _notice = null;
    });
    final ok = await _service.retryCredential();
    if (!mounted) return;
    setState(() {
      _retrying = false;
      _notice = ok
          ? slang.t.settings.appLockRetrySucceeded
          : slang.t.settings.appLockRetryFailed;
    });
    if (ok) {
      _biometricPrompted = false;
      unawaited(_tryBiometrics());
    }
  }

  /// 显式重置：确认后关掉应用锁并清除凭据。见
  /// [AppLockService.resetAfterCredentialFailure] 的注释。
  Future<void> _resetAfterFailure() async {
    final confirmed = await showGlassAlertDialog<bool>(
      title: slang.t.settings.appLockResetConfirmTitle,
      content: Text(slang.t.settings.appLockResetConfirmDesc),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: slang.t.settings.appLockReset,
          destructive: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true) return;
    await _service.resetAfterCredentialFailure();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isMobile = GetPlatform.isAndroid || GetPlatform.isIOS;
    return PopScope(
      canPop: false,
      child: Material(
        color: colors.surface,
        child: SafeArea(
          child: Align(
            alignment: isMobile ? const Alignment(0, -0.35) : Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Obx(
                  () => _service.credentialUnavailable.value
                      ? _buildCredentialFailure(context)
                      : _buildPinEntry(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinEntry(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBadge(context, Icons.lock_outline),
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
        if (_notice != null) ...[
          const SizedBox(height: 8),
          Text(
            _notice!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.primary),
            textAlign: TextAlign.center,
          ),
        ],
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
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: slang.t.settings.appLockUnlock,
              emphasized: true,
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
        if (_service.biometricsEnabled &&
            _service.biometricAvailable.value) ...[
          const SizedBox(height: 8),
          Obx(
            () => GlassButtonGroup(
              children: [
                GlassTextActionButton(
                  label: slang.t.settings.appLockUseBiometrics,
                  onPressed: _service.isAuthenticating.value
                      ? null
                      : () async {
                          final success = await _service
                              .authenticateBiometrically();
                          if (!success && mounted) {
                            setState(() {
                              _error =
                                  slang.t.settings.appLockBiometricFailed;
                            });
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 凭据读不出来：不再显示 PIN 输入框（怎么输都过不了），只给「重试」
  /// 和「重置」两个出口。
  Widget _buildCredentialFailure(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBadge(context, Icons.lock_reset, error: true),
        const SizedBox(height: 20),
        Text(
          slang.t.settings.appLockCredentialUnavailableTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          slang.t.settings.appLockCredentialUnavailableDesc,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (_notice != null) ...[
          const SizedBox(height: 8),
          Text(
            _notice!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        // 生物识别在这里**照常可用**：OS 级强认证本身就是有效的身份证明，
        // 挡掉它只会把用户逼向「重置」那条更弱的路（重置=直接关掉应用锁）。
        if (_service.biometricsEnabled && _service.biometricAvailable.value)
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassButtonGroup(
                children: [
                  GlassTextActionButton(
                    label: slang.t.settings.appLockUseBiometrics,
                    emphasized: true,
                    onPressed: _service.isAuthenticating.value
                        ? null
                        : () async {
                            final success = await _service
                                .authenticateBiometrically();
                            if (!success && mounted) {
                              setState(() {
                                _notice =
                                    slang.t.settings.appLockBiometricFailed;
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: slang.t.settings.appLockRetry,
              loading: _retrying,
              onPressed: _retrying ? null : _retryCredential,
            ),
            GlassTextActionButton(
              label: slang.t.settings.appLockReset,
              destructive: true,
              onPressed: _resetAfterFailure,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, {bool error = false}) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 34,
      backgroundColor: error ? colors.errorContainer : colors.primaryContainer,
      child: Icon(
        icon,
        size: 36,
        color: error ? colors.onErrorContainer : colors.onPrimaryContainer,
      ),
    );
  }
}
