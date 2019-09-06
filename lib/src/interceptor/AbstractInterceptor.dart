import 'dart:async';
import 'dart:io';

import 'package:Q/src/aware/StoreService.dart';

abstract class AbstractInterceptor {
  // 如果返回false，需要手动在方法中处理response，否则客户端会无响应
  Future<bool> preHandle(HttpRequest req, HttpResponse res, StoreService storeService);

  void postHandle(HttpRequest req, HttpResponse res, StoreService storeService);
}
