import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

/// 首次设置向导的版式：断点、度量与页面骨架。
///
/// # 为什么版式要收在这里
///
/// 五个步骤过去各自手写一套留白与字号，于是同一页里同类元素对不齐：
///
///   - 顶部留白按 `AppService.titleBarHeight`（桌面自绘标题栏 26）算，
///     而页面顶上是一只真的 `AppBar`（[kToolbarHeight] = 56）。差的这 30
///     让每一步的首块内容都压在毛玻璃标题栏底下——只有欢迎步自己多垫了一个
///     `SizedBox` 才看着正常，另外四步则是「顶到标题栏上」。
///   - 块与块之间的间距，有的步骤写 `spacing: isNarrow ? 16 : 24`，
///     欢迎步则是 16/20/20/16 一路手填，于是每翻一页留白都在跳。
///   - 「副标题 + 描述」这一对，桌面端写 24，窄屏端有的写 20 有的直接省掉
///     描述，标题在页与页之间上下浮动。
///
/// 现在步骤只描述「有哪些内容」（[StepPageLayout] 的 subtitle / description /
/// hero / content / tip 五个槽），间距、断点、留白一律由这里下发。
/// 断点也不再由调用方层层透传：[stepIsNarrow] / [stepIsDesktop] 自己读
/// MediaQuery，避免出现「播放器步给 Anime4K 硬传 isNarrow: false」这种
/// 传着传着就传错的常量。

/// 向导 AppBar 的高度。
///
/// 页面与本文件共用同一个常量，内容顶部留白才不会再跟标题栏的真实高度脱钩。
const double kStepAppBarHeight = kToolbarHeight;

/// 窄屏阈值：低于此宽度收紧留白与字号。
const double kStepNarrowWidth = 400;

/// 双栏阈值：高于此宽度改用「左文案 / 右设置」两栏。
const double kStepDesktopWidth = 800;

bool stepIsNarrow(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kStepNarrowWidth;

bool stepIsDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width > kStepDesktopWidth;

/// 向导版式的度量表。步骤里不要再出现裸数字。
class StepMetrics {
  const StepMetrics._();

  /// 块与块之间的竖向间距（也用作页面上下留白的基数）。
  static double blockGap(bool isNarrow) => isNarrow ? 16 : 24;

  /// 「副标题 → 描述」这一对之间的间距：比块间距紧，读起来才是一组。
  static double titleGap(bool isNarrow) => isNarrow ? 6 : 10;

  /// 页面左右留白。
  static double horizontalPadding(bool isNarrow, bool isDesktop) =>
      isNarrow ? 16 : (isDesktop ? 48 : 24);

  /// 双栏之间的沟宽。
  static const double columnGap = 80;

  /// 卡片内部的横向内边距（与 [GlassSettingTile] 的 16 对齐，
  /// 卡片里自绘的网格 / 列表都用它，标题与色块才在同一条竖线上）。
  static const double cardPadding = 16;

  /// 卡片圆角（与 `GlassSettingSection` 一致）。
  static const double cardRadius = 16;

  /// 步骤主标题的字号：三档断点各一个，五个步骤共用。
  static TextStyle? subtitleStyle(
    ThemeData theme,
    bool isNarrow,
    bool isDesktop,
  ) {
    final base = isDesktop
        ? theme.textTheme.displaySmall
        : (isNarrow
              ? theme.textTheme.titleLarge
              : theme.textTheme.headlineSmall);
    return base?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }

  /// 步骤描述的字号。
  static TextStyle? descriptionStyle(ThemeData theme, bool isNarrow) {
    final base = isNarrow
        ? theme.textTheme.bodyMedium
        : theme.textTheme.bodyLarge;
    return base?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.5,
    );
  }
}

/// 单个步骤的页面骨架。
///
/// 窄屏 / 手机：`图标? → 标题组 → 设置卡 → 提示条`，块间距统一。
/// 桌面：左栏放「图标? + 标题组 + 提示条」，右栏放设置卡，两栏顶对齐。
///
/// 两种断点下元素的先后顺序一致，翻页时标题与卡片都停在同一条基线上。
class StepPageLayout extends StatelessWidget {
  /// 步骤主标题（对应 `SetupStep.subtitle`）。
  final String subtitle;

  /// 步骤描述（对应 `SetupStep.description`）。五个步骤都会显示，
  /// 不再出现「欢迎步有、其余步没有」的参差。
  final String description;

  /// 标题上方的视觉主体（目前只有欢迎步的应用图标）。
  final Widget? hero;

  /// 步骤主体：一张或多张设置卡（多张时用 [StepSectionList] 串起来）。
  final Widget content;

  /// 底部提示条。
  final Widget? tip;

  const StepPageLayout({
    super.key,
    required this.subtitle,
    required this.description,
    required this.content,
    this.hero,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isNarrow = stepIsNarrow(context);
    final isDesktop = stepIsDesktop(context);

    final blockGap = StepMetrics.blockGap(isNarrow);
    final horizontalPadding = StepMetrics.horizontalPadding(
      isNarrow,
      isDesktop,
    );

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: StepMetrics.titleGap(isNarrow),
      children: [
        Text(
          subtitle,
          style: StepMetrics.subtitleStyle(theme, isNarrow, isDesktop),
        ),
        Text(description, style: StepMetrics.descriptionStyle(theme, isNarrow)),
      ],
    );

    final Widget body = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: StepMetrics.columnGap,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: blockGap,
                  children: [?hero, header, ?tip],
                ),
              ),
              Expanded(child: content),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: blockGap,
            children: [
              if (hero != null) Center(child: hero!),
              header,
              content,
              ?tip,
            ],
          );

    return SingleChildScrollView(
      // ⛔ 这里**不要**再自己加一次 AppBar 高度。
      //
      // 页面开了 `extendBodyBehindAppBar`，Scaffold 已经把「状态栏 + AppBar」
      // 一起折进了 body 的 `MediaQuery.padding.top`（见 Scaffold 的
      // `_BodyBuilder`：`max(padding.top, appBarHeight + viewPadding.top)`）。
      // 原来的代码在它之上又加了一个 `AppService.titleBarHeight`（26，桌面
      // 自绘标题栏，跟 AppBar 毫无关系），于是首块内容比该有的位置低一截；
      // 加成 kStepAppBarHeight 更是直接多让了一整条标题栏。
      // 内容照旧从毛玻璃标题栏背后滚过去，静止时刚好停在它下面一个块间距。
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        mediaQuery.padding.top + blockGap,
        horizontalPadding,
        blockGap + computeBottomSafeInset(mediaQuery),
      ),
      child: body,
    );
  }
}

/// 一列设置卡：卡与卡之间用统一的块间距，横向铺满。
class StepSectionList extends StatelessWidget {
  final List<Widget> children;

  const StepSectionList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: StepMetrics.blockGap(stepIsNarrow(context)),
      children: children,
    );
  }
}
