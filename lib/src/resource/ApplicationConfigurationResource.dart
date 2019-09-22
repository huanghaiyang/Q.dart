import 'dart:io';

import 'package:Q/src/Resource.dart';
import 'package:Q/src/utils/FileUtil.dart';

abstract class ApplicationConfigurationResource extends Resource {
  factory ApplicationConfigurationResource(String name, String filepath) => _ApplicationConfigurationResource(name, filepath);

  factory ApplicationConfigurationResource.fromPath(String filepath) => _ApplicationConfigurationResource.fromPath(filepath);

  factory ApplicationConfigurationResource.fromFile(File file) => _ApplicationConfigurationResource.fromFile(file);
}

class _ApplicationConfigurationResource implements ApplicationConfigurationResource {
  final String name_;

  final String filepath_;

  File file_;

  final ResourceType type_ = ResourceType.CONFIGURATION;

  _ApplicationConfigurationResource(this.name_, this.filepath_, {this.file_}) {
    assert(this.name_ != null, 'file name should not be null.');
    assert(this.filepath_ != null, 'file path should not be null.');
    if (this.file_ == null) {
      this.file_ = File(this.filepath_);
      if (!this.file_.existsSync()) {
        throw Exception('file [${this.filepath_}] is not exist.');
      }
    }
  }

  factory _ApplicationConfigurationResource.fromPath(String filepath) {
    return _ApplicationConfigurationResource(getFileName(filepath), filepath);
  }

  factory _ApplicationConfigurationResource.fromFile(File file) {
    return _ApplicationConfigurationResource(getFileName(file.path), file.path, file_: file);
  }

  @override
  ResourceType get type {
    return type_;
  }

  @override
  String get filepath {
    return filepath_;
  }

  @override
  String get name {
    return name_;
  }
}
