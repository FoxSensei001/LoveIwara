import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'base_media_repository.dart';

class PopularGalleryRepository extends BaseMediaRepository<ImageModel> {
  final GalleryService galleryService;

  PopularGalleryRepository({
    required this.galleryService,
    required super.sortId,
  });

  @override
  Future<ApiResult<PageData<ImageModel>>> fetchData(
      Map<String, dynamic> params, int page, int limit) {
    return galleryService.fetchImageModelsByParams(
      params: params,
      page: page,
      limit: limit,
    );
  }
} 