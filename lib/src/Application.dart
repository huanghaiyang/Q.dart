import 'dart:async';
import 'dart:io';

import 'package:Q/Q.dart';

abstract class Application extends CloseableAware
    with
        RouteAware<Router>,
        SimplifyRouteAware<Router>,
        ResourceAware<String, Resource>,
        InterceptorRegistryAware<AbstractInterceptor>,
        HttpRequestResolverAware<AbstractResolver, Request, ResolverType>,
        HttpResponseConverterAware<ContentType, AbstractHttpMessageConverter>,
        HttpRequestHandlerAware<int, HandlerAdapter>,
        ApplicationContextAware<ApplicationContext>,
        ApplicationListenerAware<AbstractListener, ApplicationListenerType, List>,
        HttpRequestContextAware<Context>,
        ApplicationHttpServerAware {
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

  List<Resource> get resources;

  Map<ResolverType, AbstractResolver> get resolvers;

  HttpRequestInterceptorChain get httpRequestInterceptorChain;

  set httpRequestInterceptorChain(HttpRequestInterceptorChain httpRequestInterceptorChain);

  void use(Middleware middleware);

  dynamic getDelegate(Type delegateType);
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

  ApplicationContext applicationContext_;

  ApplicationInitializer applicationInitializer_;

  // 当前环境
  String env_ = 'development';

  // 中间件
  List<Middleware> middleWares_ = List();

  // 路由
  List<Router> routers_ = List();

  // default handlers
  Map<int, HandlerAdapter> handlers_ = Map();

  // 转换器
  Map<ContentType, AbstractHttpMessageConverter> converters_ = Map();

  // 资源
  List<Resource> resources_ = List();

  // 请求解析器
  Map<ResolverType, AbstractResolver> resolvers_ = Map();

  HttpRequestInterceptorChain httpRequestInterceptorChain_;

  HttpRequestLifecycleDelegate httpRequestLifecycleDelegate;

  ApplicationLifecycleDelegate applicationLifecycleDelegate;

  ApplicationSimplifyRouteDelegate applicationSimplifyRouteDelegate;

  ApplicationResourceDelegate applicationResourceDelegate;

  ApplicationRouteDelegate applicationRouteDelegate;

  ApplicationClosableDelegate applicationClosableDelegate;

  ApplicationLifecycleListener applicationLifecycleListener;

  HttpRequestContextDelegate httpRequestContextDelegate;

  HttpRequestHandlerDelegate httpRequestHandlerDelegate;

  HttpResponseConverterDelegate httpResponseConverterDelegate;

  ApplicationHttpServerDelegate applicationHttpServerDelegate;

  HttpRequestResolverDelegate httpRequestResolverDelegate;

  ApplicationInterceptorRegistryDelegate applicationInterceptorRegistryDelegate;

  init() {
    applicationInitializer_ = ApplicationInitializer(this);
    applicationLifecycleDelegate = ApplicationLifecycleDelegate(this);
    applicationRouteDelegate = ApplicationRouteDelegate(this);
    applicationSimplifyRouteDelegate = ApplicationSimplifyRouteDelegate(this);
    applicationResourceDelegate = ApplicationResourceDelegate(this);
    applicationClosableDelegate = ApplicationClosableDelegate(this);
    applicationLifecycleListener = ApplicationLifecycleListener(this);
    httpRequestLifecycleDelegate = HttpRequestLifecycleDelegate(this);
    httpRequestContextDelegate = HttpRequestContextDelegate(this);
    httpRequestHandlerDelegate = HttpRequestHandlerDelegate(this);
    httpResponseConverterDelegate = HttpResponseConverterDelegate(this);
    applicationHttpServerDelegate = ApplicationHttpServerDelegate(this);
    httpRequestResolverDelegate = HttpRequestResolverDelegate(this);
    applicationInterceptorRegistryDelegate = ApplicationInterceptorRegistryDelegate(this);
    this.applicationInitializer_.init();
  }

  // ip/端口监听
  @override
  void listen(int port, {InternetAddress internetAddress}) => applicationHttpServerDelegate.listen(port, internetAddress: internetAddress);

  // 加入一个中间件
  @override
  void use(Middleware middleware) {
    this.middleWares_.add(middleware);
  }

  @override
  void addResolver(ResolverType type, AbstractResolver resolver) => httpRequestResolverDelegate.addResolver(type, resolver);

  // 匹配请求的content-type
  @override
  Future<AbstractResolver> matchResolver(HttpRequest req) => httpRequestResolverDelegate.matchResolver(req);

  // 预处理请求
  @override
  Future<Request> resolveRequest(HttpRequest req) => httpRequestResolverDelegate.resolveRequest(req);

  @override
  void addHandler(int httpStatus, HandlerAdapter handlerAdapter) => httpRequestHandlerDelegate.addHandler(httpStatus, handlerAdapter);

  // 替换内置默认的handler
  @override
  void replaceHandler(int httpStatus, HandlerAdapter handlerAdapter) =>
      httpRequestHandlerDelegate.replaceHandler(httpStatus, handlerAdapter);

  // 替换内置转换器
  @override
  void replaceConverter(ContentType type, AbstractHttpMessageConverter converter) =>
      httpResponseConverterDelegate.replaceConverter(type, converter);

  @override
  void addConverter(ContentType type, AbstractHttpMessageConverter converter) =>
      httpResponseConverterDelegate.addConverter(type, converter);

  // 拦截器注册
  @override
  void registryInterceptor(AbstractInterceptor interceptor) => applicationInterceptorRegistryDelegate.registryInterceptor(interceptor);

  // 注册多个拦截器
  @override
  void registryInterceptors(Iterable<AbstractInterceptor> interceptors) =>
      applicationInterceptorRegistryDelegate.registryInterceptors(interceptors);

  @override
  Map<ResolverType, AbstractResolver> get resolvers {
    return this.resolvers_;
  }

  @override
  List<Resource> get resources {
    return this.resources_;
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
  set applicationContext(ApplicationContext applicationContext) {
    this.applicationContext_ = applicationContext;
  }

  @override
  ApplicationContext get applicationContext {
    return this.applicationContext_;
  }

  @override
  HttpRequestInterceptorChain get httpRequestInterceptorChain {
    return httpRequestInterceptorChain_;
  }

  @override
  set httpRequestInterceptorChain(HttpRequestInterceptorChain httpRequestInterceptorChain) {
    this.httpRequestInterceptorChain_ = httpRequestInterceptorChain;
  }

  @override
  Future<dynamic> close() => applicationClosableDelegate.close();

  @override
  void route(Router t) => applicationRouteDelegate.route(t);

  @override
  void routes(Iterable<Router> t) => applicationRouteDelegate.routes(t);

  // 资源维护
  @override
  void resource(String pattern, Resource resource) => applicationResourceDelegate.resource(pattern, resource);

  @override
  Future<dynamic> flush(String pattern) => applicationResourceDelegate.flush(pattern);

  @override
  Router patch(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) =>
      this.applicationSimplifyRouteDelegate.patch(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);

  @override
  Router delete(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) =>
      this.applicationSimplifyRouteDelegate.delete(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);

  @override
  Router put(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) =>
      this.applicationSimplifyRouteDelegate.put(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);

  @override
  Router post(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) =>
      this.applicationSimplifyRouteDelegate.post(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);

  @override
  Router get(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) =>
      this.applicationSimplifyRouteDelegate.get(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);

  @override
  dynamic getDelegate(Type delegateType) => ApplicationReflectHelper.getDelegate(delegateType, [
        httpRequestLifecycleDelegate,
        applicationLifecycleDelegate,
        applicationRouteDelegate,
        applicationSimplifyRouteDelegate,
        applicationResourceDelegate,
        applicationClosableDelegate,
        httpRequestLifecycleDelegate,
        httpRequestContextDelegate,
        httpRequestHandlerDelegate,
        httpResponseConverterDelegate,
        applicationHttpServerDelegate,
        httpRequestResolverDelegate,
        applicationInterceptorRegistryDelegate
      ]);

  @override
  void addListener(AbstractListener listener) => applicationLifecycleListener.addListener(listener);

  @override
  void trigger(ApplicationListenerType type, List payload) => applicationLifecycleListener.trigger(type, payload);

  @override
  Future<Context> createContext(HttpRequest httpRequest, HttpResponse httpResponse, {HttpRequestInterceptorState interceptorState}) =>
      httpRequestContextDelegate.createContext(httpRequest, httpResponse, interceptorState: interceptorState);
}
