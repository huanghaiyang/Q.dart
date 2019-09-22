import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationLoaderAware.dart';
import 'package:Q/src/common/CustomTypes.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';
import 'package:Q/src/utils/MapUtil.dart';
import 'package:Q/src/utils/YamlUtil.dart';
import 'package:yaml/yaml.dart';

class ApplicationConfigurationLoader
    extends ApplicationConfigurationLoaderAware<List<ApplicationConfigurationResource>, List<ApplicationConfiguration>> {
  ApplicationConfigurationLoader._();

  static ApplicationConfigurationLoader _instance;

  static ApplicationConfigurationLoader instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationLoader._();
    }
    return _instance;
  }

  @override
  Future<List<ApplicationConfiguration>> load(List<ApplicationConfigurationResource> resources) async {
    List<ApplicationConfiguration> configurations = List();
    await for (ApplicationConfigurationResource resource in Stream.fromIterable(resources)) {
      File file = File(resource.filepath);
      YamlDocument document = loadYamlDocument(await file.readAsString());
      if (document.toString() != NULL_USELESS) {
        ApplicationConfiguration configuration = ApplicationConfiguration(convertDocument(document), resource.priority);
        configurations.add(configuration);
      }
      continue;
    }
    return configurations;
  }

  Map<String, dynamic> convertDocument(YamlDocument document) {
    Map<String, dynamic> result = Map();
    MapUtil.flatten(YamlUtil.convertDocumentToMap(document), result);
    return result;
  }
}
