import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/oreno3d_favorite.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/add_search_tag_dialog.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/oreno3d_tag_picker_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 收藏的 Iwara 标签管理页（复用 videoSearchTagHistory）。
class FavoriteIwaraTagsPage extends StatelessWidget {
  const FavoriteIwaraTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final pref = Get.find<UserPreferenceService>();
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        body: Obx(
          () => _FavoriteTagWall(
            paddingTop: headerExtent,
            emptyMessage: t.favoriteTags.emptyIwara,
            addLabel: t.favoriteTags.addIwaraTag,
            onAdd: () => showAppDialog(const AddSearchTagDialog()),
            chips: pref.videoSearchTagHistory
                .map(
                  (tag) => _FavoriteChipData(
                    label: TagLocalizationService.displayName(tag.id),
                    onDeleted: () => pref.removeVideoSearchTag(tag),
                  ),
                )
                .toList(),
          ),
        ),
        // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(child: GlassTitlePill(title: t.favoriteTags.iwaraTitle)),
              const SizedBox(width: 8),
              GlassButtonGroup(
                children: [
                  GlassIconButton(
                    icon: const Icon(Icons.add),
                    tooltip: t.favoriteTags.addIwaraTag,
                    onPressed: () => showAppDialog(const AddSearchTagDialog()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 收藏的 Oreno3d 标签管理页（原作 / 角色 / 标签三段）。
class FavoriteOreno3dTagsPage extends StatefulWidget {
  const FavoriteOreno3dTagsPage({super.key});

  @override
  State<FavoriteOreno3dTagsPage> createState() =>
      _FavoriteOreno3dTagsPageState();
}

class _FavoriteOreno3dTagsPageState extends State<FavoriteOreno3dTagsPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _types = ['origin', 'character', 'tag'];

  late final TabController _tabController;
  late final UserPreferenceService _pref;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _pref = Get.find<UserPreferenceService>();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // 动画途中 indexIsChanging 为 true，只关心落定后的那次（添加动作要跟着当前段走）
    if (_tabController.indexIsChanging) return;
    if (mounted) setState(() {});
  }

  /// 打开选择器；管理页里点击行 = 切换收藏（爱心也同步），方便批量勾选。
  void _showPicker(String type) {
    showAppDialog(
      Oreno3dTagPickerDialog(
        initialType: type,
        onSelected: (e) {
          if (_pref.isOreno3dFavorite(e.type, e.id)) {
            _pref.removeOreno3dFavorite(e.type, e.id);
          } else {
            _pref.addOreno3dFavorite(
              Oreno3dFavorite(type: e.type, id: e.id, name: e.original),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    final tabItems = [
      GlassSegmentItem(label: t.oreno3d.origin),
      GlassSegmentItem(label: t.oreno3d.characters),
      GlassSegmentItem(label: t.oreno3d.tags),
    ];

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            for (final type in _types)
              Obx(
                () => _FavoriteTagWall(
                  paddingTop: headerExtent,
                  emptyMessage: t.favoriteTags.emptyOreno3d,
                  addLabel: t.favoriteTags.addFavorite,
                  onAdd: () => _showPicker(type),
                  chips: _pref
                      .oreno3dFavoritesOfType(type)
                      .map(
                        (fav) => _FavoriteChipData(
                          label: Oreno3dLocalizationService.displayName(
                            type: fav.type,
                            id: fav.id,
                            name: fav.name,
                          ),
                          onDeleted: () =>
                              _pref.removeOreno3dFavorite(fav.type, fav.id),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
        // header 行：左 返回圆钮 / 中 分段胶囊（原作/角色/标签）/ 右 动作胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                // 空间够就平铺分段胶囊，露不出 2.5 个完整段就退化成下拉钮
                // （全站同一条约定，见 GlassAdaptiveSegmentedControl）。
                child: GlassAdaptiveSegmentedControl(
                  selectedIndex: _tabController.index,
                  progress: _tabController.animation,
                  onChanged: _tabController.animateTo,
                  items: tabItems,
                ),
              ),
              const SizedBox(width: 8),
              GlassButtonGroup(
                children: [
                  GlassIconButton(
                    icon: const Icon(Icons.add),
                    tooltip: t.favoriteTags.addFavorite,
                    onPressed: () => _showPicker(_types[_tabController.index]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteChipData {
  const _FavoriteChipData({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;
}

/// 收藏标签墙：顶部快速选择提示 + 标签 Chip；空态给一枚「添加」入口。
///
/// 列表整体铺满区域，用 [paddingTop] 让出 header 高度，内容可以从玻璃 header
/// 背后滚过去。
class _FavoriteTagWall extends StatelessWidget {
  const _FavoriteTagWall({
    required this.paddingTop,
    required this.chips,
    required this.emptyMessage,
    required this.addLabel,
    required this.onAdd,
  });

  final double paddingTop;
  final List<_FavoriteChipData> chips;
  final String emptyMessage;
  final String addLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        paddingTop + 8,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        // 收藏会出现在搜索快速选择中的提示条
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: colorScheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.favoriteTags.quickPickHint,
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (chips.isEmpty) ...[
          const SizedBox(height: 32),
          MyEmptyWidget(message: emptyMessage),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
          ),
        ] else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Chip(
                    label: Text(chip.label),
                    onDeleted: chip.onDeleted,
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
