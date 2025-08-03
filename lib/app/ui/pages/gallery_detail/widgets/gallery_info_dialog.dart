import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 图库功能介绍弹窗
class GalleryInfoDialog {
  static void show(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.galleryDetail.imageLibraryFunctionIntroduction),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              // 点击左右边缘以切换图片
              _buildInfoRow(
                Icons.arrow_right_alt,
                slang.t.galleryDetail.clickLeftAndRightEdgeToSwitchImage,
              ),
              const SizedBox(height: 8),
              
              // 右键保存单张图片
              _buildInfoRow(
                Icons.save,
                slang.t.galleryDetail.rightClickToSaveSingleImage,
              ),
              const SizedBox(height: 8),
              
              // 键盘的左右控制切换
              _buildInfoRow(
                Icons.keyboard_arrow_left,
                slang.t.galleryDetail.keyboardLeftAndRightToSwitch,
              ),
              const SizedBox(height: 8),
              
              // 键盘的上下控制缩放
              _buildInfoRow(
                Icons.keyboard_arrow_up,
                slang.t.galleryDetail.keyboardUpAndDownToZoom,
              ),
              const SizedBox(height: 8),
              
              // 鼠标的滚轮滑动控制切换
              _buildInfoRow(
                Icons.swap_vert,
                slang.t.galleryDetail.mouseWheelToSwitch,
              ),
              const SizedBox(height: 8),
              
              // CTRL + 鼠标滚轮控制缩放
              _buildInfoRow(
                Icons.zoom_in,
                slang.t.galleryDetail.ctrlAndMouseWheelToZoom,
              ),
              const SizedBox(height: 8),
              
              // 更多功能待发现
              _buildInfoRow(
                Icons.thumb_up,
                slang.t.galleryDetail.moreFeaturesToBeDiscovered,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(slang.t.common.close),
            onPressed: () {
              AppService.tryPop();
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
