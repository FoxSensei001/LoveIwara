// lib/app/ui/widgets/grid_speed_dial.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedChild extends AnimatedWidget {
  final int? index;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Size buttonSize;
  final Widget? child;
  final Key? btnKey;

  final Widget? labelWidget;

  final bool visible;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? toggleChildren;
  final ShapeBorder? shape;
  final String? heroTag;
  final bool useColumn;
  final bool switchLabelPosition;
  final EdgeInsets? margin;

  final EdgeInsets childMargin;
  final EdgeInsets childPadding;

  const AnimatedChild({
    super.key,
    this.btnKey,
    required Animation<double> animation,
    this.index,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.buttonSize = const Size(56.0, 56.0),
    this.child,
    this.labelWidget,
    this.visible = true,
    this.onTap,
    required this.switchLabelPosition,
    required this.useColumn,
    required this.margin,
    this.onLongPress,
    this.toggleChildren,
    this.shape,
    this.heroTag,
    required this.childMargin,
    required this.childPadding,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    bool dark = Theme.of(context).brightness == Brightness.dark;

    void performAction([bool isLong = false]) {
      if (onTap != null && !isLong) {
        onTap!();
      } else if (onLongPress != null && isLong) {
        onLongPress!();
      }
      toggleChildren!();
    }

    Widget buildLabel() {
      if (labelWidget == null) return Container();

      return GestureDetector(
        onTap: performAction,
        onLongPress: onLongPress == null ? null : () => performAction(true),
        child: labelWidget,
      );
    }

    Widget button = ScaleTransition(
      scale: animation,
      child: FloatingActionButton(
        key: btnKey,
        heroTag: heroTag,
        onPressed: performAction,
        backgroundColor:
            backgroundColor ?? (dark ? Colors.grey[800] : Colors.grey[50]),
        foregroundColor:
            foregroundColor ?? (dark ? Colors.white : Colors.black),
        elevation: elevation ?? 6.0,
        shape: shape,
        child: child,
      ),
    );

    List<Widget> children = [
      if (labelWidget != null)
        ScaleTransition(
          scale: animation,
          child: Container(
            padding: (child == null)
                ? const EdgeInsets.symmetric(vertical: 8)
                : null,
            key: (child == null) ? btnKey : null,
            child: buildLabel(),
          ),
        ),
      if (child != null)
        Container(
          padding: childPadding,
          height: buttonSize.height,
          width: buttonSize.width,
          child: (onLongPress == null)
              ? button
              : FittedBox(
                  child: GestureDetector(
                    onLongPress: () => performAction(true),
                    child: button,
                  ),
                ),
        ),
    ];

    Widget buildColumnOrRow(
      bool isColumn, {
      CrossAxisAlignment? crossAxisAlignment,
      MainAxisAlignment? mainAxisAlignment,
      required List<Widget> children,
      MainAxisSize? mainAxisSize,
    }) {
      return isColumn
          ? Column(
              mainAxisSize: mainAxisSize ?? MainAxisSize.max,
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
              crossAxisAlignment:
                  crossAxisAlignment ?? CrossAxisAlignment.center,
              children: children,
            )
          : Row(
              mainAxisSize: mainAxisSize ?? MainAxisSize.max,
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
              crossAxisAlignment:
                  crossAxisAlignment ?? CrossAxisAlignment.center,
              children: children,
            );
    }

    return visible
        ? Container(
            margin: margin,
            child: buildColumnOrRow(
              useColumn,
              mainAxisSize: MainAxisSize.min,
              children: switchLabelPosition
                  ? children.reversed.toList()
                  : children,
            ),
          )
        : Container();
  }
}

class AnimatedFloatingButton extends StatefulWidget {
  final bool visible;
  final VoidCallback? callback;
  final VoidCallback? onLongPress;
  final Widget? label;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final String? heroTag;
  final double elevation;
  final Size size;
  final ShapeBorder shape;
  final Curve curve;
  final Widget? dialRoot;
  final bool useInkWell;
  final bool mini;

