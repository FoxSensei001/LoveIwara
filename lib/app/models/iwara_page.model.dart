class IwaraPageModel {
  final String id;
  final String slug;
  final bool hideTitle;
  final bool sensitive;
  final String title;
  final String titleJa;
  final String titleZh;
  final String body;
  final String bodyJa;
  final String bodyZh;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IwaraPageModel({
    required this.id,
    required this.slug,
    required this.hideTitle,
    required this.sensitive,
    required this.title,
    required this.titleJa,
    required this.titleZh,
    required this.body,
    required this.bodyJa,
    required this.bodyZh,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IwaraPageModel.fromJson(Map<String, dynamic> json) {
    return IwaraPageModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      hideTitle: json['hideTitle'] == true,
      sensitive: json['sensitive'] == true,
      title: json['title']?.toString() ?? '',
      titleJa: json['title_ja']?.toString() ?? '',
      titleZh: json['title_zh']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      bodyJa: json['body_ja']?.toString() ?? '',
      bodyZh: json['body_zh']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String localizedTitle(String languageCode) {
    if (languageCode.startsWith('zh')) {
      return titleZh.isNotEmpty ? titleZh : title;
    }
    if (languageCode.startsWith('ja')) {
      return titleJa.isNotEmpty ? titleJa : title;
    }
    return title;
  }

  String localizedBody(String languageCode) {
    if (languageCode.startsWith('zh')) {
      return bodyZh.isNotEmpty ? bodyZh : body;
    }
    if (languageCode.startsWith('ja')) {
      return bodyJa.isNotEmpty ? bodyJa : body;
    }
    return body;
  }
}

