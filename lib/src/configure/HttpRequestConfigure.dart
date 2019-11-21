import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

abstract class HttpRequestConfigure extends AbstractConfigure {
  factory HttpRequestConfigure() => _HttpRequestConfigure();

  // 当前不支持的请求类型
  List<ContentType> get unAllowedContentTypes;

  // 当前支持的请求类型
  List<HttpMethod> get unAllowedMethods;

  List<String> get unAllowedOrigins;

  List<String> get unAllowedHeaders;

  List<String> get unAllowedCredentials;

  List<ContentType> get allowedContentTypes;

  List<HttpMethod> get allowedMethods;

  List<String> get allowedOrigins;

  List<String> get allowedHeaders;

  List<String> get allowedCredentials;

  int get maxAge;
}

class _HttpRequestConfigure implements HttpRequestConfigure {
  List<ContentType> unAllowedContentTypes_ = List();

  List<HttpMethod> unAllowedMethods_ = List();

  List<String> unAllowedOrigins_ = List();

  List<String> unAllowedHeaders_ = List();

  List<String> unAllowedCredentials_ = List();

  List<ContentType> allowedContentTypes_ = List();

  List<HttpMethod> allowedMethods_ = List();

  List<String> allowedOrigins_ = List();

  List<String> allowedHeaders_ = List();

  List<String> allowedCredentials_ = List();

  int maxAge_;

  @override
  List<ContentType> get unAllowedContentTypes {
    return List.unmodifiable(this.unAllowedContentTypes_);
  }

  @override
  List<HttpMethod> get unAllowedMethods {
    return List.unmodifiable(this.unAllowedMethods_);
  }

  @override
  List<String> get unAllowedOrigins {
    return unAllowedOrigins_;
  }

  @override
  List<String> get unAllowedHeaders {
    return unAllowedHeaders_;
  }

  @override
  List<String> get unAllowedCredentials {
    return unAllowedCredentials_;
  }

  @override
  List<ContentType> get allowedContentTypes {
    return allowedContentTypes_;
  }

  @override
  List<HttpMethod> get allowedMethods {
    return allowedMethods_;
  }

  @override
  List<String> get allowedOrigins {
    return allowedOrigins_;
  }

  @override
  List<String> get allowedHeaders {
    return allowedHeaders_;
  }

  @override
  List<String> get allowedCredentials {
    return allowedCredentials_;
  }

  @override
  int get maxAge {
    return maxAge_;
  }

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    unAllowedContentTypes_.addAll(List.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_ALLOWED_CONTENT_TYPES)).map((value) {
      return ContentType.parse(value.toString());
    }));
    unAllowedMethods_.addAll(List.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_ALLOWED_METHODS)).map((value) {
      return HttpMethodHelper.fromMethod(value.toString().toUpperCase());
    }));
    unAllowedHeaders_.addAll(List<String>.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_ALLOWED_HEADERS)));
    unAllowedOrigins_.addAll(List<String>.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_ALLOWED_ORIGINS)));
    unAllowedCredentials_.addAll(List<String>.from(applicationConfiguration.get(APPLICATION_REQUEST_UN_ALLOWED_CREDENTIALS)));

    allowedContentTypes_.addAll(List.from(applicationConfiguration.get(APPLICATION_REQUEST_ALLOWED_CONTENT_TYPES)).map((value) {
      return ContentType.parse(value.toString());
    }));
    allowedMethods_.addAll(List.from(applicationConfiguration.get(APPLICATION_REQUEST_ALLOWED_METHODS)).map((value) {
      return HttpMethodHelper.fromMethod(value.toString().toUpperCase());
    }));
    allowedHeaders_.addAll(List<String>.from(applicationConfiguration.get(APPLICATION_REQUEST_ALLOWED_HEADERS)));
    allowedOrigins_.addAll(List<String>.from(applicationConfiguration.get(APPLICATION_REQUEST_ALLOWED_ORIGINS)));
    allowedCredentials_.addAll(List<String>.from(applicationConfiguration.get(APPLICATION_REQUEST_ALLOWED_CREDENTIALS)));

    maxAge_ = applicationConfiguration.get(APPLICATION_REQUEST_MAX_AGE);
  }
}
