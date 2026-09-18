import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_measured_box.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// [GlassAlertDialog] 正文下方一个动作按钮的描述。
///
/// 收口前，80 处裸 `AlertDialog` 各自手写 `actions:` 列表——按钮顺序、
/// 危险色（`cs.error` vs 硬编码红）、要不要强调都不统一，且清一色裸
/// `TextButton`/`FilledButton`。这里把「按下去发生什么」和「长什么样」
/// 拆开：调用点只给语义（label + 是否危险动作），渲染统一走
/// `GlassButtonGroup` + `GlassTextActionButton`——多个动作键共处同一坨玻璃，
/// 按住会一起蠕动。
class GlassDialogAction {
  const GlassDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.emphasized = true,
    this.loading = false,
  });

  final String label;

  /// 传 `null` 表示这个动作暂时禁用（例如提交进行中）——原样透传给
  /// `GlassTextActionButton.onPressed`，行为与它直接传 `onPressed: null` 一致。
  ///
  /// # ⛔ 要关弹窗必须写 `rootNavigator: true`
  ///
  /// 这张弹窗挂在 **root navigator** 上（[showGlassAlertDialog] 走
  /// `showAppDialog(useRootNavigator: true)`），而调用点的 context 多半在 shell 的
  /// 嵌套 navigator 里。于是那句顺手写下的
  ///
  /// ```dart
  /// onPressed: () => Navigator.of(context).pop(true)   // ⛔ 错
  /// ```
  ///
  /// pop 掉的是**调用它的那一页**，弹窗纹丝不动。真机上的样子是「点了确定，背景
  /// 换成了上一页，弹窗还杵在屏幕中间」——而且不报任何错。正确写法：
  ///
  /// ```dart
  /// onPressed: () => Navigator.of(context, rootNavigator: true).pop(true)
  /// ```
  final VoidCallback? onPressed;

  /// 危险动作（删除/清空一类不可逆操作）：文字转 `cs.error` 语义色。
  final bool destructive;

  /// 是否是本弹窗的主动作：转主色 + 字重加粗。次要动作（取消一类）传 false
  /// 留默认色。列表里最多应该有一个 emphasized 动作。
  final bool emphasized;

  /// 这枚动作正在执行：文字原位换成转圈、按钮置灰。见
  /// [GlassTextActionButton.loading]。
  final bool loading;
}

