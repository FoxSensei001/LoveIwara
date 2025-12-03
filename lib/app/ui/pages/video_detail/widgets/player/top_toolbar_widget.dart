import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 新增
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import '../../../../../../utils/proxy/proxy_util.dart';
import '../../../../../routes/app_routes.dart';
import '../../../settings/widgets/player_settings_widget.dart';
import '../../../settings/widgets/proxy_setting_widget.dart';
import '../../controllers/my_video_state_controller.dart';
import '../../../../../../i18n/strings.g.dart' as slang;
import 'package:floating/floating.dart';
import 'package:battery_plus/battery_plus.dart';

class TopToolbar extends StatefulWidget {
  final MyVideoStateController myVideoStateController;
  final bool currentScreenIsFullScreen;

  const TopToolbar({
    super.key,
    required this.myVideoStateController,
    required this.currentScreenIsFullScreen,
  });

  @override
  State<TopToolbar> createState() => _TopToolbarState();
}

class _TopToolbarState extends State<TopToolbar> {
  // 缓存常用组件
  final Widget _backIcon = const Icon(Icons.arrow_back, color: Colors.white);
  final Widget _homeIcon = const Icon(Icons.home, color: Colors.white);
  final Widget _helpIcon = const Icon(Icons.help_outline, color: Colors.white);
  final Widget _moreIcon = const Icon(Icons.more_vert, color: Colors.white);

