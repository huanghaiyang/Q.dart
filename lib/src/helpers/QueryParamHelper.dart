import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/QueryParam.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class QueryParamHelper {
  // 通过反射获取使用QueryParam注解的参数
  static dynamic reflectQueryParams(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(QUERY_PARAM_NAME)).reflectee;
      if (router.query.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValues(parameterMirror.type.reflectedType, router.query[nameValue]);
      }
    }
  }
}