/// `AlertDialog` 的收口替代品——统一标题行 / 关闭钮 / 动作按钮的结构与配色。
///
/// 液态档由 [GlassDialogRoute] 在路由层统一供（见 `glass_dialog_motion.dart`），
/// 本组件不自己包 scope。面板背景是不透明 `Material`，不是 `GlassSurface`，
/// 所以「弹窗背景不要变透明玻璃」这条要求照旧成立；变的只是标题行关闭钮和
/// 动作行按钮组的材质与手感。
///
/// 动作行（[actions]）走 [GlassButtonGroup] + `GlassTextActionButton`——多个
/// 动作键共处同一坨玻璃，按住会一起蠕动（[GlassButtonGroup.touchFlex]
/// 默认开），不是各自一只裸 `TextButton`/`FilledButton`；横向装不下时按
/// `_fitActionButtons` 收窄（先压内边距、再等比缩字），既不换行也不省略号。
///
/// 用 [showGlassAlertDialog] 打开，不要直接 `showDialog(GlassAlertDialog(...))`
/// ——出入场动画、安全区、主题继承都在那层。
class GlassAlertDialog extends StatelessWidget {
  const GlassAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions = const [],
    this.showCloseButton = true,
    this.scrollable = false,
    this.maxWidth = 400,
    this.insetPadding = defaultInsetPadding,
    this.floatingActions = false,
  });

  /// 动作行浮在正文之上（正文铺到面板底，从动作胶囊背后滚过去，底部垫一层
  /// 渐隐蒙层），而不是在正文下面单独占一行。正文会一直长的弹窗（列表、表单）用。
  ///
  /// 正文怎么给动作行让位：
  /// - [scrollable] 为 true 时由本组件的滚动视图加底部内边距；
  /// - 自带列表的正文：本组件把让位高度塞进 `MediaQuery.padding.bottom`，
  ///   `ListView` / `GridView` 不传 `padding` 时会自动把它用成底部内边距。
  ///   自己写了 `padding` 的滚动视图要自己加上
  ///   `MediaQuery.paddingOf(context).bottom`。
  final bool floatingActions;

  /// 面板与屏幕边缘之间的留白。
  ///
  /// ⛔ 收口前这里只有 `Center + ConstrainedBox(maxWidth)`，**一点外边距都没有**：
  /// 宽屏上看不出来（400 的面板本来就浮在屏幕中间），窄屏上 `maxWidth` 大于
  /// 屏幕宽度，面板就贴着两条屏幕边整块铺满，读起来不像一层弹出的卡片，而像
  /// 换了一页。全站其余弹窗壳（[GlassPickerDialog]、`ResponsiveDialogWidget`
  /// 宽屏档）走的都是 Material `Dialog`，白拿它 40/24 的 `insetPadding`——
  /// 唯独这只没有，于是「有的弹窗有边距有的没有」。默认值取的就是 Material
  /// `Dialog` 的那一份，让两类壳在同一块屏幕上对得齐。
  ///
  /// 键盘不在这里让：根布局 [MyAppLayout] 是 `resizeToAvoidBottomInset` 的
  /// Scaffold，整棵 Navigator（含弹窗路由）已被整体抬到键盘之上，`viewInsets`
  /// 在它之下恒为 0（见 `media_query_insets_fix.dart`），再叠一次只会多让一段。
  static const EdgeInsets defaultInsetPadding = EdgeInsets.symmetric(
    horizontal: 40,
    vertical: 24,
  );

  /// 传 `null` 跳过整个内建标题行（含右上角关闭钮）——用于标题位置需要放
  /// 自定义内容（搜索框、额外的图标动作）的场合，这时 [showCloseButton]
  /// 不再生效，调用方要自己在 [content] 里搭标题行和关闭键（关闭键仍应走
  /// `GlassIconButton(standalone: true)`，约定不变，只是不再由本组件代建）。
  final String? title;
  final Widget? content;
  final List<GlassDialogAction> actions;

  /// 标题行是否带右上角玻璃圆钮关闭键。约定统一走 [GlassIconButton]
  /// （`standalone: true`），不要在调用点各写各的关闭图标。[title] 为 null
  /// 时本项被忽略（整个标题行都不建）。
  final bool showCloseButton;

  /// 正文过长时是否允许内部滚动（对齐 `AlertDialog(scrollable: true)`）。
  final bool scrollable;

  /// 面板最大宽度。默认 400 是「提示/确认」这类短内容的舒适宽度；
  /// 标签浏览器、变量说明这类需要摆下一张列表或宽表格的内容可以调大。
  final double maxWidth;

  /// 见 [defaultInsetPadding]。
  final EdgeInsets insetPadding;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget? body = content;
    if (scrollable &&
        body != null &&
        !(floatingActions && actions.isNotEmpty)) {
      body = SingleChildScrollView(child: body);
    }
    if (body != null) {
      // ⛔ [content] 显式关回传统档，别跟着路由那层液态 scope 走。
      //
      // 这条边界是 2026-08-24 用户在真机上纠正过的：弹窗**面板和正文**不该
      // 变成折射玻璃，只有关闭钮和动作行按钮组该换。而 [content] 是调用方
      // 给的任意内容——标签浏览器、变量说明这类还会往里塞
      // `ListView`/`SingleChildScrollView`，正是 lens 最不该进的地方。
      // 路由层供档是为了让「弹窗里的按钮」不再漏，不是为了把正文一起卷进来。
      body = LiquidGlassScope(backend: flatGlassBackend(context), child: body);
    }

    // 液态档不在这里供了——[GlassDialogRoute] 已经在路由层给整张弹窗供上
    // （见 `glass_dialog_motion.dart`），本组件只管结构。面板背景仍是不透明
    // `Material`（不是 `GlassSurface`），不受 scope 影响，透底问题不会回来。
    final closeButton = showCloseButton
        // group: false —— 单独一枚圆钮，收进层里省不出 backdrop 采样，
        // 却会吃掉它按下时的底色加深（同一层玻璃只有一份材质）。
        ? GlassChromeLayer(
            group: false,
            child: GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.close),
              tooltip: t.common.close,
              onPressed: () => AppService.tryPop(),
            ),
          )
        : null;

    final Widget actionRow =
        // ⛔ 这层 `LayoutBuilder` 长在**面板里、玻璃之外**：玻璃件会长在
        // `IntrinsicHeight` 底下（侧边导航栏的 trailing 就是），而
        // `LayoutBuilder` 一进那种量法就抛——`GlassSurface` 当初正是
        // 为了这条才没用它（见 test/glass_surface_size_parity_test.dart
        // 最后一例）。这里的祖先链上没有 intrinsics，安全。
        LayoutBuilder(
          // ⛔ 量文字必须在**面板 `Material` 之内**做——动作键的文字
          // 样式继承的是这套 DefaultTextStyle，见
          // [GlassTextActionButton.measureLabelWidth]。
          builder: (context, constraints) => Align(
            alignment: Alignment.centerRight,
            child: GlassChromeLayer(
              // group: false —— 动作行整只就是一块玻璃
              // （GlassButtonGroup 的胶囊），同上。
              group: false,
              child: GlassButtonGroup(
                children: _fitActionButtons(context, constraints.maxWidth),
              ),
            ),
          ),
        );

    return Padding(
      padding: insetPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              // ⛔ `stretch` 不是排版口味，是道闸门：`start` 时正文拿到的是
              // 松约束（0..maxWidth），正文自己说多宽就多宽——调用点只要塞进
              // 一个宽度算出来接近 0 的盒子（`SizedBox(width: double.minPositive)`
              // 这种 Material `AlertDialog` 专用的老写法就是，它靠的是
              // `AlertDialog` 内部那层 `IntrinsicWidth`，本组件没有），正文就被
              // 压成一条竖线，选项文字一个字一行。标题行自带 `Expanded`，面板
              // 本来就恒等于 `maxWidth`，把正文一起拉满不改变既有观感，却让
              // 「正文塌成 0 宽」这类事故从此不可能发生。
              //
              // 顺带，动作行也因此拿到**紧**约束——收窄档要的面板内容宽度就是
              // 从这里传下去的 `maxWidth`（见 `_fitActionButtons`）。
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title!,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        if (closeButton != null) ...[
                          const SizedBox(width: 8),
                          closeButton,
                        ],
                      ],
                    ),
                  ],
                  if (floatingActions && actions.isNotEmpty) ...[
                    if (title != null) const SizedBox(height: 16),
                    Flexible(
                      child: _FloatingActionsBody(
                        scrollable: scrollable,
                        actionRow: actionRow,
                        body: body,
                      ),
                    ),
                  ] else ...[
                    if (body != null) ...[
                      const SizedBox(height: 16),
                      Flexible(child: body),
                    ],
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      actionRow,
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 把 [actions] 排成胶囊里的一行动作键；横向装不下时**按比例收窄**。
  ///
  /// # 为什么需要收窄
  ///
  /// 动作行是一颗横向胶囊（[GlassButtonGroup]），宽度只能抱内容：320dp 屏上留给
  /// 它的只有 192dp（屏宽 320 − [insetPadding] 左右各 40 − 面板内边距 24/20 −
  /// 胶囊内壁 2×2），而德语 `Abbrechen + Bestätigen` 自然宽度要 210dp、俄语三个
  /// 动作要 307dp。收口前这里就是 `Row` 直接溢出（RenderFlex overflow，被胶囊的
  /// `Clip.hardEdge` 裁掉），真机上表现为最后一枚键缺一截。
  ///
  /// # 三档：装得下就一像素都不动
  ///
  ///   1. 原样（内边距 16 + 原字号）装得下 —— 与收窄前**逐像素相同**；
  ///   2. 只压内边距（16 → 14 → 12 → 10 → 8）就装得下 —— 字号不动，键排紧一点；
  ///   3. 连最小内边距都装不下 —— 内边距压到
  ///      [GlassTextActionButton.minHorizontalPadding]，余下的宽度按**文字宽度
  ///      等比**分给各键，文字走 `FittedBox(scaleDown)` 等比缩小。
  ///
  /// 三档都不换行、不省略号、不横向滚动：动作键始终是同一坨玻璃里的一行（长按
  /// 蠕动的 `touchFlex` 也就还在）。
  ///
  /// 判据是 [GlassTextActionButton.measureLabelWidth]——它与真实段落逐位相同，
  /// 所以第 1 档的边界恰好落在「现在会不会溢出」那条线上：装得下的组合不会因为
  /// 一个估出来的余量被误判进第 2 档（那档内边距就从 16 变成了 12，视觉变了）。
  ///
  /// [available] 是面板内容宽度（`Column(crossAxisAlignment: stretch)` 递下来的
  /// 紧约束）。
  List<Widget> _fitActionButtons(BuildContext context, double available) {
    final int count = actions.length;
    // 胶囊内壁的留白不归动作键，见 [GlassButtonGroup.surfacePadding]。
    final double budget =
        available - GlassButtonGroup.surfacePadding.horizontal;
    final List<double> textWidths = [
      for (final action in actions)
        GlassTextActionButton.measureLabelWidth(
          context,
          action.label,
          emphasized: action.emphasized,
        ),
    ];
    final double textSum = textWidths.fold(0.0, (sum, w) => sum + w);

    double padding = GlassTextActionButton.defaultHorizontalPadding;
    double scale = 1;
    bool fits(double pad) => textSum + 2 * pad * count <= budget;
    if (!fits(padding)) {
      double? relaxed;
      for (final double candidate in const <double>[
        14,
        12,
        10,
        GlassTextActionButton.minHorizontalPadding,
      ]) {
        if (fits(candidate)) {
          relaxed = candidate;
          break;
        }
      }
      if (relaxed == null) {
        // 连下限都装不下：内边距就压在下限（极端到连它都放不下就清零，免得宽度
        // 预算算成负数），余下的按文字宽度等比分配，文字等比缩小。
        if (budget - 2 * padding * count < 0) padding = 0;
        final double room = budget - 2 * padding * count;
        scale = textSum > 0 ? (room / textSum).clamp(0.0, 1.0) : 1;
      } else {
        padding = relaxed;
      }
    }

    return [
      for (int i = 0; i < count; i++)
        ConstrainedBox(
          // 这枚键分到的宽度上限。第 1、2 档下它**不生效**（恰好等于自然宽度：
          // 量出来的文字宽 + 内边距本身，谁也压不着谁），第 3 档下它就是收窄后
          // 的宽度。这样「装得下」那条路上连一个像素都不会被这层碰到。
          constraints: BoxConstraints(
            maxWidth: textWidths[i] * scale + 2 * padding,
          ),
          child: GlassTextActionButton(
            label: actions[i].label,
            onPressed: actions[i].onPressed,
            emphasized: actions[i].emphasized,
            destructive: actions[i].destructive,
            loading: actions[i].loading,
            horizontalPadding: padding,
            scaleDownLabel: scale < 1,
          ),
        ),
    ];
  }
}