  const AnimatedFloatingButton({
    Key? key,
    this.visible = true,
    this.callback,
    this.label,
    required this.mini,
    this.child,
    this.dialRoot,
    this.useInkWell = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.heroTag,
    this.elevation = 6.0,
    this.size = const Size(56.0, 56.0),
    this.shape = const CircleBorder(),
    this.curve = Curves.fastOutSlowIn,
    this.onLongPress,
  }) : super(key: key);

  @override
  State createState() => _AnimatedFloatingButtonState();
}

class _AnimatedFloatingButtonState extends State<AnimatedFloatingButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.dialRoot == null
        ? AnimatedContainer(
            curve: widget.curve,
            duration: const Duration(milliseconds: 150),
            height: widget.visible
                ? widget.mini
                      ? 40
                      : widget.size.height
                : 0,
            child: FittedBox(
              child: GestureDetector(
                onLongPress: widget.onLongPress,
                child: widget.label != null
                    ? FloatingActionButton.extended(
                        icon: widget.visible ? widget.child : null,
                        label: widget.visible
                            ? widget.label!
                            : const SizedBox.shrink(),
                        shape: widget.shape is CircleBorder
                            ? const StadiumBorder()
                            : widget.shape,
                        backgroundColor: widget.backgroundColor,
                        foregroundColor: widget.foregroundColor,
                        onPressed: widget.callback,
                        tooltip: widget.tooltip,
                        heroTag: widget.heroTag,
                        elevation: widget.elevation,
                        highlightElevation: widget.elevation,
                      )
                    : FloatingActionButton(
                        mini: widget.mini,
                        shape: widget.shape,
                        backgroundColor: widget.backgroundColor,
                        foregroundColor: widget.foregroundColor,
                        onPressed: widget.callback,
                        tooltip: widget.tooltip,
                        heroTag: widget.heroTag,
                        elevation: widget.elevation,
                        highlightElevation: widget.elevation,
                        child: widget.visible ? widget.child : null,
                      ),
              ),
            ),
          )
        : AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: widget.curve,
            child: Container(
              child: widget.visible
                  ? widget.dialRoot
                  : const SizedBox(height: 0, width: 0),
            ),
          );
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null) {
      return renderObject!.paintBounds.shift(
        Offset(translation.x, translation.y),
      );
    } else {
      return null;
    }
  }

}

class BackgroundOverlay extends AnimatedWidget {
  final Color color;
  final double opacity;
  final GlobalKey dialKey;
  final LayerLink layerLink;
  final ShapeBorder shape;
  final VoidCallback? onTap;
  final bool closeManually;
  final String? tooltip;

