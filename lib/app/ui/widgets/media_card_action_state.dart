import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_like_override_utils.dart';
import 'package:i_iwara/app/ui/widgets/media_preview_dialog.dart';

/// 媒体卡片 / 列表行共用的那套「本地点赞覆盖 + 预览弹窗」状态。
///
/// 视频卡片、视频行、图库卡片、图库行原先各抄了一份一模一样的样板：三个字段、
/// 两个 getter、一个 `didUpdateWidget` 清覆盖、一个带忙碌态的开菜单方法。
/// 全部收到这里，卡片只需要用几个 getter 说清楚「我承载的是哪一条」。
///
/// # 为什么要有本地覆盖
///
/// 列表项的数据来自上游列表，点赞之后列表不一定会重建，`video.liked` /
/// `imageModel.liked` 会停在旧值上。所以卡片自己记一份覆盖，显示的时候优先用它；
/// 等上游真的换了数据（换了另一条，或者同一条的点赞态/赞数变了），再把覆盖清掉
/// 让位给新数据。
///
/// # 长按 / 右键 → 预览弹窗
///
/// 三点钮那只操作菜单由 `MediaActionMenuButton` 自己管（它贴着自己弹），卡片这
/// 一侧只负责预览：[openPreview] 出弹窗，[previewHeroEnabled] / [previewHeroTag]
/// 供卡片把缩略图挂进 Hero。分工与理由见 `media_preview_dialog.dart` 文件头。
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

  /// 打开这条媒体的详情页。
  ///
  /// 预览弹窗里那枚「打开」走它。做成抽象成员而不是可选回调：四张卡片本来就
  /// 各有一份（参数完全不同——图库要带封面/张数，视频要带回灌点赞的 extData），
  /// 声明在这儿之后，新加的卡片漏接会直接编译不过。
  Future<void> openMediaDetail();

  bool? _likedOverride;
  int? _likeCountOverride;

  /// 预览弹窗正开着（含出入场与 Hero 回飞）。
  ///
  /// 兼作重入闸门。它**驱动视觉**（Hero 挂不挂），所以改它要 setState。
  bool _previewOpen = false;

  // 上一次见到的数据源取值。didUpdateWidget 里拿它跟当前值比，判断上游是不是
  // 真的换了数据——比对着 oldWidget 读字段等价，但不用每个卡片各写一遍。
  late String _lastMediaId;
  late bool _lastBaseLiked;
  late int _lastBaseLikeCount;

  /// 显示用的点赞态：本地覆盖优先。
  bool get effectiveLiked => _likedOverride ?? baseLiked;

  /// 显示用的赞数：本地覆盖优先。
  int get effectiveLikeCount => _likeCountOverride ?? baseLikeCount;

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

  /// 这张卡片的缩略图此刻要不要参与 Hero 飞行。
  ///
  /// ⛔ **必须靠它把 Hero 关掉**，不能常驻：同一条媒体在一个路由里出现两次并
  /// 非不可能（详情页的相关推荐 + 侧边「接着看」抽屉），而重复的 Hero tag 在
  /// debug 下直接炸断言。同一时刻只可能有一张卡片开着预览，只让它挂 Hero，
  /// 重复从此不可能发生；顺带也省掉列表里几十个常驻 Hero 的开销。
  bool get previewHeroEnabled => _previewOpen;

  /// 卡片缩略图 ↔ 弹窗封面的 Hero 标签。
  String get previewHeroTag =>
      mediaPreviewHeroTag(video: actionVideo, gallery: actionGallery);

  /// 打开预览弹窗（长按 / 右键 / 操作菜单里的「预览」共用）。
  Future<void> openPreview() async {
    if (!mounted || _previewOpen) return;
    // 先让卡片带着 Hero 重建一帧：Hero 飞行是在 push 之后的 post-frame 里才去
    // 收集两侧 Hero 的，那时这一帧已经建完，正好收得到。
    setState(() => _previewOpen = true);
    try {
      await showMediaPreviewDialog(
        context: context,
        video: actionVideo,
        gallery: actionGallery,
        likedOverride: effectiveLiked,
        likeCountOverride: effectiveLikeCount,
        onLikeChanged: applyLikeToggle,
        onOpenDetail: openMediaDetail,
      );
    } finally {
      // 等的是路由**销毁**（见 showMediaPreviewDialog），所以回飞已经落地，
      // 这时候摘 Hero 不会把飞到一半的封面掐掉。
      if (mounted) setState(() => _previewOpen = false);
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
  ///
  /// 自己查一次 `mounted`：今天三个调用点都是在 await 之后先查过才进来的，但这是
  /// 个公开方法，下一个人在 `await Navigator.push(...)` 后直接调它是很自然的写法。
  void applyLikePatchFromExtData(Map<String, dynamic>? extData) {
    if (!mounted) return;
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