/// 打开 [GlassAlertDialog]。语义与 `showDialog` 一致，出入场走
/// `showAppDialog`（[GlassDialogRoute]）。
Future<T?> showGlassAlertDialog<T>({
  required String title,
  Widget? content,
  List<GlassDialogAction> actions = const [],
  bool showCloseButton = true,
  bool scrollable = false,
  bool barrierDismissible = true,
  GlassDialogMotion motion = GlassDialogMotion.auto,
}) {
  return showAppDialog<T>(
    GlassAlertDialog(
      title: title,
      content: content,
      actions: actions,
      showCloseButton: showCloseButton,
      scrollable: scrollable,
    ),
    barrierDismissible: barrierDismissible,
    motion: motion,
  );
}

/// [GlassAlertDialog.floatingActions] 的正文区：正文铺满，动作行浮在右下，
/// 底部垫渐隐蒙层；动作行高度实测后让给正文。
class _FloatingActionsBody extends StatefulWidget {
  const _FloatingActionsBody({
    required this.scrollable,
    required this.actionRow,
    required this.body,
  });

  final bool scrollable;
  final Widget actionRow;
  final Widget? body;

  @override
  State<_FloatingActionsBody> createState() => _FloatingActionsBodyState();
}

class _FloatingActionsBodyState extends State<_FloatingActionsBody> {
  /// 首帧用胶囊的标称高度，布局后换成实测值。
  double _actionHeight = GlassTokens.pillHeight;

  /// 正文末尾与动作行之间的呼吸位（与非浮动档的 20 同值）。
  static const double _gap = 20;

  @override
  Widget build(BuildContext context) {
    final inset = _actionHeight + _gap;
    Widget? body = widget.body;
    if (body != null) {
      body = widget.scrollable
          ? SingleChildScrollView(
              padding: EdgeInsets.only(bottom: inset),
              child: body,
            )
          : MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.paddingOf(context).copyWith(bottom: inset),
              ),
              child: body,
            );
    }
    final plateau = _actionHeight * 0.45;
    return Stack(
      children: [
        if (body != null) body else SizedBox(height: inset),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: EdgeFadeScrim.bottom(
              height: EdgeFadeScrim.overlayHeight(
                headerExtent: _actionHeight,
                plateauExtent: plateau,
              ),
              solidExtent: plateau,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GlassMeasuredBox(
            onSize: (size) {
              if (!mounted || (size.height - _actionHeight).abs() < 0.5) return;
              setState(() => _actionHeight = size.height);
            },
            child: widget.actionRow,
          ),
        ),
      ],
    );
  }
}
