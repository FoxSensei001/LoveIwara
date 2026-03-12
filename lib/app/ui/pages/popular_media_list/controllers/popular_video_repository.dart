import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/api_request_access.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'base_media_repository.dart';

class PopularVideoRepository extends BaseMediaRepository<Video> {
  final VideoService videoService;
  final IwaraSite site;

  PopularVideoRepository({
    required this.videoService,
    required this.site,
    required super.sortId,
  });

  @override
  Future<ApiResult<PageData<Video>>> fetchData(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) {
    return videoService.fetchVideosByParams(
      params: params,
      page: page,
      limit: limit,
      requestAccess: ApiRequestAccess.optionalAuthShortWait,
      site: site,
    );
  }
}
