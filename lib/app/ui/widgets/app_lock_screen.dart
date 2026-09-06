import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/ui/widgets/detached_navigator_host.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// PIN 的长度区间，与 [AppLockService.isValidPin] 的正则一致。
const int _kMinPinLength = 4;
const int _kMaxPinLength = 8;

/// 应用锁的锁屏。
///
/// ⚠️ 它是 `MaterialApp.router` builder 里 Navigator **旁边**的一层
/// Stack sibling，不是一条路由——视觉上它盖住一切（含根 Navigator 上的
/// 弹窗），但自带的 [PopScope] 拦不住系统返回键。返回键由
/// `PopCoordinator` 在锁定期间统一消费，见那边的 `_isAppLocked`。
///
/// ⚠️ 正因为不在路由树里，整屏内容必须包在 [DetachedNavigatorHost] 里：
/// 没有 Overlay 的子树里弹窗会画到本图层**底下**，而这一层的返回键又被吃着，
/// 等于把人卡死。详见那个组件的类文档。
///
/// # ⛔ 这里不能用 `TextField` 收 PIN
///
/// 2026-09-06 用户报障：iPhone 上点进输入框会弹出系统数字键盘，而 iOS 的键盘
/// **没有任何主动收起的办法**（没有系统级「收起」键，本层又不在路由树里、
/// 点空白处失焦也救不回来）——键盘盖住了下面的「解锁 / 使用生物验证」两枚钮，
/// 页面还滚不动，人就被卡在这一屏上。加上历史上那条「没有 Overlay 祖先时
/// `EditableText` 的批量编辑会漏、清空后重输冒出一整排圆点」的坑（留档在
/// [DetachedNavigatorHost]），结论是：锁屏**自带键盘**，一个字符都不经过系统
/// 输入法。桌面端另有物理键盘的通路（见 [_AppLockScreenState._onKeyEvent]）。
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with SingleTickerProviderStateMixin {
  late final AppLockService _service;

  /// 已敲进去的 PIN。**只在内存里**，不经过任何输入法 / 平台文本连接。
  String _pin = '';

  /// 物理键盘的落点（桌面端 / 带键盘的平板）。
  final _keyboardFocus = FocusNode(debugLabel: 'app-lock-keypad');

  /// 输错时的横向摇一摇。
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissSystemKeyboard();
      _tryBiometrics();
    });
  }

  /// 把身下那棵路由树的输入焦点摘掉，并叫系统输入法收起来。
  ///
  /// ⛔ 少了这一步，锁屏自己不用输入法也照样会被键盘盖住：用户正在评论框里
  /// 打字 → 切后台 → 回来触发锁定，底下那只 `EditableText` 焦点还在，iOS 的
  /// 系统键盘于是继续挂在最上层（它没有主动收起的办法），把整块九宫格连同
  /// 生物验证钮一起埋掉。
  void _dismissSystemKeyboard() {
    final focused = FocusManager.instance.primaryFocus;
    if (focused != null && focused != _keyboardFocus) focused.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    // 上面那下 unfocus 会把焦点交还给身下的 scope，物理键盘的通路要自己抢回来。
    _keyboardFocus.requestFocus();
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
    _shake.dispose();
    _keyboardFocus.dispose();
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
    // 生物验证没过就把物理键盘的焦点收回来，桌面端可以直接敲数字。
    if (!success && mounted) _keyboardFocus.requestFocus();
  }

  bool get _blocked => _service.retryAfter > Duration.zero;

  bool get _canSubmit =>
      !_submitting && !_blocked && _pin.length >= _kMinPinLength;

  void _append(String digit) {
    if (_submitting) return;
    if (_pin.length >= _kMaxPinLength) {
      // 满了还在敲：给一下否定反馈，而不是默默吞掉。
      _rejectFeedback();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      // 敲下一个字符就是「我知道刚才错了」，红字该让位给正在输入的这一串。
      // 封锁期的倒计时是外部状态，不能被敲键抹掉。
      if (!_blocked) _error = null;
      _notice = null;
    });
  }

  void _backspace() {
    if (_submitting || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _clearPin() {
    if (_pin.isEmpty) return;
    setState(() => _pin = '');
  }

  /// 否定反馈：摇一摇 + 震一下。输错、以及「已经 8 位还在敲」都用它。
  void _rejectFeedback() {
    HapticFeedback.heavyImpact();
    _shake.forward(from: 0);
  }

  /// 物理键盘通路：桌面端没有触摸，纯靠鼠标点小键盘太难用。
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _backspace();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_canSubmit) _submit();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _clearPin();
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (char != null && char.length == 1 && _isDigit(char)) {
      _append(char);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
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
    if (_pin.length < _kMinPinLength) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    // ⛔ 必须 try/finally：安全存储那一层可能抛、也可能久久不返回（真机上
    // Keystore 抽风就是这样）。原实现一旦走不到最后那句，_submitting 永远
    // 停在 true —— 解锁钮变成一只永远转圈的死钮，人就被卡在锁屏上了。
    try {
      final success = await _service.unlockWithPin(_pin);
      if (!mounted) return;
      if (!success) {
        final blocked = _service.retryAfter;
        setState(() {
          _pin = '';
          _error = blocked > Duration.zero
              ? slang.t.settings.appLockTooManyAttempts(
                  seconds: blocked.inSeconds + 1,
                )
              : slang.t.settings.appLockInvalidPin;
        });
        _rejectFeedback();
        _startCountdownIfBlocked();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pin = '';
          _error = slang.t.settings.appLockInvalidPin;
        });
        _rejectFeedback();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _authenticateBiometrically({bool asNotice = false}) async {
    final success = await _service.authenticateBiometrically();
    if (success || !mounted) return;
    setState(() {
      final message = slang.t.settings.appLockBiometricFailed;
      if (asNotice) {
        _notice = message;
      } else {
        _error = message;
      }
    });
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
    // 整屏内容交给自带 Navigator 的宿主：本图层不在路由树里，没有它弹窗就没有
    // 落脚点（会画到锁屏底下）。
    return DetachedNavigatorHost(builder: _buildSurface);
  }

  Widget _buildSurface(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Focus(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Material(
          // 不透明的一层：既是背景，也负责把身下整棵路由树的点击全部吃掉。
          color: colors.surface,
          child: _LockBackdrop(
            child: SafeArea(
              child: Obx(
                () => _service.credentialUnavailable.value
                    ? _buildCredentialFailureLayout(context)
                    : _buildPinLayout(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- 正常锁屏

  /// 三种摆法，按可用空间挑：
  ///   - 宽而矮（桌面窗口 / 横屏平板）：左信息右键盘，两边各自居中可滚；
  ///   - 正常竖屏：信息占上方剩余空间，键盘钉在下方拇指够得着的地方；
  ///   - 又窄又矮（被拖小的桌面窗口）：整屏一条滚动，宁可滚也不挤到溢出。
  Widget _buildPinLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        if (w >= 560 && w > h) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(child: _buildHeader(context)),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildKeypadColumn(
                        context,
                        maxHeight: h - 48,
                        maxWidth: w / 2 - 64,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (h < 460) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, compact: true),
                const SizedBox(height: 4),
                _buildKeypadColumn(
                  context,
                  // 已经在滚动容器里了，键位只按宽度算。
                  maxHeight: double.infinity,
                  maxWidth: w - 48,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(child: _buildHeader(context)),
                ),
              ),
              _buildKeypadColumn(
                context,
                maxHeight: math.min(h * 0.56, 420),
                maxWidth: w - 48,
              ),
            ],
          ),
        );
      },
    );
  }

  /// [compact]：矮窗里把徽标和那行说明收掉——它们是「好看」，而圆点和键盘是
  /// 「能用」，空间不够时先保后者。
  Widget _buildHeader(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            _buildBadge(context, Icons.lock_outline),
            const SizedBox(height: 20),
          ],
          Text(
            slang.t.settings.appLockLockedTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              slang.t.settings.appLockLockedDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: compact ? 16 : 28),
          // 摇一摇只摇圆点这一行：错的是刚敲的那串，不是整屏。
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              final t = _shake.value;
              // 振幅随时间衰减的正弦，来回三个整周期。
              final dx = t == 0
                  ? 0.0
                  : math.sin(t * math.pi * 6) * 10 * (1 - t);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: _PinDots(length: _pin.length, hasError: _error != null),
          ),
          const SizedBox(height: 12),
          _buildStatusLine(context),
        ],
      ),
    );
  }

  /// 固定高度的一行状态字：红色错误 > 提示 > 输入要求。
  ///
  /// 高度写死是为了「有出有入」的同时不让上面的标题跟着跳——错误出现/消失时
  /// 只有文字在原地交叉过渡。
  Widget _buildStatusLine(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final String message =
        _error ?? _notice ?? slang.t.settings.appLockPinRequirements;
    final Color color = _error != null
        ? colors.error
        : (_notice != null ? colors.primary : colors.onSurfaceVariant);
    return SizedBox(
      height: 40,
      child: Center(
        child: AnimatedSwitcher(
          duration: GlassTokens.motionDuration,
          switchInCurve: GlassTokens.motionCurve,
          switchOutCurve: GlassTokens.motionCurve.flipped,
          child: Text(
            message,
            key: ValueKey<String>(message),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ),
    );
  }

  /// 键盘 + 底下那枚生物验证钮。
  Widget _buildKeypadColumn(
    BuildContext context, {
    required double maxHeight,
    required double maxWidth,
  }) {
    final bool biometrics =
        _service.biometricsEnabled && _service.biometricAvailable.value;
    // 生物验证钮自己也要占一格高度，从键盘的额度里先扣掉。
    final double keypadHeight = biometrics ? maxHeight - 64 : maxHeight;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Keypad(
          maxWidth: maxWidth,
          maxHeight: keypadHeight,
          onDigit: _append,
          onBackspace: _pin.isEmpty ? null : _backspace,
          onClear: _clearPin,
          onSubmit: _canSubmit ? _submit : null,
          submitting: _submitting,
        ),
        if (biometrics) ...[
          const SizedBox(height: 16),
          Obx(
            () => _BiometricButton(
              enabled: !_service.isAuthenticating.value && !_submitting,
              onPressed: () => _authenticateBiometrically(),
            ),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------ 凭据读不出来

  Widget _buildCredentialFailureLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildCredentialFailure(context),
        ),
      ),
    );
  }

  /// 凭据读不出来：不再显示 PIN 键盘（怎么输都过不了），只给「重试」
  /// 和「重置」两个出口。
  Widget _buildCredentialFailure(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBadge(context, Icons.lock_reset, error: true),
        const SizedBox(height: 20),
        Text(
          slang.t.settings.appLockCredentialUnavailableTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          slang.t.settings.appLockCredentialUnavailableDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (_notice != null) ...[
          const SizedBox(height: 8),
          Text(
            _notice!,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
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
                        : () => _authenticateBiometrically(asNotice: true),
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
    final Color tint = error ? colors.error : colors.primary;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: error ? colors.errorContainer : colors.primaryContainer,
        border: Border.all(color: tint.withValues(alpha: 0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.16),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 34,
        color: error ? colors.onErrorContainer : colors.onPrimaryContainer,
      ),
    );
  }
}

/// 锁屏的底：一层竖向渐变 + 头顶一团主色辉光。
///
/// 纯 `surface` 平铺时，那块 400dp 的空白读起来就是「没做完的页面」。这两层
/// 渐变不采样背景（身后本来也没有内容），成本只有两次 shader 填充。
class _LockBackdrop extends StatelessWidget {
  const _LockBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              colors.primary.withValues(alpha: 0.10),
              colors.surface,
            ),
            colors.surface,
          ],
          stops: const [0, 0.62],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.72),
            radius: 0.85,
            colors: [
              colors.primary.withValues(alpha: 0.12),
              colors.primary.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// 已输入位数的圆点。
///
/// 长度可变（4–8 位），所以**不摆固定槽位**——摆 8 个空槽会让人以为必须输满
/// 八位。圆点随输入长出来，整行宽度靠 [AnimatedSize] 平滑伸缩。
class _PinDots extends StatelessWidget {
  const _PinDots({required this.length, required this.hasError});

  final int length;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color color = hasError ? colors.error : colors.primary;
    return SizedBox(
      height: 20,
      child: Center(
        child: AnimatedSize(
          duration: GlassTokens.motionDuration,
          curve: GlassTokens.motionCurve,
          child: length == 0
              // 一个空的占位横线：不留空气，也不写死八个槽。
              ? Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        // 新圆点是新建的元素，这条 0→1 只在它出生那次跑。
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey<String>('app-lock-pin-dot-$i'),
                          tween: Tween<double>(begin: 0.4, end: 1),
                          duration: GlassTokens.pressDuration,
                          curve: Curves.easeOutBack,
                          builder: (context, t, child) =>
                              Transform.scale(scale: t, child: child),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 自带的九宫格数字键盘。
///
/// 键位大小由可用空间反推（横屏 / 小屏也摆得下），上限 76 —— 再大在平板上
/// 会变成「一屏全是巨大圆钮」。
class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.maxWidth,
    required this.maxHeight,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.onSubmit,
    required this.submitting,
  });

  final double maxWidth;
  final double maxHeight;
  final ValueChanged<String> onDigit;
  final VoidCallback? onBackspace;
  final VoidCallback onClear;
  final VoidCallback? onSubmit;
  final bool submitting;

  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final double byWidth = (math.min(maxWidth, 300) - _gap * 2) / 3;
    final double byHeight = (maxHeight - _gap * 3) / 4;
    // 下限 40：再小就不是能拿拇指点的东西了。真的连它都摆不下时，摆法那边
    // （[_AppLockScreenState._buildPinLayout]）已经把整屏换成可滚的了。
    final double size = math.min(byWidth, byHeight).clamp(40.0, 76.0);
    final material = MaterialLocalizations.of(context);

    Widget digit(String d) => _KeypadKey(
      size: size,
      onTap: () => onDigit(d),
      child: Text(
        d,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );

    Widget row(List<Widget> keys) => Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            keys[i],
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([digit('1'), digit('2'), digit('3')]),
        row([digit('4'), digit('5'), digit('6')]),
        row([digit('7'), digit('8'), digit('9')]),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _KeypadKey(
              size: size,
              onTap: onBackspace,
              // 长按整串清空：错了一半时不用连点八下。
              onLongPress: onClear,
              filled: false,
              semanticLabel: material.deleteButtonTooltip,
              child: Icon(
                Icons.backspace_outlined,
                size: size * 0.34,
                color: onBackspace == null
                    ? Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.28)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: _gap),
            digit('0'),
            const SizedBox(width: _gap),
            _SubmitKey(
              size: size,
              onTap: onSubmit,
              submitting: submitting,
              semanticLabel: slang.t.settings.appLockUnlock,
            ),
          ],
        ),
      ],
    );
  }
}

