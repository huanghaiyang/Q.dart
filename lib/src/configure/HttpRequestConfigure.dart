import 'dart:io';

import 'package:Q/src/Method.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';

abstract class HttpRequestConfigure extends AbstractConfigure {
  factory HttpRequestConfigure() => _HttpRequestConfigure();

  // 当前不支持的请求类型
  List<ContentType> get unSupportedContentTypes;

  // 当前支持的请求类型
  List<HttpMethod> get unSupportedMethods;
}

class _HttpRequestConfigure implements HttpRequestConfigure {
  List<ContentType> unSupportedContentTypes_ = List();

  List<HttpMethod> unSupportedMethods_ = List();

  @override
  List<ContentType> get unSupportedContentTypes {
    return this.unSupportedContentTypes_;
  }

  @override
  List<HttpMethod> get unSupportedMethods {
    return this.unSupportedMethods_;
  }

  @override
  Future<dynamic> init() async {}
}
