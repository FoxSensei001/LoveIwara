import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_like_override_utils.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';

/// 媒体卡片 / 列表行共用的那套「本地点赞覆盖 + 操作菜单」状态。
///
/// 视频卡片、视频行、图库卡片、图库行原先各抄了一份一模一样的样板：三个字段、
/// 两个 getter、一个 `didUpdateWidget` 清覆盖、一个带忙碌态的 `_openActionMenu`。
/// 全部收到这里，卡片只需要用几个 getter 说清楚「我承载的是哪一条」。
///
/// # 为什么要有本地覆盖
///
/// 列表项的数据来自上游列表，点赞之后列表不一定会重建，`video.liked` /
/// `imageModel.liked` 会停在旧值上。所以卡片自己记一份覆盖，显示的时候优先用它；
/// 等上游真的换了数据（换了另一条，或者同一条的点赞态/赞数变了），再把覆盖清掉
/// 让位给新数据。
///
/// # 为什么开菜单前要转圈
///
/// [resolveMediaActionStatus] 要打一次网络请求，而菜单开出来之后行就改不了了
/// （见 media_action_menu.dart 文件头）。所以必须先查完再开，期间把 [menuBusy]
/// 引到三点钮上转圈——否则长按 / 右键之后画面会静静地冻上一两秒。
mixin MediaCardActionState<T extends StatefulWidget> on State<T> {
  /// 这张卡片承载的视频。与 [actionGallery] 二选一。
  Video? get actionVideo => null;

  /// 这张卡片承载的图库。与 [actionVideo] 二选一。
  ImageModel? get actionGallery => null;

  /// 用于判断「换了另一条」的 id。
  String get actionMediaId;

  /// 数据源里的点赞态（不含本地覆盖）。
  bool get baseLiked;

  /// 数据源里的赞数（不含本地覆盖）。
  int get baseLikeCount;

  bool? _likedOverride;
  int? _likeCountOverride;
  bool _menuBusy = false;

  // 上一次见到的数据源取值。didUpdateWidget 里拿它跟当前值比，判断上游是不是
  // 真的换了数据——比对着 oldWidget 读字段等价，但不用每个卡片各写一遍。
  late String _lastMediaId;
  late bool _lastBaseLiked;
  late int _lastBaseLikeCount;

  /// 显示用的点赞态：本地覆盖优先。
  bool get effectiveLiked => _likedOverride ?? baseLiked;

  /// 显示用的赞数：本地覆盖优先。
  int get effectiveLikeCount => _likeCountOverride ?? baseLikeCount;

  /// 正在解析菜单状态（引到三点钮上转圈）。
  bool get menuBusy => _menuBusy;

  @override
  void initState() {
    super.initState();
    _snapshotSource();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (shouldResetLikeOverride(
      oldId: _lastMediaId,
      newId: actionMediaId,
      oldLiked: _lastBaseLiked,
      newLiked: baseLiked,
      oldLikeCount: _lastBaseLikeCount,
      newLikeCount: baseLikeCount,
    )) {
      _likedOverride = null;
      _likeCountOverride = null;
    }
    _snapshotSource();
  }

  void _snapshotSource() {
    _lastMediaId = actionMediaId;
    _lastBaseLiked = baseLiked;
    _lastBaseLikeCount = baseLikeCount;
  }

  /// 打开媒体操作菜单（长按 / 右键 / 三点钮共用）。
  Future<void> openActionMenu() async {
    if (!mounted || _menuBusy) return;
    setState(() => _menuBusy = true);
    try {
      // 先把状态查完再开菜单，期间三点钮转圈（见类文档）。
      final status = await resolveMediaActionStatus(
        video: actionVideo,
        gallery: actionGallery,
        likedOverride: effectiveLiked,
      );
      if (!mounted) return;
      await showMediaActionMenu(
        anchorContext: context,
        status: status,
        video: actionVideo,
        gallery: actionGallery,
        likedOverride: effectiveLiked,
        onLikeChanged: applyLikeToggle,
      );
    } finally {
      if (mounted) setState(() => _menuBusy = false);
    }
  }

  /// 菜单里点赞/取消点赞之后，把卡片自己那份显示态跟上（卡片不一定重建）。
  void applyLikeToggle(bool liked) {
    if (!mounted) return;
    setState(() {
      _likedOverride = liked;
      _likeCountOverride = effectiveLikeCount + (liked ? 1 : -1);
    });
  }

  /// 从详情页回来时，把详情页写回 extData 的点赞态补到卡片上。
  void applyLikePatchFromExtData(Map<String, dynamic>? extData) {
    if (extData == null) return;
    final liked = extData[NaviService.mediaLikePatchLikedKey];
    final likeCount = extData[NaviService.mediaLikePatchCountKey];
    if (liked is! bool || likeCount is! num) return;

    final normalizedLikeCount = likeCount.toInt() < 0 ? 0 : likeCount.toInt();
    if (effectiveLiked == liked && effectiveLikeCount == normalizedLikeCount) {
      return;
    }
    setState(() {
      _likedOverride = liked;
      _likeCountOverride = normalizedLikeCount;
    });
  }
}
