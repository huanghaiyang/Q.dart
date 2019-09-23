import 'dart:io';

import 'package:Q/src/utils/MapUtil.dart';

final Map _map = Map.unmodifiable({
  'application': {
    'name': '',
    'author': '',
    'createTime': '',
    'environment': 'prod',
    'configuration': {
      'interceptor': {'timeout': '10ms'},
      'router': {'defaultMapping': '/'},
      'request': {
        'unSupportedContentTypes': [],
        'unSupportedMethods': [],
        'multipart': {'maxFileUploadSize': '10m', 'fixNameSuffixIfArray': true, 'defaultUploadTempDirPath': Directory.systemTemp.path},
      },
      'response': {
        'defaultProducedType': 'application/json',
      }
    }
  }
});

class ApplicationConfigurationMapper {
  ApplicationConfigurationMapper._();

  static ApplicationConfigurationMapper _instance;

  static ApplicationConfigurationMapper instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationMapper._();
    }
    return _instance;
  }

  Map<String, dynamic> value() {
    Map<String, dynamic> result = Map();
    MapUtil.flatten(Map.from(_map), result);
    return result;
  }

  static String DOT_STAND_IN_CHAR = '_';

  static String getKey(String key) {
    return key.replaceAll(RegExp("\\."), ApplicationConfigurationMapper.DOT_STAND_IN_CHAR);
  }
}
