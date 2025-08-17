import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 搜索分段选择器组件
class SearchSegmentSelector extends StatelessWidget {
  final SearchSegment selectedSegment;
  final Function(SearchSegment) onSegmentChanged;
  final bool showLabel;
  final double height;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;

  const SearchSegmentSelector({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
    this.showLabel = false,
    this.height = 44,
    this.margin,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.only(left: 4),
      height: height,
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        initialValue: selectedSegment.name,
        onSelected: (String newValue) {
          onSegmentChanged(SearchSegment.fromValue(newValue));
        },
        itemBuilder: (BuildContext context) => _buildSegmentMenuItems(t),
        child: _buildSegmentButton(context, t),
      ),
    );
  }

  List<PopupMenuItem<String>> _buildSegmentMenuItems(slang.Translations t) {
    return [
      _buildMenuItem(SearchSegment.video, Icons.video_library, t.common.video),
      _buildMenuItem(SearchSegment.image, Icons.image, t.common.gallery),
      _buildMenuItem(SearchSegment.post, Icons.article, t.common.post),
      _buildMenuItem(SearchSegment.user, Icons.person, t.common.user),
      _buildMenuItem(SearchSegment.forum, Icons.forum, t.forum.forum),
      _buildMenuItem(SearchSegment.oreno3d, Icons.view_in_ar, 'Oreno3D'),
      _buildMenuItem(SearchSegment.playlist, Icons.playlist_play, t.common.playlist),
    ];
  }

  PopupMenuItem<String> _buildMenuItem(SearchSegment segment, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: segment.name,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(BuildContext context, slang.Translations t) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      elevation: elevation ?? 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: showLabel ? null : 44,
        height: 44,
        alignment: Alignment.center,
        padding: showLabel ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10) : null,
        child: showLabel
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getSegmentIcon(selectedSegment),
                  const SizedBox(width: 4),
                  Text(
                    _getSegmentLabel(selectedSegment, t),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              )
            : _getSegmentIcon(selectedSegment),
      ),
    );
  }

  Widget _getSegmentIcon(SearchSegment segment) {
    switch (segment) {
      case SearchSegment.video:
        return const Icon(Icons.video_library, size: 20);
      case SearchSegment.image:
        return const Icon(Icons.image, size: 20);
      case SearchSegment.post:
        return const Icon(Icons.article, size: 20);
      case SearchSegment.user:
        return const Icon(Icons.person, size: 20);
      case SearchSegment.forum:
        return const Icon(Icons.forum, size: 20);
      case SearchSegment.oreno3d:
        return const Icon(Icons.view_in_ar, size: 20);
      case SearchSegment.playlist:
        return const Icon(Icons.playlist_play, size: 20);
    }
  }

  String _getSegmentLabel(SearchSegment segment, slang.Translations t) {
    switch (segment) {
      case SearchSegment.video:
        return t.common.video;
      case SearchSegment.image:
        return t.common.gallery;
      case SearchSegment.post:
        return t.common.post;
      case SearchSegment.user:
        return t.common.user;
      case SearchSegment.forum:
        return t.forum.forum;
      case SearchSegment.oreno3d:
        return 'Oreno3D';
      case SearchSegment.playlist:
        return t.common.playlist;
    }
  }
}

/// 搜索按钮组件
class SearchButton extends StatelessWidget {
  final VoidCallback onSearch;
  final double height;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;

  const SearchButton({
    super.key,
    required this.onSearch,
    this.height = 44,
    this.margin,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        elevation: elevation ?? 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

/// 排序选择器组件（主要用于Oreno3d）
class SortSelector extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortChanged;
  final double height;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;

  const SortSelector({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    this.height = 44,
    this.margin,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.only(left: 4),
      height: height,
      alignment: Alignment.center,
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        initialValue: selectedSort,
        onSelected: onSortChanged,
        itemBuilder: (BuildContext context) => _buildSortMenuItems(t),
        child: _buildSortButton(context),
      ),
    );
  }

  List<PopupMenuItem<String>> _buildSortMenuItems(slang.Translations t) {
    return [
      PopupMenuItem<String>(
        value: 'hot',
        child: Row(
          children: [
            const Icon(Icons.trending_up, size: 20),
            const SizedBox(width: 8),
            Text(t.oreno3d.sortTypes.hot),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'favorites',
        child: Row(
          children: [
            const Icon(Icons.favorite, size: 20),
            const SizedBox(width: 8),
            Text(t.oreno3d.sortTypes.favorites),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'latest',
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 20),
            const SizedBox(width: 8),
            Text(t.oreno3d.sortTypes.latest),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'popularity',
        child: Row(
          children: [
            const Icon(Icons.star, size: 20),
            const SizedBox(width: 8),
            Text(t.oreno3d.sortTypes.popularity),
          ],
        ),
      ),
    ];
  }

  Widget _buildSortButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      elevation: elevation ?? 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          Icons.sort,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// 搜索输入框组件
class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final String? errorText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final Widget? suffixIcon;
  final VoidCallback? onClear;
  final Color? backgroundColor;
  final double? elevation;

  const SearchInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.suffixIcon,
    this.onClear,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation ?? 0,
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        autofocus: autofocus,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: _buildInputDecoration(context),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
      ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      prefixIcon: Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      suffixIcon: suffixIcon ?? (onClear != null
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClear,
            )
          : null),
      filled: true,
      fillColor: Colors.transparent,
      errorText: errorText,
    );
  }
}

/// 标签显示组件（用于Oreno3d）
class TagDisplayWidget extends StatelessWidget {
  final String tagName;
  final VoidCallback onCopy;
  final VoidCallback onTranslate;

  const TagDisplayWidget({
    super.key,
    required this.tagName,
    required this.onCopy,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onCopy,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    '#$tagName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.translate, size: 20),
            onPressed: onTranslate,
          ),
        ],
      ),
    );
  }
}
