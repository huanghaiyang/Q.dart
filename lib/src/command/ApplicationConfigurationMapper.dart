class ApplicationConfigurationMapper {
  ApplicationConfigurationMapper._();

  static ApplicationConfigurationMapper _instance;

  static ApplicationConfigurationMapper instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationMapper._();
    }
    return _instance;
  }

  Map map = Map.unmodifiable({
    'application': {
      'environment': 's',
      'configuration': {
        'interceptor': {'timeout': '10ms'}
      }
    }
  });

  Map<String, dynamic> value() {
    Map<String, dynamic> result = Map();
    this._flatten(Map.from(map), result, null);
    return result;
  }

  Map<String, dynamic> _flatten(Map<String, dynamic> map, Map<String, dynamic> result, String parentKey) {
    for (MapEntry entry in map.entries) {
      String key = entry.key;
      dynamic value = entry.value;
      String path = parentKey != null ? '${parentKey}.${key}' : key;
      if (value is Map) {
        _flatten(value, result, path);
      } else {
        result[path] = value;
      }
    }
    return result;
  }

  static String DOT_STAND_IN_CHAR = '_';

  static String getKey(String key) {
    return key.replaceAll(RegExp("\\."), ApplicationConfigurationMapper.DOT_STAND_IN_CHAR);
  }
}
