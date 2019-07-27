import 'dart:io';

abstract class Configuration {
  List<ContentType> get unSupportedContentTypes;

  ContentType get defaultProducedType;

  factory Configuration() => _Configuration();
}

class _Configuration implements Configuration {
  _Configuration();

  List<ContentType> unSupportedContentTypes_ = List();

  ContentType defaultProducedType_ = ContentType.json;

  @override
  List<ContentType> get unSupportedContentTypes {
    return this.unSupportedContentTypes_;
  }

  @override
  ContentType get defaultProducedType {
    return this.defaultProducedType_;
  }
}
