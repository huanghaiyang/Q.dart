import 'dart:async';
import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/ApplicationContext.dart';
import 'package:curie/curie.dart';

abstract class Application {
  factory Application() => _Application.getInstance();

  static ApplicationContext getApplicationContext() {
    return Application().applicationContext;
  }

  String get env;

  List<Middleware> get middleWares;

  List<Router> get routers;

  Map<int, HandlerAdapter> get handlers;

  Map<ContentType, AbstractHttpMessageConverter> get converters;

  List<AbstractInterceptor> get interceptors;

  List<Resource> get resources;

  Map<ResolverType, AbstractResolver> get resolvers;

  ApplicationContext get applicationContext;

  void route(Router router);

  void listen(int port, {InternetAddress internetAddress});

  void use(Middleware middleware);

  void onFinished(Context ctx);

  void onError(Context ctx);

  void routes(List<Router> routers);

  Future<Context> matchRouter(Context ctx, HttpRequest req);

  void replaceHandler(int httpStatus, HandlerAdapter handlerAdapter);

  void replaceConverter(ContentType type, AbstractHttpMessageConverter converter);

  void registryInterceptor(AbstractInterceptor interceptor);

  void registryInterceptors(List<AbstractInterceptor> interceptors);
}

class _Application implements Application {
  _Application._();

  static _Application _instance;

  static _Application getInstance() {
    if (_instance == null) {
      _instance = _Application._();
      _instance.init();
    }
    return _instance;
  }

  ApplicationContext applicationContext_ = ApplicationContext();

  // 当前环境
  String env_ = 'development';

  // 服务
  HttpServer server_;

  // 中间件
  List<Middleware> middleWares_ = List();

  // 路由
  List<Router> routers_ = List();

  // default handlers
  Map<int, HandlerAdapter> handlers_ = Map();

  // 转换器
  Map<ContentType, AbstractHttpMessageConverter> converters_ = Map();

  // 拦截器
  List<AbstractInterceptor> interceptors_ = List();

  // 资源
  List<Resource> resources_ = List();

  // 请求解析器
  Map<ResolverType, AbstractResolver> resolvers_ = Map();

  init() {
    this.initHandlers();
    this.initConverters();
    this.initInterceptors();
    this.initResolvers();
  }

  // 初始化默认处理器
  initHandlers() {
    this.handlers_[HttpStatus.notFound] = NotFoundHandler.getInstance();
    this.handlers_[HttpStatus.ok] = OKHandler.getInstance();
  }

  // 初始化转换器
  initConverters() {
    this.converters_[ContentType.json] = JSONHttpMessageConverter.getInstance();
    this.converters_[ContentType.text] = StringHttpMessageConverter.getInstance();
    this.converters_[ContentType.html] = StringHttpMessageConverter.getInstance();
  }

  // 内置拦截器初始化
  initInterceptors() {
    this.interceptors_.add(I18nInterceptor.getInstance());
    this.interceptors_.add(UnSupportedContentTypeInterceptor.getInstance());
  }

  // 初始化内置解析器
  initResolvers() {
    this.resolvers_[ResolverType.MULTIPART] = MultipartResolver.getInstance();
    this.resolvers_[ResolverType.JSON] = JsonResolver.getInstance();
  }

  // ip/端口监听
  @override
  void listen(int port, {InternetAddress internetAddress}) async {
    // 默认ipv4
    internetAddress = internetAddress != null ? internetAddress : InternetAddress.loopbackIPv4;
    // 创建服务
    this.server_ = await HttpServer.bind(internetAddress, port).catchError(this.onError);

    // 处理请求
    await for (HttpRequest req in this.server_) {
      await this.handleRequest(req);
    }
  }

  // 请求处理
  Future<dynamic> handleRequest(HttpRequest req) async {
    HttpResponse res = req.response;
    // 处理拦截
    bool suspend = await this.applyPreHandler(req, res);
    // 如果返回false，则表示拦截器已经处理了当前请求，不需要再匹配路由、处理请求、消费中间件
    if (suspend) {
      // 创建请求上下文
      Context ctx = await this.createContext(req, res);
      // 前置中间件处理
      await this.handleWithMiddleware(ctx, MiddlewareType.BEFORE, this.onFinished, this.onError);
      // 匹配路由并处理请求
      await this.matchRouter(ctx, req);
      // 后置中间件处理
      await this.handleWithMiddleware(ctx, MiddlewareType.AFTER, this.onFinished, this.onError);
      // 执行后置拦截器方法
      await this.applyPostHandler(req, res);
    }
    await makeSureResponseRelease(res);
    return true;
  }

  // 确保response被正确的释放并关闭
  Future<bool> makeSureResponseRelease(HttpResponse res) async {
    await res.flush();
    await res.close();
    return true;
  }

  // 加入一个中间件
  @override
  void use(Middleware middleware) {
    this.middleWares_.add(middleware);
  }

