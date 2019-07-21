import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/ResponseEntry.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

String GET = 'get';

String POST = 'post';

String PUT = 'put';

String DELETE = 'delete';

String OPTIONS = 'options';

typedef RouterHandleFunction = Future<dynamic> Function(Context, [HttpRequest, HttpResponse]);

class Router {
  Application app;
  String path;
  String requestPath;
  RegExp pathRegex;
  bool hasMatch;

  // 处理函数
  RouterHandleFunction handle;
  Map params;
  String method = 'GET';
  Map<String, List<String>> query;

  // 默认返回的格式为json
  ContentType contentType = ContentType.json;

  // 默认json数据转换
  AbstractHttpMessageConverter converter;

  // response handler
  HandlerAdapter handlerAdapter;

  Router(this.path, this.method, this.handle, {this.params, this.contentType, this.converter, this.handlerAdapter}) {
    if (this.handle == null) {
      this.handle = (Context ctx, [HttpRequest req, HttpResponse res]) async => null;
    }
    if (this.contentType == null) {
      this.contentType = ContentType.json;
    }
  }

  // 请求路径匹配
  Future<bool> match(HttpRequest request) async {
    this.requestPath = request.uri.path;
    this.query = request.uri.queryParametersAll;
    this.pathRegex = pathToRegExp(this.path);
    this.hasMatch = this.pathRegex.hasMatch(this.requestPath) && request.method.toLowerCase() == this.method.toLowerCase();
    return this.hasMatch;
  }

  Future convert(ResponseEntry entry) async {
    return this.converter.convert(entry.result);
  }

  Future write(Context ctx) {
    return this.handlerAdapter.handle(ctx);
  }

  static get(String path, RouterHandleFunction handle, {Map params, ContentType contentType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter}) {
    return Router(path, GET, handle, params: params, contentType: contentType, converter: converter, handlerAdapter: handlerAdapter);
  }

  static post(String path, RouterHandleFunction handle, {Map params, ContentType contentType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter}) {
    return Router(path, POST, handle, params: params, contentType: contentType, converter: converter, handlerAdapter: handlerAdapter);
  }

  static delete(String path, RouterHandleFunction handle, {Map params, ContentType contentType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter}) {
    return Router(path, DELETE, handle, params: params, contentType: contentType, converter: converter, handlerAdapter: handlerAdapter);
  }

  static put(String path, RouterHandleFunction handle, {Map params, ContentType contentType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter}) {
    return Router(path, PUT, handle, params: params, contentType: contentType, converter: converter, handlerAdapter: handlerAdapter);
  }
}