/// 一枚圆形键位。
///
/// ⛔ 这里**不用** [GlassSurface]：九宫格是 12 块并排的独立玻璃，液态档下每块
/// 都要一次整屏 backdrop resolve（见项目里那份玻璃性能留档），而锁屏身后压根
/// 没有内容可折射——付了钱看不到东西。收下的只有那套按压手感：点击与「手指
/// 移出多远才算放弃」照旧走 [GlassPressable]（内部即 `GlassTapArea`）。
class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.size,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.filled = true,
    this.semanticLabel,
  });

  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 是否画出那块圆底。数字键要（是「键」），退格不要（是「动作」）。
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bool enabled = onTap != null;
    Widget key = GlassPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      scale: 0.92,
      builder: (context, pressed) => AnimatedContainer(
        duration: GlassTokens.pressDuration,
        curve: Curves.easeOut,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pressed && enabled
              ? colors.primary.withValues(alpha: 0.18)
              : (filled
                    ? colors.onSurface.withValues(alpha: 0.05)
                    : Colors.transparent),
        ),
        child: child,
      ),
    );
    if (semanticLabel != null) {
      key = Semantics(button: true, label: semanticLabel, child: key);
    }
    return key;
  }
}

/// 解锁键：位数够了才亮起来（主色实心），按下去转圈。
class _SubmitKey extends StatelessWidget {
  const _SubmitKey({
    required this.size,
    required this.onTap,
    required this.submitting,
    required this.semanticLabel,
  });

