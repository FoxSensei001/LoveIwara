import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/ui/widgets/detached_navigator_host.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 应用锁的锁屏。
///
/// ⚠️ 它是 `MaterialApp.router` builder 里 Navigator **旁边**的一层
/// Stack sibling，不是一条路由——视觉上它盖住一切（含根 Navigator 上的
/// 弹窗），但自带的 [PopScope] 拦不住系统返回键。返回键由
/// `PopCoordinator` 在锁定期间统一消费，见那边的 `_isAppLocked`。
///
/// ⚠️ 正因为不在路由树里，整屏内容必须包在 [DetachedNavigatorHost] 里：
/// 没有 Overlay 的子树里 PIN 输入框一建选择浮层就会抛断言并把输入法状态
/// 打乱，弹窗也会画到本图层**底下**。详见那个组件的类文档。
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
    _startCountdownIfBlocked();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  /// 封锁倒计时的秒表——**只在真的处于封锁期时才跑**。
  ///
  /// 原来是一只常驻的 `Timer.periodic`：没被封锁时每秒空转一次（锁屏白白重建），
  /// 而且它永远不结束，任何碰到锁屏的 widget test 里 `pumpAndSettle` 都会超时。
  void _startCountdownIfBlocked() {
    _timer?.cancel();
    _timer = null;
    if (_service.retryAfter <= Duration.zero) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final retry = _service.retryAfter;
      setState(() {
        _error = retry > Duration.zero
            ? slang.t.settings.appLockTooManyAttempts(
                seconds: retry.inSeconds + 1,
              )
            : null;
      });
      if (retry <= Duration.zero) {
        timer.cancel();
        _timer = null;
      }
    });
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
    // ⛔ 必须 try/finally：安全存储那一层可能抛、也可能久久不返回（真机上
    // Keystore 抽风就是这样）。原实现一旦走不到最后那句，_submitting 永远
    // 停在 true —— 解锁钮变成一只永远转圈的死钮，人就被卡在锁屏上了。
    try {
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
        _startCountdownIfBlocked();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = slang.t.settings.appLockInvalidPin);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// 凭据读失败后的重试：Keystore 抽风多半是瞬时的。
  Future<void> _retryCredential() async {
    if (_retrying) return;
    setState(() {
      _retrying = true;
      _notice = null;
    });
    var ok = false;
    try {
      ok = await _service.retryCredential();
    } catch (_) {
      ok = false;
    }
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
  ///
  /// [hostContext] 必须是 [DetachedNavigatorHost] **内部**的 context：走默认的
  /// 根 Navigator 会把弹窗挂到底层路由树里，也就是画在锁屏底下——看不见、
  /// 点不到，而返回键这会儿又被 PopCoordinator 吃着，等于卡死。
  Future<void> _resetAfterFailure(BuildContext hostContext) async {
    final navigator = Navigator.of(hostContext);
    final confirmed = await showAppDialog<bool>(
      GlassAlertDialog(
        title: slang.t.settings.appLockResetConfirmTitle,
        content: Text(slang.t.settings.appLockResetConfirmDesc),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => navigator.pop(false),
          ),
          GlassDialogAction(
            // 用短标签：弹窗标题已经写明是「重置应用锁？」，动作行再摆一遍
            // 全称会把 GlassButtonGroup 的 Row 顶溢出。
            label: slang.t.settings.appLockResetAction,
            destructive: true,
            onPressed: () => navigator.pop(true),
          ),
        ],
      ),
      dialogContext: hostContext,
      useRootNavigator: false,
    );
    if (confirmed != true) return;
    await _service.resetAfterCredentialFailure();
  }

  @override
  Widget build(BuildContext context) {
    // 整屏内容交给自带 Navigator 的宿主：本图层不在路由树里，没有它就既没有
    // Overlay（输入框一动就抛断言 + 打乱输入法状态）也没有弹窗落脚点。
    return DetachedNavigatorHost(builder: _buildSurface);
  }

  Widget _buildSurface(BuildContext context) {
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
        // ⛔ 两枚钮别塞进同一只胶囊：「重试」+「重置应用锁」在 360dp 窄屏上
        // 一行摆不下，GlassButtonGroup 的 Row 会直接 OVERFLOWED。
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: slang.t.settings.appLockRetry,
              emphasized: true,
              loading: _retrying,
              onPressed: _retrying ? null : _retryCredential,
            ),
          ],
        ),
        const SizedBox(height: 8),
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: slang.t.settings.appLockReset,
              destructive: true,
              onPressed: () => _resetAfterFailure(context),
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
