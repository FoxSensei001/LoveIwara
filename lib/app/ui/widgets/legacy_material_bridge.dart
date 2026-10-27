import 'package:flutter/cupertino.dart'
    as legacy_cupertino
    show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_localizations/flutter_localizations.dart'
    as legacy_l10n;
import 'package:material_ui/material_ui.dart';

/// 旧版 `package:flutter/material.dart` 的兼容桥，挂在 `MaterialApp.builder` 最外层。
///
/// 应用本体已迁到独立的 `material_ui` 包，但 extended_text_field（评论框）、
/// markdown_widget、toastification、tutorial_coach_mark、flutter_colorpicker、
/// media_kit_video、liquid_glass_easy 这些三方包仍 import 旧的 material。两边是
/// **两套互不相认的类型**，编译全绿，只在运行时出事：
///
///  1. 旧组件 `Theme.of` 找不到我们的主题，拿到 Flutter 的 fallback（恒为浅色蓝），
///     深色模式下整块发白——这里由当前新版主题同源映射出一份旧版主题；
///  2. 旧组件 `MaterialLocalizations.of` 直接断言——旧版本地化不在这里补，而是
///     由 [legacyMaterialLocalizationsDelegates] 挂到 `MaterialApp` 的同一个
///     `Localizations` 上（两边的 MaterialLocalizations 是不同类型，能并列）。
///     ⛔ 别改回在这里套 `Localizations.override`：多套一层本地化会让冷启动头几帧
///     液态玻璃的亮度采样拿到 NaN 坐标，连抛 `Infinity or NaN toInt`（实测带它 3 次、
///     不带 0 次）；
///  3. `ExtendedTextField` 一类要求祖先有**旧版** `Material`，否则断言——这里垫一层
///     透明的旧版 Material。代价：旧版 `InkWell` 的水波会画在这层上、被页面盖住
///     看不见。只影响三方包自带的按钮，不影响我们自己的组件；
///  4. 反过来，我们的组件被塞进旧包的容器（toast 卡片、markdown 节点）时，中间
///     没有**新版** Material，同样断言——所以再垫一层透明的新版 Material。
///
/// 没用官方的 `MaterialUiCompatibilityBridge`：它只映射配色和字体，
/// `pageTransitionsTheme` / `tooltipTheme` 会丢——桌面端旧路由退回带快照的 Zoom
/// 转场（撞液态玻璃的 paint 期断言），触屏长按又会弹 tooltip 截胡玻璃手势
/// （见 `buildThemeData` 的注释）。
///
/// 三方包全部迁完 `material_ui` 后整只删除。
class LegacyMaterialBridge extends StatelessWidget {
  const LegacyMaterialBridge({super.key, required this.child});

  final Widget child;