  final double size;
  final VoidCallback? onTap;
  final bool submitting;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bool enabled = onTap != null && !submitting;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        child: GlassPressable(
          onTap: enabled ? onTap : null,
          scale: 0.92,
          builder: (context, pressed) => AnimatedContainer(
            duration: GlassTokens.motionDuration,
            curve: Curves.easeOut,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled
                  ? (pressed
                        ? Color.alphaBlend(
                            colors.onPrimary.withValues(alpha: 0.14),
                            colors.primary,
                          )
                        : colors.primary)
                  : colors.onSurface.withValues(alpha: 0.05),
            ),
            // 箭头 ↔ 转圈原位交叉过渡，和玻璃动作钮同一套表达。
            child: AnimatedSwitcher(
              duration: GlassTokens.motionDuration,
              switchInCurve: GlassTokens.motionCurve,
              switchOutCurve: GlassTokens.motionCurve.flipped,
              child: submitting
                  ? SizedBox(
                      key: const ValueKey('app-lock-submitting'),
                      width: size * 0.32,
                      height: size * 0.32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_rounded,
                      key: const ValueKey('app-lock-submit'),
                      size: size * 0.38,
                      color: enabled
                          ? colors.onPrimary
                          : colors.onSurface.withValues(alpha: 0.28),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 「使用生物验证」——一枚带图标的玻璃胶囊。
///
/// 只有这一块用真玻璃：整屏就它一个，layer 成本可以忽略，而它是键盘之外
/// 唯一的另一条出路，值得被认出来。
class _BiometricButton extends StatelessWidget {
  const _BiometricButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color tint = enabled
        ? colors.primary
        : colors.onSurface.withValues(alpha: 0.38);
    return GlassSurface(
      height: GlassTokens.pillHeight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      onTap: enabled ? onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint, size: GlassTokens.iconSize, color: tint),
          const SizedBox(width: 8),
          Text(
            slang.t.settings.appLockUseBiometrics,
            style: TextStyle(
              color: tint,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
