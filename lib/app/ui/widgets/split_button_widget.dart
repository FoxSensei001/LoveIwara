import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// 操作栏按钮的胶囊高度：比 GlassTokens.pillHeight（44，独立浮动控件用）矮一档，
/// 适配一排并列的密集操作按钮，避免整行显得过大。
const double _kActionPillHeight = 32.0;

/// 统一的填充按钮组件，基于 SplitFilledButton 的设计
/// 确保所有按钮具有相同的高度和样式
class FilledActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? accentColor;

  const FilledActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.accentColor,
  });

  @override
  State<FilledActionButton> createState() => _FilledActionButtonState();
}

class _FilledActionButtonState extends State<FilledActionButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading || widget.isLoading || widget.onTap == null) return;

    // 添加震动反馈
    VibrateUtils.vibrate();

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 100)); // 模拟异步操作
      widget.onTap?.call();
    } catch (e) {
      // 错误处理
      LogUtils.e('操作按钮执行失败: $e', tag: 'FilledActionButton');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = _isLoading || widget.isLoading;
    final isEnabled = widget.onTap != null && !isLoading;
    final hasAccentColor = widget.accentColor != null;

    // 液态玻璃胶囊：容器统一走 GlassSurface（半透明底色 + 细描边 + 投影 + 按下缩放），
    // 仅在有 accentColor 时（如已点赞）给图标/文字上色，容器底色保持一致。
    final contentColor = isEnabled
        ? (hasAccentColor ? widget.accentColor! : colorScheme.onSurface)
        : colorScheme.onSurface.withValues(alpha: 0.38);

    return GlassSurface(
      height: _kActionPillHeight,
      elevated: false,
      onTap: isEnabled ? _handleTap : null,
      // Material 图标的字形在其量框内自带留白，跟文字比"视觉上"更靠内，
      // 左右用同样的 padding 会显得图标离左边更远——左侧少留 2dp 做光学补偿。
      padding: const EdgeInsets.only(
        left: UIConstants.buttonInternalPadding - 2,
        right: UIConstants.buttonInternalPadding + 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            Shimmer.fromColors(
              baseColor: hasAccentColor
                  ? widget.accentColor!.withValues(alpha: 0.3)
                  : colorScheme.onSurface.withValues(alpha: 0.3),
              highlightColor: hasAccentColor
                  ? widget.accentColor!.withValues(alpha: 0.1)
                  : colorScheme.onSurface.withValues(alpha: 0.1),
              child: Icon(widget.icon, size: 16),
            )
          else
            Icon(widget.icon, size: 16, color: contentColor),
          const SizedBox(width: UIConstants.iconTextSpacing),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              color: contentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 基于 FilledActionButton 的点赞按钮组件
/// 提取了点赞逻辑，使用统一的按钮样式
class FilledLikeButton extends StatefulWidget {
  final String mediaId;
  final bool? liked;
  final int likeCount;
  final Future<bool> Function(String mediaId) onLike;
  final Future<bool> Function(String mediaId) onUnlike;
  final Function(bool liked)? onLikeChanged;

  const FilledLikeButton({
    super.key,
    required this.mediaId,
    required this.liked,
    required this.likeCount,
    required this.onLike,
    required this.onUnlike,
    this.onLikeChanged,
  });

  @override
  State<FilledLikeButton> createState() => _FilledLikeButtonState();
}

class _FilledLikeButtonState extends State<FilledLikeButton> {
  bool _isLoading = false;
  late bool? _isLiked;
  late int _likeCount;
  final UserService _userService = Get.find();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.liked;
    _likeCount = widget.likeCount;
  }

  @override
  void didUpdateWidget(FilledLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liked != widget.liked) {
      _isLiked = widget.liked;
    }
    if (oldWidget.likeCount != widget.likeCount) {
      _likeCount = widget.likeCount;
    }
  }

  Future<void> _handleLikeToggle() async {
    if (_isLoading) return;
    // 如果 liked 为 null，说明正在加载状态，不允许操作
    if (_isLiked == null) return;
    if (!_userService.isAuthenticated) {
      showGlassToast(t.errors.pleaseLoginFirst, type: GlassToastType.error);
      LoginService.showLogin();
      return;
    }

    VibrateUtils.vibrate();

    setState(() {
      _isLoading = true;
    });

    try {
      final bool success = _isLiked!
          ? await widget.onUnlike(widget.mediaId)
          : await widget.onLike(widget.mediaId);

      if (success) {
        setState(() {
          _isLiked = !_isLiked!;
          _likeCount += _isLiked! ? 1 : -1;
        });
        widget.onLikeChanged?.call(_isLiked!);
      }
    } catch (e) {
      // 使用 CommonUtils.parseExceptionMessage 来获取详细的错误信息
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      showGlassToast(
        errorMessage,
        type: GlassToastType.error,
        position: GlassToastPosition.top,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果 liked 为 null，显示 loading 状态
    final bool isLoadingState = _isLiked == null || _isLoading;
    final bool isLiked = _isLiked == true;
    final Color? accentColor = isLiked
        ? Theme.of(context).colorScheme.error
        : null;

    return FilledActionButton(
      icon: isLiked ? Icons.favorite : Icons.favorite_border,
      label: _likeCount.toString(),
      onTap: isLoadingState ? null : _handleLikeToggle,
      isLoading: isLoadingState,
      accentColor: accentColor,
    );
  }
}

/// Split Button 组件，左侧主按钮，右侧下拉菜单
/// 复现 Ant Design Space.Compact 效果
class SplitFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final List<GlassMenuEntry> menuItems;
  final Function(String)? onMenuItemSelected;
  final bool isDisabled;
  final IconData? icon; // 左侧按钮的图标
  final Color? accentColor; // 高亮颜色，用于已下载等状态
  final bool isPrimary; // 主操作样式（用于强调关键按钮）

  const SplitFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.menuItems,
    this.onMenuItemSelected,
    this.isDisabled = false,
    this.icon,
    this.accentColor,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isDisabled;
    final hasAccentColor = accentColor != null;

    // 液态玻璃：外层单个 GlassSurface（不挂 onTap）承载底色/描边/投影，
    // 左右两段各自用 GlassPressable 处理点击反馈——与 GlassSegmentedControl
    // 的分段结构同一套写法。
    final defaultContentColor = isPrimary ? colorScheme.primary : colorScheme.onSurface;
    final contentColor = isEnabled
        ? (hasAccentColor ? accentColor! : defaultContentColor)
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final dividerColor = GlassTokens.stroke(colorScheme);
    final pressedOverlay = colorScheme.onSurface.withValues(alpha: 0.06);

    // 内部 Padding
    // 左侧图标+文字段用左右不对称 padding：Material 图标字形自带留白，
    // 跟文字比"视觉上"更靠内，同样的 padding 会显得图标离左边更远。
    const internalPadding = EdgeInsets.only(
      left: UIConstants.buttonInternalPadding - 2,
      right: UIConstants.buttonInternalPadding + 2,
      top: UIConstants.smallSpacing,
      bottom: UIConstants.smallSpacing,
    );

    return GlassSurface(
      height: _kActionPillHeight,
      elevated: false,
      clipContent: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =======================
          // 1. 左侧：主操作按钮
          // =======================
          GlassPressable(
            scale: 0.97,
            onTap: isEnabled ? onPressed : null,
            builder: (context, pressed) => AnimatedContainer(
              duration: GlassTokens.pressDuration,
              curve: Curves.easeOut,
              color: pressed ? pressedOverlay : Colors.transparent,
              padding: internalPadding,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: contentColor),
                    const SizedBox(width: UIConstants.iconTextSpacing),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =======================
          // 2. 中间：分割线
          // =======================
          Container(width: 0.6, height: _kActionPillHeight * 0.5, color: dividerColor),

          // =======================
          // 3. 右侧：下拉菜单按钮
          // =======================
          // 菜单走全站统一的玻璃面板（原来是 PopupMenuButton：一层透明 Material
          // 撑着水波纹、吐出一块不透明卡片）。
          Builder(
            builder: (anchorContext) => GlassPressable(
              enabled: isEnabled,
              // 长按也能打开，且长按不抬手可以直接划到某一条上松手选中
              // （见 GlassTapArea.opensOverlay）。
              opensOverlay: true,
              scale: 1.0,
              onTap: () async {
                final picked = await showGlassMenu<String>(
                  anchorContext: anchorContext,
                  entries: menuItems,
                );
                if (picked != null) onMenuItemSelected?.call(picked);
              },
              builder: (context, pressed) => AnimatedContainer(
                duration: GlassTokens.pressDuration,
                curve: Curves.easeOut,
                color: pressed ? pressedOverlay : Colors.transparent,
                // 水平 Padding 稍微调小一点，视觉更紧凑
                padding: internalPadding.copyWith(left: 8, right: 12),
                alignment: Alignment.center,
                child: Icon(Icons.more_horiz, size: 16, color: contentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
