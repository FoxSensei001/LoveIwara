import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';

/// 订阅下拉选择项
class SubscriptionDropdownItem {
  final String id;
  final String label;
  final String avatarUrl;
  final VoidCallback? onLongPress;

  SubscriptionDropdownItem({
    required this.id,
    required this.label,
    required this.avatarUrl,
    this.onLongPress,
  });
}

/// 紧凑型订阅选择下拉组件 - 用于AppBar收缩状态
class CompactSubscriptionDropdown extends StatefulWidget {
  final List<SubscriptionDropdownItem> userList;
  final String selectedUserId;
  final Function(String) onUserSelected;
  final double height;

  /// 紧凑模式：胶囊里只放头像 + 箭头（不显示名字），用于窄屏 header 单行布局。
  final bool compact;

  /// 无壳模式：只渲染一个 [GlassTokens.groupIconButtonSize] 的触发位，玻璃壳
  /// 由外层 [GlassButtonGroup] 提供。
  ///
  /// 这个入口和 header 左侧的「我」头像圆钮长得太像（都是一张圆头像），所以
  /// 这里刻意换一套形状语言把两者拉开：
  ///   - 没选人时压根不显示头像，只是一枚 `person_search` 图标，和胶囊里
  ///     其他功能键完全同款；
  ///   - 选中某人后头像裁成**圆角方形**并套一圈主色描边。
  /// 即：圆形 = 身份（我），方形 + 主色描边 = 正在生效的筛选条件。
  final bool flat;

  /// 非紧凑模式下胶囊的最大宽度。
  final double maxWidth;

  const CompactSubscriptionDropdown({
    super.key,
    required this.userList,
    required this.selectedUserId,
    required this.onUserSelected,
    this.height = GlassTokens.pillHeight,
    this.compact = false,
    this.flat = false,
    this.maxWidth = 220,
  });

  @override
  State<CompactSubscriptionDropdown> createState() =>
      _CompactSubscriptionDropdownState();
}

