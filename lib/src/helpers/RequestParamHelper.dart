import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/RequestParam.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class RequestParamHelper {
  // 通过反射获取使用RequestParam注解的参数
  static dynamic reflectRequestParam(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(PARAM_NAME)).reflectee;
      if (nameValue == null) return null;
      Map data = router?.context?.request?.data;
      if (data == null) return null;
      if (router.context.request.data.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValues(
            parameterMirror.type.reflectedType, router.context.request.data[nameValue]);
      }
    }
  }
}
