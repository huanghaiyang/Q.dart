import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/MimeTypes.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

class Router {
  Application app;
  String path;
  RegExp pathRegex;
  bool hasMatch;

  // 处理函数
  Function handle;
  Map params;
  String method;

  // 默认返回的格式为json
  MimeTypes mimeType = MimeTypes.JSON;

  Router(
    this.path,
    this.method,
    Function handler, {
    Map params,
    MimeTypes mimeType,
  }) {
    this.params = params;
    this.mimeType = mimeType;
  }

  // 请求路径匹配
  Future<bool> match(HttpRequest request) async {
    this.path = request.uri.path;
    this.pathRegex = pathToRegExp(this.path);
    this.hasMatch = this.pathRegex.hasMatch(this.path);
    return this.hasMatch;
  }
}
