import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/settings/settings_navigation.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';

/// 全应用快捷键自定义。
///
/// 提供两种入口：
/// - [open]：设置页中作为独立页面（带 AppBar）推入导航栈，展示全部作用域；
/// - [openSheet]：播放器内以底部抽屉弹出，默认仅展示视频作用域。
///
/// 两者共用 [KeybindingSettingsView] 渲染主体；通过 `scopeFilter` 控制展示范围。
class KeybindingSettingsPage extends StatelessWidget {
  const KeybindingSettingsPage({this.isWideScreen = false, super.key});

  final bool isWideScreen;

  /// 设置页：独立页面跳转（全部作用域）。
  ///
  /// 走真路由而不是裸 `Navigator.push`：后者虽然「碰巧」能推进设置自己的
  /// Navigator，但拿不到设置树的转场（窄屏侧滑 / 宽屏右栏横推），左栏高亮
  /// 也不会跟着走——因为 URL 根本没变。
  static Future<void> open(BuildContext context) {
    return SettingsNavigation.openSubPage(SettingsSection.keybinding.path);
  }

  /// 播放器：底部抽屉弹出（默认仅视频作用域）。
  static Future<void> openSheet(
    BuildContext context, {
    ShortcutScope? scopeFilter = ShortcutScope.video,
  }) {
    return showAppBottomSheet(
      _KeybindingSheet(scopeFilter: scopeFilter),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassSettingsScaffold(
      title: slang.t.settings.keybinding.title,
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 8),
          sliver: SliverToBoxAdapter(
            // 内嵌进外层 CustomScrollView：必须 shrinkWrap 且禁用内层滚动，
            // 否则非 shrinkWrap 的 ListView 会获得无界高度，hit-test 时
            // 内层 viewport 几何为 null 触发崩溃（viewport.dart 的 `!`）。
            child: KeybindingSettingsView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      ],
    );
  }
}

/// 底部抽屉外壳：圆角顶部 + 拖拽指示条 + 标题栏 + 主体。
class _KeybindingSheet extends StatelessWidget {
  final ShortcutScope? scopeFilter;

  const _KeybindingSheet({this.scopeFilter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.t.settings.keybinding;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
            child: Row(
              children: [
                Icon(Icons.keyboard, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: slang.t.common.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: KeybindingSettingsView(
              shrinkWrap: true,
              scopeFilter: scopeFilter,
            ),
          ),
        ],
      ),
    );
  }
}

/// 快捷键设置主体内容（页面与抽屉共用）。
///
/// [scopeFilter] 为 null 时展示全部作用域；指定时仅展示该作用域（如播放器内只看视频）。
class KeybindingSettingsView extends StatefulWidget {
  /// 抽屉内需要 shrinkWrap 以便随内容收缩并在 [Flexible] 中滚动。
  final bool shrinkWrap;

  /// 内层 ListView 的滚动行为；内嵌进外层 CustomScrollView 时传
  /// [NeverScrollableScrollPhysics] 让外层驱动滚动。null 使用默认。
  final ScrollPhysics? physics;

  /// 限定展示的作用域；null 表示全部。
  final ShortcutScope? scopeFilter;

  const KeybindingSettingsView({
    super.key,
    this.shrinkWrap = false,
    this.physics,
    this.scopeFilter,
  });

  @override
  State<KeybindingSettingsView> createState() => _KeybindingSettingsViewState();
}

