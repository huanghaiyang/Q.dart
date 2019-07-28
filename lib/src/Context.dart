import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Attribute.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/aware/AttributeAware.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';
import 'package:Q/src/aware/CookieAware.dart';
import 'package:Q/src/utils/UuidUtil.dart';

abstract class Context extends AttributeAware<Attribute> with CookieAware<Cookie>, BindApplicationAware<Application> {
  factory Context([Request request, Response response, Application app]) => _Context(request, response, app);

  Request get request;

  Response get response;

  String get id;

  Router get router;

  Map get body;

  Map<String, List<String>> get query;

  int get routeCount;

  void incrementRouteCount();

  void setRouter(Router router);
}

class _Context implements Context {
  Request request_;

  Response response_;

  Application app_;

  String id_;

  Router router_;

  Map<String, Attribute> attributes_ = Map();

  int routeCount_ = 0;

  _Context([this.request_, this.response_, this.app_]) {
    this.id_ = uuid5;
  }

  @override
  Map get body {
    return this.request_.data;
  }

  @override
  Map<String, List<String>> get query {
    return this.router_.query;
  }

  @override
  List<Cookie> get cookies {
    return this.request_.req.cookies;
  }

  Cookie getBookie(String name) {
    return this.cookies.singleWhere((cookie) {
      return cookie.name == name;
    });
  }

  @override
  Iterable<Cookie> getBookiesBy(String domain) {
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
    this.attributes_[name] = Attribute(name, value, this.router_);
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
  set app(Application app) {
    this.app_ = app;
  }

  @override
  void mergeAttributes(Map<String, Attribute> attributes) {
    if (attributes != null) {
      if (attributes is Map<String, Attribute>) {
        Map<String, Attribute> newAttributes = Map();
        attributes.entries.forEach((entry) {
          newAttributes[entry.key] = Attribute(entry.value.name, entry.value.value, this.router_);
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
  void setRouter(Router router) {
    this.router_ = router;
    this.incrementRouteCount();
  }
}