  const BackgroundOverlay({
    super.key,
    this.onTap,
    required this.shape,
    required Animation<double> animation,
    required this.dialKey,
    required this.layerLink,
    required this.closeManually,
    required this.tooltip,
    this.color = Colors.white,
    this.opacity = 0.7,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        color.withOpacity(opacity * animation.value),
        BlendMode.srcOut,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: closeManually ? null : onTap,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                backgroundBlendMode: BlendMode.dstOut,
              ),
            ),
          ),
          Positioned(
            width: dialKey.globalPaintBounds?.size.width,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: () {
                  final Widget child = GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: dialKey.globalPaintBounds?.size.width,
                      height: dialKey.globalPaintBounds?.size.height,
                      decoration: ShapeDecoration(
                        shape: shape == const CircleBorder()
                            ? const StadiumBorder()
                            : shape,
                        color: Colors.white,
                      ),
                    ),
                  );
                  return tooltip != null && tooltip!.isNotEmpty
                      ? Tooltip(message: tooltip!, child: child)
                      : child;
                }(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 提供 speed dial 子按钮的数据
class SpeedDialChild {
  /// speed dial 子按钮的 key。
  final Key? key;

  /// 如果提供此项，将替换默认的 widget
  final Widget? labelWidget;

  /// 该 `SpeedDialChild` 的子 widget
  final Widget? child;

  /// 该 `SpeedDialChild` 的背景色
  final Color? backgroundColor;

  /// 该 `SpeedDialChild` 的前景色
  final Color? foregroundColor;

  /// 该 `SpeedDialChild` 的阴影强度
  final double? elevation;

  /// 点击该 `SpeedDialChild` 后执行的操作
  final VoidCallback? onTap;

  /// 长按该 `SpeedDialChild` 后执行的操作
  final VoidCallback? onLongPress;

  /// 该 `SpeedDialChild` 的形状
  final ShapeBorder? shape;

  /// 该 `SpeedDialChild` 是否可见
  final bool visible;

  SpeedDialChild({
    this.key,
    this.labelWidget,
    this.child,
    this.visible = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.shape,
  });
}

enum SpeedDialDirection { up, down, left, right }

extension EnumExtension on SpeedDialDirection {
  bool get isDown => this == SpeedDialDirection.down;

  bool get isUp => this == SpeedDialDirection.up;

  bool get isLeft => this == SpeedDialDirection.left;

  bool get isRight => this == SpeedDialDirection.right;
}

typedef AsyncChildrenBuilder =
    Future<List<SpeedDialChild>> Function(BuildContext context);

/// 一个自定义的 SpeedDial 组件，支持子按钮的网格布局。
class GridSpeedDial extends StatefulWidget {
  /// 子按钮，二维数组，用于定义网格布局。
  /// 外层列表的每个元素代表一列，内层列表包含该列中的按钮。
  final List<List<SpeedDialChild>> childrens;

  /// 用于在滚动时隐藏按钮。详见示例。
  final bool visible;

  /// 用于滚动时按钮动画的曲线。
  final Curve curve;

  final String? tooltip;
  final String? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? activeBackgroundColor;
  final Color? activeForegroundColor;
  final double elevation;
  final Size buttonSize;
  final Size childrenButtonSize;
  final ShapeBorder shape;
  final Gradient? gradient;
  final BoxShape gradientBoxShape;
  final bool isOpenOnStart;
  final bool closeDialOnPop;
  final Color? overlayColor;
  final double overlayOpacity;
  final AnimatedIconData? animatedIcon;
  final IconThemeData? animatedIconTheme;
  final IconData? icon;
  final IconData? activeIcon;
  final bool useRotationAnimation;
  final double animationAngle;
  final IconThemeData? iconTheme;
  final Widget? label;
  final Widget? activeLabel;
  final Widget Function(Widget, Animation<double>)? labelTransitionBuilder;
  final AsyncChildrenBuilder? onOpenBuilder;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final VoidCallback? onPress;
  final bool closeManually;
  final bool renderOverlay;
  final ValueNotifier<bool>? openCloseDial;
  final Duration animationDuration;
  final EdgeInsets childMargin;
  final EdgeInsets childPadding;
  final double? spacing;
  final double? spaceBetweenChildren;
  final SpeedDialDirection direction;
  final Widget Function(
    BuildContext context,
    bool open,
    VoidCallback toggleChildren,
  )?
  dialRoot;
  final Widget? child;
  final Widget? activeChild;
  final bool switchLabelPosition;
  final Curve? animationCurve;
  final bool mini;

  const GridSpeedDial({
    super.key,
    this.childrens = const [],
    this.visible = true,
    this.backgroundColor,
    this.foregroundColor,
    this.activeBackgroundColor,
    this.activeForegroundColor,
    this.gradient,
    this.gradientBoxShape = BoxShape.rectangle,
    this.elevation = 6.0,
    this.buttonSize = const Size(56.0, 56.0),
    this.childrenButtonSize = const Size(56.0, 56.0),
    this.dialRoot,
    this.mini = false,
    this.overlayOpacity = 0.8,
    this.overlayColor,
    this.tooltip,
    this.heroTag,
    this.animatedIcon,
    this.animatedIconTheme,
    this.icon,
    this.activeIcon,
    this.child,
    this.activeChild,
    this.switchLabelPosition = false,
    this.useRotationAnimation = true,
    this.animationAngle = pi / 2,
    this.iconTheme,
    this.label,
    this.activeLabel,
    this.labelTransitionBuilder,
    this.onOpenBuilder,
    this.onOpen,
    this.onClose,
    this.direction = SpeedDialDirection.up,
    this.closeManually = false,
    this.renderOverlay = true,
    this.shape = const StadiumBorder(),
    this.curve = Curves.fastOutSlowIn,
    this.onPress,
    this.animationDuration = const Duration(milliseconds: 150),
    this.openCloseDial,
    this.isOpenOnStart = false,
    this.closeDialOnPop = true,
    this.childMargin = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    this.childPadding = const EdgeInsets.symmetric(vertical: 5),
    this.spaceBetweenChildren,
    this.spacing,
    this.animationCurve,
  });

  @override
  State createState() => _GridSpeedDialState();
}

class _GridSpeedDialState extends State<GridSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.animationDuration,
    vsync: this,
  );
  bool _open = false;
  OverlayEntry? overlayEntry;
  OverlayEntry? backgroundOverlay;
  final LayerLink _layerLink = LayerLink();
  final dialKey = GlobalKey<State<StatefulWidget>>();

  @override
  void initState() {
    super.initState();
    widget.openCloseDial?.addListener(_onOpenCloseDial);
    Future.delayed(Duration.zero, () async {
      if (mounted && widget.isOpenOnStart) _toggleChildren();
    });
  }

  @override
  void dispose() {
    if (overlayEntry != null) {
      if (overlayEntry!.mounted) overlayEntry!.remove();
      overlayEntry!.dispose();
    }
    if (widget.renderOverlay && backgroundOverlay != null) {
      if (backgroundOverlay!.mounted) backgroundOverlay!.remove();
      backgroundOverlay!.dispose();
    }
    _controller.dispose();
    widget.openCloseDial?.removeListener(_onOpenCloseDial);
    super.dispose();
  }

  @override
  void didUpdateWidget(GridSpeedDial oldWidget) {
    if (oldWidget.childrens.expand((e) => e).length !=
        widget.childrens.expand((e) => e).length) {
      _controller.duration = widget.animationDuration;
    }

    widget.openCloseDial?.removeListener(_onOpenCloseDial);
    widget.openCloseDial?.addListener(_onOpenCloseDial);
    super.didUpdateWidget(oldWidget);
  }

  void _onOpenCloseDial() {
    final show = widget.openCloseDial?.value;
    if (!mounted) return;
    if (_open != show) {
      _toggleChildren();
    }
  }

  void _toggleChildren() async {
    if (!mounted) return;

    final opening = !_open;
    if (opening && widget.onOpenBuilder != null) {
      // This part needs to be adapted if onOpenBuilder is used with the new structure.
      // For now, assuming it's not used or will be adapted by the user.
      // final newChildrens = await widget.onOpenBuilder!(context);
      // widget.childrens.clear();
      // widget.childrens.addAll(newChildrens);
    }

    if (widget.childrens.expand((e) => e).isNotEmpty) {
      toggleOverlay();
      widget.openCloseDial?.value = opening;
      opening ? widget.onOpen?.call() : widget.onClose?.call();
    } else {
      widget.onOpen?.call();
    }
  }

  toggleOverlay() {
    if (_open) {
      _controller.reverse().whenComplete(() {
        overlayEntry?.remove();
        if (widget.renderOverlay &&
            backgroundOverlay != null &&
            backgroundOverlay!.mounted) {
          backgroundOverlay?.remove();
        }
      });
    } else {
      if (_controller.isAnimating) {
        return;
      }
      overlayEntry = OverlayEntry(
        builder: (ctx) => _ChildrensOverlay(
          widget: widget,
          dialKey: dialKey,
          layerLink: _layerLink,
          controller: _controller,
          toggleChildren: _toggleChildren,
          animationCurve: widget.animationCurve,
        ),
      );
      if (widget.renderOverlay) {
        backgroundOverlay = OverlayEntry(
          builder: (ctx) {
            bool dark = Theme.of(ctx).brightness == Brightness.dark;
            return BackgroundOverlay(
              dialKey: dialKey,
              layerLink: _layerLink,
              closeManually: widget.closeManually,
              tooltip: widget.tooltip,
              shape: widget.shape,
              onTap: _toggleChildren,
              animation: _controller,
              color:
                  widget.overlayColor ??
                  (dark ? Colors.grey[900] : Colors.white)!,
              opacity: widget.overlayOpacity,
            );
          },
        );
      }

      if (!mounted) return;

      _controller.forward();
      if (widget.renderOverlay) Overlay.of(context).insert(backgroundOverlay!);
      Overlay.of(context).insert(overlayEntry!);
    }

    if (!mounted) return;
    setState(() {
      _open = !_open;
    });
  }

  Widget _renderButton() {
    var child = widget.animatedIcon != null
        ? Container(
            decoration: BoxDecoration(
              shape: widget.gradientBoxShape,
              gradient: widget.gradient,
            ),
            child: Center(
              child: AnimatedIcon(
                icon: widget.animatedIcon!,
                progress: _controller,
                color: widget.animatedIconTheme?.color,
                size: widget.animatedIconTheme?.size,
              ),
            ),
          )
        : AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) => Transform.rotate(
              angle:
                  (widget.activeChild != null || widget.activeIcon != null) &&
                      widget.useRotationAnimation
                  ? _controller.value * widget.animationAngle
                  : 0,
              child: AnimatedSwitcher(
                duration: widget.animationDuration,
                child: (widget.child != null && _controller.value < 0.4)
                    ? widget.child
                    : (widget.activeIcon == null &&
                              widget.activeChild == null ||
                          _controller.value < 0.4)
                    ? Container(
                        decoration: BoxDecoration(
                          shape: widget.gradientBoxShape,
                          gradient: widget.gradient,
                        ),
                        child: Center(
                          child: widget.icon != null
                              ? Icon(
                                  widget.icon,
                                  key: const ValueKey<int>(0),
                                  color: widget.iconTheme?.color,
                                  size: widget.iconTheme?.size,
                                )
                              : widget.child,
                        ),
                      )
                    : Transform.rotate(
                        angle: widget.useRotationAnimation ? -pi * 1 / 2 : 0,
                        child:
                            widget.activeChild ??
                            Container(
                              decoration: BoxDecoration(
                                shape: widget.gradientBoxShape,
                                gradient: widget.gradient,
                              ),
                              child: Center(
                                child: Icon(
                                  widget.activeIcon,
                                  key: const ValueKey<int>(1),
                                  color: widget.iconTheme?.color,
                                  size: widget.iconTheme?.size,
                                ),
                              ),
                            ),
                      ),
              ),
            ),
          );

    var label = AnimatedSwitcher(
      duration: widget.animationDuration,
      transitionBuilder:
          widget.labelTransitionBuilder ??
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child: (!_open || widget.activeLabel == null)
          ? widget.label
          : widget.activeLabel,
    );

    final backgroundColorTween = ColorTween(
      begin: widget.backgroundColor,
      end: widget.activeBackgroundColor ?? widget.backgroundColor,
    );
    final foregroundColorTween = ColorTween(
      begin: widget.foregroundColor,
      end: widget.activeForegroundColor ?? widget.foregroundColor,
    );

    var animatedFloatingButton = AnimatedBuilder(
      animation: _controller,
      builder: (context, ch) => CompositedTransformTarget(
        link: _layerLink,
        key: dialKey,
        child: AnimatedFloatingButton(
          visible: widget.visible,
          tooltip: widget.tooltip,
          mini: widget.mini,
          dialRoot: widget.dialRoot != null
              ? widget.dialRoot!(context, _open, _toggleChildren)
              : null,
          backgroundColor: widget.backgroundColor != null
              ? backgroundColorTween.lerp(_controller.value)
              : null,
          foregroundColor: widget.foregroundColor != null
              ? foregroundColorTween.lerp(_controller.value)
              : null,
          elevation: widget.elevation,
          onLongPress: _toggleChildren,
          callback: (_open || widget.onPress == null)
              ? _toggleChildren
              : widget.onPress,
          size: widget.buttonSize,
          label: widget.label != null ? label : null,
          heroTag: widget.heroTag,
          shape: widget.shape,
          child: child,
        ),
      ),
    );

    return animatedFloatingButton;
  }

  @override
  Widget build(BuildContext context) {
    return (kIsWeb || !Platform.isIOS) && widget.closeDialOnPop
        ? WillPopScope(
            child: _renderButton(),
            onWillPop: () async {
              if (_open) {
                _toggleChildren();
                return false;
              }
              return true;
            },
          )
        : _renderButton();
  }
}