class _KeybindingSettingsViewState extends State<KeybindingSettingsView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  KeybindingService get _service => Get.find<KeybindingService>();

  slang.TranslationsSettingsKeybindingEn get _t => slang.t.settings.keybinding;

  /// 当前展示的作用域列表（保持 global→gallery→video 顺序）。
  List<ShortcutScope> get _scopes {
    if (widget.scopeFilter != null) return [widget.scopeFilter!];
    return const [
      ShortcutScope.global,
      ShortcutScope.gallery,
      ShortcutScope.video,
    ];
  }

  bool get _isSingleScope => widget.scopeFilter != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ListView(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + computeBottomSafeInset(mq)),
      children: [
        _buildInfoCard(context),
        const SizedBox(height: 12),
        _buildSearchField(context),
        const SizedBox(height: 16),
        for (final scope in _scopes) ..._buildScope(context, scope),
        if (!_isSingleScope) _buildResetAllButton(context),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      // 本页其它 Card 都写了 margin: zero，唯独这张没写，于是吃到了 Material
      // 给 Card 的默认外边距 4dp，整张卡比同页所有内容往右缩了 4dp（真机量得
      // 卡片左缘 x=978，而搜索框 967、下方动作行 963）。对齐问题出在外边距，
      // 不是内边距。
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        // 横向 16 与全站设置页保持一致（glass_setting_tiles / settings_app_bar
        // 都是 16，本页的动作行也是 16）。原来的 all(14) 让这张卡比同页下方
        // 所有内容都往里缩了 2px，跨页看更明显。
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.keyboard, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _t.desktopHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return GlassInputSurface(
      borderRadius: 12,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        decoration: glassFieldDecoration(context, hint: _t.searchHint).copyWith(
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  /// 动作是否匹配当前搜索（按本地化标签 + 已绑定组合的展示文本）。
  bool _matchesQuery(ShortcutAction action) {
    if (_query.isEmpty) return true;
    if (_actionLabel(action).toLowerCase().contains(_query)) return true;
    for (final chord in _service.chordsOf(action)) {
      if (chord.displayLabel.toLowerCase().contains(_query)) return true;
    }
    return false;
  }

  List<Widget> _buildScope(BuildContext context, ShortcutScope scope) {
    final actions = ShortcutActionMetaExt.inScope(
      scope,
    ).where(_matchesQuery).toList();
    // 画面缩放为固定手势展示：移动端有双指捏合/触控板缩放，桌面端额外有
    // Ctrl/Shift + 滚轮，因此全平台都展示（不再限定桌面）。
    // 有没有固定手势可展示，由能力表说了算，不再按作用域硬编码——
    // 图库过去被连带展示了它根本没有的「旋转画面」。
    final showFixed = _query.isEmpty && scopeHasFixedGestures(scope);
    if (actions.isEmpty && !showFixed) return const [];

    final widgets = <Widget>[];
    // 多作用域视图才显示作用域大标题；单作用域（播放器内）保持原有简洁外观。
    if (!_isSingleScope) {
      widgets.add(_scopeHeader(context, _scopeLabel(scope)));
    }

    // 按分类（枚举顺序）分组。
    for (final category in ShortcutActionCategory.values) {
      final inCategory = actions.where((a) => a.category == category).toList();
      if (inCategory.isEmpty) continue;
      widgets.add(_sectionLabel(context, _categoryLabel(category)));
      widgets.add(_actionsCard(context, inCategory));
      // 进度分类下补充长按倍速说明。
      if (category == ShortcutActionCategory.seek) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              _t.seekLongPressHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      widgets.add(const SizedBox(height: 16));
    }

    if (showFixed) widgets.addAll(_buildFixedZoomSection(context, scope));

    // 每作用域的重置按钮（非全默认时显示）。
    // 包进 Obx：增删快捷键后按钮可即时出现/消失（isScopeDefault 读取响应式 bindings）。
    widgets.add(
      Obx(() {
        if (_service.isScopeDefault(scope)) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(_t.resetScope),
            onPressed: () => _service.resetScope(scope),
          ),
        );
      }),
    );
    widgets.add(const SizedBox(height: 12));
    return widgets;
  }

  Widget _actionsCard(BuildContext context, List<ShortcutAction> actions) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            _buildActionRow(context, actions[i]),
            if (i != actions.length - 1)
              const Divider(
                height: 1,
                thickness: 0.5,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, ShortcutAction action) {
    final theme = Theme.of(context);
    return Obx(() {
      final chords = _service.chordsOf(action);
      final isDefault = _service.isDefault(action);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(action.icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_actionLabel(action), style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  if (chords.isEmpty)
                    Text(
                      _t.notSet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chord in chords)
                          _chordChip(context, action, chord),
                      ],
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: _t.addShortcut,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _addChord(context, action),
            ),
            if (!isDefault)
              IconButton(
                tooltip: _t.resetToDefault,
                icon: const Icon(Icons.restart_alt),
                onPressed: () => _service.resetAction(action),
              ),
          ],
        ),
      );
    });
  }

  Widget _chordChip(
    BuildContext context,
    ShortcutAction action,
    KeyChord chord,
  ) {
    final theme = Theme.of(context);
    return InputChip(
      label: Text(chord.displayLabel),
      labelStyle: theme.textTheme.bodyMedium,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _service.removeBinding(action, chord),
      deleteButtonTooltipMessage: _t.removeShortcut,
      backgroundColor: theme.colorScheme.secondaryContainer,
    );
  }

  // ---------------------------------------------------------------------------
  // 画面缩放（固定快捷键，仅展示，桌面端）
  // ---------------------------------------------------------------------------

  List<Widget> _buildFixedZoomSection(BuildContext context, ShortcutScope scope) {
    final theme = Theme.of(context);
    // 滚轮提示按**能力表**给，不按平台、也不做鼠标接入探测。
    //
    // Ctrl/Shift + 滚轮在代码里没有任何平台门控，安卓平板接上鼠标就能用（真机
    // 日志实证：滚轮事件到达、修饰键读到、缩放/旋转分支确实执行），而原来按
    // GetPlatform.isDesktop 硬判，移动端接了鼠标也看不到提示——功能在、提示没有。
    //
    // 也试过用 MouseTracker.mouseIsConnected 做运行时探测，真机验证不可靠：
    // 它要等鼠标 hover/added 事件才翻真，鼠标插着但没动过时提示照样消失，
    // 等于把「有时有有时没有」换个形式。宁可多显示一行也不要时隐时现。
    final channels = inputChannelsOf(scope);

    // 每一行、每一枚 chip 都由能力表推导：作用域没有的通道不展示。
    // 图库没有任何旋转能力，此前却和视频共用同一份写死的两行文案。
    final rows = <Widget>[];
    if (scopeSupportsFixedZoom(scope)) {
      rows.add(
        _fixedHintRow(context, Icons.zoom_in, _t.zoomScaleLabel, [
          if (channels.contains(ShortcutInputChannel.pinchZoom))
            _t.zoomPinchGesture,
          if (channels.contains(ShortcutInputChannel.wheelZoom))
            _t.zoomScaleHint,
        ]),
      );
    }
    if (scopeSupportsFixedRotate(scope)) {
      if (rows.isNotEmpty) {
        rows.add(
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
        );
      }
      rows.add(
        _fixedHintRow(context, Icons.rotate_right, _t.zoomRotateLabel, [
          if (channels.contains(ShortcutInputChannel.twoFingerRotate))
            _t.zoomTwoFingerRotateGesture,
          if (channels.contains(ShortcutInputChannel.wheelRotate))
            _t.zoomRotateHint,
        ]),
      );
    }

    return [
      _sectionLabel(context, _t.zoomSectionTitle),
      Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: rows),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Text(
          _t.zoomFixedNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  /// 固定手势展示行：左侧图标 + 动作名，右侧一个或多个「固定手势」chip。
  /// 用 Wrap 承载多个 chip，窄屏时自动换行，避免溢出。
  Widget _fixedHintRow(
    BuildContext context,
    IconData icon,
    String label,
    List<String> hints,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          const SizedBox(width: 8),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final hint in hints)
                  Chip(
                    label: Text(hint),
                    labelStyle: theme.textTheme.bodyMedium,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetAllButton(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.restart_alt),
        label: Text(_t.resetAll),
        onPressed: () => _confirmResetAll(context),
      ),
    );
  }

  Widget _scopeHeader(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 交互
  // ---------------------------------------------------------------------------

  Future<void> _addChord(BuildContext context, ShortcutAction action) async {
    final chord = await showDialog<KeyChord>(
      context: context,
      builder: (_) =>
          _KeybindingCaptureDialog(service: _service, scope: action.scope),
    );
    if (chord == null) return;
    if (!context.mounted) return;

    // 同作用域硬冲突：提示是否解除原绑定。
    final conflicts = _service.conflictsFor(
      chord,
      scope: action.scope,
      except: action,
    );
    if (conflicts.isNotEmpty) {
      final conflictName = _actionLabel(conflicts.first);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => GlassAlertDialog(
          title: _t.conflictTitle,
          content: Text(_t.conflictMessage(action: conflictName)),
          actions: [
            GlassDialogAction(
              label: slang.t.common.cancel,
              emphasized: false,
              onPressed: () => Navigator.pop(ctx, false),
            ),
            GlassDialogAction(
              label: _t.conflictContinue,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );
      if (ok != true) return;
      if (!context.mounted) return;
    } else {
      // 软提示：跨作用域遮蔽（可继续）。两个方向各检测一侧：
      // - 在叶子作用域绑定，会遮蔽常驻全局绑定；
      // - 在全局作用域绑定，会被叶子作用域已有的同组合绑定遮蔽。
      final String? shadowMessage;
      if (action.scope == ShortcutScope.global) {
        final shadowers = _service.shadowedByLeaf(chord);
        shadowMessage = shadowers.isEmpty
            ? null
            : _t.globalShadowedMessage(
                scope: _scopeLabel(shadowers.first.scope),
                action: _actionLabel(shadowers.first),
              );
      } else {
        final shadowed = _service.shadowsGlobal(chord, scope: action.scope);
        shadowMessage = shadowed == null
            ? null
            : _t.shadowWarningMessage(action: _actionLabel(shadowed));
      }
      if (shadowMessage != null) {
        final message = shadowMessage;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => GlassAlertDialog(
            title: _t.shadowWarningTitle,
            content: Text(message),
            actions: [
              GlassDialogAction(
                label: slang.t.common.cancel,
                emphasized: false,
                onPressed: () => Navigator.pop(ctx, false),
              ),
              GlassDialogAction(
                label: _t.conflictContinue,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );
        if (ok != true) return;
      }
    }
    await _service.addBinding(action, chord);
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: _t.resetAll,
        content: Text(_t.resetAllConfirm),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          GlassDialogAction(
            label: _t.resetAll,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.resetAll();
      showGlassToast(_t.resetAll, type: GlassToastType.success);
    }
  }

  String _scopeLabel(ShortcutScope scope) {
    switch (scope) {
      case ShortcutScope.global:
        return _t.scopeGlobal;
      case ShortcutScope.gallery:
        return _t.scopeGallery;
      case ShortcutScope.video:
        return _t.scopeVideo;
    }
  }

  String _categoryLabel(ShortcutActionCategory category) {
    switch (category) {
      case ShortcutActionCategory.navigation:
        return _t.categoryNavigation;
      case ShortcutActionCategory.zoom:
        return _t.categoryZoom;
      case ShortcutActionCategory.playback:
        return _t.categoryPlayback;
      case ShortcutActionCategory.seek:
        return _t.categorySeek;
      case ShortcutActionCategory.volume:
        return _t.categoryVolume;
      case ShortcutActionCategory.display:
        return _t.categoryDisplay;
    }
  }

  String _actionLabel(ShortcutAction action) {
    switch (action) {
      case ShortcutAction.globalBack:
        return _t.actionGlobalBack;
      case ShortcutAction.galleryNext:
        return _t.actionGalleryNext;
      case ShortcutAction.galleryPrevious:
        return _t.actionGalleryPrevious;
      case ShortcutAction.galleryZoomIn:
        return _t.actionGalleryZoomIn;
      case ShortcutAction.galleryZoomOut:
        return _t.actionGalleryZoomOut;
      case ShortcutAction.galleryResetZoom:
        return _t.actionGalleryResetZoom;
      case ShortcutAction.playPause:
        return _t.actionPlayPause;
      case ShortcutAction.speedUp:
        return _t.actionSpeedUp;
      case ShortcutAction.speedDown:
        return _t.actionSpeedDown;
      case ShortcutAction.seekForward:
        return _t.actionSeekForward;
      case ShortcutAction.seekBackward:
        return _t.actionSeekBackward;
      case ShortcutAction.volumeUp:
        return _t.actionVolumeUp;
      case ShortcutAction.volumeDown:
        return _t.actionVolumeDown;
      case ShortcutAction.toggleMute:
        return _t.actionToggleMute;
      case ShortcutAction.toggleFullscreen:
        return _t.actionToggleFullscreen;
    }
  }
}

/// 录制快捷键的对话框：捕获首个「非修饰键」按下或鼠标侧键，结合当前修饰键生成组合。
///
/// 鼠标按键通过全局指针路由捕获，因此光标在屏幕任意位置点击侧键都能识别（不必悬浮在弹窗内）。
class _KeybindingCaptureDialog extends StatefulWidget {
  final KeybindingService service;
  final ShortcutScope scope;

  const _KeybindingCaptureDialog({required this.service, required this.scope});

  @override
  State<_KeybindingCaptureDialog> createState() =>
      _KeybindingCaptureDialogState();
}

class _KeybindingCaptureDialogState extends State<_KeybindingCaptureDialog> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  String _preview = '';
  /// 上一次「检测到但没被接受」的输入，用于实时回显。
  String? _detected;

  slang.TranslationsSettingsKeybindingEn get _t => slang.t.settings.keybinding;

  @override
  void initState() {
    super.initState();
    // 全局指针路由：捕获屏幕任意位置的鼠标按下（含侧键），不受弹窗 hit-test 限制。
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointer);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handleGlobalPointer,
    );
    _focusNode.dispose();
    super.dispose();
  }

  /// 鼠标按下。
  ///
  /// **每一种拒收都必须当场说清楚理由**：这个弹窗以前对不被接受的输入一律
  /// 静默 `return`，屏幕上什么都不变，于是用户分不清「没检测到」和「检测到但
  /// 不让绑」，只能反复试，试出一套玄学（真机反馈：「得把鼠标悬浮到某个区域
  /// 才能记录，有没有效果也不知道」）。
  void _handleGlobalPointer(PointerEvent event) {
    if (event is! PointerDownEvent) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    if (!mounted) return;

    final int buttons = event.buttons;

    // 左键 / 右键：静默忽略，**不能**在这里报错。
    // 用鼠标操作这个弹窗时，点「取消」按钮用的就是左键——在那一刻闪一条红色
    // 「左键不可绑定」既刺眼又答非所问。它们不可绑定这件事由下方的能力行
    // 事先说明，不需要事后再骂用户一次。
    if (buttons == kPrimaryMouseButton || buttons == kSecondaryMouseButton) {
      return;
    }

    // 该作用域根本不受理鼠标事件——与「系统保留键」是完全不同的两件事。
    if (!scopeAcceptsMouseButtons(widget.scope)) {
      _reject(_t.mouseNotSupportedInScope, detected: KeyChord.describeMouseButton(buttons));
      return;
    }

    // 平台自己就把这个键当返回用（安卓的鼠标后退键）。
    if (!KeyChord.isBindableMouseButton(buttons)) {
      _reject(_t.rejectPlatformBack, detected: KeyChord.describeMouseButton(buttons));
      return;
    }

    final chord = KeyChord.fromPointerEvent(event);
    if (chord == null) {
      // 同时按住多个鼠标键：说清楚是这个原因，别套「左右键」那条答非所问。
      _reject(_t.rejectMultipleButtons, detected: KeyChord.describeMouseButton(buttons));
      return;
    }
    if (widget.service.isReserved(chord, widget.scope)) {
      _reject(_t.reservedKey, detected: chord.displayLabel);
      return;
    }
    Navigator.of(context).pop(chord);
  }

  /// 显示「检测到 X —— 但不能绑，因为 Y」，并保持弹窗开着让用户换一个。
  void _reject(String reason, {required String detected}) {
    setState(() {
      _detected = '${_t.detectedLabel}: $detected';
      _errorText = reason;
    });
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      // 松开修饰键时更新预览。
      setState(() => _preview = _modifierPreview());
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return;
    }
    final chord = KeyChord.fromEvent(event);
    if (chord == null) {
      // 仍是修饰键，刷新预览。
      setState(() => _preview = _modifierPreview());
      return;
    }
    // 诊断：真机上出现过「自定义键绑了却不触发，而默认的方向键正常」。
    // 键位系统本身是通的（方向键走的就是同一条路），所以嫌疑在键位身份：
    // 录入时的 logicalKey 与播放器里收到的可能不是同一个。两端打同样的字段，
    // 对着日志一比就能定性。
    LogUtils.d(
      '[录入] keyId=${chord.keyId} debugName=${event.logicalKey.debugName} '
      'label="${chord.displayLabel}" '
      'ctrl=${chord.control} shift=${chord.shift} alt=${chord.alt} meta=${chord.meta} '
      'scope=${widget.scope.name}',
      'Keybinding',
    );
    if (widget.service.isReserved(chord, widget.scope)) {
      // 「被系统占用作返回」和「应用保留键（Esc）」对用户是两回事，分开说。
      final bool platformBack =
          KeyChord.isPlatformHandledBackButton &&
          KeyChord.platformBackKeyIds.contains(chord.keyId);
      _reject(
        platformBack ? _t.rejectPlatformBack : _t.reservedKey,
        detected: chord.displayLabel,
      );
      return;
    }
    Navigator.of(context).pop(chord);
  }

  /// 本区域接受什么——直接由能力表推导，并且**提前**把平台差异说清楚。
  ///
  /// 移动端要单独说一句「后退键不可绑」：安卓把鼠标后退键当系统返回，用户按下
  /// 它时系统会直接把这个弹窗关掉，我们的拒收提示根本没机会显示——那看起来就是
  /// 「弹窗自己莫名其妙关了」。与其事后解释，不如按之前先讲。
  String get _capabilityLine {
    if (!scopeAcceptsMouseButtons(widget.scope)) {
      return _t.capabilityKeyboardOnly;
    }
    return KeyChord.isPlatformHandledBackButton
        ? _t.capabilityKeyboardAndMouseMobile
        : _t.capabilityKeyboardAndMouse;
  }

  String _modifierPreview() {
    final keyboard = HardwareKeyboard.instance;
    final parts = <String>[];
    if (keyboard.isControlPressed) parts.add('Ctrl');
    if (keyboard.isAltPressed) parts.add('Alt');
    if (keyboard.isShiftPressed) parts.add('Shift');
    if (keyboard.isMetaPressed) parts.add('Meta');
    return parts.isEmpty ? '' : '${parts.join(' + ')} + …';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassAlertDialog(
      title: _t.pressNewShortcut,
      // 用 Focus.onKeyEvent 并返回 handled，吞掉按键，避免 Esc 等被全局
      // Shortcuts/PopCoordinator 重复处理导致双重返回。鼠标键由全局指针路由处理。
      content: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_, event) {
          _onKey(event);
          return KeyEventResult.handled;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              // 回显区：优先显示「刚刚检测到什么」，其次是修饰键预览。
              // 以前这里只会显示修饰键，按下不被接受的键时整块纹丝不动，
              // 用户无从判断到底有没有被听见。
              child: Text(
                _detected ?? (_preview.isEmpty ? '…' : _preview),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _detected != null && _errorText != null
                      ? theme.colorScheme.error
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorText ?? _t.recordingCancelHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            // 本区域到底接受什么——直接取自能力表，不再让用户自己猜。
            Text(
              _capabilityLine,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

          ],
        ),
      ),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
