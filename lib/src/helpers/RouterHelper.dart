import 'dart:io';
import 'dart:mirrors';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/AttributeValue.dart';
import 'package:Q/src/annotation/Body.dart';
import 'package:Q/src/annotation/Config.dart';
import 'package:Q/src/annotation/CookieValue.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/annotation/RequestHeader.dart';
import 'package:Q/src/annotation/RequestParam.dart';
import 'package:Q/src/annotation/SessionValue.dart';
import 'package:Q/src/annotation/UrlParam.dart';
import 'package:Q/src/exception/UnSupportRouterHandlerParameterAnnotationException.dart';
import 'package:Q/src/helpers/AnnotationHelpers.dart';
import 'package:Q/src/helpers/RedirectHelper.dart';
import 'package:Q/src/helpers/reflect/AttributeValueHelper.dart';
import 'package:Q/src/helpers/reflect/BodyReflectHelper.dart';
import 'package:Q/src/helpers/reflect/ConfigValueHelper.dart';
import 'package:Q/src/helpers/reflect/CookieValueHelper.dart';
import 'package:Q/src/helpers/reflect/PathVariableHelper.dart';
import 'package:Q/src/helpers/reflect/RequestHeaderHelper.dart';
import 'package:Q/src/helpers/reflect/RequestParamHelper.dart';
import 'package:Q/src/helpers/reflect/SessionValueHelper.dart';
import 'package:Q/src/helpers/reflect/UrlParamHelper.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

class RouterHelper {
  // 匹配重定向
  static Future<Router> matchRedirect(Redirect redirect, List<Router> routers) async {
    // 先路由名称匹配
    Router matchedRouter = await RedirectHelper.matchRouter(redirect, routers);
    if (matchedRouter == null) {
      await for (Router router in Stream.fromIterable(routers)) {
        bool hasMatch = await router.matchRedirect(redirect);
        if (hasMatch) {
          matchedRouter = router;
        }
      }
    }
    return matchedRouter;
  }

  // 匹配路由
  static Future<Router> matchRouter(HttpRequest req, List<Router> routers) async {
    Router matchedRouter;
    await for (Router router in Stream.fromIterable(routers)) {
      bool hasMatch = await router.match(req);
      if (hasMatch) {
        matchedRouter = router;
        matchedRouter.apply(req);
      }
    }
    return matchedRouter;
  }

  // 通过理由地址获取路由地址参数
  static Map<String, String> applyPathVariables(String requestPath, String path) {
    final parameters = <String>[];
    final regExp = pathToRegExp(path, parameters: parameters);
    final match = regExp.matchAsPrefix(requestPath);
    return extract(parameters, match);
  }

  // 检查路由路径是否有效
  static bool checkPathAvailable(String path) {
    if (path == null || path.isEmpty) return false;
    return true;
  }

  // 通过路由地址参数重建地址
  static String reBuildPathByVariables(Router router) {
    String path = router.path;
    router.pathVariables.forEach((dynamic key, dynamic val) {
      path = path.replaceAll(RegExp(":${key.toString()}"), val.toString());
    });
    return path;
  }

  // 反射获取路由处理器方法的参数列表
  static Future<List<dynamic>> listParameters(Router router) async {
    List<Future> futures = List();
    FunctionTypeMirror functionTypeMirror = reflect(router.handle).type;
    functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
      List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
      if (instanceMirrors.isNotEmpty) {
        for (InstanceMirror instanceMirror in instanceMirrors) {
          ClassMirror type = instanceMirror.type;
          List params = [router, parameterMirror, instanceMirror];
          if (type == reflectClass(PathVariable)) {
            futures.add(Function.apply(PathVariableHelper.reflectPathVariable, params));
            break;
          }
          if (type == reflectClass(CookieValue)) {
            futures.add(Function.apply(CookieValueHelper.reflectCookieValue, params));
            break;
          }
          if (type == reflectClass(RequestHeader)) {
            futures.add(Function.apply(RequestHeaderHelper.reflectRequestHeader, params));
            break;
          }
          if (type == reflectClass(SessionValue)) {
            futures.add(Function.apply(SessionValueHelper.reflectSessionValue, params));
            break;
          }
          if (type == reflectClass(AttributeValue)) {
            futures.add(Function.apply(AttributeValueHelper.reflectAttributeValue, params));
            break;
          }
          if (type == reflectClass(UrlParam)) {
            futures.add(Function.apply(UrlParamHelper.reflectUrlParams, params));
            break;
          }
          if (type == reflectClass(RequestParam)) {
            futures.add(Function.apply(RequestParamHelper.reflectRequestParam, params));
            break;
          }
          if (type == reflectClass(Config)) {
            futures.add(Function.apply(ConfigValueHelper.reflectConfigValue, params));
            break;
          }
          if (type == reflectClass(Body)) {
            futures.add(Function.apply(BodyReflectHelper.reflectBody, params));
            break;
          }
        }
      }
    });
    return await Future.wait(futures);
  }

  // 检查路由处理器上的注解参数是否合法
  static void checkoutRouterHandlerParameterAnnotations(Router router) {
    FunctionTypeMirror functionTypeMirror = reflect(router.handle).type;
    for (ParameterMirror parameterMirror in functionTypeMirror.parameters) {
      List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
      if (instanceMirrors.isNotEmpty) {
        for (InstanceMirror instanceMirror in instanceMirrors) {
          ClassMirror type = instanceMirror.type;
          if (SUPPORTED_ROUTER_HANDLER_PARAMETER_ANNOTATION_CLASSES.indexWhere((classMirror) => classMirror == type) == -1) {
            throw UnSupportRouterHandlerParameterAnnotationException(router: router, annotation: type.reflectedType);
          }
        }
      }
    }
  }

  // 默认路由根路径
  static String getPath(String path) {
    String defaultMapping = Application.getApplicationContext().configuration.routerMappingConfigure.defaultMapping;
    if (!path.startsWith(RegExp('^${defaultMapping}'))) {
      path = '$defaultMapping${path}';
    }
    return path;
  }
}