class _ChildrensOverlay extends StatelessWidget {
  const _ChildrensOverlay({
    super.key,
    required this.widget,
    required this.layerLink,
    required this.dialKey,
    required this.controller,
    required this.toggleChildren,
    this.animationCurve,
  });

  final GridSpeedDial widget;
  final GlobalKey<State<StatefulWidget>> dialKey;
  final LayerLink layerLink;
  final AnimationController controller;
  final Function toggleChildren;
  final Curve? animationCurve;

  List<Widget> _getChildrenList() {
    final List<Widget> result = [];
    final flatChildren = widget.childrens.expand((c) => c).toList();
    final totalChildren = flatChildren.length;

    for (var i = 0; i < totalChildren; i++) {
      final child = flatChildren[i];
      result.add(AnimatedChild(
        animation: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              i / totalChildren,
              1.0,
              curve: widget.animationCurve ?? Curves.ease,
            ),
          ),
        ),
        index: i,
        margin: (widget.spaceBetweenChildren != null
            ? EdgeInsets.fromLTRB(
                widget.direction.isRight ? widget.spaceBetweenChildren! : 0,
                widget.direction.isDown ? widget.spaceBetweenChildren! : 0,
                widget.direction.isLeft ? widget.spaceBetweenChildren! : 0,
                widget.direction.isUp ? widget.spaceBetweenChildren! : 0,
              )
            : null),
        btnKey: child.key,
        useColumn: widget.direction.isLeft || widget.direction.isRight,
        visible: child.visible,
        switchLabelPosition: widget.switchLabelPosition,
        backgroundColor: child.backgroundColor,
        foregroundColor: child.foregroundColor,
        elevation: child.elevation,
        buttonSize: widget.childrenButtonSize,
        labelWidget: child.labelWidget,
        onTap: child.onTap,
        onLongPress: child.onLongPress,
        toggleChildren: () {
          if (!widget.closeManually) toggleChildren();
        },
        shape: child.shape,
        heroTag:
            widget.heroTag != null ? '${widget.heroTag}-child-$i' : null,
        childMargin: widget.childMargin,
        childPadding: widget.childPadding,
        child: child.child,
      ));
    }
    return result.reversed.toList();
  }

  // ==================== 新方法：构建网格 ====================
  Widget _buildGrid() {
    final childrens = widget.childrens;
    final flatChildren = childrens.expand((c) => c).toList();
    final totalChildren = flatChildren.length;

    int childIndex = 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: childrens.map((columnChildren) {
        final columnWidgets = columnChildren.map((child) {
          final int currentIndex = childIndex;
          childIndex++;

          return AnimatedChild(
            animation: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Interval(
                  currentIndex / totalChildren,
                  1.0,
                  curve: widget.animationCurve ?? Curves.ease,
                ),
              ),
            ),
            index: currentIndex,
            margin: EdgeInsets.only(bottom: widget.spaceBetweenChildren ?? 4.0),
            btnKey: child.key,
            useColumn: false,
            visible: child.visible,
            switchLabelPosition: widget.switchLabelPosition,
            backgroundColor: child.backgroundColor,
            foregroundColor: child.foregroundColor,
            elevation: child.elevation,
            buttonSize: widget.childrenButtonSize,
            labelWidget: child.labelWidget,
            onTap: child.onTap,
            onLongPress: child.onLongPress,
            toggleChildren: () {
              if (!widget.closeManually) toggleChildren();
            },
            shape: child.shape,
            heroTag: widget.heroTag != null
                ? '${widget.heroTag}-child-$currentIndex'
                : null,
            childMargin: widget.childMargin,
            childPadding: widget.childPadding,
            child: child.child,
          );
        }).toList();

        return Container(
          margin:
              EdgeInsets.symmetric(horizontal: (widget.spacing ?? 4.0) / 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: columnWidgets.reversed.toList(),
          ),
        );
      }).toList(),
    );
  }
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Positioned(
          child: CompositedTransformFollower(
            followerAnchor: widget.direction.isDown
                ? widget.switchLabelPosition
                      ? Alignment.topLeft
                      : Alignment.topRight
                : widget.direction.isUp
                ? widget.switchLabelPosition
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight
                : widget.direction.isLeft
                ? Alignment.centerRight
                : widget.direction.isRight
                ? Alignment.centerLeft
                : Alignment.center,
            offset: widget.direction.isDown
                ? Offset(
                    (widget.switchLabelPosition ||
                                dialKey.globalPaintBounds == null
                            ? 0
                            : dialKey.globalPaintBounds!.size.width) +
                        max(widget.childrenButtonSize.height - 56, 0) / 2,
                    dialKey.globalPaintBounds!.size.height,
                  )
                : widget.direction.isUp
                ? Offset(
                    (widget.switchLabelPosition ||
                                dialKey.globalPaintBounds == null
                            ? 0
                            : dialKey.globalPaintBounds!.size.width) +
                        max(widget.childrenButtonSize.width - 56, 0) / 2,
                    0,
                  )
                : widget.direction.isLeft
                ? Offset(
                    -10.0,
                    dialKey.globalPaintBounds == null
                        ? 0
                        : dialKey.globalPaintBounds!.size.height / 2,
                  )
                : widget.direction.isRight && dialKey.globalPaintBounds != null
                ? Offset(
                    dialKey.globalPaintBounds!.size.width + 12,
                    dialKey.globalPaintBounds!.size.height / 2,
                  )
                : const Offset(-10.0, 0.0),
            link: layerLink,
            showWhenUnlinked: false,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.direction.isUp || widget.direction.isDown
                      ? max(widget.buttonSize.width - 56, 0) / 2
                      : 0,
                ),
                margin: widget.spacing != null
                    ? EdgeInsets.fromLTRB(
                        widget.direction.isRight ? widget.spacing! : 0,
                        widget.direction.isDown ? widget.spacing! : 0,
                        widget.direction.isLeft ? widget.spacing! : 0,
                        widget.direction.isUp ? widget.spacing! : 0,
                      )
                    : null,
                // ==================== MODIFIED LOGIC HERE ====================
                child: (widget.childrens.isNotEmpty &&
                        (widget.direction.isUp || widget.direction.isDown))
                    ? Align(
                        alignment: widget.direction.isUp
                            ? (widget.switchLabelPosition
                                ? Alignment.bottomLeft
                                : Alignment.bottomRight)
                            : (widget.switchLabelPosition
                                ? Alignment.topLeft
                                : Alignment.topRight),
                        child: _buildGrid(),
                      )
                    : _buildColumnOrRow(
                        widget.direction.isUp || widget.direction.isDown,
                        crossAxisAlignment: widget.switchLabelPosition
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children:
                            widget.direction.isDown || widget.direction.isRight
                                ? _getChildrenList().reversed.toList()
                                : _getChildrenList(),
                      ),
                // =============================================================
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildColumnOrRow(
  bool isColumn, {
  CrossAxisAlignment? crossAxisAlignment,
  MainAxisAlignment? mainAxisAlignment,
  required List<Widget> children,
  MainAxisSize? mainAxisSize,
}) {
  return isColumn
      ? Column(
          mainAxisSize: mainAxisSize ?? MainAxisSize.max,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          children: children,
        )
      : Row(
          mainAxisSize: mainAxisSize ?? MainAxisSize.max,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          children: children,
        );
}
