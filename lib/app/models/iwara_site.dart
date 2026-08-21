import 'package:i_iwara/common/constants.dart';

/// Iwara 内容来源站点。
enum IwaraSite {
  main,
  ai,
}

extension IwaraSiteX on IwaraSite {
  String get host {
    switch (this) {
      case IwaraSite.main:
        return CommonConstants.iwaraSiteHost;
      case IwaraSite.ai:
        return CommonConstants.iwaraAiSiteHost;
    }
  }

  String get baseUrl {
    switch (this) {
      case IwaraSite.main:
        return CommonConstants.iwaraBaseUrl;
      case IwaraSite.ai:
        return CommonConstants.iwaraAiBaseUrl;
    }
  }

  String get shortLabel {
    switch (this) {
      case IwaraSite.main:
        return '主站';
      case IwaraSite.ai:
        return 'AI';
    }
  }

  bool get isAi => this == IwaraSite.ai;

  /// 服务端用于标识站点的 id：跨站请求被拒时，响应体形如
  /// `{"message": "errors.differentSite", "siteId": "iwara_ai"}`。
  String get siteId {
    switch (this) {
      case IwaraSite.main:
        return 'iwara';
      case IwaraSite.ai:
        return 'iwara_ai';
    }
  }

  Map<String, String> get requestHeaders => {
    'x-site': host,
    'Referer': baseUrl,
    'Origin': baseUrl,
  };
}

class IwaraSiteUtils {
  const IwaraSiteUtils._();

  static IwaraSite fromHost(String? host) {
    final normalized = (host ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return IwaraSite.main;
    }

    if (normalized == CommonConstants.iwaraAiDomain ||
        normalized.endsWith('.${CommonConstants.iwaraAiDomain}')) {
      return IwaraSite.ai;
    }

    return IwaraSite.main;
  }

  static IwaraSite fromUrl(String url) {
    try {
      return fromHost(Uri.parse(url).host);
    } catch (_) {
      return IwaraSite.main;
    }
  }

  static IwaraSite fromExtra(dynamic extraSite) {
    if (extraSite is IwaraSite) {
      return extraSite;
    }
    if (extraSite is String) {
      return extraSite == IwaraSite.ai.name ? IwaraSite.ai : IwaraSite.main;
    }
    return IwaraSite.main;
  }

  /// 解析服务端返回的 `siteId`。无法识别时返回 null（调用方应视为"无法定位站点"，
  /// 不要默认成主站，否则会在主站上反复重试同一个跨站资源）。
  static IwaraSite? fromSiteId(String? siteId) {
    final normalized = (siteId ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final site in IwaraSite.values) {
      if (site.siteId == normalized) {
        return site;
      }
    }

    // 兼容服务端可能改用 host 形式（www.iwara.ai / iwara.tv）返回。
    if (normalized.contains('.')) {
      return fromHost(normalized);
    }

    return null;
  }

  static bool isIwaraHost(String? host) {
    final normalized = (host ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    return normalized == CommonConstants.iwaraDomain ||
        normalized.endsWith('.${CommonConstants.iwaraDomain}') ||
        normalized == CommonConstants.iwaraAiDomain ||
        normalized.endsWith('.${CommonConstants.iwaraAiDomain}');
  }
}
