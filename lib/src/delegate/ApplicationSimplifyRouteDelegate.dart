import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/aware/SimplifyRouteAware.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

abstract class ApplicationSimplifyRouteDelegate extends SimplifyRouteAware<Router> with AbstractDelegate {
  factory ApplicationSimplifyRouteDelegate(Application application) => _ApplicationSimplifyRouteDelegate(application);
}

class _ApplicationSimplifyRouteDelegate implements ApplicationSimplifyRouteDelegate {
  final Application application_;

  _ApplicationSimplifyRouteDelegate(this.application_);

  //-----------------------------------------------路由 简便使用方法-------------------------------------------//
  @override
  Router patch(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, HttpMethod.PATCH, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.application_.route(router);
    return router;
  }

  @override
  Router delete(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, HttpMethod.DELETE, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.application_.route(router);
    return router;
  }

  @override
  Router put(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, HttpMethod.PUT, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.application_.route(router);
    return router;
  }

  @override
  Router post(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, HttpMethod.POST, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.application_.route(router);
    return router;
  }

  @override
  Router get(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, HttpMethod.GET, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.application_.route(router);
    return router;
  }
}
