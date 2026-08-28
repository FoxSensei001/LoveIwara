import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';

/// 卡片右下角那枚三点钮的槽位（视频卡片与图库卡片共用）。
///
/// 刻意做成 [Stack] 的**兄弟**而不是塞进卡片那只 InkWell 里——同一棵子树里两个
/// 手势识别器抢竞技场，结果会随实现细节漂移；做成兄弟之后它天然先被命中测试，
/// 卡片点击一点没受影响。所以这里自带 [Positioned]，调用方直接把它摆进 Stack 的
/// children 即可。
///
/// 多选态下整只退场（那时候点什么都该是「选中/取消」），进出两个方向都有过渡、
/// 不硬切。这枚钮不是玻璃件，所以用普通的淡入淡出而不是 GlassReveal——后者是给
/// 玻璃的 materialize 用的。
class MediaCardActionSlot extends StatelessWidget {
  const MediaCardActionSlot({
    super.key,
    this.video,
    this.gallery,
    required this.isMultiSelectMode,
    required this.likedOverride,
    required this.onLikeChanged,
    required this.busy,
    this.duration = const Duration(milliseconds: 220),
  }) : assert(
         (video == null) != (gallery == null),
         'MediaCardActionSlot 一次只处理一条媒体：video 与 gallery 二选一',
       );

  final Video? video;
  final ImageModel? gallery;

  /// 多选态：整只淡出并缩一点，同时不再接收点击。
  final bool isMultiSelectMode;

  /// 卡片自己维护的点赞态。
  final bool likedOverride;

  final ValueChanged<bool> onLikeChanged;

  /// 长按 / 右键期间的忙碌态，引到这枚钮上转圈。
  final bool busy;

  /// 进出多选态的过渡时长，跟卡片自己的悬停过渡保持一致。
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: isMultiSelectMode,
        child: AnimatedOpacity(
          opacity: isMultiSelectMode ? 0 : 1,
          duration: duration,
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: isMultiSelectMode ? 0.8 : 1,
            duration: duration,
            curve: Curves.easeOut,
            child: MediaActionMenuButton(
              video: video,
              gallery: gallery,
              likedOverride: likedOverride,
              onLikeChanged: onLikeChanged,
              busy: busy,
            ),
          ),
        ),
      ),
    );
  }
}
