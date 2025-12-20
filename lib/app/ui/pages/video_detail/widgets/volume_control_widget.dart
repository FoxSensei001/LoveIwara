import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../../i18n/strings.g.dart' as slang;

import '../../../../services/config_service.dart';
import '../controllers/my_video_state_controller.dart';

class VolumeControl extends StatefulWidget {
  final ConfigService configService;
  final MyVideoStateController myVideoStateController;
  final double iconSize;

  const VolumeControl({
    super.key,
    required this.configService,
    required this.myVideoStateController,
    this.iconSize = 20.0,
  });

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  // 定义动画控制器和动画
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
      if (_isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _getVolumeIcon(double volume) {
    String assetName;
    if (volume == 0) {
      assetName = 'assets/svg/volume_off.svg';
    } else if (volume < 0.5) {
      assetName = 'assets/svg/volume_down.svg';
    } else {
      assetName = 'assets/svg/volume_up.svg';
    }

    return SvgPicture.asset(
      assetName,
      width: widget.iconSize,
      height: widget.iconSize,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: Obx(() {
        double volume = widget.configService[ConfigKey.VOLUME_KEY];
        return Row(
          children: [
            Tooltip(
              message: '${t.videoDetail.volume}: ${(volume * 100).toInt()}%',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    widget.myVideoStateController.setVolume(0, save: false);
                  },
                  child: Container(
                    width:
                        widget.iconSize +
                        16, // Use consistent touch target sizing logic
                    height: widget.iconSize + 16,
                    alignment: Alignment.center,
                    child: _getVolumeIcon(volume),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).scale(duration: 300.ms),
            // 使用 SliderTheme 包裹 Slider
            SizeTransition(
              sizeFactor: _fadeAnimation,
              axis: Axis.horizontal,
              axisAlignment: -1.0,
              child: SizedBox(
                width: 150,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12.0,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.1),
                    valueIndicatorColor: Colors.white,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    showValueIndicator: ShowValueIndicator.onDrag,
                  ),
                  child:
                      Slider(
                            value: volume,
                            min: 0.0,
                            max: 1.0,
                            focusNode: FocusNode(
                              skipTraversal: true,
                              canRequestFocus: false,
                            ),
                            autofocus: false,
                            onChanged: (double newVolume) {
                              widget.myVideoStateController.setVolume(
                                newVolume,
                              );
                            },
                            label: '音量: ${(volume * 100).toInt()}%',
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: -0.3, end: 0.0, duration: 300.ms),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
