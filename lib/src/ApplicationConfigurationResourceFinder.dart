import 'dart:io';

import 'package:Q/src/common/ResourceFileTypes.dart';
import 'package:Q/src/helpers/ResourceHelper.dart';
import 'package:Q/src/utils/FileUtil.dart';

final String APPLICATION_CONFIGURATION_RESOURCE_PREFIX = 'application';

final ResourceFileTypes defaultConfigurationResourceFileType = ResourceFileTypes.YML;

abstract class ApplicationConfigurationResourceFinder {
  Future<Map<String, String>> search(ResourceFileTypes type);

  factory ApplicationConfigurationResourceFinder() => _ApplicationConfigurationResourceFinder();

  Map<String, String> get paths;
}

class _ApplicationConfigurationResourceFinder implements ApplicationConfigurationResourceFinder {
  Map<String, String> paths_;

  @override
  Future<Map<String, String>> search(ResourceFileTypes type) async {
    type = type == null ? defaultConfigurationResourceFileType : type;
    Map<String, String> paths = Map();
    String resourcePath = ResourceHelper.findResourceDirectory();
    Directory resourceDirectory = Directory(resourcePath);
    if (await resourceDirectory.exists()) {
      await for (FileSystemEntity file in resourceDirectory.list(followLinks: false)) {
        Pattern matcher = RegExp('^${APPLICATION_CONFIGURATION_RESOURCE_PREFIX}(((\\-?)[a-z]+)?)(\\.)${ResourceFileTypesLink.get(type)}');
        String filePath = file.path;
        String path = '${getFileName(filePath)}.${getPathExtension(filePath)}';
        if (path.contains(matcher)) {
          paths[path] = filePath;
        }
      }
    }
    paths_ = paths;
    return paths;
  }

  @override
  Map<String, String> get paths {
    return paths_;
  }
}
