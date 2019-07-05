import 'dart:io';

import 'package:Q/src/handler/HandlerAdapter.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

class Router {
  String path;
  RegExp pathRegex;
  bool hasMatch;

  // 请求处理句柄
  HandlerAdapter handlerAdapter;
  Map params;
  String method;

  Router(this.path, this.method, this.handlerAdapter, {Map params});

  // 请求路径匹配
  Future<bool> match(HttpRequest request) async {
    this.path = request.uri.path;
    this.pathRegex = pathToRegExp(this.path);
    this.hasMatch = this.pathRegex.hasMatch(this.path);
    return this.hasMatch;
  }

  static get(String path, HandlerAdapter handlerAdapter, {Map params}) {
    return Router(path, 'get', handlerAdapter, params: params);
  }

  static post(String path, HandlerAdapter handlerAdapter, Map params) {
    return Router(path, 'post', handlerAdapter, params: params);
  }

  static put(String path, HandlerAdapter handlerAdapter, Map params) {
    return Router(path, 'put', handlerAdapter, params: params);
  }

  static delete(String path, HandlerAdapter handlerAdapter, {Map params}) {
    return Router(path, 'delete', handlerAdapter, params: params);
  }
}
