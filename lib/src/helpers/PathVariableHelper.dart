import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class PathVariableHelper {
  // 通过反射获取使用PathVariable注解的参数
  static dynamic reflectPathVariable(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(PATH_VARIABLE_NAME)).reflectee;
      if (router.pathVariables.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror, router.pathVariables[nameValue]);
      }
    }
  }
}
