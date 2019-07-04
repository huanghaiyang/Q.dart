import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';

class Application {
  List<Middleware> middleWares = new List();
  String env = 'development';
  HttpServer server;

  // ip/端口监听
  void listen(int port, {InternetAddress internetAddress}) async {
    internetAddress = internetAddress != null
        ? internetAddress
        : InternetAddress.loopbackIPv4;
    this.server = await HttpServer.bind(internetAddress, port);

    await for (HttpRequest req in server) {
      await this.handleRequest(this.createContext(req, req.response));
    }
  }

  void use(Middleware middleware) {
    this.middleWares.add(middleware);
  }

  Future<Context> handleWithMiddleware(
      Context ctx, Function onFinished, Function onError) async {
    await for (Middleware middleware in Stream.fromIterable(this.middleWares)) {
      await middleware.handle(ctx, onFinished, onError);
    }
    return ctx;
  }

  Future<Response> handleRequest(Context ctx) async {
    await handleWithMiddleware(ctx, this.onFinished, this.onError);
    return ctx.response;
  }

  void onFinished(Context ctx) async {}

  void onError(Context ctx) async {}

  createContext(HttpRequest req, HttpResponse res) {
    Request request = new Request();
    request.req = req;
    Response response = new Response();
    response.res = res;
    Context context = new Context(request, response);
    context.app = request.app = response.app = this;
    request.ctx = response.ctx = context;
    request.response = response;
    response.request = request;
    return context;
  }
}
