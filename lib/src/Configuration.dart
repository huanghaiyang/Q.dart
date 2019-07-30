import 'dart:io';

import 'package:Q/src/Method.dart';

// 应用程序配置
abstract class Configuration {
  // 当前不支持的请求类型
  List<ContentType> get unSupportedContentTypes;

  // 当前支持的请求类型
  List<HttpMethod> get unSupportedMethods;

  // 默认返回结果的类型
  ContentType get defaultProducedType;

  factory Configuration() => _Configuration();
}

class _Configuration implements Configuration {
  _Configuration();

  List<ContentType> unSupportedContentTypes_ = List();

  List<HttpMethod> unSupportedMethods_ = List();

  ContentType defaultProducedType_ = ContentType.json;

  @override
  List<ContentType> get unSupportedContentTypes {
    return this.unSupportedContentTypes_;
  }

  @override
  ContentType get defaultProducedType {
    return this.defaultProducedType_;
  }

  @override
  List<HttpMethod> get unSupportedMethods {
    return this.unSupportedMethods_;
  }
}
