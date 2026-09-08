import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/xr_immersive_service.dart';
import '../../../../../routes/app_router.dart';
import 'player_settings_drawer.dart';
import 'player_icon.dart';
import 'toolbar_fade_visibility.dart';
import '../../controllers/my_video_state_controller.dart';
import '../../../../../../i18n/strings.g.dart' as slang;
import 'package:floating/floating.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import '../../../../../../common/anime4k_presets.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'vr/vr_format_menu.dart';

/// 顶部工具栏高度（窗口态）。设计常量，不是测量值，但必须只存在这一份 ——
/// 任何要相对工具栏定位的图层都从这里取，否则改一处漏一处。
const double kPlayerTopToolbarHeight = 48.0;

/// 顶部工具栏高度（全屏态）。
const double kPlayerTopToolbarHeightFullscreen = 60.0;

/// 工具栏本体从播放器栈的 y=0 起画、高度就是本值，所以它的下边缘在 Stack 坐标
/// 系里恰好等于本值（状态栏那一条由 [PlayerTopScrimStrip] 在栈**外面**补）。
double playerTopToolbarHeight(bool isFullScreen) =>
    isFullScreen ? kPlayerTopToolbarHeightFullscreen : kPlayerTopToolbarHeight;

/// 顶部遮罩最深处那档黑。[TopToolbar] 与 [PlayerTopScrimStrip] 是同一层遮罩的
/// 两半，必须共用这一个值，否则接缝处会出现一道台阶。
const int kPlayerTopScrimAlpha = 179;

