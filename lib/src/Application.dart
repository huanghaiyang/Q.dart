import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';

class Application {
  List<Middleware> middleware = new List();
  String env = 'development';
  Context context;
  Request request;
  Response response;
  HttpServer server;

  Application([this.context, this.request, this.response]);

  // ip/端口监听
  void listen(int port, {InternetAddress internetAddress}) async {
    internetAddress = internetAddress != null
        ? internetAddress
        : InternetAddress.loopbackIPv4;
    this.server = await HttpServer.bind(internetAddress, port);

    await for (var request in server) {}
  }

  void use(Middleware middleware) {
    this.middleware.add(middleware);
  }
}
