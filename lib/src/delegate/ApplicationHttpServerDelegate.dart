import 'dart:async';
import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/ApplicationStage.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';
import 'package:Q/src/Redirect.dart';
import 'package:Q/src/ResponseEntry.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/aware/ApplicationHttpServerAware.dart';
import 'package:Q/src/configure/ServerConfigure.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/delegate/ApplicationLifecycleDelegate.dart';
import 'package:Q/src/delegate/HttpRequestLifecycleDelegate.dart';
import 'package:Q/src/helpers/ApplicationHelper.dart';
import 'package:Q/src/helpers/AsyncHelper.dart';
import 'package:Q/src/helpers/ResponseHelper.dart';
import 'package:Q/src/helpers/RouterHelper.dart';
import 'package:Q/src/utils/connectionpool/RouterConnectionPool.dart';
import 'package:Q/src/utils/connectionpool/ConnectionPool.dart';
import 'package:Q/src/interceptor/HttpRequestInterceptorState.dart';
import 'package:Q/src/request/RequestTimeout.dart';
import 'package:Q/src/request/RouterStage.dart';

abstract class ApplicationHttpServerDelegate extends ApplicationHttpServerAware with AbstractDelegate {
  factory ApplicationHttpServerDelegate(Application application) => _ApplicationHttpServerDelegate(application);

  factory ApplicationHttpServerDelegate.from(Application application) {
    return application.getDelegate(ApplicationHttpServerDelegate);
  }

  dynamic close();
}

class _ApplicationHttpServerDelegate implements ApplicationHttpServerDelegate {
  final Application application;

  HttpServer server;
  
  // 路由连接池
  RouterConnectionPool _routerConnectionPool;

  _ApplicationHttpServerDelegate(this.application) {}

  /// 初始化路由连接池
  void _initRouterConnectionPool() async {
    ServerConfigure serverConfigure = this.application.applicationContext.configuration.serverConfigure;
    // 初始化路由连接池
    _routerConnectionPool = RouterConnectionPool(
      maxConcurrentConnections: serverConfigure.maxConcurrentConnections,
      connectionTimeout: Duration(seconds: serverConfigure.connectionTimeout)
    );
  }

  // ip/端口监听
  @override
  void listen(int port, {InternetAddress internetAddress, int backlog = 5000, bool v6Only = false, bool shared = true}) async {
    try {
      // 初始化路由连接池
      await _initRouterConnectionPool();

      this.application.applicationContext.currentStage = ApplicationStage.STARTING;
      // 默认ipv4
      internetAddress = internetAddress != null ? internetAddress : InternetAddress.loopbackIPv4;
      // 创建服务，启用连接池
      print('Starting server on $internetAddress:$port with backlog=$backlog');
      this.server = await HttpServer.bind(
        internetAddress, 
        port,
        backlog: backlog,
        v6Only: v6Only,
        shared: shared
      )
          .catchError((e) {
            print('Error binding server: $e');
            throw e;
          })
          .whenComplete(() {
            print('Server bound successfully');
            ApplicationLifecycleDelegate.from(application).onStartup();
          });
      
      // 配置连接池参数
      int sessionTimeout = this.application.applicationContext.configuration.serverConfigure.sessionTimeout;
      this.server.sessionTimeout = sessionTimeout;
      this.application.applicationContext.currentStage = ApplicationStage.RUNNING;
      print('Server started with connection pool enabled.');
      print('Server session timeout: $sessionTimeout seconds');
      print('Max concurrent connections: ${this.application.applicationContext.configuration.serverConfigure.maxConcurrentConnections}');
      
      // 处理请求
      print('Starting to handle requests...');
      int requestCount = 0;
      await for (HttpRequest req in this.server) {
        requestCount++;
        if (requestCount % 100 == 0) {
          print('Handled $requestCount requests');
        }
        // 使用异步处理，避免阻塞事件循环
        Future.microtask(() {
          handleRequest(req).catchError((e, s) {
            print('Exception details:\n $e');
            print('Stack trace:\n $s');
          });
        });
      }
    } catch (e, s) {
      print('Server error: $e');
      print('Stack trace: $s');
      // 尝试关闭服务器
      try {
        if (this.server != null) {
          await this.server.close();
        }
      } catch (closeError) {
        print('Error closing server: $closeError');
      }
    }
  }

  @override
  dynamic close() {
    // 关闭路由连接池
    _routerConnectionPool.close();
    // 关闭服务器
    return this.server.close();
  }