  Timer? _timeTimer;
  DateTime _currentTime = DateTime.now();
  
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  bool _batterySupported = false;
  StreamSubscription<BatteryState>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    _initializeTime();
    _initializeBattery();
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _batterySubscription?.cancel();
    super.dispose();
  }

  void _initializeTime() {
    _currentTime = DateTime.now();
    // 每秒更新一次时间
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _initializeBattery() async {
    try {
      // 初始获取电量
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      
      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _batteryState = state;
          _batterySupported = true;
        });
      }
      
      // 监听电池状态变化 (充电、未充电等)
      _batterySubscription = _battery.onBatteryStateChanged.listen((BatteryState state) async {
        final level = await _battery.batteryLevel;
        if (mounted) {
          setState(() {
            _batteryState = state;
            _batteryLevel = level;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _batterySupported = false;
        });
      }
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // --- SVG 构建逻辑开始 ---

  /// 根据时间段获取时间图标 SVG
  Widget _buildTimeIcon(DateTime time) {
    final hour = time.hour;
    String svgPath;
    
    // 定义简单的 SVG 路径
    // 上午 6-11 点: 日出/早上
    // 11-17 点: 太阳/白天
    // 17-19 点: 日落/傍晚
    // 19-6 点: 月亮/晚上

    if (hour >= 6 && hour < 11) {
       // Morning (Sun partly rising)
       svgPath = '<path d="M12 5c-3.87 0-7 3.13-7 7h14c0-3.87-3.13-7-7-7zm0 9H8v-2h8v2h-4zm7-9.5l1.5-1.5 1.42 1.42L20.42 5.92 19 4.5zm-14 0L3.58 5.92 2.16 4.5 3.58 2.92 5 4.5zM12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z" fill="white"/>'; // 使用 access_time 风格或自定义
       // 这里为了简洁，使用一个通用的 "wb_twilight" 风格或简单的太阳
       return const Icon(Icons.wb_twilight, color: Colors.white, size: 16); 
    } else if (hour >= 11 && hour < 17) {
      // Day (Full Sun)
      return const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 16);
    } else if (hour >= 17 && hour < 19) {
      // Evening (Sunset)
      return const Icon(Icons.wb_twilight, color: Colors.white, size: 16);
    } else {
      // Night (Moon)
      return const Icon(Icons.nights_stay_outlined, color: Colors.white, size: 16);
    }
  }

  /// 动态构建电池 SVG
  Widget _buildBatterySvg(int level, BatteryState state) {
    // 确定颜色
    Color batteryColor = Colors.white;
    bool isCharging = state == BatteryState.charging || state == BatteryState.full;

    if (isCharging) {
      batteryColor = const Color(0xFF4CAF50); // 充电中显示绿色
    } else if (level <= 20) {
      batteryColor = const Color(0xFFF44336); // 低电量显示红色
    }

    // 将 Color 转换为 Hex String for SVG
    String colorHex = '#${batteryColor.value.toRadixString(16).substring(2)}';
    
    // 计算内部矩形的宽度 (最大宽度设为 14 左右，对应 viewBox 的坐标)
    // 电池主体大约宽 18，内部填充区域大约宽 14
    double fillWidth = (level / 100.0) * 14.0;
    if (fillWidth < 0) fillWidth = 0;
    if (fillWidth > 14) fillWidth = 14;

    // SVG 字符串
    String svgString = '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- 电池外框 -->
        <path d="M17 6H7C5.89543 6 5 6.89543 5 8V16C5 17.1046 5.89543 18 7 18H17C18.1046 18 19 17.1046 19 16V8C19 6.89543 18.1046 6 17 6Z" stroke="$colorHex" stroke-width="1.5"/>
        <!-- 电池正极头 -->
        <path d="M20 10V14" stroke="$colorHex" stroke-width="1.5" stroke-linecap="round"/>
        
        <!-- 电量填充 -->
        <rect x="6.5" y="7.5" width="$fillWidth" height="9" rx="0.5" fill="$colorHex"/>
        
        ${isCharging ? 
          // 充电闪电图标 (居中覆盖)
          '''<path d="M11 15L13.5 10H10.5L13 7" stroke="black" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="white"/>''' 
          : ''}
      </svg>
    ''';

    return SvgPicture.string(
      svgString,
      width: 24,
      height: 14, // 稍微压扁一点适应工具栏，或者保持比例
    );
  }
  
  // --- SVG 构建逻辑结束 ---

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SlideTransition(
      position: widget.myVideoStateController.topBarAnimation,
      child: FadeTransition(
        opacity: widget.myVideoStateController.animationController,
        child: MouseRegion(
          onEnter: (_) => widget.myVideoStateController.setToolbarHovering(true),
          onExit: (_) => widget.myVideoStateController.setToolbarHovering(false),
          child: Container(
            height: 60 + statusBarHeight,
            padding: EdgeInsets.only(top: statusBarHeight),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(179), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左侧部分保持不变
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: t.common.back,
                        icon: _backIcon,
                        onPressed: () {
                          if (widget.currentScreenIsFullScreen) {
                            widget.myVideoStateController.exitFullscreen();
                          } else {
                            AppService.tryPop();
                          }
                        },
                      ),
                      if (!widget.currentScreenIsFullScreen &&
                          !widget.myVideoStateController.isDesktopAppFullScreen.value)
                        IconButton(
                          tooltip: t.videoDetail.home,
                          icon: _homeIcon,
                          onPressed: () {
                            AppService appService = Get.find();
                            int currentIndex = appService.currentIndex;
                            final routes = [
                              Routes.POPULAR_VIDEOS,
                              Routes.GALLERY,
                              Routes.SUBSCRIPTIONS,
                            ];
                            AppService.homeNavigatorKey.currentState!
                                .pushNamedAndRemoveUntil(
                                  routes[currentIndex],
                                  (route) => false,
                                );
                          },
                        ),
                      Expanded(
                        child: Obx(
                          () => Text(
                            widget.myVideoStateController.videoInfo.value?.title ??
                                t.videoDetail.videoPlayer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 中间: 全屏模式下显示时间、电量 (优化后)
                if (widget.currentScreenIsFullScreen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black12, // 稍微加深一点背景，使其更易读
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 系统时间 (带动态 Icon)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTimeIcon(_currentTime),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(_currentTime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13, // 稍微调小一点字体使其更精致
                                fontWeight: FontWeight.w600,
                                fontFamily: 'RobotoMono', // 如果有等宽字体更好，没有也没关系
                              ),
                            ),
                          ],
                        ),
                        // 分隔符
                        if (_batterySupported) ...[
                          const SizedBox(width: 8),
                          Container(width: 1, height: 12, color: Colors.white24),
                          const SizedBox(width: 8),
                        ],
                        // 电量显示 (SVG 动态构建)
                        if (_batterySupported) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBatterySvg(_batteryLevel, _batteryState),
                              const SizedBox(width: 6),
                              Text(
                                '$_batteryLevel%',
                                style: TextStyle(
                                  // 电量文字颜色也跟随状态变色，或者保持白色
                                  color: (_batteryState == BatteryState.charging) 
                                      ? const Color(0xFF4CAF50) 
                                      : (_batteryLevel <= 20 ? const Color(0xFFF44336) : Colors.white),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                // 右侧部分保持不变
                Row(
                  children: [
                    if (!GetPlatform.isWeb && !GetPlatform.isLinux)
                      IconButton(
                        tooltip: t.videoDetail.cast.dlnaCast,
                        icon: const Icon(Icons.cast, color: Colors.white),
                        onPressed: () =>
                            widget.myVideoStateController.showDlnaCastDialog(),
                      ),
                    if (GetPlatform.isAndroid)
                      IconButton(
                        tooltip: t.videoDetail.pipMode,
                        icon: const Icon(
                          Icons.picture_in_picture_alt,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final floating = Floating();
                          if (await floating.isPipAvailable) {
                            final status = await floating.pipStatus;
                            if (status == PiPStatus.disabled ||
                                status == PiPStatus.automatic) {
                              if (widget.currentScreenIsFullScreen) {
                                AppService.tryPop();
                              }
                              if (widget.myVideoStateController
                                  .isDesktopAppFullScreen
                                  .value) {
                                widget.myVideoStateController
                                        .isDesktopAppFullScreen
                                        .value =
                                    false;
                              }
                              widget.myVideoStateController.enterPiPMode();
                            } else if (status == PiPStatus.enabled) {
                              widget.myVideoStateController.exitPiPMode();
                            }
                          }
                        },
                      ),
                    IconButton(
                      tooltip: t.videoDetail.videoPlayerInfo,
                      icon: _helpIcon,
                      onPressed: () => showInfoModal(context),
                    ),
                    IconButton(
                      tooltip: t.videoDetail.moreSettings,
                      icon: _moreIcon,
                      onPressed: () => showSettingsModal(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... 后面保持原本的 showSettingsModal 和 showInfoModal 代码不变 ...
  // 为了简洁，这里省略了未修改的 modal 代码，实际使用时请保留原有的代码
  
  void showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.80,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SettingsContent(
                myVideoStateController: widget.myVideoStateController,
              ),
            );
          },
        );
      },
    );
  }

  void showInfoModal(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.videoDetail.videoPlayerFeatureInfo),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Row(
                children: [
                  const Icon(Icons.repeat),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.videoDetail.autoRewind)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.fast_forward),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(slang.t.videoDetail.rewindAndFastForward),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_up),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(slang.t.videoDetail.volumeAndBrightness),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.pause_circle_filled),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slang.t.videoDetail.centerAreaDoubleTapPauseOrPlay,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (GetPlatform.isAndroid || GetPlatform.isIOS)
                Row(
                  children: [
                    const Icon(Icons.screen_rotation),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        slang.t.videoDetail.showVerticalVideoInFullScreen,
                      ),
                    ),
                  ],
                ),
              if (GetPlatform.isAndroid || GetPlatform.isIOS)
                const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.settings_backup_restore),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slang.t.videoDetail.keepLastVolumeAndBrightness,
                    ),
                  ),
                ],
              ),
              if (ProxyUtil.isSupportedPlatform()) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.laptop),
                    const SizedBox(width: 8),
                    Expanded(child: Text(slang.t.videoDetail.setProxy)),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.high_quality),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slang.t.anime4k.realTimeVideoUpscalingAndDenoising,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.thumb_up),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(slang.t.videoDetail.moreFeaturesToBeDiscovered),
                  ),
                ],
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
}

class SettingsContent extends StatelessWidget {
  final MyVideoStateController myVideoStateController;

  const SettingsContent({super.key, required this.myVideoStateController});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            t.videoDetail.videoPlayerSettings,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          PlayerSettingsWidget(),
          const SizedBox(height: 16),
          if (ProxyUtil.isSupportedPlatform()) ProxySettingsWidget(),
        ],
      ),
    );
  }
}