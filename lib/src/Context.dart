import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/utils/UuidUtil.dart';

class Context {
  Request request;
  Response response;
  Application app;
  int status;
  String id;
  Router router;

  Context([this.request, this.response, this.app]) {
    this.status = HttpStatus.ok;
    this.id = uuid;
  }

  Map get body {
    return this.request.data;
  }

  Map<String, List<String>> get query {
    return this.router.query;
  }

  List<Cookie> get cookies {
    return this.request.req.cookies;
  }

  Cookie getBookie(String name) {
    return this.cookies.singleWhere((cookie) {
      return cookie.name == name;
    });
  }

  Iterable<Cookie> getBookiesBy(String domain) {
    return this.cookies.where((cookie) {
      return cookie.domain == domain;
    });
  }

  void onerror(Error error) async {}
}