  // 请求处理
  Future<dynamic> handleRequest(HttpRequest req) async {
    if (this.application.applicationContext.currentStage == ApplicationStage.RUNNING) {
      HttpResponse res = req.response;
      HttpRequestInterceptorState interceptorState = HttpRequestInterceptorState();
      
      try {
        // 处理拦截
        bool suspend = await this.application.httpRequestInterceptorChain.applyPreHandle(req, res, interceptorState);
        
        // 如果返回true，则继续处理请求
        if (suspend) {
          // 创建请求上下文
          Context context = await this.application.createContext(req, res, interceptorState: interceptorState);
          // 前置中间件处理
          await this.handleWithMiddleware(
              context,
              MiddlewareType.BEFORE,
              this.application.getDelegate(HttpRequestLifecycleDelegate).onMiddleware,
              this.application.getDelegate(HttpRequestLifecycleDelegate).onMiddlewareError);
          // 匹配路由并处理请求
          await this.applyRouter(context, req);
          // 后置中间件处理
          await this.handleWithMiddleware(
              context,
              MiddlewareType.AFTER,
              this.application.getDelegate(HttpRequestLifecycleDelegate).onMiddleware,
              this.application.getDelegate(HttpRequestLifecycleDelegate).onMiddlewareError);
          // 执行后置拦截器方法
          await this.application.httpRequestInterceptorChain.applyPostHandle(req, res, interceptorState);
        }
      } on SocketException catch (e, s) {
        print('SocketException: $e');
        print('Stack trace: $s');
        // 处理网络异常，确保响应被正确关闭
        try {
          res.statusCode = HttpStatus.serviceUnavailable;
          await res.flush();
        } catch (flushError) {
          print('Error flushing response: $flushError');
        }
      } catch (e, s) {
        print('Request handling error: $e');
        print('Stack trace: $s');
        // 处理其他错误
        try {
          // 尝试使用已有的上下文或创建新的上下文
          Context errorContext;
          try {
            errorContext = await this.application.createContext(req, res);
            await this.application.handlers[HttpStatus.internalServerError].handle(errorContext);
          } catch (contextError) {
            print('Error creating context: $contextError');
            // 如果创建上下文失败，直接设置状态码
            res.statusCode = HttpStatus.internalServerError;
            await res.flush();
          }
        } catch (errorHandlingError) {
          print('Error handling error: $errorHandlingError');
          // 如果错误处理也失败，确保响应被正确关闭
          try {
            res.statusCode = HttpStatus.internalServerError;
            await res.flush();
          } catch (flushError) {
            print('Error flushing response: $flushError');
          }
        }
      } finally {
        // 确保响应被正确释放
        try {
          await ApplicationHelper.makeSureResponseRelease(res);
        } catch (e) {
          print('Error releasing response: $e');
        }
      }
      
      return true;
    }
    return false;
  }

  // response中间件
  Future<Context> handleWithMiddleware(Context context, MiddlewareType type, Function onFinished, Function onError) async {
    // 按优先级排序，值越大优先级越高
    List<Middleware> sortedMiddlewares = this.application.middleWares
        .where((Middleware middleware) => middleware.type == type)
        .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
    
    for (Middleware middleware in sortedMiddlewares) {
      try {
        await middleware.handle(context, onFinished, onError);
      } catch (e, stackTrace) {
        print('Middleware error (${middleware.name ?? middleware.runtimeType}): $e');
        print('Stack trace: $stackTrace');
        
        // 调用错误处理函数
        if (onError != null) {
          try {
            await onError(e, stackTrace, context);
          } catch (errorHandlingError) {
            print('Error handling error: $errorHandlingError');
          }
        }
        
        // 可以选择是否继续执行其他中间件
        // 这里选择继续执行，因为一个中间件的错误不应该影响其他中间件
      }
    }
    return context;
  }

  // 匹配路由，并处理请求
  Future<Context> applyRouter(Context context, HttpRequest req) async {
    // 匹配路由
    Router router = await RouterHelper.matchRouter(req, this.application.routers);
    if (router != null) {
      // 设置当前请求上下文的路由
      context.setRouter(router);
      router.context = context;
      // 处理路由请求
      await this.handleRouter(router, context, req);
    } else {
      // TODO throw router not found exception
      await this.application.handlers[HttpStatus.notFound].handle(context);
    }
    return context;
  }

