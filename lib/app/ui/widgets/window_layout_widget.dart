import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:window_manager/window_manager.dart';

/// 窗口框架
class WindowTitleBarLayout extends StatelessWidget {
  const WindowTitleBarLayout(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isMobile) return child;
    AppService controller = Get.find();

    // 使用 Builder 确保正确的上下文传递
    return Builder(
      builder: (context) {
        var body = Stack(
          children: [
            Obx(() {
              final double statusBarHeight = MediaQuery.paddingOf(context).top +
                  (controller.showTitleBar ? AppService.titleBarHeight : 0);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: EdgeInsets.only(top: statusBarHeight),
                ),
                child: child,
              );
            }),
            // 顶部标题栏
            Obx(() {
              if (!controller.showTitleBar) {
                return const SizedBox.shrink(); // 不显示标题栏
              }
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: Theme(
                    data: Theme.of(context),
                    child: Builder(builder: (context) {
                      return SizedBox(
                        height: AppService.titleBarHeight,
                        child: Row(
                          children: [
                            if (!GetPlatform.isMacOS)
                              _buildMenuButton(controller, context)
                                  .toAlign(Alignment.centerLeft)
                            else
                              const DragToMoveArea(
                                child: SizedBox(
                                  height: double.infinity,
                                  width: 16,
                                ),
                              ).paddingRight(52),
                            Expanded(
                              child: DragToMoveArea(
                                child: Text(
                                  'Love Iwara',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: (context.brightness == Brightness.dark)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ).toAlign(Alignment.centerLeft).paddingLeft(4),
                              ),
                            ),
                            if (!GetPlatform.isMacOS)
                              const WindowButtons()
                            else
                              _buildMenuButton(controller, context)
                                  .toAlign(Alignment.centerRight),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              );
            }),
          ],
        );

        if (GetPlatform.isLinux) {
          return VirtualWindowFrame(child: body);
        } else {
          return body;
        }
      },
    );
  }


  Widget _buildMenuButton(AppService controller, BuildContext context) {
    return InkWell(
        onTap: () {
          AppService.switchGlobalDrawer();
        },
        child: SizedBox(
          width: 42,
          height: double.infinity,
          child: Center(
            child: CustomPaint(
              size: const Size(18, 20),
              painter: _MenuPainter(
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black),
            ),
          ),
        ));
  }
}

class _MenuPainter extends CustomPainter {
  final Color color;

  _MenuPainter({this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = getPaint(color);
    final path = Path()
      ..moveTo(0, size.height / 4)
      ..lineTo(size.width, size.height / 4)
      ..moveTo(0, size.height / 4 * 2)
      ..lineTo(size.width, size.height / 4 * 2)
      ..moveTo(0, size.height / 4 * 3)
      ..lineTo(size.width, size.height / 4 * 3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  bool isMaximized = false;

  @override
  void initState() {
    windowManager.addListener(this);
    windowManager.isMaximized().then((value) {
      if (value) {
        setState(() {
          isMaximized = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {
      isMaximized = true;
    });
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      isMaximized = false;
    });
    super.onWindowUnmaximize();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8);
    final defaultHoverColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);

    return SizedBox(
      width: 138,
      height: AppService.titleBarHeight,
      child: Row(
        children: [
          WindowButton(
            icon: MinimizeIcon(color: defaultIconColor),
            hoverIconColor: isDark ? Colors.white : Colors.black,
            hoverColor: defaultHoverColor,
            onPressed: () async {
              bool isMinimized = await windowManager.isMinimized();
              if (isMinimized) {
                windowManager.restore();
              } else {
                windowManager.minimize();
              }
            },
          ),
          if (isMaximized)
            WindowButton(
              icon: RestoreIcon(color: defaultIconColor),
              hoverIconColor: isDark ? Colors.white : Colors.black,
              hoverColor: defaultHoverColor,
              onPressed: () => windowManager.unmaximize(),
            )
          else
            WindowButton(
              icon: MaximizeIcon(color: defaultIconColor),
              hoverIconColor: isDark ? Colors.white : Colors.black,
              hoverColor: defaultHoverColor,
              onPressed: () => windowManager.maximize(),
            ),
          WindowButton(
            icon: CloseIcon(color: defaultIconColor),
            hoverIconColor: Colors.white,
            hoverColor: const Color(0xFFE81123),
            isCloseButton: true,
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class WindowButton extends StatefulWidget {
  const WindowButton({
    required this.icon,
    required this.onPressed,
    required this.hoverColor,
    required this.hoverIconColor,
    this.isCloseButton = false,
    super.key,
  });

  final Widget icon;
  final void Function() onPressed;
  final Color hoverColor;
  final Color hoverIconColor;
  final bool isCloseButton;

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool isHovering = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (event) => setState(() => isHovering = true),
        onExit: (event) => setState(() {
          isHovering = false;
          isPressed = false;
        }),
        child: InkWell(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: widget.onPressed,
          child: Container(
            width: 46,
            height: double.infinity,
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
            ),
            child: Center(
              child: _buildIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (widget.isCloseButton) {
      if (isPressed) {
        return const Color(0xFFBF0F1D);
      }
      if (isHovering) {
        return const Color(0xFFE81123);
      }
      return Colors.transparent;
    }

    if (isPressed) {
      return isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.04);
    }
    if (isHovering) {
      return widget.hoverColor;
    }
    return Colors.transparent;
  }

  Widget _buildIcon() {
    if (isHovering) {
      if (widget.icon is CloseIcon) {
        return CloseIcon(color: widget.hoverIconColor);
      }
      if (widget.icon is MaximizeIcon) {
        return MaximizeIcon(color: widget.hoverIconColor);
      }
      if (widget.icon is RestoreIcon) {
        return RestoreIcon(color: widget.hoverIconColor);
      }
      if (widget.icon is MinimizeIcon) {
        return MinimizeIcon(color: widget.hoverIconColor);
      }
    }
    return widget.icon;
  }
}

/// Close
class CloseIcon extends StatelessWidget {
  final Color color;

  const CloseIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) => _AlignedPaint(_ClosePainter(color));
}

class _ClosePainter extends _IconPainter {
  _ClosePainter(super.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color, true);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), p);
  }
}

/// Maximize
class MaximizeIcon extends StatelessWidget {
  final Color color;

  const MaximizeIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) => _AlignedPaint(_MaximizePainter(color));
}

class _MaximizePainter extends _IconPainter {
  _MaximizePainter(super.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width - 1, size.height - 1), p);
  }
}

/// Restore
class RestoreIcon extends StatelessWidget {
  final Color color;

  const RestoreIcon({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => _AlignedPaint(_RestorePainter(color));
}

class _RestorePainter extends _IconPainter {
  _RestorePainter(super.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 2, size.width - 2, size.height), p);
    canvas.drawLine(const Offset(2, 2), const Offset(2, 0), p);
    canvas.drawLine(const Offset(2, 0), Offset(size.width, 0), p);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height - 2), p);
    canvas.drawLine(Offset(size.width, size.height - 2),
        Offset(size.width - 2, size.height - 2), p);
  }
}

/// Minimize
class MinimizeIcon extends StatelessWidget {
  final Color color;

  const MinimizeIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) => _AlignedPaint(_MinimizePainter(color));
}

class _MinimizePainter extends _IconPainter {
  _MinimizePainter(super.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }
}

/// Helpers
abstract class _IconPainter extends CustomPainter {
  _IconPainter(this.color);

