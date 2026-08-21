import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 设置页（主页 + 全部子页）共用的玻璃骨架。
///
/// 走「详情 / 二级页标准配方」：[GlassHeaderOverlay] 把列表铺满整个区域，
/// header 行浮在上方，蒙层从 0 一路渐隐到 `headerExtent + headerFadeExtent`
/// —— 这多出来的一段渐隐是关键，否则渐变在 header 行底缘被硬切，会在内容上
/// 糊出一条肉眼可见的暗带（读起来像「阴影很重」）。所以这里用 Stack 而不是
/// `SliverAppBar.flexibleSpace`：后者的高度封死在 `statusBar + 56`，多留不出
/// 那一段。
///
/// 调用方只给内容 [slivers]，顶部让位由骨架自己插一段 spacer 完成，各页原有的
/// 内容 padding 不用动。
class GlassSettingsScaffold extends StatelessWidget {
  final String title;

  /// 标题行右侧的动作位（走 [GlassIconButton]），尾缘自带 16 右边距。
  final List<Widget>? actions;

  /// 页面内容的 sliver 列表（不含 header，也不用自己让出 header 高度）。
  final List<Widget> slivers;

  /// 返回钮显隐的强制覆盖；不传则按 [_resolveShowBack] 推导。
  final bool? showBack;

  /// 自定义返回行为；不传则走 [AppService.tryPop]。
  final VoidCallback? onBack;

  /// 滚动控制器（需要回顶 / 监听滚动的页面传）。
  final ScrollController? controller;

  const GlassSettingsScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions,
    this.showBack,
    this.onBack,
    this.controller,
  });

  /// 要不要画返回钮，从「所处的导航栈」推导，而不是从调用方传的布尔值。
  ///
  /// - 设置内部还能退（窄屏的分区页、任意屏宽的三级页）→ 画，退一层。
  /// - 宽屏的分区根页 → 不画：左栏就是它的返回，右栏再来一个是多余的。
  /// - 窄屏的一级列表（内部退无可退）→ 画，[AppService.tryPop] 会一路走到
  ///   宿主 Shell，弹掉整棵设置树。
  bool _resolveShowBack(BuildContext context) {
    if (showBack != null) return showBack!;
    final canPopInner = Navigator.maybeOf(context)?.canPop() ?? false;
    if (canPopInner) return true;
    return MediaQuery.sizeOf(context).width <= kSettingsTwoPaneBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final bool showBackButton = _resolveShowBack(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        // 视口铺满整个区域（不能在外面套 Padding，否则内容会在 header 下边缘
        // 被裁掉、永远滚不到 header 背后）；首屏留白交给列表自己的 spacer。
        body: CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: headerExtent)),
            ...slivers,
          ],
        ),
        // header 行：左 返回圆钮（窄屏才有）/ 中 标题胶囊 / 右 动作位
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBackButton) ...[
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: t.common.back,
                  onPressed: onBack ?? AppService.tryPop,
                ),
                const SizedBox(width: 8),
              ],
              // 标题胶囊：点按/长按弹出完整标题弹窗（长标题被截断时的出口）
              Expanded(child: GlassTitlePill(title: title)),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...actions!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
