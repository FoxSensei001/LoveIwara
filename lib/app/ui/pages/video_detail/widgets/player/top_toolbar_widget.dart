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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:i_iwara/app/services/config_service.dart';
import '../../../../../../common/anime4k_presets.dart';

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
  Timer? _timeTimer;
  DateTime _currentTime = DateTime.now();

  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  bool _batterySupported = false;
  StreamSubscription<BatteryState>? _batterySubscription;

  // 网络状态
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // WiFi 信号强度 (Android: -100 到 0 dBm, iOS: 不支持)
  // ignore: unused_field
  final NetworkInfo _networkInfo = NetworkInfo();
  // ignore: unused_field
  int? _wifiSignalStrength; // null 表示不支持或无法获取，预留用于未来扩展

  @override
  void initState() {
    super.initState();
    _initializeTime();
    _initializeBattery();
    _initializeConnectivity();
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _batterySubscription?.cancel();
    _connectivitySubscription?.cancel();
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

  Future<void> _initializeConnectivity() async {
    try {
      // 初始状态（取列表的第一个结果）
      final results = await _connectivity.checkConnectivity();
      final ConnectivityResult result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _connectivityResult = result;
        });
      }

      // 如果是 WiFi，尝试获取信号强度
      if (result == ConnectivityResult.wifi) {
        await _updateWifiSignalStrength();
      }

      // 监听变化（同样取列表的第一个结果）
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) async {
        final ConnectivityResult result = results.isNotEmpty
            ? results.first
            : ConnectivityResult.none;
        if (mounted) {
          setState(() {
            _connectivityResult = result;
            // 如果切换到非 WiFi，清除信号强度
            if (result != ConnectivityResult.wifi) {
              _wifiSignalStrength = null;
            }
          });

          // 如果是 WiFi，尝试获取信号强度
          if (result == ConnectivityResult.wifi) {
            await _updateWifiSignalStrength();
          }
        }
      });

      // 定期更新 WiFi 信号强度（如果是 WiFi）
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_connectivityResult == ConnectivityResult.wifi) {
          await _updateWifiSignalStrength();
        }
      });
    } catch (_) {
      // 忽略异常，保持默认 none 状态
    }
  }

  /// 更新 WiFi 信号强度
  Future<void> _updateWifiSignalStrength() async {
    try {
      // Android 才支持获取 WiFi 信号强度 (单位: dBm, 范围通常 -100 到 0)
      // iOS 不支持此功能
      if (GetPlatform.isAndroid) {
        // network_info_plus 需要权限: ACCESS_FINE_LOCATION
        // 注意: network_info_plus 6.x 版本可能没有直接获取信号强度的API
        // 这里我们使用一个变通方法，或者考虑使用 wifi_info_flutter 等其他包
        // 为了演示，这里假设我们能获取到信号强度
        // 实际情况下可能需要使用平台通道或其他方法

        // 由于 network_info_plus 不直接提供信号强度，我们这里先设置为 null
        // 如果需要真实的信号强度，可能需要使用平台特定的代码
        if (mounted) {
          setState(() {
            // 暂时设置为 null，表示不支持
            // 如果有实际的信号强度 API，在这里设置
            _wifiSignalStrength = null;
          });
        }
      }
    } catch (_) {
      // 忽略错误
    }
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
      _batterySubscription = _battery.onBatteryStateChanged.listen((
        BatteryState state,
      ) async {
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

    // 定义简单的 SVG 路径
    // 上午 6-11 点: 日出/早上
    // 11-17 点: 太阳/白天
    // 17-19 点: 日落/傍晚
    // 19-6 点: 月亮/晚上

    if (hour >= 6 && hour < 11) {
      // Morning (Sun partly rising)
      return const Icon(Icons.wb_twilight, color: Colors.white, size: 16);
    } else if (hour >= 11 && hour < 17) {
      // Day (Full Sun)
      return const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 16);
    } else if (hour >= 17 && hour < 19) {
      // Evening (Sunset)
      return const Icon(Icons.wb_twilight, color: Colors.white, size: 16);
    } else {
      // Night (Moon)
      return const Icon(
        Icons.nights_stay_outlined,
        color: Colors.white,
        size: 16,
      );
    }
  }

  /// 动态构建电池 SVG
  Widget _buildBatterySvg(int level, BatteryState state) {
    // 确定颜色
    Color batteryColor = Colors.white;
    bool isCharging =
        state == BatteryState.charging || state == BatteryState.full;

    if (isCharging) {
      batteryColor = const Color(0xFF4CAF50); // 充电中显示绿色
    } else if (level <= 20) {
      batteryColor = const Color(0xFFF44336); // 低电量显示红色
    }

    // 将 Color 转换为 Hex String for SVG
    final int argb =
        (batteryColor.a * 255).toInt() << 24 |
        (batteryColor.r * 255).toInt() << 16 |
        (batteryColor.g * 255).toInt() << 8 |
        (batteryColor.b * 255).toInt();
    String colorHex = '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';

    // 计算内部矩形的宽度
    // 电池外框从 x=5 到 x=19，宽度为 14
    // 考虑到 stroke-width=1.5，实际内部可用区域从 x=6.5 到 x=17.5，宽度为 11
    // 填充矩形从 x=6.5 开始，最大宽度为 11
    const double maxFillWidth = 11.0;
    double fillWidth = (level / 100.0) * maxFillWidth;
    if (fillWidth < 0) fillWidth = 0;
    if (fillWidth > maxFillWidth) fillWidth = maxFillWidth;

    // SVG 字符串
    String svgString =
        '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- 电池外框 -->
        <path d="M17 6H7C5.89543 6 5 6.89543 5 8V16C5 17.1046 5.89543 18 7 18H17C18.1046 18 19 17.1046 19 16V8C19 6.89543 18.1046 6 17 6Z" stroke="$colorHex" stroke-width="1.5"/>
        <!-- 电池正极头 -->
        <path d="M20 10V14" stroke="$colorHex" stroke-width="1.5" stroke-linecap="round"/>
        
        <!-- 电量填充 -->
        <rect x="6.5" y="7.5" width="$fillWidth" height="9" rx="0.5" fill="$colorHex"/>
        
        ${isCharging ?
              // 充电闪电图标 (居中覆盖)
              '''<path d="M11 15L13.5 10H10.5L13 7" stroke="black" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="white"/>''' : ''}
      </svg>
    ''';

    return SvgPicture.string(
      svgString,
      width: 24,
      height: 14, // 稍微压扁一点适应工具栏，或者保持比例
    );
  }

  /// 判断是否应该显示网络状态
  bool _shouldShowNetworkStatus() {
    // 只显示 WiFi、移动网络、宽带和无网络
    return _connectivityResult == ConnectivityResult.wifi ||
        _connectivityResult == ConnectivityResult.mobile ||
        _connectivityResult == ConnectivityResult.ethernet ||
        _connectivityResult == ConnectivityResult.none;
  }

  /// 网络状态图标（不显示文本）
  Widget _buildNetworkStatus() {
    // 根据网络类型返回对应的 SVG 图标
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return _buildWifiIcon();
      case ConnectivityResult.mobile:
        return _buildMobileNetworkIcon();
      case ConnectivityResult.ethernet:
        return _buildEthernetIcon();
      case ConnectivityResult.none:
        // 无网络显示红色的断网图标
        return _buildNoNetworkIcon();
      // 其他类型（vpn, bluetooth, other）不显示
      default:
        return const SizedBox.shrink();
    }
  }

  /// WiFi 图标（带信号强度）
  Widget _buildWifiIcon() {
    // WiFi 图标 - 简洁的扇形信号设计
    // 由于 network_info_plus 不提供信号强度，我们显示满信号的 WiFi 图标
    const String svgString = '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- WiFi 信号波纹 - 3层 -->
        <path d="M12 18C12.5523 18 13 17.5523 13 17C13 16.4477 12.5523 16 12 16C11.4477 16 11 16.4477 11 17C11 17.5523 11.4477 18 12 18Z" fill="white"/>
        <path d="M9.17 14.83C9.95639 14.0436 11.0217 13.5977 12.135 13.5977C13.2483 13.5977 14.3136 14.0436 15.1 14.83" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
        <path d="M6.34 12C7.90609 10.4339 10.0261 9.55664 12.235 9.55664C14.4439 9.55664 16.5639 10.4339 18.13 12" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
        <path d="M3.51 9.17C5.85609 6.82391 9.08174 5.50391 12.455 5.50391C15.8283 5.50391 19.0539 6.82391 21.4 9.17" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
    ''';

    return SvgPicture.string(svgString, width: 20, height: 16);
  }

  /// 移动网络图标（统一样式）
  Widget _buildMobileNetworkIcon() {
    // 移动网络信号塔图标
    const String svgString = '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- 信号塔主体 -->
        <path d="M12 4L9 9H15L12 4Z" fill="white"/>
        <rect x="11" y="9" width="2" height="11" fill="white"/>
        <!-- 左侧信号波 -->
        <path d="M7 11C8.5 11 9 12 9 13" stroke="white" stroke-width="1.2" stroke-linecap="round"/>
        <path d="M5 9C7.5 9 8.5 11 8.5 13" stroke="white" stroke-width="1.2" stroke-linecap="round"/>
        <!-- 右侧信号波 -->
        <path d="M17 11C15.5 11 15 12 15 13" stroke="white" stroke-width="1.2" stroke-linecap="round"/>
        <path d="M19 9C16.5 9 15.5 11 15.5 13" stroke="white" stroke-width="1.2" stroke-linecap="round"/>
        <!-- 底座 -->
        <rect x="9" y="20" width="6" height="1.5" rx="0.5" fill="white"/>
      </svg>
    ''';

    return SvgPicture.string(svgString, width: 20, height: 16);
  }

  /// 宽带（以太网）图标
  Widget _buildEthernetIcon() {
    // 以太网接口图标
    const String svgString = '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- 网线接口外框 -->
        <rect x="4" y="8" width="16" height="10" rx="1.5" stroke="white" stroke-width="1.5"/>
        <!-- 接口卡槽 -->
        <rect x="7" y="11" width="2" height="4" rx="0.5" fill="white"/>
        <rect x="11" y="11" width="2" height="4" rx="0.5" fill="white"/>
        <rect x="15" y="11" width="2" height="4" rx="0.5" fill="white"/>
        <!-- 网线 -->
        <path d="M10 8V5H14V8" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
        <path d="M10 5H14" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
    ''';

    return SvgPicture.string(svgString, width: 20, height: 16);
  }

  /// 无网络图标
  Widget _buildNoNetworkIcon() {
    // 断网图标 - WiFi + 斜线
    const String svgString = '''
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- WiFi 信号（半透明） -->
        <path d="M12 18C12.5523 18 13 17.5523 13 17C13 16.4477 12.5523 16 12 16C11.4477 16 11 16.4477 11 17C11 17.5523 11.4477 18 12 18Z" fill="#F44336" opacity="0.5"/>
        <path d="M9.17 14.83C9.95639 14.0436 11.0217 13.5977 12.135 13.5977C13.2483 13.5977 14.3136 14.0436 15.1 14.83" stroke="#F44336" stroke-width="1.5" stroke-linecap="round" opacity="0.5"/>
        <path d="M6.34 12C7.90609 10.4339 10.0261 9.55664 12.235 9.55664C14.4439 9.55664 16.5639 10.4339 18.13 12" stroke="#F44336" stroke-width="1.5" stroke-linecap="round" opacity="0.5"/>
        <!-- 斜线表示断网 -->
        <line x1="4" y1="20" x2="20" y2="4" stroke="#F44336" stroke-width="2" stroke-linecap="round"/>
      </svg>
    ''';

    return SvgPicture.string(svgString, width: 20, height: 16);
  }

  // --- SVG 构建逻辑结束 ---

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool isFullScreen = widget.currentScreenIsFullScreen;
    final double toolbarHeight = isFullScreen ? 60.0 : 48.0;
    final double iconSize = isFullScreen ? 24.0 : 20.0;
    final double fontSize = isFullScreen ? 18.0 : 14.0;

    return SlideTransition(
      position: widget.myVideoStateController.topBarAnimation,
      child: FadeTransition(
        opacity: widget.myVideoStateController.animationController,
        child: MouseRegion(
          onEnter: (_) =>
              widget.myVideoStateController.setToolbarHovering(true),
          onExit: (_) =>
              widget.myVideoStateController.setToolbarHovering(false),
          child: Container(
            height: toolbarHeight + statusBarHeight,
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
                // 左侧部分
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: t.common.back,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        onPressed: () {
                          if (isFullScreen) {
                            widget.myVideoStateController.exitFullscreen();
                          } else {
                            AppService.tryPop();
                          }
                        },
                      ),
                      if (!isFullScreen &&
                          !widget
                              .myVideoStateController
                              .isDesktopAppFullScreen
                              .value)
                        IconButton(
                          tooltip: t.videoDetail.home,
                          icon: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: iconSize,
                          ),
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
                            widget
                                    .myVideoStateController
                                    .videoInfo
                                    .value
                                    ?.title ??
                                t.videoDetail.videoPlayer,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 中间:[状态信息]全屏模式下显示时间、电量、网络状态
                if (isFullScreen &&
                    !((GetPlatform.isAndroid || GetPlatform.isIOS) &&
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                          ],
                        ),
                        // 分隔符
                        if (_batterySupported) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.white24,
                          ),
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
                                  color:
                                      (_batteryState == BatteryState.charging)
                                      ? const Color(0xFF4CAF50)
                                      : (_batteryLevel <= 20
                                            ? const Color(0xFFF44336)
                                            : Colors.white),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // 电量与网络之间的分隔
                        if (_shouldShowNetworkStatus()) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.white24,
                          ),
                          const SizedBox(width: 8),
                        ],
                        // 网络状态
                        if (_shouldShowNetworkStatus()) _buildNetworkStatus(),
                      ],
                    ),
                  ),

                // 右侧部分
                Row(
                  children: [
                    if (!GetPlatform.isWeb &&
                        !GetPlatform.isLinux &&
                        !widget.myVideoStateController.isLocalVideoMode)
                      IconButton(
                        tooltip: t.videoDetail.cast.dlnaCast,
                        icon: Icon(
                          Icons.cast,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        onPressed: () =>
                            widget.myVideoStateController.showDlnaCastDialog(),
                      ),
                    if (GetPlatform.isAndroid)
                      IconButton(
                        tooltip: t.videoDetail.pipMode,
                        icon: Icon(
                          Icons.picture_in_picture_alt,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        onPressed: () async {
                          final floating = Floating();
                          if (await floating.isPipAvailable) {
                            final status = await floating.pipStatus;
                            if (status == PiPStatus.disabled ||
                                status == PiPStatus.automatic) {
                              if (isFullScreen) {
                                AppService.tryPop();
                              }
                              if (widget
                                  .myVideoStateController
                                  .isDesktopAppFullScreen
                                  .value) {
                                widget
                                        .myVideoStateController
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
                    _buildAnime4KButton(context, iconSize),
                    IconButton(
                      tooltip: t.videoDetail.moreSettings,
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: iconSize,
                      ),
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

  /// Anime4K 设置按钮
  Widget _buildAnime4KButton(BuildContext context, double iconSize) {
    return Obx(() {
      return PopupMenuButton<String>(
        tooltip: slang.t.anime4k.settings,
        icon: Icon(Icons.adjust, color: Colors.white, size: iconSize),
        onSelected: (value) async {
          if (value == 'disable') {
            await widget.myVideoStateController.switchAnime4KPreset('');
          } else {
            await widget.myVideoStateController.switchAnime4KPreset(value);
          }
        },
        itemBuilder: (context) {
          final configService = Get.find<ConfigService>();
          final currentPresetId =
              configService[ConfigKey.ANIME4K_PRESET_ID] as String;
          final isEnabled = currentPresetId.isNotEmpty;
          return _buildAnime4KMenuItems(context, isEnabled, currentPresetId);
        },
      );
    });
  }

  // 构建 Anime4K 菜单项
  List<PopupMenuEntry<String>> _buildAnime4KMenuItems(
    BuildContext context,
    bool isEnabled,
    String currentPresetId,
  ) {
    final items = <PopupMenuEntry<String>>[];

    // 添加顶部提示文本
    items.add(
      PopupMenuItem<String>(
        enabled: false,
        child: Text(
          slang.t.anime4k.realTimeVideoUpscalingAndDenoising,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 分隔线
    items.add(const PopupMenuDivider());

    // 关闭选项
    items.add(
      PopupMenuItem<String>(
        value: 'disable',
        child: Row(
          children: [
            Icon(Icons.close, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slang.t.anime4k.disable,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    slang.t.anime4k.disableDescription,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // 分隔线
    items.add(const PopupMenuDivider());

    // 预设分组
    final highQualityPresets = Anime4KPresets.getPresetsByGroup(
      Anime4KPresetGroup.highQuality,
    );
    final fastPresets = Anime4KPresets.getPresetsByGroup(
      Anime4KPresetGroup.fast,
    );
    final litePresets = Anime4KPresets.getPresetsByGroup(
      Anime4KPresetGroup.lite,
    );
    final moreLitePresets = Anime4KPresets.getPresetsByGroup(
      Anime4KPresetGroup.moreLite,
    );
    final customPresets = Anime4KPresets.getPresetsByGroup(
      Anime4KPresetGroup.custom,
    );

    // 高质量预设
    if (highQualityPresets.isNotEmpty) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            slang.t.anime4k.highQualityPresets,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      );
      for (final preset in highQualityPresets) {
        final isSelected = currentPresetId == preset.id;
        items.add(
          PopupMenuItem<String>(
            value: preset.id,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        preset.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // 快速预设
    if (fastPresets.isNotEmpty) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            slang.t.anime4k.fastPresets,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      );
      for (final preset in fastPresets) {
        final isSelected = currentPresetId == preset.id;
        items.add(
          PopupMenuItem<String>(
            value: preset.id,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        preset.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // 轻量级预设
    if (litePresets.isNotEmpty) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            slang.t.anime4k.litePresets,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      );
      for (final preset in litePresets) {
        final isSelected = currentPresetId == preset.id;
        items.add(
          PopupMenuItem<String>(
            value: preset.id,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        preset.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // 更多轻量级预设
    if (moreLitePresets.isNotEmpty) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            slang.t.anime4k.moreLitePresets,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      );
      for (final preset in moreLitePresets) {
        final isSelected = currentPresetId == preset.id;
        items.add(
          PopupMenuItem<String>(
            value: preset.id,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        preset.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // 自定义预设
    if (customPresets.isNotEmpty) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            slang.t.anime4k.customPresets,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      );
      for (final preset in customPresets) {
        final isSelected = currentPresetId == preset.id;
        items.add(
          PopupMenuItem<String>(
            value: preset.id,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        preset.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return items;
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
