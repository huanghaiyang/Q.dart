import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/UrlParam.dart';
import 'package:Q/src/helpers/reflect/ReflectHelper.dart';

class UrlParamHelper {
  // 通过反射获取使用UrlParam注解的参数
  static Future<dynamic> reflectUrlParams(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(QUERY_PARAM_NAME)).reflectee;
      if (router.query.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValues(parameterMirror.type.reflectedType, router.query[nameValue]);
      }
    }
  }
}
