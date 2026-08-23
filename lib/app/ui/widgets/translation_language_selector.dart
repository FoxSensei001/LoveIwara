import 'package:flutter/material.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 通用语言选择组件
class TranslationLanguageSelector extends StatelessWidget {
  /// 若为 true，则内嵌 PopupMenu 形式显示
  final bool usePopupMenu;

  /// 若为 true，则采用紧凑模式显示（默认显示语言文本+下拉图标）
  /// 如果同时设置 [extrimCompact] 为 true，则只显示下拉图标按钮
  final bool compact;

  /// 是否采用额外紧凑模式—只显示按钮，不显示文字
  final bool extrimCompact;

  /// 当前选中的语言对象，应与 CommonConstants.translationSorts 中的项保持一致
  final dynamic selectedLanguage;

  /// 选择语言后的回调
  final ValueChanged<dynamic> onLanguageSelected;

  /// 对话框标题，可为空，默认为本地化文本
  final String? dialogTitle;

  /// 是否展示 AI 翻译的开关按钮
  final bool showAIToggle;

  const TranslationLanguageSelector({
    super.key,
    required this.onLanguageSelected,
    required this.selectedLanguage,
    this.usePopupMenu = false,
    this.compact = true,
    this.extrimCompact = false,
    this.dialogTitle,
    this.showAIToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    } else if (usePopupMenu) {
      return _buildPopupMenu(context);
    } else {
      return _buildDialogButton(context);
    }
  }

  /// 紧凑模式—显示语言文本以及下拉图标，并带有圆角；
  /// 如果 [extrimCompact] 为 true，则只显示下拉图标
  Widget _buildCompact(BuildContext context) {
    if (extrimCompact) {
      return IconButton(
        onPressed: () => _showDialogSelector(context),
        icon: Icon(
          Icons.keyboard_double_arrow_down_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => _showDialogSelector(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedLanguage.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_double_arrow_down_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// PopupMenu 方式，显示语言名称及下拉图标
  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<dynamic>(
      initialValue: selectedLanguage,
      useRootNavigator: false,
      onOpened: () {
        LogUtils.d('popup menu opened', 'TranslationLanguageSelector');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedLanguage.label,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_double_arrow_down_rounded, size: 24),
            ],
          ),
        ),
      ),
      itemBuilder: (context) {
        return CommonConstants.translationSorts.map((sort) {
          return PopupMenuItem<dynamic>(value: sort, child: Text(sort.label));
        }).toList();
      },
      onSelected: (sort) => onLanguageSelected(sort),
    );
  }

  /// 默认模式：点击后弹出对话框进行语言选择
  Widget _buildDialogButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDialogSelector(context),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedLanguage.label,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_double_arrow_down_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialogSelector(BuildContext context) {
    final t = slang.Translations.of(context);
    LogUtils.d(
      'dialog open requested: rootCanPop=${Navigator.of(context, rootNavigator: true).canPop()}, '
          'localCanPop=${Navigator.of(context).canPop()}',
      'TranslationLanguageSelector',
    );
    final screenHeight = MediaQuery.of(context).size.height;
    // 语言列表：沿用原来 maxHeight = 0.6 屏高的限高 + 自己接滚动。
    final Widget list = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: CommonConstants.translationSorts.map((sort) {
            return ListTile(
              dense: true,
              selected: sort.id == selectedLanguage.id,
              title: Text(sort.label),
              trailing: sort.id == selectedLanguage.id
                  ? const Icon(Icons.check, size: 18)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                onLanguageSelected(sort);
              },
            );
          }).toList(),
        ),
      ),
    );

    // 有 AI 翻译齿轮时标题行需要自定义（标题 + 齿轮 + 关闭），走 title:null
    // 自搭标题行；否则用 GlassAlertDialog 内建标题行。
    final Widget dialog = showAIToggle
        ? GlassAlertDialog(
            title: null,
            showCloseButton: false,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dialogTitle ?? t.common.selectTranslationLanguage,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.settings),
                      tooltip: slang.t.translation.translationSettings,
                      onPressed: () {
                        Navigator.of(context).pop();
                        NaviService.navigateToTranslationSettingsPage();
                      },
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.close),
                      tooltip: t.common.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                list,
              ],
            ),
          )
        : GlassAlertDialog(
            title: dialogTitle ?? t.common.selectTranslationLanguage,
            content: list,
          );

    // 保留 useRootNavigator: false（这处之前专门排查过该参数），并把
    // dialogContext 指到本地 context，让弹窗仍挂在本地 Navigator 上。
    showAppDialog(
      dialog,
      dialogContext: context,
      useRootNavigator: false,
    ).whenComplete(() {
      LogUtils.d('dialog closed', 'TranslationLanguageSelector');
    });
  }
}
