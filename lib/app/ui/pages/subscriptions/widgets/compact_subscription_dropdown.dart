import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
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

/// 「特别关注」筛选入口：header 右侧动作胶囊里的一枚无壳触发位，点开一张
/// 玻璃菜单选人。
///
/// # 弹窗走 [showGlassMenu]，不再自建 Overlay
///
/// 2026-08-23 之前这里自己搭了一整套：`OverlayEntry` + `CompositedTransformFollower`
/// + 手写落点算术 + `_DropdownPanel` 出入场 + `_DropdownRow` 行反馈——和
/// `glass_menu.dart` 那套逐行做着同一件事，却各自演化：
///   - 出入场用的是 `FadeTransition`，**正是那条会把液态折射打断的写法**
///     （α∈(0,1) 时 `saveLayer` 把子树隔离，lens 采样不到背景，读起来是
///     「文字先出现、玻璃背景后到」，见 `liquid_glass_material.dart` 顶部）；
///   - 没有跟手形变，而同一行 header 上「更多」吐出来的菜单有；
///   - 没有滑动取焦，行高 / 圆角 / 底色也是另抄的一份。
///
/// 现在整只删掉，改用 [showGlassMenu]：出入场、材质取样、跟手形变、滑动取焦、
/// 落点与翻转、无障碍全都跟着那一份走。**同一个 App 里只该有一种下拉面板。**
///
/// 头像塞进 [GlassMenuOption.leading]（固定 22 见方的槽位），长按跳作者主页
/// 挂 [GlassMenuOption.onLongPress]——那张菜单会因此关掉滑动取焦，理由见该字段。
///
/// # 形状语言：方形 = 筛选条件，圆形 = 身份
///
/// 这个入口和 header 左侧的「我」头像圆钮（`IdentityAvatarButton`）长得太像
/// （都是一张圆头像），所以这里刻意换一套形状把两者拉开：
///   - 没选人时压根不显示头像，只是一枚 `person_search` 图标，和胶囊里其他
///     功能键完全同款；
///   - 选中某人后头像裁成**圆角方形**并套一圈主色描边。
class CompactSubscriptionDropdown extends StatefulWidget {
  final List<SubscriptionDropdownItem> userList;
  final String selectedUserId;
  final Function(String) onUserSelected;

  const CompactSubscriptionDropdown({
    super.key,
    required this.userList,
    required this.selectedUserId,
    required this.onUserSelected,
  });

  @override
  State<CompactSubscriptionDropdown> createState() =>
      _CompactSubscriptionDropdownState();
}

class _CompactSubscriptionDropdownState
    extends State<CompactSubscriptionDropdown> {
  /// 菜单里那枚 22 见方的头像（[GlassMenuOption.leading] 的槽位尺寸）。
  Widget _menuAvatar(SubscriptionDropdownItem item, {required bool selected}) {
    final cs = Theme.of(context).colorScheme;
    const double size = 22;
    if (item.avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: selected ? cs.primary : cs.surfaceContainerHighest,
        child: Icon(
          Icons.cloud,
          size: 13,
          color: selected ? cs.onPrimary : cs.onSurfaceVariant,
        ),
      );
    }
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: CachedNetworkImage(
          imageUrl: item.avatarUrl,
          fit: BoxFit.cover,
          httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: cs.surfaceContainerHighest,
            highlightColor: cs.surface,
            child: const ColoredBox(color: Colors.white),
          ),
          errorWidget: (context, url, error) => CachedNetworkImage(
            imageUrl: CommonConstants.defaultAvatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                Icon(Icons.person, size: 14, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  SubscriptionDropdownItem get _allItem => SubscriptionDropdownItem(
    id: '',
    label: slang.t.common.all,
    avatarUrl: '',
  );

  SubscriptionDropdownItem get _selectedItem {
    if (widget.selectedUserId.isEmpty) return _allItem;
    return widget.userList.firstWhere(
      (item) => item.id == widget.selectedUserId,
      orElse: () => _allItem,
    );
  }

  Future<void> _openMenu(BuildContext anchorContext) async {
    final String? picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        for (final item in [_allItem, ...widget.userList])
          GlassMenuOption<String>(
            value: item.id,
            label: item.label,
            selected: widget.selectedUserId == item.id,
            leading: _menuAvatar(
              item,
              selected: widget.selectedUserId == item.id,
            ),
            onLongPress: item.onLongPress,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    // 选中当前项等于没选：这里不回调，免得撞上页面那条「再点一次取消选择」
    // 的逻辑（`SubscriptionsPageState._onUserSelected`）。
    if (picked != widget.selectedUserId) widget.onUserSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final SubscriptionDropdownItem selected = _selectedItem;
    final bool hasSelection = selected.avatarUrl.isNotEmpty;
    const double avatarBox = 28;
    const double outerRadius = 9;

    final Widget content = hasSelection
        ? Container(
            key: ValueKey('special_follow_${selected.id}'),
            width: avatarBox,
            height: avatarBox,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              border: Border.all(color: cs.primary, width: 1.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(outerRadius - 1.6),
              child: CachedNetworkImage(
                imageUrl: selected.avatarUrl,
                fit: BoxFit.cover,
                httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: cs.surfaceContainerHighest,
                  highlightColor: cs.surface,
                  child: const ColoredBox(color: Colors.white),
                ),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: CommonConstants.defaultAvatarUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, size: 16, color: cs.onSurfaceVariant),
                ),
              ),
            ),
          )
        : Icon(
            Icons.person_search,
            key: const ValueKey('special_follow_all'),
            size: GlassTokens.iconSize,
            color: cs.onSurface,
          );

    return Tooltip(
      message: hasSelection
          ? '${t.common.specialFollow} · ${selected.label}'
          : t.common.specialFollow,
      // Builder：落点与材质档位都是从**触发位自身**的 context 量出来的。
      child: Builder(
        builder: (anchorContext) => GlassPressable(
          onTap: () => _openMenu(anchorContext),
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
        ),
      ),
    );
  }
}
