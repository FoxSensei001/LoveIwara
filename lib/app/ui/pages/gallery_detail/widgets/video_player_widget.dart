import 'package:flutter/material.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';

/// 视频播放器组件
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Map<String, String>? headers;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.headers,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

// 暴露状态类以便外部控制
class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late Player _player;
  late VideoController _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isPlaying = false;
  int _retryCount = 0;
  static const int _maxRetries = 2;
  bool _isWebmCodecError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      LogUtils.d('开始初始化视频播放器: ${widget.videoUrl}', 'VideoPlayerWidget');

      _player = Player();
      _videoController = VideoController(_player);

      // 设置播放器监听器
      _setupPlayerListeners();

      // 检查视频格式兼容性
      final fileExtension = CommonUtils.getFileExtension(widget.videoUrl).toLowerCase();
      LogUtils.d('视频格式: $fileExtension', 'VideoPlayerWidget');

      // Android平台对某些格式的特殊处理
      if (fileExtension == 'webm') {
        LogUtils.w('检测到WEBM格式，Android平台可能存在兼容性问题', 'VideoPlayerWidget');
      }

      // 打开视频但不自动播放
      LogUtils.d('开始加载视频文件', 'VideoPlayerWidget');
      await _openVideoWithRetry();

    } catch (e, stackTrace) {
      LogUtils.e('视频播放器初始化失败: $e', tag: 'VideoPlayerWidget', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// 带重试机制的视频打开方法
  Future<void> _openVideoWithRetry() async {
    while (_retryCount <= _maxRetries) {
      try {
        LogUtils.d('尝试打开视频 (第${_retryCount + 1}次)', 'VideoPlayerWidget');

        // 创建媒体对象，针对Android平台进行优化
        final media = Media(
          widget.videoUrl,
          httpHeaders: widget.headers,
        );

        await _player.open(media);
        await _player.pause(); // 确保暂停状态
        LogUtils.d('视频文件加载完成', 'VideoPlayerWidget');
        return; // 成功则退出

      } catch (e) {
        _retryCount++;
        LogUtils.w('视频打开失败 (第$_retryCount次尝试): $e', 'VideoPlayerWidget');

        if (_retryCount > _maxRetries) {
          LogUtils.e('视频打开重试次数已达上限', tag: 'VideoPlayerWidget');
          rethrow; // 重新抛出异常
        }

        // 等待一段时间后重试
        await Future.delayed(Duration(milliseconds: 500 * _retryCount));

        // 重新创建播放器实例
        try {
          _player.dispose();
          _player = Player();
          _videoController = VideoController(_player);
          _setupPlayerListeners();
        } catch (disposeError) {
          LogUtils.w('重新创建播放器时出错: $disposeError', 'VideoPlayerWidget');
        }
      }
    }
  }

  /// 设置播放器监听器
  void _setupPlayerListeners() {
    _player.stream.error.listen((error) {
      LogUtils.e('视频播放器错误: $error', tag: 'VideoPlayerWidget', error: error);

      // 检测是否为WEBM编解码器错误
      final isCodecError = error.toString().toLowerCase().contains('could not open codec');
      final fileExtension = CommonUtils.getFileExtension(widget.videoUrl).toLowerCase();
      final isWebmError = isCodecError && fileExtension == 'webm';

      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = error;
          _isWebmCodecError = isWebmError;
        });
      }
    });

    _player.stream.buffering.listen((buffering) {
      LogUtils.d('视频缓冲状态: $buffering', 'VideoPlayerWidget');
      if (mounted && !buffering && !_isInitialized) {
        LogUtils.d('视频初始化完成', 'VideoPlayerWidget');
        setState(() {
          _isInitialized = true;
        });
      }
    });

    _player.stream.playing.listen((playing) {
      LogUtils.d('视频播放状态: $playing', 'VideoPlayerWidget');
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });

    _player.stream.duration.listen((duration) {
      LogUtils.d('视频时长: $duration', 'VideoPlayerWidget');
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  /// 外部控制：暂停播放
  void pauseVideo() {
    if (_isInitialized && !_hasError) {
      _player.pause();
      LogUtils.d('外部控制：暂停视频播放', 'VideoPlayerWidget');
    }
  }

  /// 外部控制：停止播放并重置到开始位置
  void stopVideo() {
    if (_isInitialized && !_hasError) {
      _player.pause();
      _player.seek(Duration.zero);
      LogUtils.d('外部控制：停止视频播放', 'VideoPlayerWidget');
    }
  }

  /// 外部控制：释放播放器资源
  void releasePlayer() {
    if (_isInitialized && !_hasError) {
      _player.pause();
      LogUtils.d('外部控制：释放播放器资源', 'VideoPlayerWidget');
    }
  }

  /// 检查是否正在播放
  bool get isPlaying => _isPlaying;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器
          Video(
            controller: _videoController,
            controls: NoVideoControls,
            fit: BoxFit.contain,
          ),

          // 播放/暂停图标覆盖层
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

          // 视频标识
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
                                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        slang.t.mediaPlayer.video,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final fileExtension = CommonUtils.getFileExtension(widget.videoUrl);

    // 针对不同错误类型提供更详细的说明
    String errorDescription = slang.t.mediaPlayer.videoLoadFailed;
    String? suggestion;

    if (_errorMessage != null) {
      final errorMsg = _errorMessage!.toLowerCase();

      if (errorMsg.contains('could not open codec')) {
        errorDescription = slang.t.mediaPlayer.videoCodecNotSupported;
        if (fileExtension.toLowerCase() == 'webm') {
          suggestion = slang.t.mediaPlayer.androidWebmCompatibilityIssue;
        } else {
          suggestion = slang.t.mediaPlayer.currentDeviceCodecNotSupported;
        }
      } else if (errorMsg.contains('network') || errorMsg.contains('connection')) {
        errorDescription = slang.t.mediaPlayer.networkConnectionIssue;
        suggestion = slang.t.mediaPlayer.checkNetworkConnection;
      } else if (errorMsg.contains('permission')) {
        errorDescription = slang.t.mediaPlayer.insufficientPermission;
        suggestion = slang.t.mediaPlayer.appMayLackMediaPermission;
      } else if (errorMsg.contains('format') || errorMsg.contains('unsupported')) {
        errorDescription = slang.t.mediaPlayer.unsupportedVideoFormat;
        suggestion = slang.t.mediaPlayer.tryOtherVideoPlayer;
      }
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              errorDescription,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${slang.t.mediaPlayer.format}: ${fileExtension.toUpperCase()}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            if (suggestion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  slang.t.mediaPlayer.detailedErrorInfo,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // 添加操作按钮
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryInitialization,
                  icon: const Icon(Icons.refresh),
                  label: Text(slang.t.mediaPlayer.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_isWebmCodecError) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _openWithExternalPlayer,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(slang.t.mediaPlayer.externalPlayer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 重试初始化
  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isInitialized = false;
      _retryCount = 0;
      _isWebmCodecError = false;
    });
    _initializePlayer();
  }

  /// 使用外部播放器打开视频
  Future<void> _openWithExternalPlayer() async {
    try {
      LogUtils.d('尝试使用外部播放器打开视频: ${widget.videoUrl}', 'VideoPlayerWidget');

      final uri = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        LogUtils.d('已启动外部播放器', 'VideoPlayerWidget');
      } else {
        LogUtils.w('无法启动外部播放器', 'VideoPlayerWidget');
        // 可以显示一个提示消息
      }
    } catch (e) {
      LogUtils.e('启动外部播放器失败: $e', tag: 'VideoPlayerWidget', error: e);
    }
  }
}
