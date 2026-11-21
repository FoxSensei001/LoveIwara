import 'package:material_ui/material_ui.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 发起下载的弹窗/底部面板标题行里的「去下载管理」快捷钮。
///
/// 和「去下载设置」一起用 [downloadDialogShortcutButtons] 摆放。
///
/// 点下去先关掉所在弹层再跳下载列表页：不关的话，弹层挂在 root navigator
/// 上，会盖在刚 push 出来的下载页上面。
///
/// 关弹层用的是**本钮自己的 context**（它长在弹层的路由里，`Navigator.of`
/// 找到的就是承载这张弹层的那个 navigator），而不是调用点的 context——
/// 调用点多半在某个 shell 的嵌套 navigator 里，拿它去 pop 会退掉调用它的
/// 那一页，弹层纹丝不动。
class DownloadManagerShortcutButton extends StatelessWidget {
  const DownloadManagerShortcutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // group: false —— 单独一枚圆钮，与弹窗关闭钮同一做法。
    return GlassChromeLayer(
      group: false,
      child: GlassIconButton(
        standalone: true,
        icon: const Icon(Icons.download_for_offline_outlined),
        tooltip: t.download.viewDownloadList,
        onPressed: () {
          Navigator.of(context).pop();
          NaviService.navigateToDownloadTaskListPage();
        },
      ),
    );
  }
}

/// 同一行里的「去下载设置」快捷钮：改保存位置、命名规则这些，不用先退出弹窗
/// 再去设置里翻。关弹层的做法与 [DownloadManagerShortcutButton] 相同。
class DownloadSettingsShortcutButton extends StatelessWidget {
  const DownloadSettingsShortcutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassChromeLayer(
      group: false,
      child: GlassIconButton(
        standalone: true,
        icon: const Icon(Icons.settings_outlined),
        tooltip: t.settings.downloadSettings.downloadSettings,
        onPressed: () {
          Navigator.of(context).pop();
          NaviService.navigateToDownloadSettingsPage();
        },
      ),
    );
  }
}

/// 下载弹窗标题行右侧那一组快捷钮，三个发起下载的弹窗共用这一份顺序。
const List<Widget> downloadDialogShortcutButtons = [
  DownloadSettingsShortcutButton(),
  DownloadManagerShortcutButton(),
];
