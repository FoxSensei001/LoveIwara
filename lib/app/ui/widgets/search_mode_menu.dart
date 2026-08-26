import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 搜索模式的**优先级顺序**（高 → 低）：搜索页的分段控件按它平铺，长按搜索钮
/// 弹出的模式菜单按它排（见 [showSearchModeMenu]）。
///
/// 全 App 只此一份。两处各排一遍的话，改了顺序总有一处忘记跟——而用户读到的
/// 是「同一组东西在两个地方顺序不一样」。
const List<SearchSegment> kSearchSegmentsByPriority = [
  SearchSegment.video, // 视频
  SearchSegment.image, // 图库
  SearchSegment.oreno3d, // Oreno3D
  SearchSegment.user, // 用户
  SearchSegment.playlist, // 播放列表
  SearchSegment.forum, // 论坛
  SearchSegment.forum_posts, // 帖子
  SearchSegment.post, // 投稿
];

String searchSegmentLabel(SearchSegment seg, slang.Translations t) {
  return switch (seg) {
    SearchSegment.video => t.common.video,
    SearchSegment.image => t.common.gallery,
    SearchSegment.user => t.common.user,
    SearchSegment.playlist => t.common.playlist,
    SearchSegment.post => t.common.post,
    SearchSegment.forum => t.forum.forum,
    SearchSegment.forum_posts => t.forum.posts,
    SearchSegment.oreno3d => 'Oreno3D',
  };
}

IconData searchSegmentIcon(SearchSegment seg) {
  return switch (seg) {
    SearchSegment.video => Icons.video_library_outlined,
    SearchSegment.image => Icons.image_outlined,
    SearchSegment.user => Icons.person_outline,
    SearchSegment.playlist => Icons.playlist_play_outlined,
    SearchSegment.post => Icons.article_outlined,
    SearchSegment.forum => Icons.forum_outlined,
    SearchSegment.forum_posts => Icons.comment_outlined,
    SearchSegment.oreno3d => Icons.view_in_ar_outlined,
  };
}

/// 长按搜索钮弹出的「搜索模式」菜单：一次性列全 [kSearchSegmentsByPriority]，
/// 选中哪一条就直接进搜索页并预置成那个模式。
///
/// 顺序不用调用点操心：[showGlassMenu] 的 `priorityNearAnchor` 会在面板翻到
/// 触发件上方时把整列倒过来，于是
///   · 底部浮动栏那枚圆钮 → 菜单朝上开 → 优先级最高的落在**最下面**（贴着手指）；
///   · 顶部 header 那枚 → 菜单朝下开 → 优先级最高的落在**最上面**。
/// 两处共用同一份顺序表，读起来都是「离手指最近的最常用」。
///
/// [current] 是这个页面点按搜索钮时的默认模式，在菜单里打勾——长按只是把那次
/// 默认**换掉**，所以人得先看见默认是哪一个。
Future<void> showSearchModeMenu({
  required BuildContext anchorContext,
  required SearchSegment current,
}) async {
  final t = slang.Translations.of(anchorContext);
  final picked = await showGlassMenu<SearchSegment>(
    anchorContext: anchorContext,
    priorityNearAnchor: true,
    entries: [
      for (final seg in kSearchSegmentsByPriority)
        GlassMenuOption<SearchSegment>(
          value: seg,
          icon: searchSegmentIcon(seg),
          label: searchSegmentLabel(seg, t),
          selected: seg == current,
        ),
    ],
  );
  if (picked == null) return;
  NaviService.navigateToSearchPage(initialSegment: picked);
}

/// 全站的搜索入口钮：**点按**直接进搜索页（用页面自己的默认模式），
/// **长按**弹出全部搜索模式挑一个（[showSearchModeMenu]）。
///
/// 长按那一下与「点按开菜单」的钮同款：到点震一下、手指不用抬就能直接划到某一
/// 条上松手选中（[GlassIconButton.longPressOpensOverlay]）。
///
/// ⛔ 这枚钮就是 `glass_style_guard_test` 认的共用触发件：`longPressOpensOverlay:
/// true` 只在这儿声明一次，各页面不再各自写一遍长按。
class SearchActionButton extends StatelessWidget {
  const SearchActionButton({
    super.key,
    required this.segment,
    this.standalone = false,
  });

  /// 这个页面点按搜索钮时的默认模式（热门视频 → 视频、图库 → 图库、订阅按当前
  /// 子 tab、社区 → 论坛……）。菜单里它是打勾的那一条。
  final SearchSegment segment;

  /// 见 [GlassIconButton.standalone]。放在 header 的按钮组里时为 false。
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // Builder：落点是从**触发件自身**的 RenderBox 上量的，得拿它自己的 context。
    return Builder(
      builder: (anchorContext) => GlassIconButton(
        standalone: standalone,
        icon: const Icon(Icons.search),
        tooltip: t.common.search,
        onPressed: () => NaviService.navigateToSearchPage(
          initialSegment: segment,
        ),
        longPressOpensOverlay: true,
        onLongPressed: () => showSearchModeMenu(
          anchorContext: anchorContext,
          current: segment,
        ),
      ),
    );
  }
}
