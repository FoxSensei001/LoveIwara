/// 横向图片清单的「跟到第几张」把手。
///
/// 存在的理由：大图页是**盖在**图库详情页上的一层（`opaque: false`），用户在里面
/// 从第 1 张一路滑到第 30 张时，底下那条横向清单还停在第 1 张——退出来一眼就看得
/// 出位置不对。大图页每翻一页就经这只把手把清单同步滚过去，等它淡出，下面已经
/// 是刚才在看的那张了。
///
/// 把手挂在 `GalleryDetailController` 上（横跨「详情页落地即开大图」与「清单里
/// 点开大图」两条路），清单自己在 `initState` 里 [attach]、`dispose` 时 [detach]。
/// 清单还没挂上（详情还在骨架屏）时的请求会被记下，等它挂上立刻补做。
typedef HorizontalImageListRevealCallback = void Function(int index);

class HorizontalImageListController {
  HorizontalImageListRevealCallback? _reveal;
  int? _pendingIndex;

  bool get isAttached => _reveal != null;

  void attach(HorizontalImageListRevealCallback reveal) {
    _reveal = reveal;
    final pending = _pendingIndex;
    if (pending != null) {
      _pendingIndex = null;
      reveal(pending);
    }
  }

  void detach(HorizontalImageListRevealCallback reveal) {
    if (identical(_reveal, reveal)) {
      _reveal = null;
    }
  }

  /// 把第 [index] 张滚进视野（不带动画：多数时候清单正被大图页盖着，动画只是
  /// 白烧帧）。
  void revealIndex(int index) {
    if (index < 0) return;
    final reveal = _reveal;
    if (reveal == null) {
      _pendingIndex = index;
      return;
    }
    reveal(index);
  }
}
