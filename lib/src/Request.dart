import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Response.dart';

class Request {
  Application app;
  HttpRequest req;
  Context ctx;
  Response response;

  Request([this.app, this.req, this.ctx, this.response]);

  void onerror(Error error) async {}
}
