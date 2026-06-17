import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/oreno3d_favorite.model.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Oreno3d 实体选择器（离线，从本地词库检索原作/角色/标签）。
///
/// - 顶部三选一切换类别（原作 / 角色 / 标签）+ 搜索框（匹配译名/原文/id）。
/// - 每行可点击触发 [onSelected]（搜索场景=浏览该实体），右侧爱心独立切换收藏。
class Oreno3dTagPickerDialog extends StatefulWidget {
  /// 初始类别：`origin` / `character` / `tag`。
  final String initialType;

  /// 点击某一行时回调（通常用于「浏览该实体」）。
  final void Function(Oreno3dEntry entry) onSelected;

  /// 点击行后是否自动关闭弹窗（搜索浏览场景=true；管理多选场景=false）。
  final bool closeOnSelect;

  const Oreno3dTagPickerDialog({
    super.key,
    this.initialType = 'tag',
    required this.onSelected,
    this.closeOnSelect = false,
  });

  @override
  State<Oreno3dTagPickerDialog> createState() => _Oreno3dTagPickerDialogState();
}

class _Oreno3dTagPickerDialogState extends State<Oreno3dTagPickerDialog> {
  final TextEditingController _controller = TextEditingController();
  final UserPreferenceService _pref = Get.find<UserPreferenceService>();
  late String _type = widget.initialType;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Oreno3dEntry> get _results {
    if (!Get.isRegistered<Oreno3dLocalizationService>()) return const [];
    return Oreno3dLocalizationService.to.search(_type, _query, limit: 80);
  }

  void _toggleFavorite(Oreno3dEntry e) {
    if (_pref.isOreno3dFavorite(e.type, e.id)) {
      _pref.removeOreno3dFavorite(e.type, e.id);
    } else {
      _pref.addOreno3dFavorite(
        Oreno3dFavorite(type: e.type, id: e.id, name: e.original),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 720,
          minWidth: 320,
          maxHeight: 760,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.favoriteTags.pickerTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 类别切换
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'origin', label: Text(t.oreno3d.origin)),
                  ButtonSegment(
                    value: 'character',
                    label: Text(t.oreno3d.characters),
                  ),
                  ButtonSegment(value: 'tag', label: Text(t.oreno3d.tags)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
                showSelectedIcon: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: t.favoriteTags.searchHint,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Builder(
                builder: (context) {
                  final results = _results;
                  if (results.isEmpty) {
                    return Center(child: Text(t.common.noData));
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final e = results[index];
                      final subtitleParts = <String>[];
                      if (e.origin != null && e.origin!.isNotEmpty) {
                        subtitleParts.add(e.origin!);
                      }
                      if (e.original.isNotEmpty && e.original != e.name) {
                        subtitleParts.add(e.original);
                      }
                      subtitleParts.add(
                        t.favoriteTags.worksCount(count: e.workCount),
                      );
                      return ListTile(
                        dense: true,
                        title: Text(e.name),
                        subtitle: Text(
                          subtitleParts.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Obx(() {
                          final fav = _pref.isOreno3dFavorite(e.type, e.id);
                          return IconButton(
                            icon: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              color: fav ? Colors.red : null,
                            ),
                            onPressed: () => _toggleFavorite(e),
                          );
                        }),
                        onTap: () {
                          if (widget.closeOnSelect) {
                            Navigator.of(context).pop();
                          }
                          widget.onSelected(e);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
