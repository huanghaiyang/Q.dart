import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/Redirect.dart';
import 'package:Q/src/ResponseEntry.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';
import 'package:Q/src/aware/HttpMethodAware.dart';
import 'package:Q/src/aware/PathVariablesAware.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
import 'package:Q/src/exception/InvalidRouterPathException.dart';
import 'package:Q/src/exception/UnKnowMethodException.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';
import 'package:Q/src/helpers/RouterHelper.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

typedef RouterHandleFunction = Future<dynamic> Function(Context, [HttpRequest, HttpResponse]);

abstract class Router extends BindApplicationAware<Application> with PathVariablesAware<Map>, HttpMethodAware<HttpMethod> {
  factory Router(String path, HttpMethod method, RouterHandleFunction handle,
          {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) =>
      _Router(path, method, handle,
          pathVariables_: pathVariables, produceType_: produceType, converter_: converter, handlerAdapter_: handlerAdapter, name_: name);

  String get name;

  Map<String, List<String>> get query;

  ContentType get produceType;

  RouterHandleFunction get handle;

  String get path;

  String get requestUri;

  set handlerAdapter(HandlerAdapter handlerAdapter);

  set converter(AbstractHttpMessageConverter converter);

  set requestUri(String requestUri);

  Future<bool> match(HttpRequest request);

  Future<bool> matchPath(String path);

  void apply(HttpRequest request);

  Future<bool> matchRedirect(Redirect redirect);

  Future convert(ResponseEntry entry);

  Future write(Context ctx);
}

class _Router implements Router {
  Application app_;

  final String name_;

  final String path_;

  String requestUri_;

  // 处理函数
  final RouterHandleFunction handle_;

  Map pathVariables_;

  HttpMethod method_ = HttpMethod.GET;

  // 默认返回的格式为json
  ContentType produceType_;

  // 默认json数据转换
  AbstractHttpMessageConverter converter_;

  // response handler
  HandlerAdapter handlerAdapter_;

  Map<String, List<String>> query_;

  _Router(this.path_, this.method_, this.handle_, {this.pathVariables_, this.produceType_, this.converter_, this.handlerAdapter_, this.name_}) {
    if (!HttpMethodHelper.checkValidMethod(this.method_)) {
      throw UnKnowMethodException(method: this.method_);
    }
    if (!RouterHelper.checkPathAvailable(this.path_)) {
      throw InvalidRouterPathException(path: this.path_);
    }
    if (this.produceType_ == null) {
      this.produceType_ = Application.getApplicationContext().configuration.defaultProducedType;
    }
    if (this.pathVariables_ == null) {
      this.pathVariables_ = Map();
    }
  }

  // 请求路径匹配
  Future<bool> match(HttpRequest request) async {
    return await this.matchPath(request.uri.path) && request.method.toUpperCase() == this.methodName;
  }

  @override
  Future<bool> matchPath(String path) async {
    return pathToRegExp(this.path).hasMatch(path);
  }

  Future convert(ResponseEntry entry) async {
    entry.lastConvertedTime = DateTime.now();
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
  HttpMethod get method {
    return this.method_;
  }

  @override
  String get methodName {
    return HttpMethodHelper.getMethodName(this.method);
  }

  @override
  Map get pathVariables {
    return this.pathVariables_;
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
  ContentType get produceType {
    return this.produceType_;
  }

  @override
  Map<String, List<String>> get query {
    return this.query_;
  }

  @override
  set converter(AbstractHttpMessageConverter converter) {
    this.converter_ = converter;
  }

  @override
  Future<bool> matchRedirect(Redirect redirect) async {
    return pathToRegExp(this.path).hasMatch(redirect.address) && redirect.method.toString() == this.methodName;
  }

  @override
  String get name {
    return this.name_;
  }

  @override
  void apply(HttpRequest request) {
    this.query_ = request.uri.queryParametersAll;
    this.requestUri_ = request.uri.path;
    this.pathVariables = RouterHelper.applyPathVariables(request.uri.path, this.path_);
  }

  @override
  set pathVariables(Map pathVariables) {
    this.pathVariables_ = pathVariables;
  }

  @override
  void mergePathVariables(Map pathVariables) {
    if (pathVariables != null) {
      this.pathVariables_.addAll(pathVariables);
    }
  }

  @override
  set requestUri(String requestUri) {
    this.requestUri_ = requestUri;
  }

  @override
  String get requestUri {
    return this.requestUri_;
  }

  @override
  List<String> pathVariableNames() {
    return this.pathVariables.keys;
  }

  @override
  bool containsPathVariable(String name) {
    return this.pathVariables.containsKey(name);
  }

  @override
  dynamic getPathVariable(String name) {
    return this.pathVariables[name];
  }
}
