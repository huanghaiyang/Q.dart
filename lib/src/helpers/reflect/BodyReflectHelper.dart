import 'dart:io';
import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/Body.dart';
import 'package:Q/src/annotation/RequestParam.dart';
import 'package:Q/src/exception/RequestParamRequiredException.dart';
import 'package:Q/src/helpers/reflect/ReflectHelper.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/query/CommonValue.dart';
import 'package:Q/src/query/MultipartFile.dart';

class BodyReflectHelper {
  // 通过反射获取使用RequestParam注解的参数
  static Future<dynamic> reflectBody(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      String name = annotationMirror.getField(Symbol(BODY_NAME)).reflectee;
      Map data = router?.context?.request?.data;
      if (data == null) return null;
      // 参数类型
      Type parameterType = parameterMirror.type.reflectedType;
      // multipart/form-data类型
      if (data is MultipartValueMap) {
        // TODO 
      }
    }
  }
}
