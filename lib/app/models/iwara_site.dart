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
