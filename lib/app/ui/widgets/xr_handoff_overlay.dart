import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/xr_immersive_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「正在交给空间…」的全局罩子。
///
/// # 为什么需要它
///
/// 把视频 / 图库交给沉浸场景的那段窗口里，**2D 面板上看不出任何变化**：幕布是在用户
/// 身前另一个地方亮起来的，而面板这侧一动不动。交付本身要过通道、等原生回执，图库
/// 还要先把封面备齐——短则半秒，长则好几秒。没有任何反馈的话，用户会当成没点上、
/// 连点好几下，而每一下都是一次重新提交（用户 2026-09-15 提的）。
///
/// # 为什么挂在最外层
///
/// 交付的入口只有 [XrImmersiveService.present] 与 [XrImmersiveService.presentGallery]
/// 两个，调用点却散在视频详情页、图库详情页、本机文件的三处入口、面板里的「接着看」……
/// 罩子跟着**服务**走，新增调用点不必各自记得画一个。
///
/// ⛔ [AbsorbPointer] 是它的正事，不是装饰：只画一层半透明黑挡不住手指。
class XrHandoffOverlay extends StatelessWidget {
  const XrHandoffOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<XrImmersiveService>()) return const SizedBox.shrink();
    final xr = Get.find<XrImmersiveService>();
    return Obx(() {
      final busy = xr.handoffDepth.value > 0;
      return IgnorePointer(
        ignoring: !busy,
        child: AnimatedOpacity(
          opacity: busy ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AbsorbPointer(
            absorbing: busy,
            child: ColoredBox(
              color: const Color(0x73000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      slang.t.vrFormat.handingOff,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
