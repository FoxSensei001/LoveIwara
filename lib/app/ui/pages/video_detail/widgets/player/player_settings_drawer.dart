import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/player_settings_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_gesture_guide.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 播放器设置抽屉。
///
/// # 从底部弹窗改成整页右侧抽屉（2026-08-30）
///
/// 老版本是播放器顶栏「⋮」拉起的一张 80% 高的底部弹窗。它有三个躲不掉的毛病：
///
///   1. **横屏（全屏播放）时几乎没有可用高度**——弹窗从下往上长，而全屏正是最
///      需要调「画面尺寸 / 画质增强 / 硬解」的时候；
///   2. 它是**播放器内部**的一张浮层，宽度跟着播放器走，窄屏上设置项被挤成两行；
///   3. 拖拽高度这件事跟内容滚动抢手势。
///
/// 现在走全站唯一那条侧边抽屉路由 [showGlassSideDrawer]：它挂在 **root
/// Navigator** 上，所以是**相对整个页面**贴右滑出（不是只盖住播放器那一块），
/// 宽屏 380 / 窄屏 88%，全屏与非全屏都能开——与「接着看」抽屉同一套观感与手势
/// （圆角、投影、Esc、按住横拖甩出）。
///
/// # 布局：一条常驻的分区导航 + 一列可滚动的分区
///
/// 播放器设置有 8 个分区、几十条，竖着摞在一条 380 宽的抽屉里就是一管长得看不
/// 到头的滚动条。所以 header 底下常驻一条**分区导航**（[_SectionNavBar]）：
///
///   - 点一下跳到那一区（落点让开 header，不会被玻璃标题压住）；
///   - 手指滚动时高亮**跟着当前分区走**，导航条自己把它滚进视野——
///     用户任何时候都知道「我在第几区、还有哪些区」。
///
/// ⛔ 没有把分区做成折叠面板：设置是拿来**扫**的，折起来等于每次都要多点一下
/// 才知道里面有什么。导航条只加了一条捷径，没有藏任何东西。
Future<void> showPlayerSettingsDrawer({
  required BuildContext context,
  required MyVideoStateController controller,
}) {
  return showGlassSideDrawer<void>(
    context: context,
    builder: (_) => _PlayerSettingsDrawer(controller: controller),
  );
}

class _PlayerSettingsDrawer extends StatefulWidget {
  const _PlayerSettingsDrawer({required this.controller});

  final MyVideoStateController controller;

  @override
  State<_PlayerSettingsDrawer> createState() => _PlayerSettingsDrawerState();
}

class _PlayerSettingsDrawerState extends State<_PlayerSettingsDrawer> {
  final ScrollController _scroll = ScrollController();

  /// 每个分区在内容列里的定位锚。**必须跨 build 稳定**，所以按 id 存着复用。
  final Map<String, GlobalKey> _anchors = <String, GlobalKey>{};

  /// 当前落在哪一区。null = 还没量出来（首帧）。
  ///
  /// ⛔ 用 [ValueNotifier] 而不是 setState：滚过一条分界线就 setState 的话，
  /// 整列设置（八个分区、几十条 Obx）会跟着重建一次——滚动中途白掉一帧。
  /// 需要重建的只有导航条那一排胶囊。
  final ValueNotifier<String?> _activeId = ValueNotifier<String?>(null);

  /// 正在因为「点了导航」而滚动：这期间不让滚动反过来改高亮，否则一路飞过去
  /// 会把中间每一区都点亮一遍。
  bool _jumping = false;

  /// 内容顶部让给 header 的那一段（由外壳实测下发）。跳转落点要减掉它，
  /// 否则分区标题正好停在玻璃 header 底下。
  double _contentTop = 0;

  @override
  void dispose() {
    _scroll.dispose();
    _activeId.dispose();
    super.dispose();
  }

  GlobalKey _anchorFor(String id) => _anchors.putIfAbsent(
    id,
    () => GlobalKey(debugLabel: 'playerSetting:$id'),
  );

  /// 分区顶边要滚到哪个 offset 才刚好落在 header 下缘。
  double? _offsetOf(String id) {
    final ctx = _anchors[id]?.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return null;
    return viewport.getOffsetToReveal(box, 0).offset - _contentTop;
  }

  Future<void> _jumpTo(String id) async {
    final target = _offsetOf(id);
    if (target == null || !_scroll.hasClients) return;
    _activeId.value = id;
    _jumping = true;
    await _scroll.animateTo(
      target.clamp(
        _scroll.position.minScrollExtent,
        _scroll.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 320),
      curve: GlassTokens.motionCurve,
    );
    if (!mounted) return;
    _jumping = false;
    _syncActive();
  }

