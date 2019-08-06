import 'dart:io';
import 'dart:mirrors';

import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/AttributeValue.dart';
import 'package:Q/src/annotation/CookieValue.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/annotation/QueryParam.dart';
import 'package:Q/src/annotation/RequestHeader.dart';
import 'package:Q/src/annotation/SessionValue.dart';
import 'package:Q/src/helpers/AttributeValueHelper.dart';
import 'package:Q/src/helpers/CookieValueHelper.dart';
import 'package:Q/src/helpers/PathVariableHelper.dart';
import 'package:Q/src/helpers/QueryParamHelper.dart';
import 'package:Q/src/helpers/RedirectHelper.dart';
import 'package:Q/src/helpers/RequestHeaderHelper.dart';
import 'package:Q/src/helpers/SessionValueHelper.dart';
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
  static List<dynamic> listParameters(Router router) {
    List<dynamic> parameters = List();
    FunctionTypeMirror functionTypeMirror = reflect(router.handle).type;
    functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
      List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
      if (instanceMirrors.isNotEmpty) {
        for (InstanceMirror instanceMirror in instanceMirrors) {
          ClassMirror type = instanceMirror.type;
          List params = [router, parameterMirror, instanceMirror];
          if (type == reflectClass(PathVariable)) {
            parameters.add(Function.apply(PathVariableHelper.reflectPathVariable, params));
            break;
          }
          if (type == reflectClass(CookieValue)) {
            parameters.add(Function.apply(CookieValueHelper.reflectCookieValue, params));
            break;
          }
          if (type == reflectClass(RequestHeader)) {
            parameters.add(Function.apply(RequestHeaderHelper.reflectRequestHeader, params));
            break;
          }
          if (type == reflectClass(SessionValue)) {
            parameters.add(Function.apply(SessionValueHelper.reflectSessionValue, params));
            break;
          }
          if (type == reflectClass(AttributeValue)) {
            parameters.add(Function.apply(AttributeValueHelper.reflectAttributeValue, params));
            break;
          }
          if (type == reflectClass(QueryParam)) {
            parameters.add(Function.apply(QueryParamHelper.reflectQueryParams, params));
            break;
          }
          if (parameterMirror.hasDefaultValue) {
            parameters.add(parameterMirror.defaultValue);
          }
        }
      }
    });
    return parameters;
  }
}
