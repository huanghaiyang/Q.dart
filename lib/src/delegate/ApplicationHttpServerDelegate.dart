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
import 'package:Q/src/helpers/RouterHelper.dart';
import 'package:curie/curie.dart';

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
      // 处理拦截
      bool suspend = await this.applyPreHandler(req, res);
      // 如果返回false，则表示拦截器已经处理了当前请求，不需要再匹配路由、处理请求、消费中间件
      if (suspend) {
        // 创建请求上下文
        Context context = await this.application.createContext(req, res);
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
        await this.applyPostHandler(req, res);
      }
      await ApplicationHelper.makeSureResponseRelease(res);
      return true;
    }
    return false;
  }

  // 执行拦截器的preHandler
  Future<bool> applyPreHandler(HttpRequest req, HttpResponse res) async {
    List<Function> functions = List();
    for (int i = 0; i < this.application.interceptors.length; i++) {
      functions.add(() async {
        bool suspend;
        try {
          suspend = await this.application.interceptors[i].preHandle(req, res);
        } catch (e, s) {
          // 如果拦截器执行preHandler时抛出异常，则终止请求
          suspend = true;
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
        }
        return suspend;
      });
    }
    bool suspend = await everySeries(functions);
    return suspend;
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
    Router matchedRouter = await RouterHelper.matchRouter(req, this.application.routers);
    if (matchedRouter != null) {
      // 设置当前请求上下文的路由
      context.setRouter(matchedRouter);
      matchedRouter.context = context;
      // 处理路由请求
      await this.handleRouter(matchedRouter, context, req);
    } else {
      // TODO throw router not found exception
      await this.application.handlers[HttpStatus.notFound].handle(context);
    }
    return context;
  }

  // 路由处理，响应请求
  Future<Context> handleRouter(Router matchedRouter, Context context, HttpRequest req) async {
    // 通过反射获取当前请求处理函数上定义的路径参数
    List<dynamic> reflectedParameters = await RouterHelper.listParameters(matchedRouter);
    // 合并参数
    List positionArguments = List()..addAll([context, context.request.req, context.response.res])..addAll(reflectedParameters);
    // 等待结果处理完成
    dynamic result = await Function.apply(matchedRouter.handle, positionArguments);
    // 如果执行的结果是一个重定向
    if (result is Redirect) {
      // 根据重定向匹配路由并执行
      await this.handleRedirect(context, result, req);
    } else {
      ResponseEntry responseEntry = ResponseEntry.from(result);
      // 将执行结果赋值给上线文的响应
      context.response.responseEntry = responseEntry;
      // 转换后的而结果，类型为String
      dynamic convertedResult = await matchedRouter.convert(responseEntry);
      responseEntry.convertedResult = convertedResult;
      // 写response,完成请求
      await matchedRouter.write(context);
    }
    return context;
  }

  // 处理重定向
  Future<Context> handleRedirect(Context context, Redirect redirect, HttpRequest req) async {
    // 根据重定向的地址匹配路由
    Router matchedRouter = await RouterHelper.matchRedirect(redirect, this.application.routers);
    if (matchedRouter != null) {
      matchedRouter.mergePathVariables(
          redirect.isName ? redirect.pathVariables : RouterHelper.applyPathVariables(matchedRouter.path, redirect.path));
      // 根据参数构建请求地址，此地址不是从request.uri.path取到的
      matchedRouter.requestUri = RouterHelper.reBuildPathByVariables(matchedRouter);
      // 重新设置请求上下文的路由
      context.setRouter(matchedRouter);
      // 合并当前请求上下文中的attributes数据
      context.mergeAttributes(redirect.attributes);
      // 处理路由请求
      return this.handleRouter(matchedRouter, context, req);
    } else {
      throw Exception('redirect ${redirect.address} not found.');
    }
  }

  // 执行拦截器的postHandler
  void applyPostHandler(HttpRequest req, HttpResponse res) async {
    List<Function> functions = List();
    for (int i = this.application.interceptors.length - 1; i >= 0; i--) {
      functions.add(() async {
        return this.application.interceptors[i].postHandle(req, res);
      });
    }
    // 处理每一个拦截器的后置处理方法
    await eachSeries(functions);
  }
}
