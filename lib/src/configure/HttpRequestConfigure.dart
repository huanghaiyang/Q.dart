import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

List<HttpMethod> DEFAULT_ALLOWED_METHODS = [
  HttpMethod.GET,
  HttpMethod.POST,
  HttpMethod.PUT,
  HttpMethod.DELETE,
  HttpMethod.PATCH,
  HttpMethod.OPTIONS,
  HttpMethod.COPY,
  HttpMethod.HEAD,
  HttpMethod.LINK,
  HttpMethod.UNLINK,
  HttpMethod.PURGE,
  HttpMethod.LOCK,
  HttpMethod.UNLOCK,
  HttpMethod.PROPFIND,
  HttpMethod.VIEW
];

abstract class HttpRequestConfigure extends AbstractConfigure {
  factory HttpRequestConfigure() => _HttpRequestConfigure();

  List<ContentType> get allowedContentTypes;

  List<HttpMethod> get allowedMethods;

  List<String> get allowedOrigins;

  List<String> get allowedHeaders;

  List<String> get allowedCredentials;

  int get maxAge;

  PrefetchStrategy get prefetchStrategy;
}

class _HttpRequestConfigure implements HttpRequestConfigure {
  List<ContentType> allowedContentTypes_ = List();

  List<HttpMethod> allowedMethods_ = List();

  List<String> allowedOrigins_ = List();

  List<String> allowedHeaders_ = List();

  List<String> allowedCredentials_ = List();

  int maxAge_;

  PrefetchStrategy _prefetchStrategy;

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
    _prefetchStrategy = PrefetchStrategyHelper.transform(applicationConfiguration.get(APPLICATION_REQUEST_PREFETCH_STRATEGY));
  }

  @override
  PrefetchStrategy get prefetchStrategy => _prefetchStrategy;
}
