import 'package:flutter/foundation.dart';

/// 图库详情页交给**大图页**的那一份「接着看」。
///
/// # 为什么要有这个小包
///
/// 大图页（`MyGalleryPhotoViewWrapper`）是**盖在**详情页上的一条独立路由，而池
/// （`PlaybackQueue`）是**详情页**的属性——每层详情页各持一份，池的真身在
/// `PlaybackQueueService` 里。所以大图页自己既建不出池、也不该去建：它只是把
/// 详情页手上那份的两个动作（在不在场 / 打开抽屉）借过来画一枚钮。
///
/// 一路要经过 `GalleryImageScrollerWidget → openGalleryImageViewer →
/// pushPhotoViewWrapperOverlay → PhotoViewExtra → MyGalleryPhotoViewWrapper`
/// 五道口子。打成一个包传，每道口子只加一个参数；拆成三四个回调各传一遍，
/// 加一枚钮就要改十几处签名。
///
/// # 与视频那边的对应关系
///
/// 视频播放器的全屏是**同一条路由里的一层叠加**（`my_video_screen.dart` 的
/// `isFullScreen`），池由详情页直接下发给它，用不着这种包。图库这边全屏看图是
/// 另一条路由，中间隔着好几层构造函数，才需要把它收成一件东西。
@immutable
class GalleryUpNext {
  const GalleryUpNext({required this.hasQueue, required this.open});

  /// 入口钮要不要在场。判据与详情页 header 上那一枚**完全一致**：
  /// 手上有没有池，不看池里这会儿有没有东西（成因见详情页的 `_hasPlaybackQueue`）。
  final bool hasQueue;

  /// 打开「接着看」抽屉。
  ///
  /// [onBeforeNavigate] 在**真的要换到下一个图库之前**调用一次；用户只是逛了一圈
  /// 没点任何一条时不会被调到。大图页拿它把自己这一层先收掉——不收的话，换页用的
  /// `pushReplacement` 替掉的会是**栈顶**（也就是大图页自己），旧的那张详情页反而
  /// 留在栈里，返回键会退回上一个图库。
  final Future<void> Function({VoidCallback? onBeforeNavigate}) open;
}
