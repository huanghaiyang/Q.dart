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

abstract class Router {
  factory Router(String path, String method, RouterHandleFunction handle,
          {Map params, ContentType contentType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter}) =>
      _Router(path, method, handle, params_: params, contentType_: contentType, converter_: converter, handlerAdapter_: handlerAdapter);

  Map<String, List<String>> get query;

  ContentType get contentType;

  RouterHandleFunction get handle;

  Application get app;

  String get path;

  Map get params;

  String get method;

  set app(Application app);

  set handlerAdapter(HandlerAdapter handlerAdapter);

  set converter(AbstractHttpMessageConverter converter);

  Future<bool> match(HttpRequest request);

  Future convert(ResponseEntry entry);

  Future write(Context ctx);
}

class _Router implements Router {
  Application app_;

  final String path_;

  // 处理函数
  final RouterHandleFunction handle_;

  final Map params_;

  String method_ = GET;

  // 默认返回的格式为json
  ContentType contentType_ = ContentType.json;

  // 默认json数据转换
  AbstractHttpMessageConverter converter_;

  // response handler
  HandlerAdapter handlerAdapter_;

  Map<String, List<String>> query_;

  _Router(this.path_, this.method_, this.handle_, {this.params_, this.contentType_, this.converter_, this.handlerAdapter_}) {
    if (this.contentType_ == null) {
      this.contentType_ = ContentType.json;
    }
  }

  // 请求路径匹配
  Future<bool> match(HttpRequest request) async {
    this.query_ = request.uri.queryParametersAll;
    return pathToRegExp(this.path).hasMatch(request.uri.path) && request.method.toLowerCase() == this.method.toLowerCase();
  }

  Future convert(ResponseEntry entry) async {
    return this.converter_.convert(entry.result);
  }

  Future write(Context ctx) {
    return this.handlerAdapter_.handle(ctx);
  }

  @override
  set app(Application app) {
    this.app_ = app;
  }

  @override
  set handlerAdapter(HandlerAdapter handlerAdapter) {
    this.handlerAdapter_ = handlerAdapter;
  }

  @override
  String get method {
    return this.method_;
  }

  @override
  Map get params {
    return this.params_;
  }

  @override
  String get path {
    return this.path_;
  }

  @override
  Application get app {
    return this.app_;
  }

  @override
  RouterHandleFunction get handle {
    return this.handle_;
  }

  @override
  ContentType get contentType {
    return this.contentType_;
  }

  @override
  Map<String, List<String>> get query {
    return this.query_;
  }

  @override
  set converter(AbstractHttpMessageConverter converter) {
    this.converter_ = converter;
  }
}