class _CompactSubscriptionDropdownState
    extends State<CompactSubscriptionDropdown> {
  final SubscriptionDropdownItem _allItem = SubscriptionDropdownItem(
    id: '',
    label: slang.t.common.all,
    avatarUrl: '',
  );

  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey<_DropdownPanelState> _panelKey =
      GlobalKey<_DropdownPanelState>();
  bool _isDropdownOpen = false;

  /// 退场动画播放中：期间忽略再次开/关请求，防止 OverlayEntry 被重复挂摘。
  bool _isClosing = false;

  /// OverlayEntry 是否还挂在 Overlay 上（退场动画结束后才置回 false）。
  bool _overlayAttached = false;

  /// 开面板那一刻取样到的玻璃档位。面板挂在 Overlay 上、不在页面子树里，
  /// 读不到 `LiquidGlassScope`，只能在这边取了带过去。
  bool _liquid = false;

  @override
  void dispose() {
    if (_overlayAttached) {
      _overlayEntry.remove();
      _overlayAttached = false;
    }
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  // 关闭下拉菜单：先播退场动画，结束后再摘掉 OverlayEntry。
  void _closeDropdown() {
    if (!_overlayAttached || _isClosing) return;
    _isClosing = true;
    setState(() {
      _isDropdownOpen = false;
    });
    final panel = _panelKey.currentState;
    if (panel == null) {
      _removeOverlay();
      return;
    }
    panel.dismiss().whenComplete(_removeOverlay);
  }

  void _removeOverlay() {
    if (!_overlayAttached) return;
    _overlayAttached = false;
    _overlayEntry.remove();
    _isClosing = false;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  // 打开下拉菜单
  void _openDropdown() {
    if (_overlayAttached) return;
    _liquid = LiquidGlassScope.isEnabled(context);
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
    _overlayAttached = true;
    setState(() {
      _isDropdownOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // 计算下拉菜单最大高度 - 屏幕高度的1/3
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxHeight = screenHeight / 3;
    final double itemHeight = 48.0; // 每个选项的高度
    final double calculatedHeight = min(
      maxHeight,
      (widget.userList.length + 1) * itemHeight, // +1 为"全部"选项
    );

    // 紧凑 / 无壳模式下触发器本身很窄，下拉面板按固定宽度展开
    final double panelWidth = widget.flat
        ? min(260.0, screenWidth - 16)
        : min(
            widget.compact ? 260.0 : min(size.width * 1.5, 320.0),
            screenWidth - offset.dx - 8,
          );
    // 无壳模式挂在 header 右侧胶囊里，面板得跟触发位**右对齐**：
    // 沿用左对齐的话贴着屏幕右边只剩几十像素，面板会被压成一条。
    final double panelLeft = widget.flat
        ? (offset.dx + size.width - panelWidth).clamp(
            8.0,
            max(8.0, screenWidth - panelWidth - 8),
          )
        : offset.dx;
    // 无壳触发位比外层玻璃胶囊矮，面板再往下挪一点，别压住胶囊本身
    final double panelGap = widget.flat ? 8.0 : 0.0;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 全屏透明遮罩层，用于捕获点击事件关闭下拉菜单
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 下拉菜单内容
          Positioned(
            left: panelLeft,
            top: offset.dy + size.height + panelGap,
            width: panelWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(panelLeft - offset.dx, size.height + panelGap),
              // 入场自锚点向下放大淡入，退场反向收拢，避免面板瞬间出现/消失
              child: _DropdownPanel(
                key: _panelKey,
                // 面板挂在 Overlay 上，读不到触发件那边的 LiquidGlassScope；
                // 材质档位在开面板时就地取样（_openDropdown），这里重新供上，
                // 玻璃胶囊才不会吐出一块实心板。
                child: LiquidGlassScope(
                  enabled: _liquid,
                  child: GlassSurface(
                    // 高度按内容走（外层还有 maxHeight 卡着），所以必须显式给圆角
                    height: null,
                    borderRadius: BorderRadius.circular(20),
                    clipContent: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: calculatedHeight),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          _buildDropdownItem(_allItem),
                          ...widget.userList.map(
                            (item) => _buildDropdownItem(item),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(SubscriptionDropdownItem item) {
    return _DropdownRow(
      item: item,
      selected: widget.selectedUserId == item.id,
      onTap: () {
        if (widget.selectedUserId != item.id) {
          widget.onUserSelected(item.id);
        }
        _closeDropdown();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 查找当前选中的用户
    SubscriptionDropdownItem selectedItem;
    if (widget.selectedUserId.isEmpty) {
      selectedItem = _allItem;
    } else {
      selectedItem = widget.userList.firstWhere(
        (item) => item.id == widget.selectedUserId,
        orElse: () => _allItem,
      );
    }

    if (widget.flat) {
      return _buildFlatTrigger(context, selectedItem);
    }

    final Widget avatar = selectedItem.avatarUrl.isEmpty
        ? CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.cloud,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 14,
            ),
          )
        : CircleAvatar(
            radius: 14,
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: selectedItem.avatarUrl,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 14,
                  backgroundImage: const NetworkImage(
                    CommonConstants.defaultAvatarUrl,
                  ),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person, size: 14),
                ),
                httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                fit: BoxFit.cover,
              ),
            ),
          );

    final Widget caret = GlassAnimatedIcon(
      icon: Icon(
        _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    final Widget pill = GlassSurface(
      height: widget.height,
      tooltip: widget.compact ? selectedItem.label : null,
      padding: EdgeInsets.only(left: widget.compact ? 8 : 10, right: 4),
      onTap: _toggleDropdown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          if (!widget.compact) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selectedItem.label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
          ],
          caret,
        ],
      ),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.compact
          ? pill
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: pill,
            ),
    );
  }

  /// 无壳触发位：塞进 header 右侧玻璃胶囊的 40×40 按钮位。
  ///
  /// 形状语言见 [CompactSubscriptionDropdown.flat] 的注释——未选中是纯图标，
  /// 选中后是「圆角方形头像 + 主色描边」，和左侧圆形的「我」头像互不混淆。
  Widget _buildFlatTrigger(
    BuildContext context,
    SubscriptionDropdownItem selectedItem,
  ) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final bool hasSelection = selectedItem.avatarUrl.isNotEmpty;
    const double avatarBox = 28;
    const double outerRadius = 9;

    final Widget content = hasSelection
        ? Container(
            key: ValueKey('special_follow_${selectedItem.id}'),
            width: avatarBox,
            height: avatarBox,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              border: Border.all(color: cs.primary, width: 1.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(outerRadius - 1.6),
              child: CachedNetworkImage(
                imageUrl: selectedItem.avatarUrl,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: CommonConstants.defaultAvatarUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, size: 16, color: cs.onSurfaceVariant),
                ),
                httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                fit: BoxFit.cover,
              ),
            ),
          )
        : Icon(
            Icons.person_search,
            key: const ValueKey('special_follow_all'),
            size: GlassTokens.iconSize,
            color: cs.onSurface,
          );

    Widget trigger = GlassPressable(
      onTap: _toggleDropdown,
      scale: 0.9,
      builder: (context, pressed) => AnimatedContainer(
        duration: GlassTokens.pressDuration,
        width: GlassTokens.groupIconButtonSize,
        height: GlassTokens.groupIconButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pressed
              ? cs.onSurface.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        // 图标 ↔ 头像换形走同一套形变词汇表，别瞬间跳变
        child: Center(child: GlassShapeSwitcher(child: content)),
      ),
    );

    trigger = Tooltip(
      message: hasSelection
          ? '${t.common.specialFollow} · ${selectedItem.label}'
          : t.common.specialFollow,
      child: trigger,
    );

    return CompositedTransformTarget(link: _layerLink, child: trigger);
  }

  double min(double a, double b) {
    return a < b ? a : b;
  }

  double max(double a, double b) {
    return a > b ? a : b;
  }
}

