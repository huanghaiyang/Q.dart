import 'dart:io';

abstract class MultipartConfigure {
  factory MultipartConfigure() => _MultipartConfigure();

  bool get fixNameSuffixIfArray;

  set fixNameSuffixIfArray(bool fixNameSuffixIfArray);

  String get defaultUploadTempDirPath;

  set defaultUploadTempDirPath(String defaultUploadTempDitPath);
}

class _MultipartConfigure implements MultipartConfigure {
  _MultipartConfigure();

  bool _fixNameSuffixIfArray = true;

  String _defaultUploadTempDirPath = Directory.systemTemp.path;

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
}
