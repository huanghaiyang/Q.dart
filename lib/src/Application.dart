import 'dart:async';
import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/Middleware.dart';
import 'package:Q/src/aware/MiddlewareAware.dart';

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
        ApplicationHttpServerAware,
        ApplicationArgumentsParsedAware<List<String>, List<String>>,
        MiddlewareAware<Middleware> {
  factory Application() => _Application._();

  factory Application.instance() => _Application._();

  static ApplicationContext getApplicationContext() {
    return Application.instance().applicationContext;
  }

  static List<Router> getRouters() {
    return List.unmodifiable(Application.instance().routers);
  }

  static List<Middleware> getMiddleWares() {
    return List.unmodifiable(Application.instance().middleWares);
  }

  List<Middleware> get middleWares;

  List<Router> get routers;

  Map<int, HandlerAdapter> get handlers;

  Map<ContentType, AbstractHttpMessageConverter> get converters;

  List<Resource> get resources;

  Map<ResolverType, AbstractResolver> get resolvers;

  HttpRequestInterceptorChain get httpRequestInterceptorChain;

  set httpRequestInterceptorChain(HttpRequestInterceptorChain httpRequestInterceptorChain);

  dynamic getDelegate(Type delegateType);

  void init();
  
  void registerBlueprint(Blueprint blueprint);
}

class _Application implements Application, MiddlewareAware<Middleware> {
  _Application._();

  // 不再使用单例模式，每个 Application() 调用都返回一个新的实例
  static _Application instance() {
    return _Application._();
  }

  ApplicationContext applicationContext_;

  ApplicationInitializer applicationInitializer_;

  // 中间件
  List<Middleware> middleWares_;

  // 路由
  List<Router> routers_;

  // default handlers
  Map<int, HandlerAdapter> handlers_;

  // 转换器
  Map<ContentType, AbstractHttpMessageConverter> converters_;

  // 资源
  List<Resource> resources_;

  // 请求解析器
  Map<ResolverType, AbstractResolver> resolvers_;

  HttpRequestInterceptorChain httpRequestInterceptorChain_;

  HttpRequestLifecycleDelegate httpRequestLifecycleDelegate;

  ApplicationLifecycleDelegate applicationLifecycleDelegate;

  ApplicationSimplifyRouteDelegate applicationSimplifyRouteDelegate;

  ApplicationResourceDelegate applicationResourceDelegate;

  ApplicationRouteDelegate applicationRouteDelegate;

  ApplicationClosableDelegate applicationClosableDelegate;

  ApplicationLifecycleListener applicationLifecycleListener;
  
  // 临时存储监听器，在init()方法调用时添加
  List<AbstractListener> pendingListeners;

  HttpRequestContextDelegate httpRequestContextDelegate;

  HttpRequestHandlerDelegate httpRequestHandlerDelegate;

  HttpResponseConverterDelegate httpResponseConverterDelegate;

  ApplicationHttpServerDelegate applicationHttpServerDelegate;

  HttpRequestResolverDelegate httpRequestResolverDelegate;

  ApplicationInterceptorRegistryDelegate applicationInterceptorRegistryDelegate;

  ApplicationArgumentsParsedDelegate applicationArgumentsParsedDelegate;

  @override
  Future<void> init() async {
    // 保存现有的监听器
    List<AbstractListener> existingListeners = pendingListeners ?? [];
    
    this.middleWares_ = List();
    this.routers_ = List();
    this.handlers_ = Map();
    this.converters_ = Map();
    this.resolvers_ = Map();
    this.pendingListeners = [];

    applicationInitializer_ = ApplicationInitializer(this);
    applicationLifecycleDelegate = ApplicationLifecycleDelegate(this);
    applicationRouteDelegate = ApplicationRouteDelegate(this);
    applicationSimplifyRouteDelegate = ApplicationSimplifyRouteDelegate(this);
    applicationResourceDelegate = ApplicationResourceDelegate(this);
    applicationClosableDelegate = ApplicationClosableDelegate(this);
    applicationLifecycleListener = ApplicationLifecycleListener(this);
    
    // 添加所有临时存储的监听器
    for (AbstractListener listener in existingListeners) {
      applicationLifecycleListener.addListener(listener);
    }
    // 清空临时监听器列表
    pendingListeners.clear();
    
    httpRequestLifecycleDelegate = HttpRequestLifecycleDelegate(this);
    httpRequestContextDelegate = HttpRequestContextDelegate(this);
    httpRequestHandlerDelegate = HttpRequestHandlerDelegate(this);
    httpResponseConverterDelegate = HttpResponseConverterDelegate(this);
    applicationHttpServerDelegate = ApplicationHttpServerDelegate(this);
    httpRequestResolverDelegate = HttpRequestResolverDelegate(this);
    applicationInterceptorRegistryDelegate = ApplicationInterceptorRegistryDelegate(this);

    await this.applicationInitializer_.init();
  }

