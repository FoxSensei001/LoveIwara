import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i_iwara/app/my_app.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'app_startup.dart';

class AppStartupShell extends StatefulWidget {
  const AppStartupShell({super.key, this.runner, this.readyBuilder});

  final AppStartupRunner? runner;
  final WidgetBuilder? readyBuilder;

  @override
  State<AppStartupShell> createState() => _AppStartupShellState();
}

class _AppStartupShellState extends State<AppStartupShell> {
  late final AppStartupRunner _runner = widget.runner ?? appStartupCoordinator;
  AppStartupProgress _progress = const AppStartupProgress(
    stage: AppStartupStage.preparing,
    value: 0.06,
    detail: 'Bootstrap',
  );
  Object? _error;
  bool _isRunning = false;
  late bool _showApp = _runner.isReady;

  @override
  void initState() {
    super.initState();
    if (!_showApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_startInitialization());
      });
    }
  }

  Future<void> _startInitialization() async {
    if (!mounted || _isRunning || _showApp) {
      return;
    }

    setState(() {
      _isRunning = true;
      _error = null;
      _progress = const AppStartupProgress(
        stage: AppStartupStage.preparing,
        value: 0.08,
        detail: 'Bootstrap',
      );
    });

    try {
      await _runner.initializeDeferred(onProgress: _handleProgress);
      if (!mounted) {
        return;
      }
      setState(() {
        _showApp = true;
        _isRunning = false;
      });
    } catch (error, stackTrace) {
      LogUtils.e(
        '延迟启动初始化失败',
        tag: '启动开屏',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _isRunning = false;
      });
    }
  }

  void _handleProgress(AppStartupProgress progress) {
    if (!mounted) {
      return;
    }
    setState(() {
      _progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showApp
          ? KeyedSubtree(
              key: const ValueKey('startup-ready'),
              child: widget.readyBuilder?.call(context) ?? const MyApp(),
            )
          : _StartupShellMaterialApp(
              key: const ValueKey('startup-splash'),
              progress: _progress,
              error: _error,
              onRetry: _isRunning ? null : _startInitialization,
            ),
    );
  }
}

class _StartupShellMaterialApp extends StatelessWidget {
  const _StartupShellMaterialApp({
    super.key,
    required this.progress,
    required this.error,
    required this.onRetry,
  });

  final AppStartupProgress progress;
  final Object? error;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final seedColor = _resolveSeedColor();
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: t.common.appName,
      theme: buildThemeData(colorScheme: colorScheme),
      darkTheme: buildThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ja', ''),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
      ],
      locale: LocaleSettings.currentLocale.flutterLocale,
      home: _StartupSplashPage(
        progress: progress,
        error: error,
        onRetry: onRetry,
      ),
    );
  }

  Color _resolveSeedColor() {
    if (!CommonConstants.usePresetColor &&
        CommonConstants.currentCustomHex.isNotEmpty) {
      return Color(int.parse('0xFF${CommonConstants.currentCustomHex}'));
    }

    final index = CommonConstants.currentPresetIndex;
    if (index >= 0 && index < ThemeService.presetColors.length) {
      return ThemeService.presetColors[index];
    }

    return const Color(0xFF2563EB);
  }
}

class _StartupSplashPage extends StatelessWidget {
  const _StartupSplashPage({
    required this.progress,
    required this.error,
    required this.onRetry,
  });

  final AppStartupProgress progress;
  final Object? error;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasError = error != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          _GlowOrb(
            alignment: Alignment.topLeft,
            color: colorScheme.primary.withValues(alpha: 0.16),
            size: 260,
          ),
          _GlowOrb(
            alignment: Alignment.bottomRight,
            color: colorScheme.tertiary.withValues(alpha: 0.12),
            size: 320,
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            key: const Key('startup-icon-shell'),
                            width: 144,
                            height: 144,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(
                                alpha: 0.84,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 32,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.surface.withValues(alpha: 0.96),
                                  colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                CommonConstants.launcherIconPath,
                                key: const Key('startup-icon'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasError) ...[
                        const SizedBox(height: 20),
                        IconButton.filledTonal(
                          key: const Key('startup-retry'),
                          onPressed: onRetry == null
                              ? null
                              : () {
                                  unawaited(onRetry!.call());
                                },
                          tooltip: t.common.retry,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      ),
    );
  }
}
