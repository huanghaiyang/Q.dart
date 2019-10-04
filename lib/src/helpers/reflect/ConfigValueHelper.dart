import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/Config.dart';
import 'package:Q/src/configure/ApplicationConfigurationMapper.dart';
import 'package:Q/src/helpers/reflect/ReflectHelper.dart';

class ConfigValueHelper {
  // 通过反射获取使用CookieValue注解的参数
  static Future<dynamic> reflectConfigValue(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(CONFIG_NAME)).reflectee;
      if (nameValue == null) return null;
      if (router.context.hasCookie(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror.type.reflectedType, ApplicationConfigurationMapper.get(nameValue));
      }
    }
  }
}
