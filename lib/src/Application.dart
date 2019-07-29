import 'dart:async';
import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/ApplicationContext.dart';
import 'package:curie/curie.dart';

typedef ApplicationStartUpCallback = Future<dynamic> Function(Application application);

typedef ApplicationCloseCallback = void Function(Application application, [Future<dynamic> prevCloseableResult]);

abstract class Application extends CloseableAware<Application, ApplicationCloseCallback> with RouteAware<Router> {
  factory Application() => _Application.getInstance();

  static ApplicationContext getApplicationContext() {
    return Application().applicationContext;
  }

  static List<Router> getRouters() {
    return Application().routers;
  }

  static List<Middleware> getMiddleWares() {
    return Application().middleWares;
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

  void listen(int port, {InternetAddress internetAddress});

  void onStartup(ApplicationStartUpCallback applicationStartUpCallback);

  void use(Middleware middleware);

  void onFinished(Context ctx);

  void onError(Context ctx);

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

  ApplicationContext applicationContext_ = ApplicationContext(_instance);

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

  ApplicationCloseCallback applicationCloseCallback;

  ApplicationStartUpCallback applicationStartUpCallback;

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
    this.server_ = await HttpServer.bind(internetAddress, port).catchError(this.onError).whenComplete(() {
      if (this.applicationStartUpCallback != null) {
        this.applicationStartUpCallback(this);
      }
    });

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
      await this.applyRouter(ctx, req);
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
    // 查找路由的响应结果转换器
    router.converter = this.converters_[router.produceType];
    router.handlerAdapter = this.handlers_[HttpStatus.ok];
  }

  // 同时添加多个路由
  @override
  void routes(Iterable<Router> routers) {
    routers.forEach((router) => this.route(router));
  }

  // 匹配路由，并处理请求
  Future<Context> applyRouter(Context ctx, HttpRequest req) async {
    // 匹配路由
    Router matchedRouter = await RouterHelper.matchRouter(req, this.routers_);
    if (matchedRouter != null) {
      // 设置当前请求上下文的路由
      ctx.setRouter(matchedRouter);
      // 处理路由请求
      await this.handleRouter(matchedRouter, ctx, req);
    } else {
      // TODO throw router not found exception
      await this.handlers_[HttpStatus.notFound].handle(ctx);
    }
    return ctx;
  }

  // 路由处理，响应请求
  Future<Context> handleRouter(Router matchedRouter, Context ctx, HttpRequest req) async {
    // 通过反射获取当前请求处理函数上定义的路径参数
    Map<String, dynamic> reflectedPathVariables = RouterHelper.reflectPathVariables(matchedRouter);
    // 合并参数
    List positionArguments = List()..addAll([ctx, ctx.request.req, ctx.response.res])..addAll(reflectedPathVariables.values);
    // 等待结果处理完成
    dynamic result = await Function.apply(matchedRouter.handle, positionArguments);
    // 如果执行的结果是一个重定向
    if (result is Redirect) {
      // 根据重定向匹配路由并执行
      await this.handleRedirect(ctx, result, req);
    } else {
      ResponseEntry responseEntry = ResponseEntry.from(result);
      // 将执行结果赋值给上线文的响应
      ctx.response.responseEntry = responseEntry;
      // 转换后的而结果，类型为String
      String convertedResult = await matchedRouter.convert(responseEntry);
      responseEntry.convertedResult = convertedResult;
      // 写response,完成请求
      await matchedRouter.write(ctx);
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
          // 如果拦截器执行preHandler时抛出异常，则终止请求
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
    // 处理每一个拦截器的后置处理方法
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

  // 处理重定向
  Future<Context> handleRedirect(Context ctx, Redirect redirect, HttpRequest req) async {
    // 根据重定向的地址匹配路由
    Router matchedRouter = await RouterHelper.matchRedirect(redirect, this.routers_);
    if (matchedRouter != null) {
      matchedRouter.mergePathVariables(RouterHelper.applyPathVariables(matchedRouter.path, redirect.address.replaceFirst(PATH_PATTERN, '')));
      // 重新设置请求上下文的路由
      ctx.setRouter(matchedRouter);
      // 合并当前请求上下文中的attributes数据
      ctx.mergeAttributes(redirect.attributes);
      // 处理路由请求
      return this.handleRouter(matchedRouter, ctx, req);
    } else {
      throw Exception('redirect ${redirect.address} not found.');
    }
  }

  @override
  Future<dynamic> close(Application application) async {
    Future<dynamic> prevCloseableResult = await this.server_.close();
    if (this.applicationCloseCallback != null) {
      return await this.applicationCloseCallback(this, prevCloseableResult);
    }
    return prevCloseableResult;
  }

  @override
  Future<dynamic> onClose(ApplicationCloseCallback applicationCloseCallback) async {
    this.applicationCloseCallback = applicationCloseCallback;
    return true;
  }

  @override
  void onStartup(ApplicationStartUpCallback applicationStartUpCallback) {
    this.applicationStartUpCallback = applicationStartUpCallback;
  }

  //-----------------------------------------------路由 简便使用方法-------------------------------------------//
  @override
  Router patch(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, PATCH, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.route(router);
    return router;
  }

  @override
  Router delete(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, DELETE, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.route(router);
    return router;
  }

  @override
  Router put(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, PUT, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.route(router);
    return router;
  }

  @override
  Router post(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, POST, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.route(router);
    return router;
  }

  @override
  Router get(String path, RouterHandleFunction handle,
      {Map pathVariables, ContentType produceType, AbstractHttpMessageConverter converter, HandlerAdapter handlerAdapter, String name}) {
    Router router = Router(path, GET, handle,
        pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    this.route(router);
    return router;
  }
}
