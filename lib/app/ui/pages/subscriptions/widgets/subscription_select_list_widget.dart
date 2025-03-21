import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';
import '../../../../../common/constants.dart';

/// 订阅列表选择框
class SubscriptionSelectItem {
  final String id;
  final String label;
  final String avatarUrl;
  final VoidCallback? onLongPress;

  SubscriptionSelectItem({
    required this.id,
    required this.label,
    required this.avatarUrl,
    this.onLongPress,
  });
}

class SubscriptionSelectList extends StatefulWidget {
  final List<SubscriptionSelectItem> userList;
  final String selectedUserId;
  final Function(String) onUserSelected;

  const SubscriptionSelectList({
    super.key,
    required this.userList,
    required this.selectedUserId,
    required this.onUserSelected,
  });

  @override
  SubscriptionSelectListState createState() => SubscriptionSelectListState();
}

class SubscriptionSelectListState extends State<SubscriptionSelectList> {
  final ScrollController _scrollController = ScrollController();
  bool _showButtons = false;

  final allSubscriptionItem = SubscriptionSelectItem(
    id: '',
    label: slang.t.common.all,
    avatarUrl: '',
  );

  void _scrollToPage(bool isLeft) {
    final viewportWidth = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;
    final targetOffset = isLeft
        ? max(currentOffset - viewportWidth, 0.0)
        : min(currentOffset + viewportWidth,
            _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        height: 72, // 固定高度确保不需要垂直滚动
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildIconWithLabel(
                allSubscriptionItem,
                theme,
              ),
            ),
            Expanded(
              child: MouseRegion(
                onEnter: (_) => setState(() => _showButtons = true),
                onExit: (_) => setState(() => _showButtons = false),
                child: Stack(
                  children: [
                    Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          final double scrollAmount =
                              pointerSignal.scrollDelta.dy * 2;
                          _scrollController.jumpTo(
                            (_scrollController.offset + scrollAmount).clamp(
                              0.0,
                              _scrollController.position.maxScrollExtent,
                            ),
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: widget.userList
                              .map((item) => _buildIconWithLabel(item, theme))
                              .toList(),
                        ),
                      ),
                    ),
                    if (_showButtons) ..._buildScrollButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScrollButtons() {
    return [
      Positioned(
        left: -10,
        top: 0,
        bottom: 0,
        child: Center(
          child: _buildScrollButton(true),
        ),
      ),
      Positioned(
        right: 10,
        top: 0,
        bottom: 0,
        child: Center(
          child: _buildScrollButton(false),
        ),
      ),
    ];
  }

  Widget _buildScrollButton(bool isLeft) {
    return AnimatedOpacity(
      opacity: _showButtons ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        onPressed: () => _scrollToPage(isLeft),
        child: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildIconWithLabel(
    SubscriptionSelectItem selectItem,
    ThemeData theme,
  ) {
    final bool isSelected = widget.selectedUserId == selectItem.id;
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    return SizedBox(
      width: isSmallScreen ? 60 : 68,
      child: InkWell(
        onTap: () => {
          if (widget.selectedUserId != selectItem.id)
            widget.onUserSelected(selectItem.id)
        },
        onLongPress: selectItem.onLongPress,
        onSecondaryTap: selectItem.onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectItem.avatarUrl.isEmpty)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isSmallScreen ? 16 : 18,
                  backgroundColor: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.cloud,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isSmallScreen ? 16 : 18,
                  backgroundColor: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
                    child: CachedNetworkImage(
                      imageUrl: selectItem.avatarUrl,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: CircleAvatar(
                          radius: isSmallScreen ? 16 : 18,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: isSmallScreen ? 16 : 18,
                        backgroundImage: const NetworkImage(CommonConstants.defaultAvatarUrl),
                        onBackgroundImageError: (exception, stackTrace) => Icon(
                          Icons.person,
                          size: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      httpHeaders: const {
                        'referer': CommonConstants.iwaraBaseUrl
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 2),
            Text(
              selectItem.label,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
