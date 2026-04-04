import 'dart:io';

import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationConfigurationResourceFinderAware.dart';
import 'package:Q/src/common/ResourceFileTypeHelper.dart';
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
    try {
      String typename = 
          type == null ? ResourceFileTypeHelper.toExtension(defaultConfigurationResourceFileType) : ResourceFileTypeHelper.toExtension(type);
      Map<String, String> result = Map();
      try {
        String resourcePath = await ResourceHelper.findResourceDirectory();
        if (resourcePath == null) {
          throw ApplicationConfigurationResourceNotFoundException(filename: 'resource directory');
        }
        Directory resourceDirectory = Directory(resourcePath);
        if (await resourceDirectory.exists()) {
          Pattern matcher = RegExp('^${APPLICATION_CONFIGURATION_RESOURCE_PREFIX}(((\\-?)[a-z]+)?)(\\.)${typename}');
          await for (FileSystemEntity file in resourceDirectory.list(followLinks: false)) {
            if (file is File) {
              String filePath = file.path;
              String fileName = getFileName(filePath);
              String fileExtension = getPathExtension(filePath);
              if (fileName != null && fileExtension != null) {
                String path = '$fileName.$fileExtension';
                if (path.contains(matcher)) {
                  allPaths_[fileName] = filePath;
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error searching for configuration files: $e');
      }
      String defaultConfigurationFilename = APPLICATION_CONFIGURATION_RESOURCE_PREFIX;
      if (allPaths_[defaultConfigurationFilename] == null) {
        throw ApplicationConfigurationResourceNotFoundException(filename: APPLICATION_CONFIGURATION_RESOURCE_PREFIX);
      } else {
        result[defaultConfigurationFilename] = allPaths_[defaultConfigurationFilename];
      }
      if (environment != null && environment.value != null) {
        String environmentFilename = '${APPLICATION_CONFIGURATION_RESOURCE_PREFIX}-${environment.value}';
        if (allPaths_[environmentFilename] == null) {
          print('Warning: Environment configuration file not found: $environmentFilename');
          // 不再抛出异常，允许只使用默认配置文件
        } else {
          result[environmentFilename] = allPaths_[environmentFilename];
        }
      }
      paths_.addAll(result);
      return paths;
    } catch (e) {
      print('Error in configuration resource search: $e');
      rethrow;
    }
  }

  @override
  Map<String, String> get paths {
    return Map.unmodifiable(paths_);
  }
}
