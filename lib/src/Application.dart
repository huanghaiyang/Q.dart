import 'dart:io';

import 'package:Q/Q.dart';

class Application {
  List<Middleware> middleWares = List();
  String env = 'development';
  HttpServer server;
  List<Router> routers = List();

  // default handlers
  Map<HandlerMapper, HandlerAdapter> handlers = Map();

  // 转换器
  Map<MimeTypes, AbstractHttpMessageConverter> converters = Map();

  Application() {
    this.handlers[HandlerMapper.NOT_FOUND_HANDLER] = NotFoundHandler();
  }

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

  // 加入一个中间件
  void use(Middleware middleware) {
    this.middleWares.add(middleware);
  }

  // response中间件
  Future<Context> handleWithMiddleware(
      Context ctx, Function onFinished, Function onError) async {
    await for (Middleware middleware in Stream.fromIterable(this.middleWares)) {
      await middleware.handle(ctx, onFinished, onError);
    }
    return ctx;
  }

  // 请求处理
  Future<Context> handleRequest(Context ctx) async {
    await handleWithMiddleware(ctx, this.onFinished, this.onError);
    return ctx;
  }

  // 请求完成处理回调函数
  void onFinished(Context ctx) async {}

  // 错误处理
  void onError(Context ctx) async {}

  // 创建上下文
  Context createContext(HttpRequest req, HttpResponse res) {
    Request request = Request();
    request.req = req;
    Response response = Response();
    response.res = res;
    Context context = Context(request, response);
    context.app = request.app = response.app = this;
    request.ctx = response.ctx = context;
    request.response = response;
    response.request = request;
    return context;
  }

  // 添加多个路由
  void addRouters(List<Router> routes) {
    this.routers.addAll(routes);
  }

  // 添加一个路由
  void addRouter(Router router) {
    this.routers.add(router);
  }

  // 匹配路由，并处理请求
  Future<Context> matchRouter(HttpRequest req) async {
    Router matchedRouter;
    // 匹配路由
    await for (Router router in Stream.fromIterable(this.routers)) {
      bool hasMatch = await router.match(req);
      if (hasMatch) {
        matchedRouter = router;
      }
    }
    Context ctx = this.createContext(req, req.response);
    if (matchedRouter != null) {
      // 等待结果处理完成
      dynamic result =
          await matchedRouter.handle(ctx, ctx.request.req, ctx.response.res);
      ResponseEntry responseEntry;
      if (!(result is ResponseEntry)) {
        responseEntry = ResponseEntry(result: result, router: matchedRouter);
      } else {
        responseEntry = result;
      }
      // 转换后的而结果，类型为String
      String convertedResult = await responseEntry.convert();
      // TODO
    } else {
      await this.handlers[HandlerMapper.NOT_FOUND_HANDLER].handle(ctx);
    }
    return ctx;
  }

  // 替换内置默认的handler
  void replaceHandler(
      HandlerMapper handlerMapper, HandlerAdapter handlerAdapter) {
    if (this.handlers.containsKey(handlerMapper)) {
      this.handlers[handlerMapper] = handlerAdapter;
    }
  }
}
