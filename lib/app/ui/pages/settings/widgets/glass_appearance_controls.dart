import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/glass_appearance_settings.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_slider.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'glass_setting_tiles.dart';

class GlassAppearanceControls extends StatelessWidget {
  const GlassAppearanceControls({super.key, required this.service});
  final ThemeService service;

  @override
  Widget build(BuildContext context) => Obx(() {
    final settings = service.glassSettings;
    final quality = chromeGlassQuality(context);
    // 流畅档（lightweight shader）没有背景纹理可采：折射率与色散在那条路上
    // 根本不参与计算，饱和度只叠在背景模糊上。滑块不置灰，用户只会觉得「怎么
    // 调都没反应」（2026-11-21 用户报障）。
    final premium = quality == lgw.GlassQuality.premium;
    final labels = {
      GlassQualityPreference.standard: t.settings.glassQualityStandard,
      GlassQualityPreference.premium: t.settings.glassQualityPremium,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.settings.glassQuality,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${t.settings.glassQualityCurrent}: ${quality == lgw.GlassQuality.premium ? labels[GlassQualityPreference.premium] : labels[GlassQualityPreference.standard]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        for (final preference in GlassQualityPreference.values)
          GlassChoiceItem<GlassQualityPreference>(
            title: Text(labels[preference]!),
            subtitle: Text(switch (preference) {
              GlassQualityPreference.standard =>
                t.settings.glassQualityStandardDesc,
              GlassQualityPreference.premium =>
                t.settings.glassQualityPremiumDesc,
            }),
            value: preference,
            groupValue: settings.quality,
            onChanged: (value) {
              service.previewGlassSetting('quality', value.name);
              service.saveGlassSettings();
            },
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.settings.glassChromeParametersDesc,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const _GlassPreview(),
        _slider(
          context,
          t.settings.glassOpacity,
          'opacity',
          settings.opacity,
          0,
          0.8,
          divisions: 80,
          percentage: true,
        ),
        _slider(
          context,
          t.settings.glassBlur,
          'blur',
          settings.blur,
          0,
          12,
          divisions: 24,
          subtitle: t.settings.glassBlurDesc,
        ),
        ExpansionTile(
          title: Text(t.settings.glassAdvancedParameters),
          children: [
            _slider(
              context,
              t.settings.glassThickness,
              'thickness',
              settings.thickness,
              0,
              40,
              divisions: 40,
            ),
            _slider(
              context,
              t.settings.glassRefractiveIndex,
              'refractiveIndex',
              settings.refractiveIndex,
              1,
              2,
              divisions: 100,
              decimals: 2,
              enabled: premium,
              subtitle: premium ? null : t.settings.glassPremiumOnly,
            ),
            _slider(
              context,
              t.settings.glassLightIntensity,
              'lightIntensity',
              settings.lightIntensity,
              0,
              2,
              divisions: 40,
              decimals: 2,
            ),
            _slider(
              context,
              t.settings.glassSaturation,
              'saturation',
              settings.saturation,
              0,
              2,
              divisions: 40,
              decimals: 2,
              subtitle: premium ? null : t.settings.glassSaturationNeedsBlur,
            ),
            _slider(
              context,
              t.settings.glassChromaticAberration,
              'chromaticAberration',
              settings.chromaticAberration,
              0,
              0.03,
              divisions: 30,
              decimals: 3,
              enabled: premium,
              subtitle: premium ? null : t.settings.glassPremiumOnly,
            ),
            GlassSwitchItem(
              title: Text(t.settings.glassShadows),
              value: settings.shadows,
              onChanged: (value) {
                service.previewGlassSetting('shadows', value);
                service.saveGlassSettings();
              },
            ),
          ],
        ),
        GlassSettingTile(
          icon: Icons.restore,
          title: Text(t.settings.glassResetParameters),
          onTap: service.resetGlassSettings,
        ),
      ],
    );
  });

  Widget _slider(
    BuildContext context,
    String title,
    String key,
    double value,
    double min,
    double max, {
    required int divisions,
    int decimals = 1,
    bool percentage = false,
    String? subtitle,
    bool enabled = true,
  }) => _ParamSlider(
    service: service,
    title: title,
    settingKey: key,
    value: value,
    min: min,
    max: max,
    divisions: divisions,
    decimals: decimals,
    percentage: percentage,
    subtitle: subtitle,
    enabled: enabled,
  );
}

/// 一个参数滑块。拖动期间在屏幕**另一半**浮出一份预览（2026-11-21 用户报：
/// 参数多，手机上调一个就得滑回顶上看效果，再滑下来接着调）。
///
/// 放在另一半而不是固定顶部：滑块本身可能就在顶部，手指和预览会撞在一起。
/// 松手后淡出；页面里那份常驻预览照旧在。
class _ParamSlider extends StatefulWidget {
  const _ParamSlider({
    required this.service,
    required this.title,
    required this.settingKey,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.decimals,
    required this.percentage,
    required this.subtitle,
    required this.enabled,
  });

  final ThemeService service;
  final String title;
  final String settingKey;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final int decimals;
  final bool percentage;
  final String? subtitle;
  final bool enabled;

  @override
  State<_ParamSlider> createState() => _ParamSliderState();
}

class _ParamSliderState extends State<_ParamSlider> {
  static const _fade = Duration(milliseconds: 180);

