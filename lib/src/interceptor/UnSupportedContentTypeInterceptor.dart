import 'dart:io';

import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/exception/UnSupportedRequestContentTypeException.dart';
import 'package:Q/src/helpers/UnSupportedContentTypeHelper.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:Q/src/views/UnSupportedContentTypeView.dart';

class UnSupportedContentTypeInterceptor implements AbstractInterceptor {
  UnSupportedContentTypeInterceptor._();

  static UnSupportedContentTypeInterceptor _instance;

  static UnSupportedContentTypeInterceptor instance() {
    if (_instance == null) {
      _instance = UnSupportedContentTypeInterceptor._();
    }
    return _instance;
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    bool passed = await UnSupportedContentTypeHelper.checkSupported(req);
    if (!passed) {
      res.write(UnSupportedContentTypeView().toRaw(req, res, extra: {'unSupported': req.headers.contentType.mimeType}));
      throw UnSupportedRequestContentTypeException(contentType: req.headers.contentType);
    }
    return passed;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {}
}
