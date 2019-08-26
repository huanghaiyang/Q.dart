import 'dart:io';

import 'package:Q/src/Router.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

abstract class SimplifyRouteAware<T> {
  T get(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name});

  T post(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name});

  T put(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name});

  T delete(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name});

  T patch(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name});
}
