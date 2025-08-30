import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class Oreno3dTagsWidget extends StatelessWidget {
  final dynamic oreno3dDetail;
  final Function(String, String, String) onSearchTap;

  const Oreno3dTagsWidget({
    super.key,
    required this.oreno3dDetail,
    required this.onSearchTap,
  });

  Widget _buildSearchableTag({
    required String id,
    required String name,
    required String type,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSearchTap(id, type, name),
        borderRadius: BorderRadius.circular(12),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.tagPaddingHorizontal,
              vertical: UIConstants.tagPaddingVertical,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<dynamic> items,
    required Color color,
    required String type,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: UIConstants.smallSpacing),
        Wrap(
          spacing: UIConstants.iconTextSpacing,
          runSpacing: UIConstants.smallSpacing,
          children: items.map((item) {
            return _buildSearchableTag(
              id: item.id ?? item.name,
              name: item.name,
              type: type,
              color: color,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    if (oreno3dDetail == null) return const SizedBox.shrink();

    final hasOrigin = oreno3dDetail.origin != null;
    final hasTags = oreno3dDetail.tags.isNotEmpty;
    final hasCharacters = oreno3dDetail.characters.isNotEmpty;
    
    // 如果三者都为空，不显示
    if (!hasOrigin && !hasTags && !hasCharacters) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 原作信息
          if (hasOrigin) ...[
            _buildSection(
              title: t.oreno3d.origin,
              items: [oreno3dDetail.origin],
              color: Colors.green,
              type: 'origin',
            ),
          ],

          // Oreno3D标签
          if (hasTags) ...[
            if (hasOrigin) const SizedBox(height: UIConstants.interElementSpacing),
            _buildSection(
              title: t.oreno3d.tags,
              items: oreno3dDetail.tags,
              color: Colors.purple,
              type: 'tag',
            ),
          ],

          // 角色信息
          if (hasCharacters) ...[
            if (hasTags || hasOrigin) const SizedBox(height: UIConstants.interElementSpacing),
            _buildSection(
              title: t.oreno3d.characters,
              items: oreno3dDetail.characters,
              color: Colors.blue,
              type: 'character',
            ),
          ],
        ],
      ),
    );
  }
}
