import 'dart:io';

abstract class Configuration {
  List<ContentType> get unSupportedContentTypes;

  factory Configuration() => _Configuration();
}

class _Configuration implements Configuration {
  _Configuration();

  List<ContentType> unSupportedContentTypes_ = List();

  @override
  List<ContentType> get unSupportedContentTypes {
    return this.unSupportedContentTypes_;
  }
}
