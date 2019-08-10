import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/helpers/reflect/ReflectHelper.dart';

class PathVariableHelper {
  // 通过反射获取使用PathVariable注解的参数
  static Future<dynamic> reflectPathVariable(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(PATH_VARIABLE_NAME)).reflectee;
      if (nameValue == null) return null;
      if (router.pathVariables.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror.type.reflectedType, router.pathVariables[nameValue]);
      }
    }
  }
}
