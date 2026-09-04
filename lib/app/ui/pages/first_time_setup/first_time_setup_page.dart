import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

import 'controllers/setup_controller.dart';
import 'widgets/shared/layouts.dart';

/// header 底色里掺进去的主题色比例。整条标题栏的「有多少主体色」只看它。
const double _kHeaderTintAlpha = 0.12;

/// header 底色的不透明度：留一点让内容能从背后透出来（毛玻璃的前提）。
const double _kHeaderOpacity = 0.85;

/// header 底部那根发丝分隔线的主题色浓度。
const double _kHeaderHairlineAlpha = 0.28;

class FirstTimeSetupPage extends StatefulWidget {
  const FirstTimeSetupPage({super.key});

  @override
  State<FirstTimeSetupPage> createState() => _FirstTimeSetupPageState();
}

class _FirstTimeSetupPageState extends State<FirstTimeSetupPage> {
  late SetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SetupController());
    LogUtils.i('新的首次设置页面初始化完成', '首次设置页面');
  }

  void _nextStep() {
    if (_controller.canProceed()) {
      _controller.nextStep();
    }
  }

  void _previousStep() => _controller.previousStep();

  Future<void> _completeSetup() => _controller.completeSetup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // header 上的主题色：底色是「毛玻璃 + 一层主题色薄染」，发丝分隔线与
    // 步骤计数也走主题色 —— 和卡片的分组标题（labelMedium / primary）、
    // 提示条（primaryContainer）同源，整页只有一处强调色。
    // 浓淡只由这三个常数决定，要更重就调 _kHeaderTintAlpha。
    final headerTint = Color.alphaBlend(
      cs.primary.withValues(alpha: _kHeaderTintAlpha),
      cs.surface,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // 高度与 StepPageLayout 的顶部让位共用同一个常量，否则内容又会
        // 压在标题栏底下（见 layouts.dart 文件头）。
        toolbarHeight: kStepAppBarHeight,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // 向导是 go 替换整个路由栈进来的，不该出现返回箭头；显式关掉，
        // 免得某条深链让它冒出来把标题整体推右 40。
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: headerTint.withValues(alpha: _kHeaderOpacity),
                border: Border(
                  bottom: BorderSide(
                    color: cs.primary.withValues(alpha: _kHeaderHairlineAlpha),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Obx(() {
          final step = _controller.stepManager.currentStep;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_controller.currentStepIndex.value),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step?.title ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_controller.currentStepIndex.value + 1} / '
                  '${_controller.stepManager.totalSteps}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          // 翻页键走全站统一的玻璃胶囊：一只 GlassButtonGroup 里两枚
          // GlassIconButton。「上一步」在第一步没有，用 GlassGroupSlot 增删
          // （胶囊跟着一起收放），而不是塞个等宽占位符硬撑。
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GlassChromeLayer(
                // 这条 header 上只有这一块玻璃，不需要融合层。
                group: false,
                child: _HeaderCapsuleLift(
                  child: Obx(() {
                    final index = _controller.currentStepIndex.value;
                    final isFirst = index == 0;
                    final isLast =
                        index == _controller.stepManager.totalSteps - 1;
                    final canProceed = _controller.canProceed();
                    return GlassButtonGroup(
                      // easy 档要靠它知道「胶囊宽度会随这个状态变」。
                      touchFlexSignature: 'prev:$isFirst',
                      children: [
                        GlassGroupSlot(
                          visible: !isFirst,
                          child: GlassIconButton(
                            icon: const Icon(Icons.chevron_left),
                            tooltip: slang.t.firstTimeSetup.common.previousStep,
                            onPressed: _previousStep,
                          ),
                        ),
                        GlassIconButton(
                          // 主行动染主题色；不可继续时交给按钮自己的置灰色，
                          // 两者都走 GlassAnimatedColors 平滑推移。
                          color: canProceed ? theme.colorScheme.primary : null,
                          icon: Icon(isLast ? Icons.done : Icons.chevron_right),
                          tooltip: isLast
                              ? slang.t.firstTimeSetup.common.finishSetup
                              : slang.t.firstTimeSetup.common.nextStep,
                          onPressed: canProceed
                              ? (isLast ? _completeSetup : _nextStep)
                              : null,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          // ⛔ 默认的 layoutBuilder 是 `Stack(alignment: center)` + 松约束：
          // 交叉淡入期间新旧两页同时在树上，短的那页会**收缩到内容高度并被
          // 竖直居中**，读起来就是「刚翻过来顶部空一大截，动画结束又弹回去」
          // （2026-08-26 报障）。让两页都撑满 body，位置才从头到尾不动。
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.topLeft,
            children: [...previousChildren, ?currentChild],
          ),
          child: KeyedSubtree(
            key: ValueKey(_controller.currentStepIndex.value),
            child:
                _controller.stepManager.currentStep?.builder(context) ??
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// 给 header 上那只玻璃胶囊补一层外投影。
///
/// ⛔ 这是**有意的一处例外**，不是把 2026-08-26 删掉的 `GlassTokens.shadow`
/// 又捡回来。全站传统档的玻璃一律不吐外投影：它是「贴在内容上的一层半透明
/// 膜」，靠 fill + stroke 立起来，再补外投影会读成一张浮在上面的卡片（见
/// `glass_tokens.dart` 上那条零容忍规则与它的闸门）。
///
/// 这条 header 是唯一的例外，因为它自己染了主题色：胶囊的 fill 与底色几乎
/// 同一个明度，不给一点「浮起来」的暗示就分辨不出边界（2026-08-26 报障
/// 「不好分辨」）。作用范围只有这一枚胶囊，**不要**往 `widgets/glass/` 里搬。
///
/// 两个液态档各自已经有投影通道（easy 的 `liquidShadow`、widgets 的
/// `shadowElevation`），那里再叠一层就是双份，所以只在传统档生效。
class _HeaderCapsuleLift extends StatelessWidget {
  const _HeaderCapsuleLift({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ⛔ 只有传统档（液态档内部的仿玻璃便宜档）才补这一下抬升。Material 档
    // 一概不画投影——它的面是不透明 `surfaceContainerHigh`，与身下的
    // `surface` 本来就差着一档色阶，不需要影子来分辨（2026-09-04 用户拍板：
    // 「按钮和控件的阴影」是仿玻璃时期的非 Material 装饰）。
    final isPlain = LiquidGlassScope.of(context) == GlassBackend.plain;
    return PhysicalModel(
      // 透明遮挡体：drawShadow 只画形状外圈的影，不会把半透明胶囊的内部压暗。
      color: Colors.transparent,
      shadowColor: Theme.of(context).colorScheme.shadow,
      elevation: isPlain ? 3 : 0,
      borderRadius: BorderRadius.circular(GlassTokens.pillHeight / 2),
      child: child,
    );
  }
}
