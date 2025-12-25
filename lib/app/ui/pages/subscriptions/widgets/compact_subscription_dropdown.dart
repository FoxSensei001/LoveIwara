import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  const CompactSubscriptionDropdown({
    super.key,
    required this.userList,
    required this.selectedUserId,
    required this.onUserSelected,
    this.height = 48.0,
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
  bool _isDropdownOpen = false;

  @override
  void dispose() {
    if (_isDropdownOpen) {
      _overlayEntry.remove();
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

  // 关闭下拉菜单
  void _closeDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry.remove();
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  // 打开下拉菜单
  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
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
            left: offset.dx,
            top: offset.dy + size.height,
            width: min(
              size.width * 1.5,
              screenWidth - offset.dx * 2,
            ), // 设置一个合理的宽度
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surface,
                child: Container(
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
        ],
      ),
    );
  }

  Widget _buildDropdownItem(SubscriptionDropdownItem item) {
    final theme = Theme.of(context);
    final bool isSelected = widget.selectedUserId == item.id;

    return InkWell(
      onTap: () {
        if (widget.selectedUserId != item.id) {
          widget.onUserSelected(item.id);
        }
        _closeDropdown();
      },
      onLongPress: item.onLongPress,
      child: Container(
        height: 48.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surfaceContainerHighest : null,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            if (item.avatarUrl.isEmpty)
              CircleAvatar(
                radius: 14,
                backgroundColor: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.cloud,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
              )
            else
              CircleAvatar(
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
                    httpHeaders: const {
                      'referer': CommonConstants.iwaraBaseUrl,
                    },
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: theme.colorScheme.primary, size: 16),
          ],
        ),
      ),
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

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.transparent, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedItem.avatarUrl.isEmpty)
                CircleAvatar(
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
              else
                CircleAvatar(
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
                      httpHeaders: const {
                        'referer': CommonConstants.iwaraBaseUrl,
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                selectedItem.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double min(double a, double b) {
    return a < b ? a : b;
  }
}
