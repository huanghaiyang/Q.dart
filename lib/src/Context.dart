import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Attribute.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/aware/AttributeAware.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';
import 'package:Q/src/aware/CookieAware.dart';
import 'package:Q/src/interceptor/HttpRequestInterceptorState.dart';
import 'package:Q/src/utils/UuidUtil.dart';

abstract class Context extends AttributeAware<Attribute> with CookieAware<Cookie>, BindApplicationAware<Application> {
  factory Context(Request request, Response response, Application app, {HttpRequestInterceptorState interceptorState}) =>
      _Context(request, response, app, interceptorState_: interceptorState);

  Request get request;

  Response get response;

  String get id;

  Router get router;

  Map get body;

  Map<String, List<String>> get query;

  int get routeCount;

  HttpRequestInterceptorState get interceptorState;

  void incrementRouteCount();

  void setRouter(Router router);
}

class _Context implements Context {
  final Request request_;

  final Response response_;

  final Application app_;

  final HttpRequestInterceptorState interceptorState_;

  String id_;

  Router router_;

  Map<String, Attribute> attributes_ = Map();

  int routeCount_ = 0;

  _Context(this.request_, this.response_, this.app_, {this.interceptorState_}) {
    this.id_ = uuid4();
  }

  @override
  Map get body {
    return this.request_.data;
  }

  @override
  Map<String, List<String>> get query {
    return this.router.query;
  }

  @override
  List<Cookie> get cookies {
    return this.request_.req.cookies;
  }

  Cookie getCookie(String name) {
    return this.cookies.singleWhere((cookie) {
      return cookie.name == name;
    });
  }

  @override
  Iterable<Cookie> getCookiesBy(String domain) {
    return this.cookies.where((cookie) {
      return cookie.domain == domain;
    });
  }

  @override
  bool hasCookie(String name) {
    int index = this.cookies.indexWhere((cookie) {
      return cookie.name == name;
    });
    return index != -1;
  }

  @override
  List<String> get cookieNames {
    return this.cookies.map((cookie) => cookie.name);
  }

  @override
  Attribute getAttribute(String name) {
    return this.attributes_[name];
  }

  @override
  Iterable<String> getAttributeNames() {
    return this.attributes_.keys;
  }

  @override
  void setAttribute(String name, dynamic value) {
    assert(name != null);
    assert(value != null);
    this.attributes_[name] = Attribute(name, value);
  }

  @override
  Map<String, Attribute> get attributes {
    return this.attributes_;
  }

  @override
  Router get router {
    return this.router_;
  }

  @override
  String get id {
    return this.id_;
  }

  @override
  Application get app {
    return this.app_;
  }

  @override
  Response get response {
    return this.response_;
  }

  @override
  Request get request {
    return this.request_;
  }

  @override
  void mergeAttributes(Map<String, Attribute> attributes) {
    if (attributes != null) {
      if (attributes is Map<String, Attribute>) {
        Map<String, Attribute> newAttributes = Map();
        attributes.entries.forEach((entry) {
          newAttributes[entry.key] = Attribute(entry.value.name, entry.value.value);
        });
        this.attributes_.addAll(newAttributes);
      }
    }
  }

  @override
  bool hasAttribute(String name) {
    return this.getAttributeNames().contains(name);
  }

  @override
  Iterable<String> get attributeNames {
    return this.getAttributeNames();
  }

  @override
  Attribute removeAttribute(String name) {
    if (this.hasAttribute(name)) {
      return this.attributes_.remove(name);
    }
    return null;
  }

  @override
  void incrementRouteCount() {
    this.routeCount_++;
  }

  @override
  int get routeCount {
    return this.routeCount_;
  }

  @override
  HttpRequestInterceptorState get interceptorState {
    return this.interceptorState_;
  }

  @override
  void setRouter(Router router) {
    assert(router != null);
    this.router_ = router;
    this.incrementRouteCount();
  }
}
