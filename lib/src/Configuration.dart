import 'dart:io';

import 'package:Q/src/Method.dart';
import 'package:Q/src/configure/InterceptorConfigure.dart';
import 'package:Q/src/configure/MultipartConfigure.dart';
import 'package:Q/src/configure/RouterMappingConfigure.dart';

// 应用程序配置
abstract class Configuration {
  // 当前不支持的请求类型
  List<ContentType> get unSupportedContentTypes;

  // 当前支持的请求类型
  List<HttpMethod> get unSupportedMethods;

  // 默认返回结果的类型
  ContentType get defaultProducedType;

  MultipartConfigure get multipartConfigure;

  RouterMappingConfigure get routerMappingConfigure;

  InterceptorConfigure get interceptorConfigure;

  factory Configuration() => _Configuration();
}

class _Configuration implements Configuration {
  _Configuration();

  List<ContentType> unSupportedContentTypes_ = List();

  List<HttpMethod> unSupportedMethods_ = List();

  ContentType defaultProducedType_ = ContentType.json;

  MultipartConfigure _multipartConfigure = MultipartConfigure();

  RouterMappingConfigure _routerMappingConfigure = RouterMappingConfigure();

  InterceptorConfigure _interceptorConfigure = InterceptorConfigure();

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

  @override
  MultipartConfigure get multipartConfigure {
    return this._multipartConfigure;
  }

  @override
  RouterMappingConfigure get routerMappingConfigure {
    return this._routerMappingConfigure;
  }

  @override
  InterceptorConfigure get interceptorConfigure {
    return this._interceptorConfigure;
  }
}
