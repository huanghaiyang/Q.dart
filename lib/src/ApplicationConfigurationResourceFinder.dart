import 'dart:io';

import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationConfigurationResourceFinderAware.dart';
import 'package:Q/src/common/ResourceFileTypes.dart';
import 'package:Q/src/exception/ApplicationConfigurationResourceNotFoundException.dart';
import 'package:Q/src/helpers/ResourceHelper.dart';
import 'package:Q/src/utils/FileUtil.dart';

final String APPLICATION_CONFIGURATION_RESOURCE_PREFIX = 'application';

final String CONFIGURE_CONFIGURATION_RESOURCE = 'configure';

final ResourceFileTypes defaultConfigurationResourceFileType = ResourceFileTypes.YML;

abstract class ApplicationConfigurationResourceFinder
    implements ApplicationConfigurationResourceFinderAware<ResourceFileTypes, ApplicationEnvironment, Map<String, String>> {
  factory ApplicationConfigurationResourceFinder() => _ApplicationConfigurationResourceFinder();

  Map<String, String> get paths;
}

class _ApplicationConfigurationResourceFinder implements ApplicationConfigurationResourceFinder {
  Map<String, String> paths_ = Map();

  Map<String, String> allPaths_ = Map();

  @override
  Future<Map<String, String>> search(ResourceFileTypes type, ApplicationEnvironment environment) async {
    String typename = type == null ? ResourceFileTypesLink.get(defaultConfigurationResourceFileType) : ResourceFileTypesLink.get(type);
    Map<String, String> result = Map();
    String resourcePath = ResourceHelper.findResourceDirectory();
    Directory resourceDirectory = Directory(resourcePath);
    if (await resourceDirectory.exists()) {
      Pattern matcher = RegExp('^${APPLICATION_CONFIGURATION_RESOURCE_PREFIX}(((\\-?)[a-z]+)?)(\\.)${typename}');
      await for (FileSystemEntity file in resourceDirectory.list(followLinks: false)) {
        String filePath = file.path;
        String path = '${getFileName(filePath)}.${getPathExtension(filePath)}';
        if (path.contains(matcher)) {
          allPaths_[getFileName(filePath)] = filePath;
        }
      }
    }
    String defaultConfigurationFilename = APPLICATION_CONFIGURATION_RESOURCE_PREFIX;
    if (allPaths_[defaultConfigurationFilename] == null) {
      throw ApplicationConfigurationResourceNotFoundException(filename: APPLICATION_CONFIGURATION_RESOURCE_PREFIX);
    } else {
      result[defaultConfigurationFilename] = allPaths_[defaultConfigurationFilename];
    }
    String environmentFilename = '${APPLICATION_CONFIGURATION_RESOURCE_PREFIX}-${environment.value}';
    if (allPaths_[environmentFilename] == null) {
      throw ApplicationConfigurationResourceNotFoundException(filename: environmentFilename);
    } else {
      result[environmentFilename] = allPaths_[environmentFilename];
    }
    paths_.addAll(result);
    return paths;
  }

  @override
  Map<String, String> get paths {
    return Map.unmodifiable(paths_);
  }
}
