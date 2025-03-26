import 'package:get/get.dart';
import 'base_media_repository.dart';

abstract class BaseMediaController<T> extends GetxController {
  final String sortId;
  late final BaseMediaRepository<T> repository;

  List<String> searchTagIds = [];
  String searchDate = '';
  String searchRating = '';

  BaseMediaController({required this.sortId}) {
    repository = createRepository();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    repository.dispose();
    super.onClose();
  }

  BaseMediaRepository<T> createRepository();

  void updateSearchParams({
    List<String> searchTagIds = const [],
    String searchDate = '',
    String searchRating = '',
  }) {
    this.searchTagIds = searchTagIds;
    this.searchDate = searchDate;
    this.searchRating = searchRating;
    repository.updateSearchParams(
      searchTagIds: this.searchTagIds,
      searchDate: this.searchDate,
      searchRating: this.searchRating,
    );
  }
} 