  // ip/端口监听
  @override
  void listen(int port, {InternetAddress internetAddress}) async =>
      applicationHttpServerDelegate.listen(port, internetAddress: internetAddress);

  // 加入一个中间件
  @override
  void use(Middleware middleware) {
    if (middleware != null) {
      this.middleWares_.add(middleware);
    }
  }

  // 使用中间件配置添加中间件
  @override
  void useWithConfig(Middleware middleware, {
    int priority,
    String name,
    String group,
    MiddlewareType type,
  }) {
    if (middleware != null) {
      // 覆盖中间件的属性
      if (priority != null) {
        middleware.priority = priority;
      }
      if (name != null) {
        middleware.name = name;
      }
      if (group != null) {
        middleware.group = group;
      }
      if (type != null) {
        middleware.type = type;
      }
      this.middleWares_.add(middleware);
    }
  }

  // 批量添加中间件
  @override
  void useAll(Iterable<Middleware> middlewares) {
    if (middlewares != null) {
      this.middleWares_.addAll(middlewares);
    }
  }

  // 按分组获取中间件
  @override
  List<Middleware> getMiddlewaresByGroup(String group) {
    return this.middleWares_.where((middleware) => middleware.group == group).toList();
  }

  // 按分组移除中间件
  @override
  void removeMiddlewaresByGroup(String group) {
    this.middleWares_.removeWhere((middleware) => middleware.group == group);
  }

  // 按名称获取中间件
  @override
  Middleware getMiddlewareByName(String name) {
    return this.middleWares_.firstWhere((middleware) => middleware.name == name, orElse: () => null);
  }

  // 按名称移除中间件
  @override
  void removeMiddlewareByName(String name) {
    this.middleWares_.removeWhere((middleware) => middleware.name == name);
  }

  // 按类型获取中间件
  @override
  List<Middleware> getMiddlewaresByType(MiddlewareType type) {
    return this.middleWares_.where((middleware) => middleware.type == type).toList();
  }

  // 移除所有中间件
  @override
  void clearMiddlewares() {
    this.middleWares_.clear();
  }

  @override
  void addResolver(ResolverType type, AbstractResolver resolver) {
    if (type != null && resolver != null) {
      httpRequestResolverDelegate.addResolver(type, resolver);
    }
  }

  // 匹配请求的content-type
  @override
  Future<AbstractResolver> matchResolver(HttpRequest req) => httpRequestResolverDelegate.matchResolver(req);

  // 预处理请求
  @override
  Future<Request> resolveRequest(HttpRequest req) => httpRequestResolverDelegate.resolveRequest(req);

  @override
  void addHandler(int httpStatus, HandlerAdapter handlerAdapter) {
    if (httpStatus != null && handlerAdapter != null) {
      httpRequestHandlerDelegate.addHandler(httpStatus, handlerAdapter);
    }
  }

  // 替换内置默认的handler
  @override
  void replaceHandler(int httpStatus, HandlerAdapter handlerAdapter) {
    if (httpStatus != null && handlerAdapter != null) {
      httpRequestHandlerDelegate.replaceHandler(httpStatus, handlerAdapter);
    }
  }

  // 替换内置转换器
  @override
  void replaceConverter(ContentType type, AbstractHttpMessageConverter converter) {
    if (type != null && converter != null) {
      httpResponseConverterDelegate.replaceConverter(type, converter);
    }
  }

  @override
  void addConverter(ContentType type, AbstractHttpMessageConverter converter) {
    if (type != null && converter != null) {
      httpResponseConverterDelegate.addConverter(type, converter);
    }
  }

