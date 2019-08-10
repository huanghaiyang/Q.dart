import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/CookieValue.dart';
import 'package:Q/src/helpers/reflect/ReflectHelper.dart';

class CookieValueHelper {
  // 通过反射获取使用CookieValue注解的参数
  static Future<dynamic> reflectCookieValue(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(COOKIE_NAME)).reflectee;
      if (nameValue == null) return null;
      if (router.context.hasCookie(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror.type.reflectedType, router.context.getCookie(nameValue).value);
      }
    }
  }
}
