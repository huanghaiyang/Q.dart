import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/RequestParam.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class RequestParamHelper {
  // 通过反射获取使用RequestParam注解的参数
  static dynamic reflectSessionValue(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(PARAM_NAME)).reflectee;
      if (router.context.request.data.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror, router.context.request.data[nameValue]);
      }
    }
  }
}