  /// 按当前滚动位置算「现在在哪一区」：最后一个顶边已经越过 header 下缘的分区。
  void _syncActive() {
    if (_jumping || !_scroll.hasClients) return;
    // 插入序就是分区序（[_anchorFor] 按内容列的顺序建）。
    final ids = _anchors.keys.toList();
    if (ids.isEmpty) return;

    final double offset = _scroll.offset;
    String next = ids.first;
    if (offset >= _scroll.position.maxScrollExtent - 8) {
      // ⛔ 滚到底了就认最后一区：末尾那几区往往矮到**永远**顶不到 header 下缘，
      // 只按「越过没有」判的话它们的导航项一次都点不亮。
      next = ids.last;
    } else {
      for (final id in ids) {
        final sectionOffset = _offsetOf(id);
        if (sectionOffset == null) continue;
        if (sectionOffset > offset + 4) break;
        next = id;
      }
    }
    _activeId.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final sections = PlayerSettingsWidget(
      // 播放器里不整页跳走：快捷键配置改用弹层，画面尺寸这类会话级选项也只有
      // 拿到当前控制器才显示。
      openKeybindingAsSheet: true,
      playerController: widget.controller,
    ).buildSections(context);

    return GlassSideDrawerShell(
      title: t.settings.playerSettings,
      subtitle: t.searchFilter.drawerSubtitle,
      // 设置一屏七八行文字，从半透明 header 背后滚过去就是字压字（尤其是常驻
      // 的分区导航那一条）。见 GlassSideDrawerShell.opaqueHeader。
      opaqueHeader: true,
      headerActions: [
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.help_outline),
          tooltip: t.videoDetail.gestureGuide.viewGuide,
          onPressed: () => VideoGestureGuideDialog.show(context),
        ),
      ],
      headerBottom: ValueListenableBuilder<String?>(
        valueListenable: _activeId,
        builder: (context, activeId, _) => _SectionNavBar(
          sections: sections,
          // 还没滚动过（首帧）时高亮第一区：导航条上一枚都不亮会读成「坏了」。
          activeId: activeId ?? (sections.isEmpty ? null : sections.first.id),
          onSelected: _jumpTo,
        ),
      ),
      bodyBuilder: (context, contentPadding) {
        // 外壳实测 header 后会重新下发，这里跟着更新即可（只被手势读，不需要
        // setState）。
        _contentTop = contentPadding.top;
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth == 0 &&
                (notification is ScrollUpdateNotification ||
                    notification is ScrollEndNotification)) {
              _syncActive();
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scroll,
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final section in sections) _buildSection(context, section),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, PlayerSettingsSection section) {
    final theme = Theme.of(context);
    return Padding(
      key: _anchorFor(section.id),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                // 图标与导航条上那一枚是同一个：滚到一半时「我在哪一区」不用读字。
                Icon(section.icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          section.content,
        ],
      ),
    );
  }
}

/// 抽屉 header 底下那条常驻的分区导航。
///
/// 8 个分区在一条 380 宽的抽屉里排不下，所以是**横向可滚的一排胶囊**——
/// 高亮跟着内容滚动走，并且自己把当前那枚滚进视野。
///
/// ⛔ 不用分段胶囊（`GlassAdaptiveSegmentedControl`）：那是给「少数几个平级
/// 视图」用的，摆不下会退化成一只下拉钮——而这里恰恰是**分区目录**，把 8 个
/// 目录项收进下拉，等于又把"还有哪些区"藏了回去。这排胶囊也不是 tab：点它不
/// 切视图，只是把同一列内容滚到那一段。
class _SectionNavBar extends StatefulWidget {
  const _SectionNavBar({
    required this.sections,
    required this.activeId,
    required this.onSelected,
  });

  final List<PlayerSettingsSection> sections;
  final String? activeId;
  final ValueChanged<String> onSelected;

  @override
  State<_SectionNavBar> createState() => _SectionNavBarState();
}

class _SectionNavBarState extends State<_SectionNavBar> {
  static const double _kPillHeight = 32;

  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _pills = <String, GlobalKey>{};

  @override
  void didUpdateWidget(covariant _SectionNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeId != widget.activeId) {
      // 当前那一枚要一直看得见：内容滚到第 6 区、导航条却还停在第 1 枚上，
      // 高亮就等于没有。
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealActive());
    }
  }

  void _revealActive() {
    final ctx = _pills[widget.activeId]?.currentContext;
    if (ctx == null || !mounted) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 240),
      curve: GlassTokens.motionCurve,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kPillHeight,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: widget.sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, index) => _pill(context, widget.sections[index]),
      ),
    );
  }

  Widget _pill(BuildContext context, PlayerSettingsSection section) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool selected = section.id == widget.activeId;
    return GlassPressable(
      key: _pills.putIfAbsent(section.id, GlobalKey.new),
      onTap: () => widget.onSelected(section.id),
      builder: (context, pressed) {
        // 底色、图标色、文字色是同一段过渡（见玻璃形变词汇表第七原语）：
        // 分三个 Animated* 各走各的，切换时会看出先后。
        return GlassAnimatedColors(
          colors: [
            selected
                ? colorScheme.primary.withValues(alpha: 0.16)
                : (pressed
                      ? colorScheme.onSurface.withValues(alpha: 0.06)
                      : colorScheme.onSurface.withValues(alpha: 0.0)),
            selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ],
          builder: (context, colors) => Container(
            height: _kPillHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: colors[0],
              borderRadius: BorderRadius.circular(_kPillHeight / 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(section.icon, size: 15, color: colors[1]),
                const SizedBox(width: 5),
                Text(
                  section.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors[1],
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