/// 状态栏那一条的遮罩 —— 顶部遮罩的**上半截**。
///
/// ⛔ 它不能由 [TopToolbar] 自己画（试过，画不到）。工具栏住在播放器栈那只
/// `Stack` 里，而栈的坐标原点已经在状态栏**下面**（外层 `Container` 带
/// `padding.top = 状态栏`）；负坐标那一段会被 `Stack` 默认的 `Clip.hardEdge`
/// 整只裁掉。
///
/// 2026-08-30 真机取证（OnePlus Pad，剧院模式开）：状态栏那条是 (13,10,18)，
/// 紧挨着的工具栏顶是 (4,3,5)，中间一条清清楚楚的接缝——用户报的「状态栏位置
/// 看不到阴影」就是它。剧院模式下那一条是**亮的模糊封面**，接缝尤其显眼。
///
/// 所以这一半画在播放器栈**外面**、与剧院背景同级，跟着工具栏同一条动画淡入
/// 淡出。
class PlayerTopScrimStrip extends StatelessWidget {
  const PlayerTopScrimStrip({super.key, required this.animation});

  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ToolbarFadeVisibility(
        animation: animation,
        child: ColoredBox(color: Colors.black.withAlpha(kPlayerTopScrimAlpha)),
      ),
    );
  }
}

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
  Timer? _wifiSignalTimer;
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
    // 沉浸空间的可用性只随「进/出沉浸空间」变化，进播放器时刷一次就够。
    // 非 XR 设备上这条会因为通道未注册而直接返回 false，不会有额外开销。
    Get.find<XrImmersiveService>().refreshAvailability();
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _wifiSignalTimer?.cancel();
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
      _wifiSignalTimer?.cancel();
      _wifiSignalTimer = Timer.periodic(const Duration(seconds: 5), (
        timer,
      ) async {
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

  /// 根据时间段获取时间图标
  Widget _buildTimeIcon(DateTime time) {
    final hour = time.hour;

    PlayerSymbol iconData;
    if (hour >= 6 && hour < 11) {
      // Morning
      iconData = PlayerSymbol.sunrise;
    } else if (hour >= 11 && hour < 17) {
      // Day
      iconData = PlayerSymbol.sun;
    } else if (hour >= 17 && hour < 19) {
      // Evening
      iconData = PlayerSymbol.sunrise;
    } else {
      // Night
      iconData = PlayerSymbol.moon;
    }

    return PlayerIcon(iconData, color: Colors.white, size: 16);
  }

  Widget _buildBatteryIcon(int level, BatteryState state) {
    final isCharging =
        state == BatteryState.charging || state == BatteryState.full;
    final color = isCharging
        ? const Color(0xFF4CAF50)
        : level <= 20
        ? const Color(0xFFF44336)
        : Colors.white;
    return PlayerBatteryIcon(level: level, charging: isCharging, color: color);
  }

  /// 判断是否应该显示网络状态
  bool _shouldShowNetworkStatus() {
    // 只显示 WiFi、移动网络、宽带和无网络
    return _connectivityResult == ConnectivityResult.wifi ||
        _connectivityResult == ConnectivityResult.mobile ||
        _connectivityResult == ConnectivityResult.ethernet ||
        _connectivityResult == ConnectivityResult.none;
  }

  /// 与播放控制共用圆角符号，状态槽位仍保持 20 × 16。
  Widget _buildNetworkStatus() {
    final symbol = switch (_connectivityResult) {
      ConnectivityResult.wifi => PlayerSymbol.wifi,
      ConnectivityResult.mobile => PlayerSymbol.cellular,
      ConnectivityResult.ethernet => PlayerSymbol.ethernet,
      ConnectivityResult.none => PlayerSymbol.wifiOff,
      _ => null,
    };
    if (symbol == null) return const SizedBox.shrink();
    return SizedBox(
      width: 20,
      height: 16,
      child: PlayerIcon(
        symbol,
        size: 16,
        color: _connectivityResult == ConnectivityResult.none
            ? const Color(0xFFF44336)
            : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool isFullScreen = widget.currentScreenIsFullScreen;
    final double toolbarHeight = playerTopToolbarHeight(isFullScreen);
    final double iconSize = isFullScreen ? 24.0 : 20.0;
    final double fontSize = isFullScreen ? 18.0 : 14.0;

    // 淡入淡出显隐（原为位移滑入滑出），隐藏后自动放行指针事件
    return ToolbarFadeVisibility(
      animation: widget.myVideoStateController.animationController,
      child: MouseRegion(
        onEnter: (_) => widget.myVideoStateController.setToolbarHovering(true),
        onExit: (_) => widget.myVideoStateController.setToolbarHovering(false),
        child: Container(
          // 只画自己这一段：状态栏那一条在栈外面（[PlayerTopScrimStrip]）。
          height: toolbarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withAlpha(kPlayerTopScrimAlpha),
                Colors.transparent,
              ],
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
          // ⛔ 竖屏手机（360dp 宽）上这排钮原本摆不下：默认 IconButton 是
          // 48dp 的方框套 20dp 图标，一边空着 14dp，左二右五共七枚就吃掉
          // 336dp，标题只剩 24dp——真机上被压成「R⋯」。所以窄屏换成贴合
          // 图标的紧凑框：命中区仍是整枚方框，只是不再摊那圈空白。
          //
          // 收在 IconButtonTheme 里而不是逐枚传参，是因为这排钮里有
          // [PlaybackHandoffButton]、Anime4K 这些自带 IconButton 的独立
          // 组件——逐枚改必然漏，主题一挂就全跟着走。
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 480;
              final double box = compact ? 36 : 48;
              return IconButtonTheme(
                data: IconButtonThemeData(
                  style: IconButton.styleFrom(
                    minimumSize: Size.square(box),
                    // 图标之外只留下必要的呼吸位；48dp 那档仍走 Material 默认。
                    padding: EdgeInsets.all((box - iconSize) / 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
                            icon: PlayerIcon(
                              PlayerSymbol.back,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            onPressed: () {
                              if (isFullScreen) {
                                widget.myVideoStateController.exitFullscreen();
                              } else if (widget
                                  .myVideoStateController
                                  .isDesktopAppFullScreen
                                  .value) {
                                // 应用内全屏下，返回键先退出应用内全屏，而不是关闭页面
                                widget
                                        .myVideoStateController
                                        .isDesktopAppFullScreen
                                        .value =
                                    false;
                                Get.find<AppService>().showSystemUI();
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
                              icon: PlayerIcon(
                                PlayerSymbol.home,
                                color: Colors.white,
                                size: iconSize,
                              ),
                              // 回到「视频」那一类的首页页签：从订阅进来的落回订阅的
                              // 视频半边，其余（社区 / 图库 / 视频栏）落回视频栏。
                              onPressed: () => goHomeForMedia(MediaType.VIDEO),
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
                            // 电量显示
                            if (_batterySupported) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildBatteryIcon(
                                    _batteryLevel,
                                    _batteryState,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_batteryLevel%',
                                    style: TextStyle(
                                      color:
                                          (_batteryState ==
                                              BatteryState.charging)
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
                            if (_shouldShowNetworkStatus())
                              _buildNetworkStatus(),
                          ],
                        ),
                      ),

                    // 右侧部分
                    Row(
                      children: [
                        // 「进入影院」：把当前视频交给 XR 沉浸空间，作为独立的空间对象呈现
                        // （平面片走幕布，180/360 走球幕，配空间化控制条），而不是继续画在
                        // 这块 2D 面板里。
                        //
                        // ⛔ 露出条件只问「沉浸场景在不在」，**不问设备是不是 Quest**：
                        // standard 变体根本不注册这条通道，可用性天然为 false；
                        // 而 Quest 上应用也可能处在普通 2D 面板形态（场景没起来），
                        // 那时同样不该露出。
                        Obx(() {
                          if (!Get.find<XrImmersiveService>().available.value) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            tooltip: '进入影院',
                            icon: PlayerIcon(
                              PlayerSymbol.theater,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            onPressed: _presentInImmersiveSpace,
                          );
                        }),
                        // 「换个方式放」：一枚钮吐出两条路——交给本机其它播放器，或者
                        // 换一套几何（VR 180/360、左右 3D）在这儿放。合成一枚的理由
                        // （语义同类 + 顶栏宽度）见 [PlaybackHandoffButton] 的类文档。
                        // 摆在投屏旁边是因为语义再同类不过：都是「不这么放」。
                        PlaybackHandoffButton(
                          controller: widget.myVideoStateController,
                          iconSize: iconSize,
                        ),
                        if (!GetPlatform.isWeb &&
                            !GetPlatform.isLinux &&
                            !widget.myVideoStateController.isLocalVideoMode)
                          Obx(
                            () => IconButton(
                              tooltip: t.videoDetail.cast.dlnaCast,
                              icon: PlayerIcon(
                                widget
                                        .myVideoStateController
                                        .dlnaCastService
                                        .isConnected
                                        .value
                                    ? PlayerSymbol.castConnected
                                    : PlayerSymbol.cast,
                                color: Colors.white,
                                size: iconSize,
                              ),
                              onPressed:
                                  widget
                                      .myVideoStateController
                                      .dlnaCastService
                                      .isCasting
                                      .value
                                  ? null
                                  : () => widget.myVideoStateController
                                        .showDlnaCastDialog(),
                            ),
                          ),
                        if (GetPlatform.isAndroid)
                          IconButton(
                            tooltip: t.videoDetail.pipMode,
                            icon: PlayerIcon(
                              PlayerSymbol.pictureInPicture,
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
                          icon: PlayerIcon(
                            PlayerSymbol.more,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          onPressed: () => showPlayerSettingsDrawer(
                            context: context,
                            controller: widget.myVideoStateController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Anime4K 设置按钮。
  ///
  /// 面板走全站统一的玻璃菜单：原来是 `PopupMenuButton`，靠
  /// `PopupMenuItem(enabled: false)` 硬凑分组标题、每条自己拿 Column 排
  /// 「名字 + 说明」，吐出来还是块不透明的 Material 卡片。现在分组标题用
  /// [GlassMenuSectionHeader]、说明用 [GlassMenuOption.description]，选中态
  /// 交给 `selected`（对勾 + 主色），不再自己画 check_circle。
  /// 把当前视频交给沉浸空间呈现。
  ///
  /// 格式走 `vrFormatForImmersive`：用户在「播放模式」里选过就以用户的为准，
  /// 没选过则采纳机器的建议——⛔ 与平面播放器**刻意不同**（那边推断从不自动
  /// 生效），理由见那个 getter 的注释。
  Future<void> _presentInImmersiveSpace() async {
    final c = widget.myVideoStateController;
    final url = c.currentMediaSource;
    if (url == null || url.isEmpty) return;
    await Get.find<XrImmersiveService>().present(
      url: url,
      format: c.vrFormatForImmersive,
      // 标题与 id 是空间控制面板要的：前者显示在面板上，后者让「接着看」列表能
      // 把当前这条高亮出来（否则用户在列表里看不出自己正在放哪条）。
      title: c.videoInfo.value?.title?.trim() ?? '',
      author: c.videoInfo.value?.user?.name ?? '',
      videoId: c.videoId,
      width: c.sourceVideoWidth.value,
      height: c.sourceVideoHeight.value,
      positionMs: c.currentPosition.inMilliseconds,
    );
    // ok == false 表示沉浸场景还没就绪；原生侧已把请求暂存，场景 ready 时会补投，
    // 所以这里不需要报错，也不该给用户弹提示。
  }

  Widget _buildAnime4KButton(BuildContext context, double iconSize) {
    return Tooltip(
      message: slang.t.anime4k.settings,
      child: Builder(
        builder: (anchorContext) => GlassPressable(
          // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到
          // 某一条上松手选中（见 GlassTapArea.opensOverlay）。
          opensOverlay: true,
          onTap: () => _openAnime4KMenu(anchorContext),
          builder: (context, pressed) => SizedBox(
            width: 48,
            height: 48,
            child: PlayerIcon(
              PlayerSymbol.enhance,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAnime4KMenu(BuildContext anchorContext) async {
    final configService = Get.find<ConfigService>();
    final currentPresetId =
        configService[ConfigKey.ANIME4K_PRESET_ID] as String;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: _buildAnime4KMenuEntries(currentPresetId),
    );
    if (picked == null) return;
    await widget.myVideoStateController.switchAnime4KPreset(
      picked == 'disable' ? '' : picked,
    );
  }

  /// Anime4K 菜单条目：一行说明 + 关闭项 + 五组预设。
  List<GlassMenuEntry> _buildAnime4KMenuEntries(String currentPresetId) {
    final bool isEnabled = currentPresetId.isNotEmpty;
    final entries = <GlassMenuEntry>[
      GlassMenuSectionHeader(
        slang.t.anime4k.realTimeVideoUpscalingAndDenoising,
      ),
      GlassMenuOption<String>(
        value: 'disable',
        label: slang.t.anime4k.disable,
        description: slang.t.anime4k.disableDescription,
        selected: !isEnabled,
      ),
    ];

    void addGroup(String title, Anime4KPresetGroup group) {
      final presets = Anime4KPresets.getPresetsByGroup(group);
      if (presets.isEmpty) return;
      entries.add(const GlassMenuSeparator());
      entries.add(GlassMenuSectionHeader(title));
      for (final preset in presets) {
        entries.add(
          GlassMenuOption<String>(
            value: preset.id,
            label: preset.name,
            description: preset.description,
            selected: currentPresetId == preset.id,
          ),
        );
      }
    }

    addGroup(
      slang.t.anime4k.highQualityPresets,
      Anime4KPresetGroup.highQuality,
    );
    addGroup(slang.t.anime4k.fastPresets, Anime4KPresetGroup.fast);
    addGroup(slang.t.anime4k.litePresets, Anime4KPresetGroup.lite);
    addGroup(slang.t.anime4k.moreLitePresets, Anime4KPresetGroup.moreLite);
    addGroup(slang.t.anime4k.customPresets, Anime4KPresetGroup.custom);
    return entries;
  }
}
