import 'dart:io';

import 'package:Q/src/aware/ApplicationConfigurationMapperAware.dart';
import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/configure/CustomYamlPaser.dart';

final String _DEFAULT_CONFIGURATION_FILE_NAME = 'configure.yml';

class ApplicationConfigurationMapper implements ApplicationConfigurationMapperAware<List<CustomYamlNode>> {
  static String DOT_STAND_IN_CHAR = '_';

  static String getKey(String key) {
    return key.replaceAll(RegExp("\\."), ApplicationConfigurationMapper.DOT_STAND_IN_CHAR);
  }

  ApplicationConfigurationMapper._();

  static ApplicationConfigurationMapper _instance;

  static ApplicationConfigurationMapper instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationMapper._();
    }
    return _instance;
  }

  List<CustomYamlNode> nodes;

  @override
  void init() async {
    File file = File('${Directory.current.path}/lib/resources/${_DEFAULT_CONFIGURATION_FILE_NAME}');
    if (await file.exists()) {
      CustomYamlPaser yamlPaser = CustomYamlPaser(await file.readAsString());
      nodes = await yamlPaser.parse();
    }
  }

  @override
  List<CustomYamlNode> get defaults {
    return List.unmodifiable(nodes);
  }
}
