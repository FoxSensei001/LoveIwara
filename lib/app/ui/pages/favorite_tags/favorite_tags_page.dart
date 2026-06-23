import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/models/oreno3d_favorite.model.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/add_search_tag_dialog.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
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
    final mq = MediaQuery.of(context);
    // Scaffold 已按 padding.bottom 抬高 FAB；edge-to-edge 下 padding.bottom 可能为 0，
    // 此时手势条仍占空间，补上差值即可，避免三键导航下重复抬高。
    final fabGap = math.max(
      0.0,
      computeBottomSafeInset(mq) - mq.padding.bottom,
    );
    return Scaffold(
      appBar: AppBar(title: Text(t.favoriteTags.iwaraTitle)),
      body: Column(
        children: [
          _QuickPickHint(),
          Expanded(
            child: Obx(() {
              final tags = pref.videoSearchTagHistory;
              if (tags.isEmpty) {
                return Center(
                  child: MyEmptyWidget(message: t.favoriteTags.emptyIwara),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            TagLocalizationService.displayName(tag.id),
                          ),
                          onDeleted: () => pref.removeVideoSearchTag(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      )
                      .toList(),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabGap),
        child: FloatingActionButton.extended(
          onPressed: () => showAppDialog(const AddSearchTagDialog()),
          icon: const Icon(Icons.add),
          label: Text(t.favoriteTags.addIwaraTag),
        ),
      ),
    );
  }
}

/// 收藏的 Oreno3d 标签管理页（原作 / 角色 / 标签三个 Tab）。
class FavoriteOreno3dTagsPage extends StatelessWidget {
  const FavoriteOreno3dTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final pref = Get.find<UserPreferenceService>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.favoriteTags.oreno3dTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: t.oreno3d.origin),
              Tab(text: t.oreno3d.characters),
              Tab(text: t.oreno3d.tags),
            ],
          ),
        ),
        body: Column(
          children: [
            _QuickPickHint(),
            Expanded(
              child: TabBarView(
                children: [
                  _Oreno3dTab(pref: pref, type: 'origin'),
                  _Oreno3dTab(pref: pref, type: 'character'),
                  _Oreno3dTab(pref: pref, type: 'tag'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 收藏会出现在搜索快速选择中的提示条。
class _QuickPickHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              t.favoriteTags.quickPickHint,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Oreno3d 收藏 Tab（origin / character / tag 各一份）。
class _Oreno3dTab extends StatelessWidget {
  final UserPreferenceService pref;
  final String type;
  const _Oreno3dTab({required this.pref, required this.type});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final mq = MediaQuery.of(context);
    final fabGap = math.max(
      0.0,
      computeBottomSafeInset(mq) - mq.padding.bottom,
    );
    return Scaffold(
      body: Obx(() {
        final favorites = pref.oreno3dFavoritesOfType(type);
        if (favorites.isEmpty) {
          return Center(
            child: MyEmptyWidget(message: t.favoriteTags.emptyOreno3d),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: favorites.map((fav) {
              final name = Oreno3dLocalizationService.displayName(
                type: fav.type,
                id: fav.id,
                name: fav.name,
              );
              return Chip(
                label: Text(name),
                onDeleted: () => pref.removeOreno3dFavorite(fav.type, fav.id),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        );
      }),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabGap),
        child: FloatingActionButton.extended(
          onPressed: () => showAppDialog(
            Oreno3dTagPickerDialog(
              initialType: type,
              // 管理页里点击行 = 切换收藏（爱心也同步），方便批量勾选。
              onSelected: (e) {
                if (pref.isOreno3dFavorite(e.type, e.id)) {
                  pref.removeOreno3dFavorite(e.type, e.id);
                } else {
                  pref.addOreno3dFavorite(
                    Oreno3dFavorite(type: e.type, id: e.id, name: e.original),
                  );
                }
              },
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(t.favoriteTags.addFavorite),
        ),
      ),
    );
  }
}
