import 'dart:io';

import 'package:Q/Q.dart';

class Application {
  // 当前环境
  String env = 'development';

  // 服务
  HttpServer server;

// 中间件
  List<Middleware> middleWares = List();

  // 路由
  List<Router> routers = List();

  // default handlers
  Map<int, HandlerAdapter> handlers = Map();

  // 转换器
  Map<ContentType, AbstractHttpMessageConverter> converters = Map();

  // 拦截器
  List<AbstractInterceptor> interceptors = List();

  Application() {
    initHandlers();
    initConverters();
    initInterceptors();
  }

  // 初始化默认处理器
  initHandlers() {
    this.handlers[HttpStatus.notFound] = NotFoundHandler.getInstance();
    this.handlers[HttpStatus.ok] = OKHandler.getInstance();
  }

  // 初始化转换器
  initConverters() {
    this.converters[ContentType.json] = JSONHttpMessageConverter.getInstance();
    this.converters[ContentType.text] =
        StringHttpMessageConverter.getInstance();
    this.converters[ContentType.html] =
        StringHttpMessageConverter.getInstance();
  }

  // 内置拦截器初始化
  initInterceptors() {
    this.interceptors.add(I18nInterceptor.getInstance());
  }

  // ip/端口监听
  void listen(int port, {InternetAddress internetAddress}) async {
    // 默认ipv4
    internetAddress = internetAddress != null
        ? internetAddress
        : InternetAddress.loopbackIPv4;
    // 创建服务
    this.server = await HttpServer.bind(internetAddress, port);

    // 处理请求
    await for (HttpRequest req in server) {
      // 创建请求上下文
      Context ctx = this.createContext(req, req.response);
      // 前置中间件处理
      await this.handleWithMiddleware(
          ctx, MiddlewareType.BEFORE, this.onFinished, this.onError);
      // 匹配路由并处理请求
      await this.matchRouter(ctx, req);
      // 后置中间件处理
      await this.handleWithMiddleware(
          ctx, MiddlewareType.AFTER, this.onFinished, this.onError);
    }
  }

  // 加入一个中间件
  void use(Middleware middleware) {
    this.middleWares.add(middleware);
  }

  // response中间件
  Future<Context> handleWithMiddleware(Context ctx, MiddlewareType type,
      Function onFinished, Function onError) async {
    await for (Middleware middleware in Stream.fromIterable(this
        .middleWares
        .where((Middleware middleware) => middleware.type == type))) {
      await middleware.handle(ctx, onFinished, onError);
    }
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

  // 添加路由
  router(Router router) {
    this.routers.add(router);
    router.app = this;
    router.converter = this.converters[router.contentType];
    router.handlerAdapter = this.handlers[HttpStatus.ok];
  }

  // 匹配路由，并处理请求
  Future<Context> matchRouter(Context ctx, HttpRequest req) async {
    Router matchedRouter;
    // 匹配路由
    await for (Router router in Stream.fromIterable(this.routers)) {
      bool hasMatch = await router.match(req);
      if (hasMatch) {
        matchedRouter = router;
      }
    }
    if (matchedRouter != null) {
      ctx.router = matchedRouter;
      // 等待结果处理完成
      dynamic result =
          await matchedRouter.handle(ctx, ctx.request.req, ctx.response.res);
      ResponseEntry responseEntry;
      if (!(result is ResponseEntry)) {
        responseEntry = ResponseEntry(result);
      } else {
        responseEntry = result;
      }
      ctx.response.responseEntry = responseEntry;
      // 转换后的而结果，类型为String
      String convertedResult = await matchedRouter.convert(responseEntry);
      responseEntry.convertedResult = convertedResult;
      // 写response,完成请求
      await matchedRouter.write(ctx);
    } else {
      // TODO throw router not found exception
      await this.handlers[HttpStatus.notFound].handle(ctx);
    }
    return ctx;
  }

  // 替换内置默认的handler
  void replaceHandler(int httpStatus, HandlerAdapter handlerAdapter) {
    if (this.handlers.containsKey(httpStatus)) {
      this.handlers[httpStatus] = handlerAdapter;
    }
  }

  // 替换内置转换器
  void replaceConverter(
      ContentType type, AbstractHttpMessageConverter converter) {
    if (this.converters.containsKey(type)) {
      this.converters[type] = converter;
    }
  }

  // 拦截器注册
  void registryInterceptor(AbstractInterceptor interceptor) {
    this.interceptors.add(interceptor);
  }
}
