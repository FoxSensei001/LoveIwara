
import 'package:i_iwara/common/constants.dart';

class MediaFile {
  final String id;
  final String type; // image, video
  final String path;
  final String name;
  final String mime;
  final int? size;
  final int? width;
  final int? height;
  final int? duration;
  final int? numThumbnails;
  final bool animatedPreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaFile({
    required this.id,
    required this.type,
    required this.path,
    required this.name,
    required this.mime,
    this.size,
    this.width,
    this.height,
    this.duration,
    this.numThumbnails,
    required this.animatedPreview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'],
      type: json['type'],
      path: json['path'],
      name: json['name'],
      mime: json['mime'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      duration: json['duration'],
      numThumbnails: json['numThumbnails'],
      animatedPreview: json['animatedPreview'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'path': path,
      'name': name,
      'mime': mime,
      'size': size,
      'width': width,
      'height': height,
      'duration': duration,
      'numThumbnails': numThumbnails,
      'animatedPreview': animatedPreview,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 这一条是不是视频。
  ///
  /// 判据按可靠性排序：服务端明说的 [type]（`image` / `video`）与 [mime] 是权威的，
  /// 文件名后缀只是两者都缺席时的兜底。图库里混着的视频文件，服务端这两个字段
  /// 都会说清楚 —— 此前全链路只按 URL 后缀猜（`ImageItem._detectMediaType` 与
  /// `MyGalleryPhotoViewWrapper._isVideo` 各抄了一份），明明手里有权威字段却不用。
  bool get isVideo {
    if (type.toLowerCase() == 'video') return true;
    if (mime.toLowerCase().startsWith('video/')) return true;
    return kGalleryVideoFileExtensions.contains(_extension);
  }

  /// 服务端会不会为这一条生成「大图」那一档。
  ///
  /// ⛔ `/image/large/` 是**图片缩放**端点，只对能被服务端重新编码的静态图存在。
  /// gif 早就特判过了（动图没有 large 版）；视频是同一类东西，而此前没人拦——
  /// 于是图库里的 webm 在默认的「标清」档下被拿 `/image/large/…/x.webm` 去喂
  /// libmpv，回来的不是视频字节，报的正是 `Failed to recognize file format.`
  /// （不是缺编解码器，安卓上恒定复现）。
  ///
  /// 判据因此从「是不是 gif」抬成「服务端会不会给它生成缩放版」，这是唯一的收口点：
  /// 上层不需要再各自记得「视频要绕开 large」。
  bool get hasLargeVariant => !isVideo && mime.toLowerCase() != 'image/gif';

  String get _extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  String getLargeImageUrl() {
    if (!hasLargeVariant) return getOriginalImageUrl();
    return '${CommonConstants.iwaraImageBaseUrl}/image/large/$id/$name';
  }

  String getOriginalImageUrl() =>
      '${CommonConstants.iwaraImageBaseUrl}/image/original/$id/$name';
}

/// 图库里可能混进来的视频扩展名。
///
/// 只在服务端没给出 `type` / `mime` 时兜底用（例如本地下载回来、按文件路径重建
/// 的条目）。此前 `horizontial_image_list.dart` 与 `my_gallery_photo_view_wrapper.dart`
/// 各写了一份一模一样的字面量，改一处漏一处，现在收口在这里。
const Set<String> kGalleryVideoFileExtensions = {
  'mp4',
  'webm',
  'mov',
  'avi',
  'mkv',
  'flv',
  'wmv',
  'm4v',
};
