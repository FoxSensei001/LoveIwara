// pages/login/login_dialog.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/captcha.model.dart';

import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../services/storage_service.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  /// 显示登录对话框
  static Future<bool?> show(BuildContext context) {

    // 使用 DraggableScrollableSheet 实现可拖拽到顶部的效果
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const LoginDialog(),
        ),
      ),
    );
  }

  /// 便捷的静态调用方法，替换 Get.toNamed(Routes.LOGIN)
  static Future<bool?> showLoginDialog() {
    final context = Get.context;
    if (context != null) {
      return show(context);
    }
    return Future.value(false);
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  final StorageService _storage = StorageService();
  final ConfigService _configService = Get.find<ConfigService>();

  // 登录表单控制器
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // 注册表单控制器
  final TextEditingController _captchaController = TextEditingController();

  // 表单键
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  // 加载状态
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _isCaptchaLoading = false;

  // 当前是否为登录模式
  bool _isLoginMode = true;

  final Rxn<Captcha?> _captcha = Rxn<Captcha>();

  // 焦点节点
  final FocusNode _loginPasswordFocus = FocusNode();
  final FocusNode _registerCaptchaFocus = FocusNode();

  // 密码可见性切换
  bool _isPasswordVisible = false;

  // State类添加新变量
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();

    // 初始化时加载保存的登录信息
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final rememberMe = _configService[ConfigKey.REMEMBER_ME_KEY];
      final credentials = await _storage.readCredentials();
      if (mounted) {
        setState(() {
          _loginEmailController.text = credentials?['username'] ?? '';
          _loginPasswordController.text = credentials?['password'] ?? '';
          _rememberMe = rememberMe;
        });
      }
    } catch (e) {
      LogUtils.e('加载保存的凭据失败: $e', tag: 'LoginPage');
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.failedToLoadSavedCredentials,
          type: MDToastType.warning,
        ),
      );
    }
  }

  void _toggleRememberMe(bool newValue) {
    if (mounted) {
      setState(() {
        _rememberMe = newValue;
      });
    }
    // 立即持久化状态
    _configService[ConfigKey.REMEMBER_ME_KEY] = newValue;
    if (!newValue) {
      _storage.clearCredentials();
    }
  }

  void _fetchCaptcha() async {
    // 立即清除旧验证码和输入内容
    _captcha.value = null;
    _captchaController.clear(); // 清空验证码输入框
    if (mounted) {
      setState(() {
        _isCaptchaLoading = true;
      });
    }
    try {
      ApiResult<Captcha> res = await _authService.fetchCaptcha();
      if (res.isSuccess) {
        // 直接更新状态，不需要延迟
        if (mounted) {
          setState(() {
            _captcha.value = res.data;
          });
        }
      } else {
        showToastWidget(
          MDToastWidget(message: res.message, type: MDToastType.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCaptchaLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _captchaController.dispose();
    _loginPasswordFocus.dispose();
    _registerCaptchaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 统一返回内容部分
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      icon: const Icon(Icons.login),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      icon: const Icon(Icons.person_add),
                    ),
                  ],
                  selected: {_isLoginMode},
                  onSelectionChanged: (Set<bool> newSelection) {
                    final newMode = newSelection.first;
                    if (newMode != _isLoginMode && mounted) {
                      setState(() {
                        _isLoginMode = newMode;
                      });
                      if (!newMode && _captcha.value == null) {
                        _fetchCaptcha();
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
          // 内容区域
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isLoginMode
                  ? _buildLoginForm(context)
                  : _buildRegisterForm(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth > 600 ? 400 : double.infinity,
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _loginEmailController,
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
                          FocusScope.of(
                            context,
                          ).requestFocus(_loginPasswordFocus);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _loginPasswordController,
                        decoration: InputDecoration(
                          labelText: t.auth.password,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        focusNode: _loginPasswordFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return t.auth.pleaseEnterPassword;
                          }
                          if (value.length < 6) {
                            return t.auth.passwordMustBeAtLeast6Characters;
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _toggleRememberMe(!_rememberMe);
                            },
                            icon: Icon(
                              _rememberMe
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text(
                              slang.t.auth.rememberMe,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_loginFormKey.currentState!.validate()) {
                                  _login();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                t.auth.login,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth > 600 ? 400 : double.infinity,
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _loginEmailController,
                        decoration: InputDecoration(
                          labelText: t.auth.usernameOrEmail,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.auth.pleaseEnterUsernameOrEmail;
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return t.errors.invalidEmail;
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (_captcha.value != null) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_registerCaptchaFocus);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _isCaptchaLoading
                                    ? _buildCaptchaShimmer(constraints.maxWidth)
                                    : LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            width: constraints.maxWidth,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).dividerColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: _captcha.value != null
                                                  ? Image.memory(
                                                      base64Decode(
                                                        _captcha.value!.data
                                                            .split(',')[1],
                                                      ),
                                                      fit: BoxFit.contain,
                                                      frameBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            frame,
                                                            wasSynchronouslyLoaded,
                                                          ) {
                                                            if (frame == null ||
                                                                _isCaptchaLoading) {
                                                              return _buildCaptchaShimmer(
                                                                constraints
                                                                    .maxWidth,
                                                              );
                                                            }
                                                            return child;
                                                          },
                                                    )
                                                  : Center(
                                                      child: Text(
                                                        t.auth.captchaNotLoaded,
                                                      ),
                                                    ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: _isCaptchaLoading
                                    ? null
                                    : _fetchCaptcha,
                                tooltip: t.auth.refreshCaptcha,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _captchaController,
                            decoration: InputDecoration(
                              labelText: t.auth.captcha,
                              prefixIcon: const Icon(Icons.security),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            focusNode: _registerCaptchaFocus,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return t.auth.pleaseEnterCaptcha;
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              if (_registerFormKey.currentState!.validate()) {
                                _register();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isRegistering
                            ? null
                            : () {
                                if (_registerFormKey.currentState!.validate()) {
                                  _register();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isRegistering
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                t.auth.register,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCaptchaShimmer(double containerWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: containerWidth,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _login() async {
    final usernameOrEmail = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    ApiResult result = await _authService.login(usernameOrEmail, password);

    if (result.isSuccess) {
      await _userService.fetchUserProfile();
      showToastWidget(
        MDToastWidget(
          message: slang.t.auth.loginSuccess,
          type: MDToastType.success,
        ),
      );
      _userService.startNotificationTimer();

      if (_rememberMe) {
        await _storage.writeCredentials(usernameOrEmail, password);
      } else {
        await _storage.clearCredentials();
      }

      // 关闭 Dialog 并返回成功状态
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
        position: ToastPosition.bottom,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _register() async {
    final email = _loginEmailController.text.trim();
    final captchaAnswer = _captchaController.text.trim();

    if (_captcha.value == null) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.auth.captchaNotLoaded,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isRegistering = true;
      });
    }

    try {
      ApiResult result = await _authService.register(
        email,
        _captcha.value!.id,
        captchaAnswer,
      );
      if (result.isSuccess) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.auth.emailVerificationSent,
            type: MDToastType.success,
          ),
        );
        // 切换回登录视图
        if (mounted) {
          setState(() {
            _isLoginMode = true;
          });
        }
      } else {
        showToastWidget(
          MDToastWidget(message: result.message, type: MDToastType.error),
          position: ToastPosition.bottom,
        );
        // 发生错误时刷新验证码
        _fetchCaptcha();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }
}
