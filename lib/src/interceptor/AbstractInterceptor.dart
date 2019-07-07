import 'dart:async';
import 'dart:io';

abstract class AbstractInterceptor {
  Future<bool> preHandle(HttpRequest req, HttpResponse res);

  void postHandle(HttpRequest req, HttpResponse res);
}