  static final Expando<legacy.ThemeData> _cache = Expando<legacy.ThemeData>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final legacy.ThemeData legacyTheme = _cache[theme] ??= buildLegacyThemeData(
      theme,
    );
    return legacy.Theme(
      data: legacyTheme,
      child: legacy.Material(
        type: legacy.MaterialType.transparency,
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}

/// 旧版 material / cupertino 的本地化，与 material_ui 那一组并列挂在 `MaterialApp` 上。
const List<LocalizationsDelegate<dynamic>>
legacyMaterialLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  legacy_l10n.GlobalMaterialLocalizations.delegate,
  legacy_l10n.GlobalCupertinoLocalizations.delegate,
];

/// 由新版主题映射出旧版主题。
///
/// ⛔ `buildThemeData` 里自定义的每一项都要在这里有对应：现在是配色、字体、
/// 页面转场、tooltip 触发方式四样。
legacy.ThemeData buildLegacyThemeData(ThemeData theme) {
  final ColorScheme s = theme.colorScheme;
  final TextTheme t = theme.textTheme;
  final TooltipTriggerMode? triggerMode = theme.tooltipTheme.triggerMode;
  return legacy.ThemeData(
    useMaterial3: theme.useMaterial3,
    platform: theme.platform,
    visualDensity: legacy.VisualDensity(
      horizontal: theme.visualDensity.horizontal,
      vertical: theme.visualDensity.vertical,
    ),
    colorScheme: legacy.ColorScheme(
      brightness: s.brightness,
      primary: s.primary,
      onPrimary: s.onPrimary,
      primaryContainer: s.primaryContainer,
      onPrimaryContainer: s.onPrimaryContainer,
      primaryFixed: s.primaryFixed,
      primaryFixedDim: s.primaryFixedDim,
      onPrimaryFixed: s.onPrimaryFixed,
      onPrimaryFixedVariant: s.onPrimaryFixedVariant,
      secondary: s.secondary,
      onSecondary: s.onSecondary,
      secondaryContainer: s.secondaryContainer,
      onSecondaryContainer: s.onSecondaryContainer,
      secondaryFixed: s.secondaryFixed,
      secondaryFixedDim: s.secondaryFixedDim,
      onSecondaryFixed: s.onSecondaryFixed,
      onSecondaryFixedVariant: s.onSecondaryFixedVariant,
      tertiary: s.tertiary,
      onTertiary: s.onTertiary,
      tertiaryContainer: s.tertiaryContainer,
      onTertiaryContainer: s.onTertiaryContainer,
      tertiaryFixed: s.tertiaryFixed,
      tertiaryFixedDim: s.tertiaryFixedDim,
      onTertiaryFixed: s.onTertiaryFixed,
      onTertiaryFixedVariant: s.onTertiaryFixedVariant,
      error: s.error,
      onError: s.onError,
      errorContainer: s.errorContainer,
      onErrorContainer: s.onErrorContainer,
      surface: s.surface,
      onSurface: s.onSurface,
      surfaceDim: s.surfaceDim,
      surfaceBright: s.surfaceBright,
      surfaceContainerLowest: s.surfaceContainerLowest,
      surfaceContainerLow: s.surfaceContainerLow,
      surfaceContainer: s.surfaceContainer,
      surfaceContainerHigh: s.surfaceContainerHigh,
      surfaceContainerHighest: s.surfaceContainerHighest,
      onSurfaceVariant: s.onSurfaceVariant,
      outline: s.outline,
      outlineVariant: s.outlineVariant,
      shadow: s.shadow,
      scrim: s.scrim,
      inverseSurface: s.inverseSurface,
      onInverseSurface: s.onInverseSurface,
      inversePrimary: s.inversePrimary,
      surfaceTint: s.surfaceTint,
    ),
    textTheme: legacy.TextTheme(
      displayLarge: t.displayLarge,
      displayMedium: t.displayMedium,
      displaySmall: t.displaySmall,
      headlineLarge: t.headlineLarge,
      headlineMedium: t.headlineMedium,
      headlineSmall: t.headlineSmall,
      titleLarge: t.titleLarge,
      titleMedium: t.titleMedium,
      titleSmall: t.titleSmall,
      bodyLarge: t.bodyLarge,
      bodyMedium: t.bodyMedium,
      bodySmall: t.bodySmall,
      labelLarge: t.labelLarge,
      labelMedium: t.labelMedium,
      labelSmall: t.labelSmall,
    ),
    // 与 `buildThemeData` 同一张表：桌面端 Zoom 关快照，原因见那边的注释。
    pageTransitionsTheme: const legacy.PageTransitionsTheme(
      builders: <TargetPlatform, legacy.PageTransitionsBuilder>{
        TargetPlatform.android: legacy.PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: legacy_cupertino.CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS:
            legacy_cupertino.CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: legacy.ZoomPageTransitionsBuilder(
          allowSnapshotting: false,
        ),
        TargetPlatform.linux: legacy.ZoomPageTransitionsBuilder(
          allowSnapshotting: false,
        ),
      },
    ),
    tooltipTheme: legacy.TooltipThemeData(
      triggerMode: triggerMode == null
          ? null
          : legacy.TooltipTriggerMode.values.byName(triggerMode.name),
    ),
  );
}
