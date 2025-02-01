import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
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
import '../widgets/private_video_widget.dart';
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
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxBool videoPlaying = false.obs;
  final RxBool videoBuffering = true.obs;
  final RxBool sliderDragLoadFinished = true.obs; // 拖动进度条加载完成
  final RxDouble playerPlaybackSpeed = 1.0.obs; // 播放速度
  final RxBool isDesktopAppFullScreen = false.obs; // 是否是应用全屏
  bool firstLoaded = false;

  // 工具栏可见性
  final RxBool areToolbarsVisible = true.obs;

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

  MyVideoStateController(this.videoId);

  @override
  void onInit() async {
    super.onInit();
    // 添加生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    
    // 动画
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

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

    // 初始化 VideoController
    player = Player();
    videoController = VideoController(player);

    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      // 初始化并关闭系统音量UI
      volumeController = VolumeController();
      volumeController?.showSystemUI = false;
      // 添加音量监听
      _volumeListenerDisposer = volumeController?.listener((volume) {
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

    fetchVideoDetail(videoId!);
  }

  void _setupPiPListener() {
    if (GetPlatform.isAndroid) {
      _pipStatusSubscription = Floating().pipStatusStream.listen((status) {
        if (status == PiPStatus.enabled) {
          if (!isPiPMode.value) enterPiPMode();
        } else {
          if (isPiPMode.value) exitPiPMode();
        }
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
          ScreenBrightness().setScreenBrightness(lastBrightness);
        } catch (e) {
          LogUtils.e('设置亮度失败: $e', tag: 'MyVideoStateController', error: e);
        }
      }
    }
  }

  @override
  void onClose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    
    // 保存播放记录
    if (videoId != null && totalDuration.value.inMilliseconds > 0) {
      final currentMs = currentPosition.value.inMilliseconds;
      final totalMs = totalDuration.value.inMilliseconds;
      
      // 如果在开头5秒或结尾5秒,删除记录
      if (currentMs <= 5000 || currentMs >= (totalMs - 5000)) {
        _playbackHistoryService.deletePlaybackHistory(videoId!);
      } else {
        // 否则保存/更新记录
        _playbackHistoryService.savePlaybackHistory(
          videoId!,
          totalMs,
          currentMs,
        );
      }
    }
    
    _autoHideTimer?.cancel();
    _cancelSubscriptions();
    _volumeListenerDisposer?.cancel(); // 取消音量监听
    player.dispose();
    _resumeTipTimer?.cancel();
    _pipStatusSubscription?.cancel(); // 取消监听
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 当应用从后台恢复到前台时
    if (state == AppLifecycleState.resumed) {
      setDefaultBrightness();
    }
  }

  // 取消监��
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
    try {
      isVideoInfoLoading.value = true;
      isVideoSourceLoading.value = true;
      videoErrorMessage.value = null;

      // 获取视频基本信息
      var res = await _apiService.get('/video/$videoId');
      videoInfo.value = video_model.Video.fromJson(res.data);
      if (videoInfo.value == null) {
        mainErrorWidget.value = CommonErrorWidget(
          text: slang.t.videoDetail.videoInfoIsEmpty,
          children: [
            ElevatedButton(
              onPressed: () => AppService.tryPop(),
              child: Text(slang.t.common.back),
            ),
          ],
        );
        return;
      }

      // 添加历史记录
      try {
        if (videoInfo.value != null) {
          final historyRecord = HistoryRecord.fromVideo(videoInfo.value!);
          LogUtils.d('添加历史记录: ${historyRecord.toJson()}', 'MyVideoStateController');
          await _historyRepository.addRecordWithCheck(historyRecord);
        }
      } catch (e) {
        LogUtils.e('添加历史记录失败', tag: 'MyVideoStateController', error: e);
      }

      String? authorId = videoInfo.value!.user?.id;
      if (authorId != null) {
        otherAuthorzVideosController = OtherAuthorzMediasController(
            mediaId: videoId, userId: authorId, mediaType: MediaType.VIDEO);
        otherAuthorzVideosController!.fetchRelatedMedias();
      }

      // 如果视频不是私密的且有文件URL，则获取视频源
      if (videoInfo.value!.private == false &&
          videoInfo.value!.fileUrl != null) {
        fetchVideoSource();
      }
    } catch (e) {
      // 处理 403 错误，表示这是一个私密视频
      LogUtils.e('获取视频详情失败: $e', tag: 'MyVideoStateController', error: e);
      if (e is DioException && e.response?.statusCode == 403) {
        var data = e.response?.data;
        if (data != null && 
            data['message'] != null && 
            data['message'] == 'errors.privateVideo') {
          User author = User.fromJson(data['data']['user']);
          mainErrorWidget.value = PrivateVideoWidget(author: author);
          return;
        }
      }
      mainErrorWidget.value = CommonErrorWidget(
        text: slang.t.videoDetail.getVideoInfoFailed,
        children: [
          ElevatedButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.back),
          ),
        ],
      );
    } finally {
      // 无论成功还是失败，都将加载状态设置为 false
      isVideoInfoLoading.value = false;
      isVideoSourceLoading.value = false;
    }
  }

  /// 获取视频源信息
  Future<void> fetchVideoSource() async {
    try {
      isVideoSourceLoading.value = true;
      videoErrorMessage.value = null;

      // 获取视频源数据
      var res = await _apiService.get(videoInfo.value!.fileUrl!, headers: {
        'X-Version':
            XVersionCalculatorUtil.calculateXVersion(videoInfo.value!.fileUrl!),
      });
      List<dynamic> data = res.data;
      List<VideoSource> sources =
          data.map((item) => VideoSource.fromJson(item)).toList();
      currentVideoSourceList.value = sources;

      var lastUserSelectedResolution =
          _configService[ConfigKey.DEFAULT_QUALITY_KEY];
      // 使用 Video 的 copyWith 方法来更新 videoSources
      videoInfo.value = videoInfo.value!.copyWith(videoSources: sources);

      await resetVideoInfo(
        title: videoInfo.value!.title ?? '',
        resolutionTag: lastUserSelectedResolution,
        videoResolutions: CommonUtils.convertVideoSourcesToResolutions(
            videoInfo.value!.videoSources,
            filterPreview: true),
      );
    } catch (e) {
      // 如果是个 404 的DioException 
      if (e is DioException && e.response?.statusCode == 404) {
        videoErrorMessage.value = 'resource_404';
        return;
      }

      // 处理错误
      LogUtils.e('获取视频源失败: $e', tag: 'MyVideoStateController', error: e);
      videoErrorMessage.value = slang.t.videoDetail.getVideoInfoFailed;
    } finally {
      // 无论成功还是失败，都将加载状态设置为 false
      isVideoSourceLoading.value = false;
    }
  }

  /// 切换清晰度
  Future<void> switchResolution(String resolutionTag) async {
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
      position: currentPosition.value,
    );
  }

  /// 重置视频信息并加载新视频
  Future<void> resetVideoInfo({
    required String title,
    required String resolutionTag,
    required List<VideoResolution> videoResolutions,
    Duration position = Duration.zero,
  }) async {
    LogUtils.i('[重置视频] $title $resolutionTag $videoResolutions $position', 'MyVideoStateController');

    await _cancelSubscriptions();

    videoIsReady.value = false;
    _configService[ConfigKey.DEFAULT_QUALITY_KEY] = resolutionTag;
    this.videoResolutions.value = videoResolutions;
    currentPosition.value = position;
    currentResolutionTag.value = resolutionTag;
    sliderDragLoadFinished.value = true;
    _clearBuffers(); // 清空缓冲区

    // 通过tag找出对应的视频源
    String? url =
        CommonUtils.findUrlByResolutionTag(videoResolutions, resolutionTag);
    if (url == null) {
      mainErrorWidget.value = CommonErrorWidget(
        text: slang.t.videoDetail.noVideoSourceFound,
        children: [
          ElevatedButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.back),
          ),
        ],
      );
      return;
    }

    await player.open(Media(url));

    // 监听缓冲状态
    bufferingSubscription = player.stream.buffering.listen((buffering) async {
      // LogUtils.d('[视频缓冲中] $buffering', 'MyVideoStateController');
      videoBuffering.value = buffering;
    });

    // 监听播放位置
    positionSubscription = player.stream.position.listen((position) async {
      if (!videoIsReady.value) return;

      // 只有在不是等待seek完成的状态下才更新位置
      if (!isWaitingForSeek.value) {
        if (videoIsReady.value &&
            totalDuration.value.inMilliseconds > 0 &&
            position.inMilliseconds > 0 &&
            (position.inMilliseconds >= totalDuration.value.inMilliseconds - 100)) {
          bool repeat = _configService[ConfigKey.REPEAT_KEY];
          if (repeat) {
            LogUtils.d('[视频播放完成]，尝试重播', 'MyVideoStateController');
            // 清空缓冲区
            _clearBuffers();
            player.setPlaylistMode(PlaylistMode.loop);
          } else {
            player.setPlaylistMode(PlaylistMode.single);
          }
        }

        currentPosition.value = position;
      }
      sliderDragLoadFinished.value = true;
    });

    // 监听视频总时长
    durationSubscription = player.stream.duration.listen((duration) {
      LogUtils.d('[视频总时长] $duration', 'MyVideoStateController');
      totalDuration.value = duration;
    });

    // 监听视频宽度
    widthSubscription = player.stream.width.listen((width) {
      LogUtils.d('[视频宽度] $width', 'MyVideoStateController');
      if (width != null) {
        sourceVideoWidth.value = width;
      }
    });

    // 监听视频高度
    heightSubscription = player.stream.height.listen((height) {
      LogUtils.d('[视频高度] $height', 'MyVideoStateController');
      if (height != null) {
        sourceVideoHeight.value = height;
        _updateAspectRatio();
      }
    });

    // 正在播放
    playingSubscription = player.stream.playing.listen((playing) {
      LogUtils.d('[正在播放] $playing', 'MyVideoStateController');
      videoPlaying.value = playing;
    });

    // 缓冲进度
    bufferSubscription = player.stream.buffer.listen((bufferDuration) {
      _addBufferRange(bufferDuration);
    });
  }

  /// 更新视频宽高比
  void _updateAspectRatio() async {
    aspectRatio.value = sourceVideoWidth.value / sourceVideoHeight.value;
    LogUtils.d(
        '[更新后的宽高比] $aspectRatio, 视频高度: $sourceVideoHeight, 视频宽度: $sourceVideoWidth', 'MyVideoStateController');
    if (!videoIsReady.value) {
      videoIsReady.value = true;
      int targetPosition = 0;

      // 避免初次加载视频时，又被seek到0
      if (firstLoaded) {
        // 刷新率切换触发的更新
        await player.seek(currentPosition.value);
      } else {
        // 新视频加载触发的更新
        if (_configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]) {
          try {
            final history = await _playbackHistoryService.getPlaybackHistory(videoId!);
            if (history != null) {
              // 设置初始播放位置为历史记录位置减去4秒，但不小于0
              final playedDuration = history['played_duration'] as int;
              final totalDuration = history['total_duration'] as int;
              targetPosition = (playedDuration - 4000).clamp(0, totalDuration);
              await player.seek(Duration(milliseconds: targetPosition));
              showResumeFromPositionTip(Duration(milliseconds: targetPosition));
            }
            // 如果播放记录不存在，则不显示，不处理
          } catch (e) {
            LogUtils.e('获取播放记录失败', tag: 'MyVideoStateController', error: e);
          }
        }
      }
      firstLoaded = true;
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

  // 修改现有的 toggleToolbars 方法
  void toggleToolbars() {
    if (animationController.isCompleted) {
      animationController.reverse();
      _autoHideTimer?.cancel(); // 用户主动隐藏时取消定时器
    } else {
      animationController.forward();
      _resetAutoHideTimer();
    }
  }

  // 显示工具栏（不切换状态）
  void showToolbars() {
    if (!animationController.isCompleted) {
      animationController.forward();
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
    _configService.setSetting(ConfigKey.VOLUME_KEY, volume); // 移除save参数
    _isAdjustingVolumeByGesture = false;
  }

  void _addBufferRange(Duration bufferDuration) {
    // 如果总时长为0，说明视频还未加载，不处理缓冲
    if (totalDuration.value.inMilliseconds == 0) return;
    
    final Duration start = currentPosition.value;
    final Duration end = bufferDuration;

    // 如果缓冲时长小于等于当前播放位置，或大于总时长，则忽略
    if (end <= start || end > totalDuration.value) {
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
      range.end <= currentPosition.value || 
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
    if (newPosition < currentPosition.value) {
      _clearBuffers();
    } else {
      // 清理失效的缓冲区
      List<BufferRange> updatedBuffers = buffers.where((range) {
        return range.end > newPosition && range.start < totalDuration.value;
      }).toList();

      buffers.value = updatedBuffers;
    }
    
    // 先更新UI位置
    currentPosition.value = newPosition;
    
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
  void enterPiPMode() {
    isPiPMode.value = true;
    player.play();
  }

  /// 退出画中画模式
  void exitPiPMode() {
    isPiPMode.value = false;
  }
}

/// 视频清晰度模型
class VideoResolution {
  final String label;
  final String url;

  VideoResolution({required this.label, required this.url});
}
