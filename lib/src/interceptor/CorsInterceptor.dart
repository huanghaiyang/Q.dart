import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/helpers/ResponseHelper.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class CorsInterceptor implements AbstractInterceptor {
  CorsInterceptor._();

  static CorsInterceptor _instance;

  static CorsInterceptor instance() {
    return _instance ?? (_instance = CorsInterceptor._());
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    // 添加CORS头
    await ResponseHelper.addCorsHeaders(req, res);
    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {}
}
