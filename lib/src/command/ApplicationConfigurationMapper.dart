import 'package:Q/src/utils/MapUtil.dart';

class ApplicationConfigurationMapper {
  ApplicationConfigurationMapper._();

  static ApplicationConfigurationMapper _instance;

  static ApplicationConfigurationMapper instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationMapper._();
    }
    return _instance;
  }

  final Map map = Map.unmodifiable({
    'application': {
      'environment': 's',
      'configuration': {
        'interceptor': {'timeout': '10ms'}
      }
    }
  });

  Map<String, dynamic> value() {
    Map<String, dynamic> result = Map();
    MapUtil.flatten(Map.from(map), result);
    return result;
  }

  static String DOT_STAND_IN_CHAR = '_';

  static String getKey(String key) {
    return key.replaceAll(RegExp("\\."), ApplicationConfigurationMapper.DOT_STAND_IN_CHAR);
  }
}
