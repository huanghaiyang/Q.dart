import 'dart:io';

import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/exception/UnSupportedRequestMethodException.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';
import 'package:Q/src/helpers/UnSupportedMethodHelper.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:Q/src/views/UnSupportedMethodView.dart';

class UnSupportedMethodInterceptor implements AbstractInterceptor {
  UnSupportedMethodInterceptor._();

  static UnSupportedMethodInterceptor _instance;

  static UnSupportedMethodInterceptor getInstance() {
    if (_instance == null) {
      _instance = UnSupportedMethodInterceptor._();
    }
    return _instance;
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    bool passed = await UnSupportedMethodHelper.checkSupported(req);
    if (!passed) {
      res.write(UnSupportedMethodView().toRaw(req, res, extra: {'unSupported': req.method}));
      throw UnSupportedRequestMethodException(method: HttpMethodHelper.fromMethod(req.method));
    }
    return passed;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {}
}
