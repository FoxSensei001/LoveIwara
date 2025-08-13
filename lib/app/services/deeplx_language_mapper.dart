/// DeepLX 语言代码映射工具类
/// 用于在应用内部语言代码和 DeepLX API 语言代码之间进行转换
class DeepLXLanguageMapper {
  /// 应用内部语言代码到 DeepLX 语言代码的映射
  static const Map<String, String> _appToDeepLXMap = {
    // 中文
    'zh-CN': 'ZH',
    'zh-TW': 'ZH-HANT',
    
    // 英语
    'en-US': 'EN-US',
    'en': 'EN-US',
    
    // 日语
    'ja': 'JA',
    
    // 韩语
    'ko': 'KO',
    
    // 越南语 (DeepLX 不支持，回退到英语)
    'vi': 'EN-US',
    
    // 泰语 (DeepLX 不支持，回退到英语)
    'th': 'EN-US',
    
    // 印尼语
    'id': 'ID',
    
    // 马来语 (DeepLX 不支持，回退到英语)
    'ms': 'EN-US',
    
    // 法语
    'fr': 'FR',
    
    // 德语
    'de': 'DE',
    
    // 西班牙语
    'es': 'ES',
    
    // 意大利语
    'it': 'IT',
    
    // 葡萄牙语
    'pt': 'PT-PT',
    
    // 俄语
    'ru': 'RU',
  };

  /// DeepLX 语言代码到应用内部语言代码的映射
  static const Map<String, String> _deepLXToAppMap = {
    'ZH': 'zh-CN',
    'ZH-HANS': 'zh-CN',
    'ZH-HANT': 'zh-TW',
    'EN-US': 'en-US',
    'EN-GB': 'en-US',
    'JA': 'ja',
    'KO': 'ko',
    'ID': 'id',
    'FR': 'fr',
    'DE': 'de',
    'ES': 'es',
    'IT': 'it',
    'PT-PT': 'pt',
    'PT-BR': 'pt',
    'RU': 'ru',
  };

  /// 将应用内部语言代码转换为 DeepLX 语言代码
  /// [appLanguageCode] 应用内部使用的语言代码（如 'zh-CN', 'en-US'）
  /// 返回 DeepLX API 支持的语言代码（如 'ZH', 'EN-US'）
  static String appToDeepLX(String appLanguageCode) {
    return _appToDeepLXMap[appLanguageCode] ?? 'EN-US';
  }

  /// 将 DeepLX 语言代码转换为应用内部语言代码
  /// [deepLXLanguageCode] DeepLX API 返回的语言代码（如 'ZH', 'EN-US'）
  /// 返回应用内部使用的语言代码（如 'zh-CN', 'en-US'）
  static String deepLXToApp(String deepLXLanguageCode) {
    return _deepLXToAppMap[deepLXLanguageCode] ?? 'en-US';
  }

  /// 检查 DeepLX 是否支持指定的应用内部语言代码
  /// [appLanguageCode] 应用内部使用的语言代码
  /// 返回 true 如果 DeepLX 原生支持该语言，false 如果需要回退到英语
  static bool isNativelySupported(String appLanguageCode) {
    final deepLXCode = _appToDeepLXMap[appLanguageCode];
    return deepLXCode != null && deepLXCode != 'EN-US' || appLanguageCode == 'en-US' || appLanguageCode == 'en';
  }

  /// 获取所有 DeepLX 支持的语言代码列表
  static List<String> getSupportedDeepLXLanguages() {
    return _deepLXToAppMap.keys.toList();
  }

  /// 获取所有应用内部支持的语言代码列表（映射到 DeepLX）
  static List<String> getSupportedAppLanguages() {
    return _appToDeepLXMap.keys.toList();
  }
}
