import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/SessionValue.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';

class SessionValueHelper {
  // 通过反射获取使用SessionValue注解的参数
  static dynamic reflectSessionValue(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(SESSION_NAME)).reflectee;
      if (router.context.request.req.session.containsKey(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror.type.reflectedType, router.context.request.req.session[nameValue]);
      }
    }
  }
}
