import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Attribute.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/utils/UuidUtil.dart';

abstract class Context {
  factory Context([Request request, Response response, Application app]) => _Context(request, response, app);

  Request get request;

  Response get response;

  Application get app;

  int get status;

  String get id;

  Router get router;

  Map<String, Attribute> get attributes;

  Map get body;

  Map<String, List<String>> get query;

  List<Cookie> get cookies;

  set app(Application app);

  set router(Router router);

  set status(int status);

  Cookie getBookie(String name);

  Iterable<Cookie> getBookiesBy(String domain);

  Attribute getAttribute(String name);

  Iterable<String> getAttributeNames();

  void setAttribute(String name, dynamic value);
}

class _Context implements Context {
  Request request_;

  Response response_;

  Application app_;

  int status_;

  String id_;

  Router router_;

  Map<String, Attribute> attributes_ = Map();

  _Context([this.request_, this.response_, this.app_]) {
    this.status_ = HttpStatus.ok;
    this.id_ = uuid;
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
  Attribute getAttribute(String name) {
    return this.attributes_[name];
  }

  @override
  Iterable<String> getAttributeNames() {
    return this.attributes_.keys;
  }

  @override
  void setAttribute(String name, dynamic value) {
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
  int get status {
    return this.status_;
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
  set status(int status) {
    this.status_ = status;
  }

  @override
  set router(Router router) {
    this.router_ = router;
  }

  @override
  set app(Application app) {
    this.app_ = app;
  }
}
