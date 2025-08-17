import 'package:i_iwara/app/models/media_file.model.dart';

class PlaylistThumbnail {
  final MediaFile file;
  final int thumbnail;

  PlaylistThumbnail({
    required this.file,
    required this.thumbnail,
  });

  factory PlaylistThumbnail.fromJson(Map<String, dynamic> json) {
    return PlaylistThumbnail(
      file: MediaFile.fromJson(json['file']),
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file.toJson(),
      'thumbnail': thumbnail,
    };
  }

  // 获取缩略图URL
  String get thumbnailUrl {
    return 'https://i.iwara.tv/image/thumbnail/${file.id}/thumbnail-${_padNumber(thumbnail, 2)}.jpg';
  }

  String _padNumber(int number, int width) {
    return number.toString().padLeft(width, '0');
  }
}