  final Color color;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlignedPaint extends StatelessWidget {
  const _AlignedPaint(this.painter);

  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: CustomPaint(size: const Size(10, 10), painter: painter));
  }
}

Paint getPaint(Color color, [bool isAntiAlias = false]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..isAntiAlias = isAntiAlias
  ..strokeWidth = 1;

class WindowPlacement {
  final Rect rect;

  final bool isMaximized;

  const WindowPlacement(this.rect, this.isMaximized);

  Future<void> applyToWindow() async {
    await windowManager.setBounds(rect);

    if (!validate(rect)) {
      await windowManager.center();
    }

    if (isMaximized) {
      await windowManager.maximize();
    }
  }

  // Future<void> writeToFile() async {
  //   var file = File("${GetPlatform.dataPath}/window_placement");
  //   await file.writeAsString(jsonEncode({
  //     'width': rect.width,
  //     'height': rect.height,
  //     'x': rect.topLeft.dx,
  //     'y': rect.topLeft.dy,
  //     'isMaximized': isMaximized
  //   }));
  // }

  // static Future<WindowPlacement> loadFromFile() async {
  //   try {
  //     var file = File("${GetPlatform.dataPath}/window_placement");
  //     if (!file.existsSync()) {
  //       return defaultPlacement;
  //     }
  //     var json = jsonDecode(await file.readAsString());
  //     var rect =
  //         Rect.fromLTWH(json['x'], json['y'], json['width'], json['height']);
  //     return WindowPlacement(rect, json['isMaximized']);
  //   } catch (e) {
  //     return defaultPlacement;
  //   }
  // }

  static Future<WindowPlacement> get current async {
    var rect = await windowManager.getBounds();
    var isMaximized = await windowManager.isMaximized();
    return WindowPlacement(rect, isMaximized);
  }

  static const defaultPlacement =
      WindowPlacement(Rect.fromLTWH(10, 10, 900, 600), false);

  static WindowPlacement cache = defaultPlacement;

  static Timer? timer;

  // static void loop() async {
  //   timer ??= Timer.periodic(const Duration(milliseconds: 100), (timer) async {
  //     var placement = await WindowPlacement.current;
  //     if (!validate(placement.rect)) {
  //       return;
  //     }
  //     if (placement.rect != cache.rect ||
  //         placement.isMaximized != cache.isMaximized) {
  //       cache = placement;
  //       await placement.writeToFile();
  //     }
  //   });
  // }

  static bool validate(Rect rect) {
    return rect.topLeft.dx >= 0 && rect.topLeft.dy >= 0;
  }
}
