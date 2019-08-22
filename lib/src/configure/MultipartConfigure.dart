import 'dart:io';

abstract class MultipartConfigure {
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
}
