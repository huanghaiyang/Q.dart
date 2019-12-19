import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/helpers/ResponseHelper.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class HttpPrefetchInterceptor implements AbstractInterceptor {
  HttpPrefetchInterceptor._();

  static HttpPrefetchInterceptor _instance;

  static HttpPrefetchInterceptor instance() {
    if (_instance == null) {
      _instance = HttpPrefetchInterceptor._();
    }
    return _instance;
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    if (req.method.toUpperCase() == 'OPTIONS' &&
        Application.getApplicationContext().configuration.httpRequestConfigure.prefetchStrategy == PrefetchStrategy.ALLOW) {
      ResponseHelper.addCorsHeaders(res);
      res.write('');
      return false;
    }
    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {}
}
