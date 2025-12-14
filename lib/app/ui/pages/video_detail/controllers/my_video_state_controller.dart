import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    show ExtendedNestedScrollViewState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/oreno3d_client.dart' show Oreno3dClient;
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/related_media_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/dlna_cast_sheet.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart';
import 'package:i_iwara/common/anime4k_presets.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../../../utils/common_utils.dart';
import '../../../../../utils/easy_throttle.dart';
import '../../../../../utils/glsl_shader_service.dart';
import '../../../../../utils/x_version_calculator_utils.dart';
import '../../../../models/user.model.dart';
import '../../../../models/video_source.model.dart';
import '../../../../models/video.model.dart' as video_model;
import '../../../../services/api_service.dart';
import '../../../../services/config_service.dart';
import '../../../../services/favorite_service.dart';
import '../../../../services/play_list_service.dart';
import '../../../../services/user_service.dart';
import '../../../../services/download_service.dart';
import '../widgets/player/custom_slider_bar_shape_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../widgets/private_or_deleted_video_widget.dart';
import 'package:floating/floating.dart';
import '../services/video_cache_manager.dart';
import 'dlna_cast_service.dart';

enum VideoDetailPageLoadingState {
  init, // 初始化
  loadingVideoInfo, // 加载视频信息
  loadingVideoSource, // 获取视频播放源
  idle, // 空闲状态
  applyingSolution, // 应用解决方案
  addingListeners, // 添加监听器
  successFecthVideoDurationInfo, // 成功获取视频时长信息
  successFecthVideoHeightInfo, // 成功获取视频高度信息
  playerError, // 播放器错误
}

