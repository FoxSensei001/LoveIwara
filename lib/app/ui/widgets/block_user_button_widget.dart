import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/content_block_service.dart';
import 'package:i_iwara/app/ui/widgets/action_icon_button_scaffold.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:oktoast/oktoast.dart';

/// 用户主页操作栏上的「屏蔽 / 取消屏蔽」按钮（本地屏蔽，不调用 Iwara API）。
class BlockUserButtonWidget extends StatelessWidget {
  final User user;

  /// 仅图标模式（用于空间有限的操作栏）。
  final bool iconOnly;

  const BlockUserButtonWidget({
    super.key,
    required this.user,
    this.iconOnly = false,
  });

  ContentBlockService get _service => Get.find<ContentBlockService>();

  void _onBlock() {
    final t = slang.t.settings.blockSettings;
    showAppDialog(
      AlertDialog(
        title: Text(t.blockUser),
        content: Text(t.blockUserConfirm(name: user.name)),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          FilledButton(
            onPressed: () async {
              AppService.tryPop();
              VibrateUtils.vibrate();
              await _service.blockUser(user);
              showToastWidget(
                MDToastWidget(
                  message: t.userBlocked,
                  type: MDToastType.success,
                ),
              );
            },
            child: Text(t.blockUser),
          ),
        ],
      ),
    );
  }

  Future<void> _onUnblock() async {
    VibrateUtils.vibrate();
    await _service.unblockUser(user.id);
    showToastWidget(
      MDToastWidget(
        message: slang.t.settings.blockSettings.userUnblocked,
        type: MDToastType.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t.settings.blockSettings;
    return Obx(() {
      final blocked = _service.isUserBlocked(user.id);
      if (iconOnly) {
        return ActionIconButtonScaffold(
          icon: blocked ? Icons.block : Icons.block_outlined,
          tooltip: blocked ? t.unblockUser : t.blockUser,
          label: blocked ? t.unblockUser : t.blockUser,
          selected: blocked,
          highlightColor: blocked
              ? Theme.of(context).colorScheme.error
              : null,
          onPressed: blocked ? _onUnblock : _onBlock,
        );
      }
      if (blocked) {
        return OutlinedButton.icon(
          onPressed: _onUnblock,
          icon: const Icon(Icons.block, size: 18),
          label: Text(t.unblockUser),
        );
      }
      return OutlinedButton.icon(
        onPressed: _onBlock,
        icon: const Icon(Icons.block_outlined, size: 18),
        label: Text(t.blockUser),
      );
    });
  }
}
