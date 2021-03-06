import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/AttributeValue.dart';
import 'package:Q/src/helpers/reflect/ReflectHelper.dart';

class AttributeValueHelper {
  // 通过反射获取使用AttributeValue注解的参数
  static Future<dynamic> reflectAttributeValue(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      String nameValue = annotationMirror.getField(Symbol(ATTRIBUTE_NAME)).reflectee;
      if (nameValue == null) return null;
      if (router.context.hasAttribute(nameValue)) {
        return ReflectHelper.reflectParameterValue(parameterMirror.type.reflectedType, router.context.getAttribute(nameValue).value);
      }
    }
  }
}
