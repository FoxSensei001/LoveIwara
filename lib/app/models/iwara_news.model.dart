enum IwaraNewsCategoryType { newsUpdates, articles, broadcast }

enum IwaraNewsLanguage { en, ja, zh }

class IwaraNewsCategory {
  const IwaraNewsCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.type,
    required this.language,
  });

  final int id;
  final String slug;
  final String name;
  final IwaraNewsCategoryType type;
  final IwaraNewsLanguage language;
}

class IwaraNewsListItem {
  const IwaraNewsListItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.link,
    required this.publishedAt,
    required this.updatedAt,
    required this.language,
    required this.categoryType,
    this.featuredImageUrl,
  });

  final int id;
  final String title;
  final String excerpt;
  final String link;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final IwaraNewsLanguage language;
  final IwaraNewsCategoryType categoryType;
  final String? featuredImageUrl;
}

class IwaraNewsDetail {
  const IwaraNewsDetail({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.contentMarkdown,
    required this.link,
    required this.publishedAt,
    required this.updatedAt,
    required this.language,
    required this.translationLinks,
    this.featuredImageUrl,
  });

  final int id;
  final String title;
  final String excerpt;
  final String contentMarkdown;
  final String link;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final IwaraNewsLanguage language;
  final Map<IwaraNewsLanguage, String> translationLinks;
  final String? featuredImageUrl;

  bool hasTranslation(IwaraNewsLanguage language) =>
      translationLinks[language]?.isNotEmpty == true;
}

