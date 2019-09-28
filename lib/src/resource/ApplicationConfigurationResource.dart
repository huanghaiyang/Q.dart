import 'dart:io';

import 'package:Q/src/Resource.dart';
import 'package:Q/src/utils/FileUtil.dart';

abstract class ApplicationConfigurationResource extends Resource {
  factory ApplicationConfigurationResource(String name, String filepath, {int priority, ResourceType type}) =>
      _ApplicationConfigurationResource(name, filepath, priority_: priority, type_: type);

  factory ApplicationConfigurationResource.fromPath(String filepath, {int priority, ResourceType type}) =>
      _ApplicationConfigurationResource.fromPath(filepath, priority: priority, type: type);

  int get priority;
}

class _ApplicationConfigurationResource implements ApplicationConfigurationResource {
  final String name_;

  final String filepath_;

  File file_;

  final int priority_;

  ResourceType type_;

  _ApplicationConfigurationResource(this.name_, this.filepath_, {this.file_, this.priority_, this.type_}) {
    assert(this.name_ != null, 'file name should not be null.');
    assert(this.filepath_ != null, 'file path should not be null.');
    if (this.file_ == null) {
      this.file_ = File(this.filepath_);
      if (!this.file_.existsSync()) {
        throw Exception('file [${this.filepath_}] is not exist.');
      }
    }
    if (this.type_ == null) {
      this.type_ = ResourceType.CONFIGURATION;
    }
  }

  factory _ApplicationConfigurationResource.fromPath(String filepath, {int priority, ResourceType type}) {
    return _ApplicationConfigurationResource(getFileName(filepath), filepath, priority_: priority, type_: type);
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

  @override
  int get priority {
    return priority_;
  }
}
