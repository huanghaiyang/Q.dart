import 'dart:io';
import 'dart:mirrors';

import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/helpers/RedirectHelper.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

class RouterHelper {
  // 反射获取路由地址参数
  static Map<String, dynamic> reflectPathVariables(Router router) {
    Map<String, dynamic> reflectedPathVariables = Map();
    FunctionTypeMirror functionTypeMirror = reflect(router.handle).type;
    functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
      List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
      if (instanceMirrors.isNotEmpty) {
        InstanceMirror pathVariableMirror = instanceMirrors.lastWhere((InstanceMirror instanceMirror) {
          return instanceMirror.type == reflectClass(PathVariable);
        });
        if (pathVariableMirror != null) {
          String nameValue = pathVariableMirror.getField(Symbol(PATH_VARIABLE_NAME)).reflectee;
          if (router.pathVariables.containsKey(nameValue)) {
            reflectedPathVariables[nameValue] = ReflectHelper.reflectParameterValue(parameterMirror, router.pathVariables[nameValue]);
          }
        }
      }
    });

    return reflectedPathVariables;
  }

  // 匹配重定向
  static Future<Router> matchRedirect(Redirect redirect, List<Router> routers) async {
    // 先路由名称匹配
    Router matchedRouter = await RedirectHelper.matchRouter(redirect);
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

  static Map<String, String> applyPathVariables(String requestPath, String path) {
    final parameters = <String>[];
    final regExp = pathToRegExp(path, parameters: parameters);
    final match = regExp.matchAsPrefix(requestPath);
    return extract(parameters, match);
  }

  static bool checkPathAvailable(String path) {
    if (path == null || path.isEmpty) return false;
    return true;
  }
}
