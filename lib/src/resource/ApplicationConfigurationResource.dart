import 'dart:io';

import 'package:Q/src/Resource.dart';
import 'package:Q/src/utils/FileUtil.dart';

abstract class ApplicationConfigurationResource extends Resource {
  factory ApplicationConfigurationResource(String name, String filepath, {int priority}) =>
      _ApplicationConfigurationResource(name, filepath, priority_: priority);

  factory ApplicationConfigurationResource.fromPath(String filepath, {int priority}) =>
      _ApplicationConfigurationResource.fromPath(filepath, priority: priority);

  int get priority;
}

class _ApplicationConfigurationResource implements ApplicationConfigurationResource {
  final String name_;

  final String filepath_;

  File file_;

  final int priority_;

  final ResourceType type_ = ResourceType.CONFIGURATION;

  _ApplicationConfigurationResource(this.name_, this.filepath_, {this.file_, this.priority_}) {
    assert(this.name_ != null, 'file name should not be null.');
    assert(this.filepath_ != null, 'file path should not be null.');
    if (this.file_ == null) {
      this.file_ = File(this.filepath_);
      if (!this.file_.existsSync()) {
        throw Exception('file [${this.filepath_}] is not exist.');
      }
    }
  }

  factory _ApplicationConfigurationResource.fromPath(String filepath, {int priority}) {
    return _ApplicationConfigurationResource(getFileName(filepath), filepath, priority_: priority);
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
