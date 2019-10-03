import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

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
    return List.unmodifiable(this.unSupportedContentTypes_);
  }

  @override
  List<HttpMethod> get unSupportedMethods {
    return List.unmodifiable(this.unSupportedMethods_);
  }

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    unSupportedContentTypes_.addAll(List.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_SUPPORTED_CONTENT_TYPES)).map((value) {
      return ContentType.parse(value.toString());
    }));
    unSupportedMethods_.addAll(List.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_SUPPORTED_METHODS)).map((value) {
      return HttpMethodHelper.fromMethod(value.toString().toUpperCase());
    }));
  }
}