  // 路由处理，响应请求
  Future<Context> handleRouter(Router router, Context context, HttpRequest req) async {
    Connection connection = null;
    try {
      // 获取路由连接
      connection = await _routerConnectionPool.acquireConnection();
      
      // 处理路由请求
      await this._applyRouterChain(router, router);
      List positionArguments = await this._applyReflectParams(router, context);
      dynamic result = await this._applyHandler(router, positionArguments);
      // 如果执行的结果是一个重定向
      if (result is Redirect) {
        await this._applyRedirect(router, context, result, req);
      } else {
        await this._applyConvertResult(router, result, context);
        await this._applyWrite(router, context);
      }
    } on SocketException catch (e, s) {
      print('Router handling SocketException: $e');
      print('Stack trace: $s');
      // 处理网络异常
      try {
        context.response.res.statusCode = HttpStatus.serviceUnavailable;
        await context.response.res.flush();
      } catch (flushError) {
        print('Error flushing response: $flushError');
      }
    } on TimeoutException catch (e, s) {
      print('Router handling TimeoutException: $e');
      print('Stack trace: $s');
      // 处理超时异常
      try {
        context.response.res.statusCode = HttpStatus.gatewayTimeout;
        await context.response.res.flush();
      } catch (flushError) {
        print('Error flushing response: $flushError');
      }
    } catch (e, s) {
      print('Router handling error: $e');
      print('Stack trace: $s');
      // 处理其他错误
      try {
        await this.application.handlers[HttpStatus.internalServerError].handle(context);
      } catch (errorHandlingError) {
        print('Error handling error: $errorHandlingError');
        // 如果错误处理也失败，确保响应被正确关闭
        try {
          context.response.res.statusCode = HttpStatus.internalServerError;
          await context.response.res.flush();
        } catch (flushError) {
          print('Error flushing response: $flushError');
        }
      }
    } finally {
      // 释放连接
      if (connection != null) {
        _routerConnectionPool.releaseConnection(connection);
      }
    }
    return context;
  }

  Future _applyRouterChain(Router router, Router next) async {
    router.chain.nextRouter(next);
  }

  Future _applyHandler(Router router, List positionArguments) async {
    router.state.stage = RouterStage.AFTER_APPLY_HANDLER;
    // 等待结果处理完成
    dynamic result;
    dynamic handler = Function.apply(router.handle, positionArguments);
    if (router.timeout != null && router.timeout.timeoutValue > Duration(milliseconds: 0)) {
      result = await handleRouterTimeout(router, handler);
    } else {
      result = await handler;
    }
    router.state.stage = RouterStage.AFTER_APPLY_HANDLER;
    return result;
  }

  Future _applyReflectParams(Router router, Context context) async {
    router.state.stage = RouterStage.BEFORE_REFLECT_PARAMS;
    // 通过反射获取当前请求处理函数上定义的路径参数
    List<dynamic> reflectedParameters = await RouterHelper.listParameters(router);
    // 合并参数
    List positionArguments = List()..addAll([context, context.request.req, context.response.res])..addAll(reflectedParameters);
    router.state.stage = RouterStage.AFTER_REFLECT_PARAMS;
    return positionArguments;
  }

  Future _applyConvertResult(Router router, dynamic result, Context context) async {
    router.state.stage = RouterStage.BEFORE_CONVERT_RESULT;
    ResponseEntry responseEntry = ResponseEntry.from(result);
    // 将执行结果赋值给上线文的响应
    context.response.responseEntry = responseEntry;
    // 转换后的而结果，类型为String
    dynamic convertedResult = await router.convert(responseEntry);
    responseEntry.convertedResult = convertedResult;
    router.state.stage = RouterStage.AFTER_CONVERT_RESULT;
  }

  Future _applyRedirect(Router router, Context context, Redirect redirect, HttpRequest req) async {
    router.state.stage = RouterStage.BEFORE_REDIRECT;
    // 根据重定向匹配路由并执行
    await this.handleRedirect(context, redirect, req);
    router.state.stage = RouterStage.AFTER_REDIRECT;
  }

  Future _applyWrite(Router router, Context context) async {
    router.state.stage = RouterStage.BEFORE_WRITE;
    // 写response,完成请求
    await router.write(context);
    router.state.stage = RouterStage.AFTER_WRITE;
  }

  // 处理重定向
  Future<Context> handleRedirect(Context context, Redirect redirect, HttpRequest req) async {
    // 根据重定向的地址匹配路由
    Router router = await RouterHelper.matchRedirect(redirect, this.application.routers);
    await this._applyRouterChain(context.router, router);
    if (router != null) {
      router.mergePathVariables(redirect.isName ? redirect.pathVariables : RouterHelper.applyPathVariables(router.path, redirect.path));
      // 根据参数构建请求地址，此地址不是从request.uri.path取到的
      router.requestUri = RouterHelper.reBuildPathByVariables(router);
      // 重新设置请求上下文的路由
      context.setRouter(router);
      // 合并当前请求上下文中的attributes数据
      context.mergeAttributes(redirect.attributes);
      // 处理路由请求
      return this.handleRouter(router, context, req);
    } else {
      throw Exception('redirect ${redirect.address} not found.');
    }
  }

  // 路由处理超时
  Future<dynamic> handleRouterTimeout(Router router, Future task) async {
    RequestTimeout requestTimeout = router.timeout;
    return AsyncHelper.timeout(requestTimeout.timeoutValue, task, requestTimeout.timeoutResult);
  }
}
