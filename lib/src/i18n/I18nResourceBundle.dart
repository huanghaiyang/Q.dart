import 'dart:io';
import 'dart:convert';

class I18nResourceBundle {
  static final Map<String, Map<String, String>> _resources = {};
  static final Map<String, String> _fallbackResources = {};
  static String _defaultLocale = 'en';

  static void init() {
    // 加载默认语言资源
    _loadResource(_defaultLocale);
  }

  static void _loadResource(String locale) {
    try {
      final fileName = 'messages_$locale.json';
      final relativePath = 'lib/resources/i18n/$fileName';
      
      // 尝试多个路径加载
      final paths = [
        relativePath,
        '${Directory.current.path}/$relativePath',
        '${Directory.current.parent.path}/$relativePath',
      ];
      
      File file;
      String foundPath;
      for (var path in paths) {
        file = File(path);
        if (file.existsSync()) {
          foundPath = path;
          break;
        }
      }
      
      if (foundPath != null) {
        String content = file.readAsStringSync();
        Map<String, dynamic> data = json.decode(content);
        _resources[locale] = data.cast<String, String>();
      } else {
        print('I18n resource file not found: $relativePath');
      }
    } catch (e) {
      print('Error loading i18n resource for $locale: $e');
      // 可以考虑抛出特定异常或记录到日志系统
    }
  }

  static String getString(String key, {String locale, Map<String, dynamic> params}) {
    String targetLocale = locale ?? _defaultLocale;
    
    // 如果目标语言资源未加载，尝试加载
    if (!_resources.containsKey(targetLocale)) {
      _loadResource(targetLocale);
    }
    
    // 尝试从目标语言获取
    if (_resources.containsKey(targetLocale) && _resources[targetLocale].containsKey(key)) {
      return _formatMessage(_resources[targetLocale][key], params);
    }
    
    // 尝试从默认语言获取
    if (_resources.containsKey(_defaultLocale) && _resources[_defaultLocale].containsKey(key)) {
      return _formatMessage(_resources[_defaultLocale][key], params);
    }
    
    // 返回key作为默认值
    return key;
  }

  static String _formatMessage(String message, Map<String, dynamic> params) {
    if (params == null || params.isEmpty) {
      return message;
    }
    
    String result = message;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    
    return result;
  }

  static void setDefaultLocale(String locale) {
    _defaultLocale = locale;
    if (!_resources.containsKey(locale)) {
      _loadResource(locale);
    }
  }

  static String getDefaultLocale() {
    return _defaultLocale;
  }

  static void addResource(String locale, Map<String, String> resource) {
    _resources[locale] = resource;
  }

  static bool hasResource(String locale) {
    return _resources.containsKey(locale);
  }
}
