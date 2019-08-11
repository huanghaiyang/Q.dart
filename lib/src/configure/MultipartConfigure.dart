abstract class MultipartConfigure {
  factory MultipartConfigure() => _MultipartConfigure();

  bool get fixNameSuffixIfArray;

  set fixNameSuffixIfArray(bool fixNameSuffixIfArray);
}

class _MultipartConfigure implements MultipartConfigure {
  _MultipartConfigure();

  bool _fixNameSuffixIfArray = true;

  @override
  bool get fixNameSuffixIfArray {
    return this._fixNameSuffixIfArray;
  }

  @override
  set fixNameSuffixIfArray(bool fixNameSuffixIfArray) {
    this._fixNameSuffixIfArray = fixNameSuffixIfArray;
  }
}