  // response中间件
  Future<Context> handleWithMiddleware(Context ctx, MiddlewareType type, Function onFinished, Function onError) async {
    await for (Middleware middleware in Stream.fromIterable(this.middleWares_.where((Middleware middleware) => middleware.type == type))) {
      await middleware.handle(ctx, onFinished, onError);
    }
    return ctx;
  }

  // 请求完成处理回调函数
  @override
  void onFinished(Context ctx) async {}

  // 错误处理
  @override
  void onError(Context ctx) async {}

  // 创建上下文
  Future<Context> createContext(HttpRequest req, HttpResponse res) async {
    Request request = await this.resolveRequest(req);
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

  // 预处理请求
  Future<Request> resolveRequest(HttpRequest req) async {
    if (this.resolvers_.isEmpty) return Request();
    List<Function> functions = List();
    List<ResolverType> keys = List.from(this.resolvers_.keys);
    for (int i = 0; i < keys.length; i++) {
      ResolverType resolverType = keys[i];
      functions.add(() async {
        return await this.resolvers_[resolverType].match(req);
      });
    }
    Completer<Request> completer = Completer();
    await someLimit(functions, 5, (Map<int, bool> result) {
      if (result.values.every((v) => !v)) {
        completer.complete(Request());
      } else {
        for (MapEntry entry in result.entries) {
          if (entry.value) {
            completer.complete(this.resolvers_[keys[entry.key]].resolve(req));
            break;
          }
        }
      }
    });
    return completer.future;
  }

  // 添加路由
  @override
  void route(Router router) {
    this.routers_.add(router);
    router.app = this;
    router.converter = this.converters_[router.contentType];
    router.handlerAdapter = this.handlers_[HttpStatus.ok];
  }

  // 同时添加多个路由
  @override
  void routes(List<Router> routers) {
    routers.forEach((router) => this.route(router));
  }

  // 匹配路由，并处理请求
  @override
  Future<Context> matchRouter(Context ctx, HttpRequest req) async {
    Router matchedRouter;
    // 匹配路由
    await for (Router router in Stream.fromIterable(this.routers_)) {
      bool hasMatch = await router.match(req);
      if (hasMatch) {
        matchedRouter = router;
      }
    }
    if (matchedRouter != null) {
      ctx.router = matchedRouter;
      // 等待结果处理完成
      dynamic result = await matchedRouter.handle(ctx, ctx.request.req, ctx.response.res);
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
      await this.handlers_[HttpStatus.notFound].handle(ctx);
    }
    return ctx;
  }

  // 替换内置默认的handler
  @override
  void replaceHandler(int httpStatus, HandlerAdapter handlerAdapter) {
    if (this.handlers_.containsKey(httpStatus)) {
      this.handlers_[httpStatus] = handlerAdapter;
    }
  }

  // 替换内置转换器
  @override
  void replaceConverter(ContentType type, AbstractHttpMessageConverter converter) {
    if (this.converters_.containsKey(type)) {
      this.converters_[type] = converter;
    }
  }

  // 拦截器注册
  @override
  void registryInterceptor(AbstractInterceptor interceptor) {
    this.interceptors_.add(interceptor);
  }

  // 注册多个拦截器
  @override
  void registryInterceptors(List<AbstractInterceptor> interceptors) {
    interceptors.forEach((interceptor) => this.registryInterceptor(interceptor));
  }

  // 执行拦截器的preHandler
  Future<bool> applyPreHandler(HttpRequest req, HttpResponse res) async {
    List<Function> functions = List();
    for (int i = 0; i < this.interceptors_.length; i++) {
      functions.add(() async {
        bool suspend;
        try {
          suspend = await this.interceptors_[i].preHandle(req, res);
        } catch (exception) {
          suspend = true;
          print(exception);
        }
        return suspend;
      });
    }
    bool suspend = await everySeries(functions);
    return suspend;
  }

  // 执行拦截器的postHandler
  void applyPostHandler(HttpRequest req, HttpResponse res) async {
    List<Function> functions = List();
    for (int i = this.interceptors_.length - 1; i >= 0; i--) {
      functions.add(() async {
        return this.interceptors_[i].postHandle(req, res);
      });
    }
    await eachSeries(functions);
  }

  // 资源维护
  void resource(String pattern, Resource resource) {}

  @override
  Map<ResolverType, AbstractResolver> get resolvers {
    return this.resolvers_;
  }

  @override
  List<Resource> get resources {
    return this.resources_;
  }

  @override
  List<AbstractInterceptor> get interceptors {
    return this.interceptors_;
  }

  @override
  Map<ContentType, AbstractHttpMessageConverter> get converters {
    return this.converters_;
  }

  @override
  Map<int, HandlerAdapter> get handlers {
    return this.handlers_;
  }

  @override
  List<Router> get routers {
    return this.routers_;
  }

  @override
  List<Middleware> get middleWares {
    return this.middleWares_;
  }

  @override
  String get env {
    return this.env_;
  }

  @override
  ApplicationContext get applicationContext {
    return this.applicationContext_;
  }
}
