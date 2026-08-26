import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 通用语言选择组件（翻译目标语言）。
///
/// # 三种触发位，一张面板
///
/// 三个旗标（[usePopupMenu] / [compact] / [extrimCompact]）现在只决定**触发位
/// 长什么样**，点开来的一律是同一张玻璃菜单（[showGlassMenu]）。
///
/// 此前不是这样：`extrimCompact`（评论行、简介行、正文行上那枚小箭头，也就是
/// 视频详情页上能看到的那个）点开的是一张**居中对话框**，里头 15 条
/// `ListTile` 自己接滚动、自己画选中态，标题行还塞了齿轮和关闭键——为了「换个
/// 语言」这件事盖掉半个屏幕。而隔壁 `usePopupMenu` 点开的又是 Material 的
/// `PopupMenuButton`。同一个组件、同一件事，三种模式三种观感。
///
/// 现在统一成贴着触发位弹出的玻璃面板：选中态走 [GlassMenuOption.selected]
/// （主色 + 对勾），标题走 [GlassMenuSectionHeader]，原来标题行里的翻译设置
/// 齿轮降成面板末尾分隔线下的一条。长按不抬手直接划到某一条上松手选中那条也
/// 一并有了（见 [GlassTapArea.opensOverlay]）。
class TranslationLanguageSelector extends StatelessWidget {
  /// 触发位用「文字 + 下拉箭头」的胶囊（与 [compact] 为假时同款）。
  final bool usePopupMenu;

  /// 紧凑模式：显示语言文本 + 下拉图标。同时给 [extrimCompact] 则只剩图标。
  final bool compact;

  /// 极紧凑：只有一枚下拉箭头，尺寸完全交给父级的槽位。
  final bool extrimCompact;

  /// 当前选中的语言对象，应与 [CommonConstants.translationSorts] 中的项保持一致。
  final dynamic selectedLanguage;

  /// 选择语言后的回调。
  final ValueChanged<dynamic> onLanguageSelected;

  /// 面板顶部的小标题，为空时用本地化文案。
  final String? dialogTitle;

  /// 面板末尾是否给一条「翻译设置」入口。
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

  /// 「翻译设置」那一条的 value。语言用下标，它用 -1。
  static const int _settingsValue = -1;

  @override
  Widget build(BuildContext context) {
    // Builder：面板的落点与材质档位都从触发位自身的 context 量出来。
    return Builder(
      builder: (anchorContext) => compact && extrimCompact
          ? _buildIconTrigger(anchorContext)
          : _buildPillTrigger(anchorContext),
    );
  }

  /// 极紧凑触发位：一枚箭头。
  ///
  /// 尺寸只给**下限**：调用方给了紧约束（评论 / 简介 / 论坛那三行都套着
  /// `SizedBox(34, 胶囊高)`）就听它的，没给（正文行是直接摆在 Row 里）才自己
  /// 撑到标准触摸目标——原来那里是枚 `IconButton`，48 的触摸区是它给的，换成
  /// 无尺寸的 [GlassPressable] 会缩成一枚 20px 的图标。
  ///
  /// 那三处调用点原本还各套着一层 `IconButtonTheme` 把 48 的触摸目标压回胶囊
  /// 高度，现在不需要了，已一并删掉。
  Widget _buildIconTrigger(BuildContext anchorContext) {
    final Color color = Theme.of(anchorContext).colorScheme.primary;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      ),
      child: GlassPressable(
        // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条
        // 上松手选中（见 GlassTapArea.opensOverlay）。
        opensOverlay: true,
        onTap: () => _openMenu(anchorContext),
        builder: (context, pressed) => Center(
          child: Icon(
            Icons.keyboard_double_arrow_down_rounded,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  /// 「文字 + 箭头」的胶囊触发位。
  ///
  /// 走 [GlassSurface] 而不是原来的 `Card(elevation: 1)`：这枚键常常待在弹窗里
  /// （翻译弹窗的语言切换），而弹窗自 2026-08-24 起在路由层供液态档——用 Card
  /// 的话它是全场唯一一块不跟着走的实心板。
  Widget _buildPillTrigger(BuildContext anchorContext) {
    final cs = Theme.of(anchorContext).colorScheme;
    return GlassSurface(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      opensOverlay: true,
      onTap: () => _openMenu(anchorContext),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedLanguage.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_double_arrow_down_rounded,
            size: GlassTokens.iconSize,
            color: cs.onSurface,
          ),
        ],
      ),
    );
  }

  Future<void> _openMenu(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    const List<Sort> sorts = CommonConstants.translationSorts;
    final int? picked = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuSectionHeader(
          dialogTitle ?? t.common.selectTranslationLanguage,
        ),
        for (var i = 0; i < sorts.length; i++)
          GlassMenuOption<int>(
            value: i,
            label: sorts[i].label,
            selected: sorts[i].id == selectedLanguage.id,
          ),
        // 原来这枚齿轮挤在对话框标题行里，跟关闭键并排。它是「去别处」的入口，
        // 不是候选语言，所以放到分隔线之下、面板末尾。
        if (showAIToggle) ...[
          const GlassMenuSeparator(),
          GlassMenuOption<int>(
            value: _settingsValue,
            icon: Icons.settings,
            label: slang.t.translation.translationSettings,
          ),
        ],
      ],
    );

    if (picked == null) return;
    if (picked == _settingsValue) {
      NaviService.navigateToTranslationSettingsPage();
      return;
    }
    onLanguageSelected(sorts[picked]);
  }
}