/// 面板里的一行「特别关注」用户。
///
/// 反馈自绘、不用 `InkWell`：玻璃面板底下没有 Material（原先那层
/// `Material(elevation: 4)` 已经被玻璃壳换掉），而且水波画在最近的祖先 Material
/// 上、会穿透中间的 ClipRRect，在圆角面板的四角露出直角。取值与
/// `glass_menu.dart` 里的菜单行保持一致，两种面板的手感才是同一套。
class _DropdownRow extends StatefulWidget {
  const _DropdownRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionDropdownItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DropdownRow> createState() => _DropdownRowState();
}

class _DropdownRowState extends State<_DropdownRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;
    final bool isSelected = widget.selected;

    final Widget avatar = item.avatarUrl.isEmpty
        ? CircleAvatar(
            radius: 14,
            backgroundColor: isSelected
                ? cs.primary
                : cs.surfaceContainerHighest,
            child: Icon(
              Icons.cloud,
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              size: 14,
            ),
          )
        : CircleAvatar(
            radius: 14,
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: item.avatarUrl,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 14,
                  backgroundImage: const NetworkImage(
                    CommonConstants.defaultAvatarUrl,
                  ),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person, size: 14),
                ),
                httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                fit: BoxFit.cover,
              ),
            ),
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GlassPressable(
        onTap: widget.onTap,
        onLongPress: item.onLongPress,
        // 整行缩放会让面板看着在抖；行的反馈只用底色
        scale: 1.0,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: pressed
                ? cs.onSurface.withValues(alpha: 0.10)
                : _hovered
                ? cs.onSurface.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isSelected ? cs.primary : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(Icons.check, size: 18, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 下拉面板的进出场动画壳：入场自锚点（顶部中心）向下放大 + 淡入，
/// [dismiss] 反向播完后 future 完成，父级此时才摘掉 OverlayEntry。
/// 时值/曲线沿用玻璃形变词汇表（200ms easeOutCubic）。
class _DropdownPanel extends StatefulWidget {
  final Widget child;

  const _DropdownPanel({super.key, required this.child});

  @override
  State<_DropdownPanel> createState() => _DropdownPanelState();
}

class _DropdownPanelState extends State<_DropdownPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  /// 播退场动画；返回的 future 完成时面板已完全收拢。
  Future<void> dismiss() => _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: GlassTokens.motionCurve,
    );
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
        alignment: Alignment.topCenter,
        child: widget.child,
      ),
    );
  }
}
