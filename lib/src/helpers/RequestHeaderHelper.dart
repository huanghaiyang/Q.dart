import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/RequestHeader.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class RequestHeaderHelper {
  // 通过反射获取使用PathVariable注解的参数
  static dynamic reflectRequestHeader(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(HEADER_NAME)).reflectee;
      if (nameValue == null) return null;
      return ReflectHelper.reflectParameterValue(
          parameterMirror.type.reflectedType, router.context.request.req.headers.value(nameValue.toLowerCase()));
    }
  }
}
