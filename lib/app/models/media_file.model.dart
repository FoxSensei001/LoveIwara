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

  /// 「大图」那一档能不能当**播放/展示的本体**用。
  ///
  /// ⛔ `/image/large/` 是**图片缩放**端点。对视频它并不是 404 —— 服务端照样给你
  /// 一张东西，但那是**静态封面 JPEG**，不是视频字节（2026-09-15 实测：large 档回的
  /// 是 490×490 的 JPEG，只有 32.8KB）。此前没人拦，于是图库里的 webm 在默认的
  /// 「标清」档下被拿 `/image/large/…/x.webm` 去喂 libmpv，报的正是
  /// `Failed to recognize file format.`（不是缺编解码器，安卓上恒定复现）。
  ///
  /// 所以这个判据管的是「**本体**取哪一档」：视频与 gif 一律回落到原文件。
  /// ⛔ 别把它读成「服务端不给它生成缩放版」—— 那句话是错的，正因为服务端**给**，
  /// 封面才有得取，见 [getPosterUrl]。
  bool get hasLargeVariant => !isVideo && mime.toLowerCase() != 'image/gif';

  String get _extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// 这一条该从哪个域名取。
  ///
  /// ⛔ `i.iwara.tv` 对**路径以视频扩展名结尾**的请求一律回 Cloudflare 的
  /// 「Just a moment...」挑战页（HTTP 403 + 6KB HTML）。判据是**路径**不是内容：
  /// 同一个文件把路径里的 `.webm` 换成 `.jpg` 当场 200，回的还是 `video/webm` 的
  /// 13MB 字节。`files.iwara.tv` 是同一套存储、没有这条规则，`.webm` 直接 200。
  /// （2026-09-15 实测文件 `8922a1ae-…webm`：`i.` 403 / `files.` 200 13010771 字节，
  /// 且 `i.` 上同 id 的 `.jpg` 路径 200 —— 三条一起才能排除「是内容不给发」。）
  ///
  /// 这在 2D 侧不一定致命：Dart 那条 HTTP 带着完整的浏览器头、cookie 与应用内代理，
  /// 挑战多半能过。但 Quest 空间画廊里的视频项是**原生 ExoPlayer 直接取流**的，
  /// 手里只有一个 UA —— 挑战页当场变成 `ERROR_CODE_IO_BAD_HTTP_STATUS`，
  /// 表现为「这个片源放不出来」（用户 2026-09-15 真机报障）。
  ///
  /// 收口在这里：上层不需要记得「视频要换个域名」，与 [hasLargeVariant] 同一个位置。
  String get baseUrl => isVideo
      ? CommonConstants.iwaraFileBaseUrl
      : CommonConstants.iwaraImageBaseUrl;

  String getLargeImageUrl() {
    if (!hasLargeVariant) return getOriginalImageUrl();
    return '$baseUrl/image/large/$id/$name';
  }

  String getOriginalImageUrl() => '$baseUrl/image/original/$id/$name';

  /// 这一条的**静图海报**：封面、缩略图、列表里那一格预览都该用它。
  ///
  /// ⭐ 服务端**确实**会给视频生成静图。全仓库好几处注释写着「视频没有现成的
  /// 缩略图地址，不值得为一格几十像素再起一份 libmpv 去解首帧」——那句话是错的，
  /// 2026-09-15 实测推翻：同一个 webm，
  /// `/image/large/…` 回 490×490 的 JPEG（32.8KB）、`/image/thumbnail/…` 回
  /// 220×160 的 JPEG（7.7KB），`file(1)` 认出来的都是 `JPEG image data`。
  ///
  /// ⛔ 后缀必须换成 `.jpg`，两个理由缺一不可：
  /// 1. `i.iwara.tv` 拦路径以视频后缀结尾的请求（见 [baseUrl]）——换掉就不拦了，
  ///    于是封面能留在与所有图片同一个域名、同一套缓存键上；
  /// 2. 按 `.webm` 要同一份字节时，服务端把 content-type 谎报成 `video/webm`
  ///    （字节逐位相同，md5 一致）。按 `.jpg` 要才诚实。
  ///
  /// ⛔ 它**不是可播放的片源**。要播放一律 [getOriginalImageUrl]，见 [hasLargeVariant]。
  String getPosterUrl() {
    if (!isVideo) return getLargeImageUrl();
    return '${CommonConstants.iwaraImageBaseUrl}/image/large/$id/$_posterName';
  }

  /// 把文件名的后缀换成 `.jpg`（[getPosterUrl] 用）。
  String get _posterName {
    final dotIndex = name.lastIndexOf('.');
    return dotIndex <= 0 ? '$name.jpg' : '${name.substring(0, dotIndex)}.jpg';
  }
}

/// 把一条**已经存下来**的 Iwara 图片地址改写成它的静图海报地址。
///
/// 给历史数据用：下载任务的 `previewUrls` / `imageList` 里存的是**当初**算出来的
/// 地址，视频那几条指向原文件（一个 13MB 的 webm），拿去当封面画不出来；而那些
/// 数据库行不会因为代码改了就自己重写。渲染时过一道这个函数即可。
///
/// 不是视频、或不像 Iwara 的图片端点，一律原样返回（本地 `file://` 路径也是原样）。
/// 新写进去的地址请直接用 [MediaFile.getPosterUrl]，别依赖这道改写。
String iwaraPosterUrlFrom(String url) {
  if (!isGalleryVideoFileName(url)) return url;
  const marker = '/image/';
  final markerIndex = url.indexOf(marker);
  if (markerIndex < 0) return url;
  // `<档位>/<id>/<文件名>`：档位是 original / large / thumbnail 之一，这里一律换成 large。
  final segments = url.substring(markerIndex + marker.length).split('/');
  if (segments.length < 3) return url;
  final fileId = segments[1];
  final fileName = segments.sublist(2).join('/');
  if (fileId.isEmpty || fileName.isEmpty) return url;
  final dotIndex = fileName.lastIndexOf('.');
  final base = dotIndex <= 0 ? fileName : fileName.substring(0, dotIndex);
  return '${CommonConstants.iwaraImageBaseUrl}/image/large/$fileId/$base.jpg';
}

/// 按文件名（或路径）后缀判断是不是视频。
///
/// ⛔ 只在拿不到服务端 `type` / `mime` 时用 —— 有那两个字段就走 [MediaFile.isVideo]。
/// 本地文件（下载回来的、本机媒体目录扫出来的）手里只有一个路径，这是唯一判据。
///
/// ⛔ 这里**纯字符串取后缀**，不走 `Uri.parse`（`CommonUtils.getFileExtension` 那条是给
/// 带 query 的网址用的）：文件名里真实存在的 `#` 会被 URI 当成 fragment 分隔符，
/// `a#b.webm` 解出来的后缀是空的。带 `#` 的真实文件在本项目里出现过，见
/// `openLocalImageViewer` 里那条「必须裸拼 file://」的注释。
bool isGalleryVideoFileName(String nameOrPath) {
  final dotIndex = nameOrPath.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == nameOrPath.length - 1) return false;
  return kGalleryVideoFileExtensions.contains(
    nameOrPath.substring(dotIndex + 1).toLowerCase(),
  );
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
