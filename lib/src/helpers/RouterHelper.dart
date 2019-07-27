import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class RouterHelper {
  // 反射获取路由地址参数
  static Map<String, dynamic> reflectPathVariables(Router router) {
    Map<String, dynamic> reflectedPathVariables = Map();
    RouterHandleFunction routerHandleFunction = router.handle;
    FunctionTypeMirror functionTypeMirror = reflect(routerHandleFunction).type;
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
}
