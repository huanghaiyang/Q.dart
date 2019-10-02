import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationMapperAware.dart';
import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/configure/CustomYamlPaser.dart';
import 'package:Q/src/exception/ApplicationConfigurationResourceNotFoundException.dart';
import 'package:Q/src/configure/CustomYamlPaserHelper.dart';

final String _DEFAULT_CONFIGURATION_FILE_NAME = 'configure.yml';

class ApplicationConfigurationMapper
    implements ApplicationConfigurationMapperAware<List<CustomYamlNode>, Map<String, dynamic>, ApplicationConfiguration> {
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

  List<CustomYamlNode> nodes_ = List();

  bool _isParsed = false;

  Map<String, dynamic> values_ = Map();

  @override
  Future<ApplicationConfiguration> init() async {
    File file = File('${Directory.current.path}/lib/resources/${_DEFAULT_CONFIGURATION_FILE_NAME}');
    if (await file.exists()) {
      CustomYamlPaser yamlPaser = CustomYamlPaser(await file.readAsString());
      nodes_ = await yamlPaser.parse();
      nodes_.forEach((node) {
        values_[node.name] = CustomYamlPaserHelper.reflectNodeValue(node);
      });
      _isParsed = true;
      return ApplicationConfiguration(values_, 0);
    } else {
      throw ApplicationConfigurationResourceNotFoundException(filename: _DEFAULT_CONFIGURATION_FILE_NAME);
    }
  }

  @override
  List<CustomYamlNode> get nodes {
    return List.unmodifiable(nodes_);
  }

  @override
  Map<String, dynamic> get values {
    return Map.unmodifiable(values_);
  }

  @override
  bool get isParsed {
    return _isParsed;
  }

  @override
  dynamic get(String key) {
    return this.values_[key];
  }
}