  // 拦截器注册
  @override
  void registryInterceptor(AbstractInterceptor interceptor) {
    if (interceptor != null) {
      applicationInterceptorRegistryDelegate.registryInterceptor(interceptor);
    }
  }

  // 注册多个拦截器
  @override
  void registryInterceptors(Iterable<AbstractInterceptor> interceptors) {
    if (interceptors != null) {
      applicationInterceptorRegistryDelegate.registryInterceptors(interceptors);
    }
  }

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
  
  /// 注册Blueprint
  void registerBlueprint(Blueprint blueprint) {
    if (blueprint != null) {
      // 注册Blueprint中的所有路由
      routes(blueprint.routers);
    }
  }
  
  /// 注册多个Blueprint
  void registerBlueprints(Iterable<Blueprint> blueprints) {
    if (blueprints != null) {
      for (var blueprint in blueprints) {
        registerBlueprint(blueprint);
      }
    }
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
  void route(Router t) {
    if (t != null) {
      applicationRouteDelegate.route(t);
    }
  }

  @override
  void routes(Iterable<Router> t) {
    if (t != null) {
      applicationRouteDelegate.routes(t);
    }
  }

  // 资源维护
  @override
  void resource(String pattern, Resource resource) {
    if (pattern != null && resource != null) {
      applicationResourceDelegate.resource(pattern, resource);
    }
  }

  @override
  Future<dynamic> flush(String pattern) {
    if (pattern != null) {
      return applicationResourceDelegate.flush(pattern);
    }
    return Future.value(null);
  }

  @override
  Router patch(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) {
    if (path != null && handle != null) {
      return this.applicationSimplifyRouteDelegate.patch(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    }
    return null;
  }

  @override
  Router delete(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) {
    if (path != null && handle != null) {
      return this.applicationSimplifyRouteDelegate.delete(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    }
    return null;
  }

  @override
  Router put(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) {
    if (path != null && handle != null) {
      return this.applicationSimplifyRouteDelegate.put(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    }
    return null;
  }

  @override
  Router post(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) {
    if (path != null && handle != null) {
      return this.applicationSimplifyRouteDelegate.post(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    }
    return null;
  }

  @override
  Router get(String path, RouterHandleFunction handle,
          {Map pathVariables,
          ContentType produceType,
          AbstractHttpMessageConverter converter,
          HandlerAdapter handlerAdapter,
          String name}) {
    if (path != null && handle != null) {
      return this.applicationSimplifyRouteDelegate.get(path, handle,
          pathVariables: pathVariables, produceType: produceType, converter: converter, handlerAdapter: handlerAdapter, name: name);
    }
    return null;
  }

  @override
  dynamic getDelegate(Type delegateType) {
    if (delegateType != null) {
      return ApplicationReflectHelper.getDelegate(delegateType, [
        applicationArgumentsParsedDelegate,
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
    }
    return null;
  }

  @override
  void addListener(AbstractListener listener) {
    if (listener != null) {
      if (applicationLifecycleListener != null) {
        applicationLifecycleListener.addListener(listener);
      } else {
        // 暂时存储监听器，在init()方法调用时添加
        if (pendingListeners == null) {
          pendingListeners = [];
        }
        pendingListeners.add(listener);
      }
    }
  }

  @override
  void trigger(ApplicationListenerType type, List payload) {
    if (type != null) {
      applicationLifecycleListener.trigger(type, payload);
    }
  }

  @override
  Future<Context> createContext(HttpRequest httpRequest, HttpResponse httpResponse, {HttpRequestInterceptorState interceptorState}) {
    if (httpRequest != null && httpResponse != null) {
      return httpRequestContextDelegate.createContext(httpRequest, httpResponse, interceptorState: interceptorState);
    }
    return Future.value(null);
  }

  @override
  void args(List<String> arguments) {
    applicationArgumentsParsedDelegate = ApplicationArgumentsParsedDelegate(this);
    if (arguments != null) {
      applicationArgumentsParsedDelegate.args(arguments);
    }
  }

  @override
  List<String> get arguments => applicationArgumentsParsedDelegate.arguments;

  @override
  List<String> get parsedArguments => applicationArgumentsParsedDelegate.parsedArguments;
}
