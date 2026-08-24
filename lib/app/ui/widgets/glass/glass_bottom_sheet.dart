import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// `showModalBottomSheet` 正文的收口壳。
///
/// 收口前：24 个文件各写一份 `Container(color: Colors.white,
/// borderRadius: BorderRadius.vertical(top: Radius.circular(16)))`
/// 当外壳——`Colors.white` 是硬编码，暗色主题下这些弹窗全是一块刺眼的白板；
/// 圆角、内边距、标题行、底部安全区（[computeSheetBottomInset]）也是各写各的。
///
/// 2026-08-24 给内容接上液态：**面板背景本身不接**（用户明确要求——弹窗/
/// 弹层的壳保持原样，不要变透明玻璃），只给壳里的内容（标题行按钮、动作行）
/// 套一层 [LiquidGlassScope]（钉死 [kChromeGlassBackend]，与页面 chrome
/// 同一档）。做法是把 scope 包在 `child`/`builder(...)` 外面、壳自己的
/// `GlassSurface` 调用之外——壳的背景读的是它自己 build 时的祖先 scope
/// （面板挂在根 Navigator 上，天然没有祖先，落回 plain，与收口前一致），
/// 内容里的 `GlassIconButton`/`GlassButtonGroup`/[GlassComposerActions] 等
/// 才会跟着换档、长出液态档的长按蠕动。壳内如果套了
/// `ListView`/`SingleChildScrollView`，**列表 item 本身不能含 `GlassSurface`**
/// （约束见 `liquid_glass_material.dart` 文件头）——本仓库现状是干净的，新增
/// 调用点也要守这条。
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.maxHeightFactor,
    this.scrollable = false,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
  });

  /// 标题（可选）；不传就没有标题行，只留拖拽把手 + 正文。
  final String? title;

  final Widget child;

  /// 有标题时是否带右侧玻璃关闭圆钮（约定同 [GlassAlertDialog]）。
  final bool showCloseButton;

  /// 顶部拖拽把手（一条短横线，纯装饰，不接手势——`showModalBottomSheet`
  /// 本身已经支持整块下滑关闭，把手只是视觉提示）。
  final bool showDragHandle;

  /// 正文最高不超过屏幕高度的这个比例（超出部分交给 [scrollable] 内部滚动）。
  /// 不传则不限高，由调用方自己控制内容高度。
  final double? maxHeightFactor;

  /// 正文过长时是否允许内部滚动。
  final bool scrollable;

  final EdgeInsetsGeometry padding;

  /// 标题行左右不许贴边的下限——正文常见「不要横向内边距，让 [ListTile]
  /// 自己那圈 16 撑距离」的写法（下载任务「更多」菜单等），但标题行没有那圈
  /// 自带内边距，跟着 [padding] 的横向值一起归零就会贴到弹层边框上。标题行
  /// 因此**不直接吃 [padding] 的横向值**，改吃这个下限与它的较大者——
  /// 正文自己的横向内边距、成因不变。
  static const double _minTitleHorizontalInset = 16;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    Widget body = child;
    if (scrollable) {
      body = SingleChildScrollView(child: body);
    }

    final EdgeInsets resolvedPadding = padding.resolve(
      Directionality.of(context),
    );
    final double titleLeft = resolvedPadding.left < _minTitleHorizontalInset
        ? _minTitleHorizontalInset
        : resolvedPadding.left;
    final double titleRight = resolvedPadding.right < _minTitleHorizontalInset
        ? _minTitleHorizontalInset
        : resolvedPadding.right;

    // 正文的内边距：有标题时顶部已经由标题行自己的间距占掉，这里不再重复。
    final EdgeInsets bodyPadding = EdgeInsets.fromLTRB(
      resolvedPadding.left,
      title != null ? 0 : resolvedPadding.top,
      resolvedPadding.right,
      resolvedPadding.bottom,
    );
    // Flexible 只能直接挂在 Column 底下——Padding 包一层会触发
    // "Incorrect use of ParentDataWidget"，所以内边距得包在 Flexible **里面**。
    final Widget paddedBody = Padding(padding: bodyPadding, child: body);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              titleLeft,
              resolvedPadding.top,
              titleRight,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title!, style: theme.textTheme.titleLarge),
                ),
                if (showCloseButton) ...[
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => AppService.tryPop(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (maxHeightFactor != null) Flexible(child: paddedBody) else paddedBody,
      ],
    );

    return SheetBottomSafeArea(
      child: ConstrainedBox(
        constraints: maxHeightFactor == null
            ? const BoxConstraints()
            : BoxConstraints(maxHeight: screenHeight * maxHeightFactor!),
        child: _GlassBottomSheetShell(
          showDragHandle: showDragHandle,
          child: content,
        ),
      ),
    );
  }
}

