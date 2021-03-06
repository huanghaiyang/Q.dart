import 'dart:io';

import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class I18nInterceptor implements AbstractInterceptor {
  I18nInterceptor._();

  static I18nInterceptor _instance;

  static I18nInterceptor instance() {
    if (_instance == null) {
      _instance = I18nInterceptor._();
    }
    return _instance;
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {}
}