class MyVideoStateController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final String? videoId;
  final Map<String, dynamic>? extData;
  final AppService appS = Get.find();
  late Player player;
  late VideoController videoController;
  late VolumeController? volumeController;
  final PlaybackHistoryService _playbackHistoryService = Get.find();
  final ApiService _apiService = Get.find();
  final ConfigService _configService = Get.find();

  // 缓存相关
  static final VideoCacheManager _cacheManager = VideoCacheManager();

  // DLNA 投屏服务
  DlnaCastService get _dlnaCastService => DlnaCastService.instance;

  // Oreno3D相关状态
  final Rxn<Oreno3dVideoDetail> oreno3dVideoDetail = Rxn<Oreno3dVideoDetail>();
  final RxBool isOreno3dMatching = false.obs; // 是否正在匹配oreno3d视频

  // 视频详情页信息
  RxBool isCommentSheetVisible = false.obs; // 评论面板是否可见
  OtherAuthorzMediasController? otherAuthorzVideosController; // 作者的其他视频控制器

  // 收藏和播放列表状态
  final RxBool isInAnyFavorite = false.obs; // 视频是否在任何收藏夹中
  final RxBool isInAnyPlaylist = false.obs; // 视频是否在任何播放列表中
  final RxBool hasAnyDownloadTask = false.obs; // 视频是否有任何下载任务（任意清晰度）

  // 状态
  // 播放器状态
  Duration currentPosition = Duration.zero;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxBool videoPlaying = true.obs;
  final RxBool videoBuffering = true.obs;
  final RxBool sliderDragLoadFinished = true.obs; // 拖动进度条加载完成
  final RxDouble playerPlaybackSpeed = 1.0.obs; // 播放速度
  final RxBool isDesktopAppFullScreen = false.obs; // 是否是应用全屏
  bool firstLoaded = false;
  // 显示用的时间变量
  final Rx<Duration> toShowCurrentPosition = Duration.zero.obs;
  Timer? _displayUpdateTimer;

  // 锁定隐藏工具栏
  final RxBool isToolbarsLocked = false.obs;

  // 视频信息 | 详情页状态
  final Rx<VideoDetailPageLoadingState> pageLoadingState =
      VideoDetailPageLoadingState.init.obs;
  final Rxn<Widget> mainErrorWidget = Rxn<Widget>(); // 错误信息
  final Rxn<String> videoErrorMessage = Rxn<String>(); // 视频错误信息
  final Rxn<String> videoSourceErrorMessage = Rxn<String>(); // 视频源错误信息
  final Rxn<video_model.Video> videoInfo = Rxn<video_model.Video>(); // 视频信息
  final RxBool videoPlayerReady = false.obs; // 播放器是否准备好
  final RxInt sourceVideoWidth = 1920.obs; // 视频宽度
  final RxInt sourceVideoHeight = 1080.obs; // 视频高度
  final RxDouble aspectRatio = (16 / 9).obs; // 视频宽高比
  final RxList<VideoResolution> videoResolutions = <VideoResolution>[].obs;
  final Rxn<String> currentResolutionTag = Rxn<String>();
  final RxBool isDescriptionExpanded = false.obs;
  final RxBool isFullscreen = false.obs;
  final RxList<VideoSource> currentVideoSourceList = <VideoSource>[].obs;

  // 快进和后退时间设置
  final RxList<BufferRange> buffers = <BufferRange>[].obs; // 缓冲区段列表

  late AnimationController animationController;
  late Animation<Offset> topBarAnimation;
  late Animation<Offset> bottomBarAnimation;

  StreamSubscription<bool>? bufferingSubscription;
  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<Duration?>? durationSubscription;
  StreamSubscription<int?>? widthSubscription;
  StreamSubscription<int?>? heightSubscription;
  StreamSubscription<bool>? playingSubscription;
  StreamSubscription<Duration>? bufferSubscription;
  StreamSubscription<String>? errorSubscription; // 添加错误监听订阅

  Timer? _autoHideTimer;
  final _autoHideDelay = const Duration(seconds: 3); // 3秒后自动隐藏
  final RxBool _isInteracting = false.obs; // 是否正在交互（如拖动进度条）
  final RxBool _isHoveringToolbar = false.obs; // 是否正在悬浮在工具栏上
  final RxBool _isMouseHoveringPlayer = false.obs; // 是否鼠标悬浮在播放器上
  Timer? _mouseMovementTimer; // 鼠标移动检测定时器

  // 是否显示进度预览
  final RxBool isSeekPreviewVisible = false.obs;
  // 预览位置
  final Rx<Duration> previewPosition = Duration.zero.obs;

  // 历史记录
  final HistoryRepository _historyRepository = HistoryRepository();

  // 添加一个新的变量来跟踪是否正在等待seek完成
  final RxBool isWaitingForSeek = false.obs;

  // 添加一个标志位，表示是否正在横向拖拽
  final RxBool isHorizontalDragging = false.obs;

  // 添加一个标志位，表示是否正在通过手势调节音量
  bool _isAdjustingVolumeByGesture = false;
  // 添加音量监听器的取消函数
  StreamSubscription<double>? _volumeListenerDisposer;

  // 在类的成员变量区域添加:
  final RxBool showResumePositionTip = false.obs;
  final Rx<Duration> resumePosition = Duration.zero.obs;
  Timer? _resumeTipTimer;

  // 在类成员变量区域添加画中画状态标识
  final RxBool isPiPMode = false.obs;

  // 在类成员变量区域添加
  StreamSubscription<PiPStatus>? _pipStatusSubscription;

  // 在MyVideoStateController类成员变量区域添加
  final RxBool isSlidingBrightnessZone = false.obs; // 是否在滑动亮度区域
  final RxBool isSlidingVolumeZone = false.obs; // 是否在滑动音量区域
  final RxBool isLongPressing = false.obs; // 是否在长按
  final RxDouble currentLongPressSpeed = 1.0.obs; // 长按时的当前播放速度（可通过滑动调整）

  // 节流相关变量
  Timer? _positionUpdateThrottleTimer;
  static const _positionUpdateThrottleInterval = Duration(
    milliseconds: 200,
  ); // 正常模式200ms节流间隔
  static const _longPressPositionUpdateInterval = Duration(
    milliseconds: 500,
  ); // 长按模式500ms节流间隔
  Duration _lastPosition = Duration.zero;

  // 在类成员变量区域添加
  Timer? _lockButtonHideTimer;
  final RxBool isLockButtonVisible = true.obs;

  // 添加 Dio CancelToken
  final CancelToken _cancelToken = CancelToken();
  // 添加 disposed 标志位
  bool _isDisposed = false;
  // 添加随机ID用于节流key，避免与其他视频实例冲突
  late final String randomId;

  // 添加倍速播放防抖定时器
  Timer? _speedChangeDebouncer;
  Timer? _bufferUpdateThrottleTimer;

  // 预览播放器相关变量
  Player? previewPlayer;
  VideoController? previewVideoController;
  Timer? _previewSeekThrottleTimer;
  String? previewVideoUrl;
  final RxBool isPreviewPlayerReady = false.obs;
  StreamSubscription<Duration?>? previewDurationSubscription;
  StreamSubscription<bool>? previewPlayingSubscription;
  // 预览 seek 最新目标位置（与 EasyThrottle 配合使用）
  Duration? _latestPreviewSeekPosition;

  // 滚动相关状态管理
  final RxDouble scrollRatio = 0.0.obs; // 滚动比例
  late final ScrollController scrollController = ScrollController();
  final RxBool isExpanding = false.obs; // 是否正在展开
  final RxBool isCollapsing = false.obs; // 是否正在收缩
  late final double minVideoHeight; // 最小视频高度
  late final double maxVideoHeight; // 最大视频高度
  late final double videoHeight; // 当前视频高度

  late final nestedScrollViewKey = GlobalKey<ExtendedNestedScrollViewState>();

  // 视频源过期管理
  Timer? _videoSourceExpirationTimer; // 视频源过期检查定时器
  DateTime? _currentVideoSourceExpireTime; // 视频源的过期时间（所有清晰度共享）

  void refreshScrollView() {
    // 触发重建 - 使用更可靠的方法
    if (nestedScrollViewKey.currentState != null) {
      try {
        // 强制触发 ExtendedNestedScrollView 重建
        (nestedScrollViewKey.currentState as dynamic).setState(() {});
      } catch (ignored) {
        // ignore: empty_catches
      }
    }
  }

  MyVideoStateController(this.videoId, {this.extData});

  @override
  void onInit() async {
    super.onInit();
    _isDisposed = false; // 初始化时确保标志位为 false
    // 生成随机ID用于节流key
    randomId =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
    LogUtils.i(
      '初始化 MyVideoStateController，videoId: $videoId',
      'MyVideoStateController',
    );
    try {
      // 添加生命周期观察者
      WidgetsBinding.instance.addObserver(this);
      LogUtils.d('已添加生命周期观察者', 'MyVideoStateController');

      // 动画
      animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      LogUtils.d('已初始化 animationController', 'MyVideoStateController');

      topBarAnimation =
          Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
          );

      bottomBarAnimation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
          );

      // 初始状态显示工具栏
      animationController.forward();
      if (!_configService[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE]) {
        // 添加自动隐藏工具栏的定时器
        _resetAutoHideTimer();
        // 添加自动隐藏锁定按钮的定时器
        _lockButtonHideTimer = Timer(const Duration(seconds: 3), () {
          if (isToolbarsLocked.value) {
            isLockButtonVisible.value = false;
          }
        });
      }

      // 初始化 VideoController
      player = Player(
        configuration: PlayerConfiguration(
          bufferSize: _getBufferSize(), // 根据配置设置缓冲区大小
          title: 'i_iwara Video Player',
          // 启用异步模式以提高性能
          async: true,
          // 设置合适的协议白名单
          protocolWhitelist: const [
            'udp',
            'rtp',
            'tcp',
            'tls',
            'data',
            'file',
            'http',
            'https',
            'crypto',
          ],
        ),
      );

      videoController = VideoController(
        player,
        configuration: VideoControllerConfiguration(
          enableHardwareAcceleration:
              _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION],
          hwdec: _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION]
              ? _configService[ConfigKey.HARDWARE_DECODING]
              : null,
          // 添加Android平台特定配置来减少ImageReader缓冲区压力
          // androidAttachSurfaceAfterVideoParameters: false,
        ),
      );

      // 初始化滚动相关变量
      final screenSize = Get.size;
      minVideoHeight = max(screenSize.shortestSide * 9 / 16, 250);
      maxVideoHeight = screenSize.longestSide * 0.65;
      videoHeight = minVideoHeight;

      // 添加滚动监听器
      scrollController.addListener(_scrollListener);

      // 移动端初始化音量控制器
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        // 初始化并关闭系统音量UI
        volumeController = VolumeController();
        volumeController?.showSystemUI = false;
        // 添加音量监听
        _volumeListenerDisposer = volumeController?.listener((volume) {
          // 如果当前在long press状态，则不更新音量
          if (isLongPressing.value ||
              isSlidingVolumeZone.value ||
              isSlidingBrightnessZone.value) {
            return;
          }
          if (!_isAdjustingVolumeByGesture) {
            _configService.setSetting(ConfigKey.VOLUME_KEY, volume, save: true);
          }
        });
      }

      if (videoId == null) {
        mainErrorWidget.value = CommonErrorWidget(
          text: slang.t.videoDetail.videoIdIsEmpty,
          children: [
            ElevatedButton(
              onPressed: () => AppService.tryPop(),
              child: Text(slang.t.common.back),
            ),
          ],
        );
        return;
      }

      // 监听 currentVideoSourceList 变化，初始化预览播放器
      // 提前到发起网络/缓存请求之前，避免缓存命中时事件在监听注册之前就触发导致丢失
      currentVideoSourceList.listen((sources) {
        if (!_isDisposed && sources.isNotEmpty) {
          // 延迟初始化，避免影响主播放器加载
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_isDisposed) {
              _initializePreviewPlayer();
            }
          });
        }
      });

      // 使用 WidgetsBinding.instance.addPostFrameCallback 确保基础设置完成
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        fetchVideoDetail(videoId!);
        // 处理从oreno3d传入的详情信息
        _handleOreno3dExtData();
      }
      // });

      // 音量初始化逻辑
      bool keepLastVolumeKey = _configService[ConfigKey.KEEP_LAST_VOLUME_KEY];
      if (keepLastVolumeKey) {
        // 保持之前的音量
        double lastVolume = _configService[ConfigKey.VOLUME_KEY];
        setVolume(lastVolume, save: false);
        LogUtils.d('使用记住的音量: $lastVolume', 'MyVideoStateController');
      } else {
        if (GetPlatform.isAndroid || GetPlatform.isIOS) {
          // 更新配置为当前的系统音量
          double currentVolume = await volumeController?.getVolume() ?? 0.4;
          _configService.setSetting(
            ConfigKey.VOLUME_KEY,
            currentVolume,
            save: true,
          );
          LogUtils.d('使用系统音量: $currentVolume', 'MyVideoStateController');
        } else {
          // 桌面平台使用配置中的默认音量
          double defaultVolume = 1;
          setVolume(defaultVolume, save: false);
          LogUtils.d('使用默认音量: $defaultVolume', 'MyVideoStateController');
        }
      }

      // 设置亮度
      setDefaultBrightness();

      // 想办法让native player默认走系统代理
      if (player.platform is! NativePlayer) return;
      if (player.platform is NativePlayer &&
          _configService[ConfigKey.USE_PROXY]) {
        bool useProxy = _configService[ConfigKey.USE_PROXY];
        String proxyUrl = _configService[ConfigKey.PROXY_URL];
        LogUtils.i(
          '使用代理: $useProxy, 代理地址: $proxyUrl',
          'MyVideoStateController',
        );
        if (useProxy && proxyUrl.isNotEmpty) {
          // 如果是以 https 开头的地址，需要转换为 http
          var finalProxyUrl = proxyUrl;
          if (proxyUrl.startsWith('https://')) {
            finalProxyUrl = proxyUrl.replaceFirst('https://', 'http://');
          }
          // 如果没有以 http 开头，需要加上 http://
          if (!proxyUrl.startsWith('http://')) {
            finalProxyUrl = 'http://$proxyUrl';
          }
          (player.platform as dynamic).setProperty('http-proxy', finalProxyUrl);
        }
      }

      // 应用音视频配置
      await _applyPlayerConfiguration();

      // 添加画中画状态监听
      _setupPiPListener();

      // 启动显示时间更新定时器
      _startDisplayTimer();
    } catch (e) {
      LogUtils.e('初始化失败: $e', tag: 'MyVideoStateController', error: e);
      if (!_isDisposed) {
        String errorMessage = CommonUtils.parseExceptionMessage(e);
        mainErrorWidget.value = CommonErrorWidget(
          text: errorMessage,
          children: [
            ElevatedButton(
              onPressed: () => AppService.tryPop(),
              child: Text(slang.t.common.back),
            ),
          ],
        );
      }
    }
  }

  void _setupPiPListener() {
    if (GetPlatform.isAndroid) {
      // 添加防抖
      Timer? debounceTimer;
      _pipStatusSubscription = Floating().pipStatusStream
          .distinct() // 避免重复状态
          .listen((status) {
            debounceTimer?.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 100), () {
              if (status == PiPStatus.enabled && !isPiPMode.value) {
                enterPiPMode();
              } else if (status != PiPStatus.enabled && isPiPMode.value) {
                exitPiPMode();
              }
            });
          });
    }
  }

  // 设置亮度
  /// 处理从oreno3d传入的扩展数据
  void _handleOreno3dExtData() {
    if (extData != null && extData!.containsKey('oreno3dVideoDetailInfo')) {
      try {
        final oreno3dData =
            extData!['oreno3dVideoDetailInfo'] as Map<String, dynamic>;
        oreno3dVideoDetail.value = Oreno3dVideoDetail.fromJson(oreno3dData);
        isOreno3dMatching.value = false;
        LogUtils.d(
          '成功从extData获取oreno3d视频详情信息: ${oreno3dVideoDetail.value?.title}',
          'MyVideoStateController',
        );
      } catch (e) {
        LogUtils.e(
          '解析oreno3d扩展数据失败: $e',
          tag: 'MyVideoStateController',
          error: e,
        );
      }
    }
  }

  /// 通过视频标题和作者名匹配oreno3d视频信息
  Future<void> _tryMatchOreno3dVideo() async {
    // 如果已经匹配到oreno3d视频信息，则不进行匹配
    if (oreno3dVideoDetail.value != null ||
        videoInfo.value == null ||
        _isDisposed) {
      return;
    }

    final videoTitle = videoInfo.value?.title;
    final authorName = videoInfo.value?.user?.name;

    if (videoTitle == null || videoTitle.isEmpty) return;

    // 设置加载状态
    isOreno3dMatching.value = true;

    try {
      // 检查是否已被销毁
      if (_isDisposed) return;

      final oreno3dClient = Oreno3dClient();
      final searchResult = await oreno3dClient.searchVideos(
        keyword: videoTitle,
      );

      // 查找匹配的视频（先用作者名过滤，再用标题相似度找出最佳匹配）
      Oreno3dVideo? matchedVideo;
      List<Oreno3dVideo> authorFilteredVideos = [];

      // 第一步：用作者名进行严格过滤
      if (authorName != null) {
        authorFilteredVideos = searchResult.videos
            .where(
              (video) => video.author.toLowerCase() == authorName.toLowerCase(),
            )
            .toList();
      }

      // 第二步：从过滤结果中找出标题最相似的视频
      if (authorFilteredVideos.isNotEmpty) {
        double bestSimilarity = 0.0;
        for (final video in authorFilteredVideos) {
          final similarity = _calculateTitleSimilarity(videoTitle, video.title);
          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
            matchedVideo = video;
          }
        }

        // 如果作者匹配的视频标题相似度太低，则考虑所有视频
        if (bestSimilarity < 0.6) {
          matchedVideo = null;
        }
      }

      // 如果没有作者匹配的视频或相似度太低，则从所有视频中找标题最相似的
      if (matchedVideo == null) {
        double bestSimilarity = 0.0;
        for (final video in searchResult.videos) {
          final similarity = _calculateTitleSimilarity(videoTitle, video.title);
          if (similarity > bestSimilarity && similarity > 0.8) {
            bestSimilarity = similarity;
            matchedVideo = video;
          }
        }
      }

      if (matchedVideo != null && !_isDisposed) {
        // 获取详细信息
        final detail = await oreno3dClient.getVideoDetailParsed(
          matchedVideo.id,
        );

        // 再次检查是否已被销毁
        if (_isDisposed) return;

        if (detail != null) {
          oreno3dVideoDetail.value = detail;
          LogUtils.d(
            '成功匹配oreno3d视频: ${detail.title}',
            'MyVideoStateController',
          );
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.e(
          '匹配oreno3d视频失败: $e',
          tag: 'MyVideoStateController',
          error: e,
        );
      }
    } finally {
      // 无论成功还是失败，都要清除加载状态
      if (!_isDisposed) {
        isOreno3dMatching.value = false;
      }
    }
  }

  /// 计算标题相似度（简单的字符匹配）
  double _calculateTitleSimilarity(String title1, String title2) {
    final words1 = title1.toLowerCase().split(' ');
    final words2 = title2.toLowerCase().split(' ');

    int matchCount = 0;
    for (final word1 in words1) {
      for (final word2 in words2) {
        if (word1.contains(word2) || word2.contains(word1)) {
          matchCount++;
          break;
        }
      }
    }

    return matchCount / words1.length;
  }

  // 设置亮度
  void setDefaultBrightness() {
    // 如果没有设置过亮度，则不设置默认值
    if (!CommonConstants.isSetBrightness) return;
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      bool keepLastBrightnessKey =
          _configService[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY];
      if (keepLastBrightnessKey) {
        double lastBrightness = _configService[ConfigKey.BRIGHTNESS_KEY];
        try {
          LogUtils.d("设置亮度: $lastBrightness", '详情页路由监听');
          ScreenBrightness().setApplicationScreenBrightness(lastBrightness);
        } catch (e) {
          LogUtils.e('设置亮度失败: $e', tag: 'MyVideoStateController', error: e);
        }
      }
    }
  }

  // 获取缓冲区大小
  int _getBufferSize() {
    bool expandBuffer = _configService[ConfigKey.EXPAND_BUFFER];
    if (expandBuffer) {
      return 32 * 1024 * 1024; // 32MB
    } else {
      return 4 * 1024 * 1024; // 4MB
    }
  }

  // 应用播放器配置
  Future<void> _applyPlayerConfiguration() async {
    if (player.platform is! NativePlayer) return;

    final platform = player.platform as NativePlayer;

    try {
      // 设置视频同步模式
      String videoSync = _configService[ConfigKey.VIDEO_SYNC];
      await platform.setProperty("video-sync", videoSync);
      LogUtils.d('设置视频同步模式: $videoSync', 'MyVideoStateController');

      // 设置音频输出（仅Android）
      if (Platform.isAndroid) {
        bool useOpenSLES = _configService[ConfigKey.USE_OPENSLES];
        String ao = useOpenSLES ? "opensles,audiotrack" : "audiotrack,opensles";
        await platform.setProperty("ao", ao);
        LogUtils.d('设置音频输出: $ao', 'MyVideoStateController');
      }

      // 设置硬件解码
      bool enableHA = _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION];
      if (enableHA) {
        String hwdec = _configService[ConfigKey.HARDWARE_DECODING];
        await platform.setProperty("hwdec", hwdec);
        LogUtils.d('设置硬件解码: $hwdec', 'MyVideoStateController');
      } else {
        await platform.setProperty("hwdec", "no");
        LogUtils.d('禁用硬件解码', 'MyVideoStateController');
      }
    } catch (e) {
      LogUtils.e('应用播放器配置失败: $e', tag: 'MyVideoStateController', error: e);
    }
  }

  @override
  void onClose() {
    LogUtils.i('MyVideoStateController onClose 被调用', 'MyVideoStateController');
    _isDisposed = true;

    // 首先取消所有定时器，避免dispose后还有回调执行
    _positionUpdateThrottleTimer?.cancel();
    _displayUpdateTimer?.cancel();
    _lockButtonHideTimer?.cancel();
    _autoHideTimer?.cancel();
    _mouseMovementTimer?.cancel();
    _resumeTipTimer?.cancel();
    _speedChangeDebouncer?.cancel();
    _bufferUpdateThrottleTimer?.cancel();
    _previewSeekThrottleTimer?.cancel();
    _videoSourceExpirationTimer?.cancel();
    LogUtils.d('所有定时器已取消', 'MyVideoStateController');

    // 取消网络请求
    _cancelToken.cancel("Controller is being disposed");
    LogUtils.d('网络请求已取消', 'MyVideoStateController');

    try {
      // 取消 Stream 订阅
      _cancelSubscriptions();
      _volumeListenerDisposer?.cancel();
      _pipStatusSubscription?.cancel();
      errorSubscription?.cancel(); // 取消错误监听订阅
      LogUtils.d('所有订阅已取消', 'MyVideoStateController');

      // 释放播放器资源
      try {
        player.dispose();
        LogUtils.w('播放器资源已释放', 'MyVideoStateController');
      } catch (e) {
        LogUtils.w('尝试释放播放器资源时出错: $e', 'MyVideoStateController');
      }

      // 释放预览播放器资源
      _disposePreviewPlayer();

      // 移除生命周期观察者
      WidgetsBinding.instance.removeObserver(this);
      LogUtils.d('生命周期观察者已移除', 'MyVideoStateController');

      // 获取当前的主题是否为亮色
      final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

      // 设置状态栏颜色为黑色字体
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDarkMode
              ? Brightness.light
              : Brightness.dark,
        ),
      );

      // 销毁动画控制器
      animationController.dispose();

      // 清理滚动控制器
      if (scrollController.hasClients) {
        scrollController.removeListener(_scrollListener);
        scrollController.dispose();
        LogUtils.d('滚动控制器已清理', 'MyVideoStateController');
      }

      // 保存播放记录
      final Duration lastPosition = currentPosition;
      final Duration lastTotalDuration = totalDuration.value;

      if (videoId != null && lastTotalDuration.inMilliseconds > 0) {
        final currentMs = lastPosition.inMilliseconds;
        final totalMs = lastTotalDuration.inMilliseconds;

        if (currentMs <= 5000 || currentMs >= (totalMs - 5000)) {
          _playbackHistoryService.deletePlaybackHistory(videoId!);
        } else {
          _playbackHistoryService.savePlaybackHistory(
            videoId!,
            totalMs,
            currentMs,
          );
        }
      }

      super.onClose();
    } catch (e) {
      LogUtils.e('关闭控制器时发生错误: $e', tag: 'MyVideoStateController', error: e);
      super.onClose();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // LogUtils.d('应用生命周期状态变更: $state', 'MyVideoStateController');

    // 当应用从后台恢复到前台时
    if (state == AppLifecycleState.resumed) {
      // LogUtils.d('应用进入前台，设置默认屏幕亮度', 'MyVideoStateController');
      setDefaultBrightness();
    }

    super.didChangeAppLifecycleState(state);
  }

  // 取消监听
  Future<void> _cancelSubscriptions() async {
    await Future.wait([
      bufferingSubscription?.cancel() ?? Future.value(),
      positionSubscription?.cancel() ?? Future.value(),
      durationSubscription?.cancel() ?? Future.value(),
      widthSubscription?.cancel() ?? Future.value(),
      heightSubscription?.cancel() ?? Future.value(),
      playingSubscription?.cancel() ?? Future.value(),
      bufferSubscription?.cancel() ?? Future.value(),
      errorSubscription?.cancel() ?? Future.value(), // 取消错误监听订阅
    ]);
  }

  /// 获取视频详情信息
  void fetchVideoDetail(String videoId) async {
    if (_isDisposed) return;

    LogUtils.i('开始获取视频详情，videoId: $videoId', 'MyVideoStateController');
    pageLoadingState.value = VideoDetailPageLoadingState.loadingVideoInfo;
    videoErrorMessage.value = null;
    mainErrorWidget.value = null;

    // 检查视频信息缓存
    final cachedVideoInfo = _cacheManager.getVideoInfo(videoId);
    if (cachedVideoInfo != null) {
      // 缓存命中时，先将 liked 和 numLikes 设置为 null 表示 loading 状态
      videoInfo.value = cachedVideoInfo.copyWith(liked: null, numLikes: null);

      // 缓存命中时，立即开始并行任务
      final List<Future<void>> parallelTasks = [];

      // 1. 添加历史记录（可以并行执行）
      parallelTasks.add(_addHistoryRecord());

      // 2. 获取作者其他视频（可以并行执行）
      String? authorId = cachedVideoInfo.user?.id;
      if (authorId != null) {
        parallelTasks.add(_initializeAuthorVideosController(authorId));
      }

      // 3. Oreno3D匹配（可以并行执行，但只在没有extData的情况下）
      if (oreno3dVideoDetail.value == null &&
          (extData == null ||
              !extData!.containsKey('oreno3dVideoDetailInfo'))) {
        parallelTasks.add(_tryMatchOreno3dVideo());
      }

      // 4. 异步请求最新视频信息（不阻塞UI渲染）
      parallelTasks.add(_refreshVideoLikeInfo(videoId, cachedVideoInfo));

      // 5. 检查收藏和播放列表状态（不阻塞UI渲染）
      parallelTasks.add(checkFavoriteAndPlaylistStatus());

      // 6. 检查下载任务状态（不阻塞UI渲染）
      parallelTasks.add(checkDownloadTaskStatus());

      // 继续获取视频源 - 仅对站内视频
      if (cachedVideoInfo.fileUrl != null && !cachedVideoInfo.isExternalVideo) {
        fetchVideoSource();
      } else if (cachedVideoInfo.isExternalVideo) {
        // 对于站外视频，直接设置为idle状态
        pageLoadingState.value = VideoDetailPageLoadingState.idle;
        // 设置站外视频的默认宽高比（16:9）
        aspectRatio.value = 16 / 9;
        // 站外视频不需要播放器准备，直接设置为true
        videoPlayerReady.value = true;
        LogUtils.d('站外视频（缓存命中），直接设置为idle状态', 'MyVideoStateController');
      }

      // 并行执行其他任务，但不等待
      if (parallelTasks.isNotEmpty) {
        Future.wait(parallelTasks).catchError((e) {
          if (!_isDisposed) {
            LogUtils.w('并行任务执行失败: $e', 'MyVideoStateController');
          }
          return <void>[];
        });
      }

      return;
    } else {
      try {
        if (_isDisposed) return;

        // 1. 获取视频信息(私密视频会以异常的形式捕获)
        var res = await _apiService.get(
          '/video/$videoId',
          cancelToken: _cancelToken,
        );

        if (_isDisposed) return;

        videoInfo.value = video_model.Video.fromJson(res.data);

        // 缓存视频信息
        _cacheManager.cacheVideoInfo(videoId, videoInfo.value!);

        if (videoInfo.value == null) {
          if (!_isDisposed) {
            mainErrorWidget.value = CommonErrorWidget(
              text: slang.t.videoDetail.videoInfoIsEmpty,
              children: [
                ElevatedButton(
                  onPressed: () => AppService.tryPop(),
                  child: Text(slang.t.common.back),
                ),
              ],
            );
          }
          return;
        }

        // 获取作者ID用于后续操作
        String? authorId = videoInfo.value!.user?.id;

        // 并行执行以下操作（不需要等待的）
        final List<Future<void>> parallelTasks = [];

        // 1. 添加历史记录（可以并行执行）
        if (videoInfo.value != null) {
          parallelTasks.add(_addHistoryRecord());
        }

        // 2. 获取作者其他视频（可以并行执行）
        if (authorId != null) {
          parallelTasks.add(_initializeAuthorVideosController(authorId));
        }

        // 3. Oreno3D匹配（可以并行执行，但只在没有extData的情况下）
        if (oreno3dVideoDetail.value == null &&
            (extData == null ||
                !extData!.containsKey('oreno3dVideoDetailInfo'))) {
          parallelTasks.add(_tryMatchOreno3dVideo());
        }

        // 4. 获取视频源（关键路径，需要等待）- 仅对站内视频
        if (videoInfo.value!.fileUrl != null &&
            !videoInfo.value!.isExternalVideo) {
          // 立即开始获取视频源，不等待其他任务
          fetchVideoSource();
        } else if (videoInfo.value!.isExternalVideo) {
          // 对于站外视频，直接设置为idle状态
          pageLoadingState.value = VideoDetailPageLoadingState.idle;
          // 设置站外视频的默认宽高比（16:9）
          aspectRatio.value = 16 / 9;
          // 站外视频不需要播放器准备，直接设置为true
          videoPlayerReady.value = true;
          LogUtils.d('站外视频，跳过视频源获取，直接设置为idle状态', 'MyVideoStateController');
        }

        // 等待所有任务完成，但设置超时
        if (parallelTasks.isNotEmpty) {
          await Future.wait(parallelTasks);
        }

        // 检查收藏和播放列表状态
        checkFavoriteAndPlaylistStatus();

        // 检查下载任务状态
        checkDownloadTaskStatus();
      } on DioException catch (e) {
        if (_isDisposed || e.type == DioExceptionType.cancel) {
          LogUtils.w('请求被取消或Controller已销毁', 'MyVideoStateController');
          return;
        }
        LogUtils.e(
          '获取视频详情失败 (Dio): $e',
          tag: 'MyVideoStateController',
          error: e,
        );
        if (!_isDisposed) {
          if (e.response?.statusCode == 403) {
            var data = e.response?.data;
            if (data != null &&
                data['message'] != null &&
                data['message'] == 'errors.privateVideo') {
              User author = User.fromJson(data['data']['user']);
              mainErrorWidget.value = PrivateOrDeletedVideoWidget(
                author: author,
                isPrivate: true,
              );
            }
          } else if (e.response?.statusCode == 404) {
            mainErrorWidget.value = PrivateOrDeletedVideoWidget(
              isPrivate: false,
            );
          } else {
            String errorMessage = CommonUtils.parseExceptionMessage(e);
            mainErrorWidget.value = CommonErrorWidget(
              text: errorMessage,
              children: [
                ElevatedButton(
                  onPressed: () => AppService.tryPop(),
                  child: Text(slang.t.common.back),
                ),
              ],
            );
          }
        }
      } catch (e) {
        if (!_isDisposed) {
          LogUtils.e(
            '获取视频详情失败 (Other): $e',
            tag: 'MyVideoStateController',
            error: e,
          );
          String errorMessage = CommonUtils.parseExceptionMessage(e);
          mainErrorWidget.value = CommonErrorWidget(
            text: errorMessage,
            children: [
              ElevatedButton(
                onPressed: () => AppService.tryPop(),
                child: Text(slang.t.common.back),
              ),
            ],
          );
        }
      }
    }
  }

  /// 添加历史记录（异步）
  Future<void> _addHistoryRecord() async {
    try {
      if (videoInfo.value != null) {
        final historyRecord = HistoryRecord.fromVideo(videoInfo.value!);
        LogUtils.d(
          '添加历史记录: ${historyRecord.toJson()}',
          'MyVideoStateController',
        );
        await _historyRepository.addRecordWithCheck(historyRecord);
        if (_isDisposed) return;
      }
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.e('添加历史记录失败', tag: 'MyVideoStateController', error: e);
      }
    }
  }

  /// 初始化作者视频控制器（异步）
  Future<void> _initializeAuthorVideosController(String authorId) async {
    try {
      otherAuthorzVideosController = OtherAuthorzMediasController(
        mediaId: videoId!,
        userId: authorId,
        mediaType: MediaType.VIDEO,
      );
      otherAuthorzVideosController!.fetchRelatedMedias();
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.e('初始化作者视频控制器失败', tag: 'MyVideoStateController', error: e);
      }
    }
  }

  /// 获取视频源信息
  Future<void> fetchVideoSource({bool forceRefresh = false}) async {
    if (_isDisposed) return;
    if (videoInfo.value?.fileUrl == null) {
      return;
    }

    pageLoadingState.value = VideoDetailPageLoadingState.loadingVideoSource;
    videoErrorMessage.value = null;
    videoSourceErrorMessage.value = null;

    // 检查缓存
    final cacheKey = videoInfo.value!.fileUrl!;
    final cachedSources = _cacheManager.getVideoSources(cacheKey);
    final logVideoUrl = videoInfo.value!.fileUrl!;
    // 尝试还原历史记录
    Duration targetDuration = Duration.zero;
    try {
      if (!firstLoaded &&
          _configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]) {
        final history = await _playbackHistoryService.getPlaybackHistory(
          videoId!,
        );
        if (_isDisposed) return;

        if (history != null) {
          final playedDuration = history['played_duration'] as int;
          final totalDurationMs = history['total_duration'] as int;
          // 目标时播放位置 = 当前播放位置 - 4秒
          targetDuration = Duration(
            milliseconds: (playedDuration - 4000).clamp(0, totalDurationMs),
          );
        }
      }
    } catch (e) {
      LogUtils.e('还原历史记录失败: $e', tag: 'MyVideoStateController', error: e);
    }

    if (cachedSources != null && !forceRefresh) {
      final serializedSources = cachedSources
          .map(
            (source) => {
              'id': source.id,
              'name': source.name,
              'view': source.view,
              'download': source.download,
              'type': source.type,
            },
          )
          .toList();
      LogUtils.d(
        '使用缓存视频源($logVideoUrl): ${jsonEncode(serializedSources)}',
        'MyVideoStateController',
      );
      currentVideoSourceList.value = cachedSources;

      var lastUserSelectedResolution =
          _configService[ConfigKey.DEFAULT_QUALITY_KEY];
      videoInfo.value = videoInfo.value!.copyWith(videoSources: cachedSources);

      if (_isDisposed) return;

      await resetVideoInfo(
        title: videoInfo.value!.title ?? '',
        resolutionTag: lastUserSelectedResolution,
        videoResolutions: CommonUtils.convertVideoSourcesToResolutions(
          videoInfo.value!.videoSources,
          filterPreview: true,
        ),
        position: targetDuration,
      );
      return;
    }

    try {
      if (forceRefresh && cachedSources != null) {
        LogUtils.i('强制刷新视频源，忽略缓存: $logVideoUrl', 'MyVideoStateController');
      }

      var res = await _apiService.get(
        videoInfo.value!.fileUrl!,
        headers: {
          'X-Version': XVersionCalculatorUtil.calculateXVersion(
            videoInfo.value!.fileUrl!,
          ),
        },
        cancelToken: _cancelToken,
      );

      if (_isDisposed) return;

      List<dynamic> data = res.data;
      List<VideoSource> sources = data
          .map((item) => VideoSource.fromJson(item))
          .toList();

      final serializedSources = sources
          .map(
            (source) => {
              'id': source.id,
              'name': source.name,
              'view': source.view,
              'download': source.download,
              'type': source.type,
            },
          )
          .toList();
      LogUtils.d(
        '接口获取视频源($logVideoUrl): ${jsonEncode(serializedSources)}',
        'MyVideoStateController',
      );

      // 缓存结果
      _cacheManager.cacheVideoSources(cacheKey, sources);

      currentVideoSourceList.value = sources;

      // 解析视频源过期时间（所有清晰度的过期时间都一样，只需解析一次）
      _currentVideoSourceExpireTime = null;
      for (var source in sources) {
        if (source.view != null) {
          final expireTime = CommonUtils.getVideoLinkExpireTime(source.view!);
          if (expireTime != null) {
            _currentVideoSourceExpireTime = expireTime;
            LogUtils.d('视频源过期时间: $expireTime', 'MyVideoStateController');
            break; // 找到一个有效的过期时间即可
          }
        }
      }

      var lastUserSelectedResolution =
          _configService[ConfigKey.DEFAULT_QUALITY_KEY];
      videoInfo.value = videoInfo.value!.copyWith(videoSources: sources);

      if (_isDisposed) return;
      await resetVideoInfo(
        title: videoInfo.value!.title ?? '',
        resolutionTag: lastUserSelectedResolution,
        videoResolutions: CommonUtils.convertVideoSourcesToResolutions(
          videoInfo.value!.videoSources,
          filterPreview: true,
        ),
        position: targetDuration,
      );

      // 设置视频源过期定时器
      _setupVideoSourceExpirationTimer();
    } catch (e) {
      String errorMessage = CommonUtils.parseExceptionMessage(e);
      if (!_isDisposed) {
        LogUtils.e(
          '获取视频源失败 (Other): $e',
          tag: 'MyVideoStateController',
          error: e,
        );
        videoSourceErrorMessage.value = errorMessage;
      }
    } finally {
      if (!_isDisposed) {
        pageLoadingState.value = VideoDetailPageLoadingState.idle;
      }
    }
  }

  /// 切换清晰度
  Future<void> switchResolution(String resolutionTag) async {
    // 检查控制器是否已销毁
    if (_isDisposed) {
      return;
    }

    if (resolutionTag == currentResolutionTag.value) {
      return;
    }

    // 通过tag找出对应的视频源
    String? url = CommonUtils.findUrlByResolutionTag(
      videoResolutions,
      resolutionTag,
    );
    if (url == null || url.isEmpty) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(slang.t.videoDetail.noVideoSourceFound),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 如果播放器已经准备好，使用无缝切换模式
    if (videoPlayerReady.value) {
      await _switchResolutionSeamlessly(resolutionTag, url);
    } else {
      // 如果播放器还未准备好，使用原有的重置模式
      await resetVideoInfo(
        title: videoInfo.value!.title ?? '',
        resolutionTag: resolutionTag,
        videoResolutions: videoResolutions.toList(),
        position: currentPosition,
      );
    }
  }

  /// 无缝切换分辨率（不显示骨架屏）
  Future<void> _switchResolutionSeamlessly(
    String resolutionTag,
    String url, {
    Duration? startPosition,
  }) async {
    if (_isDisposed) return;

    // 尝试从本地下载获取文件
    String finalUrl = url;
    if (videoId != null) {
      try {
        final downloadService = Get.find<DownloadService>();
        final localPath = await downloadService.getCompletedVideoLocalPath(
          videoId!,
          resolutionTag,
        );

        if (localPath != null && !_isDisposed) {
          // 使用本地文件路径
          finalUrl = 'file://$localPath';
          LogUtils.i(
            '使用本地下载文件播放: videoId=$videoId, quality=$resolutionTag, path=$localPath',
            'MyVideoStateController',
          );
        }
      } catch (e) {
        LogUtils.w('检查本地文件失败，使用在线播放: $e', 'MyVideoStateController');
      }
    }

    // 设置缓冲状态，显示 loading 动画
    videoBuffering.value = true;

    // 取消现有订阅但不重置 videoPlayerReady
    await _cancelSubscriptions();
    if (_isDisposed) return;

    // 清理缓冲区
    _clearBuffers();

    // 更新分辨率信息
    currentResolutionTag.value = resolutionTag;
    sliderDragLoadFinished.value = true;

    try {
      // 打开新的视频源
      LogUtils.i(
        '播放器即将播放视频源 [无缝切换] - 分辨率: $resolutionTag, URL: $finalUrl, 起始位置: ${startPosition?.inSeconds ?? currentPosition.inSeconds}秒, 是否本地文件: ${finalUrl.startsWith("file://")}',
        'MyVideoStateController',
      );
      await player.open(
        Media(finalUrl, start: startPosition ?? currentPosition),
        play: true,
      );

      if (_isDisposed) return;

      // 重新设置监听器（包括 buffering 监听器）
      _setupListenersAfterOpen();
    } catch (e) {
      if (_isDisposed) return;
      LogUtils.e('无缝切换分辨率失败: $e', tag: 'MyVideoStateController', error: e);

      // 切换失败时清理状态
      videoBuffering.value = false;

      // 如果无缝切换失败，回退到重置模式
      videoErrorMessage.value =
          '${slang.t.videoDetail.player.errorWhileLoadingVideoSource}: $e';
    }
  }

  /// 重置视频信息并加载新视频
  Future<void> resetVideoInfo({
    required String title,
    required String resolutionTag,
    required List<VideoResolution> videoResolutions,
    Duration position = Duration.zero,
  }) async {
    if (_isDisposed) return;
    pageLoadingState.value = VideoDetailPageLoadingState.applyingSolution;
    // 重置状态
    await _cancelSubscriptions();
    _clearBuffers();

    this.videoResolutions.value = videoResolutions;
    currentPosition = position;
    currentResolutionTag.value = resolutionTag;
    sliderDragLoadFinished.value = true;
    videoBuffering.value = true;
    videoPlaying.value = true;
    videoErrorMessage.value = null; // 清空之前的错误信息
    mainErrorWidget.value = null;

    // 设置播放模式
    if (_configService[ConfigKey.REPEAT_KEY]) {
      player.setPlaylistMode(PlaylistMode.loop);
    } else {
      player.setPlaylistMode(PlaylistMode.none);
    }

    String? url = CommonUtils.findUrlByResolutionTag(
      videoResolutions,
      resolutionTag,
    );
    if (url == null || url.isEmpty) {
      if (!_isDisposed) {
        mainErrorWidget.value = CommonErrorWidget(
          text: slang.t.videoDetail.noVideoSourceFound,
          children: [
            ElevatedButton(
              onPressed: () => AppService.tryPop(),
              child: Text(slang.t.common.back),
            ),
          ],
        );
      }
      return;
    }

    // 尝试从本地下载获取文件
    String finalUrl = url;
    if (videoId != null) {
      try {
        final downloadService = Get.find<DownloadService>();
        final localPath = await downloadService.getCompletedVideoLocalPath(
          videoId!,
          resolutionTag,
        );

        if (localPath != null && !_isDisposed) {
          // 使用本地文件路径
          finalUrl = 'file://$localPath';
          LogUtils.i(
            '使用本地下载文件播放: videoId=$videoId, quality=$resolutionTag, path=$localPath',
            'MyVideoStateController',
          );
        }
      } catch (e) {
        LogUtils.w('检查本地文件失败，使用在线播放: $e', 'MyVideoStateController');
      }
    }

    if (_isDisposed) return;
    try {
      LogUtils.i(
        '播放器即将播放视频源 [重置模式] - 分辨率: $resolutionTag, URL: $finalUrl, 起始位置: ${currentPosition.inSeconds}秒, 是否本地文件: ${finalUrl.startsWith("file://")}',
        'MyVideoStateController',
      );
      player.open(Media(finalUrl, start: currentPosition), play: true);
      pageLoadingState.value = VideoDetailPageLoadingState.addingListeners;
    } catch (e) {
      if (_isDisposed) return;
      LogUtils.e('Player open 出错: $e', tag: 'MyVideoStateController', error: e);
      videoErrorMessage.value =
          '${slang.t.videoDetail.player.errorWhileLoadingVideoSource}: $e';
      return;
    }
    if (_isDisposed) return;
    try {
      _setupListenersAfterOpen();

      await setShader();
    } catch (e) {
      if (_isDisposed) return;
      LogUtils.e('设置监听器时出错: $e', tag: 'MyVideoStateController', error: e);
      videoErrorMessage.value =
          '${slang.t.videoDetail.player.errorWhileSettingUpListeners}: $e';
    }
  }

  // 封装监听器设置
  void _setupListenersAfterOpen() {
    if (_isDisposed) return;

    _setupPositionListener();

    // 缓冲
    bufferingSubscription = player.stream.buffering.listen((buffering) async {
      if (_isDisposed) return;
      videoBuffering.value = buffering;
    });

    // 总时长
    durationSubscription = player.stream.duration.listen((duration) async {
      if (_isDisposed) return;
      totalDuration.value = duration;
      pageLoadingState.value =
          VideoDetailPageLoadingState.successFecthVideoDurationInfo;
    });

    // 宽度
    widthSubscription = player.stream.width.listen((width) {
      if (_isDisposed) return;
      if (width != null) {
        sourceVideoWidth.value = width;
      }
    });

    // 高度
    heightSubscription = player.stream.height.listen((height) {
      if (_isDisposed) return;
      if (height != null) {
        sourceVideoHeight.value = height;
        // [tip]: 发现每次都是先监听到 width，再监听到height，所以这里先更新宽高比
        pageLoadingState.value =
            VideoDetailPageLoadingState.successFecthVideoHeightInfo;
        _updateAspectRatio();
      }
    });

    // 播放状态
    playingSubscription = player.stream.playing.listen((playing) {
      if (_isDisposed) return;
      if (playing != videoPlaying.value) {
        videoPlaying.value = playing;
        // refreshScrollView();
      }
    });

    // 缓冲区
    bufferSubscription = player.stream.buffer.listen((bufferDuration) {
      if (_isDisposed) return;
      _addBufferRange(bufferDuration);
    });

    // 异常
    errorSubscription = player.stream.error.listen((error) {
      if (_isDisposed) return;

      final String event = error;
      LogUtils.w('播放器错误事件: $event', 'MyVideoStateController');

      // TODO Hack: 针对 mikoto 服务器故障，自动切换到 hime
      // 如果检测到是 Failed to open 错误，并且视频源还是 mikoto 这个子域名，那么就替换当前的所有视频源并更新缓存，为 hime 这个子域名，然后重试
      final info = videoInfo.value;
      final sources = info?.videoSources;
      bool isMikotoSource = false;
      if (sources != null && sources.isNotEmpty) {
        // 检查当前使用的视频源是否是 mikoto
        // 注意：这里简单取第一个视频源检查，实际上应该检查当前播放的 URL，但考虑到 mikoto 故障通常是全站性的，且源结构一致，这样检查应该足够
        isMikotoSource =
            sources.first.view?.contains('mikoto.iwara.tv') == true;
      }

      if (event.startsWith('Failed to open ') &&
          (event.contains('mikoto.iwara.tv') || isMikotoSource)) {
        LogUtils.w(
          '检测到 mikoto 服务器故障，尝试切换到 hime 服务器并重试',
          'MyVideoStateController',
        );

        if (info != null && sources != null && sources.isNotEmpty) {
          final newSources = sources.map((s) {
            return s.copyWithServer('hime.iwara.tv');
          }).toList();

          videoInfo.value = info.copyWith(videoSources: newSources);
          currentVideoSourceList.value = newSources;

          final newResolutions = CommonUtils.convertVideoSourcesToResolutions(
            newSources,
            filterPreview: true,
          );
          videoResolutions.value = newResolutions;

          if (info.fileUrl != null) {
            // 更新缓存
            _cacheManager.cacheVideoSources(info.fileUrl!, newSources);
          }

          if (Get.context != null) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                content: Text(slang.t.videoDetail.player.serverFaultDetectedAutoSwitched),
                duration: const Duration(seconds: 3),
              ),
            );
          }

          refreshPlayer(seekTo: currentPosition);
          return;
        }
      }

      // 针对常见网络/打开失败错误进行节流重试
      if (event.startsWith('Failed to open https://') ||
          event.startsWith('Can not open external file https://') ||
          event.startsWith('tcp: ffurl_read returned ') ||
          event.contains('Connection timed out') ||
          event.startsWith('tcp: Connection to ')) {
        // 记录出错时的播放位置
        final Duration savedErrorPosition = currentPosition;

        LogUtils.i(
          '检测到网络/打开失败错误，开始节流重试，出错位置: $savedErrorPosition',
          'MyVideoStateController',
        );
        EasyThrottle.throttle(
          '${randomId}_player.stream.error.retry',
          const Duration(milliseconds: 10000),
          () async {
            if (videoBuffering.value && buffers.isEmpty) {
              LogUtils.i(
                '开始重试刷新播放器，当前缓冲状态: buffering=${videoBuffering.value}, buffers=${buffers.length}',
                'MyVideoStateController',
              );
              if (Get.context != null) {
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  SnackBar(
                    content: Text(slang.t.mediaPlayer.retryingOpenVideoLink),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
              await fetchVideoSource(forceRefresh: true);
              final bool ok = await refreshPlayer(seekTo: savedErrorPosition);
              if (!ok) {
                LogUtils.w('重试刷新播放器失败', 'MyVideoStateController');
              }
            }
          },
        );
        return;
      }

      // 解码器错误提示
      if (event.startsWith('Could not open codec')) {
        LogUtils.w('检测到解码器错误: $event', 'MyVideoStateController');
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                slang.t.mediaPlayer.decoderOpenFailedWithSuggestion(
                  event: event,
                ),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // 可忽略的打开类错误，静默返回，避免打扰
      if (event.startsWith('Failed to open .') ||
          event.startsWith('Cannot open') ||
          event.startsWith('Can not open')) {
        LogUtils.i('检测到可忽略的打开类错误，已静默处理: $event', 'MyVideoStateController');
        return;
      }

      // 其他错误，给出提示与日志
      LogUtils.w('检测到其他类型的播放器错误，将显示用户提示: $event', 'MyVideoStateController');
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              slang.t.mediaPlayer.videoLoadErrorWithDetail(event: event),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      LogUtils.e('视频加载错误: $event', tag: 'MyVideoStateController');
    });
  }

  /// 刷新播放器（重开当前清晰度与进度）
  Future<bool> refreshPlayer({Duration? seekTo}) async {
    if (_isDisposed) return false;

    try {
      final String? tag = currentResolutionTag.value;
      final String? url = tag == null
          ? null
          : CommonUtils.findUrlByResolutionTag(videoResolutions, tag);

      // 若无法定位当前清晰度 URL，则回退到 resetVideoInfo 使用现有分辨率列表
      if (url == null || url.isEmpty) {
        await resetVideoInfo(
          title: videoInfo.value?.title ?? '',
          resolutionTag:
              currentResolutionTag.value ??
              (_configService[ConfigKey.DEFAULT_QUALITY_KEY] as String),
          videoResolutions: videoResolutions.toList(),
          position: seekTo ?? currentPosition,
        );
        return true;
      }

      final String defaultTag =
          (_configService[ConfigKey.DEFAULT_QUALITY_KEY] is String)
          ? (_configService[ConfigKey.DEFAULT_QUALITY_KEY] as String)
          : '';
      final String fallbackTag = videoResolutions.isNotEmpty
          ? videoResolutions.first.label
          : defaultTag;
      final String resolvedTag = (tag ?? defaultTag).isNotEmpty
          ? (tag ?? defaultTag)
          : fallbackTag;

      if (resolvedTag.isEmpty) {
        await resetVideoInfo(
          title: videoInfo.value?.title ?? '',
          resolutionTag: currentResolutionTag.value ?? defaultTag,
          videoResolutions: videoResolutions.toList(),
          position: seekTo ?? currentPosition,
        );
        return true;
      }

      await _switchResolutionSeamlessly(
        resolvedTag,
        url,
        startPosition: seekTo,
      );
      return true;
    } catch (e) {
      LogUtils.e('刷新播放器失败: $e', tag: 'MyVideoStateController', error: e);
      return false;
    }
  }

  /// 设置视频源过期定时器
  void _setupVideoSourceExpirationTimer() {
    _videoSourceExpirationTimer?.cancel();

    // 如果没有过期时间，则不设置定时器
    if (_currentVideoSourceExpireTime == null) {
      return;
    }

    final expireTime = _currentVideoSourceExpireTime!;

    // 计算刷新时间：在过期前5分钟刷新
    final refreshTime = expireTime.subtract(const Duration(minutes: 5));
    final now = DateTime.now();

    if (now.isAfter(refreshTime)) {
      // 已经过期或即将过期，立即刷新
      LogUtils.w('视频源即将过期或已过期，立即刷新', 'MyVideoStateController');
      _refreshVideoSourceBeforeExpiration();
    } else {
      // 设置定时器在刷新时间触发
      final delay = refreshTime.difference(now);
      LogUtils.d(
        '设置视频源刷新定时器，将在 ${delay.inMinutes} 分钟后刷新 (过期时间: $expireTime)',
        'MyVideoStateController',
      );

      _videoSourceExpirationTimer = Timer(delay, () {
        _refreshVideoSourceBeforeExpiration();
      });
    }
  }

  /// 刷新视频源（过期时间管理）
  Future<void> _refreshVideoSourceBeforeExpiration() async {
    if (_isDisposed || videoInfo.value?.fileUrl == null) {
      return;
    }

    LogUtils.i('开始刷新视频源（过期时间管理）', 'MyVideoStateController');

    try {
      // 强制刷新视频源
      var res = await _apiService.get(
        videoInfo.value!.fileUrl!,
        headers: {
          'X-Version': XVersionCalculatorUtil.calculateXVersion(
            videoInfo.value!.fileUrl!,
          ),
        },
        cancelToken: _cancelToken,
      );

      if (_isDisposed) return;

      List<dynamic> data = res.data;
      List<VideoSource> sources = data
          .map((item) => VideoSource.fromJson(item))
          .toList();

      // 更新缓存
      final cacheKey = videoInfo.value!.fileUrl!;
      _cacheManager.cacheVideoSources(cacheKey, sources);
      currentVideoSourceList.value = sources;

      // 解析过期时间（所有清晰度的过期时间都一样，只需解析一次）
      _currentVideoSourceExpireTime = null;
      for (var source in sources) {
        if (source.view != null) {
          final expireTime = CommonUtils.getVideoLinkExpireTime(source.view!);
          if (expireTime != null) {
            _currentVideoSourceExpireTime = expireTime;
            LogUtils.d('刷新后视频源过期时间: $expireTime', 'MyVideoStateController');
            break; // 找到一个有效的过期时间即可
          }
        }
      }

      // 如果当前正在播放，需要更新播放器的URL
      if (currentResolutionTag.value != null && videoPlayerReady.value) {
        String? newUrl = CommonUtils.findUrlByResolutionTag(
          CommonUtils.convertVideoSourcesToResolutions(
            sources,
            filterPreview: true,
          ),
          currentResolutionTag.value!,
        );

        if (newUrl != null) {
          // 无缝切换到新的URL（保持播放位置）
          await _switchToRefreshedUrl(newUrl);
        }
      }

      // 重新设置定时器
      _setupVideoSourceExpirationTimer();

      LogUtils.i('视频源刷新成功', 'MyVideoStateController');
    } catch (e) {
      LogUtils.e('刷新视频源失败: $e', tag: 'MyVideoStateController', error: e);
      // 如果刷新失败，5分钟后重试
      _videoSourceExpirationTimer = Timer(const Duration(minutes: 5), () {
        _refreshVideoSourceBeforeExpiration();
      });
    }
  }

  /// 切换到刷新后的视频URL（无缝切换）
  Future<void> _switchToRefreshedUrl(String newUrl) async {
    if (_isDisposed) return;
    LogUtils.d('切换到刷新后的视频URL: $newUrl', 'MyVideoStateController');

    try {
      // 保存当前播放位置和播放状态
      final savedPosition = currentPosition;
      final isPlaying = videoPlaying.value;

      // 打开新URL，保持播放状态
      await player.open(Media(newUrl, start: savedPosition), play: isPlaying);

      LogUtils.i('成功切换到新的视频URL', 'MyVideoStateController');
    } catch (e) {
      LogUtils.e('切换视频URL失败: $e', tag: 'MyVideoStateController', error: e);
    }
  }

  /// 更新视频宽高比
  void _updateAspectRatio() async {
    if (_isDisposed) return;

    aspectRatio.value = sourceVideoWidth.value / sourceVideoHeight.value;
    videoPlayerReady.value = true;
    firstLoaded = true;
    LogUtils.d(
      '[更新后的宽高比] $aspectRatio, 视频高度: $sourceVideoHeight, 视频宽度: $sourceVideoWidth',
      'MyVideoStateController',
    );
  }

  /// 进入全屏模式
  Future<void> enterFullscreen() async {
    // 保存进入全屏前的播放状态
    final wasPlaying = videoPlaying.value;
    isFullscreen.value = true;
    appS.hideSystemUI();
    bool renderVerticalVideoInVerticalScreen =
        _configService[ConfigKey.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN];
    NaviService.navigateToFullScreenVideoPlayerScreenPage(this);

    // 获取当前屏幕方向
    final currentOrientation = MediaQuery.of(Get.context!).orientation;

    if (renderVerticalVideoInVerticalScreen && aspectRatio.value < 1) {
      // 窄屏视频保持竖屏
      await CommonUtils.defaultEnterNativeFullscreen(toVerticalScreen: true);
    } else if (currentOrientation == Orientation.landscape) {
      // 如果当前已经是横屏，正常触发全屏，不改变方向
      await CommonUtils.defaultEnterNativeFullscreen();
    } else {
      // 当前是竖屏，根据配置选择横屏方向
      await CommonUtils.defaultEnterNativeFullscreen(
        useGravityOrientation: true,
      );
    }

    // 同步播放状态
    if (wasPlaying) {
      await player.play();
    } else {
      await player.pause();
    }
  }

  /// 退出全屏模式
  void exitFullscreen() async {
    // 保存退出全屏前的播放状态
    final wasPlaying = videoPlaying.value;
    AppService.tryPop();
    appS.showSystemUI();
    await defaultExitNativeFullscreen();
    isFullscreen.value = false;
    // 同步播放状态
    if (wasPlaying) {
      await player.play();
    } else {
      await player.pause();
    }
  }

  // 重置自动隐藏定时器
  void _resetAutoHideTimer() {
    _autoHideTimer?.cancel();

    // 如果正在交互或悬浮在工具栏上，不启动定时器
    if (_isInteracting.value || _isHoveringToolbar.value || _isDisposed) return;

    _autoHideTimer = Timer(_autoHideDelay, () {
      // 如果控制器已被dispose或者正在交互或悬浮在工具栏上，不执行隐藏
      if (_isDisposed ||
          !_isInteracting.value &&
              !_isHoveringToolbar.value &&
              animationController.value == 1.0) {
        // 再次检查dispose状态，避免dispose后调用
        if (!_isDisposed) {
          animationController.reverse();
          isLockButtonVisible.value = false; // 同时隐藏锁定按钮
        }
      }
    });
  }

  // 设置交互状态
  void setInteracting(bool value) {
    _isInteracting.value = value;
    if (!value) {
      resetDisplayPosition();
      // 交互结束时重置定时器
      _resetAutoHideTimer();
    } else {
      // 交互开始时取消定时器
      _autoHideTimer?.cancel();
    }
  }

  // 设置工具栏悬浮状态
  void setToolbarHovering(bool value) {
    _isHoveringToolbar.value = value;
    if (value) {
      // 悬浮时取消定时器
      _autoHideTimer?.cancel();
    } else {
      // 离开时重置定时器
      _resetAutoHideTimer();
    }
  }

  // 设置鼠标悬浮播放器状态
  void setMouseHoveringPlayer(bool value) {
    // 检查是否启用了鼠标悬浮显示工具栏功能
    if (!_configService[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR]) {
      return;
    }

    _isMouseHoveringPlayer.value = value;
    if (value) {
      // 鼠标进入播放器时显示工具栏
      if (!animationController.isCompleted) {
        animationController.forward();
        isLockButtonVisible.value = true;
      }
    } else {
      // 鼠标离开播放器时取消所有定时器并重置
      _mouseMovementTimer?.cancel();
      _resetAutoHideTimer();
    }
  }

  // 处理鼠标在播放器内移动
  void onMouseMoveInPlayer() {
    // 检查是否启用了鼠标悬浮显示工具栏功能
    if (!_configService[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR]) {
      return;
    }

    // 显示工具栏
    if (!animationController.isCompleted) {
      animationController.forward();
      isLockButtonVisible.value = true;
    }

    // 取消之前的移动定时器
    _mouseMovementTimer?.cancel();

    // 设置新的定时器，鼠标停止移动3秒后启动自动隐藏
    _mouseMovementTimer = Timer(_autoHideDelay, () {
      // 只有在鼠标还在播放器内且没有其他交互时才隐藏
      if (_isMouseHoveringPlayer.value &&
          !_isInteracting.value &&
          !_isHoveringToolbar.value) {
        _resetAutoHideTimer();
      }
    });
  }

  // 修改现有的 toggleToolbars 方法
  void toggleToolbars() {
    if (animationController.isCompleted) {
      animationController.reverse();
      _autoHideTimer?.cancel(); // 用户主动隐藏时取消定时器
      isLockButtonVisible.value = false; // 隐藏锁定按钮
    } else {
      animationController.forward();
      isLockButtonVisible.value = true; // 显示锁定按钮
      _resetAutoHideTimer();
    }
  }

  // 修改 showToolbars 方法
  void showToolbars() {
    if (!animationController.isCompleted) {
      animationController.forward();
      isLockButtonVisible.value = true; // 显示锁定按钮
      _resetAutoHideTimer();
    } else {
      // 如果已经显示，仅重置定时器
      _resetAutoHideTimer();
    }
  }

  // 设置当前视频的播放倍率
  void setPlaybackSpeed(double d) {
    player.setRate(d);
  }

  void setLongPressPlaybackSpeedByConfiguration() {
    // 取消之前的防抖定时器
    _speedChangeDebouncer?.cancel();

    // 使用防抖机制，避免频繁设置播放速度
    _speedChangeDebouncer = Timer(const Duration(milliseconds: 50), () {
      if (!_isDisposed) {
        double speed = _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY];
        player.setRate(speed);
        currentLongPressSpeed.value = speed;
        LogUtils.d('设置长按播放速度: ${speed}x', 'MyVideoStateController');
      }
    });
  }

  /// 更新长按时的播放速度（临时调整，不保存到配置）
  /// [speed] 新的播放速度，范围 0.1 - 4.0
  void updateLongPressSpeed(double speed) {
    // 限制速度范围
    double clampedSpeed = speed.clamp(0.1, 4.0);
    // 保留一位小数
    clampedSpeed = (clampedSpeed * 10).roundToDouble() / 10;

    if (!_isDisposed && isLongPressing.value) {
      player.setRate(clampedSpeed);
      currentLongPressSpeed.value = clampedSpeed;
      LogUtils.d('更新长按播放速度: ${clampedSpeed}x', 'MyVideoStateController');
    }
  }

  /// 设置音量
  /// [安卓、IOS] 使用系统volumeController
  /// 其他平台使用player.setVolume
  /// volume: 0.0-1.0
  void setVolume(double volume, {bool save = true}) {
    _isAdjustingVolumeByGesture = true;
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      volumeController?.setVolume(volume);
    } else {
      player.setVolume(volume * 100);
    }
    _configService.setSetting(ConfigKey.VOLUME_KEY, volume, save: save);
    _isAdjustingVolumeByGesture = false;
  }

  void _addBufferRange(Duration bufferDuration) {
    // 如果总时长为0，说明视频还未加载，不处理缓冲
    if (totalDuration.value.inMilliseconds == 0) return;

    // 使用节流机制，避免频繁的缓冲区操作
    if (_bufferUpdateThrottleTimer?.isActive ?? false) return;

    _bufferUpdateThrottleTimer = Timer(const Duration(milliseconds: 300), () {
      if (_isDisposed) return;
      _performBufferUpdate(bufferDuration);
    });
  }

  void _performBufferUpdate(Duration bufferDuration) {
    final Duration start = currentPosition;
    final Duration end = bufferDuration;

    // 如果缓冲时长小于等于当前播放位置，或大于总时长，则忽略
    if (end <= Duration.zero || end > totalDuration.value) {
      return;
    }

    BufferRange newRange = BufferRange(start: start, end: end);
    List<BufferRange> updatedBuffers = List<BufferRange>.from(buffers);

    // 简化的缓冲区合并逻辑
    bool merged = false;
    for (int i = 0; i < updatedBuffers.length && !merged; i++) {
      BufferRange existingRange = updatedBuffers[i];
      if (existingRange.overlapsOrAdjacent(newRange)) {
        updatedBuffers[i] = existingRange.merge(newRange);
        merged = true;
      }
    }

    if (!merged) {
      updatedBuffers.add(newRange);
    }

    // 移除过期的缓冲区并排序
    updatedBuffers.removeWhere(
      (range) =>
          range.end <= currentPosition || range.start >= totalDuration.value,
    );

    if (updatedBuffers.isNotEmpty) {
      updatedBuffers.sort((a, b) => a.start.compareTo(b.start));
    }

    buffers.value = updatedBuffers;
  }

  void _clearBuffers() {
    buffers.clear();
  }

  /// 显示/隐藏进度预
  void showSeekPreview(bool show) {
    isSeekPreviewVisible.value = show;
    if (!show && !_isInteracting.value) {
      resetDisplayPosition();
    }
  }

  /// 更新预览位置
  void updateSeekPreview(Duration position) {
    previewPosition.value = position;
    if (isSeekPreviewVisible.value) {
      _syncDisplayPosition(position);
    }
  }

  void resetDisplayPosition() {
    _syncDisplayPosition(currentPosition);
  }

  void _syncDisplayPosition(Duration position) {
    toShowCurrentPosition.value = position;
  }

  void handleSeek(Duration newPosition) async {
    // 标记正在等待seek完成
    isWaitingForSeek.value = true;

    // 如果是回退进度，则清空缓冲区
    if (newPosition < currentPosition) {
      _clearBuffers();
    } else {
      // 清理失效的缓冲区
      List<BufferRange> updatedBuffers = buffers.where((range) {
        return range.end > newPosition && range.start < totalDuration.value;
      }).toList();

      buffers.value = updatedBuffers;
    }

    // 先更新UI位置，立即同步到显示位置，避免进度条跳回
    currentPosition = newPosition;
    _syncDisplayPosition(newPosition);
    player.play();
    videoPlaying.value = true;

    // 执行实际的seek操作
    await player.seek(newPosition);

    // seek完成后标记状态，并清除横向拖拽状态
    isWaitingForSeek.value = false;
    isHorizontalDragging.value = false;
  }

  // 添加关闭提示的方法:
  void hideResumePositionTip() {
    showResumePositionTip.value = false;
    _resumeTipTimer?.cancel();
  }

  /// 设置 Anime4K Shader
  Future<void> setShader({String? presetId, bool synchronized = true}) async {
    if (player.platform is! NativePlayer) return;

    final pp = player.platform as NativePlayer;

    // 等待播放器初始化
    await pp.waitForPlayerInitialization;
    await pp.waitForVideoControllerInitializationIfAttached;

    // 如果没有指定预设ID，使用配置中的默认值
    final targetPresetId =
        presetId ?? _configService[ConfigKey.ANIME4K_PRESET_ID];

    // 如果预设ID为空字符串，表示禁用 Anime4K，清空 shader
    if (targetPresetId.isEmpty) {
      await pp.command(['change-list', 'glsl-shaders', 'clr', '']);
      LogUtils.d('已清除 Anime4K shaders', 'MyVideoStateController');
      return;
    }

    try {
      // 获取预设
      final preset = Anime4KPresets.getPresetById(targetPresetId);
      if (preset == null) {
        LogUtils.w('未找到 Anime4K 预设: $targetPresetId', 'MyVideoStateController');
        return;
      }

      // 构建 shader 路径
      final shaderPaths = _buildShaderPaths(preset);

      // 设置 shader
      await pp.command(['change-list', 'glsl-shaders', 'set', shaderPaths]);

      LogUtils.d(
        '成功设置 Anime4K 预设: ${preset.name} (${preset.shaders.length} 个 shaders)',
        'MyVideoStateController',
      );
    } catch (e) {
      LogUtils.e(
        '设置 Anime4K shader 失败: $e',
        tag: 'MyVideoStateController',
        error: e,
      );
      // 失败时清空 shader
      await pp.command(['change-list', 'glsl-shaders', 'clr', '']);
    }
  }

  /// 构建 shader 路径列表
  String _buildShaderPaths(Anime4KPreset preset) {
    try {
      // 获取 GLSL 着色器服务
      final glslShaderService = Get.find<GlslShaderService>();

      if (!glslShaderService.isInitialized) {
        LogUtils.w('GLSL 着色器服务未初始化，使用 assets 路径作为后备', 'MyVideoStateController');
        return _buildShaderPathsFromAssets(preset);
      }

      // 将相对路径转换为临时文件路径
      final tempShaderPaths = preset.shaders.map((shaderFile) {
        return glslShaderService.getTempShaderPath(shaderFile);
      }).toList();

      // 根据平台拼接路径分隔符
      if (GetPlatform.isWindows) {
        return tempShaderPaths.join(';');
      } else {
        return tempShaderPaths.join(':');
      }
    } catch (e) {
      LogUtils.e(
        '构建 shader 路径失败，使用 assets 路径作为后备',
        tag: 'MyVideoStateController',
        error: e,
      );
      return _buildShaderPathsFromAssets(preset);
    }
  }

  /// 构建基于 assets 的 shader 路径列表（后备方案）
  String _buildShaderPathsFromAssets(Anime4KPreset preset) {
    // 获取 assets 目录下的 shader 文件路径
    final shaderPaths = preset.shaderPaths;

    // 根据平台拼接路径分隔符
    if (GetPlatform.isWindows) {
      return shaderPaths.join(';');
    } else {
      return shaderPaths.join(':');
    }
  }

  /// 切换 Anime4K 预设
  Future<void> switchAnime4KPreset(String presetId) async {
    // 更新配置
    _configService.setSetting(ConfigKey.ANIME4K_PRESET_ID, presetId);
    // 应用新预设
    await setShader(presetId: presetId);
  }

  /// 进入画中画模式
  Future<void> enterPiPMode() async {
    // 获取当前视频的宽度和高度以构造画中画窗口的比例
    final int width = sourceVideoWidth.value;
    final int height = sourceVideoHeight.value;
    if (height == 0 || width == 0) {
      return;
    }
    // 利用视频的宽高构造比例参数（Rational类型）
    final ratio = Rational(width, height);
    LogUtils.d(
      "进入画中画模式，设置宽高比为：$width:$height, Rational: $ratio",
      "MyVideoStateController",
    );
    // 通过floating插件启用画中画模式并传入宽高比
    await Floating().enable(ImmediatePiP(aspectRatio: ratio));
    isPiPMode.value = true;
    player.play();
  }

  /// 退出画中画模式
  Future<void> exitPiPMode() async {
    await Floating().cancelOnLeavePiP();
    isPiPMode.value = false;
  }

  // 统一的position监听器设置
  void _setupPositionListener() {
    positionSubscription = player.stream.position.listen((position) async {
      // 在回调中检查控制器是否已销毁
      if (_isDisposed) return;

      if (!videoPlayerReady.value) return;

      // 只有在不是等待seek完成且不在横向拖拽的状态下才更新位置
      if (!isWaitingForSeek.value && !isHorizontalDragging.value) {
        // 根据当前状态选择节流间隔
        final throttleInterval = isLongPressing.value
            ? _longPressPositionUpdateInterval
            : _positionUpdateThrottleInterval;

        // 节流处理
        if (_positionUpdateThrottleTimer?.isActive ?? false) {
          // 保存最新位置，但不立即更新
          _lastPosition = position;
          return;
        }

        // 更新位置并设置节流定时器
        currentPosition = position;
        _lastPosition = position;

        _positionUpdateThrottleTimer = Timer(throttleInterval, () {
          // 定时器触发时，如果最新位置与当前显示位置不同，则更新
          if (_isDisposed) return;
          if (_lastPosition != currentPosition) {
            currentPosition = _lastPosition;
          }
        });
      }
      sliderDragLoadFinished.value = true;
    });
  }

  void showLockButton() {
    if (isToolbarsLocked.value) {
      isLockButtonVisible.toggle();
      if (isLockButtonVisible.value) {
        _lockButtonHideTimer?.cancel();
        _lockButtonHideTimer = Timer(const Duration(seconds: 3), () {
          if (isToolbarsLocked.value) {
            isLockButtonVisible.value = false;
          }
        });
      }
    }
  }

  void toggleLockState() {
    isToolbarsLocked.value = !isToolbarsLocked.value;
    if (!isToolbarsLocked.value) {
      // 如果解锁，显示所有工具栏
      animationController.forward();
      isLockButtonVisible.value = true;
    } else {
      // 如果锁定，隐藏所有工具栏
      animationController.reverse();
      // 启动定时器隐藏锁按钮
      _lockButtonHideTimer?.cancel();
      _lockButtonHideTimer = Timer(const Duration(seconds: 3), () {
        isLockButtonVisible.value = false;
      });
    }
  }

  // 添加启动定时器的方法
  void _startDisplayTimer() {
    _displayUpdateTimer?.cancel();

    // 根据当前状态选择更新频率
    Duration updateInterval = const Duration(milliseconds: 500);
    if (isLongPressing.value ||
        isSlidingBrightnessZone.value ||
        isSlidingVolumeZone.value) {
      // 在长按或滑动期间降低更新频率
      updateInterval = const Duration(milliseconds: 1000);
    }

    _displayUpdateTimer = Timer.periodic(updateInterval, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (videoPlayerReady.value &&
          !isWaitingForSeek.value &&
          !_isInteracting.value &&
          !isSeekPreviewVisible.value &&
          !isHorizontalDragging.value) {
        _syncDisplayPosition(currentPosition);
      }

      // 动态调整更新频率
      if (isLongPressing.value ||
          isSlidingBrightnessZone.value ||
          isSlidingVolumeZone.value) {
        if (timer.tick % 2 == 0) {
          // 每隔一次更新
          return;
        }
      }
    });
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    final offset = scrollController.offset;
    final screenSize = Get.size;
    final paddingTop = Get.context != null
        ? MediaQuery.of(Get.context!).padding.top
        : 0;
    final videoHeight = getCurrentVideoHeight(
      screenSize.width,
      screenSize.height,
      paddingTop.toDouble(),
    );

    // 计算滚动比例
    if (offset == 0) {
      scrollRatio.value = 0.0;
    } else {
      final offsetAfterVideo = offset - (videoHeight - minVideoHeight);
      if (offsetAfterVideo > 0) {
        scrollRatio.value =
            (offsetAfterVideo / (minVideoHeight - kToolbarHeight)).clamp(
              0.0,
              1.0,
            );
      } else {
        scrollRatio.value = 0.0;
      }
    }
  }

  double getCurrentVideoHeight(
    double screenWidth,
    double screenHeight,
    double paddingTop,
  ) {
    // 根据视频状态确定高度
    if (pageLoadingState.value ==
        VideoDetailPageLoadingState.loadingVideoInfo) {
      return minVideoHeight;
    }

    // 1. 获取应用的宽度，然后通过 aspectRatio 得到高度1
    if (aspectRatio.value <= 0) {
      return minVideoHeight; // Return a safe default
    }
    final double height1 = screenWidth / aspectRatio.value;

    // 2. 接着获取应用的高度, 高度 ✖️ 70%
    final double height3 = screenHeight * 0.7;

    // 3. 然后比对高度 1 和高度 3，但确保不低于最小高度
    // 这样可以防止宽视频在窄屏上高度过低的问题
    return max(min(height1, height3), minVideoHeight);
  }

  void animateToTop() {
    // 仅当播放器未完全展开时才触发
    if (scrollController.hasClients && scrollController.offset > 0) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 获取当前视频的播放 URL
  String? getCurrentVideoUrl() {
    if (currentResolutionTag.value == null) return null;

    return CommonUtils.findUrlByResolutionTag(
      videoResolutions,
      currentResolutionTag.value!,
    );
  }

  /// 获取 preview 视频源的 URL
  Future<String?> getPreviewVideoUrl() async {
    if (previewVideoUrl != null) {
      return previewVideoUrl;
    }

    // 从 currentVideoSourceList 中查找 name 为 'preview' 的源
    for (final source in currentVideoSourceList) {
      if (source.name == 'preview' &&
          source.src != null &&
          source.src!.view != null) {
        String? url = CommonUtils.normalizeUrl(source.src!.view);

        // 尝试从本地下载获取 preview 文件
        if (videoId != null) {
          try {
            final downloadService = Get.find<DownloadService>();
            final localPath = await downloadService.getCompletedVideoLocalPath(
              videoId!,
              'preview',
            );

            if (localPath != null) {
              // 使用本地文件路径
              url = 'file://$localPath';
              LogUtils.i(
                '使用本地下载的 preview 文件: videoId=$videoId, path=$localPath',
                'MyVideoStateController',
              );
            }
          } catch (e) {
            LogUtils.w(
              '检查本地 preview 文件失败，使用在线播放: $e',
              'MyVideoStateController',
            );
          }
        }

        previewVideoUrl = url;
        return previewVideoUrl;
      }
    }
    return null;
  }

  /// 初始化预览播放器
  Future<void> _initializePreviewPlayer() async {
    if (_isDisposed) return;

    // 如果预览播放器已存在，先释放
    if (previewPlayer != null) {
      await _disposePreviewPlayer();
    }

    final previewUrl = await getPreviewVideoUrl();
    if (previewUrl == null || previewUrl.isEmpty) {
      LogUtils.d('未找到 preview 视频源，跳过预览播放器初始化', 'MyVideoStateController');
      return;
    }

    try {
      LogUtils.d('开始初始化预览播放器: $previewUrl', 'MyVideoStateController');

      // 创建预览播放器
      previewPlayer = Player(
        configuration: PlayerConfiguration(
          bufferSize: 32 * 1024 * 1024, // 32MB 缓冲区（与主播放器默认一致）
          title: 'i_iwara Preview Player',
          async: true,
          protocolWhitelist: const [
            'udp',
            'rtp',
            'tcp',
            'tls',
            'data',
            'file',
            'http',
            'https',
            'crypto',
          ],
        ),
      );

      // 创建预览视频控制器
      previewVideoController = VideoController(
        previewPlayer!,
        configuration: VideoControllerConfiguration(
          enableHardwareAcceleration:
              _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION],
          hwdec: _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION]
              ? _configService[ConfigKey.HARDWARE_DECODING]
              : null,
        ),
      );

      // 设置静音
      previewPlayer!.setVolume(0);

      // 打开预览视频（但不自动播放）
      await previewPlayer!.open(Media(previewUrl), play: false);

      if (_isDisposed) {
        await _disposePreviewPlayer();
        return;
      }

      // 监听预览播放器的状态
      previewDurationSubscription = previewPlayer!.stream.duration.listen((
        duration,
      ) {
        if (_isDisposed) return;
        // 当 duration 大于 0 时，表示预览播放器已准备好
        // ignore: unnecessary_null_comparison
        if (duration != null && duration > Duration.zero) {
          isPreviewPlayerReady.value = true;
          LogUtils.d('预览播放器已准备好', 'MyVideoStateController');
        }
      });

      previewPlayingSubscription = previewPlayer!.stream.playing.listen((
        playing,
      ) {
        if (_isDisposed) return;
        // 可以在这里处理播放状态变化
      });

      LogUtils.d('预览播放器初始化完成', 'MyVideoStateController');
    } catch (e) {
      LogUtils.e('初始化预览播放器失败: $e', tag: 'MyVideoStateController', error: e);
      await _disposePreviewPlayer();
    }
  }

  /// 限流更新预览播放器位置（使用 EasyThrottle，只对最后一次位置进行 seek）
  void updatePreviewSeek(Duration position) {
    if (_isDisposed || previewPlayer == null || !isPreviewPlayerReady.value) {
      return;
    }

    // 记录最新的目标位置
    _latestPreviewSeekPosition = position;

    // 使用 EasyThrottle 控制实际 seek 频率
    EasyThrottle.throttle(
      '${randomId}_preview_seek',
      const Duration(milliseconds: 150),
      () {
        if (_isDisposed ||
            previewPlayer == null ||
            !isPreviewPlayerReady.value) {
          return;
        }

        final Duration? target = _latestPreviewSeekPosition;
        if (target == null) {
          return;
        }

        try {
          // 执行 seek 操作，并在对应位置停住用于预览
          previewPlayer!.seek(target).then((_) {
            if (_isDisposed || previewPlayer == null) {
              return;
            }
            // 预览模式下保持暂停状态，确保画面停留在 tooltip 对应的时间点
            previewPlayer!.pause();
          });
        } catch (e) {
          LogUtils.w('预览播放器 seek 失败: $e', 'MyVideoStateController');
        }
      },
    );
  }

  /// 释放预览播放器资源
  Future<void> _disposePreviewPlayer() async {
    _previewSeekThrottleTimer?.cancel();
    _previewSeekThrottleTimer = null;

    previewDurationSubscription?.cancel();
    previewDurationSubscription = null;

    previewPlayingSubscription?.cancel();
    previewPlayingSubscription = null;

    try {
      if (previewPlayer != null) {
        await previewPlayer!.dispose();
        previewPlayer = null;
      }
    } catch (e) {
      LogUtils.w('释放预览播放器失败: $e', 'MyVideoStateController');
    }

    previewVideoController = null;
    previewVideoUrl = null;
    isPreviewPlayerReady.value = false;

    LogUtils.d('预览播放器资源已释放', 'MyVideoStateController');
  }

  /// 显示投屏对话框
  void showDlnaCastDialog() {
    // 检查平台支持
    if (GetPlatform.isWeb || GetPlatform.isLinux) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(slang.t.videoDetail.cast.currentPlatformNotSupported),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // 暂停当前视频
    player.pause();

    final videoUrl = getCurrentVideoUrl();
    if (videoUrl == null || videoUrl.isEmpty) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(slang.t.videoDetail.cast.unableToGetVideoUrl),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    Get.bottomSheet(
      DlnaCastSheet(videoUrl: videoUrl, dlnaController: _dlnaCastService),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  /// 获取 DLNA 投屏服务
  DlnaCastService get dlnaCastService => _dlnaCastService;

  /// 更新缓存中的视频点赞信息
  void updateCachedVideoLikeInfo(String videoId, bool liked, int numLikes) {
    _cacheManager.updateVideoInfoFields(videoId, {
      'liked': liked,
      'numLikes': numLikes,
    });
  }

  /// 更新缓存中的作者信息（关注/取关后调用）
  void _updateCachedVideoAuthor(User updatedUser) {
    if (videoId == null) return;
    _cacheManager.updateVideoAuthor(videoId!, updatedUser);
  }

  /// 关注状态变化后的统一处理
  void handleAuthorUpdated(User updatedUser) {
    final currentVideo = videoInfo.value;
    if (currentVideo != null) {
      videoInfo.value = currentVideo.copyWith(user: updatedUser);
    }
    _updateCachedVideoAuthor(updatedUser);
  }

  /// 检查视频的收藏和播放列表状态
  Future<void> checkFavoriteAndPlaylistStatus() async {
    if (_isDisposed || videoId == null) return;

    try {
      final userService = Get.find<UserService>();
      // 只在用户已登录时检查状态
      if (!userService.isLogin) {
        isInAnyFavorite.value = false;
        isInAnyPlaylist.value = false;
        return;
      }

      // 并行检查收藏和播放列表状态
      final favoriteService = Get.find<FavoriteService>();
      final playListService = Get.find<PlayListService>();

      final favoriteFolders = await favoriteService.getItemFolders(videoId!);
      final playlistsResult = await playListService.getLightPlaylists(
        videoId: videoId!,
      );

      if (_isDisposed) return;

      // 检查收藏状态
      isInAnyFavorite.value = favoriteFolders.isNotEmpty;

      // 检查播放列表状态
      if (playlistsResult.isSuccess && playlistsResult.data != null) {
        final playlists = playlistsResult.data!;
        // 检查是否有任何播放列表的 added 字段为 true
        isInAnyPlaylist.value = playlists.any(
          (playlist) => playlist.added == true,
        );
      } else {
        isInAnyPlaylist.value = false;
      }

      LogUtils.d(
        '检查收藏和播放列表状态完成: isInAnyFavorite=${isInAnyFavorite.value}, isInAnyPlaylist=${isInAnyPlaylist.value}',
        'MyVideoStateController',
      );
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.w('检查收藏和播放列表状态失败: $e', 'MyVideoStateController');
        // 出错时重置状态
        isInAnyFavorite.value = false;
        isInAnyPlaylist.value = false;
      }
    }
  }

  /// 检查当前视频是否有下载任务
  Future<void> checkDownloadTaskStatus() async {
    if (_isDisposed || videoId == null) return;

    try {
      final downloadService = Get.find<DownloadService>();
      final hasTask = await downloadService.hasAnyVideoDownloadTask(videoId!);

      if (_isDisposed) return;

      hasAnyDownloadTask.value = hasTask;

      LogUtils.d(
        '检查下载任务状态完成: hasAnyDownloadTask=${hasAnyDownloadTask.value}',
        'MyVideoStateController',
      );
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.w('检查下载任务状态失败: $e', 'MyVideoStateController');
        // 出错时重置状态
        hasAnyDownloadTask.value = false;
      }
    }
  }

  /// 标记当前视频有下载任务
  void markVideoHasDownloadTask() {
    if (_isDisposed) return;
    hasAnyDownloadTask.value = true;
    LogUtils.d('标记视频有下载任务: $videoId', 'MyVideoStateController');
  }

  /// 异步刷新视频的点赞信息（缓存命中时的专用方法）
  Future<void> _refreshVideoLikeInfo(
    String videoId,
    video_model.Video cachedVideoInfo,
  ) async {
    if (_isDisposed) return;

    try {
      LogUtils.d('开始异步刷新视频点赞信息: $videoId', 'MyVideoStateController');

      // 请求最新视频信息
      final res = await _apiService.get(
        '/video/$videoId',
        cancelToken: _cancelToken,
      );

      if (_isDisposed) return;

      final latestVideoInfo = video_model.Video.fromJson(res.data);

      // 只更新点赞相关字段到当前显示的 videoInfo
      if (videoInfo.value != null) {
        videoInfo.value = videoInfo.value!.copyWith(
          liked: latestVideoInfo.liked,
          numLikes: latestVideoInfo.numLikes,
        );
      }

      // 更新缓存中的点赞信息
      _cacheManager.updateVideoInfoFields(videoId, {
        'liked': latestVideoInfo.liked,
        'numLikes': latestVideoInfo.numLikes,
      });

      LogUtils.d('成功刷新视频点赞信息: $videoId', 'MyVideoStateController');
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.w(
          '刷新视频点赞信息失败，使用缓存数据: $videoId, error: $e',
          'MyVideoStateController',
        );

        // 请求失败时，恢复使用缓存中的点赞信息
        if (videoInfo.value != null) {
          videoInfo.value = videoInfo.value!.copyWith(
            liked: cachedVideoInfo.liked,
            numLikes: cachedVideoInfo.numLikes,
          );
        }
      }
    }
  }
}

/// 视频清晰度模型
class VideoResolution {
  final String label;
  final String url;

  VideoResolution({required this.label, required this.url});
}
