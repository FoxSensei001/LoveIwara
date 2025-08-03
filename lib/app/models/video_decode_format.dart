class VideoSyncOption {
  final String value;
  final String description;

  const VideoSyncOption(this.value, this.description);

  static const List<VideoSyncOption> options = [
    VideoSyncOption('audio', '音频同步'),
    VideoSyncOption('display-resample', '显示重采样'),
    VideoSyncOption('display-resample-vdrop', '显示重采样(丢帧)'),
    VideoSyncOption('display-resample-desync', '显示重采样(去同步)'),
    VideoSyncOption('display-tempo', '显示节拍'),
    VideoSyncOption('display-vdrop', '显示丢视频帧'),
    VideoSyncOption('display-adrop', '显示丢音频帧'),
    VideoSyncOption('display-desync', '显示去同步'),
    VideoSyncOption('desync', '去同步'),
  ];
}

class HardwareDecodingOption {
  final String value;
  final String description;

  const HardwareDecodingOption(this.value, this.description);

  static const List<HardwareDecodingOption> options = [
    HardwareDecodingOption('auto', '自动'),
    HardwareDecodingOption('auto-copy', '自动复制'),
    HardwareDecodingOption('auto-safe', '自动安全'),
    HardwareDecodingOption('no', '禁用'),
    HardwareDecodingOption('yes', '强制启用'),
  ];
}