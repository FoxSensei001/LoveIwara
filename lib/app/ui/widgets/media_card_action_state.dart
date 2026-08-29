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
/// # ⛔ 开菜单前不转圈
///
/// [resolveMediaActionStatus] 现在只查本地库（毫秒级），所以长按 / 右键 / 三点钮
/// 都是点下去就出菜单，中间没有任何加载态——这里只留一个重入闸门，免得连点两下
/// 开出两张菜单。真正要加载的动作（下载要先拉源）在菜单自己那一行转圈，
/// 见 media_action_menu.dart 文件头。
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

  /// 纯重入闸门（见类文档）：不驱动任何视觉，所以改它不需要 setState。
  bool _openingMenu = false;

  /// 最近一次按下的落点（全局坐标），见 [recordActionAnchor]。
  Offset? _actionAnchor;

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

  /// 记下这一下按在哪儿（全局坐标），给 [openActionMenu] 当落点用。
  ///
  /// ⛔ **卡片这一路必须挂上它**：卡片是一整块大面积热区，菜单要是照着控件边缘
  /// 弹（[showGlassMenu] 的默认行为），手指按在卡片中间、菜单从卡片顶边冒出来，
  /// 隔着大半张卡片——「离手指最近的一条优先」那套排序也就跟着量歪了。三点钮
  /// 不需要，那枚钮只有 40px，贴着它弹本来就贴着手指。
  ///
  /// 挂在 `onTapDown` / `onSecondaryTapDown` 上而不是长按回调里：`InkWell` 的
  /// `onLongPress` 不给位置。tap 识别器在按下 100ms（`kPressTimeout`）就会派
  /// `onTapDown`，比长按的 500ms 早得多，所以长按最终成立时这个落点一定已经记
  /// 上了——按住时 InkWell 的水波纹立刻亮起来走的就是这同一条路。
  void recordActionAnchor(TapDownDetails details) {
    _actionAnchor = details.globalPosition;
  }

  /// 打开媒体操作菜单（长按 / 右键 / 三点钮共用）。
  Future<void> openActionMenu() async {
    if (!mounted || _openingMenu) return;
    _openingMenu = true;
    try {
      // 本地状态查完再开菜单（都是本地库查询，见类文档）。
      final status = await resolveMediaActionStatus(
        video: actionVideo,
        gallery: actionGallery,
        likedOverride: effectiveLiked,
      );
      if (!mounted) return;
      await showMediaActionMenu(
        anchorContext: context,
        // 贴着手指弹，不贴卡片边缘（见 [recordActionAnchor]）。
        globalPosition: _actionAnchor,
        status: status,
        video: actionVideo,
        gallery: actionGallery,
        likedOverride: effectiveLiked,
        onLikeChanged: applyLikeToggle,
      );
    } finally {
      if (mounted) _openingMenu = false;
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
