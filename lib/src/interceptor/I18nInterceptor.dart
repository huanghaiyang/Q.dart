import 'dart:io';

import 'package:Q/src/aware/StoreService.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class I18nInterceptor implements AbstractInterceptor {
  I18nInterceptor._();

  static I18nInterceptor _instance;

  static I18nInterceptor getInstance() {
    if (_instance == null) {
      _instance = I18nInterceptor._();
    }
    return _instance;
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, StoreService storeService) async {
    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, StoreService storeService) {}
}
