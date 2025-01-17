import 'package:get/get.dart';

class RulesModel {
  final String id;
  final int weight; // 权重 越小越靠前
  final Map<String, String> title; // 标题 多语言
  final Map<String, String> body; // 内容 使用markdown语法 {@link CustomMarkdownBody disableLinkClick: true}
  final String createdAt; // 创建时间
  final String updatedAt; // 更新时间

  RulesModel({
    required this.id,
    required this.weight,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RulesModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> titleMap = json['title'] as Map<String, dynamic>;
    final Map<String, String> title = titleMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final Map<String, dynamic> bodyMap = json['body'] as Map<String, dynamic>;
    final Map<String, String> body = bodyMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return RulesModel(
      id: json['id'],
      weight: json['weight'],
      title: title,
      body: body,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  String getLocalizedTitle() {
    final languageCode = Get.deviceLocale?.languageCode ?? 'en';
    // 如果当前语言存在对应的内容，则返回当前语言的内容
    if (title.containsKey(languageCode)) {
      return title[languageCode]!;
    }
    // 如果是中文但只有 zh，则返回 zh
    if (languageCode.startsWith('zh') && title.containsKey('zh')) {
      return title['zh']!;
    }
    // 如果都没有，返回英文内容，如果英文也没有，返回第一个可用的内容
    return title['en'] ?? title.values.first;
  }

  String getLocalizedBody() {
    final languageCode = Get.deviceLocale?.languageCode ?? 'en';
    // 如果当前语言存在对应的内容，则返回当前语言的内容
    if (body.containsKey(languageCode)) {
      return body[languageCode]!;
    }
    // 如果是中文但只有 zh，则返回 zh
    if (languageCode.startsWith('zh') && body.containsKey('zh')) {
      return body['zh']!;
    }
    // 如果都没有，返回英文内容，如果英文也没有，返回第一个可用的内容
    return body['en'] ?? body.values.first;
  }
}
