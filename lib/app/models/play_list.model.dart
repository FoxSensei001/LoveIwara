import 'package:i_iwara/app/models/play_list_thumbnail.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/common/constants.dart';

class PlaylistModel {
  String id;
  String title;
  PlaylistThumbnail? thumbnail;
  int numVideos;
  User? user;

  PlaylistModel({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.numVideos,
    this.user,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'],
      title: json['title'],
      thumbnail: json['thumbnail'] != null 
          ? PlaylistThumbnail.fromJson(json['thumbnail']) 
          : null,
      numVideos: json['numVideos'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail?.toJson(),
      'numVideos': numVideos,
      'user': user?.toJson(),
    };
  }

  // 获取缩略图URL
  String get thumbnailUrl {
    if (thumbnail != null) {
      return thumbnail!.thumbnailUrl;
    }
    return CommonConstants.defaultPlaylistThumbnailUrl;
  }
}
