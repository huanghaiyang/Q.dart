import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationLoaderAware.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';
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
      ApplicationConfiguration configuration = ApplicationConfiguration(Map());
    }
    return configurations;
  }
}
