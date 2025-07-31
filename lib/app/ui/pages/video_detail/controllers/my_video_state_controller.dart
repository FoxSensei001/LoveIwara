import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/oreno3d_client.dart' show Oreno3dClient;
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/related_media_controller.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oktoast/oktoast.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../../../utils/common_utils.dart';
import '../../../../../utils/x_version_calculator_utils.dart';
import '../../../../models/user.model.dart';
import '../../../../models/video_source.model.dart';
import '../../../../models/video.model.dart' as video_model;
import '../../../../services/api_service.dart';
import '../../../../services/config_service.dart';
import '../widgets/player/custom_slider_bar_shape_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../widgets/private_or_deleted_video_widget.dart';
import 'package:floating/floating.dart';

class MyVideoStateController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final String? videoId;
  final AppService appS = Get.find();
  late Player player;
  late VideoController videoController;
  late VolumeController? volumeController;
  final PlaybackHistoryService _playbackHistoryService = Get.find();
  final ApiService _apiService = Get.find();
  final ConfigService _configService = Get.find();

  // 视频详情页信息
  RxBool isCommentSheetVisible = false.obs; // 评论面板是否可见
  OtherAuthorzMediasController? otherAuthorzVideosController; // 作者的其他视频控制器

  // 状态
  // 播放器状态
  Duration currentPosition = Duration.zero;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxBool videoPlaying = false.obs;
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
  final RxBool isVideoInfoLoading = false.obs;
  final RxBool isVideoSourceLoading = false.obs;
  final Rxn<Widget> mainErrorWidget = Rxn<Widget>(); // 错误信息
  final Rxn<String> videoErrorMessage = Rxn<String>(); // 视频错误信息
  final Rxn<video_model.Video> videoInfo = Rxn<video_model.Video>(); // 视频信息
  final RxBool videoIsReady = false.obs; // 视频是否准备好
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
  final RxBool isSlidingVolumeZone = false.obs;     // 是否在滑动音量区域
  final RxBool isLongPressing = false.obs;          // 是否在长按

  // 节流相关变量
  Timer? _positionUpdateThrottleTimer;
  static const _positionUpdateThrottleInterval = Duration(milliseconds: 200); // 200ms节流间隔
  Duration _lastPosition = Duration.zero;

  // 播放模式设置标志位
  bool _isSettingPlayMode = false;

  // 在类成员变量区域添加
  Timer? _lockButtonHideTimer;
  final RxBool isLockButtonVisible = true.obs;

  // 添加 Dio CancelToken
  final CancelToken _cancelToken = CancelToken();
  // 添加 disposed 标志位
  bool _isDisposed = false;

  // 滚动相关状态管理
  final RxDouble scrollRatio = 0.0.obs; // 滚动比例
  late final ScrollController scrollController = ScrollController();
  final RxBool isExpanding = false.obs; // 是否正在展开
  final RxBool isCollapsing = false.obs; // 是否正在收缩
  late final double minVideoHeight; // 最小视频高度
  late final double maxVideoHeight; // 最大视频高度
  late final double videoHeight; // 当前视频高度
  bool isInitialized = false;

  final GlobalKey<State<StatefulWidget>> nestedScrollViewKey = GlobalKey<State<StatefulWidget>>();

  MyVideoStateController(this.videoId);

  void refreshScrollView() {
    // 触发重建
    nestedScrollViewKey.currentState?.setState(() {});
  }

  @override
  void onInit() async {
    super.onInit();
    _isDisposed = false; // 初始化时确保标志位为 false
    LogUtils.i('初始化 MyVideoStateController，videoId: $videoId', 'MyVideoStateController');
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

      topBarAnimation = Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ));

      bottomBarAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ));

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
      player = Player();

      videoController = VideoController(player);

      // 初始化滚动相关变量
      _initializeScrollSettings();

      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        // 初始化并关闭系统音量UI
        volumeController = VolumeController.instance;
        volumeController?.showSystemUI = false;
        // 添加音量监听
        _volumeListenerDisposer = volumeController?.addListener((volume) {
          // 如果当前在long press状态，则不更新音量
          if (isLongPressing.value || isSlidingVolumeZone.value || isSlidingBrightnessZone.value) return;
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

      // 使用 WidgetsBinding.instance.addPostFrameCallback 确保基础设置完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          fetchVideoDetail(videoId!);
        }
      });

      // 是否沿用之前的音量
      bool keepLastVolumeKey = _configService[ConfigKey.KEEP_LAST_VOLUME_KEY];
      if (CommonConstants.isSetVolume) {
        if (keepLastVolumeKey) {
          // 保持之前的音量
          double lastVolume = _configService[ConfigKey.VOLUME_KEY];
          setVolume(lastVolume, save: false);
        } else {
          if (GetPlatform.isAndroid || GetPlatform.isIOS) {
            // 更新配置为当前的系统音量
            double currentVolume = await volumeController?.getVolume() ?? 0.0;
            _configService[ConfigKey.VOLUME_KEY] = currentVolume;
          }
        }
      }

      // 设置亮度
      setDefaultBrightness();

      // 想办法让native player默认走系统代理
      if (player.platform is NativePlayer &&
          _configService[ConfigKey.USE_PROXY]) {
        bool useProxy = _configService[ConfigKey.USE_PROXY];
        String proxyUrl = _configService[ConfigKey.PROXY_URL];
        LogUtils.i('使用代理: $useProxy, 代理地址: $proxyUrl', 'MyVideoStateController');
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
          (player.platform as dynamic).setProperty(
            'http-proxy',
            finalProxyUrl,
          );
        }
      }

      // 添加画中画状态监听
      _setupPiPListener();

      // 启动显示时间更新定时器
      _startDisplayTimer();
    } catch (e) {
      LogUtils.e('初始化失败: $e', tag: 'MyVideoStateController', error: e);
      if (!_isDisposed) {
        mainErrorWidget.value = CommonErrorWidget(
          text: slang.t.videoDetail.getVideoInfoFailed,
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

  @override
  void onClose() {
    LogUtils.i('MyVideoStateController onClose 被调用', 'MyVideoStateController');
    _isDisposed = true;

    // 取消网络请求
    _cancelToken.cancel("Controller is being disposed");
    LogUtils.d('网络请求已取消', 'MyVideoStateController');

    try {
      // 取消定时器
      _positionUpdateThrottleTimer?.cancel();
      _displayUpdateTimer?.cancel();
      _lockButtonHideTimer?.cancel();
      _autoHideTimer?.cancel();
      _mouseMovementTimer?.cancel();
      _resumeTipTimer?.cancel();
      LogUtils.d('所有定时器已取消', 'MyVideoStateController');

      // 取消 Stream 订阅
      _cancelSubscriptions();
      _volumeListenerDisposer?.cancel();
      _pipStatusSubscription?.cancel();
      LogUtils.d('所有订阅已取消', 'MyVideoStateController');

      // 释放播放器资源
      try {
        player.dispose();
        LogUtils.w('播放器资源已释放', 'MyVideoStateController');
      } catch (e) {
        LogUtils.w('尝试释放播放器资源时出错: $e', 'MyVideoStateController');
      }

      // 移除生命周期观察者
      WidgetsBinding.instance.removeObserver(this);
      LogUtils.d('生命周期观察者已移除', 'MyVideoStateController');

      // 销毁动画控制器
      animationController.dispose();

      // 清理滚动控制器
      if (isInitialized) {
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
    LogUtils.d('应用生命周期状态变更: $state', 'MyVideoStateController');

    // 当应用从后台恢复到前台时
    if (state == AppLifecycleState.resumed) {
      LogUtils.d('应用进入前台，设置默认屏幕亮度', 'MyVideoStateController');
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
    ]);
  }

  /// 获取视频详情信息
  void fetchVideoDetail(String videoId) async {
    if (_isDisposed) return;

    LogUtils.i('开始获取视频详情，videoId: $videoId', 'MyVideoStateController');
    isVideoInfoLoading.value = true;
    videoErrorMessage.value = null;
    mainErrorWidget.value = null;

    try {
      var res = await _apiService.get(
        '/video/$videoId',
        cancelToken: _cancelToken,
      );

      if (_isDisposed) return;

      videoInfo.value = video_model.Video.fromJson(res.data);
      if (videoInfo.value == null) {
        LogUtils.e('视频信息为空', tag: 'MyVideoStateController');
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

      LogUtils.d('成功获取视频信息: ${videoInfo.value?.title}, 作者: ${videoInfo.value?.user?.name}', 'MyVideoStateController');

      // TODO: 创建 oreno3dClient
      // try {
      //   final oreno3dClient = Oreno3dClient();
      //   // 获取 oreno3d 视频信息
      //   final oreno3dVideo = await oreno3dClient.searchVideos(keyword: videoInfo.value!.title!);
      //   LogUtils.d('成功获取 oreno3d 视频信息 ${oreno3dVideo.videos.length}, 第一个视频: ${oreno3dVideo.videos.first.title},第一个视频的作者: ${oreno3dVideo.videos.first.author}', 'MyVideoStateController');
      // } catch (e) {
      //   LogUtils.e('获取 oreno3d 视频信息失败: $e', tag: 'MyVideoStateController', error: e);
      // }



      // 添加历史记录
      try {
        if (videoInfo.value != null) {
          final historyRecord = HistoryRecord.fromVideo(videoInfo.value!);
          LogUtils.d('添加历史记录: ${historyRecord.toJson()}', 'MyVideoStateController');
          await _historyRepository.addRecordWithCheck(historyRecord);
          if (_isDisposed) return;
        }
      } catch (e) {
        if (!_isDisposed) {
          LogUtils.e('添加历史记录失败', tag: 'MyVideoStateController', error: e);
        }
      }

      String? authorId = videoInfo.value!.user?.id;
      if (authorId != null) {
        otherAuthorzVideosController = OtherAuthorzMediasController(
            mediaId: videoId, userId: authorId, mediaType: MediaType.VIDEO);
        otherAuthorzVideosController!.fetchRelatedMedias();
      }

      if (videoInfo.value!.private == false &&
          videoInfo.value!.fileUrl != null) {
        await fetchVideoSource();
      }
    } on DioException catch (e) {
      if (_isDisposed || e.type == DioExceptionType.cancel) {
        LogUtils.w('请求被取消或Controller已销毁', 'MyVideoStateController');
        return;
      }
      LogUtils.e('获取视频详情失败 (Dio): $e', tag: 'MyVideoStateController', error: e);
      if (!_isDisposed) {
        if (e.response?.statusCode == 403) {
          var data = e.response?.data;
          if (data != null &&
              data['message'] != null &&
              data['message'] == 'errors.privateVideo') {
            User author = User.fromJson(data['data']['user']);
            mainErrorWidget.value = PrivateOrDeletedVideoWidget(author: author, isPrivate: true);
          }
        } else if (e.response?.statusCode == 404) {
          mainErrorWidget.value = PrivateOrDeletedVideoWidget(isPrivate: false);
        } else {
          mainErrorWidget.value = CommonErrorWidget(
            text: slang.t.videoDetail.getVideoInfoFailed,
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
        LogUtils.e('获取视频详情失败 (Other): $e', tag: 'MyVideoStateController', error: e);
        mainErrorWidget.value = CommonErrorWidget(
          text: slang.t.videoDetail.getVideoInfoFailed,
          children: [
            ElevatedButton(
              onPressed: () => AppService.tryPop(),
              child: Text(slang.t.common.back),
            ),
          ],
        );
      }
    } finally {
      if (!_isDisposed) {
        isVideoInfoLoading.value = false;
      }
    }
  }

  /// 获取视频源信息
  Future<void> fetchVideoSource() async {
    if (_isDisposed) return;
    if (videoInfo.value?.fileUrl == null) {
      LogUtils.w('视频 FileUrl 为空，无法获取源', 'MyVideoStateController');
      return;
    }

    isVideoSourceLoading.value = true;
    videoErrorMessage.value = null;

    try {
      var res = await _apiService.get(
        videoInfo.value!.fileUrl!,
        headers: {
          'X-Version':
          XVersionCalculatorUtil.calculateXVersion(videoInfo.value!.fileUrl!),
        },
        cancelToken: _cancelToken,
      );

      if (_isDisposed) return;

      List<dynamic> data = res.data;
      List<VideoSource> sources =
      data.map((item) => VideoSource.fromJson(item)).toList();
      currentVideoSourceList.value = sources;

      var lastUserSelectedResolution =
      _configService[ConfigKey.DEFAULT_QUALITY_KEY];
      videoInfo.value = videoInfo.value!.copyWith(videoSources: sources);

      if (_isDisposed) return;
      await resetVideoInfo(
        title: videoInfo.value!.title ?? '',
        resolutionTag: lastUserSelectedResolution,
        videoResolutions: CommonUtils.convertVideoSourcesToResolutions(
            videoInfo.value!.videoSources,
            filterPreview: true),
      );
    } on DioException catch (e) {
      if (_isDisposed || e.type == DioExceptionType.cancel) {
        LogUtils.w('请求被取消或Controller已销毁', 'MyVideoStateController');
        return;
      }
      LogUtils.e('获取视频源失败 (Dio): $e', tag: 'MyVideoStateController', error: e);
      if (!_isDisposed) {
        if (e.response?.statusCode == 404) {
          videoErrorMessage.value = 'resource_404';
        } else {
          videoErrorMessage.value = slang.t.videoDetail.getVideoInfoFailed;
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.e('获取视频源失败 (Other): $e', tag: 'MyVideoStateController', error: e);
        videoErrorMessage.value = slang.t.videoDetail.getVideoInfoFailed;
      }
    } finally {
      if (!_isDisposed) {
        isVideoSourceLoading.value = false;
      }
    }
  }

  /// 切换清晰度
  Future<void> switchResolution(String resolutionTag) async {
    // 检查控制器是否已销毁
    if (_isDisposed) {
      LogUtils.d('控制器已销毁，取消切换清晰度', 'MyVideoStateController');
      return;
    }

    LogUtils.i('[切换清晰度] $resolutionTag', 'MyVideoStateController');
    if (resolutionTag == currentResolutionTag.value) {
      LogUtils.d('清晰度相同，无需切换', 'MyVideoStateController');
      return;
    }

    // 通过tag找出对应的视频源
    String? url =
    CommonUtils.findUrlByResolutionTag(videoResolutions, resolutionTag);
    if (url == null) {
      showToastWidget(MDToastWidget(message: slang.t.videoDetail.noVideoSourceFound, type: MDToastType.error),position: ToastPosition.top);
      return;
    }

    await resetVideoInfo(
      title: videoInfo.value!.title ?? '',
      resolutionTag: resolutionTag,
      videoResolutions: videoResolutions.toList(),
      position: currentPosition,
    );
  }

  /// 重置视频信息并加载新视频
  Future<void> resetVideoInfo({
    required String title,
    required String resolutionTag,
    required List<VideoResolution> videoResolutions,
    Duration position = Duration.zero,
  }) async {
    if (_isDisposed) return;
    LogUtils.i('[重置视频] $title $resolutionTag $videoResolutions $position', 'MyVideoStateController');

    if (_isDisposed) return;
    await _cancelSubscriptions();
    if (_isDisposed) return;

    _clearBuffers();

    videoIsReady.value = false;
    _configService[ConfigKey.DEFAULT_QUALITY_KEY] = resolutionTag;
    this.videoResolutions.value = videoResolutions;
    currentPosition = position;
    currentResolutionTag.value = resolutionTag;
    sliderDragLoadFinished.value = true;
    _clearBuffers();

    String? url =
    CommonUtils.findUrlByResolutionTag(videoResolutions, resolutionTag);
    if (url == null) {
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

    if (_isDisposed) return;
    try {
      await player.open(Media(url));
      if (_isDisposed) return;
      _setupListenersAfterOpen();
    } catch (e) {
      if (!_isDisposed) {
        LogUtils.e('Player open 或设置监听器时出错: $e', tag: 'MyVideoStateController', error: e);
        videoErrorMessage.value = slang.t.videoDetail.errorLoadingVideo;
      } else {
        LogUtils.w('Player open 或设置监听器时 Controller 已销毁: $e', 'MyVideoStateController');
      }
    }
  }

  // 封装监听器设置
  void _setupListenersAfterOpen() {
    if (_isDisposed) return;

    _setupPositionListener();

    bufferingSubscription = player.stream.buffering.listen((buffering) async {
      if (_isDisposed) return;
      videoBuffering.value = buffering;
    });

    durationSubscription = player.stream.duration.listen((duration) {
      if (_isDisposed) return;
      totalDuration.value = duration;
    });

    widthSubscription = player.stream.width.listen((width) {
      if (_isDisposed) return;
      if (width != null) {
        sourceVideoWidth.value = width;
      }
    });

    heightSubscription = player.stream.height.listen((height) {
      if (_isDisposed) return;
      if (height != null) {
        sourceVideoHeight.value = height;
        _updateAspectRatio();
      }
    });

    playingSubscription = player.stream.playing.listen((playing) {
      if (_isDisposed) return;
      if (playing != videoPlaying.value) {
        videoPlaying.value = playing;
        // 当播放状态改变时，刷新滚动视图
        WidgetsBinding.instance.addPostFrameCallback((_) {
          refreshScrollView();
        });
      }
    });

    bufferSubscription = player.stream.buffer.listen((bufferDuration) {
      if (_isDisposed) return;
      _addBufferRange(bufferDuration);
    });
  }

  /// 更新视频宽高比
  void _updateAspectRatio() async {
    if (_isDisposed) return;

    aspectRatio.value = sourceVideoWidth.value / sourceVideoHeight.value;
    LogUtils.d(
        '[更新后的宽高比] $aspectRatio, 视频高度: $sourceVideoHeight, 视频宽度: $sourceVideoWidth', 'MyVideoStateController');

    if (!videoIsReady.value && !_isDisposed) {
      videoIsReady.value = true;
      int targetPositionMs = 0;

      try {
        if (!firstLoaded && _configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]) {
          final history = await _playbackHistoryService.getPlaybackHistory(videoId!);
          if (_isDisposed) return;

          if (history != null) {
            final playedDuration = history['played_duration'] as int;
            final totalDurationMs = history['total_duration'] as int;
            targetPositionMs = (playedDuration - 4000).clamp(0, totalDurationMs);
            showResumeFromPositionTip(Duration(milliseconds: targetPositionMs));
          }
        } else if (firstLoaded) {
          targetPositionMs = currentPosition.inMilliseconds;
        }

        if (!_isDisposed) {
          LogUtils.d('准备 Seek 到: ${Duration(milliseconds: targetPositionMs)}', 'MyVideoStateController');
          await player.seek(Duration(milliseconds: targetPositionMs));
          if (_isDisposed) return;
        }
      } catch (e) {
        if (!_isDisposed) {
          LogUtils.e('获取或恢复播放记录/Seek时失败: $e', tag: 'MyVideoStateController', error: e);
        }
      } finally {
        if (!_isDisposed) {
          firstLoaded = true;
        }
      }
    }
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
    if (renderVerticalVideoInVerticalScreen && aspectRatio.value < 1) {
      await CommonUtils.defaultEnterNativeFullscreen(toVerticalScreen: true);
    } else {
      await defaultEnterNativeFullscreen();
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
    if (_isInteracting.value || _isHoveringToolbar.value) return;

    _autoHideTimer = Timer(_autoHideDelay, () {
      // 如果正在交互或悬浮在工具栏上，不执行隐藏
      if (!_isInteracting.value && !_isHoveringToolbar.value && animationController.value == 1.0) {
        animationController.reverse();
        isLockButtonVisible.value = false; // 同时隐藏锁定按钮
      }
    });
  }

  // 设置交互状态
  void setInteracting(bool value) {
    _isInteracting.value = value;
    if (!value) {
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
      if (_isMouseHoveringPlayer.value && !_isInteracting.value && !_isHoveringToolbar.value) {
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
    double speed = _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY];
    player.setRate(speed);
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

    final Duration start = currentPosition;
    final Duration end = bufferDuration;

    // 如果缓冲时长小于等于当前播放位置，或大于总时长，则忽略
    if (end <= Duration.zero || end > totalDuration.value) {
      return;
    }

    BufferRange newRange = BufferRange(start: start, end: end);
    List<BufferRange> updatedBuffers = List<BufferRange>.from(buffers);

    // 尝试合并重叠的缓冲区
    bool merged = false;
    for (int i = 0; i < updatedBuffers.length; i++) {
      BufferRange existingRange = updatedBuffers[i];
      if (existingRange.overlapsOrAdjacent(newRange)) {
        updatedBuffers[i] = existingRange.merge(newRange);
        merged = true;
        break;
      }
    }

    if (!merged) {
      updatedBuffers.add(newRange);
    }

    // 对缓冲区进行排序并移除无效的缓冲区
    updatedBuffers.sort((a, b) => a.start.compareTo(b.start));
    updatedBuffers.removeWhere((range) =>
    range.end <= currentPosition ||
        range.start >= totalDuration.value
    );

    // 合并相邻的缓冲区
    for (int i = updatedBuffers.length - 2; i >= 0; i--) {
      if (updatedBuffers[i].overlapsOrAdjacent(updatedBuffers[i + 1])) {
        updatedBuffers[i] = updatedBuffers[i].merge(updatedBuffers[i + 1]);
        updatedBuffers.removeAt(i + 1);
      }
    }

    buffers.value = updatedBuffers;
  }

  void _handleSeek(Duration newPosition) async {
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

    // 先更新UI位置
    currentPosition = newPosition;

    // 执行实际的seek操作
    await player.seek(newPosition);

    // seek完成后标记状态
    isWaitingForSeek.value = false;
  }

  void _clearBuffers() {
    buffers.clear();
  }

  /// 显示/隐藏进度预
  void showSeekPreview(bool show) {
    isSeekPreviewVisible.value = show;
  }

  /// 更新预览位置
  void updateSeekPreview(Duration position) {
    previewPosition.value = position;
  }

  void handleSeek(Duration newPosition) {
    _handleSeek(newPosition);
  }

  // 在类中添加这个方法:
  void showResumeFromPositionTip(Duration position) {
    resumePosition.value = position;
    showResumePositionTip.value = true;

    // 3秒后自动隐藏
    _resumeTipTimer?.cancel();
    _resumeTipTimer = Timer(const Duration(seconds: 3), () {
      showResumePositionTip.value = false;
    });
  }

  // 添加关闭提示的方法:
  void hideResumePositionTip() {
    showResumePositionTip.value = false;
    _resumeTipTimer?.cancel();
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
    LogUtils.d("进入画中画模式，设置宽高比为：$width:$height, Rational: $ratio", "MyVideoStateController");
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

  // 修改position监听器
  void _setupPositionListener() {
    positionSubscription = player.stream.position.listen((position) async {
      // 在回调中检查控制器是否已销毁
      if (_isDisposed) return;

      if (!videoIsReady.value) return;

      // 只有在不是等待seek完成的状态下才更新位置
      if (!isWaitingForSeek.value) {
        // 节流处理
        if (_positionUpdateThrottleTimer?.isActive ?? false) {
          // 保存最新位置，但不立即更新
          _lastPosition = position;
          return;
        }

        // 更新位置并设置节流定时器
        currentPosition = position;
        _lastPosition = position;

        _positionUpdateThrottleTimer = Timer(_positionUpdateThrottleInterval, () {
          // 定时器触发时，如果最新位置与当前显示位置不同，则更新
          if (_isDisposed) return;
          if (_lastPosition != currentPosition) {
            currentPosition = _lastPosition;
          }
        });

        // 检查视频是否播放完成的逻辑
        if (!_isSettingPlayMode &&
            videoIsReady.value &&
            totalDuration.value.inMilliseconds > 0 &&
            position.inMilliseconds > 0 &&
            (position.inMilliseconds >= totalDuration.value.inMilliseconds - 2000)) {
          _isSettingPlayMode = true;
          bool repeat = _configService[ConfigKey.REPEAT_KEY];
          if (repeat) {
            LogUtils.d('[视频即将播放完成]，设置播放模式', 'MyVideoStateController');
            _clearBuffers();
            if (!_isDisposed) {
              player.setPlaylistMode(PlaylistMode.loop);
            }
          } else {
            if (!_isDisposed) {
              player.setPlaylistMode(PlaylistMode.none);
            }
          }
          // 设置一个延时，在视频真正结束后重置标志位
          Future.delayed(const Duration(seconds: 3), () {
            if (!_isDisposed) {
              _isSettingPlayMode = false;
            }
          });
        }
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
    _displayUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (videoIsReady.value && !isWaitingForSeek.value) {
        toShowCurrentPosition.value = currentPosition;
      }
    });
  }

  // 滚动相关方法
  void _initializeScrollSettings() {
    // 计算视频高度范围
    final screenSize = Get.size;
    minVideoHeight = max(screenSize.shortestSide * 9 / 16, 250);
    maxVideoHeight = screenSize.longestSide * 0.65;
    videoHeight = minVideoHeight;
    
    // 添加滚动监听器
    scrollController.addListener(_scrollListener);
    
    isInitialized = true;
    LogUtils.d('滚动设置初始化完成: minHeight=$minVideoHeight, maxHeight=$maxVideoHeight', 'MyVideoStateController');
  }

  void _scrollListener() {
    if (!scrollController.hasClients || !isInitialized) return;

    final offset = scrollController.offset;
    final screenSize = Get.size;
    final paddingTop =
        Get.context != null ? MediaQuery.of(Get.context!).padding.top : 0;
    final videoHeight =
        getCurrentVideoHeight(screenSize.width, screenSize.height, paddingTop.toDouble());

    // 计算滚动比例
    if (offset == 0) {
      scrollRatio.value = 0.0;
    } else {
      final offsetAfterVideo = offset - (videoHeight - minVideoHeight);
      if (offsetAfterVideo > 0) {
        scrollRatio.value = (offsetAfterVideo / (minVideoHeight - kToolbarHeight)).clamp(0.0, 1.0);
      } else {
        scrollRatio.value = 0.0;
      }
    }
  }

  double getCurrentVideoHeight(
      double screenWidth, double screenHeight, double paddingTop) {
    // 根据视频状态确定高度
    if (isVideoInfoLoading.value || !videoIsReady.value) {
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


}

/// 视频清晰度模型
class VideoResolution {
  final String label;
  final String url;

  VideoResolution({required this.label, required this.url});
}
