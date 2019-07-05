import 'package:Q/src/Application.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';

class Context {
  Request request;
  Response response;
  Application app;
  int status;

  Context([this.request, this.response, this.app]);

  void onerror(Error error) async {}
}
