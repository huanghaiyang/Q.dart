import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/Router.dart';

class Application {
  List<Middleware> middleWares = new List();
  String env = 'development';
  HttpServer server;
  List<Router> routers = new List();

  // ip/端口监听
  void listen(int port, {InternetAddress internetAddress}) async {
    internetAddress = internetAddress != null
        ? internetAddress
        : InternetAddress.loopbackIPv4;
    this.server = await HttpServer.bind(internetAddress, port);

    await for (HttpRequest req in server) {
      Context ctx = await this.matchRouter(req);
      await this.handleRequest(ctx);
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

  Future<Context> handleRequest(Context ctx) async {
    await handleWithMiddleware(ctx, this.onFinished, this.onError);
    return ctx;
  }

  void onFinished(Context ctx) async {}

  void onError(Context ctx) async {}

  Context createContext(HttpRequest req, HttpResponse res) {
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

  void addRouters(List<Router> routes) {
    this.routers.addAll(routes);
  }

  void addRouter(Router router) {
    this.routers.add(router);
  }

  Future<Context> matchRouter(HttpRequest req) async {
    Router matchedRouter;
    await for (Router router in Stream.fromIterable(this.routers)) {
      bool matched = await router.match(req);
      if (matched) {
        matchedRouter = router;
      }
    }
    return matchedRouter.dispatcher(this.createContext(req, req.response));
  }
}