/// 外壳：圆角顶 + 玻璃材质，替掉各页手写的 `Colors.white` 容器。
///
/// 复用 [GlassSurface]（全 App 唯一的玻璃材质定义处）而不是自己再画一套
/// fill/stroke——顶部单独圆角是 [GlassSurface.borderRadius] 已支持的口子，
/// 液态档要跟进也只用改这一处。
class _GlassBottomSheetShell extends StatelessWidget {
  const _GlassBottomSheetShell({
    required this.child,
    required this.showDragHandle,
  });

  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 面板背景使用不透明的 Material 底色（surfaceContainerLow），
    // 避免半透明玻璃导致下层被遮挡的内容透出来。
    // 内部按钮通过 LiquidGlassScope 接入液态档。
    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
          ],
          // 液态档由 [showGlassBottomSheet] 在路由层统一供（见那里的注释），
          // 壳自己不再包——包在壳里的话，自建壳的弹层（表情选择器一类）
          // 就漏掉了。
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// 打开一块 [GlassBottomSheet]。`backgroundColor: transparent` +
/// `isScrollControlled: true` 是固定搭配（壳自己画背景、自己算高度），
/// 不用在调用点重复传。
///
/// ⭐ 液态档在**这一层**供，不在 [GlassBottomSheet] 壳里：弹层内容不一定用
/// 我们的壳（表情选择器就是自建 `DraggableScrollableSheet` + 自己的
/// `Container`），供在壳里那些就全漏了，里头的新组件会静默落回传统档。
/// 供在路由上，「走了这个入口就一定有档」。壳自己的背景不受影响——它画的是
/// 不透明 `Material`，不是 `GlassSurface`。
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (context) =>
        LiquidGlassScope(backend: kChromeGlassBackend, child: builder(context)),
  );
}

/// [GlassBottomSheet] 的可拖拽缩放变体。
///
/// [GlassBottomSheet] 是钉死高度（+ 可选内部滚动）的壳，适合表单/选项这类
/// 长度大致可预期的内容。评论列表一类**可能很长、用户会想拖大看更多**的内容
/// 用它并不合适——2026-08-24 之前，这类弹层（评论回复列表、播放器设置面板）
/// 各自手写了一份 `DraggableScrollableSheet` + `Container(color: colorScheme.surface)`
/// 当外壳，和 [GlassBottomSheet] 收编前的裸 `showModalBottomSheet` 是同一个问题：
/// 硬编码底色、圆角、拖拽条、安全区各写一份。
///
/// 这里只收口「壳」（玻璃材质 + 顶部圆角 + 拖拽条 + 安全区），**不**收口标题行——
/// 各处标题行结构差异较大（有的带图标+计数+两枚动作钮，有的只是简单标题+关闭钮），
/// 强行统一反而会丢信息。[builder] 拿到的 `scrollController` 必须接到内容的
/// 可滚动组件上（`ListView(controller: scrollController)` 一类）——它由
/// `DraggableScrollableSheet` 提供，滚动到底部与拖拽变高共用同一条手势链路，
/// 这也是不能直接套 [GlassBottomSheet]（自己接 [SingleChildScrollView]）的原因。
///
/// 用 [showGlassDraggableBottomSheet] 打开。
class GlassDraggableBottomSheet extends StatelessWidget {
  const GlassDraggableBottomSheet({
    super.key,
    required this.builder,
    this.initialChildSize = 0.6,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.92,
    this.snap = false,
  });

  /// 内容构建器，`scrollController` 必须接到正文的可滚动组件上。
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  /// 拖拽松手后是否吸附到 [DraggableScrollableSheet] 的 snap 位置。
  final bool snap;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      snap: snap,
      // 同 [_GlassBottomSheetShell]：只给内容接液态，壳自己的 GlassSurface
      // 留在 LiquidGlassScope 之外，面板背景保持原样。
      builder: (context, scrollController) => SheetBottomSafeArea(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              // 同上：液态档由 [showGlassDraggableBottomSheet] 在路由层供。
              Expanded(child: builder(context, scrollController)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 打开一块 [GlassDraggableBottomSheet]。同 [showGlassBottomSheet]，
/// `backgroundColor: transparent` + `isScrollControlled: true` 固定搭配，
/// 液态档同样供在这一层。
Future<T?> showGlassDraggableBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (context) =>
        LiquidGlassScope(backend: kChromeGlassBackend, child: builder(context)),
  );
}
