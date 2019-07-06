import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/MimeTypes.dart';
import 'package:Q/src/ResponseEntry.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
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

  // 默认json数据转换
  AbstractHttpMessageConverter converter;

  Router(this.path, this.method, Function handler,
      {this.params, this.mimeType, this.converter});

  // 请求路径匹配
  Future<bool> match(HttpRequest request) async {
    this.path = request.uri.path;
    this.pathRegex = pathToRegExp(this.path);
    this.hasMatch = this.pathRegex.hasMatch(this.path);
    return this.hasMatch;
  }

  Future convert(ResponseEntry entry) async {
    return this.converter.convert(entry.result);
  }
}
