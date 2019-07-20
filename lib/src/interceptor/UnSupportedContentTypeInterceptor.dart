import 'dart:io';

import 'package:Q/src/helpers/UnSupportedContentTypeHelper.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class UnSupportedContentTypeInterceptor implements AbstractInterceptor {
  UnSupportedContentTypeInterceptor._();

  static UnSupportedContentTypeInterceptor _instance;

  static UnSupportedContentTypeInterceptor getInstance() {
    if (_instance == null) {
      _instance = UnSupportedContentTypeInterceptor._();
    }
    return _instance;
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res) async {
    return UnSupportedContentTypeHelper.checkSupported(req);
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res) {}

  @override
  void rejectHandle(HttpRequest req, HttpResponse res) {}
}
