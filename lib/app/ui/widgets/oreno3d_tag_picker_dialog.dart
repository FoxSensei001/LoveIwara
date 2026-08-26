import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/oreno3d_favorite.model.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Oreno3d 实体选择器（离线，从本地词库检索原作/角色/标签）。
///
/// - 顶部三选一切换类别（原作 / 角色 / 标签）+ 搜索框（匹配译名/原文/id）。
/// - 每行可点击触发 [onSelected]（搜索场景=浏览该实体），右侧爱心独立切换收藏。
///
/// 弹窗本体走 [GlassPickerDialog]：圆角 28 + 顶部渐变蒙层 + 标题行关闭玻璃
/// 圆钮 + 玻璃分段胶囊 + 玻璃输入胶囊。
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

  static const List<String> _typeValues = ['origin', 'character', 'tag'];

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

    return GlassPickerDialog(
      title: t.favoriteTags.pickerTitle,
      onClose: () => Navigator.of(context).pop(),
      constraints: const BoxConstraints(
        maxWidth: 720,
        minWidth: 320,
        maxHeight: 760,
      ),
      rows: [
        // 类别切换：玻璃分段胶囊（内容尺寸，段多时自身可横滚）
        GlassPickerRow(
          child: // 空间够就平铺分段胶囊，露不出 2.5 个完整段就退化成下拉钮
              // （全站同一条约定，见 GlassAdaptiveSegmentedControl）。
              GlassAdaptiveSegmentedControl(
                items: [
                  GlassSegmentItem(label: t.oreno3d.origin),
                  GlassSegmentItem(label: t.oreno3d.characters),
                  GlassSegmentItem(label: t.oreno3d.tags),
                ],
                selectedIndex: _typeValues.indexOf(_type),
                onChanged: (index) =>
                    setState(() => _type = _typeValues[index]),
              ),
        ),
        // 搜索：本地词库检索，输入即过滤
        GlassPickerRow.field(
          child: GlassPickerField(
            controller: _controller,
            hintText: t.favoriteTags.searchHint,
            icon: Icons.search,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      ],
      bodyBuilder: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, double headerExtent) {
    final t = slang.Translations.of(context);
    final results = _results;
    if (results.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: Center(child: Text(t.common.noData)),
      );
    }
    return ListView.builder(
      // headerExtent 由 GlassPickerDialog 实测下发（已含 8px 尾部留白）：
      // 蒙层的尾巴还会往下压一小段，但走到 header 底缘时已经淡到峰值的两成
      // 出头，首屏条目是从渐变里「溶」出来的，不是被一条硬边切开。
      padding: EdgeInsets.only(top: headerExtent, bottom: 12),
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
        subtitleParts.add(t.favoriteTags.worksCount(count: e.workCount));
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
  }
}
