import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Response.dart';

class Request {
  Application app;
  HttpRequest req;
  Context ctx;
  Response response;

  Map data;

  Request({this.data});

  void onerror(Error error) async {}
}
