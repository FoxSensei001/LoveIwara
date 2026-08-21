import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/oreno3d_favorite.model.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

// header 各行的显式尺寸--列表要用 paddingTop 让出这些高度，让内容可以从
// header 背后滚过去（与 add_video_to_playlist_dialog 同一套弹窗玻璃配方）。
const double _kTitleRowHeight = 16 + 44 + 4;
const double _kSegmentRowHeight = 8 + 44;
const double _kSearchRowHeight = 8 + 44;
const double _kHeaderTailSpacing = 8;
const double _kHeaderExtent =
    _kTitleRowHeight +
    _kSegmentRowHeight +
    _kSearchRowHeight +
    _kHeaderTailSpacing;

/// header 蒙层「淡出段」高度：弹窗四周有 clip，过长的半透明淡出会把
/// 第一排条目糊白，20 只作为「条目钻进 header 背后」的过渡带。
const double _kHeaderFadeExtent = 20;

/// Oreno3d 实体选择器（离线，从本地词库检索原作/角色/标签）。
///
/// - 顶部三选一切换类别（原作 / 角色 / 标签）+ 搜索框（匹配译名/原文/id）。
/// - 每行可点击触发 [onSelected]（搜索场景=浏览该实体），右侧爱心独立切换收藏。
///
/// 弹窗本体走「弹窗玻璃标准配方」：圆角 28 + Stack + EdgeFadeScrim +
/// 标题行关闭玻璃圆钮 + 玻璃分段胶囊 + 玻璃输入胶囊。
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

  /// 玻璃胶囊输入框容器：半透明底色 + 细描边，与全局玻璃控件一致。
  Widget _buildGlassField(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GlassTokens.stroke(colorScheme), width: 0.6),
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: slang.t.favoriteTags.searchHint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 720,
          minWidth: 320,
          maxHeight: 760,
        ),
        child: Stack(
          children: [
            // 主体：列表铺满整个区域，用 paddingTop 让出 header 高度，
            // 让条目可以从上方玻璃 header 背后滚过去。
            Positioned.fill(child: _buildBody(context)),
            // 顶部渐变蒙层：header 高度区间恒定不透明，再向下平滑淡出
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: EdgeFadeScrim.top(
                height: _kHeaderExtent + _kHeaderFadeExtent,
                solidExtent: _kHeaderExtent,
              ),
            ),
            // 顶部玻璃控件行：标题 / 关闭 / 类别分段 / 搜索
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // 标题行：标题 + 玻璃关闭圆钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.favoriteTags.pickerTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        GlassIconButton(
                          standalone: true,
                          icon: const Icon(Icons.close),
                          tooltip: t.common.close,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // 类别切换：玻璃分段胶囊（内容尺寸，段多时自身可横滚）
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GlassSegmentedControl(
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
                  ),
                  // 搜索：本地词库检索，输入即过滤
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _buildGlassField(
                      context,
                      child: TextField(
                        controller: _controller,
                        decoration: _fieldDecoration(context),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final t = slang.Translations.of(context);
    final results = _results;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: _kHeaderExtent),
        child: Center(child: Text(t.common.noData)),
      );
    }
    return ListView.builder(
      // paddingTop 落在渐变蒙层完全淡出之后，首屏条目不被半透明段糊住
      padding: const EdgeInsets.only(
        top: _kHeaderExtent + _kHeaderFadeExtent,
        bottom: 12,
      ),
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
