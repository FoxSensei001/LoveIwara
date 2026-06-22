// pages/login/login_page_v2.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/iwara_site_headers.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

const double _kBodyHeightMin = 420;
const double _kBodyHeightMax = 640;
const double _kFormMaxWidth = 420;

enum _AuthFlow { login, register }

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  /// 显示登录对话框
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const LoginDialog(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 便捷的静态调用方法
  static Future<bool?> showLoginDialog() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return Future.value(false);
    return show(context);
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  final ConfigService _configService = Get.find<ConfigService>();
  final StorageService _storage = StorageService();

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final FocusNode _loginPasswordFocus = FocusNode();

  _AuthFlow _flow = _AuthFlow.login;

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final rememberMe =
          _configService[ConfigKey.REMEMBER_ME_KEY] as bool? ?? false;
      // 仅预填用户名；不再保存/回填密码(HIGH#3)。
      final username = await _storage.readRememberedUsername();
      if (!mounted) return;
      setState(() {
        _rememberMe = rememberMe;
        _loginEmailController.text = username ?? '';
      });
    } catch (error) {
      LogUtils.e('加载保存的凭据失败: $error', tag: 'LoginDialogV2');
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.failedToLoadSavedCredentials,
          type: MDToastType.warning,
        ),
      );
    }
  }

  Future<void> _toggleRememberMe(bool? value) async {
    final newValue = value ?? false;
    if (!mounted) return;
    setState(() {
      _rememberMe = newValue;
    });
    _configService[ConfigKey.REMEMBER_ME_KEY] = newValue;
    if (!newValue) {
      await _storage.clearCredentials();
    }
  }

  void _changeFlow(_AuthFlow flow) {
    if (_flow == flow) return;
    setState(() {
      _flow = flow;
    });
  }

  Future<void> _submitLogin() async {
    if (_isLoading) return;
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    await _performLogin();
  }

  Future<void> _performLogin() async {
    final usernameOrEmail = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final ApiResult result = await _authService.login(
        usernameOrEmail,
        password,
      );
      if (result.isSuccess) {
        // 登录已成功(token 已就绪)；资料拉取成败决定提示文案，
        // 避免"成功 toast + 资料为空"的割裂(#3)。资料失败时后台会重试。
        final profileLoaded = await _userService.fetchUserProfile();
        showToastWidget(
          MDToastWidget(
            message: profileLoaded
                ? slang.t.auth.loginSuccess
                : slang.t.auth.loginSuccessProfilePending,
            type: profileLoaded ? MDToastType.success : MDToastType.warning,
          ),
        );
        _userService.startNotificationTimer();
        if (_rememberMe) {
          await _storage.writeRememberedUsername(usernameOrEmail);
        } else {
          await _storage.clearCredentials();
        }
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        LogUtils.w('登录失败（业务返回）: ${result.message}', 'LoginDialogV2');
        showToastWidget(
          MDToastWidget(message: result.message, type: MDToastType.error),
          position: ToastPosition.bottom,
        );
      }
    } catch (error, stackTrace) {
      LogUtils.e(
        '登录失败（异常）',
        tag: 'LoginDialogV2',
        error: error,
        stackTrace: stackTrace,
      );
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.unknownError,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 打开官网注册页面：应用内不再提供注册功能，引导用户前往当前站点的官网完成注册。
  Future<void> _openRegisterWebsite() async {
    final url = '${currentIwaraSiteOrMain().baseUrl}/register';
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('launchUrl returned false for $url');
      }
    } catch (error) {
      LogUtils.e('打开官网注册页面失败: $error', tag: 'LoginDialogV2');
      showToastWidget(
        MDToastWidget(
          message: slang.t.search.googleSearchBrowserOpenFailed(error: url),
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    }
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _loginPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double availableHeight = (MediaQuery.of(context).size.height * 0.65)
        .clamp(_kBodyHeightMin, _kBodyHeightMax);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const _SheetHandle(),
          _HeaderBar(
            flow: _flow,
            onFlowChanged: _changeFlow,
            onClose: () => Navigator.of(context).pop(false),
          ),
          SizedBox(
            height: availableHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _flow == _AuthFlow.login
                  ? _LoginFormSection(
                      key: const ValueKey('login-form'),
                      formKey: _loginFormKey,
                      emailController: _loginEmailController,
                      passwordController: _loginPasswordController,
                      passwordFocusNode: _loginPasswordFocus,
                      isLoading: _isLoading,
                      rememberMe: _rememberMe,
                      isPasswordVisible: _isPasswordVisible,
                      onRememberMeChanged: (value) {
                        _toggleRememberMe(value);
                      },
                      onSubmit: _submitLogin,
                      onTogglePasswordVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : _RegisterNoticeSection(
                      key: const ValueKey('register-notice'),
                      onOpenWebsite: _openRegisterWebsite,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.25);
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.flow,
    required this.onFlowChanged,
    required this.onClose,
  });

  final _AuthFlow flow;
  final ValueChanged<_AuthFlow> onFlowChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton<_AuthFlow>(
            segments: [
              ButtonSegment<_AuthFlow>(
                value: _AuthFlow.login,
                label: Text(t.auth.login),
                icon: const Icon(Icons.login),
              ),
              ButtonSegment<_AuthFlow>(
                value: _AuthFlow.register,
                label: Text(t.auth.register),
                icon: const Icon(Icons.person_add),
              ),
            ],
            selected: {flow},
            showSelectedIcon: false,
            onSelectionChanged: (value) {
              onFlowChanged(value.first);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: t.common.close,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _LoginFormSection extends StatelessWidget {
  const _LoginFormSection({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.isLoading,
    required this.rememberMe,
    required this.isPasswordVisible,
    required this.onRememberMeChanged,
    required this.onSubmit,
    required this.onTogglePasswordVisibility,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool isLoading;
  final bool rememberMe;
  final bool isPasswordVisible;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: t.auth.usernameOrEmail,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.auth.pleaseEnterUsernameOrEmail;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(passwordFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: t.auth.password,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: onTogglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.auth.pleaseEnterPassword;
                    }
                    if (value.length < 6) {
                      return t.auth.passwordMustBeAtLeast6Characters;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => onSubmit(),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: rememberMe,
                  onChanged: onRememberMeChanged,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.auth.rememberMe),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          t.auth.login,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 注册引导面板：应用内不再提供注册功能，改为以友好的说明文案引导用户前往官网注册。
class _RegisterNoticeSection extends StatelessWidget {
  const _RegisterNoticeSection({
    super.key,
    required this.onOpenWebsite,
  });

  final VoidCallback onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.Translations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.travel_explore,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t.auth.registerNoticeTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.auth.registerNoticeDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: onOpenWebsite,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(
                    t.auth.goToOfficialWebsite,
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.auth.registerNoticeReturnTip,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
