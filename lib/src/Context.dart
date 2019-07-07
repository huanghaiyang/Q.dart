import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/Router.dart';

class Context {
  Request request;
  Response response;
  Application app;
  int status;

  Router router;

  Context([this.request, this.response, this.app]) {
    this.status = HttpStatus.ok;
  }

  void onerror(Error error) async {}
}
