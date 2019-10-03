import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/common/SizeUnit.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';

abstract class MultipartConfigure extends AbstractConfigure {
  factory MultipartConfigure() => _MultipartConfigure();

  bool get fixNameSuffixIfArray;

  set fixNameSuffixIfArray(bool fixNameSuffixIfArray);

  String get defaultUploadTempDirPath;

  set defaultUploadTempDirPath(String defaultUploadTempDitPath);

  int get maxUploadSize;

  set maxUploadSize(int maxUploadSize);

  bool isExceeded(int size);
}

class _MultipartConfigure implements MultipartConfigure {
  _MultipartConfigure();

  bool _fixNameSuffixIfArray = true;

  String _defaultUploadTempDirPath = Directory.systemTemp.path;

  int _maxUploadSize = -1;

  @override
  bool get fixNameSuffixIfArray {
    return this._fixNameSuffixIfArray;
  }

  @override
  set fixNameSuffixIfArray(bool fixNameSuffixIfArray) {
    this._fixNameSuffixIfArray = fixNameSuffixIfArray;
  }

  @override
  set defaultUploadTempDirPath(String defaultUploadTempDitPath) {
    this._defaultUploadTempDirPath = defaultUploadTempDitPath;
  }

  @override
  String get defaultUploadTempDirPath {
    return this._defaultUploadTempDirPath;
  }

  @override
  set maxUploadSize(int maxUploadSize) {
    this._maxUploadSize = maxUploadSize;
  }

  @override
  int get maxUploadSize {
    return this._maxUploadSize;
  }

  @override
  bool isExceeded(int size) {
    if (this.maxUploadSize < 0) {
      return false;
    } else {
      return size > this.maxUploadSize;
    }
  }

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    _maxUploadSize = (applicationConfiguration.get(APPLICATION_MULTIPART_MAX_FILE_UPLOAD_SIZE) as SizeUnit).bytes;
    _defaultUploadTempDirPath = applicationConfiguration.get(APPLICATION_MULTIPART_DEFAULT_UPLOAD_TEMP_DIR_PATH);
    _fixNameSuffixIfArray = applicationConfiguration.get(APPLICATION_MULTIPART_FIX_NAME_SUFFIX_IF_ARRAY);
  }
}
