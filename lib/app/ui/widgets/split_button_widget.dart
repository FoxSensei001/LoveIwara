import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';

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

    // 颜色定义
    final borderColor = hasAccentColor
        ? widget.accentColor!.withValues(alpha: 0.3)
        : colorScheme.outline.withValues(alpha: 0.4);
    final backgroundColor = hasAccentColor
        ? widget.accentColor!.withValues(alpha: 0.1)
        : colorScheme.surfaceContainerHighest;
    final contentColor = isEnabled
        ? (hasAccentColor ? widget.accentColor : colorScheme.onSurface)
        : colorScheme.onSurface.withValues(alpha: 0.38);

    // 圆角定义
    const radiusValue = 20.0;

    // 边框定义
    final border = Border.all(
      color: borderColor,
      width: 1,
    );

    // 内部 Padding
    const internalPadding = EdgeInsets.symmetric(
      horizontal: UIConstants.buttonInternalPadding,
      vertical: UIConstants.smallSpacing,
    );

    return IntrinsicWidth(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radiusValue),
            border: border,
          ),
          child: InkWell(
            onTap: isEnabled ? _handleTap : null,
            borderRadius: BorderRadius.circular(radiusValue),
            child: Container(
              padding: internalPadding,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    Shimmer.fromColors(
                      baseColor: hasAccentColor
                          ? widget.accentColor!.withValues(alpha: 0.3)
                          : Colors.grey.shade300,
                      highlightColor: hasAccentColor
                          ? widget.accentColor!.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      child: Icon(widget.icon, size: 20),
                    )
                  else
                    Icon(
                      widget.icon,
                      size: 20,
                      color: contentColor,
                    ),
                  const SizedBox(width: UIConstants.iconTextSpacing),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: contentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    if (!_userService.isLogin) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.pleaseLoginFirst,
          type: MDToastType.error,
        ),
      );
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
      showToastWidget(
        MDToastWidget(
          message: errorMessage,
          type: MDToastType.error,
        ),
        position: ToastPosition.top,
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
    final Color? accentColor = isLiked ? Colors.pink : null;

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
  final List<PopupMenuEntry<String>> menuItems;
  final Function(String)? onMenuItemSelected;
  final bool isDisabled;
  final IconData? icon; // 左侧按钮的图标

  const SplitFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.menuItems,
    this.onMenuItemSelected,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isDisabled;

    // 1. 颜色定义：确保边框颜色清晰
    // 使用 outline 并提高不透明度确保可见
    final borderColor = colorScheme.outline.withValues(alpha: 0.4);
    final backgroundColor = colorScheme.surfaceContainerHighest;
    final contentColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    // 2. 圆角定义
    const radiusValue = 20.0; // 与 FilledActionButton 保持一致
    const radius = Radius.circular(radiusValue);

    // 3. 边框定义 (分离左侧和右侧的边框逻辑)
    // 左侧按钮：左、上、下 有边框
    final leftBorder = Border(
      top: BorderSide(color: borderColor, width: 1),
      bottom: BorderSide(color: borderColor, width: 1),
      left: BorderSide(color: borderColor, width: 1),
      right: BorderSide.none, // 关键：右侧无边框
    );

    // 右侧按钮：右、上、下 有边框
    final rightBorder = Border(
      top: BorderSide(color: borderColor, width: 1),
      bottom: BorderSide(color: borderColor, width: 1),
      right: BorderSide(color: borderColor, width: 1),
      left: BorderSide.none, // 关键：左侧无边框
    );

    // 内部 Padding
    const internalPadding = EdgeInsets.symmetric(
      horizontal: UIConstants.buttonInternalPadding,
      vertical: UIConstants.smallSpacing,
    );

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =======================
          // 1. 左侧：主操作按钮
          // =======================
          // 使用 Material 确保 InkWell 正确渲染
          Material(
            color: Colors.transparent, // 背景由内部 Container 负责
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: radius,
                  bottomLeft: radius,
                ),
                border: leftBorder, // 显式绘制边框
              ),
              child: InkWell(
                onTap: isEnabled ? onPressed : null,
                // 修复 Hover 溢出：告诉 InkWell 它的形状
                borderRadius: const BorderRadius.only(
                  topLeft: radius,
                  bottomLeft: radius,
                ),
                child: Container(
                  padding: internalPadding,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: contentColor,
                        ),
                        const SizedBox(width: UIConstants.iconTextSpacing),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: contentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =======================
          // 2. 中间：分割线
          // =======================
          Container(
            width: 1,
            color: borderColor,
          ),

          // =======================
          // 3. 右侧：下拉菜单按钮
          // =======================
          // 修复 Hover 溢出：将 ClipRRect 放在最外层，包裹整个右侧区域
          // 这样 PopupMenuButton 内部的方形水波纹就会被切成圆角
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: radius,
              bottomRight: radius,
            ),
            clipBehavior: Clip.antiAlias, // 确保裁剪生效
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias, // Material 也启用裁剪
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topRight: radius,
                    bottomRight: radius,
                  ),
                  border: rightBorder, // 显式绘制边框
                ),
                child: PopupMenuButton<String>(
                  tooltip: '',
                  enabled: isEnabled,
                  offset: const Offset(0, 48),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) => menuItems,
                  onSelected: onMenuItemSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // 使用 child 自定义触发区域
                  child: Container(
                    // 水平 Padding 稍微调小一点，视觉更紧凑
                    padding: internalPadding.copyWith(left: 10, right: 14),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: contentColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

