import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_repository.dart';
import 'base_media_controller.dart';
import 'popular_video_repository.dart';


class PopularVideoController extends BaseMediaController<Video> {
  final VideoService _videoService = Get.find<VideoService>();

  PopularVideoController({required super.sortId});

  @override
  BaseMediaRepository<Video> createRepository() {
    return PopularVideoRepository(
      videoService: _videoService,
      sortId: sortId,
    );
  }
}
