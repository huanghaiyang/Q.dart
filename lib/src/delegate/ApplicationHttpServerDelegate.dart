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
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/delegate/ApplicationLifecycleDelegate.dart';
import 'package:Q/src/delegate/HttpRequestLifecycleDelegate.dart';
import 'package:Q/src/helpers/ApplicationHelper.dart';
import 'package:Q/src/helpers/AsyncHelper.dart';
import 'package:Q/src/helpers/RouterHelper.dart';
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

  _ApplicationHttpServerDelegate(this.application);

  // ip/端口监听
  @override
  void listen(int port, {InternetAddress internetAddress}) async {
    this.application.applicationContext.currentStage = ApplicationStage.STARTING;
    // 默认ipv4
    internetAddress = internetAddress != null ? internetAddress : InternetAddress.loopbackIPv4;
    // 创建服务
    this.server = await HttpServer.bind(internetAddress, port)
        .catchError(ApplicationLifecycleDelegate.from(application).onError)
        .whenComplete(ApplicationLifecycleDelegate.from(application).onStartup);
    this.application.applicationContext.currentStage = ApplicationStage.RUNNING;
    // 处理请求
    await for (HttpRequest req in this.server) {
      try {
        await this.handleRequest(req);
      } catch (e, s) {
        print('Exception details:\n $e');
        print('Stack trace:\n $s');
      }
    }
  }

  @override
  dynamic close() {
    return this.server.close();
  }

  // 请求处理
  Future<dynamic> handleRequest(HttpRequest req) async {
    if (this.application.applicationContext.currentStage == ApplicationStage.RUNNING) {
      HttpResponse res = req.response;
      HttpRequestInterceptorState interceptorState = HttpRequestInterceptorState();
      // 处理拦截
      bool suspend = await this.application.httpRequestInterceptorChain.applyPreHandle(req, res, interceptorState);
      // 如果返回false，则表示拦截器已经处理了当前请求，不需要再匹配路由、处理请求、消费中间件
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
      await ApplicationHelper.makeSureResponseRelease(res);
      return true;
    }
    return false;
  }

  // response中间件
  Future<Context> handleWithMiddleware(Context context, MiddlewareType type, Function onFinished, Function onError) async {
    await for (Middleware middleware
        in Stream.fromIterable(this.application.middleWares.where((Middleware middleware) => middleware.type == type))) {
      await middleware.handle(context, onFinished, onError);
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
    List positionArguments = await this._applyReflectParams(router, context);
    dynamic result = await this._applyHandler(router, positionArguments);
    // 如果执行的结果是一个重定向
    if (result is Redirect) {
      await this._applyRedirect(router, context, result, req);
    } else {
      await this._applyConvertResult(router, result, context);
      await this._applyWrite(router, context);
    }
    return context;
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

  Future _applyRedirect(Router router, Context context, dynamic result, HttpRequest req) async {
    router.state.stage = RouterStage.BEFORE_REDIRECT;
    // 根据重定向匹配路由并执行
    await this.handleRedirect(context, result, req);
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
