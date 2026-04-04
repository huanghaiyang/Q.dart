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
    return _instance ?? (_instance = ApplicationConfigurationLoader._());
  }

  @override
  Future<List<ApplicationConfiguration>> load(List<ApplicationConfigurationResource> resources) async {
    if (resources == null || resources.isEmpty) {
      return [];
    }
    List<ApplicationConfiguration> configurations = List();
    await for (ApplicationConfigurationResource resource in Stream.fromIterable(resources)) {
      if (resource == null || resource.filepath == null) {
        continue;
      }
      try {
        File file = File(resource.filepath);
        if (!await file.exists()) {
          continue;
        }
        String content = await file.readAsString();
        YamlDocument document = loadYamlDocument(content);
        if (document != null && document.toString() != NULL_USELESS) {
          ApplicationConfiguration configuration = ApplicationConfiguration(convertDocument(document), resource.priority);
          configurations.add(configuration);
        }
      } catch (e) {
        // 记录异常但继续处理其他配置文件
        print('Error loading configuration file ${resource.filepath}: $e');
        continue;
      }
    }
    return configurations;
  }

  Map<String, dynamic> convertDocument(YamlDocument document) {
    Map<String, dynamic> result = Map();
    MapUtil.flatten(YamlUtil.convertDocumentToMap(document), result);
    return result;
  }
}