  OverlayEntry? _entry;
  final _visible = ValueNotifier<bool>(false);
  Timer? _removeTimer;

  void _showPreview() {
    _removeTimer?.cancel();
    if (_entry == null) {
      final box = context.findRenderObject() as RenderBox?;
      final height = MediaQuery.sizeOf(context).height;
      final centerY = box == null || !box.hasSize
          ? height
          : box.localToGlobal(box.size.center(Offset.zero)).dy;
      final atTop = centerY > height / 2;
      _entry = OverlayEntry(
        builder: (_) => _FloatingPreview(visible: _visible, atTop: atTop),
      );
      Overlay.of(context, rootOverlay: true).insert(_entry!);
      // 先以透明插进去，下一帧再显形，淡入才有动画可走。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_entry != null) _visible.value = true;
      });
    } else {
      _visible.value = true;
    }
  }

  void _hidePreview() {
    _visible.value = false;
    _removeTimer?.cancel();
    _removeTimer = Timer(_fade, _removeEntry);
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _removeTimer?.cancel();
    _removeEntry();
    _visible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatted = widget.percentage
        ? '${(widget.value * 100).round()}%'
        : widget.value.toStringAsFixed(widget.decimals);
    return Column(
      children: [
        GlassSettingTile(
          enabled: widget.enabled,
          title: Text(widget.title),
          subtitle: widget.subtitle == null ? null : Text(widget.subtitle!),
          trailing: Text(
            formatted,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Semantics(
          label: widget.title,
          child: GlassSlider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: formatted,
            onChangeStart: widget.enabled ? (_) => _showPreview() : null,
            onChanged: widget.enabled
                ? (value) => widget.service.previewGlassSetting(
                    widget.settingKey,
                    value,
                  )
                : null,
            onChangeEnd: widget.enabled
                ? (_) {
                    _hidePreview();
                    widget.service.saveGlassSettings();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

/// 拖滑块时浮出来的那份预览。不吃点击：手指还按在滑块上，别挡住任何东西。
class _FloatingPreview extends StatelessWidget {
  const _FloatingPreview({required this.visible, required this.atTop});

  final ValueListenable<bool> visible;
  final bool atTop;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Positioned(
      left: 16,
      right: 16,
      // 顶部让开状态栏和标题栏，底部让开手势条。
      top: atTop ? padding.top + 64 : null,
      bottom: atTop ? null : padding.bottom + 24,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (context, shown, child) => AnimatedOpacity(
                opacity: shown ? 1 : 0,
                duration: _ParamSliderState._fade,
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: shown ? 1 : 0.96,
                  duration: _ParamSliderState._fade,
                  curve: Curves.easeOut,
                  child: child,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const _GlassPreviewStrip(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 参数区顶上的实时预览：一枚胶囊 + 一枚圆钮，压在一块有色、有纹理的底子上。
///
/// 为什么要有它：设置页本身几乎没有玻璃（只有返回钮），身后又是平涂底色，
/// 折射、色散、厚度画上去和不画一样——用户拖滑块看不出任何变化，就会以为
/// 参数失效（2026-11-21 用户报障「怎么调都没有意义」）。这里给玻璃一块
/// 「有东西可折射」的背景，走的是和全站 chrome 同一套 [GlassSurface]，
/// 参数一变就跟着变。
class _GlassPreview extends StatelessWidget {
  const _GlassPreview();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: _GlassPreviewStrip(),
  );
}

/// 预览条本体：页面里那份和拖动时浮出来的那份共用。
class _GlassPreviewStrip extends StatelessWidget {
  const _GlassPreviewStrip();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 104,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _PreviewBackdropPainter(cs)),
            Center(
              child: GlassChromeLayer(
                group: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassSurface(
                      liquidTouch: false,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: GlassTokens.iconSize,
                            color: cs.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.settings.glassPreview,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: cs.onSurface),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 预览底子：主题色渐变 + 斜条纹 + 几枚圆点。条纹边缘锐利，折射的弯曲和
/// 色散的彩边都落在它上面才看得出来。
class _PreviewBackdropPainter extends CustomPainter {
  _PreviewBackdropPainter(this.cs);
  final ColorScheme cs;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [cs.primary, cs.tertiary, cs.secondary],
        ).createShader(rect),
    );
    final stripe = Paint()..color = cs.surface.withValues(alpha: 0.55);
    const gap = 22.0;
    const width = 9.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height)
          ..lineTo(x + width, size.height)
          ..lineTo(x + width + size.height, 0)
          ..lineTo(x + size.height, 0)
          ..close(),
        stripe,
      );
    }
    final dot = Paint()..color = cs.onPrimary.withValues(alpha: 0.85);
    for (final f in const [
      Offset(0.12, 0.3),
      Offset(0.3, 0.75),
      Offset(0.55, 0.22),
      Offset(0.72, 0.7),
      Offset(0.9, 0.35),
    ]) {
      canvas.drawCircle(Offset(f.dx * size.width, f.dy * size.height), 7, dot);
    }
  }

  @override
  bool shouldRepaint(_PreviewBackdropPainter oldDelegate) =>
      oldDelegate.cs != cs;
}
